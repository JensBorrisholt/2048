object FormMain: TFormMain
  Left = 303
  Top = 178
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderStyle = bsSizeToolWin
  Caption = '2048'
  ClientHeight = 741
  ClientWidth = 614
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object GameBoardGrid: TStringGrid
    Left = 0
    Top = 89
    Width = 614
    Height = 613
    Align = alClient
    BorderStyle = bsNone
    ColCount = 4
    Ctl3D = False
    DefaultColWidth = 50
    DefaultRowHeight = 50
    Enabled = False
    FixedCols = 0
    RowCount = 4
    FixedRows = 0
    GridLineWidth = 5
    ParentCtl3D = False
    ScrollBars = ssNone
    TabOrder = 0
    OnDrawCell = GameBoardGridDrawCell
    ExplicitLeft = 8
    ExplicitWidth = 630
    ExplicitHeight = 652
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 614
    Height = 89
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = -6
    ExplicitWidth = 613
    DesignSize = (
      614
      89)
    object Label1: TLabel
      Left = 5
      Top = 1
      Width = 124
      Height = 58
      Caption = '2048'
      Font.Charset = ANSI_CHARSET
      Font.Color = 10841658
      Font.Height = -48
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Left = 5
      Top = 61
      Width = 274
      Height = 16
      Caption = 'Join the numbers and get to the 2048 tile!'
      Font.Charset = ANSI_CHARSET
      Font.Color = 10841658
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Shape1: TShape
      Left = 429
      Top = 9
      Width = 84
      Height = 65
      Anchors = [akTop, akRight]
      Brush.Color = 10849396
      Shape = stRoundRect
    end
    object Shape2: TShape
      Left = 520
      Top = 9
      Width = 84
      Height = 65
      Anchors = [akTop, akRight]
      Brush.Color = 10849396
      Shape = stRoundRect
    end
    object Label5: TLabel
      Left = 448
      Top = 16
      Width = 49
      Height = 24
      Anchors = [akTop, akRight]
      Caption = 'Score'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWhite
      Font.Height = -20
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label6: TLabel
      Left = 541
      Top = 16
      Width = 39
      Height = 24
      Anchors = [akTop, akRight]
      Caption = 'Best'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWhite
      Font.Height = -20
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object LabelScore: TLabel
      Left = 429
      Top = 41
      Width = 83
      Height = 24
      Alignment = taCenter
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = '0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWhite
      Font.Height = -20
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object LabelBest: TLabel
      Left = 522
      Top = 41
      Width = 81
      Height = 24
      Alignment = taCenter
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = '0'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWhite
      Font.Height = -20
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 702
    Width = 614
    Height = 39
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitWidth = 594
    DesignSize = (
      614
      39)
    object Label3: TLabel
      Left = 5
      Top = 6
      Width = 94
      Height = 16
      Caption = 'HOW TO PLAY:'
      Font.Charset = ANSI_CHARSET
      Font.Color = 10841658
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label4: TLabel
      Left = 5
      Top = 20
      Width = 590
      Height = 15
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoSize = False
      Caption = 
        'Use your arrow keys to move the tiles. When two tiles with the s' +
        'ame number touch, they merge into one!'
      Font.Charset = ANSI_CHARSET
      Font.Color = 10841658
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      WordWrap = True
      ExplicitWidth = 570
    end
  end
  object ActionList1: TActionList
    OnUpdate = ActionList1Update
    Left = 192
    Top = 216
    object actExit: TAction
      Category = 'Application control'
      Caption = 'Exit'
      ShortCut = 27
      OnExecute = actExitExecute
    end
    object actRestart: TAction
      Category = 'Application control'
      Caption = 'Restart'
      ShortCut = 113
      OnExecute = actRestartExecute
    end
    object actLeft: TAction
      Category = 'Game control'
      Caption = 'Left'
      ShortCut = 37
      OnExecute = actLeftExecute
    end
    object actRight: TAction
      Tag = 1
      Category = 'Game control'
      Caption = 'Right'
      ShortCut = 39
      OnExecute = actLeftExecute
    end
    object actUp: TAction
      Tag = 2
      Category = 'Game control'
      Caption = 'Up'
      ShortCut = 38
      OnExecute = actLeftExecute
    end
    object actDown: TAction
      Tag = 3
      Category = 'Game control'
      Caption = 'down'
      ShortCut = 40
      OnExecute = actLeftExecute
    end
  end
end
