object frmDynTFTSimMain: TfrmDynTFTSimMain
  Left = 311
  Height = 358
  Top = 268
  Width = 927
  Caption = 'DynTFT Simulator'
  ClientHeight = 358
  ClientWidth = 927
  Color = clBtnFace
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  OnClose = FormClose
  OnCreate = FormCreate
  LCLVersion = '6.3'
  object lblAllocatedMemory: TLabel
    Left = 454
    Height = 13
    Top = 8
    Width = 89
    Caption = 'Allocated Memory:'
    ParentColor = False
  end
  object lstLog: TListBox
    Left = 8
    Height = 294
    Top = 56
    Width = 913
    Anchors = [akTop, akLeft, akRight, akBottom]
    Font.CharSet = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    ItemHeight = 0
    OnKeyDown = lstLogKeyDown
    ParentShowHint = False
    ParentFont = False
    ShowHint = True
    TabOrder = 0
  end
  object pnlRunning: TPanel
    Left = 372
    Height = 41
    Top = 8
    Width = 69
    Caption = 'Running'
    Color = clGreen
    ParentColor = False
    TabOrder = 1
  end
  object btnSimulate: TButton
    Left = 151
    Height = 42
    Top = 8
    Width = 89
    Caption = 'Simulate'
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    OnClick = btnSimulateClick
    ParentFont = False
    TabOrder = 2
  end
  object btnStopSimulator: TButton
    Left = 246
    Height = 42
    Top = 8
    Width = 120
    Caption = 'Stop Simulator'
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    OnClick = btnStopSimulatorClick
    ParentFont = False
    TabOrder = 3
  end
  object btnDisplayVirtualScreen: TButton
    Left = 8
    Height = 42
    Top = 8
    Width = 137
    Caption = 'Display Virtual Screen'
    OnClick = btnDisplayVirtualScreenClick
    TabOrder = 4
  end
  object prbAllocatedMemory: TProgressBar
    Left = 454
    Height = 17
    Top = 32
    Width = 257
    Smooth = True
    TabOrder = 5
  end
  object tmrStartup: TTimer
    Enabled = False
    Interval = 10
    OnTimer = tmrStartupTimer
    Left = 768
    Top = 104
  end
  object tmrSimulator: TTimer
    Enabled = False
    Interval = 1
    OnTimer = tmrSimulatorTimer
    Left = 768
    Top = 216
  end
  object tmrBlinkCaret: TTimer
    Enabled = False
    Interval = 500
    OnTimer = tmrBlinkCaretTimer
    Left = 768
    Top = 160
  end
end
