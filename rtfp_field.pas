// 计划要做单独字段管理
//
//
//
//
//

unit rtfp_field;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, dbf;

type

  TAttrsFieldList = class;
  TAttrsGroup = class;
  TAttrsGroupList = class;


  TAttrsField = class(TCollectionItem)
  private
    FFieldName:string;
    FDataType:TFieldType;
    FAttrsGroup:TAttrsGroup;
    FShown:boolean;
  public
    constructor Create(ACollection: TCollection);
    property Shown:boolean read FShown write FShown;
    property DataType:TFieldType read FDataType write FDataType;
    property FieldName:string read FFieldName write FFieldName;
    property AttrsGroup:TAttrsGroup read FAttrsGroup;
  end;

  TAttrsFieldEnumerator = class(TCollectionEnumerator)
  private
    FCollection: TAttrsFieldList;
    FPosition: Integer;
  public
    constructor Create(ACollection: TCollection);
    function GetCurrent:string;
    function MoveNext: Boolean;
    property Current:string read GetCurrent;
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
    function AddEx(AFieldName:string): TAttrsField;
    procedure Clear;
    function GetEnumerator:TAttrsFieldEnumerator;
    property Items[Index: integer]: TAttrsField read GetItems write SetItems; default;
  end;



  TAttrsGroup = class(TCollectionItem)
  private
    FName,FFullPath:string;
    FDbf:TDbf;
    FGroupShown:boolean;
  public
    property Name:string read FName;
    property FullPath:string read FFullPath;
    property Dbf:Tdbf read FDbf;
    property GroupShown:boolean read FGroupShown write FGroupShown;//如果为true，FieldFilter会以此为筛选条件
  public
    constructor Create(ACollection:TCollection);override;
    destructor Destroy;override;
  end;


  TAttrsGroupEnumerator = class(TCollectionEnumerator)
  private
    FCollection: TAttrsGroupList;
    FPosition: Integer;
  public
    constructor Create(ACollection: TCollection);
    function GetCurrent:string;
    function MoveNext: Boolean;
    property Current:string read GetCurrent;
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
    function AddEx(AFullPath,AName:string): TAttrsGroup;
    procedure Clear;
    function GetEnumerator: TAttrsGroupEnumerator;
    function FindItemIndexByName(AName:string):integer;
    property Items[Index: integer]: TAttrsGroup read GetItems write SetItems; default;
    property Path:string read FFullPath write FFullPath;
  public
    procedure LoadFromPath(APath:string='\');//相对地址

  end;


implementation
uses rtfp_files;

{ TAttrsField }

constructor TAttrsField.Create(ACollection: TCollection);
begin
  if Assigned(ACollection) and (ACollection is TAttrsFieldList) then
    inherited Create(ACollection)
  else raise Exception.Create('TAttrsField.Create: unassigned or wrong ListType');
end;


{ TAttrsFieldEnumerator }

constructor TAttrsFieldEnumerator.Create(ACollection: TCollection);
begin
  if Assigned(ACollection) then
    inherited Create(ACollection)
  else raise Exception.Create('TAttrsFieldEnumerator.Create: unassigned');
end;

function TAttrsFieldEnumerator.GetCurrent:string;
begin
  result:=(inherited GetCurrent as TAttrsField).FFieldName;
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

function TAttrsFieldList.AddEx(AFieldName:string): TAttrsField;
begin
  Result := inherited Add as TAttrsField;
  result.FFieldName:=AFieldName;
end;

procedure TAttrsFieldList.Clear;
begin
  inherited Clear;
end;






{ TAttrsGroup }

constructor TAttrsGroup.Create(ACollection: TCollection);
begin
  if Assigned(ACollection) then
    inherited Create(ACollection)
  else raise Exception.Create('TAttrsGroup.Create: unassigned');
  FDbf:=TDbf.Create(nil);
end;

destructor TAttrsGroup.Destroy;
begin
  FDbf.Free;
  Inherited Destroy;
end;

{ TAttrsGroupEnumerator }

constructor TAttrsGroupEnumerator.Create(ACollection: TCollection);
begin
  if Assigned(ACollection) then
    inherited Create(ACollection)
  else raise Exception.Create('TRTFP_ClassEnumerator.Create: unassigned');
end;

function TAttrsGroupEnumerator.GetCurrent:string;
begin
  result:=(inherited GetCurrent as TAttrsGroup).FFullPath;
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

function TAttrsGroupList.AddEx(AFullPath,AName:string): TAttrsGroup;
begin
  Result := inherited Add as TAttrsGroup;
  result.FFullPath:=AFullPath;
  result.FName:=AName;
  result.FDbf:=TDbf.Create(Self.FOwner);
end;

procedure TAttrsGroupList.Clear;
begin
  inherited Clear;
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

procedure TAttrsGroupList.LoadFromPath(APath:string='\');
var tmpFileList:TRTFP_FileList;
    stmp:TCollectionItem;
    pathname,groupname:string;
begin
  assert(APath<>'','TAttrsGroupList.LoadFromPath: APath=""');
  if APath='' then exit;
  Clear;
  tmpFileList:=TRTFP_FileList.Create(nil,FFullPath+'\'+APath);
  try
    tmpFileList.BaseDir:=FFullPath+'\'+APath;
    tmpFileList.RunDir;
    for stmp in tmpFileList do
      begin
        pathname:=(stmp as TRTFP_FileItem).Name;
        groupname:=ExtractFilename(pathname);
        if lowercase(ExtractFileExt(groupname))='.dbf' then groupname:=Copy(groupname,1,length(groupname)-4);
        if lowercase(ExtractFileExt(pathname))='.dbf' then pathname:=Copy(pathname,1,length(pathname)-4);
        //ShowMessage(groupname+#13#10+pathname);
        Self.AddEx(pathname,groupname);
      end;

  finally
    tmpFileList.Free;
  end;

end;



end.

