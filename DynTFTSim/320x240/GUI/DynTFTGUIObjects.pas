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

unit DynTFTGUIObjects;

{$IFNDEF IsMCU}
  {$DEFINE IsDelphi}
{$ENDIF}

{$IFDEF IsDelphi}
interface
{$ENDIF}

uses
  DynTFTButton, DynTFTArrowButton, DynTFTPanel, DynTFTCheckBox, DynTFTScrollBar,
  DynTFTItems, DynTFTListBox, DynTFTLabel, DynTFTRadioButton, DynTFTRadioGroup,
  DynTFTTabButton, DynTFTPageControl, DynTFTEdit, DynTFTVirtualKeyboard,
  DynTFTComboBox, DynTFTTrackBar, DynTFTProgressBar
  {$I DynTFTGUIAdditionalUnits.inc}
  ;


var
  tabbtnTab1: PDynTFTTabButton;
  tabbtnTab2: PDynTFTTabButton;
  tabbtnTab3: PDynTFTTabButton;
  tabbtnTab4: PDynTFTTabButton;
  tabbtnTab5: PDynTFTTabButton;
  tabbtnTab6: PDynTFTTabButton;
  PageControl1: PDynTFTPageControl;
  btn1: PDynTFTButton;
  Arrow1: PDynTFTArrowButton;
  Panel1: PDynTFTPanel;
  Arrow2: PDynTFTArrowButton;
  Arrow3: PDynTFTArrowButton;
  Arrow4: PDynTFTArrowButton;
  btn3: PDynTFTButton;
  Arrow5: PDynTFTArrowButton;
  Arrow6: PDynTFTArrowButton;
  Arrow7: PDynTFTArrowButton;
  Arrow8: PDynTFTArrowButton;
  btn2: PDynTFTButton;
  btn4: PDynTFTButton;
  ScrollBar1: PDynTFTScrollBar;
  ScrollBar2: PDynTFTScrollBar;
  CheckBox1: PDynTFTCheckBox;
  CheckBox2: PDynTFTCheckBox;
  CheckBox3: PDynTFTCheckBox;
  ListBox1: PDynTFTListBox;
  ListBox3: PDynTFTListBox;
  lbl1: PDynTFTLabel;
  lbl2: PDynTFTLabel;
  radbtnfirst: PDynTFTRadioButton;
  radbtnsecond: PDynTFTRadioButton;
  radbtnthird: PDynTFTRadioButton;
  radbtnfourth: PDynTFTRadioButton;
  radbtnfifth: PDynTFTRadioButton;
  radbtnsixth: PDynTFTRadioButton;
  radbtnseventh: PDynTFTRadioButton;
  radbtneighth: PDynTFTRadioButton;
  rdgrpTest: PDynTFTRadioGroup;
  lbl3: PDynTFTLabel;
  lbl4: PDynTFTLabel;
  radbtnone: PDynTFTRadioButton;
  radbtntwo: PDynTFTRadioButton;
  radbtnthree: PDynTFTRadioButton;
  radbtnfour: PDynTFTRadioButton;
  radbtnfive: PDynTFTRadioButton;
  radbtnsix: PDynTFTRadioButton;
  radbtnseven: PDynTFTRadioButton;
  radbtneight: PDynTFTRadioButton;
  rdgrpTest1: PDynTFTRadioGroup;
  Edit1: PDynTFTEdit;
  vkTest: PDynTFTVirtualKeyboard;
  ComboBox1: PDynTFTComboBox;
  ComboBox2: PDynTFTComboBox;
  Label4: PDynTFTLabel;
  Label5: PDynTFTLabel;
  ListBox2: PDynTFTListBox;
  ListBox4: PDynTFTListBox;
  TrackBar1: PDynTFTTrackBar;
  ProgressBar1: PDynTFTProgressBar;
  TrackBar2: PDynTFTTrackBar;
  ProgressBar2: PDynTFTProgressBar;
  btnShowMessageBox: PDynTFTButton;

implementation

end.
