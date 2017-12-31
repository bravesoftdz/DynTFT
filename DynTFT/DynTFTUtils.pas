{   DynTFT  - graphic components for microcontrollers
    Copyright (C) 2017 VCC
    release date: 29 Dec 2017
    author: VCC

    This file is part of DynTFT project.

    DynTFT is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, version 3 of the License.

    DynTFT is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with DynTFT, in COPYING.LESSER file.
    If not, see <http://www.gnu.org/licenses/>.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
    DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
    OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

unit DynTFTUtils;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{ - VCC -
2017.11.28 - Created file

This unit calls VTFT functions and allows user code to be called when required.
For example, additional operations have to be performed after setting a color.
It uses project-level compiler directives.
}



{$IFNDEF UserTFTCommands}  //this can be a project-level definition
  {$DEFINE mikroTFT}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  DynTFTTypes
  {$IFDEF mikroTFT}
    {$DEFINE MissingStuff}

    {$IFDEF IsDesktop}
      ,TFT
    {$ELSE}
      //,__Lib_TFT
    {$ENDIF}
  {$ENDIF}

  {$IFDEF userTFT}
    {$IFNDEF MissingStuff}
      {$DEFINE MissingStuff}
    {$ENDIF}
    UserTFT
  {$ENDIF}

  {$IFDEF IsDesktop}
    ,Classes, SysUtils, Graphics, Forms, StdCtrls
  {$ENDIF}

  {$IFDEF UserTFTCommands}  //this can be a project-level definition
    {$INCLUDE UserDrawingUnits.inc} //if required
  {$ENDIF}
  ;

{$IFNDEF IsDesktop}
  {$IFDEF AppArch32}     //e.g. PIC32
    {$UNDEF AppArch32}
  {$ENDIF}
  
  {$IFDEF AppArch16}     //e.g. dsPIC / PIC24
    {$UNDEF AppArch16}
  {$ENDIF}

  {$IFDEF P30}
    {$DEFINE AppArch16}
  {$ENDIF}

  {$IFDEF P33}
    {$DEFINE AppArch16}
  {$ENDIF}

  {$IFDEF P24}
    {$DEFINE AppArch16}
  {$ENDIF}

  {$IFNDEF AppArch16}    //16-bit not defined,
    {$DEFINE AppArch32}  //then it must be 32-bit !
  {$ENDIF}

type
  //PByte = ^Byte;
  {$IFDEF AppArch16}
    PByte = ^far const code Byte;
  {$ELSE}
    PByte = ^const code Byte;
  {$ENDIF}
{$ENDIF}

{$IFNDEF IsDesktop}
  procedure DynTFTCopyStr(var S: string; Index: Integer; Count: Integer; var Result: string);
  procedure DynTFTDelete(var S: string; Index: Integer; Count: Integer);
  procedure DynTFTInsert(var Substr: string; var Dest: string; Index: Integer);
{$ENDIF}

procedure DynTFT_Init(display_width, display_height: Word);
procedure DynTFT_Set_Pen(pen_color: TColor; pen_width: Byte);
procedure DynTFT_Set_Brush(brush_enabled: Byte; brush_color: TColor; gradient_enabled, gradient_orientation: Byte; gradient_color_from, gradient_color_to: TColor);
procedure DynTFT_Set_Font(activeFont: PByte; font_color: TColor; font_orientation: Word);
procedure DynTFT_Write_Text({$IFDEF IsMCU} var {$ENDIF} AText: string; x, y: Word);
procedure DynTFT_Line(x1, y1, x2, y2: Integer);
procedure DynTFT_Dot(x, y: Integer; Color: TColor);
procedure DynTFT_Fill_Screen(color: TColor);
procedure DynTFT_Rectangle(x_upper_left, y_upper_left, x_bottom_right, y_bottom_right: Integer);
procedure DynTFT_Circle(x_center, y_center, radius: Integer);

{$IFDEF IsDesktop}
  procedure GetTextWidthAndHeight(AText: string; var Width, Height: Word);
{$ELSE}
  procedure GetTextWidthAndHeight(var AText: string; var Width, Height: Word);
{$ENDIF}


{$IFDEF IsDesktop}
  procedure DynTFT_AssignDebugConsole(AComp: TComponent); //this should be a TListBox or a TMemo
  procedure DynTFT_DebugConsole(AText: string);
{$ELSE}
  procedure DynTFT_DebugConsole(var AText: string);
{$ENDIF}


{$IFDEF MissingStuff}
  {$IFDEF IsDesktop}
    var
      TFT_defaultFont: Byte;
  {$ENDIF}
{$ENDIF}

implementation

{$IFDEF IsDesktop}
  var
    DebugComponent: TComponent;
{$ENDIF}

{$IFNDEF IsDesktop}
  procedure DynTFTCopyStr(var S: string; Index: Integer; Count: Integer; var Result: string);
  var
    i: Integer;
  begin
    if (Count <= 0) or (s[0] = #0) or (Index > Length(S)) then
    begin
      Result[0] := #0;
      Exit;
    end;

    Index := Max(Index, 0);
    Count := Min(Count, Length(S) - Index + 1);

    Dec(Count); //used by for
    for i := 0 to Count do
      Result[i] := S[i + Index];

    Result[Count + 1] := #0;
  end;
  

  procedure DynTFTDelete(var S: string; Index: Integer; Count: Integer);
  var
    i, RemainingCount, Offset: Integer;
  begin
    if (Count <= 0) or (Index >= Length(S)) or (Index < 0) then
      Exit;

    Count := Min(Count, Length(S) - Index + 1);
    RemainingCount := Length(S) - Index - Count;

    for i := 1 to RemainingCount do
    begin
      Offset := i + Index - 1;
      S[Offset] := S[Offset + Count];
    end;

    if Length(S) >= Count then
      S[Length(S) - Count] := #0
    else
      S[0] := #0;
  end;


  procedure DynTFTInsert(var Substr: string; var Dest: string; Index: Integer);
  var
    i, Offset, SubstrLen, RemainingCount: Integer;
  begin
    if Index < 0 then
      Index := 0;

    Index := Min(Index, Length(Dest));
    SubstrLen := Length(Substr);

    RemainingCount := Length(Dest) - Index;
                 
    for i := RemainingCount downto 1 do
    begin
      Offset := i + Index - 1;
      Dest[Offset + SubstrLen] := Dest[Offset];
    end;

    for i := Index to Index + SubstrLen - 1 do
      Dest[i] := Substr[i - Index];

    Dest[RemainingCount + SubstrLen + Index] := #0;
  end;
{$ENDIF}


{$IFNDEF UserTFTCommands}

  procedure DynTFT_Init(display_width, display_height: Word);
  begin
    TFT_Init(display_width, display_height);
  end;
  

  procedure DynTFT_Set_Pen(pen_color: TColor; pen_width: Byte);
  begin
    TFT_Set_Pen(pen_color and $00FFFFFF, pen_width);
  end;


  procedure DynTFT_Set_Brush(brush_enabled: Byte; brush_color: TColor; gradient_enabled, gradient_orientation: Byte; gradient_color_from, gradient_color_to: TColor);
  begin
    TFT_Set_Brush(brush_enabled, brush_color and $00FFFFFF, gradient_enabled, gradient_orientation, gradient_color_from and $00FFFFFF, gradient_color_to and $00FFFFFF);
  end;


  procedure DynTFT_Set_Font(activeFont: PByte; font_color: TColor; font_orientation: Word);
  begin
    TFT_Set_Font(activeFont, font_color and $00FFFFFF, font_orientation);
  end;

  
  procedure DynTFT_Write_Text({$IFDEF IsMCU} var {$ENDIF} AText: string; x, y: Word);
  begin
    TFT_Write_Text(AText, x, y);
  end;


  procedure DynTFT_Line(x1, y1, x2, y2: Integer);
  begin
    TFT_Line(x1, y1, x2, y2);
  end;


  procedure DynTFT_Dot(x, y: Integer; Color: TColor);
  begin
    TFT_Dot(x, y, Color);
  end;


  procedure DynTFT_Fill_Screen(color: TColor);
  begin
    TFT_Fill_Screen(color);
  end;


  procedure DynTFT_Rectangle(x_upper_left, y_upper_left, x_bottom_right, y_bottom_right: Integer);
  begin
    TFT_Rectangle(x_upper_left, y_upper_left, x_bottom_right, y_bottom_right);
  end;


  procedure DynTFT_Circle(x_center, y_center, radius: Integer);
  begin
    TFT_Circle(x_center, y_center, radius);
  end;


  {$IFDEF IsDesktop}
    procedure GetTextWidthAndHeight(AText: string; var Width, Height: Word);
  {$ELSE}
    procedure GetTextWidthAndHeight(var AText: string; var Width, Height: Word);
  {$ENDIF}
    begin
      TFT_Write_Text_Return_Pos(AText, 0, 0);

      Width := caption_length;
      Height := caption_height;
    end;


    {$IFDEF IsDesktop}
      procedure DynTFT_AssignDebugConsole(AComp: TComponent); //this should be a TListBox or a TMemo
      begin
        DebugComponent := AComp;
      end;


      procedure AddMultipleItems(AItems: TStrings; s: string);
      var
        TempItems: TStringList;
      begin
        TempItems := TStringList.Create;
        try
          AItems.Text := s;
          AItems.AddStrings(TempItems);
        finally
          TempItems.Free;
        end;
      end;


      procedure DynTFT_DebugConsole(AText: string);
      var
        i: Integer;
        AForm: TForm;
      begin
        try
          if Assigned(DebugComponent) then
          begin
            if DebugComponent is TListBox then
            begin
              if Pos(#13#10, AText) > 0 then
                AddMultipleItems((DebugComponent as TListBox).Items, AText)
              else  
                (DebugComponent as TListBox).Items.Add(AText);
                
              (DebugComponent as TListBox).ItemIndex := (DebugComponent as TListBox).Count - 1;
            end
            else
              if DebugComponent is TMemo then
                (DebugComponent as TMemo).Lines.Add(AText);
          end
          else
          begin
            if Assigned(Application) then
            begin
              AForm := Application.MainForm;
              for i := 0 to AForm.ComponentCount - 1 do
              begin
                if AForm.Components[i] is TListBox then
                begin
                  DebugComponent := AForm.Components[i];
                  (DebugComponent as TListBox).Items.Add('DebugConsoleItems self assigned to ' + (DebugComponent as TListBox).Name + ' because you didn''t assign it.');
                  Break;
                end;

                if AForm.Components[i] is TMemo then
                begin
                  DebugComponent := AForm.Components[i];
                  (DebugComponent as TMemo).Lines.Add('DebugConsoleItems self assigned to ' + (DebugComponent as TMemo).Name + ' because you didn''t assign it.');
                  Break;
                end;
              end;
            end;
          end;
        except
        end;
      end;
    {$ELSE}
      procedure DynTFT_DebugConsole(var AText: string);
      begin
        {$IFDEF UseDynTFT_DebugConsole}
          {$I DynTFT_DebugConsole.inc}  //call UART_Write_Text or whatever you want here
        {$ENDIF}
      end;
    {$ENDIF}


{$ELSE}
  {$I UserTFT.inc}  //This file should contain the required implementation of TFT function, matching the headers above.
{$ENDIF}

{$IFDEF IsDesktop}
begin
  DebugComponent := nil;
{$ENDIF}
end.
