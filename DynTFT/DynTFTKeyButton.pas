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

unit DynTFTKeyButton;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  DynTFTTypes, DynTFTBaseDrawing, DynTFTConsts, DynTFTUtils
  {$IFDEF IsDesktop}
    ,SysUtils, Forms
  {$ENDIF}
  ;

const
  CMaxKeyButtonStringLength = 11; //n * 4 - 1

type
  TDynTFTKeyButtonCaption = string[CMaxKeyButtonStringLength];

  TDynTFTKeyButton = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    //button properties
    UpCaption: TDynTFTKeyButtonCaption;
    DownCaption: TDynTFTKeyButtonCaption;
    Color: TColor;
    Font_Color: TColor;

    OnGenerateDrawingUser: PDynTFTGenericEventHandler;
  end;
  PDynTFTKeyButton = ^TDynTFTKeyButton;

procedure DynTFTDrawKeyButton(AKeyButton: PDynTFTKeyButton; FullRedraw: Boolean);
function DynTFTKeyButton_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTKeyButton;
procedure DynTFTKeyButton_Destroy(var AKeyButton: PDynTFTKeyButton);
procedure DynTFTKeyButton_DestroyAndPaint(var AKeyButton: PDynTFTKeyButton);

procedure DynTFTRegisterKeyButtonEvents;
function DynTFTGetKeyButtonComponentType: TDynTFTComponentType;


implementation

var
  ComponentType: TDynTFTComponentType;

//{$DEFINE CenterTextOnComponent}  //to draw centered text on a component

function DynTFTGetKeyButtonComponentType: TDynTFTComponentType;
begin
  Result := ComponentType;
end;


procedure DynTFTDrawKeyButton(AKeyButton: PDynTFTKeyButton; FullRedraw: Boolean);
var
  Col1, Col2, ACol: TColor;
  x1, y1, x2, y2: TSInt;
  TextWidth, TextHeight: Word;

  {$IFDEF CenterTextOnComponent}
    HalfHeight: TSInt;
    HalfWidth: TSInt;
    TextXOffset: TSInt; //used to compute the X coord of text on button to make the text centered
  {$ENDIF}
begin
  if not DynTFTIsDrawableComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton))) then
    Exit;

  x1 := AKeyButton^.BaseProps.Left;
  y1 := AKeyButton^.BaseProps.Top;
  x2 := x1 + AKeyButton^.BaseProps.Width;
  y2 := y1 + AKeyButton^.BaseProps.Height;

  ACol := AKeyButton^.Color;

  if FullRedraw then       
  begin
    DynTFT_Set_Pen(ACol, 1);
    DynTFT_Set_Brush(1, ACol, 0, 0, 0, 0);
    DynTFT_Rectangle(x1, y1, x2, y2);
  end;
                                     {
     //Commented because keys of a keyboard may not need focus rectangles.
  //Draw focus rectangle from lines
  if AKeyButton^.BaseProps.Focused and CFOCUSED = CFOCUSED then
    ACol := CL_DynTFTKeyButton_FocusRectangle
  else
    ACol := AKeyButton^.Color;
    
  DynTFT_Set_Pen(ACol, 1);

  DynTFT_Line(x1 + 4, y1 + 3, x1 + 4, y2 - 3); //vert
  DynTFT_Line(x1 + 4, y1 + 3, x2 - 4, y1 + 3); //horiz
  DynTFT_Line(x2 - 4, y1 + 3, x2 - 4, y2 - 3); //vert
  DynTFT_Line(x1 + 4, y2 - 3, x2 - 4, y2 - 3); //horiz
                                   }
                                   
  if AKeyButton^.BaseProps.CompState and CPRESSED = CPRESSED then
  begin
    Col2 := CL_DynTFTKeyButton_LightEdge;
    Col1 := CL_DynTFTKeyButton_DarkEdge;
  end
  else
  begin
    Col1 := CL_DynTFTKeyButton_LightEdge;
    Col2 := CL_DynTFTKeyButton_DarkEdge;
  end;

  //border lines
  DynTFT_Set_Pen(Col1, 1);
  DynTFT_Line(x1, y1, x1, y2); //vert
  DynTFT_Line(x1, y1, x2, y1); //horiz

  DynTFT_Set_Pen(Col2, 1);
  DynTFT_Line(x2, y1, x2, y2); //vert
  DynTFT_Line(x1, y2, x2, y2); //horiz

  //draw text
  if AKeyButton^.BaseProps.Enabled and CENABLED = CENABLED then
    ACol := AKeyButton^.Font_Color
  else
    ACol := CL_DynTFTKeyButton_DisabledFont;

  DynTFT_Set_Font(@TFT_defaultFont, ACol, FO_HORIZONTAL);

  GetTextWidthAndHeight(AKeyButton^.UpCaption, TextWidth, TextHeight);
  {$IFDEF CenterTextOnComponent}
    HalfWidth := AKeyButton^.BaseProps.Width shr 1;
    HalfHeight := AKeyButton^.BaseProps.Height shr 1;

    TextXOffset := HalfWidth - TSInt(TextWidth shr 1);
    DynTFT_Write_Text(AKeyButton^.UpCaption, x1 + TextXOffset, y1 + HalfHeight - TSInt(TextHeight {shr 1} + 0));
    DynTFT_Write_Text(AKeyButton^.DownCaption, x1 + TextXOffset, y1 + HalfHeight + TSInt({TextHeight {shr 1} + 0));
  {$ELSE}
    DynTFT_Write_Text(AKeyButton^.UpCaption, x1 + 2, y1);
    DynTFT_Write_Text(AKeyButton^.DownCaption, x1 + 2, y1 + TextHeight);
  {$ENDIF}

  {$IFDEF IsDesktop}
    if Assigned(AKeyButton^.OnGenerateDrawingUser) then
      if Assigned(AKeyButton^.OnGenerateDrawingUser^) then
  {$ELSE}
    if AKeyButton^.OnGenerateDrawingUser <> nil then
  {$ENDIF}
      AKeyButton^.OnGenerateDrawingUser^(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
end;


function DynTFTKeyButton_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTKeyButton;
begin
  Result := PDynTFTKeyButton(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTKeyButton was not registered. Please call RegisterKeyButtonEvents before creating a PDynTFTKeyButton. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := True;
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));
 
  Result^.Color := CL_DynTFTKeyButton_Background;
  Result^.Font_Color := CL_DynTFTKeyButton_EnabledFont;
  Result^.UpCaption := '';
  Result^.DownCaption := '';
  Result^.BaseProps.Focused := CREJECTFOCUS;

  {$IFDEF IsDesktop}
    New(Result^.OnGenerateDrawingUser);

    Result^.OnGenerateDrawingUser^ := nil;
  {$ELSE}
    Result^.OnGenerateDrawingUser := nil;
  {$ENDIF}
end;


function DynTFTKeyButton_BaseCreate(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
begin
  Result := PDynTFTBaseComponent(TPtrRec(DynTFTKeyButton_Create(ScreenIndex, Left, Top, Width, Height)));
end;


procedure DynTFTKeyButton_Destroy(var AKeyButton: PDynTFTKeyButton);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTBaseComponent;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AKeyButton)), SizeOf(AKeyButton^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"
    ATemp := PDynTFTBaseComponent(TPtrRec(AKeyButton));
    DynTFTComponent_Destroy(ATemp, SizeOf(AKeyButton^));
    AKeyButton := PDynTFTKeyButton(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTKeyButton_DestroyAndPaint(var AKeyButton: PDynTFTKeyButton);
begin
  DynTFTClearComponentAreaWithScreenColor(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
  DynTFTKeyButton_Destroy(AKeyButton);
end;


procedure DynTFTKeyButton_BaseDestroyAndPaint(var AKeyButton: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTKeyButton;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTKeyButton_DestroyAndPaint(PDynTFTKeyButton(TPtrRec(AKeyButton)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTKeyButton(TPtrRec(AKeyButton));
    DynTFTKeyButton_DestroyAndPaint(ATemp);
    AKeyButton := PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure TDynTFTKeyButton_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
begin
  DynTFTDrawKeyButton(PDynTFTKeyButton(TPtrRec(ABase)), ABase^.BaseProps.Focused and CFOCUSED = CFOCUSED);
end;


procedure TDynTFTKeyButton_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin

end;


procedure TDynTFTKeyButton_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
  DynTFTDrawKeyButton(PDynTFTKeyButton(TPtrRec(ABase)), False);
end;


procedure TDynTFTKeyButton_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
begin
  DynTFTDrawKeyButton(PDynTFTKeyButton(TPtrRec(ABase)), FullRepaint);
end;


procedure DynTFTRegisterKeyButtonEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    ABaseEventReg.MouseDownEvent^ := TDynTFTKeyButton_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent^ := TDynTFTKeyButton_OnDynTFTBaseInternalMouseMove;
    ABaseEventReg.MouseUpEvent^ := TDynTFTKeyButton_OnDynTFTBaseInternalMouseUp;
    ABaseEventReg.Repaint^ := TDynTFTKeyButton_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTKeyButton_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTKeyButton_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    ABaseEventReg.MouseDownEvent := @TDynTFTKeyButton_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent := @TDynTFTKeyButton_OnDynTFTBaseInternalMouseMove;
    ABaseEventReg.MouseUpEvent := @TDynTFTKeyButton_OnDynTFTBaseInternalMouseUp;
    ABaseEventReg.Repaint := @TDynTFTKeyButton_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTKeyButton_Create;
      ABaseEventReg.CompDestroy := @DynTFTKeyButton_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTKeyButton); 
  {$ENDIF}

  ComponentType := DynTFTRegisterComponentType(@ABaseEventReg);

  {$IFDEF IsDesktop}
    DynTFTDisposeInternalHandlers(ABaseEventReg);
  {$ENDIF}
end;

{$IFDEF IsDesktop}
begin
  ComponentType := -1;
{$ENDIF}

end.
