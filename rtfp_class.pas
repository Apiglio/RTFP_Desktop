unit rtfp_class;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dbf, rtfp_constants;

type

  TKlassList = class;

  TKlass = class(TCollectionItem)
  private
    FName,FFullPath:string;
    FDbf:TDbf;
    FFilterEnabled:boolean;
  public
    property Name:string read FName;
    property FullPath:string read FFullPath;
    property Dbf:Tdbf read FDbf;
    property FilterEnabled:boolean read FFilterEnabled write FFilterEnabled;//如果为true，RecordFilter会以此为筛选条件
  public
    constructor Create(ACollection:TCollection);override;
    destructor Destroy;override;
  end;


  TKlassEnumerator = class(TCollectionEnumerator)
  private
    FCollection: TKlassList;
    FPosition: Integer;
  public
    constructor Create(ACollection: TCollection);
    function GetCurrent:TKlass;
    function MoveNext: Boolean;
    property Current:TKlass read GetCurrent;
  end;

  TKlassList = class(TCollection)
  private
    FOwner:TComponent;
    FFullPath:string;
    FFiltersEnabled:boolean;
  private
    function GetItems(Index: integer): TKlass;
    procedure SetItems(Index: integer; AValue: TKlass);
  public
    constructor Create(AOwner:TComponent);
  public
    function Add: TKlass;
    function AddEx(AFullPath,AName:string): TKlass;
    procedure Clear;
    function GetEnumerator: TKlassEnumerator;
    function FindItemIndexByName(AName:string):integer;
    function FindItemByName(AName:string):TKlass;
    property Items[Index: integer]: TKlass read GetItems write SetItems; default;
    property Path:string read FFullPath write FFullPath;
  public
    procedure LoadFromPath(APath:string='\');//相对地址
    //procedure SaveToPath(APath:string='\');//暂未发现此方法的必要性

  public
    property FiltersEnabled:boolean read FFiltersEnabled write FFiltersEnabled;//如果为true，RecordFilter会以此为筛选条件（列表总开关）

  end;


implementation
uses rtfp_files;


{ TKlass }

constructor TKlass.Create(ACollection: TCollection);
begin
  if Assigned(ACollection) then
    inherited Create(ACollection)
  else raise Exception.Create('TKlass.Create: unassigned');
  FDbf:=TDbf.Create(nil);
end;

destructor TKlass.Destroy;
begin
  FDbf.Free;
  Inherited Destroy;
end;

{ TKlassEnumerator }

constructor TKlassEnumerator.Create(ACollection: TCollection);
begin
  if Assigned(ACollection) then
    inherited Create(ACollection)
  else raise Exception.Create('TKlassEnumerator.Create: unassigned');
end;

function TKlassEnumerator.GetCurrent:TKlass;
begin
  result:=inherited GetCurrent as TKlass;
end;

function TKlassEnumerator.MoveNext: Boolean;
begin
  result:=inherited MoveNext;
end;

{ TKlassList }

function TKlassList.GetItems(Index: integer): TKlass;
begin
  Result := TKlass(inherited Items[Index]);
end;

procedure TKlassList.SetItems(Index: integer; AValue: TKlass);
begin
  Items[Index].Assign(AValue);
end;

constructor TKlassList.Create(AOwner:TComponent);
begin
  inherited Create(TKlass);//why???
end;

function TKlassList.Add: TKlass;
begin
  Result := inherited Add as TKlass;
end;

function TKlassList.AddEx(AFullPath,AName:string): TKlass;
begin
  Result := inherited Add as TKlass;
  result.FFullPath:=AFullPath;
  result.FName:=AName;
  result.FDbf:=TDbf.Create(Self.FOwner);
end;

procedure TKlassList.Clear;
begin
  inherited Clear;
end;

function TKlassList.GetEnumerator:TKlassEnumerator;
begin
  Result := TKlassEnumerator.Create(Self);
end;

function TKlassList.FindItemIndexByName(AName:string):integer;
begin
  result:=0;
  while result<Count do begin
    if Items[result].Name=AName then exit;
    inc(result);
  end;
  result:=-1;
end;

function TKlassList.FindItemByName(AName:string):TKlass;
var index:integer;
begin
  index:=FindItemIndexByName(AName);
  if index<0 then result:=nil
  else result:=Items[index];
end;

procedure TKlassList.LoadFromPath(APath:string='\');
var tmpFileList:TRTFP_FileList;
    stmp:TCollectionItem;
    pathname,klassname:string;
begin
  assert(APath<>'','TRTFP_ClassList.LoadFromPath: APath=""');
  if APath='' then exit;
  Clear;
  tmpFileList:=TRTFP_FileList.Create(nil,FFullPath+'\'+APath);
  try
    tmpFileList.BaseDir:=FFullPath+'\'+APath;
    tmpFileList.RunDir;
    for stmp in tmpFileList do
      begin
        pathname:=(stmp as TRTFP_FileItem).Name;
        klassname:=ExtractFilename(pathname);
        if pos('.dbf',lowercase(pathname))<>length(pathname)-3 then continue;
        if pos('_run.dbf',lowercase(pathname))=length(pathname)-7 then continue;
        if lowercase(ExtractFileExt(klassname))='.dbf' then klassname:=Copy(klassname,1,length(klassname)-4);
        {if lowercase(ExtractFileExt(pathname))='.dbf' then }pathname:=Copy(pathname,1,length(pathname)-4);
        //ShowMessage(klassname+#13#10+pathname);
        Self.AddEx(APath+'\'+pathname,klassname);
      end;

  finally
    tmpFileList.Free;
  end;

end;

{
procedure TKlassList.SaveToPath(APath:string='\');
begin
  assert(APath<>'','TRTFP_ClassList.SaveToPath: APath=""');
  if APath='' then exit;

end;
}

end.

