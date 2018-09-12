unit LogUnit;

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Forms;

const
  APPDATA_FOLDER = 'TrueConf\TrueConf SDK for Windows\';

procedure Log(const ALine: string);
function GetLogPath: string;

implementation

function GetLogPath: string;
begin
  Result := GetEnvironmentVariable('APPDATA');
  if Result <> '' then begin
    Result := IncludeTrailingPathDelimiter(Result) + APPDATA_FOLDER;
    { make folders if need }
    ForceDirectories(Result);
    Result := Result + ExtractFileName(Application.ExeName) + '.log';
  end;
end;

procedure Log(const ALine: string);
var fLog: TextFile;
  sFileName: string;
  hFile: THandle;
begin
  sFileName := GetLogPath;

  AssignFile(fLog, sFileName);

  if not FileExists(sFileName) then
    Rewrite(fLog);

  Append(fLog);
  try
    WriteLn(fLog, ALine);
  finally
    CloseFile(fLog);
  end;
end;

end.
