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

program DynTFTSim;

uses
  Forms,
  DynTFTSimMainForm in 'DynTFTSimMainForm.pas' {frmDynTFTSimMain},
  DynTFTArrowButton in 'D:\DynTFT\DynTFTArrowButton.pas',
  DynTFTBaseDrawing in 'D:\DynTFT\DynTFTBaseDrawing.pas',
  DynTFTButton in 'D:\DynTFT\DynTFTButton.pas',
  DynTFTCheckBox in 'D:\DynTFT\DynTFTCheckBox.pas',
  DynTFTComboBox in 'D:\DynTFT\DynTFTComboBox.pas',
  DynTFTConsts in 'D:\DynTFT\DynTFTConsts.pas',
  DynTFTControls in 'D:\DynTFT\DynTFTControls.pas',
  DynTFTEdit in 'D:\DynTFT\DynTFTEdit.pas',
  DynTFTItems in 'D:\DynTFT\DynTFTItems.pas',
  DynTFTKeyButton in 'D:\DynTFT\DynTFTKeyButton.pas',
  DynTFTLabel in 'D:\DynTFT\DynTFTLabel.pas',
  DynTFTListBox in 'D:\DynTFT\DynTFTListBox.pas',
  DynTFTPageControl in 'D:\DynTFT\DynTFTPageControl.pas',
  DynTFTPanel in 'D:\DynTFT\DynTFTPanel.pas',
  DynTFTRadioButton in 'D:\DynTFT\DynTFTRadioButton.pas',
  DynTFTRadioGroup in 'D:\DynTFT\DynTFTRadioGroup.pas',
  DynTFTScrollBar in 'D:\DynTFT\DynTFTScrollBar.pas',
  DynTFTSmallMM in 'D:\DynTFT\DynTFTSmallMM.pas',
  DynTFTTabButton in 'D:\DynTFT\DynTFTTabButton.pas',
  DynTFTTypes in 'D:\DynTFT\DynTFTTypes.pas',
  DynTFTUtils in 'D:\DynTFT\DynTFTUtils.pas',
  DynTFTVirtualKeyboard in 'D:\DynTFT\DynTFTVirtualKeyboard.pas',
  MemManager in 'D:\DynTFT\MemManager.pas',
  TFT in 'D:\DynTFT\TFT.pas',
  DynTFTSimScreenForm in 'DynTFTSimScreenForm.pas' {frmDynTFTSimScreen},
  DynTFTGUI in '..\GUI\DynTFTGUI.pas',
  DynTFTGUIObjects in '..\GUI\DynTFTGUIObjects.pas',
  DynTFTHandlers in '..\GUI\DynTFTHandlers.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmDynTFTSimMain, frmDynTFTSimMain);
  Application.CreateForm(TfrmDynTFTSimScreen, frmDynTFTSimScreen);
  Application.Run;
end.
