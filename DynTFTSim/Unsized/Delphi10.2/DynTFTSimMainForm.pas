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

unit DynTFTSimMainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls;

type
  TfrmDynTFTSimMain = class(TForm)
    lblAllocatedMemory: TLabel;
    lstLog: TListBox;
    pnlRunning: TPanel;
    btnSimulate: TButton;
    btnStopSimulator: TButton;
    btnDisplayVirtualScreen: TButton;
    prbAllocatedMemory: TProgressBar;
    tmrStartup: TTimer;
    tmrSimulator: TTimer;
    tmrBlinkCaret: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure lstLogKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnDisplayVirtualScreenClick(Sender: TObject);
    procedure btnSimulateClick(Sender: TObject);
    procedure btnStopSimulatorClick(Sender: TObject);
    procedure tmrStartupTimer(Sender: TObject);
    procedure tmrBlinkCaretTimer(Sender: TObject);
    procedure tmrSimulatorTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure LoadSettingsFromIni;
    procedure SaveSettingsToIni;
  public
    { Public declarations }
  end;

var
  frmDynTFTSimMain: TfrmDynTFTSimMain;

implementation

{$R *.dfm}

uses
  {$IFDEF UseSmallMM}
    DynTFTSmallMM,
  {$ELSE}
    MemManager,
  {$ENDIF}

  TFT, DynTFTGUI, DynTFTControls, DynTFTBaseDrawing, DynTFTUtils,
  IniFiles, DynTFTSimScreenForm, ClipBrd;


{TfrmTestDynTFTMain}


procedure TfrmDynTFTSimMain.LoadSettingsFromIni;
var
  Ini: TMemIniFile;
begin
  Ini := TMemIniFile.Create(ExtractFilePath(ParamStr(0)) + Application.Title + '.ini');
  try
    Left := Ini.ReadInteger('Window', 'Left', Left);
    Top := Ini.ReadInteger('Window', 'Top', Top);
    Width := Ini.ReadInteger('Window', 'Width', Width);
    Height := Ini.ReadInteger('Window', 'Height', Height);
  finally
    Ini.Free;
  end;
end;


procedure TfrmDynTFTSimMain.SaveSettingsToIni;
var
  Ini: TMemIniFile;
begin
  Ini := TMemIniFile.Create(ExtractFilePath(ParamStr(0)) + Application.Title + '.ini');
  try
    Ini.WriteInteger('Window', 'Left', Left);
    Ini.WriteInteger('Window', 'Top', Top);
    Ini.WriteInteger('Window', 'Width', Width);
    Ini.WriteInteger('Window', 'Height', Height);
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;


procedure TfrmDynTFTSimMain.lstLogKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = Ord('C') then
    if ssCtrl in Shift then
    begin
      if ssShift in Shift then
        Clipboard.AsText := lstLog.Items.Text
      else
        if lstLog.ItemIndex > -1 then
          Clipboard.AsText := lstLog.Items.Strings[lstLog.ItemIndex];
    end;
end;


procedure TfrmDynTFTSimMain.tmrBlinkCaretTimer(Sender: TObject);
begin
  DynTFTGBlinkingCaretStatus := not DynTFTGBlinkingCaretStatus;
end;


procedure TfrmDynTFTSimMain.tmrSimulatorTimer(Sender: TObject);
var
  TotalFreeMemSize: Integer;
begin
  try
    DynTFT_GUI_LoopIteration;

    TotalFreeMemSize := {$IFDEF UseSmallMM} MaxMM {$ELSE} HEAP_SIZE {$ENDIF} - MM_TotalFreeMemSize;
    if prbAllocatedMemory.Position <> TotalFreeMemSize then
    begin
      prbAllocatedMemory.Position := TotalFreeMemSize;
      lblAllocatedMemory.Caption := 'Allocated Memory: ' + IntToStr(TotalFreeMemSize) + ' B    (' + IntToStr(TotalFreeMemSize shr 10) + ' KB)';
    end;
  except
    on E: Exception do
    begin
      DynTFT_DebugConsole('Exception while executing DynTFT_GUI_LoopIteration: ' + E.Message);
      lstLog.Color := $E0E0FF;
    end;
  end;
end;


procedure TfrmDynTFTSimMain.tmrStartupTimer(Sender: TObject);
begin
  tmrStartup.Enabled := False;
  UseTFTTrueColor := True;
  prbAllocatedMemory.Max := {$IFDEF UseSmallMM} MaxMM {$ELSE} HEAP_SIZE {$ENDIF};

  LoadSettingsFromIni;
  DynTFT_AssignDebugConsole(lstLog);
end;


procedure TfrmDynTFTSimMain.btnDisplayVirtualScreenClick(Sender: TObject);
begin
  frmDynTFTSimScreen.Show;
end;


procedure TfrmDynTFTSimMain.btnSimulateClick(Sender: TObject);
begin
  pnlRunning.Color := clLime;
  pnlRunning.Tag := 1; //Set the color to whatever you want, but leave this tag alone!

  btnSimulate.Enabled := False;
  lstLog.Clear;
  MM_Init;
  tmrSimulator.Enabled := True;

  GCanvas.Pen.Color := $0088FF;
  GCanvas.Brush.Color := clSilver;
  GCanvas.Rectangle(0, 0, frmDynTFTSimScreen.imgScreen.Width, frmDynTFTSimScreen.imgScreen.Height);

  DynTFT_Init(frmDynTFTSimScreen.trbScreenWidth.Position, frmDynTFTSimScreen.trbScreenHeight.Position);

  try
    DynTFT_GUI_Start;
    tmrBlinkCaret.Enabled := True;
    lstLog.Color := clWindow;
  except
    on E: Exception do
    begin
      DynTFT_DebugConsole('Exception in DynTFT_GUI_Start: ' + E.Message);
      lstLog.Color := $E0E0FF;
    end;
  end;
end;


procedure TfrmDynTFTSimMain.btnStopSimulatorClick(Sender: TObject);
begin
  tmrSimulator.Enabled := False;

  if pnlRunning.Tag = 1 then
  begin
    pnlRunning.Tag := 0;
    try
      DynTFTFreeComponentTypeRegistration;
    except
      on E: Exception do
        DynTFT_DebugConsole('Exception in FreeComponentTypeRegistration: ' + E.Message);
    end;
  end;

  pnlRunning.Color := clGreen;
  btnSimulate.Enabled := True;
  tmrBlinkCaret.Enabled := False;
end;


procedure TfrmDynTFTSimMain.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  try
    btnStopSimulator.Click;  //some cleanup before closing
  except
  end;

  try
    SaveSettingsToIni;
  except
  end;
end;


procedure TfrmDynTFTSimMain.FormCreate(Sender: TObject);
begin
  tmrStartup.Enabled := True;
  lstLog.Hint := 'Press Ctrl-C to copy selected line to clipboard.' + #13#10 +
                 'Press Ctrl-Shift-C to copy the entire log.';
end;

end.
