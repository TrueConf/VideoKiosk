unit UserCacheUnit;

interface

uses
  SysUtils, Classes, Contnrs, JSON;

type
  TUserStatus = (usUnknown, usOnline = 1);

  TUserData = class
  private
    procedure Free;
  public
    ID: string;
    DN: string;
    Status: integer;

    procedure CopyFrom(AData: TUserData);
  end;

  TUserCache = class(TObjectList)
  private
    function GetUserItem(Index: Integer): TUserData;
    procedure ReplaceOrAdd(AData: TUserData);
  public
    function Update(jsonStr: string): Boolean;
    procedure Clear; override;
    function GetUserDataById(userId: string): TUserData;
    function GetUserStatusById(userId: string): Integer;
    function IsOnline(userId: string): boolean;
    function GetUserCountByStatus(AUserStatus: TUserStatus): Integer;
  public
    property UserData[Index: Integer]: TUserData read GetUserItem; default;
  end;

implementation

{ TUserCache }

function TUserCache.GetUserItem(Index: Integer): TUserData;
begin
  Result := TUserData(inherited Items[Index]);
end;

procedure TUserCache.ReplaceOrAdd(AData: TUserData);
var
  exUserData, newUserData: TUserData;
begin
  exUserData := GetUserDataById(AData.ID);
  if exUserData <> Nil then begin
    exUserData.CopyFrom(AData);
  end
  else begin
    newUserData := TUserData.Create;
    newUserData.CopyFrom(AData);
    Add(newUserData);
  end;
end;

procedure TUserCache.Clear;
begin
  inherited;
end;

function TUserCache.GetUserStatusById(userId: string): Integer;
var
  udata: TUserData;
begin
  Result := -1;
  udata := GetUserDataById(userId);
  if (udata <> Nil) then
    Result := udata.Status;
end;

function TUserCache.IsOnline(userId: string): boolean;
begin
  Result := GetUserStatusById(userId) = Ord(usOnline);
end;

function TUserCache.GetUserCountByStatus(AUserStatus: TUserStatus): Integer;
var i: integer;
begin
  Result := 0;
  for i := 0 to Count - 1 do
    if UserData[i].Status = Ord(AUserStatus) then
      Result := Result + 1;
end;

function TUserCache.GetUserDataById(userId: string): TUserData;
var
  i: Integer;
begin
  Result := Nil;
  for i := 0 to Count - 1 do
    if UserData[i].ID = userId then begin
      Result := UserData[i];
      break;
    end;
end;

function TUserCache.Update(jsonStr: string): Boolean;
var
  JSON, evVal, abVal, userVal: TJSONValue;
  i: Integer;
  userData: TUserData;
begin
  Result := false;
  userData := Nil;
  try
    JSON := TJSONObject.ParseJSONValue(jsonStr);
    if JSON is TJSONObject then begin
      evVal := TJSONObject(JSON).GetValue('event');
      if not(Assigned(evVal) and (LowerCase(evVal.Value) = LowerCase('onAbookUpdate'))) then
        Exit;
      abVal := TJSONObject(JSON).GetValue('abook');
      if abVal is TJSONArray then
        for i := 0 to TJSONArray(abVal).Count - 1 do begin
          userData := TUserData.Create;
          userVal := TJSONArray(abVal).Items[i];
          if (userVal is TJSONObject) then begin
            userData.ID := TJSONObject(userVal).GetValue('peerId').Value;
            userData.DN := TJSONObject(userVal).GetValue('peerDn').Value;
            userData.Status := StrToIntDef(TJSONObject(userVal).GetValue('status').Value, -1);
            ReplaceOrAdd(userData);
          end;
          FreeAndNil(userVal);
        end;
    end;
  except
    userData.Free;
    Result := false;
  end;
end;


{ TUserData }

procedure TUserData.CopyFrom(AData: TUserData);
begin
  ID := AData.ID;
  DN := AData.DN;
  Status := AData.Status;
end;

procedure TUserData.Free;
begin
  inherited Free;
end;

end.
