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

  DynTFTAllComponentsContainer[1].ScreenColor := CL_DynTFTScreen_Background;
end;


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


procedure DrawGUI;
begin
  DynTFT_Set_Pen(DynTFTAllComponentsContainer[1].ScreenColor, 1);
  DynTFT_Set_Brush(1, DynTFTAllComponentsContainer[1].ScreenColor, 0, 0, 0, 0);
  DynTFT_Rectangle(0, 0, TFT_DISP_WIDTH, TFT_DISP_HEIGHT);

  SelfDestroyButton := DynTFTButton_Create(1, 580, 140, 100, 20);
  {$IFDEF IsDesktop}
    SelfDestroyButton^.BaseProps.OnMouseUpUser^ := SelfDestroy_OnMouseUpUser;
  {$ELSE}
    SelfDestroyButton^.BaseProps.OnMouseUpUser := @SelfDestroy_OnMouseUpUser;
  {$ENDIF}
  SelfDestroyButton^.Caption := 'SelfDestroy';
  

  ATestButton := DynTFTButton_Create(1, 20, 20, 80, 16);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestButton)));
  ATestButton^.Caption := 'shapes';
  {$IFDEF IsDesktop}
    ATestButton^.BaseProps.OnMouseDownUser^ := TestShapes_OnMouseDownUser;
  {$ELSE}
    ATestButton^.BaseProps.OnMouseDownUser := @TestShapes_OnMouseDownUser;
  {$ENDIF}
  ShapesButton := ATestButton;


  ATestArrowButton := DynTFTArrowButton_CreateWithArrow(1, 40, 60, 40, 16, CUpArrow);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestArrowButton)));
                 
  ATestArrowButton := DynTFTArrowButton_CreateWithArrow(1, 120, 60, 40, 16, CDownArrow);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtr(ATestArrowButton)));

  ATestArrowButton := DynTFTArrowButton_CreateWithArrow(1, 40, 90, 40, 16, CLeftArrow);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestArrowButton)));

  ATestArrowButton := DynTFTArrowButton_CreateWithArrow(1, 120, 90, 40, 16, CRightArrow);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestArrowButton)));


  ATestArrowButton := DynTFTArrowButton_CreateWithArrow(1, 240, 60, 40, 30, CUpArrow);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestArrowButton)));

  ATestArrowButton := DynTFTArrowButton_CreateWithArrow(1, 320, 60, 40, 30, CDownArrow);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestArrowButton)));

  ATestArrowButton := DynTFTArrowButton_CreateWithArrow(1, 240, 100, 40, 30, CLeftArrow);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestArrowButton)));

  ATestArrowButton := DynTFTArrowButton_CreateWithArrow(1, 320, 100, 40, 30, CRightArrow);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestArrowButton)));


  ATestButton := DynTFTButton_Create(1, 20, 220, 80, 16);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestButton)));
  ATestButton^.BaseProps.Enabled := 0;
  ATestButton^.Caption := 'Disabled';

  ATestArrowButton := DynTFTArrowButton_CreateWithArrow(1, 40, 260, 40, 16, CUpArrow);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestArrowButton)));
  ATestArrowButton^.BaseProps.Enabled := 0;
  //DrawArrowButton(ATestArrowButton, False, False);

  ATestArrowButton := DynTFTArrowButton_CreateWithArrow(1, 120, 260, 40, 16, CDownArrow);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestArrowButton)));
  ATestArrowButton^.BaseProps.Enabled := 0;
  //DrawArrowButton(ATestArrowButton, False, False);

  ATestArrowButton := DynTFTArrowButton_CreateWithArrow(1, 40, 290, 40, 16, CLeftArrow);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestArrowButton)));
  ATestArrowButton^.BaseProps.Enabled := 0;
  //DrawArrowButton(ATestArrowButton, False, False);

  ATestArrowButton := DynTFTArrowButton_CreateWithArrow(1, 120, 290, 40, 16, CRightArrow);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestArrowButton)));
  ATestArrowButton^.BaseProps.Enabled := 0;
  //DrawArrowButton(ATestArrowButton, False, False);


  ATestArrowButton := DynTFTArrowButton_CreateWithArrow(1, 240, 260, 40, 30, CUpArrow);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestArrowButton)));
  ATestArrowButton^.BaseProps.Enabled := 0;
  //DrawArrowButton(ATestArrowButton, False, False);

  ATestArrowButton := DynTFTArrowButton_CreateWithArrow(1, 320, 260, 40, 30, CDownArrow);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestArrowButton)));
  ATestArrowButton^.BaseProps.Enabled := 0;
  //DrawArrowButton(ATestArrowButton, False, False);

  ATestArrowButton := DynTFTArrowButton_CreateWithArrow(1, 240, 300, 40, 30, CLeftArrow);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestArrowButton)));
  ATestArrowButton^.BaseProps.Enabled := 0;
  //DrawArrowButton(ATestArrowButton, False, False);

  ATestArrowButton := DynTFTArrowButton_CreateWithArrow(1, 320, 300, 40, 30, CRightArrow);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestArrowButton)));
  ATestArrowButton^.BaseProps.Enabled := 0;
  //DrawArrowButton(ATestArrowButton, False, False);

  
  ATestButton := DynTFTButton_Create(1, 320, 20, 100, 20);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestButton)));
  ATestButton^.Color := CL_YELLOW;
  ATestButton^.Font_Color := CL_RED;
  ATestButton^.Caption := 'Create button';

  {$IFDEF IsDesktop}
    ATestButton^.BaseProps.OnMouseUpUser^ := CreateNewButton_OnMouseUpUser;
  {$ELSE}
    ATestButton^.BaseProps.OnMouseUpUser := @CreateNewButton_OnMouseUpUser;
  {$ENDIF}



  ATestCheckBox := DynTFTCheckBox_Create(1, 192, 528, 120, 20);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestCheckBox)));
  ATestCheckBox^.Color := CL_YELLOW;
  ATestCheckBox^.Caption := 'Password Char';
  {$IFDEF IsDesktop}
    ATestCheckBox^.BaseProps.OnMouseUpUser^ := CheckPasswordChar_OnMouseUpUser;
  {$ELSE}
    ATestCheckBox^.BaseProps.OnMouseUpUser := @CheckPasswordChar_OnMouseUpUser;
  {$ENDIF}
  //DrawCheckBox(ATestCheckBox, True);

  ATestCheckBox := DynTFTCheckBox_Create(1, 10, 335, 100, 20);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestCheckBox)));
  ATestCheckBox^.BaseProps.Enabled := 0;
  //DrawCheckBox(ATestCheckBox, True);
  ATestCheckBox^.Caption := 'Disabled';


  ATestCheckBox := DynTFTCheckBox_Create(1, 364, 438, 120, 20);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestCheckBox)));
  ATestCheckBox^.Color := CL_AQUA;
  ATestCheckBox^.Caption := 'ScrBar Visibility';
  {$IFDEF IsDesktop}
    ATestCheckBox^.BaseProps.OnMouseUpUser^ := CheckTestVisibility_OnMouseUpUser;
  {$ELSE}
    ATestCheckBox^.BaseProps.OnMouseUpUser := @CheckTestVisibility_OnMouseUpUser;
  {$ENDIF}
  ATestCheckBox^.Checked := True;


  ATestCheckBox := DynTFTCheckBox_Create(1, 364, 478, 120, 20);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestCheckBox)));
  ATestCheckBox^.Color := CL_FUCHSIA;
  ATestCheckBox^.Caption := 'ScrBar Enabling';
  {$IFDEF IsDesktop}
    ATestCheckBox^.BaseProps.OnMouseUpUser^ := CheckTestEnabling_OnMouseUpUser;
  {$ELSE}
    ATestCheckBox^.BaseProps.OnMouseUpUser := @CheckTestEnabling_OnMouseUpUser;
  {$ENDIF}


  ATestCheckBox := DynTFTCheckBox_Create(1, 364, 520, 120, 20);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestCheckBox)));
  ATestCheckBox^.Color := CL_WHITE;
  ATestCheckBox^.Caption := 'rdBtn Visibility';
  {$IFDEF IsDesktop}
    ATestCheckBox^.BaseProps.OnMouseUpUser^ := CheckTestRdBtnVisibility_OnMouseUpUser;
  {$ELSE}
    ATestCheckBox^.BaseProps.OnMouseUpUser := @CheckTestRdBtnVisibility_OnMouseUpUser;
  {$ENDIF}
  ATestCheckBox^.Checked := True;


  ATestCheckBox := DynTFTCheckBox_Create(1, 490, 520, 120, 20);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestCheckBox)));
  ATestCheckBox^.Color := CL_YELLOW;
  ATestCheckBox^.Caption := 'LstBox Visibility';
  {$IFDEF IsDesktop}
    ATestCheckBox^.BaseProps.OnMouseUpUser^ := CheckTestLstBoxVisibility_OnMouseUpUser;
  {$ELSE}
    ATestCheckBox^.BaseProps.OnMouseUpUser := @CheckTestLstBoxVisibility_OnMouseUpUser;
  {$ENDIF}
  ATestCheckBox^.Checked := True;

  
  ATestCheckBox := DynTFTCheckBox_Create(1, 490, 438, 120, 20);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestCheckBox)));
  ATestCheckBox^.Color := CL_RED;
  ATestCheckBox^.Caption := 'rdGrp Visibility';
  {$IFDEF IsDesktop}
    ATestCheckBox^.BaseProps.OnMouseUpUser^ := CheckTestRdGrpVisibility_OnMouseUpUser;
  {$ELSE}
    ATestCheckBox^.BaseProps.OnMouseUpUser := @CheckTestRdGrpVisibility_OnMouseUpUser;
  {$ENDIF}
  ATestCheckBox^.Checked := True;


  ATestCheckBox := DynTFTCheckBox_Create(1, 490, 478, 120, 20);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestCheckBox)));
  ATestCheckBox^.Color := CL_GREEN;
  ATestCheckBox^.Caption := 'pag Visibility';
  {$IFDEF IsDesktop}
    ATestCheckBox^.BaseProps.OnMouseUpUser^ := CheckTestPagVisibility_OnMouseUpUser;
  {$ELSE}
    ATestCheckBox^.BaseProps.OnMouseUpUser := @CheckTestPagVisibility_OnMouseUpUser;
  {$ENDIF}
  ATestCheckBox^.Checked := True;


  ATestPanel := DynTFTPanel_Create(1, 44, 142, 80, 30);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestPanel)));
  ATestPanel^.Caption := 'Panel1';

  ATestPanel := DynTFTPanel_Create(1, 44, 182, 90, 30);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestPanel)));
  ATestPanel^.BaseProps.Enabled := 0;
  ATestPanel^.Caption := 'Disabled';
  //DrawPanel(ATestPanel, True);

  ATestPanel := DynTFTPanel_Create(1, 144, 142, 100, 30);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestPanel)));
  ATestPanel^.Caption := 'Panel2';
  //DrawPanel(ATestPanel, True);

  ATestScrollBar := DynTFTScrollBar_CreateWithDir(1, 272, 144, 200, 30, CScrollBarHorizDir);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestScrollBar)));
  //UpdateScrollbarEventHandlers(ATestScrollBar);

  ATestScrollBar := DynTFTScrollBar_CreateWithDir(1, 442, 200, 30, 200, CScrollBarVertDir);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestScrollBar)));
  //UpdateScrollbarEventHandlers(ATestScrollBar);
  {$IFDEF IsDesktop}
    ATestScrollBar^.OnScrollBarChange^ := TestScrollBarChange;
  {$ELSE}
    ATestScrollBar^.OnScrollBarChange := @TestScrollBarChange;
  {$ENDIF}

  ATestScrollBar := DynTFTScrollBar_CreateWithDir(1, 482, 200, 30, 200, CScrollBarVertDir);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestScrollBar)));
  //UpdateScrollbarEventHandlers(ATestScrollBar);
  DynTFTDisableScrollBar(ATestScrollBar);

  ATestListBox := DynTFTListBox_Create(1, 133, 339, 200, 76);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestListBox^.VertScrollBar)));
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestListBox)));
  SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestListBox^.Items)));
  //UpdateScrollbarEventHandlers(ATestListBox^.VertScrollBar);

  {$IFDEF UseExternalItems}
    ATestListBox^.Items^.Count := 160000;
    {$IFDEF IsDesktop}
      //ATestListBox^.Items^.OnGetItem^ := ListBoxItemsGetItemText;
    {$ELSE}
      ATestListBox^.Items^.OnGetItem := @ListBoxItemsGetItemText;
    {$ENDIF}
  {$ELSE}
    ATestListBox^.Items^.Count := 16;
    ATestListBox^.Items^.Strings[0] := 'one';
    ATestListBox^.Items^.Strings[1] := 'two';
    ATestListBox^.Items^.Strings[2] := 'three';
    ATestListBox^.Items^.Strings[3] := 'four';
    ATestListBox^.Items^.Strings[4] := 'five';
    ATestListBox^.Items^.Strings[5] := 'six';
    ATestListBox^.Items^.Strings[6] := 'seven';
    ATestListBox^.Items^.Strings[7] := 'eight';
    ATestListBox^.Items^.Strings[8] := 'nine';
    ATestListBox^.Items^.Strings[9] := 'ten';
    ATestListBox^.Items^.Strings[10] := 'eleven';
    ATestListBox^.Items^.Strings[11] := 'twelve';
    ATestListBox^.Items^.Strings[12] := 'thirteen';
    ATestListBox^.Items^.Strings[13] := 'fourteen';
    ATestListBox^.Items^.Strings[14] := 'fifteen';
    ATestListBox^.Items^.Strings[15] := 'sixteen - fpWgJj';
  {$ENDIF}   
  //DrawListBox(ATestListBox, True);
  {$IFDEF IsDesktop}
    ATestListBox^.VertScrollBar^.PnlScroll^.BaseProps.OnMouseMoveUser^ := LstBoxScroll_OnMouseMoveUser;
  {$ELSE}
    ATestListBox^.VertScrollBar^.PnlScroll^.BaseProps.OnMouseMoveUser := @LstBoxScroll_OnMouseMoveUser;
  {$ENDIF}


  ATestLabel := DynTFTLabel_Create(1, 236, 20, 80, 20);
  ATestLabel^.Caption := 'lblDisabled';
  ATestLabel^.BaseProps.Enabled := 0;

  ATestLabel := DynTFTLabel_Create(1, 130, 20, 100, 30);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestLabel)));
  ATestLabel^.Color := CL_GREEN;
  ATestLabel^.Font_Color := CL_WHITE;
  ATestLabel^.Caption := 'My label';


  ATestLabel := DynTFTLabel_Create(1, 497, 575, 100, 20);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestLabel)));
  ATestLabel^.Color := CL_MAROON;
  ATestLabel^.Font_Color := CL_WHITE;
  ATestLabel^.Caption := 'Repainted area';


  ATestRadioGroup := DynTFTRadioGroup_Create(1, 12, 444, 150, 130);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestRadioGroup)));
  ATestRadioGroup^.Caption := 'Some RadioGroup';
  //DisableComponent(PDynTFTBaseComponent(TPtrRec(ATestRadioGroup)));

  ATestRadioButton1 := DynTFTRadioButton_Create(1, 18, 464, 120, 16);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestRadioButton)));
  ATestRadioButton1^.Caption := 'RadioButton 1 fp';
  DynTFTAddRadioButtonToRadioGroup(ATestRadioGroup, ATestRadioButton1);

  ATestRadioButton2 := DynTFTRadioButton_Create(1, 18, 494, 120, 16);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestRadioButton)));
  ATestRadioButton2^.Caption := 'RadioButton 2 fp';
  DynTFTAddRadioButtonToRadioGroup(ATestRadioGroup, ATestRadioButton2);

  ATestRadioButton3 := DynTFTRadioButton_Create(1, 18, 544, 120, 16);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestRadioButton)));
  ATestRadioButton3^.Caption := 'RadioButton 3 fp';
  DynTFTAddRadioButtonToRadioGroup(ATestRadioGroup, ATestRadioButton3);

  ATestRadioGroup^.ItemIndex := 0;
  DynTFTDrawRadioGroup(ATestRadioGroup, True);


  ATestPageControl := DynTFTPageControl_Create(1, 200, 570, 500, 40);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestPageControl)));

  ATabButton1 := DynTFTTabButton_Create(1, 200, 570, 80, 30);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestTabButton)));
  ATabButton1^.Caption := 'Tab 1';
  DynTFTAddTabButtonToPageControl(ATestPageControl, ATabButton1);

  ATabButton2 := DynTFTTabButton_Create(1, 280, 570, 80, 30);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestTabButton)));
  ATabButton2^.Caption := 'Tab 2';
  DynTFTAddTabButtonToPageControl(ATestPageControl, ATabButton2);

  ATabButton3 := DynTFTTabButton_Create(1, 360, 570, 80, 30);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestTabButton)));
  ATabButton3^.Caption := 'Tab 3';
  DynTFTAddTabButtonToPageControl(ATestPageControl, ATabButton3);
  //DisableComponent(PDynTFTBaseComponent(TPtrRec(ATestPageControl)));

  //DrawPageControl(ATestPageControl, True);

  ATestEdit := DynTFTEdit_Create(1, 192, 434, 150, 22);
  ATestEdit^.Text := 'This is another long text for Edit.';
  DynTFTEditAfterSetText(ATestEdit);
  DynTFTDisableComponent(PDynTFTBaseComponent(TPtrRec(ATestEdit)));

  ATestEdit := DynTFTEdit_Create(1, 192, 500, 150, 22);
  ATestEdit^.Text := 'This is the second long text Edit.';
  DynTFTEditAfterSetText(ATestEdit);

  ATestArrowButton := DynTFTArrowButton_CreateWithArrow(1, 194, 462, 40, 16, CLeftArrow);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestArrowButton)));
  {$IFDEF IsDesktop}
    ATestArrowButton^.BaseProps.OnMouseDownUser^ := MoveCarretLeft;
  {$ELSE}
    ATestArrowButton^.BaseProps.OnMouseDownUser := @MoveCarretLeft;
  {$ENDIF}
  ATestArrowButton^.BaseProps.Focused := CREJECTFOCUS;

  ATestArrowButton := DynTFTArrowButton_CreateWithArrow(1, 240, 462, 40, 16, CRightArrow);
  //SetAllHandlersToDefault(PDynTFTBaseComponent(TPtrRec(ATestArrowButton)));

  {$IFDEF IsDesktop}
    ATestArrowButton^.BaseProps.OnMouseDownUser^ := MoveCarretRight;
  {$ELSE}
    ATestArrowButton^.BaseProps.OnMouseDownUser := @MoveCarretRight;
  {$ENDIF}
  ATestArrowButton^.BaseProps.Focused := CREJECTFOCUS;


  btnCreateKeybord := DynTFTButton_Create(1, 200, 614, 130, 20);
  {$IFDEF IsDesktop}
    btnCreateKeybord^.BaseProps.OnMouseUpUser^ := CreateNewKeyButtons_OnMouseUpUser;
  {$ELSE}
    btnCreateKeybord^.BaseProps.OnMouseUpUser := @CreateNewKeyButtons_OnMouseUpUser;
  {$ENDIF}
  btnCreateKeybord^.Caption := 'Create Keyboard';


  ATestButton := DynTFTButton_Create(1, 580, 20, 100, 20);
  {$IFDEF IsDesktop}
    ATestButton^.BaseProps.OnMouseUpUser^ := DestroyTab_OnMouseUpUser;
  {$ELSE}
    ATestButton^.BaseProps.OnMouseUpUser := @DestroyTab_OnMouseUpUser;
  {$ENDIF}
  ATestButton^.Caption := 'DestroyTab';


  ATestButton := DynTFTButton_Create(1, 580, 40, 100, 20);
  {$IFDEF IsDesktop}
    ATestButton^.BaseProps.OnMouseUpUser^ := DestroyPage_OnMouseUpUser;
  {$ELSE}
    ATestButton^.BaseProps.OnMouseUpUser := @DestroyPage_OnMouseUpUser;
  {$ENDIF}
  ATestButton^.Caption := 'DestroyPage';


  ATestButton := DynTFTButton_Create(1, 580, 60, 100, 20);
  {$IFDEF IsDesktop}
    ATestButton^.BaseProps.OnMouseUpUser^ := DestroyRdBtn_OnMouseUpUser;
  {$ELSE}
    ATestButton^.BaseProps.OnMouseUpUser := @DestroyRdBtn_OnMouseUpUser;
  {$ENDIF}
  ATestButton^.Caption := 'DestroyRdBtn';


  ATestButton := DynTFTButton_Create(1, 580, 80, 100, 20);
  {$IFDEF IsDesktop}
    ATestButton^.BaseProps.OnMouseUpUser^ := DestroyRdGrp_OnMouseUpUser;
  {$ELSE}
    ATestButton^.BaseProps.OnMouseUpUser := @DestroyRdGrp_OnMouseUpUser;
  {$ENDIF}
  ATestButton^.Caption := 'DestroyRdGrp';


  ATestButton := DynTFTButton_Create(1, 580, 110, 100, 20);
  {$IFDEF IsDesktop}
    ATestButton^.BaseProps.OnMouseUpUser^ := SelfDestroy_OnMouseUpUser;
  {$ELSE}
    ATestButton^.BaseProps.OnMouseUpUser := @SelfDestroy_OnMouseUpUser;
  {$ENDIF}
  ATestButton^.Caption := 'Self Destroy';


  AComboBox := DynTFTComboBox_Create(1, 550, 412, 150, 20);
  {$IFDEF IsDesktop}
    AComboBox^.BaseProps.OnMouseUpUser^ := SelfDestroy_OnMouseUpUser;
  {$ELSE}
    AComboBox^.BaseProps.OnMouseUpUser := @SelfDestroy_OnMouseUpUser;
  {$ENDIF}
  AComboBox^.ListBox^.Items^.Count := 12;

  {$IFDEF UseExternalItems}
    {$IFDEF IsDesktop}
      AComboBox^.ListBox^.Items^.OnGetItem^ := ComboBoxItemsGetItemText;
    {$ELSE}
      AComboBox^.ListBox^.Items^.OnGetItem := @ComboBoxItemsGetItemText;
    {$ENDIF}
  {$ELSE}
    AComboBox^.ListBox^.Items^.Strings[0] := 'one';
    AComboBox^.ListBox^.Items^.Strings[1] := 'two';
    AComboBox^.ListBox^.Items^.Strings[2] := 'three';
    AComboBox^.ListBox^.Items^.Strings[3] := 'four';
    AComboBox^.ListBox^.Items^.Strings[4] := 'five';
    AComboBox^.ListBox^.Items^.Strings[5] := 'six';
    AComboBox^.ListBox^.Items^.Strings[6] := 'seven';
    AComboBox^.ListBox^.Items^.Strings[7] := 'eight';
    AComboBox^.ListBox^.Items^.Strings[8] := 'nine';
    AComboBox^.ListBox^.Items^.Strings[9] := 'ten';
    AComboBox^.ListBox^.Items^.Strings[10] := 'eleven';
    AComboBox^.ListBox^.Items^.Strings[11] := 'twelve';
  {$ENDIF}

  ATestButton := DynTFTButton_Create(1, 550, 383, 150, 20);
  {$IFDEF IsDesktop}
    ATestButton^.BaseProps.OnMouseUpUser^ := ToggleCmbEditable_OnMouseUpUser;
  {$ELSE}
    ATestButton^.BaseProps.OnMouseUpUser := @ToggleCmbEditable_OnMouseUpUser;
  {$ENDIF}
  ATestButton^.Caption := 'Toggle editable cmb';
  ATestButton^.Font_Color := CL_TEAL;


  ATrackBar := DynTFTTrackBar_CreateWithDir(1, 338, 648, 150, 24, CTrackBarHorizDir);
  ATrackBar^.Max := 128;
  ATrackBar^.Position := 100;
  DynTFTSetTrackBarTickMode(ATrackBar);
  {$IFDEF IsDesktop}
    ATrackBar^.OnTrackBarChange^ := HorizTrackBar_OnTrackBarChange;
  {$ELSE}
    ATrackBar^.OnTrackBarChange := @HorizTrackBar_OnTrackBarChange;
  {$ENDIF}

  ATrackBar := DynTFTTrackBar_CreateWithDir(1, 640, 480, 24, 150, CTrackBarVertDir);
  DynTFTSetTrackBarTickMode(ATrackBar);
  {$IFDEF IsDesktop}
    ATrackBar^.OnTrackBarChange^ := VertTrackBar_OnTrackBarChange;
  {$ELSE}
    ATrackBar^.OnTrackBarChange := @VertTrackBar_OnTrackBarChange;
  {$ENDIF}
  
  
  ATrackBar := DynTFTTrackBar_CreateWithDir(1, 338, 680, 150, 24, CTrackBarHorizDir);
  DynTFTDisableTrackBar(ATrackBar);

  ATrackBar := DynTFTTrackBar_CreateWithDir(1, 670, 480, 24, 150, CTrackBarVertDir);
  DynTFTDisableTrackBar(ATrackBar);


  AProgressBarH := DynTFTProgressBar_CreateWithDir(1, 338, 712, 150, 20, CProgressBarHorizDir);
  AProgressBarH^.Max := 128;
  AProgressBarH^.Position := 3;

  AProgressBarV := DynTFTProgressBar_CreateWithDir(1, 700, 480, 20, 150, CProgressBarVertDir);
  AProgressBarV^.Position := 6;


  ALabelH := DynTFTLabel_Create(1, 498, 648, 80, 20);
  ALabelH^.Caption := '100';

  ALabelV := DynTFTLabel_Create(1, 640, 648, 80, 20);
  ALabelV^.Caption := '0';

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
