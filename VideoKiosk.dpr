program VideoKiosk;

uses
  Vcl.Forms,
  ActiveX,
  TrueConf_CallXLib_TLB,
  Vcl.Dialogs,
  KioskMainForm in 'KioskMainForm.pas' {frmKioskMain},
  CallX_Common in 'utils\CallX_Common.pas',
  HardwareForm in 'utils\HardwareForm.pas' {frmHardware},
  LogUnit in 'utils\LogUnit.pas',
  UserCacheUnit in 'utils\UserCacheUnit.pas',
  ConfigForm in 'ConfigForm.pas' {frmConfigurator},
  MessageForm in 'MessageForm.pas' {frmMessage},
  rcstrings in 'rcstrings.pas';

{$R *.res}

const
  REGDB_E_CLASSNOTREG = $80040154;
  REGDB_E_READREGDB = $80040150;

var szName: PWideChar;
  iRes: Cardinal;
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'TrueConf Kiosk';


  { Check that CallX was installed }
  Application.CreateForm(TfrmKioskMain, frmKioskMain);
  Application.CreateForm(TfrmConfigurator, frmConfigurator);
  GetMem(szName, 1024);
  iRes := ProgIDFromCLSID(CLASS_TrueConfCallX, szName);

  if iRes = S_OK then
  begin
    Application.Run;
  end
  else if iRes = REGDB_E_CLASSNOTREG then
  begin
    MessageDlg(sERROR_NO_CALLX_IN_SYSTEM, mtError, [mbOK], 0);
    Application.Terminate;
  end
  else if iRes = REGDB_E_READREGDB then
  begin
    MessageDlg(sERROR_READ_REG, mtError, [mbOK], 0);
    Application.Terminate;
  end;
end.
