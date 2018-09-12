object frmHardware: TfrmHardware
  Left = 0
  Top = 0
  BorderStyle = bsSizeToolWin
  Caption = 'Hardware'
  ClientHeight = 220
  ClientWidth = 532
  Color = clBtnFace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 550
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  DesignSize = (
    532
    220)
  PixelsPerInch = 120
  TextHeight = 16
  object Label1: TLabel
    Left = 24
    Top = 16
    Width = 153
    Height = 16
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Camera'
    FocusControl = comboCamera
  end
  object Label2: TLabel
    Left = 24
    Top = 48
    Width = 153
    Height = 16
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Speaker'
    FocusControl = comboSpeaker
  end
  object Label3: TLabel
    Left = 24
    Top = 80
    Width = 153
    Height = 16
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Microphone'
    FocusControl = comboMicrophone
  end
  object comboCamera: TComboBox
    Left = 208
    Top = 13
    Width = 310
    Height = 24
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object comboSpeaker: TComboBox
    Left = 208
    Top = 45
    Width = 309
    Height = 24
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
  end
  object comboMicrophone: TComboBox
    Left = 208
    Top = 77
    Width = 309
    Height = 24
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
  end
  object btnOk: TButton
    Left = 208
    Top = 175
    Width = 153
    Height = 33
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 364
    Top = 175
    Width = 153
    Height = 33
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
end
