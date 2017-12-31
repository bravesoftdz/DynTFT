object frmDynTFTSimMain: TfrmDynTFTSimMain
  Left = 891
  Top = 309
  Caption = 'DynTFT Simulator'
  ClientHeight = 358
  ClientWidth = 927
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    927
    358)
  PixelsPerInch = 96
  TextHeight = 13
  object lblAllocatedMemory: TLabel
    Left = 454
    Top = 8
    Width = 89
    Height = 13
    Caption = 'Allocated Memory:'
  end
  object lstLog: TListBox
    Left = 8
    Top = 56
    Width = 913
    Height = 294
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    ItemHeight = 16
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnKeyDown = lstLogKeyDown
  end
  object pnlRunning: TPanel
    Left = 372
    Top = 8
    Width = 69
    Height = 41
    Caption = 'Running'
    Color = clGreen
    ParentBackground = False
    TabOrder = 1
  end
  object btnSimulate: TButton
    Left = 151
    Top = 8
    Width = 89
    Height = 42
    Caption = 'Simulate'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = btnSimulateClick
  end
  object btnStopSimulator: TButton
    Left = 246
    Top = 8
    Width = 120
    Height = 42
    Caption = 'Stop Simulator'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    OnClick = btnStopSimulatorClick
  end
  object btnDisplayVirtualScreen: TButton
    Left = 8
    Top = 8
    Width = 137
    Height = 42
    Caption = 'Display Virtual Screen'
    TabOrder = 4
    OnClick = btnDisplayVirtualScreenClick
  end
  object prbAllocatedMemory: TProgressBar
    Left = 454
    Top = 32
    Width = 257
    Height = 17
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
