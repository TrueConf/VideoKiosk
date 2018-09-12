unit rcstrings;

interface

const
  sRECOMMENDED_SIZE = 'Recommended: Width=%d, Height=%d';
  sCANT_PLAY_VIDEO = 'Can''t play this video';
  sERROR_EMPTY_PASSWORD = 'Password field is empty';
  sERROR_EMPTY_USER = 'UserID field is empty';
  sERROR_PASSWORDS_DO_NOT_MATCH = 'Passwords do not match. Please try again';
  sERROR_EMPTY_CALL_USER_ID = 'Field "User id" can not be empty';

  sCALLING_TO = ' calling to ';
  sNO_AVAILABLE_OPERATORS = 'No available operators';

  sERROR_INVALID_IMAGE_FORMAT = 'Invalid image format';

  sERROR_NO_CALLX_IN_SYSTEM = 'TrueConf SDK for Windows is not installed in your system';
  sERROR_READ_REG = 'Error reading Registry';

  sERROR_SUPPORT_SDK = 'Support for SDK Applications is not enabled on this server';

  { Login error }
  sUSER_LOGGEDIN_OK      = 'Login successful, otherwise error code';
  sUSER_ALREADY_LOGGEDIN = 'Answer on CheckUserLoginStatus_Method, if current CID is already authorized at TransportRouter';
  sNO_USER_LOGGEDIN      = 'Answer on CheckUserLoginStatus_Method, if current CID is not authorized at TransportRouter - can try to login';
  sACCESS_DENIED         = 'Incorrect login or password';
  sSILENT_REJECT_LOGIN   = 'Client shouldn''t show error to user (example: incorrect AutoLoginKey)';
  sLICENSE_USER_LIMIT    = 'License restriction of online users reached, server cannot login you';
  sUSER_DISABLED         = 'User exist, but he is disabled to use this server';
  sRETRY_LOGIN           = 'Client should retry login after timeout (value in container or default), due to server busy or other server problems';
  sINVALID_CLIENT_TYPE   = 'User cannot login using this client app (should use other type of client app)';

  sUSER_NOT_AVIALABLE = 'User is not available';

implementation

end.
