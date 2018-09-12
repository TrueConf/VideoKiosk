unit HardwareForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, TrueConf_CallXLib_TLB;

const
  sREGKEY_CAMERA = 'Camera';
  sREGKEY_SPEAKER = 'Speaker';
  sREGKEY_MICRPHONE = 'Microphone';
  sERR_UNDEFINED_CALLX = 'Undefined CallX variable';
  sNONE_DEVICE = 'None';

type
  TfrmHardware = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    comboCamera: TComboBox;
    comboSpeaker: TComboBox;
    comboMicrophone: TComboBox;
    btnOk: TButton;
    btnCancel: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    FCallX: TTrueConfCallX;
    FRegKey: string;
  protected
    procedure GetHardwareList;
    procedure Check;
  public
    { Public declarations }
    class function ShowDialog(AOwner: TComponent; const ARegKey: string; ACallX: TTrueConfCallX): boolean;
    class function ApplySettings(AOwner: TComponent; const ARegKey: string; ACallX: TTrueConfCallX): boolean;
  end;

implementation

{$R *.dfm}

uses Registry;

{ TfrmHardware }

class function TfrmHardware.ApplySettings(AOwner: TComponent; const ARegKey: string;
  ACallX: TTrueConfCallX): boolean;
begin
  Result := False;

  with Create(AOwner) do
  try
    FCallX := ACallX;
    FRegKey := ARegKey;

    Check; { check }

    with TRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;
      Result := OpenKey(ARegKey, False);
      if Result then
      begin
        if ValueExists(sREGKEY_CAMERA) then
          FCallX.Camera := ReadString(sREGKEY_CAMERA);
        if ValueExists(sREGKEY_SPEAKER) then
          FCallX.Speaker := ReadString(sREGKEY_SPEAKER);
        if ValueExists(sREGKEY_MICRPHONE) then
          FCallX.Microphone := ReadString(sREGKEY_MICRPHONE);
      end;
    finally
      Free;
    end;
  finally
    Free;
  end;
end;

procedure TfrmHardware.Check;
begin
  if not Assigned(FCallX) then
    raise Exception.Create('sERR_UNDEFINED_CALLX');
end;

class function TfrmHardware.ShowDialog(AOwner: TComponent; const ARegKey: string;
  ACallX: TTrueConfCallX): boolean;
begin
  Result := False;

  with Create(AOwner) do
  try
    FCallX := ACallX;
    FRegKey := ARegKey;

    Check; { check }

    { Read Hardware List}
    GetHardwareList;
    { Show }
    Result := (ShowModal = mrOk);

    if Result then
    begin
      with TRegistry.Create do
      try
        RootKey := HKEY_CURRENT_USER;
        if OpenKey(ARegKey, True) then
        begin
          WriteString(sREGKEY_CAMERA, comboCamera.Text);
          WriteString(sREGKEY_SPEAKER, comboSpeaker.Text);
          WriteString(sREGKEY_MICRPHONE, comboMicrophone.Text);
        end;
      finally
        Free;
      end;
    end;
  finally
    Free;
  end;
end;

procedure TfrmHardware.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmHardware.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ModalResult = mrOk then
  begin
    // Camera
    if comboCamera.ItemIndex <= 0 then
      FCallX.XDeselectCamera
    else
      FCallX.Camera := comboCamera.Text;

    // Speaker
    if comboSpeaker.ItemIndex <= 0 then
      FCallX.XDeselectSpeaker
    else
      FCallX.Speaker := comboSpeaker.Text;

    // Microphone
    if comboMicrophone.ItemIndex <= 0 then
      FCallX.XDeselectMic
    else
      FCallX.Microphone := comboMicrophone.Text;
  end;

  CanClose := True;
end;

procedure TfrmHardware.GetHardwareList;

  procedure _SetComboItemIndex(AHardwareName: string; AComboBox: TComboBox);
  var idxName: integer;
  begin
    idxName := AComboBox.Items.IndexOf(AHardwareName);
    if idxName < 0 then
      AComboBox.ItemIndex := 0
    else
      AComboBox.ItemIndex := idxName;
  end;

begin
  comboCamera.Items.Text := FCallX.XGetCameraList;
  comboCamera.Items.Insert(0, sNONE_DEVICE);
  _SetComboItemIndex(FCallX.Camera, comboCamera);

  comboSpeaker.Items.Text := FCallX.XGetSpeakerList;
  comboSpeaker.Items.Insert(0, sNONE_DEVICE);
  _SetComboItemIndex(FCallX.Speaker, comboSpeaker);

  comboMicrophone.Items.Text := FCallX.XGetMicList;
  comboMicrophone.Items.Insert(0, sNONE_DEVICE);
  _SetComboItemIndex(FCallX.Microphone, comboMicrophone);
end;

end.
