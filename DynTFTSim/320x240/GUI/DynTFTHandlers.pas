{   DynTFT  - graphic components for microcontrollers
    Copyright (C) 2017 VCC
    release date: 29 Dec 2017
    author: VCC

    This file is part of DynTFT project.

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
    DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
    OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

unit DynTFTHandlers;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  {$IFDEF UseSmallMM}
    DynTFTSmallMM,
  {$ELSE}
    {$IFDEF IsDesktop}
      MemManager,
    {$ENDIF}  
  {$ENDIF} //this must be the first unit, at least in Delphi, because it exports GetMem.
  
  DynTFTTypes, DynTFTConsts, DynTFTUtils, DynTFTBaseDrawing, DynTFTControls,
  DynTFTGUIObjects,
  
  DynTFTButton, DynTFTArrowButton, DynTFTPanel, DynTFTCheckBox, DynTFTScrollBar,
  DynTFTItems, DynTFTListBox, DynTFTLabel, DynTFTRadioButton, DynTFTRadioGroup,
  DynTFTTabButton, DynTFTPageControl, DynTFTEdit, DynTFTKeyButton, DynTFTProgressBar,
  DynTFTVirtualKeyboard, DynTFTComboBox, DynTFTMessageBox

  {$IFDEF IsDesktop}
    ,SysUtils, Forms, TFT
  {$ENDIF}
  {$I DynTFTHandlersAdditionalUnits.inc}
  ;

procedure SwitchScreen_OnMouseDownUser(Sender: PPtrRec);
procedure VirtualKeyboard_OnCharKey(Sender: PPtrRec; var PressedChar: TVKPressedChar; CurrentShiftState: TPtr);
procedure VirtualKeyboard_OnSpecialKey(Sender: PPtrRec; SpecialKey: Integer; CurrentShiftState: TPtr);
procedure ListBoxItemsGetItemText(AItems: PPtrRec; Index: LongInt; var ItemText: string);
procedure ComboBoxItemsGetItemText(AItems: PPtrRec; Index: LongInt; var ItemText: string);
procedure btnShowMessageBox_OnMouseUpUser(Sender: PPtrRec);


implementation


procedure SwitchScreen_OnMouseDownUser(Sender: PPtrRec);
var
  i: Integer;
begin
  DynTFT_Set_Pen(DynTFTAllComponentsContainer[PageControl1^.ActiveIndex].ScreenColor, 1);
  DynTFT_Set_Brush(1, DynTFTAllComponentsContainer[PageControl1^.ActiveIndex].ScreenColor, 0, 0, 0, 0);
  DynTFT_Rectangle(0, 21, TFT_DISP_WIDTH, TFT_DISP_HEIGHT);

  for i := 1 to PageControl1^.PageCount {- 1} do
  begin
    DynTFTAllComponentsContainer[i].Active := PageControl1^.ActiveIndex = i - 1;
    if DynTFTAllComponentsContainer[i].Active then
      DynTFTRepaintScreenComponents(i, CREPAINTONSTARTUP, nil);
  end;
end;


procedure VirtualKeyboard_OnCharKey(Sender: PPtrRec; var PressedChar: TVKPressedChar; CurrentShiftState: TPtr);
var
  AText: string {$IFNDEF IsDesktop}[CMaxKeyButtonStringLength] {$ENDIF};
begin
  if PDynTFTVirtualKeyboard(TPtrRec(Sender))^.ShiftState and CDYNTFTSS_CTRL = CDYNTFTSS_CTRL then
    Exit;

  if PDynTFTVirtualKeyboard(TPtrRec(Sender))^.ShiftState and CDYNTFTSS_ALT = CDYNTFTSS_ALT then
    Exit;

  AText := PressedChar;
  DynTFTEditInsertTextAtCaret(Edit1, AText);

  if Edit1^.BaseProps.Focused and CFOCUSED <> CFOCUSED then
    DynTFTFocusComponent(PDynTFTBaseComponent(TPtrRec(Edit1)));
end;


procedure VirtualKeyboard_OnSpecialKey(Sender: PPtrRec; SpecialKey: Integer; CurrentShiftState: TPtr);
begin
  case SpecialKey of
    VK_BACK : DynTFTEditBackspaceAtCaret(Edit1);

    VK_DELETE :
    begin
      if CurrentShiftState and CDYNTFTSS_CTRL_ALT = CDYNTFTSS_CTRL_ALT then  
        {$IFNDEF IsDesktop}
          Reset;
        {$ELSE}
          Application.MainForm.Close;
        {$ENDIF}
      DynTFTEditDeleteAtCaret(Edit1);
    end;

    VK_LEFT: DynTFTMoveEditCaretToLeft(Edit1, 1);

    VK_RIGHT: DynTFTMoveEditCaretToRight(Edit1, 1);

    VK_HOME: DynTFTMoveEditCaretToHome(Edit1);

    VK_END: DynTFTMoveEditCaretToEnd(Edit1);
  end;
end;


procedure ListBoxItemsGetItemText(AItems: PPtrRec; Index: LongInt; var ItemText: string);
begin
  {$IFDEF IsDesktop}
    ItemText := IntToStr(Index);
  {$ELSE}
    IntToStr(Index, ItemText);
  {$ENDIF}
end;


procedure ComboBoxItemsGetItemText(AItems: PPtrRec; Index: LongInt; var ItemText: string);
begin
  {$IFDEF IsDesktop}
    ItemText := IntToStr(Index);
  {$ELSE}
    IntToStr(Index, ItemText);
  {$ENDIF}
end;


procedure btnShowMessageBox_OnMouseUpUser(Sender: PPtrRec);
var
  AButton: PDynTFTButton;
  Res: Integer;                                
  MBMsg: string {$IFNDEF IsDesktop}[CMessageBoxMaxTextLength] {$ENDIF};
  MBTitle: string {$IFNDEF IsDesktop}[CMessageBoxMaxTitleLength] {$ENDIF};
begin
  AButton := PDynTFTButton(TPtrRec(Sender));
  MBMsg := 'This is a very long messagebox.';
  MBTitle := 'MB Title fp';

  {$IFDEF IsDesktop}
    DynTFT_DebugConsole('AButton $' + IntToHex(DWord(AButton), 8) + ' before showing Messagebox');
  {$ENDIF}

  ProgressBar1^.Position := 1;
  ProgressBar2^.Position := 1;
  DynTFTDrawProgressBar(ProgressBar1, False);
  DynTFTDrawProgressBar(ProgressBar2, False);

  Res := DynTFTShowMessageBox(6, MBMsg, MBTitle, CDynTFT_MB_OKCANCEL);
  //Res := DynTFTShowMessageBox(6, MBMsg, MBTitle, CDynTFT_MB_YESNO);

  {$IFDEF IsDesktop}
    DynTFT_DebugConsole('AButton $' + IntToHex(DWord(AButton), 8) + ' after closing Messagebox: ' + IntToStr(Res));
    DynTFT_DebugConsole('');
  {$ENDIF}

  ProgressBar1^.Position := Res * 3;
  ProgressBar2^.Position := Res * 3;
  DynTFTDrawProgressBar(ProgressBar1, False);
  DynTFTDrawProgressBar(ProgressBar2, False);
end;

end.
