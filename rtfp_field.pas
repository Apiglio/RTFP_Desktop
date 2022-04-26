// 计划要做单独字段管理
// 开始给每一个attrs一个单独的modified属性，需要在definition.pas里实现


unit rtfp_field;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, dbf, rtfp_constants, Graphics, BufDataset;

type

  TAttrsFieldList = class;
  TAttrsGroup = class;
  TAttrsGroupList = class;

  TColorizeProcess = function(v1,v2:double;c1,c2:TColor;expresion:string;Value:TField):TColor;

  TFieldDisplayOption = record
    v1,v2:double;
    c1,c2:TColor;
    expression:string;
    colorize_process:TColorizeProcess;
    display_width:integer;
  end;


  TAttrsField = class(TCollectionItem)
  private
    FFieldName:string;
    FFieldDef:TFieldDef;
    FAttrsGroup:TAttrsGroup;
    FShown:boolean;
    FOnChangeVisibility:TNotifyEvent;
    FUpdating:boolean;
  public//暂时改成公共
    FFieldDisplayOption:TFieldDisplayOption;
  protected
    procedure SetShown(value:boolean);
  public
    constructor Create(ACollection: TCollection);
    procedure BeginUpdate;
    procedure EndUpdate;

    property Shown:boolean read FShown write SetShown;
    property OnChangeVisibility:TNotifyEvent read FOnChangeVisibility write FOnChangeVisibility;
    property FieldDef:TFieldDef read FFieldDef;
    property FieldName:string read FFieldName write FFieldName;
    property AttrsGroup:TAttrsGroup read FAttrsGroup;
    property FieldDisplayOption:TFieldDisplayOption read FFieldDisplayOption{ write FFieldDisplayOption};
  end;

  TAttrsFieldEnumerator = class(TCollectionEnumerator)
  private
    FCollection: TAttrsFieldList;
    FPosition: Integer;
  public
    constructor Create(ACollection: TCollection);
    function GetCurrent:TAttrsField;
    function MoveNext: Boolean;
    property Current:TAttrsField read GetCurrent;
  end;

  TAttrsFieldList = class(TCollection)
  private
    FOwner:TComponent;
  private
    function GetItems(Index: integer): TAttrsField;
    procedure SetItems(Index: integer; AValue: TAttrsField);
  public
    constructor Create(AOwner:TComponent);
  public
    function Add: TAttrsField;
    function AddEx(AFieldDef:TFieldDef): TAttrsField;
    procedure Clear;
    function GetEnumerator:TAttrsFieldEnumerator;
    function FindItemIndexByName(AName:string):integer;
    function FindItemByName(AName:string):TAttrsField;
    property Items[Index: integer]: TAttrsField read GetItems write SetItems; default;
  end;



  TAttrsGroup = class(TCollectionItem)
  private
    FName,FFullPath:string;
    FDbf:{TDbf}TDataSet;
    FFieldList:TAttrsFieldList;
    FGroupShown:boolean;
    FModified:boolean;
  protected
    function GetIsEmpty:boolean;
  public
    property Name:string read FName;
    property FullPath:string read FFullPath;
    property FieldList:TAttrsFieldList read FFieldList;
    property Dbf:{TDbf}TDataSet read FDbf;
    property GroupShown:boolean read FGroupShown write FGroupShown;//如果为true，FieldFilter会以此为筛选条件
    property IsEmpty:boolean read GetIsEmpty;
    property Modified:boolean read FModified write FModified;
  public
    constructor Create(ACollection:TCollection);override;
    destructor Destroy;override;
    procedure LoadFieldListFromDbf;
    procedure DelField(AName:string);
    procedure AddField(AFieldDef:TFieldDef);
  end;


  TAttrsGroupEnumerator = class(TCollectionEnumerator)
  private
    FCollection: TAttrsGroupList;
    FPosition: Integer;
  public
    constructor Create(ACollection: TCollection);
    function GetCurrent:TAttrsGroup;
    function MoveNext: Boolean;
    property Current:TAttrsGroup read GetCurrent;
  end;

  TAttrsGroupList = class(TCollection)
  private
    FOwner:TComponent;
    FFullPath:string;
  private
    function GetItems(Index: integer): TAttrsGroup;
    procedure SetItems(Index: integer; AValue: TAttrsGroup);
  public
    constructor Create(AOwner:TComponent);
  public
    function Add: TAttrsGroup;
    function AddEx(AFullPath,AName:string;data_set_type:string='dbf'): TAttrsGroup;
    procedure Clear;
    function GetEnumerator: TAttrsGroupEnumerator;
    function FindItemIndexByName(AName:string):integer;
    function FindItemByName(AName:string):TAttrsGroup;
    property Items[Index: integer]: TAttrsGroup read GetItems write SetItems; default;
    property Path:string read FFullPath write FFullPath;
  public
    procedure LoadFromPath(APath:string='\';data_set_type:string='dbf');//相对地址
  end;


implementation
uses rtfp_files, regexpr;

{ TAttrsField }

procedure TAttrsField.SetShown(value:boolean);
begin
  if FShown<>value then begin
    FShown:=value;
    if (not FUpdating) and (FOnChangeVisibility<>nil) then FOnChangeVisibility(Self);
  end;
end;

constructor TAttrsField.Create(ACollection: TCollection);
begin
  if Assigned(ACollection) and (ACollection is TAttrsFieldList) then
    inherited Create(ACollection)
  else raise Exception.Create('TAttrsField.Create: unassigned or wrong ListType');
  FUpdating:=false;
  FOnChangeVisibility:=nil;
  FFieldDisplayOption.colorize_process:=nil;
  FFieldDisplayOption.display_width:=90;
end;

procedure TAttrsField.BeginUpdate;
begin
  FUpdating:=true;
end;

procedure TAttrsField.EndUpdate;
begin
  FUpdating:=false;
end;

{ TAttrsFieldEnumerator }

constructor TAttrsFieldEnumerator.Create(ACollection: TCollection);
begin
  if Assigned(ACollection) then
    inherited Create(ACollection)
  else raise Exception.Create('TAttrsFieldEnumerator.Create: unassigned');
end;

function TAttrsFieldEnumerator.GetCurrent:TAttrsField;
begin
  result:=(inherited GetCurrent as TAttrsField);
end;

function TAttrsFieldEnumerator.MoveNext: Boolean;
begin
  result:=inherited MoveNext;
end;

{ TAttrsFieldList }

function TAttrsFieldList.GetItems(Index: integer): TAttrsField;
begin
  Result := TAttrsField(inherited Items[Index]);
end;

procedure TAttrsFieldList.SetItems(Index: integer; AValue: TAttrsField);
begin
  Items[Index].Assign(AValue);
end;

constructor TAttrsFieldList.Create(AOwner:TComponent);
begin
  inherited Create(TAttrsField);//why??
end;

function TAttrsFieldList.GetEnumerator:TAttrsFieldEnumerator;
begin
  Result := TAttrsFieldEnumerator.Create(Self);
end;

function TAttrsFieldList.Add: TAttrsField;
begin
  Result := inherited Add as TAttrsField;
end;

function TAttrsFieldList.AddEx(AFieldDef:TFieldDef): TAttrsField;
begin
  Result := inherited Add as TAttrsField;
  Result.FFieldName:=UpperCase(AFieldDef.Name);
  Result.FFieldDef:=AFieldDef;
  Result.FFieldDisplayOption.display_width:=-1;
end;

procedure TAttrsFieldList.Clear;
begin
  inherited Clear;
end;

function TAttrsFieldList.FindItemIndexByName(AName:string):integer;
begin
  result:=0;
  AName:=UpperCase(AName);
  while result<Count do begin
    if Uppercase(Items[result].FieldName)=AName then exit;
    inc(result);
  end;
  result:=-1;
end;

function TAttrsFieldList.FindItemByName(AName:string):TAttrsField;
var index:integer;
begin
  index:=FindItemIndexByName(AName);
  if index<0 then result:=nil
  else result:=Items[index];
end;





{ TAttrsGroup }

constructor TAttrsGroup.Create(ACollection: TCollection);
begin
  if Assigned(ACollection) then
    inherited Create(ACollection)
  else raise Exception.Create('TAttrsGroup.Create: unassigned');

  //FDbf:=TDbf.Create(nil);
  //数据库创建不要放在这里了，改到TAttrsGroup.AddEx中

  FFieldList:=TAttrsFieldList.Create(nil);
  FGroupShown:=true;
  FModified:=false

end;

destructor TAttrsGroup.Destroy;
begin
  FFieldList.Free;
  FDbf.Free;
  Inherited Destroy;
end;

procedure TAttrsGroup.LoadFieldListFromDbf;
var pi:integer;
begin
  FFieldList.Clear;
  with FDbf do
    begin
      if not Active then Open;
      pi:=0;
      while pi<FieldDefs.Count do
        begin
          FFieldList.AddEx(FieldDefs[pi]).FAttrsGroup:=Self;
          inc(pi);
        end;
    end;
end;

procedure TAttrsGroup.DelField(AName:string);
var idx:integer;
begin
  idx:=FFieldList.FindItemIndexByName(AName);
  if idx>=0 then FFieldList.Delete(idx);
end;

procedure TAttrsGroup.AddField(AFieldDef:TFieldDef);
var idx:integer;
begin
  idx:=FFieldList.FindItemIndexByName(AFieldDef.Name);
  if idx<0 then FFieldList.AddEx(AFieldDef).FAttrsGroup:=Self;
end;

function TAttrsGroup.GetIsEmpty:boolean;
var pi:integer;
begin
  result:=false;
  if FFieldList.Count>2 then exit;
  for pi:=0 to FFieldList.Count-1 do
    begin
      if (FFieldList[pi].FieldName<>_Col_PID_)
      and (FFieldList[pi].FieldName<>_Col_OID_)
      then exit;
    end;
  result:=true;
end;

{ TAttrsGroupEnumerator }

constructor TAttrsGroupEnumerator.Create(ACollection: TCollection);
begin
  if Assigned(ACollection) then
    inherited Create(ACollection)
  else raise Exception.Create('TRTFP_ClassEnumerator.Create: unassigned');
end;

function TAttrsGroupEnumerator.GetCurrent:TAttrsGroup;
begin
  result:=(inherited GetCurrent as TAttrsGroup);
end;

function TAttrsGroupEnumerator.MoveNext: Boolean;
begin
  result:=inherited MoveNext;
end;

{ TAttrsGroupList }

function TAttrsGroupList.GetItems(Index: integer): TAttrsGroup;
begin
  Result := TAttrsGroup(inherited Items[Index]);
end;

procedure TAttrsGroupList.SetItems(Index: integer; AValue: TAttrsGroup);
begin
  Items[Index].Assign(AValue);
end;

constructor TAttrsGroupList.Create(AOwner:TComponent);
begin
  inherited Create(TAttrsGroup);//why???
end;

function TAttrsGroupList.Add: TAttrsGroup;
begin
  Result := inherited Add as TAttrsGroup;
end;

function TAttrsGroupList.AddEx(AFullPath,AName:string;data_set_type:string='dbf'): TAttrsGroup;
begin
  Result := inherited Add as TAttrsGroup;
  AFullPath:=StringReplace(AFullPath,'\\','\',[rfReplaceAll]);//不会吧，不是这里的问题吧
  AFullPath:=StringReplace(AFullPath,'\\','\',[rfReplaceAll]);//斜杠要整理一下
  result.FFullPath:=AFullPath;
  result.FName:=AName;
  case data_set_type of
    'dbf':result.FDbf:=TDbf.Create(Self.FOwner);
    'buf':result.FDbf:=TBufDataset.Create(Self.FOwner);
  end;

end;

procedure TAttrsGroupList.Clear;
begin
  inherited Clear;
  //Self.BeginUpdate;
  //while Self.Count>0 do Self.Delete(0);
  //Self.EndUpdate;
end;

function TAttrsGroupList.GetEnumerator:TAttrsGroupEnumerator;
begin
  Result := TAttrsGroupEnumerator.Create(Self);
end;

function TAttrsGroupList.FindItemIndexByName(AName:string):integer;
begin
  result:=0;
  while result<Count do begin
    if Items[result].Name=AName then exit;
    inc(result);
  end;
  result:=-1;
end;

function TAttrsGroupList.FindItemByName(AName:string):TAttrsGroup;
var index:integer;
begin
  index:=FindItemIndexByName(AName);
  if index<0 then result:=nil
  else result:=Items[index];
end;


procedure TAttrsGroupList.LoadFromPath(APath:string='\';data_set_type:string='dbf');
var tmpFileList:TRTFP_FileList;
    stmp:TCollectionItem;
    pathname,groupname:string;
    regexp:TRegExpr;
begin
  assert(APath<>'','TAttrsGroupList.LoadFromPath: APath=""');
  if APath='' then exit;
  Clear;
  tmpFileList:=TRTFP_FileList.Create(nil,FFullPath+'\'+APath);
  regexp:=TRegExpr.Create;
  case data_set_type of
    'dbf':regexp.Expression:='[^_run]\.dbf';
    'buf':regexp.Expression:='\S\.buf';
  end;
  try
    //tmpFileList.BaseDir:=FFullPath+'\'+APath;
    tmpFileList.RunDir;
    for stmp in tmpFileList do
      begin
        pathname:=(stmp as TRTFP_FileItem).Name;
        if not regexp.Exec(pathname) then continue;
        groupname:=ExtractFileName(pathname);
        System.delete(groupname,length(groupname)-3,4);
        System.delete(pathname,length(pathname)-3,4);
        {
        if pos('.dbf',lowercase(pathname))<>length(pathname)-3 then continue;
        poss:=pos('_run.dbf',lowercase(pathname));
        if (poss=length(pathname)-7) and (poss>0) then continue;
        if lowercase(ExtractFileExt(groupname))='.dbf' then groupname:=Copy(groupname,1,length(groupname)-4);
        {if lowercase(ExtractFileExt(pathname))='.dbf' then }pathname:=Copy(pathname,1,length(pathname)-4);
        //ShowMessage(groupname+#13#10+pathname);
        }
        Self.AddEx(APath+'\'+pathname,groupname,data_set_type);
      end;

  finally
    tmpFileList.Free;
    regexp.Free;
  end;

end;


end.

