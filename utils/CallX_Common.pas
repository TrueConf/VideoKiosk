unit CallX_Common;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes;

const
  iUSER_LOGGEDIN_OK      = 0;// (login successful, otherwise error code)
  iUSER_ALREADY_LOGGEDIN = 1;// (answer on CheckUserLoginStatus_Method, if current CID is already authorized at TransportRouter)
  iNO_USER_LOGGEDIN      = 2;// (answer on CheckUserLoginStatus_Method, if current CID is not authorized at TransportRouter - can try to login)
  iACCESS_DENIED         = 3;// (incorrect password or other problems with DB)
  iSILENT_REJECT_LOGIN   = 4;// (client shouldn't show error to user (example: incorrect AutoLoginKey))
  iLICENSE_USER_LIMIT    = 5;// (license restriction of online users reached, server cannot login you)
  iUSER_DISABLED         = 6;// (user exist, but he is disabled to use this server)
  iRETRY_LOGIN           = 7;// (client should retry login after timeout (value in container or default), due to server busy or other server problems)
  iINVALID_CLIENT_TYPE   = 8;// (user cannot login using this client app (should use other type of client app))

type
  TCallState = (csBeforeInit, csNone, csConnect, csLogin, csNormal, csWait, csConference, csClose);


function GetShiftDown : Boolean;
function IntToCallState(AState: integer): TCallState;
function IntToStringState(AState: integer): string;

implementation

function GetShiftDown : Boolean;
begin
  Result := HiWord(GetKeyState(VK_SHIFT)) <> 0;
end;

function IntToCallState(AState: integer): TCallState;
begin
  Result := csNone;

  case AState of
    0: Result := csNone;
    1: Result := csConnect;
    2: Result := csLogin;
    3: Result := csNormal;
    4: Result := csWait;
    5: Result := csConference;
    6: Result := csClose;
    else
      Result := csNone;
  end;
end;

function IntToStringState(AState: integer): string;
begin
  Result := 'None';

  case AState of
    0: Result := 'None';
    1: Result := 'Connect';
    2: Result := 'Login';
    3: Result := 'Normal';
    4: Result := 'Wait';
    5: Result := 'Conference';
    6: Result := 'Close';
    else
      Result := 'Unknown';
  end;
end;

end.
