object frmDynTFTSimScreen: TfrmDynTFTSimScreen
  Left = 0
  Height = 984
  Top = 32
  Width = 798
  Caption = 'DynTFT SimScreen'
  ClientHeight = 984
  ClientWidth = 798
  Color = clBtnFace
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  LCLVersion = '5.9'
  object imgScreen: TImage
    Left = 8
    Height = 929
    Top = 47
    Width = 782
    Anchors = [akTop, akLeft, akRight, akBottom]
    OnMouseDown = imgScreenMouseDown
    OnMouseMove = imgScreenMouseMove
    OnMouseUp = imgScreenMouseUp
  end
  object lblScreenWidth: TLabel
    Left = 160
    Height = 13
    Top = 2
    Width = 68
    Caption = 'Screen Width:'
    ParentColor = False
  end
  object lblScreenHeight: TLabel
    Left = 486
    Height = 13
    Top = 2
    Width = 71
    Caption = 'Screen Height:'
    ParentColor = False
  end
  object lblWidth: TLabel
    Left = 176
    Height = 41
    Top = 27
    Width = 10
    AutoSize = False
    Color = clRed
    ParentColor = False
    Transparent = False
    Visible = False
  end
  object lblHeight: TLabel
    Left = 547
    Height = 14
    Top = 27
    Width = 52
    AutoSize = False
    Color = clRed
    ParentColor = False
    Transparent = False
    Visible = False
  end
  object pnlCoords: TPanel
    Left = 8
    Height = 27
    Top = 7
    Width = 137
    Caption = 'pnlCoords'
    TabOrder = 0
  end
  object trbScreenWidth: TTrackBar
    Left = 272
    Height = 26
    Top = 8
    Width = 177
    Max = 1024
    OnChange = trbScreenWidthChange
    Position = 0
    TabOrder = 1
  end
  object trbScreenHeight: TTrackBar
    Left = 616
    Height = 26
    Top = 8
    Width = 177
    Max = 1024
    OnChange = trbScreenHeightChange
    Position = 0
    TabOrder = 2
  end
  object chkShowWidthLine: TCheckBox
    Left = 160
    Height = 19
    Top = 21
    Width = 99
    Caption = 'Show Width Line'
    Checked = True
    OnClick = chkShowWidthLineClick
    State = cbChecked
    TabOrder = 3
  end
  object chkShowHeightLine: TCheckBox
    Left = 486
    Height = 19
    Top = 21
    Width = 102
    Caption = 'Show Height Line'
    Checked = True
    OnClick = chkShowHeightLineClick
    State = cbChecked
    TabOrder = 4
  end
  object tmrStartup: TTimer
    Enabled = False
    Interval = 10
    OnTimer = tmrStartupTimer
    left = 632
    top = 160
  end
end
