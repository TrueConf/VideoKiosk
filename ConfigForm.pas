unit ConfigForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtDlgs, KioskMainForm,
  Vcl.ComCtrls, Vcl.ExtCtrls, System.Actions, Vcl.ActnList, TrueConf_CallXLib_TLB,
  Vcl.Imaging.pngimage, Vcl.Samples.Spin;

type
  TfrmConfigurator = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    btnHardware: TButton;
    OpenPictureDialog: TOpenPictureDialog;
    OpenDialog: TOpenDialog;
    PageControl: TPageControl;
    Call: TTabSheet;
    rgCallTo: TRadioGroup;
    GridPanel1: TGridPanel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Label5: TLabel;
    edCallUserID: TEdit;
    GroupBox2: TGroupBox;
    edCallUserIDList: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    TabSheet2: TTabSheet;
    Label8: TLabel;
    edServer: TEdit;
    Label9: TLabel;
    edUser: TEdit;
    Label10: TLabel;
    edPassword: TEdit;
    Label11: TLabel;
    edConfirmPassword: TEdit;
    ActionList: TActionList;
    actHardware: TAction;
    Panel4: TPanel;
    chbNotifyManager: TCheckBox;
    edManager: TEdit;
    imgTest: TImage;
    TabSheet3: TTabSheet;
    chbShowChatMessages: TCheckBox;
    Label13: TLabel;
    edChatDuration: TSpinEdit;
    Label14: TLabel;
    chbWriteLog: TCheckBox;
    btnShowLogFile: TButton;
    OpenVideoDialog: TOpenDialog;
    Label17: TLabel;
    Panel5: TPanel;
    Image1: TImage;
    Label18: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure actOKExecute(Sender: TObject);
    procedure actHardwareExecute(Sender: TObject);
    procedure actHardwareUpdate(Sender: TObject);
    procedure chbNotifyManagerClick(Sender: TObject);
    procedure btnShowLogFileClick(Sender: TObject);
  private
    { Private declarations }
    FKioskConfig: TKioskConfig;
    FCallX: TTrueConfCallX;
  protected
    function Check: boolean;
    procedure SetCallTo(ACallToType: TCallToType; ACallTo: string);
    function GetCallTo(ACallToType: TCallToType): string;
    procedure Save;
    function PictureFileName(const APreviosFile: string): string;
  public
    { Public declarations }
    class procedure SaveSettings(AKioskConfig: TKioskConfig);
    class procedure LoadSettings(var AKioskConfig: TKioskConfig);
  public
    property CallX: TTrueConfCallX read FCallX write FCallX;
  end;

var
  frmConfigurator: TfrmConfigurator;

implementation

uses Registry, rcstrings, HardwareForm, LogUnit, ShellApi;

{$R *.dfm}

const
  sREG_SHOW_CONTENT = 'Show content';
  sREG_LOGO_IMAGE = 'Logo image';
  sREG_CALL_IMAGE = 'Call image';
  sREG_CALLING_IMAGE = 'Calling image';
  sREG_REJECT_IMAGE = 'Reject image';
  sREG_CONNECTING_IMAGE = 'Connecting image';
  sREG_VIDEO = 'Promo video';
  sREG_SERVER = 'Server';
  sREG_USER = 'User';
  sREG_PASSWORD = 'Password';
  sREG_CALL_TO_TYPE = 'Call to type';
  sREG_CALL_TO = 'Call to';
  sREG_FORCED_PORTRAIT = 'Forced Portrait';
  sREG_NOTIFY_MANAGER = 'Notify manager';
  sREG_MANAGER = 'Manager';
  sREG_SHOWCHAT_MESSAGE = 'Show chat message';
  sREG_CHAT_MESSAGE_DURATION = 'Chat message duration';
  sREG_BACKGROUND_IMAGE = 'Background image';
  sREG_WRITE_LOG = 'Write log';

procedure TfrmConfigurator.actHardwareExecute(Sender: TObject);
begin
  if TfrmHardware.ShowDialog(self, REG_KEY, FCallX) then
  begin

  end;
end;

procedure TfrmConfigurator.actHardwareUpdate(Sender: TObject);
begin
  actHardware.Enabled := Assigned(FCallX);
  btnShowLogFile.Visible := Assigned(FCallX);
end;

procedure TfrmConfigurator.actOKExecute(Sender: TObject);
begin
  if not Check then
    Exit;

  { save to reg }
  Save;
  { close }
  ModalResult := mrOk;
  //Close;
end;

procedure TfrmConfigurator.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmConfigurator.btnShowLogFileClick(Sender: TObject);
var pcPath: PChar;
begin
  pcPath := PChar(GetLogPath);
  ShellExecute(Handle, nil, pcPath, nil, nil, SW_SHOWNORMAL);
end;

procedure TfrmConfigurator.chbNotifyManagerClick(Sender: TObject);
begin
  edManager.Enabled := chbNotifyManager.Checked;
end;

function TfrmConfigurator.Check: boolean;
begin
  Result := False;
  if Trim(edUser.Text) = '' then
  begin
    MessageDlg(sERROR_EMPTY_USER, mtError, [mbOK], 0);
    PageControl.ActivePageIndex := 0;
    if edUser.CanFocus then
      edUser.SetFocus;

    Exit;
  end
  else if edPassword.Text <> edConfirmPassword.Text then
  begin
    MessageDlg(sERROR_PASSWORDS_DO_NOT_MATCH, mtError, [mbOK], 0);
    PageControl.ActivePageIndex := 0;
    if edPassword.CanFocus then
      edPassword.SetFocus;

    Exit;
  end
  else if Trim(edPassword.Text) = '' then
  begin
    MessageDlg(sERROR_EMPTY_PASSWORD, mtError, [mbOK], 0);
    PageControl.ActivePageIndex := 0;
    if edPassword.CanFocus then
      edPassword.SetFocus;

    Exit;
  end
  { Tab: Call }
  else if (rgCallTo.ItemIndex = Ord(ctUser)) and (Trim(edCallUserID.Text) = '') then
  begin
    MessageDlg(sERROR_EMPTY_CALL_USER_ID, mtError, [mbOK], 0);
    PageControl.ActivePageIndex := 2;
    if edCallUserID.CanFocus then
      edCallUserID.SetFocus;

    Exit;
  end
  { Tab: Call }
  else if (rgCallTo.ItemIndex = Ord(ctUsersList)) and (Trim(edCallUserIDList.Text) = '') then
  begin
    MessageDlg(sERROR_EMPTY_CALL_USER_ID, mtError, [mbOK], 0);
    PageControl.ActivePageIndex := 2;
    if edCallUserIDList.CanFocus then
      edCallUserIDList.SetFocus;

    Exit;
  end;

  Result := True;
end;

procedure TfrmConfigurator.FormCreate(Sender: TObject);
begin
  Caption := Application.Title;

  PageControl.ActivePageIndex := 0;

  LoadSettings(FKioskConfig);

  edServer.Text := FKioskConfig.sServer;
  edUser.Text := FKioskConfig.sUser;
  edPassword.Text := FKioskConfig.sPassword;
  edConfirmPassword.Text := FKioskConfig.sPassword;

  rgCallTo.ItemIndex := Ord(FKioskConfig.iCallToType);
  SetCallTo(FKioskConfig.iCallToType, FKioskConfig.sCallTo);

  chbNotifyManager.Checked := FKioskConfig.bNotifyManager;
  edManager.Text := FKioskConfig.sManager;

  chbShowChatMessages.Checked := FKioskConfig.bShowChat;
  edChatDuration.Value := FKioskConfig.iChatDuration;

  chbWriteLog.Checked := FKioskConfig.bWriteLog;
end;

function TfrmConfigurator.GetCallTo(ACallToType: TCallToType): string;
begin
  Result := '';
  case ACallToType of
    ctUser: Result := edCallUserID.Text;
    ctUsersList: Result := edCallUserIDList.Text;
    ctAB: ;
  end;
end;

class procedure TfrmConfigurator.LoadSettings(var AKioskConfig: TKioskConfig);
begin
  // default
  AKioskConfig.iChatDuration := iDEFAULT_CHAT_MESSAGE_DURATION;

  with TRegistry.Create do
  try
    RootKey := HKEY_CURRENT_USER;
    if OpenKey(REG_KEY, False) then
    begin
        AKioskConfig.sServer := ReadString(sREG_SERVER);
      if ValueExists(sREG_USER) then
        AKioskConfig.sUser := ReadString(sREG_USER);
      if ValueExists(sREG_PASSWORD) then
        AKioskConfig.sPassword := ReadString(sREG_PASSWORD);

      if ValueExists(sREG_CALL_TO_TYPE) then
        AKioskConfig.iCallToType := TCallToType(ReadInteger(sREG_CALL_TO_TYPE))
      else
        AKioskConfig.iCallToType := ctUser;

      if ValueExists(sREG_CALL_TO) then
        AKioskConfig.sCallTo := ReadString(sREG_CALL_TO);

      if ValueExists(sREG_FORCED_PORTRAIT) then
       AKioskConfig.bForcedPortrait := ReadBool(sREG_FORCED_PORTRAIT);

      if ValueExists(sREG_NOTIFY_MANAGER) then
        AKioskConfig.bNotifyManager := ReadBool(sREG_NOTIFY_MANAGER);
      if ValueExists(sREG_MANAGER) then
        AKioskConfig.sManager := ReadString(sREG_MANAGER);

      if ValueExists(sREG_SHOWCHAT_MESSAGE) then
        AKioskConfig.bShowChat := ReadBool(sREG_SHOWCHAT_MESSAGE);

      if ValueExists(sREG_CHAT_MESSAGE_DURATION) then
        AKioskConfig.iChatDuration := ReadInteger(sREG_CHAT_MESSAGE_DURATION);

      if ValueExists(sREG_WRITE_LOG) then
        AKioskConfig.bWriteLog := ReadBool(sREG_WRITE_LOG);
    end;
  finally
    Free;
  end;
end;

function TfrmConfigurator.PictureFileName(const APreviosFile: string): string;
begin
  Result := APreviosFile;
  OpenPictureDialog.InitialDir := ExtractFileDir(APreviosFile);
  if OpenPictureDialog.Execute(self.Handle) then
  try
    imgTest.Picture.LoadFromFile(OpenPictureDialog.FileName);
    Result := OpenPictureDialog.FileName;
  except
    MessageDlg(sERROR_INVALID_IMAGE_FORMAT, mtError, [mbOk], 0);
  end;
end;

procedure TfrmConfigurator.Save;
begin
  FKioskConfig.sServer := edServer.Text;
  FKioskConfig.sUser := edUser.Text;
  FKioskConfig.sPassword := edPassword.Text;

  FKioskConfig.iCallToType := TCallToType(rgCallTo.ItemIndex);
  FKioskConfig.sCallTo := GetCallTo(FKioskConfig.iCallToType);

  FKioskConfig.bNotifyManager := chbNotifyManager.Checked;
  FKioskConfig.sManager := edManager.Text;

  FKioskConfig.bShowChat := chbShowChatMessages.Checked;
  FKioskConfig.iChatDuration := edChatDuration.Value;

  FKioskConfig.bWriteLog := chbWriteLog.Checked;

  SaveSettings(FKioskConfig);
end;

class procedure TfrmConfigurator.SaveSettings(AKioskConfig: TKioskConfig);
begin
  with TRegistry.Create do
  try
    RootKey := HKEY_CURRENT_USER;
    if OpenKey(REG_KEY, True) then
    begin
      WriteString(sREG_SERVER, AKioskConfig.sServer);
      WriteString(sREG_USER, AKioskConfig.sUser);
      WriteString(sREG_PASSWORD, AKioskConfig.sPassword);

      WriteInteger(sREG_CALL_TO_TYPE, Ord(AKioskConfig.iCallToType));
      WriteString(sREG_CALL_TO, AKioskConfig.sCallTo);

      WriteBool(sREG_FORCED_PORTRAIT, AKioskConfig.bForcedPortrait);

      WriteBool(sREG_NOTIFY_MANAGER, AKioskConfig.bNotifyManager);
      WriteString(sREG_MANAGER, AKioskConfig.sManager);

      WriteBool(sREG_SHOWCHAT_MESSAGE, AKioskConfig.bShowChat);
      WriteInteger(sREG_CHAT_MESSAGE_DURATION, AKioskConfig.iChatDuration);

      WriteBool(sREG_WRITE_LOG, AKioskConfig.bWriteLog);
    end;
  finally
    Free;
  end;
end;

procedure TfrmConfigurator.SetCallTo(ACallToType: TCallToType; ACallTo: string);
begin
  edCallUserID.Text := '';
  edCallUserIDList.Text := '';

  case ACallToType of
    ctUser: edCallUserID.Text := ACallTo;
    ctUsersList: edCallUserIDList.Text := ACallTo;
    ctAB: ;
  end;
end;

end.
