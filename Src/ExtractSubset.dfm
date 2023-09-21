object frmExtractSubset: TfrmExtractSubset
  Left = 784
  Top = 393
  Width = 783
  Height = 455
  Caption = 'Extract Subset of Words from File'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    767
    417)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 112
    Width = 127
    Height = 13
    Caption = 'Length of Words to Extract'
  end
  object lblStatus: TLabel
    Left = 24
    Top = 392
    Width = 40
    Height = 13
    Caption = 'lblStatus'
  end
  object leInFileName: TLabeledEdit
    Left = 16
    Top = 24
    Width = 633
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 53
    EditLabel.Height = 13
    EditLabel.Caption = 'Source File'
    TabOrder = 0
    Text = 'C:\D7\Projects\Four Letter Words\wordsEn.txt'
  end
  object leOutFileName: TLabeledEdit
    Left = 16
    Top = 72
    Width = 633
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    EditLabel.Width = 72
    EditLabel.Height = 13
    EditLabel.Caption = 'Destination File'
    TabOrder = 1
    Text = 'C:\D7\Projects\Four Letter Words\words4.txt'
  end
  object btnCancel: TButton
    Left = 672
    Top = 376
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnOK: TButton
    Left = 584
    Top = 376
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
    OnClick = btnOKClick
  end
  object ovcWordLen: TOvcNumericField
    Left = 16
    Top = 128
    Width = 33
    Height = 21
    Cursor = crIBeam
    DataType = nftByte
    CaretOvr.Shape = csBlock
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = []
    PictureMask = '999'
    TabOrder = 4
    RangeHigh = {FF000000000000000000}
    RangeLow = {00000000000000000000}
  end
  object OvcSpinner1: TOvcSpinner
    Left = 48
    Top = 128
    Width = 16
    Height = 25
    AutoRepeat = True
    Delta = 1.000000000000000000
    FocusedControl = ovcWordLen
  end
end
