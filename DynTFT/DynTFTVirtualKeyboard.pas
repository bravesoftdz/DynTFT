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

unit DynTFTVirtualKeyboard;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  DynTFTTypes, DynTFTBaseDrawing, DynTFTConsts, DynTFTUtils,
  DynTFTKeyButton
  {$IFDEF IsDesktop}
    ,SysUtils, Forms
  {$ENDIF}
  ;

const
  //Shift State constants
  CDYNTFTSS_SHIFT = 1;
  CDYNTFTSS_ALT = 2;
  CDYNTFTSS_CTRL = 4;
  CDYNTFTSS_CAPS = 8;

  CDYNTFTSS_ALT_SHIFT = 3;
  CDYNTFTSS_CTRL_ALT = 6;
  CDYNTFTSS_CTRL_SHIFT = 5;
  CDYNTFTSS_CTRL_ALT_SHIFT = 7;

type
  TVKPressedChar = string[CMaxKeyButtonStringLength]; //reserve at least 4 bytes for unicode support

  TOnVirtualKeyboardCharKeyPressedEvent = procedure(Sender: PPtrRec; var PressedChar: TVKPressedChar; CurrentShiftState: TPtr);
  POnVirtualKeyboardCharKeyPressedEvent = ^TOnVirtualKeyboardCharKeyPressedEvent;

  TOnVirtualKeyboardSpecialKeyPressedEvent = procedure(Sender: PPtrRec; SpecialKey: Integer; CurrentShiftState: TPtr);
  POnVirtualKeyboardSpecialKeyPressedEvent = ^TOnVirtualKeyboardSpecialKeyPressedEvent;

  TDynTFTVirtualKeyboard = record
    BaseProps: TDynTFTBaseProperties;  //inherited properties from TDynTFTBaseProperties - must be the first field of this structure !!!

    //keyboard properties
    FirstCreatedKey: PDynTFTBaseComponent;
    LastCreatedKey: PDynTFTBaseComponent;
    Color: TColor;
    
    ShiftState: TPtr;

    OnCharKey: POnVirtualKeyboardCharKeyPressedEvent;
    OnSpecialKey: POnVirtualKeyboardSpecialKeyPressedEvent;
  end;
  PDynTFTVirtualKeyboard = ^TDynTFTVirtualKeyboard;

procedure DynTFTDrawVirtualKeyboard(AVirtualKeyboard: PDynTFTVirtualKeyboard; FullRedraw: Boolean);
function DynTFTVirtualKeyboard_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTVirtualKeyboard;
procedure DynTFTVirtualKeyboard_Destroy(var AVirtualKeyboard: PDynTFTVirtualKeyboard);
procedure DynTFTVirtualKeyboard_DestroyAndPaint(var AVirtualKeyboard: PDynTFTVirtualKeyboard);

procedure DynTFTRegisterVirtualKeyboardEvents;
function DynTFTGetVirtualKeyboardComponentType: TDynTFTComponentType;


implementation

var
  ComponentType: TDynTFTComponentType;


function DynTFTGetVirtualKeyboardComponentType: TDynTFTComponentType;
begin
  Result := ComponentType;
end;


procedure DrawAllKeys(AVirtualKeyboard: PDynTFTVirtualKeyboard);
var
  ParentComponent: PDynTFTComponent;
  ABase: PDynTFTBaseComponent;
  ScreenIndex: Byte;
  FirstFound: Boolean;
begin
  ScreenIndex := AVirtualKeyboard^.BaseProps.ScreenIndex;
  ParentComponent := DynTFTAllComponentsContainer[ScreenIndex].ScreenContainer;
  ParentComponent := PDynTFTComponent(TPtrRec(ParentComponent^.NextSibling));

  if ParentComponent = nil then
    Exit;

  FirstFound := False;
  repeat
    ABase := PDynTFTBaseComponent(TPtrRec(ParentComponent^.BaseComponent));
    if ABase = AVirtualKeyboard^.FirstCreatedKey then
      FirstFound := True;

    if FirstFound then
    begin
      DynTFTShowComponent(ABase);
      //ABase^.BaseProps.Enabled := CDISABLED;  //for debugging only - to verify if the proper components are disabled
    end;

    if ABase = AVirtualKeyboard^.LastCreatedKey then
      Break;

    ParentComponent := PDynTFTComponent(TPtrRec(ParentComponent^.NextSibling));
  until ParentComponent = nil;
end;



procedure DynTFTDrawVirtualKeyboard(AVirtualKeyboard: PDynTFTVirtualKeyboard; FullRedraw: Boolean);
var
  x1, y1, x2, y2: TSInt;
begin
  if not DynTFTIsDrawableComponent(PDynTFTBaseComponent(TPtrRec(AVirtualKeyboard))) then
    Exit;

  if FullRedraw then
  begin
    x1 := AVirtualKeyboard^.BaseProps.Left;
    y1 := AVirtualKeyboard^.BaseProps.Top;
    x2 := x1 + AVirtualKeyboard^.BaseProps.Width;
    y2 := y1 + AVirtualKeyboard^.BaseProps.Height;

    DynTFT_Set_Pen(CL_DynTFTVirtualKeyboard_Border, 1);
    DynTFT_Set_Brush(1, AVirtualKeyboard^.Color, 0, 0, 0, 0);
    DynTFT_Rectangle(x1, y1, x2, y2);

    DrawAllKeys(AVirtualKeyboard);
  end;
end;


procedure SetDrawingColorForKeyButton(ABase: PDynTFTBaseComponent);
begin
  if ABase^.BaseProps.Enabled and CENABLED = CENABLED then
    DynTFT_Set_Pen(CL_DynTFTVirtualKeyboard_EnabledKeyDrawing, 1)
  else
    DynTFT_Set_Pen(CL_DynTFTVirtualKeyboard_DisabledKeyDrawing, 1);
end;


procedure ToggleKeyInShiftState(AKey: PPtrRec; NewShiftState: TPtr);
var
  PShiftState: PPtr;
begin
  PShiftState := @PDynTFTVirtualKeyboard(TPtrRec(PDynTFTBaseComponent(TPtrRec(AKey))^.BaseProps.Parent))^.ShiftState;
  PShiftState^ := PShiftState^ xor NewShiftState;
end;


procedure SetSpecialKeyColor(AKey: PPtrRec; ExpectedShiftState: TPtr);
var
  PShiftState: PPtr;
begin
  PShiftState := @PDynTFTVirtualKeyboard(TPtrRec(PDynTFTBaseComponent(TPtrRec(AKey))^.BaseProps.Parent))^.ShiftState;
  if PShiftState^ and ExpectedShiftState = ExpectedShiftState then
    PDynTFTKeyButton(TPtrRec(AKey))^.Color := CL_DynTFTKeyButton_SpecialKeyActiveBackground
  else
    PDynTFTKeyButton(TPtrRec(AKey))^.Color := CL_DynTFTKeyButton_Background;

  DynTFTDrawKeyButton(PDynTFTKeyButton(TPtrRec(AKey)), True);
end;


procedure DrawTabArrows_OnGenerateDrawingUser(ABase: PDynTFTBaseComponent);
var
  x1, y1: Integer;
begin
  SetDrawingColorForKeyButton(ABase);

  x1 := ABase^.BaseProps.Left;
  y1 := ABase^.BaseProps.Top;
  
  DynTFT_Line(x1 + 2, y1 + 4, x1 + 2, y1 + 12);
  DynTFT_Line(x1 + 9, y1 + 8, x1 + 26, y1 + 8);
  DynTFT_Line(x1 + 3, y1 + 8, x1 + 9, Y1 + 5);   //up
  DynTFT_Line(x1 + 3, y1 + 8, x1 + 9, Y1 + 11);  //down
  DynTFT_Line(x1 + 9, y1 + 5, x1 + 9, Y1 + 11);  //vertical

  DynTFT_Line(x1 + 27, y1 + 20, x1 + 27, Y1 + 28);
  DynTFT_Line(x1 + 3, y1 + 24, x1 + 20, y1 + 24);
  DynTFT_Line(x1 + 21, y1 + 27, x1 + 26, Y1 + 24);  //up
  DynTFT_Line(x1 + 21, y1 + 21, x1 + 26, Y1 + 24);  //down
  DynTFT_Line(x1 + 20, y1 + 21, x1 + 20, y1 + 27);  //vertical
end;


procedure DrawBackSpaceArrow_OnGenerateDrawingUser(ABase: PDynTFTBaseComponent);
var
  x1, y1: Integer;
begin
  SetDrawingColorForKeyButton(ABase);

  x1 := ABase^.BaseProps.Left;
  y1 := ABase^.BaseProps.Top;
  
  DynTFT_Line(x1 + 9, y1 + 8, x1 + 26, y1 + 8);
  DynTFT_Line(x1 + 3, y1 + 8, x1 + 9, Y1 + 3);   //up
  DynTFT_Line(x1 + 3, y1 + 8, x1 + 9, Y1 + 13);  //down
  DynTFT_Line(x1 + 9, y1 + 4, x1 + 9, Y1 + 12);  //vertical
end;


procedure DrawApps_OnGenerateDrawingUser(ABase: PDynTFTBaseComponent);
var
  x1, y1: Integer;
begin
  SetDrawingColorForKeyButton(ABase);

  x1 := ABase^.BaseProps.Left;
  y1 := ABase^.BaseProps.Top;

  DynTFT_Set_Brush(0, 0, 0, 0, 0, 0);
  DynTFT_Rectangle(x1 + 3, y1 + 7, x1 + 13, y1 + 21);
  DynTFT_Line(x1 + 5, y1 + 11, x1 + 11, Y1 + 11);  //horiz 1
  DynTFT_Line(x1 + 5, y1 + 14, x1 + 11, Y1 + 14);  //horiz 2
  DynTFT_Line(x1 + 5, y1 + 17, x1 + 11, Y1 + 17);  //horiz 3
end;


procedure DrawLeftArrow_OnGenerateDrawingUser(ABase: PDynTFTBaseComponent);
var
  x1, y1: Integer;
begin
  SetDrawingColorForKeyButton(ABase);

  x1 := ABase^.BaseProps.Left;
  y1 := ABase^.BaseProps.Top;

  DynTFT_Line(x1 + 9, y1 + 8, x1 + 18, y1 + 8);
  DynTFT_Line(x1 + 3, y1 + 8, x1 + 9, Y1 + 3);   //up
  DynTFT_Line(x1 + 3, y1 + 8, x1 + 9, Y1 + 13);  //down
  DynTFT_Line(x1 + 9, y1 + 4, x1 + 9, Y1 + 12);  //vertical
end;


procedure DrawRightArrow_OnGenerateDrawingUser(ABase: PDynTFTBaseComponent);
var
  x1, y1: Integer;
begin
  SetDrawingColorForKeyButton(ABase);

  x1 := ABase^.BaseProps.Left;
  y1 := ABase^.BaseProps.Top;

  DynTFT_Line(x1 + 7, y1 + 8, x1 + 16, y1 + 8);
  DynTFT_Line(x1 + 16, y1 + 13, x1 + 22, Y1 + 8);  //up
  DynTFT_Line(x1 + 16, y1 + 3, x1 + 22, Y1 + 8);   //down
  DynTFT_Line(x1 + 16, y1 + 4, x1 + 16, Y1 + 12);  //vertical
end;


procedure DrawUpArrow_OnGenerateDrawingUser(ABase: PDynTFTBaseComponent);
var
  x1, y1: Integer;
begin
  SetDrawingColorForKeyButton(ABase);

  x1 := ABase^.BaseProps.Left;
  y1 := ABase^.BaseProps.Top;

  DynTFT_Line(x1 + 13, y1 + 8, x1 + 13, y1 + 13); //vertical
  DynTFT_Line(x1 + 9, y1 + 8, x1 + 17, Y1 + 8);   //horizontal
  DynTFT_Line(x1 + 9, y1 + 8, x1 + 13, Y1 + 2);   //up
  DynTFT_Line(x1 + 13, y1 + 2, x1 + 17, Y1 + 8);  //down
end;


procedure DrawDownArrow_OnGenerateDrawingUser(ABase: PDynTFTBaseComponent);
var
  x1, y1: Integer;
begin
  SetDrawingColorForKeyButton(ABase);

  x1 := ABase^.BaseProps.Left;
  y1 := ABase^.BaseProps.Top;

  DynTFT_Line(x1 + 13, y1 + 2, x1 + 13, y1 + 7);   //vertical
  DynTFT_Line(x1 + 9, y1 + 7, x1 + 17, Y1 + 7);    //horizontal
  DynTFT_Line(x1 + 13, y1 + 13, x1 + 17, Y1 + 7);  //up
  DynTFT_Line(x1 + 9, y1 + 7, x1 + 13, Y1 + 13);   //down
end;


procedure DrawEnterArrow_OnGenerateDrawingUser(ABase: PDynTFTBaseComponent);
var
  x1, y1: Integer;
begin
  SetDrawingColorForKeyButton(ABase);

  x1 := ABase^.BaseProps.Left;
  y1 := ABase^.BaseProps.Top;

  DynTFT_Line(x1 + 20, y1 + 10, x1 + 20, y1 + 21);  //vertical
  DynTFT_Line(x1 + 12, y1 + 21, x1 + 20, Y1 + 21);  //horizontal
  DynTFT_Line(x1 + 12, y1 + 17, x1 + 12, Y1 + 25);  //vertical (arrow)
  DynTFT_Line(x1 + 7, y1 + 21, x1 + 12, Y1 + 16);   //up (arrow)
  DynTFT_Line(x1 + 7, y1 + 21, x1 + 12, Y1 + 26);   //down (arrow)
end;


procedure DrawShift_OnGenerateDrawingUser(ABase: PDynTFTBaseComponent);
var
  x1, y1: Integer;
begin
  SetDrawingColorForKeyButton(ABase);

  x1 := ABase^.BaseProps.Left;
  y1 := ABase^.BaseProps.Top;

  DynTFT_Line(x1 + 19, y1 + 18, x1 + 19, y1 + 24);  //vertical l
  DynTFT_Line(x1 + 23, y1 + 18, x1 + 23, y1 + 24);  //vertical r
  DynTFT_Line(x1 + 19, y1 + 24, x1 + 23, y1 + 24);  //horizontal bottom
  DynTFT_Line(x1 + 15, y1 + 18, x1 + 19, y1 + 18);  //horizontal l
  DynTFT_Line(x1 + 23, y1 + 18, x1 + 27, y1 + 18);  //horizontal r
  DynTFT_Line(x1 + 15, y1 + 17, x1 + 21, y1 + 9);   //up
  DynTFT_Line(x1 + 21, y1 + 9, x1 + 27, y1 + 17);   //down
end;


function IsCaps(AVK: PDynTFTVirtualKeyboard): Boolean;
begin
  Result := (AVK^.ShiftState and CDYNTFTSS_SHIFT = CDYNTFTSS_SHIFT) xor (AVK^.ShiftState and CDYNTFTSS_CAPS = CDYNTFTSS_CAPS);
end;


procedure TwoRowsKey_OnMouseDownUser(Sender: PPtrRec);
var
  AText: TVKPressedChar;
  AVK: PDynTFTVirtualKeyboard;
begin
  AVK := PDynTFTVirtualKeyboard(TPtrRec(PDynTFTKeyButton(TPtrRec(Sender))^.BaseProps.Parent));

  if AVK^.ShiftState and CDYNTFTSS_SHIFT = CDYNTFTSS_SHIFT then
    AText := PDynTFTKeyButton(TPtrRec(Sender))^.UpCaption
  else
    AText := PDynTFTKeyButton(TPtrRec(Sender))^.DownCaption;
    
  {$IFDEF IsDesktop}
    if Assigned(AVK^.OnCharKey) then
      if Assigned(AVK^.OnCharKey^) then
  {$ELSE}
    if AVK^.OnCharKey <> nil then
  {$ENDIF}
      AVK^.OnCharKey^(PPtrRec(TPtrRec(AVK)), AText, AVK^.ShiftState);
end;


procedure OneRowKey_OnMouseDownUser(Sender: PPtrRec);
var
  AText: TVKPressedChar;
  AVK: PDynTFTVirtualKeyboard;
begin
  AVK := PDynTFTVirtualKeyboard(TPtrRec(PDynTFTKeyButton(TPtrRec(Sender))^.BaseProps.Parent));
  AText := PDynTFTKeyButton(TPtrRec(Sender))^.UpCaption;
  
  if not IsCaps(AVK) then
  {$IFDEF IsDesktop}
    AText[1] := Chr(Ord(AText[1]) + 32);       //not sure how to do this for unicode
  {$ELSE}
    AText[0] := Chr(Ord(AText[0]) + 32);
  {$ENDIF}

  {$IFDEF IsDesktop}
    if Assigned(AVK^.OnCharKey) then
      if Assigned(AVK^.OnCharKey^) then
  {$ELSE}
    if AVK^.OnCharKey <> nil then
  {$ENDIF}
      AVK^.OnCharKey^(PPtrRec(TPtrRec(AVK)), AText, AVK^.ShiftState);
end;


procedure SpecialKey_OnMouseDownUser(Sender: PPtrRec; ASpecialKey: Integer);
var
  AVK: PDynTFTVirtualKeyboard;
begin
  AVK := PDynTFTVirtualKeyboard(TPtrRec(PDynTFTKeyButton(TPtrRec(Sender))^.BaseProps.Parent));

  {$IFDEF IsDesktop}
    if Assigned(AVK^.OnSpecialKey) then
      if Assigned(AVK^.OnSpecialKey^) then
  {$ELSE}
    if AVK^.OnSpecialKey <> nil then
  {$ENDIF}
      AVK^.OnSpecialKey^(PPtrRec(TPtrRec(AVK)), ASpecialKey, AVK^.ShiftState);
end;


procedure TabKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_TAB);
end;


procedure CapsKey_OnMouseDownUser(Sender: PPtrRec);
begin
  ToggleKeyInShiftState(Sender, CDYNTFTSS_CAPS);
  SetSpecialKeyColor(Sender, CDYNTFTSS_CAPS);
  SpecialKey_OnMouseDownUser(Sender, VK_CAPITAL);
end;


procedure EnterKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_RETURN);
end;


procedure ShiftKey_OnMouseDownUser(Sender: PPtrRec);
begin
  ToggleKeyInShiftState(Sender, CDYNTFTSS_SHIFT);
  SetSpecialKeyColor(Sender, CDYNTFTSS_SHIFT);
  SpecialKey_OnMouseDownUser(Sender, VK_SHIFT);
end;


procedure BackSpaceKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_BACK);
end;


procedure DeleteKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_DELETE);
end;


procedure ControlKey_OnMouseDownUser(Sender: PPtrRec);
begin
  ToggleKeyInShiftState(Sender, CDYNTFTSS_CTRL);
  SetSpecialKeyColor(Sender, CDYNTFTSS_CTRL);
  SpecialKey_OnMouseDownUser(Sender, VK_CONTROL);
end;


procedure AltKey_OnMouseDownUser(Sender: PPtrRec);
begin
  ToggleKeyInShiftState(Sender, CDYNTFTSS_ALT);
  SetSpecialKeyColor(Sender, CDYNTFTSS_ALT);
  SpecialKey_OnMouseDownUser(Sender, VK_MENU);
end;


procedure SpaceKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_SPACE);
  TwoRowsKey_OnMouseDownUser(Sender);
end;


procedure PageUpKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_PRIOR);
end;


procedure PageDownKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_NEXT);
end;


procedure HomeKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_HOME);
end;


procedure EndKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_END);
end;


procedure LeftArrowKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_LEFT);
end;


procedure RightArrowKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_RIGHT);
end;


procedure UpArrowKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_UP);
end;


procedure DownArrowKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_DOWN);
end;


procedure AppsKey_OnMouseDownUser(Sender: PPtrRec);
begin
  SpecialKey_OnMouseDownUser(Sender, VK_APPS);
end;


procedure CreateTwoRowKeys(ScreenIndex: Byte; AVK: PDynTFTVirtualKeyboard; var Row1_Text, Row2Text: string; XOffset, YOffset, KeyWidth, KeyHeight: Integer);
var
  i, n: Integer;
  AKeyButton: PDynTFTKeyButton;
begin
  n := Length(Row1_Text);
{$IFDEF IsDesktop}
  for i := 1 to n do
{$ELSE}
  Dec(n);
  for i := 0 to n do
{$ENDIF}
  begin
    AKeyButton := DynTFTKeyButton_Create(ScreenIndex, XOffset + ((KeyWidth + 2) * (i - {$IFDEF IsDesktop} 1 {$ELSE} 0 {$ENDIF})), YOffset, KeyWidth, KeyHeight);

    {$IFDEF IsDesktop}
      AKeyButton^.BaseProps.OnMouseDownUser^ := TwoRowsKey_OnMouseDownUser;
    {$ELSE}
      AKeyButton^.BaseProps.OnMouseDownUser := @TwoRowsKey_OnMouseDownUser;
    {$ENDIF}

    {$IFDEF IsDesktop}
      AKeyButton^.UpCaption := Row1_Text[i];
      AKeyButton^.DownCaption := Row2Text[i];
    {$ELSE}
      AKeyButton^.UpCaption[0] := Row1_Text[i];
      AKeyButton^.DownCaption[0] := Row2Text[i];
      AKeyButton^.UpCaption[1] := #0;
      AKeyButton^.DownCaption[1] := #0;
    {$ENDIF}

    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
    AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));
  end;
end;


procedure CreateOneRowKeys(ScreenIndex: Byte; AVK: PDynTFTVirtualKeyboard; var Row1_Text: string; XOffset, YOffset, KeyWidth, KeyHeight: Integer);
var
  i, n: Integer;
  AKeyButton: PDynTFTKeyButton;
begin
  n := Length(Row1_Text);
{$IFDEF IsDesktop}
  for i := 1 to n do
{$ELSE}
  Dec(n);
  for i := 0 to n do
{$ENDIF}
  begin
    AKeyButton := DynTFTKeyButton_Create(ScreenIndex, XOffset + ((KeyWidth + 2) * (i - {$IFDEF IsDesktop} 1 {$ELSE} 0 {$ENDIF})), YOffset, KeyWidth, KeyHeight);

    {$IFDEF IsDesktop}
      AKeyButton^.BaseProps.OnMouseDownUser^ := OneRowKey_OnMouseDownUser;
    {$ELSE}
      AKeyButton^.BaseProps.OnMouseDownUser := @OneRowKey_OnMouseDownUser;
    {$ENDIF}

    {$IFDEF IsDesktop}
      AKeyButton^.UpCaption := Row1_Text[i];
    {$ELSE}
      AKeyButton^.UpCaption[0] := Row1_Text[i];
      AKeyButton^.UpCaption[1] := #0;
    {$ENDIF}

    AKeyButton^.DownCaption := '';

    DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
    AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));
  end;
end;


procedure CreateKeyboardKeys(AVK: PDynTFTVirtualKeyboard);
var
  ScreenIndex: Byte;
  Left, Top: TSInt;
  
  AKeyButton: PDynTFTKeyButton;
  ANumbersRow1: string{$IFNDEF IsDesktop}[13]{$ENDIF};
  ANumbersRow2: string{$IFNDEF IsDesktop}[13]{$ENDIF};
  ALettersRow1: string{$IFNDEF IsDesktop}[10]{$ENDIF};
  ALettersRow2: string{$IFNDEF IsDesktop}[9]{$ENDIF};
  ALettersRow3: string{$IFNDEF IsDesktop}[7]{$ENDIF};

  ASquareBracketsRow1: string{$IFNDEF IsDesktop}[3]{$ENDIF};
  ASquareBracketsRow2: string{$IFNDEF IsDesktop}[3]{$ENDIF};

  AColonRow1: string{$IFNDEF IsDesktop}[2]{$ENDIF};
  AColonRow2: string{$IFNDEF IsDesktop}[2]{$ENDIF};

  ADotRow1: string{$IFNDEF IsDesktop}[3]{$ENDIF};
  ADotRow2: string{$IFNDEF IsDesktop}[3]{$ENDIF};
begin
  ScreenIndex := AVK^.BaseProps.ScreenIndex;
  Left := AVK^.BaseProps.Left;
  Top := AVK^.BaseProps.Top;

  ANumbersRow1 := '~!@#$%^&*()_+';
  ANumbersRow2 := '`1234567890-=';
  ALettersRow1 := 'QWERTYUIOP';
  ALettersRow2 := 'ASDFGHJKL';
  ALettersRow3 := 'ZXCVBNM';

  ASquareBracketsRow1 := '{}|';
  ASquareBracketsRow2 := '[]\';

  AColonRow1 := ':"';
  AColonRow2 := ';' + #39;

  ADotRow1 := '<>?';
  ADotRow2 := ',./';

  //This must be the first component of the keyboard - Tab:
  AKeyButton := DynTFTKeyButton_Create(ScreenIndex, Left + 2, Top + 38, 31, 34);
  {$IFDEF IsDesktop}
    AKeyButton^.BaseProps.OnMouseDownUser^ := TabKey_OnMouseDownUser;
    AKeyButton^.OnGenerateDrawingUser^ := DrawTabArrows_OnGenerateDrawingUser;
  {$ELSE}
    AKeyButton^.BaseProps.OnMouseDownUser := @TabKey_OnMouseDownUser;
    AKeyButton^.OnGenerateDrawingUser := @DrawTabArrows_OnGenerateDrawingUser;
  {$ENDIF}
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
  AVK^.FirstCreatedKey := PDynTFTBaseComponent(TPtrRec(AKeyButton));
  AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));

  //"middle-created" components
  CreateTwoRowKeys(ScreenIndex, AVK, ANumbersRow1, ANumbersRow2, Left + 2, Top + 2, 16, 34);
  CreateOneRowKeys(ScreenIndex, AVK, ALettersRow1, Left + 35, Top + 38, 16, 34);
  CreateOneRowKeys(ScreenIndex, AVK, ALettersRow2, Left + 42, Top + 74, 16, 34);
  CreateOneRowKeys(ScreenIndex, AVK, ALettersRow3, Left + 51, Top + 110, 16, 34);

  CreateTwoRowKeys(ScreenIndex, AVK, ASquareBracketsRow1, ASquareBracketsRow2, Left + 215, Top + 38, 16, 34);
  CreateTwoRowKeys(ScreenIndex, AVK, AColonRow1, AColonRow2, Left + 204, Top + 74, 16, 34);
  CreateTwoRowKeys(ScreenIndex, AVK, ADotRow1, ADotRow2, Left + 177, Top + 110, 16, 34);

  ////////////////////////////////////////////////////// Delete:
  AKeyButton := DynTFTKeyButton_Create(ScreenIndex, Left + 280, Top + 110, 36, 34);
  {$IFDEF IsDesktop}
    AKeyButton^.BaseProps.OnMouseDownUser^ := DeleteKey_OnMouseDownUser;
  {$ELSE}  
    AKeyButton^.BaseProps.OnMouseDownUser := @DeleteKey_OnMouseDownUser;
  {$ENDIF}
  AKeyButton^.UpCaption := 'Del';
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
  AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));

  //////////////////////////////////////////////////////Caps:
  AKeyButton := DynTFTKeyButton_Create(ScreenIndex, Left + 2, Top + 74, 38, 34);
  {$IFDEF IsDesktop}
    AKeyButton^.BaseProps.OnMouseDownUser^ := CapsKey_OnMouseDownUser;
  {$ELSE}
    AKeyButton^.BaseProps.OnMouseDownUser := @CapsKey_OnMouseDownUser;
  {$ENDIF}
  AKeyButton^.UpCaption := 'Caps';
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
  AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));

  //////////////////////////////////////////////////////Enter:
  AKeyButton := DynTFTKeyButton_Create(ScreenIndex, Left + 240, Top + 74, 38, 34);
  {$IFDEF IsDesktop}
    AKeyButton^.BaseProps.OnMouseDownUser^ := EnterKey_OnMouseDownUser;
    AKeyButton^.OnGenerateDrawingUser^ := DrawEnterArrow_OnGenerateDrawingUser;
  {$ELSE}
    AKeyButton^.BaseProps.OnMouseDownUser := @EnterKey_OnMouseDownUser;
    AKeyButton^.OnGenerateDrawingUser := @DrawEnterArrow_OnGenerateDrawingUser;
  {$ENDIF}
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
  AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));

  ////////////////////////////////////////////////////// Left Shift:
  AKeyButton := DynTFTKeyButton_Create(ScreenIndex, Left + 2, Top + 110, 47, 34);
  {$IFDEF IsDesktop}
    AKeyButton^.BaseProps.OnMouseDownUser^ := ShiftKey_OnMouseDownUser;
    AKeyButton^.OnGenerateDrawingUser^ := DrawShift_OnGenerateDrawingUser;
  {$ELSE}
    AKeyButton^.BaseProps.OnMouseDownUser := @ShiftKey_OnMouseDownUser;
    AKeyButton^.OnGenerateDrawingUser := @DrawShift_OnGenerateDrawingUser;
  {$ENDIF}
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
  AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));

  ////////////////////////////////////////////////////// Right Shift:
  AKeyButton := DynTFTKeyButton_Create(ScreenIndex, Left + 231, Top + 110, 47, 34);
  {$IFDEF IsDesktop}
    AKeyButton^.BaseProps.OnMouseDownUser^ := ShiftKey_OnMouseDownUser;
    AKeyButton^.OnGenerateDrawingUser^ := DrawShift_OnGenerateDrawingUser;
  {$ELSE}
    AKeyButton^.BaseProps.OnMouseDownUser := @ShiftKey_OnMouseDownUser;
    AKeyButton^.OnGenerateDrawingUser := @DrawShift_OnGenerateDrawingUser;
  {$ENDIF}
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
  AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));

  //////////////////////////////////////////////////////Left Ctrl:
  AKeyButton := DynTFTKeyButton_Create(ScreenIndex, Left + 2, Top + 146, 30, 34);
  {$IFDEF IsDesktop}
    AKeyButton^.BaseProps.OnMouseDownUser^ := ControlKey_OnMouseDownUser;
  {$ELSE}
    AKeyButton^.BaseProps.OnMouseDownUser := @ControlKey_OnMouseDownUser;
  {$ENDIF}
  AKeyButton^.UpCaption := 'Ctrl';
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
  AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));

  //////////////////////////////////////////////////////Right Ctrl:
  AKeyButton := DynTFTKeyButton_Create(ScreenIndex, Left + 199, Top + 146, 30, 34);
  {$IFDEF IsDesktop}
    AKeyButton^.BaseProps.OnMouseDownUser^ := ControlKey_OnMouseDownUser;
  {$ELSE}
    AKeyButton^.BaseProps.OnMouseDownUser := @ControlKey_OnMouseDownUser;
  {$ENDIF}
  AKeyButton^.UpCaption := 'Ctrl';
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
  AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));

  //////////////////////////////////////////////////////Left Alt:
  AKeyButton := DynTFTKeyButton_Create(ScreenIndex, Left + 34, Top + 146, 23, 34);
  {$IFDEF IsDesktop}
    AKeyButton^.BaseProps.OnMouseDownUser^ := AltKey_OnMouseDownUser;
  {$ELSE}
    AKeyButton^.BaseProps.OnMouseDownUser := @AltKey_OnMouseDownUser;
  {$ENDIF}
  AKeyButton^.UpCaption := 'Alt';
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
  AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));

  //////////////////////////////////////////////////////Right Alt:
  AKeyButton := DynTFTKeyButton_Create(ScreenIndex, Left + 153, Top + 146, 23, 34);
  {$IFDEF IsDesktop}
    AKeyButton^.BaseProps.OnMouseDownUser^ := AltKey_OnMouseDownUser;
  {$ELSE}
    AKeyButton^.BaseProps.OnMouseDownUser := @AltKey_OnMouseDownUser;
  {$ENDIF}
  AKeyButton^.UpCaption := 'Alt';
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
  AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));

  //////////////////////////////////////////////////////Space:
  AKeyButton := DynTFTKeyButton_Create(ScreenIndex, Left + 59, Top + 146, 92, 34);
  {$IFDEF IsDesktop}
    AKeyButton^.BaseProps.OnMouseDownUser^ := SpaceKey_OnMouseDownUser;
  {$ELSE}
    AKeyButton^.BaseProps.OnMouseDownUser := @SpaceKey_OnMouseDownUser;
  {$ENDIF}
  AKeyButton^.UpCaption := ' ';    //set both captions, because of shift state
  AKeyButton^.DownCaption := ' ';
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
  AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));

  ////////////////////////////////////////////////////// Apps:
  AKeyButton := DynTFTKeyButton_Create(ScreenIndex, Left + 178, Top + 146, 19, 34);
  {$IFDEF IsDesktop}
    AKeyButton^.BaseProps.OnMouseDownUser^ := AppsKey_OnMouseDownUser;
    AKeyButton^.OnGenerateDrawingUser^ := DrawApps_OnGenerateDrawingUser;
  {$ELSE}
    AKeyButton^.BaseProps.OnMouseDownUser := @AppsKey_OnMouseDownUser;
    AKeyButton^.OnGenerateDrawingUser := @DrawApps_OnGenerateDrawingUser;
  {$ENDIF}
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
  AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));

  ////////////////////////////////////////////////////// PageUp:
  AKeyButton := DynTFTKeyButton_Create(ScreenIndex, Left + 269, Top + 2, 22, 34);
  {$IFDEF IsDesktop}
    AKeyButton^.BaseProps.OnMouseDownUser^ := PageUpKey_OnMouseDownUser;
  {$ELSE}
    AKeyButton^.BaseProps.OnMouseDownUser := @PageUpKey_OnMouseDownUser;
  {$ENDIF}
  AKeyButton^.UpCaption := 'Pg';
  AKeyButton^.DownCaption := 'Up';
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
  AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));

  ////////////////////////////////////////////////////// PageDown:
  AKeyButton := DynTFTKeyButton_Create(ScreenIndex, Left + 294, Top + 2, 22, 34);
  {$IFDEF IsDesktop}
    AKeyButton^.BaseProps.OnMouseDownUser^ := PageDownKey_OnMouseDownUser;
  {$ELSE}
    AKeyButton^.BaseProps.OnMouseDownUser := @PageDownKey_OnMouseDownUser;
  {$ENDIF}
  AKeyButton^.UpCaption := 'Pg';
  AKeyButton^.DownCaption := 'Dn';
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
  AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));

  ////////////////////////////////////////////////////// Home:
  AKeyButton := DynTFTKeyButton_Create(ScreenIndex, Left + 269, Top + 38, 47, 34);
  {$IFDEF IsDesktop}
    AKeyButton^.BaseProps.OnMouseDownUser^ := HomeKey_OnMouseDownUser;
  {$ELSE}
    AKeyButton^.BaseProps.OnMouseDownUser := @HomeKey_OnMouseDownUser;
  {$ENDIF}
  AKeyButton^.UpCaption := 'Home';
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
  AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));

  ////////////////////////////////////////////////////// End:
  AKeyButton := DynTFTKeyButton_Create(ScreenIndex, Left + 280, Top + 74, 36, 34);
  {$IFDEF IsDesktop}
    AKeyButton^.BaseProps.OnMouseDownUser^ := EndKey_OnMouseDownUser;
  {$ELSE}
    AKeyButton^.BaseProps.OnMouseDownUser := @EndKey_OnMouseDownUser;
  {$ENDIF}
  AKeyButton^.UpCaption := 'End';
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
  AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));

  ////////////////////////////////////////////////////// Left Arrow:
  AKeyButton := DynTFTKeyButton_Create(ScreenIndex, Left + 231, Top + 164, 27, 16);
  {$IFDEF IsDesktop}
    AKeyButton^.BaseProps.OnMouseDownUser^ := LeftArrowKey_OnMouseDownUser;
    AKeyButton^.OnGenerateDrawingUser^ := DrawLeftArrow_OnGenerateDrawingUser;
  {$ELSE}
    AKeyButton^.BaseProps.OnMouseDownUser := @LeftArrowKey_OnMouseDownUser;
    AKeyButton^.OnGenerateDrawingUser := @DrawLeftArrow_OnGenerateDrawingUser;
  {$ENDIF}
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
  AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));

  ////////////////////////////////////////////////////// Right Arrow:
  AKeyButton := DynTFTKeyButton_Create(ScreenIndex, Left + 289, Top + 164, 27, 16);
  {$IFDEF IsDesktop}
    AKeyButton^.BaseProps.OnMouseDownUser^ := RightArrowKey_OnMouseDownUser;
    AKeyButton^.OnGenerateDrawingUser^ := DrawRightArrow_OnGenerateDrawingUser;
  {$ELSE}
    AKeyButton^.BaseProps.OnMouseDownUser := @RightArrowKey_OnMouseDownUser;
    AKeyButton^.OnGenerateDrawingUser := @DrawRightArrow_OnGenerateDrawingUser;
  {$ENDIF}
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
  AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));

  ////////////////////////////////////////////////////// Up Arrow:
  AKeyButton := DynTFTKeyButton_Create(ScreenIndex, Left + 260, Top + 146, 27, 16);
  {$IFDEF IsDesktop}
    AKeyButton^.BaseProps.OnMouseDownUser^ := UpArrowKey_OnMouseDownUser;
    AKeyButton^.OnGenerateDrawingUser^ := DrawUpArrow_OnGenerateDrawingUser;
  {$ELSE}
    AKeyButton^.BaseProps.OnMouseDownUser := @UpArrowKey_OnMouseDownUser;
    AKeyButton^.OnGenerateDrawingUser := @DrawUpArrow_OnGenerateDrawingUser;
  {$ENDIF}
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
  AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));

  ////////////////////////////////////////////////////// Down Arrow:
  AKeyButton := DynTFTKeyButton_Create(ScreenIndex, Left + 260, Top + 164, 27, 16);
  {$IFDEF IsDesktop}
    AKeyButton^.BaseProps.OnMouseDownUser^ := DownArrowKey_OnMouseDownUser;
    AKeyButton^.OnGenerateDrawingUser^ := DrawDownArrow_OnGenerateDrawingUser;
  {$ELSE}
    AKeyButton^.BaseProps.OnMouseDownUser := @DownArrowKey_OnMouseDownUser;
    AKeyButton^.OnGenerateDrawingUser := @DrawDownArrow_OnGenerateDrawingUser;
  {$ENDIF}
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
  AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));

  //This must be the last component of the keyboard - Backspace:
  AKeyButton := DynTFTKeyButton_Create(ScreenIndex, Left + 236, Top + 2, 31, 34);
  {$IFDEF IsDesktop}
    AKeyButton^.BaseProps.OnMouseDownUser^ := BackSpaceKey_OnMouseDownUser;
    AKeyButton^.OnGenerateDrawingUser^ := DrawBackSpaceArrow_OnGenerateDrawingUser;
  {$ELSE}
    AKeyButton^.BaseProps.OnMouseDownUser := @BackSpaceKey_OnMouseDownUser;
    AKeyButton^.OnGenerateDrawingUser := @DrawBackSpaceArrow_OnGenerateDrawingUser;
  {$ENDIF}
  DynTFTShowComponent(PDynTFTBaseComponent(TPtrRec(AKeyButton)));
  AVK^.LastCreatedKey := PDynTFTBaseComponent(TPtrRec(AKeyButton));
  AKeyButton^.BaseProps.Parent := PPtrRec(TPtrRec(AVK));
end;  


function DynTFTVirtualKeyboard_Create(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTVirtualKeyboard;
begin
  Result := PDynTFTVirtualKeyboard(TPtrRec(DynTFTComponent_Create(ScreenIndex, SizeOf(Result^))));

  {$IFDEF IsDesktop}
    if ComponentType = -1 then
      raise Exception.Create('PDynTFTVirtualKeyboard was not registered. Please call RegisterVirtualKeyboardEvents before creating a PDynTFTVirtualKeyboard. It should be called once in RegisterAllComponentsEvents procedure from DynTFTGUI unit.');
  {$ENDIF}

  Result^.BaseProps.ComponentType := ComponentType;
  Result^.BaseProps.CanHandleMessages := True;
  Result^.BaseProps.Left := Left;
  Result^.BaseProps.Top := Top;
  Result^.BaseProps.Width := Width;
  Result^.BaseProps.Height := Height;
  DynTFTInitBasicStatePropertiesToDefault(PDynTFTBaseComponent(TPtrRec(Result)));

  Result^.Color := CL_DynTFTVirtualKeyboard_Background;
  Result^.ShiftState := 0;
  Result^.BaseProps.Focused := CREJECTFOCUS;
  Result^.BaseProps.CanHandleMessages := False;

  {$IFDEF IsDesktop}
    New(Result^.OnCharKey);
    New(Result^.OnSpecialKey);

    Result^.OnCharKey^ := nil;
    Result^.OnSpecialKey^ := nil;
  {$ELSE}
    Result^.OnCharKey := nil;
    Result^.OnSpecialKey := nil;
  {$ENDIF}

  CreateKeyboardKeys(Result);
end;


function DynTFTVirtualKeyboard_BaseCreate(ScreenIndex: Byte; Left, Top, Width, Height: TSInt): PDynTFTBaseComponent;
begin
  Result := PDynTFTBaseComponent(TPtrRec(DynTFTVirtualKeyboard_Create(ScreenIndex, Left, Top, Width, Height)));
end;


procedure DynTFTVirtualKeyboard_Destroy(var AVirtualKeyboard: PDynTFTVirtualKeyboard);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTBaseComponent;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    Dispose(AVirtualKeyboard^.OnCharKey);
    Dispose(AVirtualKeyboard^.OnSpecialKey);
  {$ENDIF}

  DynTFTComponent_DestroyMultiple(AVirtualKeyboard^.FirstCreatedKey, AVirtualKeyboard^.LastCreatedKey, SizeOf(TDynTFTKeyButton));

  {$IFDEF IsDesktop}
    DynTFTComponent_Destroy(PDynTFTBaseComponent(TPtrRec(AVirtualKeyboard)), SizeOf(AVirtualKeyboard^));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  289 341 Operator "@" not applicable to these operands "?T222"
    ATemp := PDynTFTBaseComponent(TPtrRec(AVirtualKeyboard));
    DynTFTComponent_Destroy(ATemp, SizeOf(AVirtualKeyboard^));
    AVirtualKeyboard := PDynTFTVirtualKeyboard(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure DynTFTVirtualKeyboard_DestroyAndPaint(var AVirtualKeyboard: PDynTFTVirtualKeyboard);
begin
  DynTFTClearComponentAreaWithScreenColor(PDynTFTBaseComponent(TPtrRec(AVirtualKeyboard)));
  DynTFTVirtualKeyboard_Destroy(AVirtualKeyboard);
end;


procedure DynTFTVirtualKeyboard_BaseDestroyAndPaint(var AVirtualKeyboard: PDynTFTBaseComponent);
{$IFNDEF IsDesktop}
  var
    ATemp: PDynTFTVirtualKeyboard;
{$ENDIF}
begin
  {$IFDEF IsDesktop}
    DynTFTVirtualKeyboard_DestroyAndPaint(PDynTFTVirtualKeyboard(TPtrRec(AVirtualKeyboard)));
  {$ELSE}
    //without temp var, mikroPascal gives an error:  Operator "@" not applicable to these operands "?T230"
    ATemp := PDynTFTVirtualKeyboard(TPtrRec(AVirtualKeyboard));
    DynTFTVirtualKeyboard_DestroyAndPaint(ATemp);
    AVirtualKeyboard := PDynTFTBaseComponent(TPtrRec(ATemp));
  {$ENDIF}
end;


procedure TDynTFTVirtualKeyboard_OnDynTFTBaseInternalMouseDown(ABase: PDynTFTBaseComponent);
begin

end;


procedure TDynTFTVirtualKeyboard_OnDynTFTBaseInternalMouseMove(ABase: PDynTFTBaseComponent);
begin

end;


procedure TDynTFTVirtualKeyboard_OnDynTFTBaseInternalMouseUp(ABase: PDynTFTBaseComponent);
begin
 
end;


procedure TDynTFTVirtualKeyboard_OnDynTFTBaseInternalRepaint(ABase: PDynTFTBaseComponent; FullRepaint: Boolean; Options: TPtr; ComponentFromArea: PDynTFTBaseComponent);
begin
  if Options = CREPAINTONMOUSEUP then
    Exit;

  if Options = CSETSUBCOMPONENTSINVISIBLEONCLEARAREAREPAINT then
  begin
    //HideComponent(PDynTFTBaseComponent(TPtrRec(...)));
    Exit;
  end;

  if Options = CSETSUBCOMPONENTSVISIBLEONSHOWREPAINT then
  begin
    //ShowComponent(PDynTFTBaseComponent(TPtrRec(...)));
    Exit;
  end;
  
  DynTFTDrawVirtualKeyboard(PDynTFTVirtualKeyboard(TPtrRec(ABase)), FullRepaint);
end;


procedure DynTFTRegisterVirtualKeyboardEvents;
var
  ABaseEventReg: TDynTFTBaseEventReg;
begin
  DynTFTAllocateInternalHandlers(ABaseEventReg);
  {$IFDEF IsDesktop}
    //ABaseEventReg.MouseDownEvent^ := TDynTFTVirtualKeyboard_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent^ := TDynTFTVirtualKeyboard_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent^ := TDynTFTVirtualKeyboard_OnDynTFTBaseInternalMouseUp;
    ABaseEventReg.Repaint^ := TDynTFTVirtualKeyboard_OnDynTFTBaseInternalRepaint;
    
    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate^ := DynTFTVirtualKeyboard_BaseCreate;
      ABaseEventReg.CompDestroy^ := DynTFTVirtualKeyboard_BaseDestroyAndPaint;
    {$ENDIF}
  {$ELSE}
    //ABaseEventReg.MouseDownEvent := @TDynTFTVirtualKeyboard_OnDynTFTBaseInternalMouseDown;
    //ABaseEventReg.MouseMoveEvent := @TDynTFTVirtualKeyboard_OnDynTFTBaseInternalMouseMove;
    //ABaseEventReg.MouseUpEvent := @TDynTFTVirtualKeyboard_OnDynTFTBaseInternalMouseUp;
    ABaseEventReg.Repaint := @TDynTFTVirtualKeyboard_OnDynTFTBaseInternalRepaint;

    {$IFDEF RTTIREG}
      ABaseEventReg.CompCreate := @DynTFTVirtualKeyboard_Create;
      ABaseEventReg.CompDestroy := @DynTFTVirtualKeyboard_BaseDestroyAndPaint;
    {$ENDIF}
  {$ENDIF}

  {$IFDEF RTTIREG}
    ABaseEventReg.CompSize := SizeOf(TDynTFTVirtualKeyboard); 
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
