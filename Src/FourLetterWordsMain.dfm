object frm4LetterWordsMain: Tfrm4LetterWordsMain
  Left = 932
  Top = 237
  Width = 387
  Height = 676
  Caption = 'Four Letter Words'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    371
    617)
  PixelsPerInch = 96
  TextHeight = 13
  object lblStatus: TLabel
    Left = 16
    Top = 591
    Width = 40
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'lblStatus'
  end
  object lblResults: TLabel
    Left = 15
    Top = 556
    Width = 345
    Height = 28
    Anchors = [akLeft, akRight, akBottom]
    AutoSize = False
    Caption = 'lblResults'
    WordWrap = True
  end
  object leSrcWord: TLabeledEdit
    Left = 16
    Top = 24
    Width = 57
    Height = 21
    EditLabel.Width = 45
    EditLabel.Height = 13
    EditLabel.Caption = 'Src Word'
    TabOrder = 0
    OnChange = leSrcWordChange
  end
  object leTarget: TLabeledEdit
    Left = 16
    Top = 531
    Width = 57
    Height = 21
    Anchors = [akLeft, akBottom]
    EditLabel.Width = 60
    EditLabel.Height = 13
    EditLabel.Caption = 'Target Word'
    TabOrder = 1
    Text = 'done'
    OnChange = leTargetChange
  end
  object StringGrid1: TStringGrid
    Left = 16
    Top = 56
    Width = 334
    Height = 457
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 3
    RowCount = 1
    FixedRows = 0
    TabOrder = 2
  end
  object MainMenu1: TMainMenu
    Left = 328
    Top = 8
    object File1: TMenuItem
      Caption = '&File'
      object New1: TMenuItem
        Caption = '&New'
      end
      object Open1: TMenuItem
        Caption = '&Open...'
      end
      object ReloadWords1: TMenuItem
        Caption = 'Reload Words'
        ShortCut = 16466
        OnClick = ReloadWords1Click
      end
      object Save1: TMenuItem
        Caption = '&Save'
      end
      object SaveAs1: TMenuItem
        Caption = 'Save &As...'
        OnClick = SaveAs1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Print1: TMenuItem
        Caption = '&Print...'
      end
      object PrintSetup1: TMenuItem
        Caption = 'P&rint Setup...'
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'E&xit'
        OnClick = Exit1Click
      end
    end
    object Edit1: TMenuItem
      Caption = '&Edit'
      object Undo1: TMenuItem
        Caption = '&Undo'
        ShortCut = 16474
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object Cut1: TMenuItem
        Caption = 'Cu&t'
        ShortCut = 16472
      end
      object Copy1: TMenuItem
        Caption = '&Copy'
        ShortCut = 16451
      end
      object Paste1: TMenuItem
        Caption = '&Paste'
        ShortCut = 16470
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object FindSimilarWords1: TMenuItem
        Caption = 'Find Similar &Words'
        ShortCut = 16471
        OnClick = FindSimilarWords1Click
      end
      object FindPathtoTarget1: TMenuItem
        Caption = 'Find &Path to Target'
        ShortCut = 16464
        OnClick = FindPathtoTarget1Click
      end
    end
    object Functions1: TMenuItem
      Caption = 'Functions'
      object ExctractFourLettersWordstoFile1: TMenuItem
        Caption = 'Extract Subset Words to File...'
        OnClick = ExctractFourLettersWordstoFile1Click
      end
      object ReCreateWordList1: TMenuItem
        Caption = 'Re-Create Word List'
        OnClick = ReCreateWordList1Click
      end
      object ListofWordswithnoSimilarWords1: TMenuItem
        Caption = 'List of Words with no Similar Words...'
        OnClick = ListofWordswithnoSimilarWords1Click
      end
      object ListofWordsbySimilarity1: TMenuItem
        Caption = 'List of Words by Similarity...'
        OnClick = ListofWordsbySimilarity1Click
      end
    end
  end
end
