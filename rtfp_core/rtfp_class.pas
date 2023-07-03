unit rtfp_class;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dbf, rtfp_constants, db, BufDataset;

type

  TKlassList = class;

  TKlass = class(TCollectionItem)
  private
    FName,FFullPath:string;
    FDbf:{TDbf}TDataSet;
    FFilterEnabled:boolean;
  public
    property Name:string read FName;
    property FullPath:string read FFullPath;
    property Dbf:{Tdbf}TDataSet read FDbf;
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
    function GetItems(Index: integer):TKlass;
    procedure SetItems(Index: integer;AValue: TKlass);
  public
    constructor Create(AOwner:TComponent);
  public
    function Add:TKlass;
    function AddEx(AFullPath,AName:string;data_set_type:string='dbf'):TKlass;
    procedure Clear;
    function GetEnumerator:TKlassEnumerator;
    function FindItemIndexByName(AName:string):integer;
    function FindItemByName(AName:string):TKlass;
    function AllUnChecked:boolean;
    property Items[Index:integer]:TKlass read GetItems write SetItems; default;
    property Path:string read FFullPath write FFullPath;
  public
    procedure LoadFromPath(APath:string='/';data_set_type:string='dbf');//相对地址
    //procedure SaveToPath(APath:string='/');//暂未发现此方法的必要性

  public
    property FiltersEnabled:boolean read FFiltersEnabled write FFiltersEnabled;//如果为true，RecordFilter会以此为筛选条件（列表总开关）

  end;


implementation
uses rtfp_files, RegExpr;


{ TKlass }

constructor TKlass.Create(ACollection: TCollection);
begin
  if Assigned(ACollection) then
    inherited Create(ACollection)
  else raise Exception.Create('TKlass.Create: unassigned');
  //FDbf:=TDbf.Create(nil);//同样不在此处创建，改到addEx中
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

function TKlassList.AddEx(AFullPath,AName:string;data_set_type:string='dbf'): TKlass;
begin
  Result := inherited Add as TKlass;
  result.FFullPath:=AFullPath;
  result.FName:=AName;
  case data_set_type of
    'dbf':result.FDbf:=TDbf.Create(Self.FOwner);
    'buf':result.FDbf:=TBufDataset.Create(Self.FOwner);
  end;
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

function TKlassList.AllUnChecked:boolean;
var pi:integer;
begin
  result:=true;
  for pi:=0 to Count-1 do
    begin
      if Items[pi].FilterEnabled then
        begin
          result:=false;
          exit;
        end;
    end;
end;

procedure TKlassList.LoadFromPath(APath:string='/';data_set_type:string='dbf');
var tmpFileList:TRTFP_FileList;
    stmp:TCollectionItem;
    pathname,klassname:string;
    regexp:TRegExpr;
begin
  assert(APath<>'','TAttrsGroupList.LoadFromPath: APath=""');
  if APath='' then exit;
  Clear;
  tmpFileList:=TRTFP_FileList.Create(nil,FFullPath+'/'+APath);
  regexp:=TRegExpr.Create;
  case data_set_type of
    'dbf':regexp.Expression:='[^_run]\.dbf$';
    'buf':regexp.Expression:='\S\.buf$';
  end;
  try
    {}tmpFileList.BaseDir:=FFullPath+'/'+APath;
    tmpFileList.RunDir;
    for stmp in tmpFileList do
      begin
        pathname:=(stmp as TRTFP_FileItem).Name;
        if not regexp.Exec(pathname) then continue;
        klassname:=ExtractFilename(pathname);

        System.delete(klassname,length(klassname)-3,4);
        System.delete(pathname,length(pathname)-3,4);
        Self.AddEx(APath+'/'+pathname,klassname,data_set_type);

      end;
  finally
    tmpFileList.Free;
    regexp.Free;
  end;

end;


{
procedure TKlassList.SaveToPath(APath:string='/');
begin
  assert(APath<>'','TRTFP_ClassList.SaveToPath: APath=""');
  if APath='' then exit;

end;
}

end.

