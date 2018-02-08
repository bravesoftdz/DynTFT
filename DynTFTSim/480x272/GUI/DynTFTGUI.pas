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

unit DynTFTGUI;

{$IFNDEF IsMCU}
  {$DEFINE IsDesktop}
{$ENDIF} 

{$IFDEF IsDesktop}
interface
{$ENDIF}

uses
  DynTFTTypes, DynTFTConsts, DynTFTUtils, DynTFTBaseDrawing,
  DynTFTGUIObjects, DynTFTHandlers,

  DynTFTButton, DynTFTArrowButton, DynTFTPanel, DynTFTCheckBox, DynTFTScrollBar,
  DynTFTItems, DynTFTListBox, DynTFTLabel, DynTFTRadioButton, DynTFTRadioGroup,
  DynTFTTabButton, DynTFTPageControl, DynTFTEdit, DynTFTKeyButton,
  DynTFTVirtualKeyboard, DynTFTComboBox, DynTFTTrackBar, DynTFTProgressBar

  {$IFDEF IsDesktop}
    ,SysUtils, TFT
  {$ENDIF}
  {$I DynTFTGUIAdditionalUnits.inc}
  ;


procedure DynTFT_GUI_Start;
procedure DrawGUI; //Made available for debugging or various performance improvements. Called by DynTFT_GUI_Start.


implementation


//Add here only the components you are using in your application. Adding more than needed would simply be a waste of memory.
procedure RegisterAllComponentsEvents;
begin
  DynTFTRegisterButtonEvents;               {$IFDEF IsDesktop}DynTFT_DebugConsole('Button type: ' + IntToStr(DynTFTGetButtonComponentType));{$ENDIF}
  DynTFTRegisterArrowButtonEvents;          {$IFDEF IsDesktop}DynTFT_DebugConsole('ArrowButton type: ' + IntToStr(DynTFTGetArrowButtonComponentType));{$ENDIF}
  DynTFTRegisterPanelEvents;                {$IFDEF IsDesktop}DynTFT_DebugConsole('Panel type: ' + IntToStr(DynTFTGetPanelComponentType));{$ENDIF}
  DynTFTRegisterCheckBoxEvents;             {$IFDEF IsDesktop}DynTFT_DebugConsole('CheckBox type: ' + IntToStr(DynTFTGetCheckBoxComponentType));{$ENDIF}
  DynTFTRegisterScrollBarEvents;            {$IFDEF IsDesktop}DynTFT_DebugConsole('ScrollBar type: ' + IntToStr(DynTFTGetScrollBarComponentType));{$ENDIF}
  DynTFTRegisterItemsEvents;                {$IFDEF IsDesktop}DynTFT_DebugConsole('Items type: ' + IntToStr(DynTFTGetItemsComponentType));{$ENDIF}
  DynTFTRegisterListBoxEvents;              {$IFDEF IsDesktop}DynTFT_DebugConsole('ListBox type: ' + IntToStr(DynTFTGetListBoxComponentType));{$ENDIF}
  DynTFTRegisterLabelEvents;                {$IFDEF IsDesktop}DynTFT_DebugConsole('Label type: ' + IntToStr(DynTFTGetLabelComponentType));{$ENDIF}
  DynTFTRegisterRadioButtonEvents;          {$IFDEF IsDesktop}DynTFT_DebugConsole('RadioButton type: ' + IntToStr(DynTFTGetRadioButtonComponentType));{$ENDIF}
  DynTFTRegisterRadioGroupEvents;           {$IFDEF IsDesktop}DynTFT_DebugConsole('RadioGroup type: ' + IntToStr(DynTFTGetRadioGroupComponentType));{$ENDIF}
  DynTFTRegisterTabButtonEvents;            {$IFDEF IsDesktop}DynTFT_DebugConsole('TabButton type: ' + IntToStr(DynTFTGetTabButtonComponentType));{$ENDIF}
  DynTFTRegisterPageControlEvents;          {$IFDEF IsDesktop}DynTFT_DebugConsole('PageControl type: ' + IntToStr(DynTFTGetPageControlComponentType));{$ENDIF}
  DynTFTRegisterEditEvents;                 {$IFDEF IsDesktop}DynTFT_DebugConsole('Edit type: ' + IntToStr(DynTFTGetEditComponentType));{$ENDIF}
  DynTFTRegisterKeyButtonEvents;            {$IFDEF IsDesktop}DynTFT_DebugConsole('KeyButton type: ' + IntToStr(DynTFTGetKeyButtonComponentType));{$ENDIF}
  DynTFTRegisterVirtualKeyboardEvents;      {$IFDEF IsDesktop}DynTFT_DebugConsole('VirtualKeyboard type: ' + IntToStr(DynTFTGetVirtualKeyboardComponentType));{$ENDIF}
  DynTFTRegisterComboBoxEvents;             {$IFDEF IsDesktop}DynTFT_DebugConsole('ComboBox type: ' + IntToStr(DynTFTGetComboBoxComponentType));{$ENDIF}
  DynTFTRegisterTrackBarEvents;             {$IFDEF IsDesktop}DynTFT_DebugConsole('TrackBar type: ' + IntToStr(DynTFTGetTrackBarComponentType));{$ENDIF}
  DynTFTRegisterProgressBarEvents;          {$IFDEF IsDesktop}DynTFT_DebugConsole('ProgressBar type: ' + IntToStr(DynTFTGetProgressBarComponentType));{$ENDIF}
end;


procedure SetScreenActivity;
begin
  DynTFTAllComponentsContainer[0].Active := True;
  DynTFTAllComponentsContainer[1].Active := True;
  DynTFTAllComponentsContainer[2].Active := False;
  DynTFTAllComponentsContainer[3].Active := False;
  DynTFTAllComponentsContainer[4].Active := False;
  DynTFTAllComponentsContainer[5].Active := False;
  DynTFTAllComponentsContainer[6].Active := False;
  DynTFTAllComponentsContainer[7].Active := False;
  DynTFTAllComponentsContainer[8].Active := False;
  DynTFTAllComponentsContainer[9].Active := False;
  DynTFTAllComponentsContainer[10].Active := False;
  DynTFTAllComponentsContainer[11].Active := False;
  DynTFTAllComponentsContainer[12].Active := False;
  DynTFTAllComponentsContainer[13].Active := False;
  DynTFTAllComponentsContainer[14].Active := False;
  DynTFTAllComponentsContainer[15].Active := False;
  DynTFTAllComponentsContainer[16].Active := False;
  DynTFTAllComponentsContainer[17].Active := False;
  DynTFTAllComponentsContainer[18].Active := False;
  DynTFTAllComponentsContainer[19].Active := False;
  DynTFTAllComponentsContainer[20].Active := False;

  DynTFTAllComponentsContainer[0].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[1].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[2].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[3].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[4].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[5].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[6].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[7].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[8].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[9].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[10].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[11].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[12].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[13].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[14].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[15].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[16].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[17].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[18].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[19].ScreenColor := CL_DynTFTScreen_Background;
  DynTFTAllComponentsContainer[20].ScreenColor := CL_DynTFTScreen_Background;

  DynTFT_Set_Pen(DynTFTAllComponentsContainer[1].ScreenColor, 1);
  DynTFT_Set_Brush(1, DynTFTAllComponentsContainer[1].ScreenColor, 0, 0, 0, 0);
  DynTFT_Rectangle(0, 21, TFT_DISP_WIDTH, TFT_DISP_HEIGHT);
end;


procedure CreateGUI_Screen_0;
begin
  PageControl1 := DynTFTPageControl_Create(0, 0, 0, 480, 272);  //Screen: 0


  tabbtnTab1 := DynTFTTabButton_Create(0, 0, 0, 45, 20);  //Screen: 0
  tabbtnTab1^.Caption := 'Tab1';
  {$IFDEF IsDesktop}
    tabbtnTab1^.BaseProps.OnMouseDownUser^ := SwitchScreen_OnMouseDownUser;
  {$ELSE}
    tabbtnTab1^.BaseProps.OnMouseDownUser := @SwitchScreen_OnMouseDownUser;
  {$ENDIF}
  DynTFTAddTabButtonToPageControl(PageControl1, tabbtnTab1);

  tabbtnTab2 := DynTFTTabButton_Create(0, 46, 0, 45, 20);  //Screen: 0
  tabbtnTab2^.Caption := 'Tab2';
  {$IFDEF IsDesktop}
    tabbtnTab2^.BaseProps.OnMouseDownUser^ := SwitchScreen_OnMouseDownUser;
  {$ELSE}
    tabbtnTab2^.BaseProps.OnMouseDownUser := @SwitchScreen_OnMouseDownUser;
  {$ENDIF}
  DynTFTAddTabButtonToPageControl(PageControl1, tabbtnTab2);

  tabbtnTab3 := DynTFTTabButton_Create(0, 92, 0, 45, 20);  //Screen: 0
  tabbtnTab3^.Caption := 'Tab3';
  {$IFDEF IsDesktop}
    tabbtnTab3^.BaseProps.OnMouseDownUser^ := SwitchScreen_OnMouseDownUser;
  {$ELSE}
    tabbtnTab3^.BaseProps.OnMouseDownUser := @SwitchScreen_OnMouseDownUser;
  {$ENDIF}
  DynTFTAddTabButtonToPageControl(PageControl1, tabbtnTab3);

  tabbtnTab4 := DynTFTTabButton_Create(0, 138, 0, 45, 20);  //Screen: 0
  tabbtnTab4^.Caption := 'Tab4';
  {$IFDEF IsDesktop}
    tabbtnTab4^.BaseProps.OnMouseDownUser^ := SwitchScreen_OnMouseDownUser;
  {$ELSE}
    tabbtnTab4^.BaseProps.OnMouseDownUser := @SwitchScreen_OnMouseDownUser;
  {$ENDIF}
  DynTFTAddTabButtonToPageControl(PageControl1, tabbtnTab4);

  tabbtnTab5 := DynTFTTabButton_Create(0, 184, 0, 45, 20);  //Screen: 0
  tabbtnTab5^.Caption := 'Tab5';
  {$IFDEF IsDesktop}
    tabbtnTab5^.BaseProps.OnMouseDownUser^ := SwitchScreen_OnMouseDownUser;
  {$ELSE}
    tabbtnTab5^.BaseProps.OnMouseDownUser := @SwitchScreen_OnMouseDownUser;
  {$ENDIF}
  DynTFTAddTabButtonToPageControl(PageControl1, tabbtnTab5);

  tabbtnTab6 := DynTFTTabButton_Create(0, 230, 0, 45, 20);  //Screen: 0
  tabbtnTab6^.Caption := 'Tab6';
  {$IFDEF IsDesktop}
    tabbtnTab6^.BaseProps.OnMouseDownUser^ := SwitchScreen_OnMouseDownUser;
  {$ELSE}
    tabbtnTab6^.BaseProps.OnMouseDownUser := @SwitchScreen_OnMouseDownUser;
  {$ENDIF}
  DynTFTAddTabButtonToPageControl(PageControl1, tabbtnTab6);


end;


procedure CreateGUI_Screen_1;
begin
  btn1 := DynTFTButton_Create(1, 9, 29, 110, 40);  //Screen: 1
  btn1^.Caption := 'Button 1';
  btn1^.Font_Color := {$IFDEF IsDesktop} $006FAD0B {$ELSE} $0D6D {$ENDIF};

  Arrow1 := DynTFTArrowButton_CreateWithArrow(1, 137, 34, 30, 30, CLeftArrow);  //Screen: 1
  Arrow1^.Color := {$IFDEF IsDesktop} $006FAD0B {$ELSE} $0D6D {$ENDIF};

  Panel1 := DynTFTPanel_Create(1, 105, 85, 274, 98);  //Screen: 1
  Panel1^.Caption := 'Panel 1';
  Panel1^.Color := {$IFDEF IsDesktop} $006FAD6F {$ELSE} $6D6D {$ENDIF};
  Panel1^.Font_Color := CL_BLACK;

  Arrow2 := DynTFTArrowButton_CreateWithArrow(1, 177, 34, 30, 30, CRightArrow);  //Screen: 1
  Arrow2^.Color := {$IFDEF IsDesktop} $006FAD0B {$ELSE} $0D6D {$ENDIF};

  Arrow3 := DynTFTArrowButton_CreateWithArrow(1, 271, 34, 30, 30, CUpArrow);  //Screen: 1
  Arrow3^.Color := {$IFDEF IsDesktop} $006FAD0B {$ELSE} $0D6D {$ENDIF};

  Arrow4 := DynTFTArrowButton_CreateWithArrow(1, 313, 34, 30, 30, CDownArrow);  //Screen: 1
  Arrow4^.Color := {$IFDEF IsDesktop} $006FAD0B {$ELSE} $0D6D {$ENDIF};

  btn3 := DynTFTButton_Create(1, 169, 189, 148, 35);  //Screen: 1
  btn3^.Caption := 'Disabled Button 3';
  btn3^.Font_Color := {$IFDEF IsDesktop} $006FAD0B {$ELSE} $0D6D {$ENDIF};
  btn3^.BaseProps.Enabled := 0;

  Arrow5 := DynTFTArrowButton_CreateWithArrow(1, 17, 165, 45, 45, CUpArrow);  //Screen: 1
  Arrow5^.Color := {$IFDEF IsDesktop} $00A0E632 {$ELSE} $3734 {$ENDIF};

  Arrow6 := DynTFTArrowButton_CreateWithArrow(1, 17, 221, 45, 45, CDownArrow);  //Screen: 1
  Arrow6^.Color := {$IFDEF IsDesktop} $00A0E632 {$ELSE} $3734 {$ENDIF};

  Arrow7 := DynTFTArrowButton_CreateWithArrow(1, 417, 165, 45, 45, CLeftArrow);  //Screen: 1
  Arrow7^.Color := {$IFDEF IsDesktop} $00A0E632 {$ELSE} $3734 {$ENDIF};

  Arrow8 := DynTFTArrowButton_CreateWithArrow(1, 417, 221, 45, 45, CRightArrow);  //Screen: 1
  Arrow8^.Color := {$IFDEF IsDesktop} $00A0E632 {$ELSE} $3734 {$ENDIF};

  btn2 := DynTFTButton_Create(1, 361, 29, 110, 40);  //Screen: 1
  btn2^.Caption := 'Button 2';
  btn2^.Font_Color := {$IFDEF IsDesktop} $006FAD0B {$ELSE} $0D6D {$ENDIF};

  btn4 := DynTFTButton_Create(1, 169, 229, 148, 35);  //Screen: 1
  btn4^.Caption := 'Disabled Button 4';
  btn4^.Font_Color := {$IFDEF IsDesktop} $006FAD0B {$ELSE} $0D6D {$ENDIF};
  btn4^.BaseProps.Enabled := 0;

end;


procedure CreateGUI_Screen_2;
begin
  ScrollBar1 := DynTFTScrollBar_CreateWithDir(2, 25, 237, 409, 20, CScrollBarHorizDir);  //Screen: 2
  ScrollBar1^.Max := 100;
  ScrollBar1^.Min := 0;
  ScrollBar1^.Position := 0;
  DynTFTUpdateScrollbarEventHandlers(ScrollBar1);

  ScrollBar2 := DynTFTScrollBar_CreateWithDir(2, 441, 29, 20, 208, CScrollBarVertDir);  //Screen: 2
  ScrollBar2^.Max := 100;
  ScrollBar2^.Min := 0;
  ScrollBar2^.Position := 0;
  DynTFTUpdateScrollbarEventHandlers(ScrollBar2);

  CheckBox1 := DynTFTCheckBox_Create(2, 25, 29, 140, 25);  //Screen: 2
  CheckBox1^.Caption := 'CheckBox 1';
  CheckBox1^.Color := {$IFDEF IsDesktop} $00BE8296 {$ELSE} $9417 {$ENDIF};
  CheckBox1^.Font_Color := CL_BLACK;

  CheckBox2 := DynTFTCheckBox_Create(2, 25, 69, 140, 25);  //Screen: 2
  CheckBox2^.Caption := 'CheckBox 2';
  CheckBox2^.Color := {$IFDEF IsDesktop} $00BE8296 {$ELSE} $9417 {$ENDIF};
  CheckBox2^.Font_Color := CL_BLACK;

  CheckBox3 := DynTFTCheckBox_Create(2, 249, 29, 140, 25);  //Screen: 2
  CheckBox3^.Caption := 'CheckBox 3';
  CheckBox3^.Color := {$IFDEF IsDesktop} $00BE8296 {$ELSE} $9417 {$ENDIF};
  CheckBox3^.Font_Color := CL_BLACK;
  CheckBox3^.BaseProps.Enabled := 0;

  ListBox1 := DynTFTListBox_Create(2, 25, 109, 140, 112);  //Screen: 2
  ListBox1^.Items^.Count := 10;
  ListBox1^.Items^.BackgroundColor := {$IFDEF IsDesktop} $00FAAFBE {$ELSE} $BD7F {$ENDIF};
  DynTFTUpdateScrollbarEventHandlers(ListBox1^.VertScrollBar);
  {$IFDEF UseExternalItems}
    {$IFDEF IsDesktop}
      ListBox1^.Items^.OnGetItem^ := ListBoxItemsGetItemText;
    {$ELSE}
      ListBox1^.Items^.OnGetItem := @ListBoxItemsGetItemText;
    {$ENDIF}
  {$ELSE}
    ListBox1^.Items^.Strings[0] := 'one';
    ListBox1^.Items^.Strings[1] := 'two';
    ListBox1^.Items^.Strings[2] := 'three';
    ListBox1^.Items^.Strings[3] := 'four';
    ListBox1^.Items^.Strings[4] := 'five';
    ListBox1^.Items^.Strings[5] := 'six';
    ListBox1^.Items^.Strings[6] := 'seven';
    ListBox1^.Items^.Strings[7] := 'eight';
    ListBox1^.Items^.Strings[8] := 'nine';
    ListBox1^.Items^.Strings[9] := 'ten';
  {$ENDIF}

  ListBox3 := DynTFTListBox_Create(2, 249, 109, 140, 112);  //Screen: 2
  ListBox3^.Items^.Count := 10;
  DynTFTUpdateScrollbarEventHandlers(ListBox3^.VertScrollBar);
  {$IFDEF UseExternalItems}
    {$IFDEF IsDesktop}
      ListBox3^.Items^.OnGetItem^ := ListBoxItemsGetItemText;
    {$ELSE}
      ListBox3^.Items^.OnGetItem := @ListBoxItemsGetItemText;
    {$ENDIF}
  {$ELSE}
    ListBox3^.Items^.Strings[0] := 'one';
    ListBox3^.Items^.Strings[1] := 'two';
    ListBox3^.Items^.Strings[2] := 'three';
    ListBox3^.Items^.Strings[3] := 'four';
    ListBox3^.Items^.Strings[4] := 'five';
    ListBox3^.Items^.Strings[5] := 'six';
    ListBox3^.Items^.Strings[6] := 'seven';
    ListBox3^.Items^.Strings[7] := 'eight';
    ListBox3^.Items^.Strings[8] := 'nine';
    ListBox3^.Items^.Strings[9] := 'ten';
  {$ENDIF}

end;


procedure CreateGUI_Screen_3;
begin
  lbl1 := DynTFTLabel_Create(3, 9, 29, 80, 30);  //Screen: 3
  lbl1^.Caption := 'Label 1';
  lbl1^.Color := {$IFDEF IsDesktop} $00FA8282 {$ELSE} $841F {$ENDIF};
  lbl1^.Font_Color := CL_BLACK;

  lbl2 := DynTFTLabel_Create(3, 129, 29, 80, 30);  //Screen: 3
  lbl2^.Caption := 'Label 2';
  lbl2^.Color := {$IFDEF IsDesktop} $00FA8282 {$ELSE} $841F {$ENDIF};
  lbl2^.Font_Color := CL_BLACK;

  rdgrpTest := DynTFTRadioGroup_Create(3, 9, 93, 160, 160);  //Screen: 3
  rdgrpTest^.Caption := 'Radio Group 1';


  radbtnfirst := DynTFTRadioButton_Create(3, 14, 108, 150, 15);  //Screen: 3
  radbtnfirst^.Caption := 'first';
  DynTFTAddRadioButtonToRadioGroup(rdgrpTest, radbtnfirst);

  radbtnsecond := DynTFTRadioButton_Create(3, 14, 123, 150, 15);  //Screen: 3
  radbtnsecond^.Caption := 'second';
  DynTFTAddRadioButtonToRadioGroup(rdgrpTest, radbtnsecond);

  radbtnthird := DynTFTRadioButton_Create(3, 14, 138, 150, 15);  //Screen: 3
  radbtnthird^.Caption := 'third';
  DynTFTAddRadioButtonToRadioGroup(rdgrpTest, radbtnthird);

  radbtnfourth := DynTFTRadioButton_Create(3, 14, 153, 150, 15);  //Screen: 3
  radbtnfourth^.Caption := 'fourth';
  DynTFTAddRadioButtonToRadioGroup(rdgrpTest, radbtnfourth);

  radbtnfifth := DynTFTRadioButton_Create(3, 14, 168, 150, 15);  //Screen: 3
  radbtnfifth^.Caption := 'fifth';
  DynTFTAddRadioButtonToRadioGroup(rdgrpTest, radbtnfifth);

  radbtnsixth := DynTFTRadioButton_Create(3, 14, 183, 150, 15);  //Screen: 3
  radbtnsixth^.Caption := 'sixth';
  DynTFTAddRadioButtonToRadioGroup(rdgrpTest, radbtnsixth);

  radbtnseventh := DynTFTRadioButton_Create(3, 14, 198, 150, 15);  //Screen: 3
  radbtnseventh^.Caption := 'seventh';
  DynTFTAddRadioButtonToRadioGroup(rdgrpTest, radbtnseventh);

  radbtneighth := DynTFTRadioButton_Create(3, 14, 213, 150, 15);  //Screen: 3
  radbtneighth^.Caption := 'eighth';
  DynTFTAddRadioButtonToRadioGroup(rdgrpTest, radbtneighth);

  rdgrpTest^.ItemIndex := 2;

  lbl3 := DynTFTLabel_Create(3, 265, 29, 80, 30);  //Screen: 3
  lbl3^.Caption := 'Label 3';
  lbl3^.Color := {$IFDEF IsDesktop} $00FA8282 {$ELSE} $841F {$ENDIF};
  lbl3^.Font_Color := CL_BLACK;

  lbl4 := DynTFTLabel_Create(3, 385, 29, 80, 30);  //Screen: 3
  lbl4^.Caption := 'Label 4';
  lbl4^.Color := {$IFDEF IsDesktop} $00FA8282 {$ELSE} $841F {$ENDIF};
  lbl4^.Font_Color := CL_BLACK;

  rdgrpTest1 := DynTFTRadioGroup_Create(3, 249, 93, 160, 160);  //Screen: 3
  rdgrpTest1^.Caption := 'Radio Group 2';


  radbtnone := DynTFTRadioButton_Create(3, 254, 108, 150, 15);  //Screen: 3
  radbtnone^.Caption := 'one';
  DynTFTAddRadioButtonToRadioGroup(rdgrpTest1, radbtnone);

  radbtntwo := DynTFTRadioButton_Create(3, 254, 123, 150, 15);  //Screen: 3
  radbtntwo^.Caption := 'two';
  DynTFTAddRadioButtonToRadioGroup(rdgrpTest1, radbtntwo);

  radbtnthree := DynTFTRadioButton_Create(3, 254, 138, 150, 15);  //Screen: 3
  radbtnthree^.Caption := 'three';
  DynTFTAddRadioButtonToRadioGroup(rdgrpTest1, radbtnthree);

  radbtnfour := DynTFTRadioButton_Create(3, 254, 153, 150, 15);  //Screen: 3
  radbtnfour^.Caption := 'four';
  DynTFTAddRadioButtonToRadioGroup(rdgrpTest1, radbtnfour);

  radbtnfive := DynTFTRadioButton_Create(3, 254, 168, 150, 15);  //Screen: 3
  radbtnfive^.Caption := 'five';
  DynTFTAddRadioButtonToRadioGroup(rdgrpTest1, radbtnfive);

  radbtnsix := DynTFTRadioButton_Create(3, 254, 183, 150, 15);  //Screen: 3
  radbtnsix^.Caption := 'six';
  DynTFTAddRadioButtonToRadioGroup(rdgrpTest1, radbtnsix);

  radbtnseven := DynTFTRadioButton_Create(3, 254, 198, 150, 15);  //Screen: 3
  radbtnseven^.Caption := 'seven';
  DynTFTAddRadioButtonToRadioGroup(rdgrpTest1, radbtnseven);

  radbtneight := DynTFTRadioButton_Create(3, 254, 213, 150, 15);  //Screen: 3
  radbtneight^.Caption := 'eight';
  DynTFTAddRadioButtonToRadioGroup(rdgrpTest1, radbtneight);

  rdgrpTest1^.ItemIndex := 2;

end;


procedure CreateGUI_Screen_4;
begin
  Edit1 := DynTFTEdit_Create(4, 9, 21, 200, 24);  //Screen: 4
  Edit1^.Text := 'Edit1';

  vkTest := DynTFTVirtualKeyboard_Create(4, 1, 45, 318, 184);  //Screen: 4
  vkTest^.Color := {$IFDEF IsDesktop} $00FFFFFF {$ELSE} $FFFF {$ENDIF};
  {$IFDEF IsDesktop}
    vkTest^.OnCharKey^ := VirtualKeyboard_OnCharKey;
    vkTest^.OnSpecialKey^ := VirtualKeyboard_OnSpecialKey;
  {$ELSE}
    vkTest^.OnCharKey := @VirtualKeyboard_OnCharKey;
    vkTest^.OnSpecialKey := @VirtualKeyboard_OnSpecialKey;
  {$ENDIF}

end;


procedure CreateGUI_Screen_5;
begin
  ComboBox1 := DynTFTComboBox_Create(5, 9, 29, 160, 22);  //Screen: 5
  ComboBox1^.ListBox^.Items^.BackgroundColor := {$IFDEF IsDesktop} $00FAFA6E {$ELSE} $6FDF {$ENDIF};
  ComboBox1^.Edit^.Color := {$IFDEF IsDesktop} $00FAFA6E {$ELSE} $6FDF {$ENDIF};
  ComboBox1^.Editable := False;
  ComboBox1^.ListBox^.Items^.Count := 10;
  {$IFDEF UseExternalItems}
    {$IFDEF IsDesktop}
      ComboBox1^.ListBox^.Items^.OnGetItem^ := ComboBoxItemsGetItemText;
    {$ELSE}
      ComboBox1^.ListBox^.Items^.OnGetItem := @ComboBoxItemsGetItemText;
    {$ENDIF}
  {$ELSE}
    ComboBox1^.ListBox^.Items^.Strings[0] := 'one';
    ComboBox1^.ListBox^.Items^.Strings[1] := 'two';
    ComboBox1^.ListBox^.Items^.Strings[2] := 'three';
    ComboBox1^.ListBox^.Items^.Strings[3] := 'four';
    ComboBox1^.ListBox^.Items^.Strings[4] := 'five';
    ComboBox1^.ListBox^.Items^.Strings[5] := 'six';
    ComboBox1^.ListBox^.Items^.Strings[6] := 'seven';
    ComboBox1^.ListBox^.Items^.Strings[7] := 'eight';
    ComboBox1^.ListBox^.Items^.Strings[8] := 'nine';
    ComboBox1^.ListBox^.Items^.Strings[9] := 'ten';
  {$ENDIF}

  ComboBox2 := DynTFTComboBox_Create(5, 9, 77, 160, 24);  //Screen: 5
  ComboBox2^.ListBox^.Items^.Count := 10;
  {$IFDEF UseExternalItems}
    {$IFDEF IsDesktop}
      ComboBox2^.ListBox^.Items^.OnGetItem^ := ComboBoxItemsGetItemText;
    {$ELSE}
      ComboBox2^.ListBox^.Items^.OnGetItem := @ComboBoxItemsGetItemText;
    {$ENDIF}
  {$ELSE}
    ComboBox2^.ListBox^.Items^.Strings[0] := 'one';
    ComboBox2^.ListBox^.Items^.Strings[1] := 'two';
    ComboBox2^.ListBox^.Items^.Strings[2] := 'three';
    ComboBox2^.ListBox^.Items^.Strings[3] := 'four';
    ComboBox2^.ListBox^.Items^.Strings[4] := 'five';
    ComboBox2^.ListBox^.Items^.Strings[5] := 'six';
    ComboBox2^.ListBox^.Items^.Strings[6] := 'seven';
    ComboBox2^.ListBox^.Items^.Strings[7] := 'eight';
    ComboBox2^.ListBox^.Items^.Strings[8] := 'nine';
    ComboBox2^.ListBox^.Items^.Strings[9] := 'ten';
  {$ENDIF}

  Label4 := DynTFTLabel_Create(5, 193, 77, 80, 24);  //Screen: 5
  Label4^.Caption := 'Editable';
  Label4^.Color := {$IFDEF IsDesktop} $00C8C800 {$ELSE} $0659 {$ENDIF};
  Label4^.Font_Color := CL_WHITE;

  Label5 := DynTFTLabel_Create(5, 193, 29, 130, 24);  //Screen: 5
  Label5^.Caption := 'Selectable only';
  Label5^.Color := {$IFDEF IsDesktop} $00C8C800 {$ELSE} $0659 {$ENDIF};
  Label5^.Font_Color := CL_WHITE;

  ListBox2 := DynTFTListBox_Create(5, 9, 133, 160, 120);  //Screen: 5
  ListBox2^.Items^.Count := 10;
  ListBox2^.Items^.BackgroundColor := {$IFDEF IsDesktop} $00F0F000 {$ELSE} $079E {$ENDIF};
  DynTFTUpdateScrollbarEventHandlers(ListBox2^.VertScrollBar);
  {$IFDEF UseExternalItems}
    {$IFDEF IsDesktop}
      ListBox2^.Items^.OnGetItem^ := ListBoxItemsGetItemText;
    {$ELSE}
      ListBox2^.Items^.OnGetItem := @ListBoxItemsGetItemText;
    {$ENDIF}
  {$ELSE}
    ListBox2^.Items^.Strings[0] := 'one';
    ListBox2^.Items^.Strings[1] := 'two';
    ListBox2^.Items^.Strings[2] := 'three';
    ListBox2^.Items^.Strings[3] := 'four';
    ListBox2^.Items^.Strings[4] := 'five';
    ListBox2^.Items^.Strings[5] := 'six';
    ListBox2^.Items^.Strings[6] := 'seven';
    ListBox2^.Items^.Strings[7] := 'eight';
    ListBox2^.Items^.Strings[8] := 'nine';
    ListBox2^.Items^.Strings[9] := 'ten';
  {$ENDIF}

  ListBox4 := DynTFTListBox_Create(5, 249, 133, 160, 120);  //Screen: 5
  ListBox4^.Items^.Count := 10;
  ListBox4^.Items^.BackgroundColor := {$IFDEF IsDesktop} $00F0F000 {$ELSE} $079E {$ENDIF};
  DynTFTUpdateScrollbarEventHandlers(ListBox4^.VertScrollBar);
  {$IFDEF UseExternalItems}
    {$IFDEF IsDesktop}
      ListBox4^.Items^.OnGetItem^ := ListBoxItemsGetItemText;
    {$ELSE}
      ListBox4^.Items^.OnGetItem := @ListBoxItemsGetItemText;
    {$ENDIF}
  {$ELSE}
    ListBox4^.Items^.Strings[0] := 'one';
    ListBox4^.Items^.Strings[1] := 'two';
    ListBox4^.Items^.Strings[2] := 'three';
    ListBox4^.Items^.Strings[3] := 'four';
    ListBox4^.Items^.Strings[4] := 'five';
    ListBox4^.Items^.Strings[5] := 'six';
    ListBox4^.Items^.Strings[6] := 'seven';
    ListBox4^.Items^.Strings[7] := 'eight';
    ListBox4^.Items^.Strings[8] := 'nine';
    ListBox4^.Items^.Strings[9] := 'ten';
  {$ENDIF}

end;


procedure CreateGUI_Screen_6;
begin
  TrackBar1 := DynTFTTrackBar_CreateWithDir(6, 9, 33, 200, 24, CTrackBarHorizDir);  //Screen: 6
  TrackBar1^.Max := 10;
  TrackBar1^.Min := 0;
  TrackBar1^.Position := 3;
  DynTFTUpdateTrackBarEventHandlers(TrackBar1);

  TrackBar2 := DynTFTTrackBar_CreateWithDir(6, 25, 93, 24, 160, CTrackBarVertDir);  //Screen: 6
  TrackBar2^.Max := 10;
  TrackBar2^.Min := 0;
  TrackBar2^.Position := 7;
  DynTFTUpdateTrackBarEventHandlers(TrackBar2);

  ProgressBar2 := DynTFTProgressBar_CreateWithDir(6, 257, 93, 24, 160, CProgressBarVertDir);  //Screen: 6
  ProgressBar2^.Max := 10;
  ProgressBar2^.Min := 0;
  ProgressBar2^.Position := 7;
  ProgressBar1 := DynTFTProgressBar_CreateWithDir(6, 257, 45, 204, 20, CProgressBarHorizDir);  //Screen: 6
  ProgressBar1^.Max := 10;
  ProgressBar1^.Min := 0;
  ProgressBar1^.Position := 3;
end;


procedure DrawGUI;
begin
  CreateGUI_Screen_0;
  CreateGUI_Screen_1;
  CreateGUI_Screen_2;
  CreateGUI_Screen_3;
  CreateGUI_Screen_4;
  CreateGUI_Screen_5;
  CreateGUI_Screen_6;

  DynTFTRepaintScreenComponents(0, CREPAINTONSTARTUP, nil);
  DynTFTRepaintScreenComponents(1, CREPAINTONSTARTUP, nil);
end;


procedure DynTFT_GUI_Start;
begin
  {$IFDEF IsDesktop}
    DynTFT_DebugConsole('Entering DynTFT_GUI_Start');
  {$ENDIF}

  DynTFTInitInputDevStateFlags;

  DynTFTInitComponentTypeRegistration;
  DynTFTInitComponentContainers;    //must be called after InitComponentTypeRegistration
  RegisterAllComponentsEvents;

  SetScreenActivity;
  DrawGUI;
end;


end.
