unit KioskMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.OleCtrls, TrueConf_CallXLib_TLB, CallX_Common, UserCacheUnit,
  System.Actions, Vcl.ActnList, Vcl.StdCtrls;

const
  REG_KEY = 'SOFTWARE\TrueConf\VideoKiosk';
  iDEFAULT_CHAT_MESSAGE_DURATION = 5; {sec}

type
  TCallToType = (ctUser, ctUsersList, ctAB);

  TKioskConfig = record
    sServer: string;
    sUser: string;
    sPassword: string;
    iCallToType: TCallToType;
    sCallTo: string;
    bForcedPortrait: boolean;
    bNotifyManager: boolean;
    sManager: string;
    bShowChat: boolean;
    iChatDuration: integer;
    bWriteLog: boolean;
  end;

  TMarkupMargins = record
    Left, Right, Top, Bottom: integer;
    AlignWithMargins: boolean;
  end;

  TfrmKioskMain = class(TForm)
    pnlFooter: TPanel;
    pnlHeader: TPanel;
    Panel3: TPanel;
    imgBackground: TImage;
    pnlClient: TPanel;
    pnlButton: TPanel;
    imgLogo: TImage;
    pnlVideo: TPanel;
    pnlCall: TPanel;
    imgCallOrReject: TImage;
    CallX: TTrueConfCallX;
    ActionList: TActionList;
    actConfigurator: TAction;
    Image1: TImage;
    pnlStatus: TPanel;
    imgStat: TImage;
    Label1: TLabel;
    imgStatGrey: TImage;
    imgStatRed: TImage;
    imgStatGreen: TImage;
    imgStatYellow: TImage;
    imgConnecting: TImage;
    imgCall: TImage;
    imgCalling: TImage;
    imgReject: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CallXXAfterStart(Sender: TObject);
    procedure CallXServerConnected(ASender: TObject;
      const eventDetails: WideString);
    procedure CallXXChangeState(ASender: TObject; prevState, newState: Integer);
    procedure imgCallOrRejectClick(Sender: TObject);
    procedure CallXRecordRequest(ASender: TObject;
      const eventDetails: WideString);
    procedure CallXInviteReceived(ASender: TObject;
      const eventDetails: WideString);
    procedure CallXIncomingChatMessage(ASender: TObject; const peerId, peerDn,
      message: WideString; time: UInt64);
    procedure CallXXLogin(Sender: TObject);
    procedure CallXAbookUpdate(ASender: TObject;
      const eventDetails: WideString);
    procedure FormDestroy(Sender: TObject);
    procedure CallXXError(ASender: TObject; errorCode: Integer;
      const errorMsg: WideString);
    procedure CallXXFileSendError(ASender: TObject; error_code, fileId: Integer;
      const filePath, fileCaption: WideString);
    procedure CallXXLoginError(ASender: TObject; errorCode: Integer);
    procedure CallXXStartFail(Sender: TObject);
    procedure CallXLogin(ASender: TObject; const eventDetails: WideString);
    procedure CallXLogout(ASender: TObject; const eventDetails: WideString);
    procedure CallXServerDisconnected(ASender: TObject;
      const eventDetails: WideString);
    procedure actConfiguratorExecute(Sender: TObject);
    procedure CallXIncomingGroupChatMessage(ASender: TObject; const peerId,
      peerDn, message: WideString; time: UInt64);
    procedure CallXIncomingRequestToPodiumAnswered(ASender: TObject;
      const eventDetails: WideString);
    procedure CallXHardwareChanged(ASender: TObject;
      const eventDetails: WideString);
  private
    { Private declarations }
    FKioskConfig: TKioskConfig;
    FCallState: TCallState;
    FUserStatusCache: TUserCache;
    FInConfigMode: boolean;
    FStarted: boolean;
  protected
    procedure SetShow(AShow: boolean);
    procedure CallOrReject;
    procedure SetCallState(const Value: TCallState);
    procedure Call;
    procedure NotifyManager(AMsg: string);
    procedure WriteLog(ALine: string);
    procedure ShowConfigurator;
    procedure OnAppException(Sender: TObject; E: Exception);
  public
    { Public declarations }
    procedure SendWarningMsg(AMsg: string);
  end;

var
  frmKioskMain: TfrmKioskMain;

implementation

{$R *.dfm}

uses ConfigForm, MessageForm, HardwareForm, rcstrings,
  LogUnit, ComObj, Activex;

function NowToString: string;
begin
  Result := '[' + DateTimeToStr(Now) + ']';
end;

procedure ShowSize(AControl: TControl);
begin
  ShowMessage(Format('Width=%d; Height=%d', [AControl.Width, AControl.Height]));
end;

procedure TfrmKioskMain.FormCreate(Sender: TObject);
begin
  FStarted := False;
  Caption := Application.Title;

  FInConfigMode := (ParamCount = 1) and (LowerCase(ParamStr(1)) = '-config');

  FUserStatusCache := TUserCache.Create;
  TfrmConfigurator.LoadSettings(FKioskConfig);

  Application.OnException := OnAppException;
end;

procedure TfrmKioskMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FUserStatusCache);
end;

procedure TfrmKioskMain.FormShow(Sender: TObject);
begin
  SetShow(True);
  SetCallState(csNone);
end;

procedure TfrmKioskMain.imgCallOrRejectClick(Sender: TObject);
begin
  CallOrReject;
end;

procedure TfrmKioskMain.NotifyManager(AMsg: string);
begin
  if (not FKioskConfig.bNotifyManager)
    or (not (FCallState in [csNormal, csWait, csConference]))
    or (Trim(FKioskConfig.sManager) = '')
  then
    Exit;

  { send a chat message }
  CallX.sendMessage(FKioskConfig.sManager, AMsg);
end;

procedure TfrmKioskMain.OnAppException(Sender: TObject; E: Exception);
begin
  WriteLog('OnAppException: ' + E.Message);
  MessageDlg(E.Message, mtError, [mbOK], 0)
end;

procedure TfrmKioskMain.SetCallState(const Value: TCallState);
begin
  FCallState := Value;

  case FCallState of
    csNone:
            begin
              imgStat.Picture.Assign(imgStatGrey.Picture);
              imgCallOrReject.Picture.Assign(imgConnecting.Picture);
            end;
    csConnect:
            begin
              imgStat.Picture.Assign(imgStatRed.Picture);
              imgCallOrReject.Picture.Assign(imgConnecting.Picture);
            end;
    csLogin:
            begin
              imgStat.Picture.Assign(imgStatRed.Picture);
              imgCallOrReject.Picture.Assign(imgConnecting.Picture);
            end;
    csNormal:
            begin
              imgStat.Picture.Assign(imgStatGreen.Picture);
              imgCallOrReject.Picture.Assign(imgCall.Picture);
            end;
    csWait: begin
              imgStat.Picture.Assign(imgStatYellow.Picture);
              imgCallOrReject.Picture.Assign(imgCalling.Picture);
            end;
    csConference:
            begin
              imgStat.Picture.Assign(imgStatYellow.Picture);
              imgCallOrReject.Picture.Assign(imgReject.Picture);
            end;
    csClose:
            begin
              imgStat.Picture.Assign(imgStatGrey.Picture);
              imgCallOrReject.Picture.Assign(imgConnecting.Picture);
            end;
  end;
end;

procedure TfrmKioskMain.SetShow(AShow: boolean);
begin
  if AShow then
  begin
    if not Visible then
      Show;

    Width := Screen.Width;
    Height := Screen.Height;

    BorderStyle := bsNone;

    Left := 0;
    Top := 0;
  end
  else begin
    Hide;
  end;
end;

procedure TfrmKioskMain.ShowConfigurator;
var FullProgPath: PAnsiChar;
begin
  with TfrmConfigurator.Create(self) do
  begin
    CallX := self.CallX;
    if ShowModal = mrOk then
    begin
      { Restart the application }
      FullProgPath := PAnsiChar(AnsiString(Application.ExeName));
      WinExec(FullProgPath, SW_SHOW);
      Application.Terminate;
    end;
  end;
end;

procedure TfrmKioskMain.WriteLog(ALine: string);
begin
  if not FKioskConfig.bWriteLog then
    Exit;

  { write logs }
  Log(NowToString + ' ' + ALine);
end;

procedure TfrmKioskMain.SendWarningMsg(AMsg: string);
begin
  if (FKioskConfig.sManager <> '')
    and FKioskConfig.bNotifyManager
    and (FCallState in [csNormal, csWait, csConference])
  then
    CallX.sendMessage(FKioskConfig.sManager, AMsg);

  WriteLog(AMsg);
end;

procedure TfrmKioskMain.actConfiguratorExecute(Sender: TObject);
begin
  if FStarted then
    ShowConfigurator;
end;

procedure TfrmKioskMain.Call;
var i, iRandom, iCnt: integer;
  Users: TStrings;
  OtherId: string;
begin
  OtherId := '';

  case FKioskConfig.iCallToType of
    { ================================================================ }
    { One user }
    { ================================================================ }
    ctUser: OtherId := FKioskConfig.sCallTo;
    { ================================================================ }
    { List of users }
    { ================================================================ }
    ctUsersList:
      begin
        Users := TStringList.Create;
        try
          Users.CommaText := FKioskConfig.sCallTo;
          for i := 0 to Users.Count - 1 do
            if FUserStatusCache.IsOnline(Users[i]) then begin
              OtherId := Users[i];
              Break;
            end;
        finally
          Users.Free;
        end;
      end;
    { ================================================================ }
    { Address book }
    { ================================================================ }
    ctAB:
      begin
        Randomize;
        iCnt := FUserStatusCache.GetUserCountByStatus(usOnline);
        WriteLog(Format('Call random by AB: all users=%d, online=%d', [FUserStatusCache.Count, iCnt]));
        if iCnt <= 0 then begin
          OtherId := '';
        end
        else begin
          iRandom := Random(iCnt - 1) + 1;
          OtherId := '';

          i := 0;
          while((iRandom > 0) and (i < FUserStatusCache.Count)) do begin
            if FUserStatusCache.IsOnline(FUserStatusCache[i].ID) then
            begin
              OtherId := FUserStatusCache[i].ID;
              iRandom := iRandom - 1;
            end;
            i := i + 1;
          end;
        end;
      end;
  end;

  OtherId := Trim(OtherId);
  if OtherId <> '' then
  begin
    SendWarningMsg(FKioskConfig.sUser + ' ' + sCALLING_TO + '"' + OtherId + '"');

    if (not FUserStatusCache.IsOnline(OtherId)) and Assigned(FUserStatusCache.GetUserDataById(OtherId)) then
      SendWarningMsg(sUSER_NOT_AVIALABLE + ': ' + OtherId);

    CallX.call(OtherId);
  end
  else begin
    SendWarningMsg(FKioskConfig.sUser + ': ' + sNO_AVAILABLE_OPERATORS);
  end;
end;

procedure TfrmKioskMain.CallOrReject;
begin
  if FCallState = csNormal then
  begin
    Call;
  end
  else if FCallState in [csWait, csConference] then
  begin
    CallX.hangUp;
  end;
end;

procedure TfrmKioskMain.CallXAbookUpdate(ASender: TObject;
  const eventDetails: WideString);
var s: string;
begin
  s := eventDetails;
  FUserStatusCache.Update(s);
end;

procedure TfrmKioskMain.CallXHardwareChanged(ASender: TObject;
  const eventDetails: WideString);
begin
  WriteLog('OnHardwareChanged: ' + eventDetails);
end;

procedure TfrmKioskMain.CallXIncomingChatMessage(ASender: TObject; const peerId,
  peerDn, message: WideString; time: UInt64);
begin
  if FKioskConfig.bShowChat then
    with TfrmMessage.Create(self) do
      SoftShow(message, FKioskConfig.iChatDuration);
end;

procedure TfrmKioskMain.CallXIncomingGroupChatMessage(ASender: TObject;
  const peerId, peerDn, message: WideString; time: UInt64);
begin
  if FKioskConfig.bShowChat then
    with TfrmMessage.Create(self) do
      SoftShow(message, FKioskConfig.iChatDuration);
end;

procedure TfrmKioskMain.CallXIncomingRequestToPodiumAnswered(ASender: TObject;
  const eventDetails: WideString);
begin
  WriteLog('OnIncomingRequestToPodiumAnswered: ' + eventDetails);
  CallX.acceptPodiumInvite;
end;

procedure TfrmKioskMain.CallXInviteReceived(ASender: TObject;
  const eventDetails: WideString);
begin
  WriteLog('OnInviteReceived: ' + eventDetails);
  Application.Restore;   // why not...?
  CallX.accept; // Accept an incoming call
end;

procedure TfrmKioskMain.CallXLogin(ASender: TObject;
  const eventDetails: WideString);
begin
  WriteLog('OnLogin: ' + eventDetails);
end;

procedure TfrmKioskMain.CallXLogout(ASender: TObject;
  const eventDetails: WideString);
begin
  WriteLog('OnLogout: ' + eventDetails);
end;

procedure TfrmKioskMain.CallXRecordRequest(ASender: TObject;
  const eventDetails: WideString);
begin
  CallX.allowRecord;
end;

procedure TfrmKioskMain.CallXServerConnected(ASender: TObject;
  const eventDetails: WideString);
begin
  WriteLog('OnServerConnected: ' + eventDetails);
  if (FKioskConfig.sUser <> '') and (FKioskConfig.sPassword <> '') then
  begin
    WriteLog('Try login: ' + FKioskConfig.sUser);
    CallX.login(FKioskConfig.sUser, FKioskConfig.sPassword)
  end
  else
    WriteLog('Empty login info');
end;

procedure TfrmKioskMain.CallXServerDisconnected(ASender: TObject;
  const eventDetails: WideString);
begin
  WriteLog('OnServerDisconnected: ' + eventDetails);
end;

procedure TfrmKioskMain.CallXXAfterStart(Sender: TObject);
begin
  WriteLog('OnXAfterStart: ==============================================');

  if (FKioskConfig.sServer <> '') or ((FKioskConfig.sUser <> '') and (FKioskConfig.sPassword <> '')) then
    CallX.connectToServer(FKioskConfig.sServer)
  else
    WriteLog('Empty connect & login info');

  if TfrmHardware.ApplySettings(self, REG_KEY, CallX) then
  begin

  end;

  FStarted := True;

  if FInConfigMode then
    ShowConfigurator;
end;

procedure TfrmKioskMain.CallXXChangeState(ASender: TObject; prevState,
  newState: Integer);
begin
  WriteLog(Format('OnXChangeState: prevState=%d (%s), newState=%d (%s)',
    [prevState, IntToStringState(prevState), newState, IntToStringState(newState)]));
  SetCallState(IntToCallState(newState));
end;

procedure TfrmKioskMain.CallXXError(ASender: TObject; errorCode: Integer;
  const errorMsg: WideString);
begin
  WriteLog('OnXError: errorCode=' + IntToStr(errorCode) + '; ' + errorMsg);
end;

procedure TfrmKioskMain.CallXXFileSendError(ASender: TObject; error_code,
  fileId: Integer; const filePath, fileCaption: WideString);
begin
  WriteLog('OnXFileSendError: errorCode=' + IntToStr(error_code) + '; ' + filePath);
end;

procedure TfrmKioskMain.CallXXLogin(Sender: TObject);
begin
  CallX.getAbook;
end;

procedure TfrmKioskMain.CallXXLoginError(ASender: TObject; errorCode: Integer);
begin
  WriteLog('OnXLoginError: errorCode=' + IntToStr(errorCode) + '; ');

  if errorCode = iUSER_ALREADY_LOGGEDIN then
    MessageDlg(sUSER_ALREADY_LOGGEDIN, mtError, [mbOK], 0)
  else if errorCode = iNO_USER_LOGGEDIN then
    MessageDlg(sNO_USER_LOGGEDIN, mtError, [mbOK], 0)
  else if errorCode = iACCESS_DENIED then
    MessageDlg(sACCESS_DENIED, mtError, [mbOK], 0)
  else if errorCode = iSILENT_REJECT_LOGIN then
    MessageDlg(sSILENT_REJECT_LOGIN, mtError, [mbOK], 0)
  else if errorCode = iLICENSE_USER_LIMIT then
    MessageDlg(sLICENSE_USER_LIMIT, mtError, [mbOK], 0)
  else if errorCode = iUSER_DISABLED then
    MessageDlg(sUSER_DISABLED, mtError, [mbOK], 0)
  else if errorCode = iRETRY_LOGIN then
    MessageDlg(sRETRY_LOGIN, mtError, [mbOK], 0)
  else if errorCode = iINVALID_CLIENT_TYPE then
    MessageDlg(sERROR_SUPPORT_SDK, mtError, [mbOK], 0);
end;

procedure TfrmKioskMain.CallXXStartFail(Sender: TObject);
begin
  WriteLog('OnXStartFail error; ');
end;

end.
