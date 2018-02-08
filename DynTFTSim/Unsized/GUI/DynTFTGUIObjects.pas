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
  {$DEFINE IsDesktop}
{$ENDIF}

{$IFDEF IsDesktop}
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
  ATestButton, ShapesButton, SelfDestroyButton, btnCreateKeybord: PDynTFTButton;
  ATestArrowButton: PDynTFTArrowButton;
  ATestCheckBox: PDynTFTCheckBox;
  ATestPanel: PDynTFTPanel;
  ATestScrollBar: PDynTFTScrollBar;
  ATestListBox: PDynTFTListBox;
  ATestLabel: PDynTFTLabel;
  ATestRadioButton1, ATestRadioButton2, ATestRadioButton3: PDynTFTRadioButton;
  ATestRadioGroup: PDynTFTRadioGroup;
  ATabButton1, ATabButton2, ATabButton3: PDynTFTTabButton;
  ATestPageControl: PDynTFTPageControl;
  ATestEdit: PDynTFTEdit;
  AVirtualKeyboard: PDynTFTVirtualKeyboard;
  AComboBox: PDynTFTComboBox;
  ATrackBar: PDynTFTTrackBar;
  AProgressBarH, AProgressBarV: PDynTFTProgressBar;
  ALabelH, ALabelV: PDynTFTLabel;

implementation

end.
