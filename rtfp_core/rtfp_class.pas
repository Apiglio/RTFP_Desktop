unit rtfp_class;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, dbf, db, BufDataset,
  rtfp_constants, rtfp_type;

type

  TKlassList = class;

  TKlass = class
  private
    FName,FPath,FKlassDir:string;
    FDbf:TDataSet;
    FFilterEnabled:boolean;
    FSubKlassShown:boolean;
    FKlassList:TKlassList;
    FParentKlass:TKlass;//如果为nil表示就在class目录之下
    FDataSetType:TRTFP_DataSetType;
  public
    function FullPath(ProjectPath:string):string;
  public
    property Name:string read FName;
    property Path:string read FPath;
    property KlassDir:string read FKlassDir write FKlassDir;
    property Dbf:TDataSet read FDbf;
    property FilterEnabled:boolean read FFilterEnabled write FFilterEnabled;//如果为true，RecordFilter会以此为筛选条件
    property SubKlassShown:boolean read FSubKlassShown write FSubKlassShown;//如果为true，在分类列表中会显示下属的分类
    property KlassList:TKlassList read FKlassList;
    property ParentKlass:TKlass read FParentKlass;
  public
    function KlassNameWithDelimiter(Delimiter:Char):string;
    function AllUnChecked:boolean;
  public
    constructor Create(data_set_type:TRTFP_DataSetType);
    destructor Destroy;override;
  end;


  TKlassEnumerator = class
  private
    FCollection: TList;
    FPosition: Integer;
  public
    constructor Create(AKlassList: TKlassList);
    function GetCurrent:TKlass;
    function MoveNext: Boolean;
    property Current:TKlass read GetCurrent;
  end;

  TKlassList = class
  private
    FList:TList;
    FOwner:TKlass;
    FKlassDir:string;
    FFiltersEnabled:boolean;
    FDataSetType:TRTFP_DataSetType;
  private
    function GetItems(Index: integer):TKlass;
    procedure SetItems(Index: integer;AValue: TKlass);
    function GetCount:Integer;
    function GetRecursiveCount:Integer;
  public
    constructor Create(AOwner:TKlass;data_set_type:TRTFP_DataSetType);
    destructor Destroy; override;
  public
    function Add(AName:string;data_set_type:TRTFP_DataSetType):TKlass;
    function Remove(AKlass:TKlass):boolean;
    procedure Clear;
    function GetEnumerator:TKlassEnumerator;
    function FindItemIndexByName(AName:string):integer;
    function FindItemByName(AName:string):TKlass;
    function AllUnChecked:boolean;
    property Items[Index:integer]:TKlass read GetItems write SetItems; default;
    property Count:Integer read GetCount;
    property RecursiveCount:Integer read GetRecursiveCount;
    property KlassDir:string read FKlassDir write FKlassDir;
    property Owner:TKlass read FOwner;
  public
    procedure LoadFromPath;

  public
    property FiltersEnabled:boolean read FFiltersEnabled write FFiltersEnabled;//如果为true，RecordFilter会以此为筛选条件（列表总开关）

  end;


implementation
uses rtfp_files, RegExpr;


{ TKlass }

function TKlass.FullPath(ProjectPath:string):string;
begin
  result:=FKlassDir;
  if FPath<>'' then result:=result+'/'+FPath;
  result:=result+'/'+FName;
  System.Delete(result,1,Length(ProjectPath));
end;

function TKlass.KlassNameWithDelimiter(Delimiter:Char):string;
begin
  result:=Name;
  if FParentKlass<>nil then result:=FParentKlass.KlassNameWithDelimiter(Delimiter)+Delimiter+result;
end;

function TKlass.AllUnChecked:boolean;
var tmpKL:TKlass;
begin
  result:=false;
  for tmpKL in FKlassList do begin
    if tmpKL.FilterEnabled then exit;
  end;
  result:=true;
end;

constructor TKlass.Create(data_set_type:TRTFP_DataSetType);
begin
  inherited Create;
  FKlassList:=TKlassList.Create(Self,data_set_type);
  FKlassList.KlassDir:=FKlassDir;
  FParentKlass:=nil;
  case data_set_type of
    dstDBF:FDbf:=TDbf.Create(nil);
    dstBUF:FDbf:=TBufDataset.Create(nil);
    else raise Exception.Create('TKlass.Create: invalid data_set_type.')
  end;
end;

destructor TKlass.Destroy;
begin
  FDbf.Free;
  FKlassList.Free;
  Inherited Destroy;
end;

{ TKlassEnumerator }

procedure RecurKlassList(dst:TList;src:TKlassList);
var pi:integer;
begin
  pi:=0;
  while pi<src.Count do begin
    dst.Add(src.Items[pi]);
    RecurKlassList(dst,src.Items[pi].FKlassList);
    inc(pi);
  end;
end;

constructor TKlassEnumerator.Create(AKlassList: TKlassList);
begin
  FCollection:=TList.Create;
  RecurKlassList(FCollection, AKlassList);
  FPosition:=-1;
end;

function TKlassEnumerator.GetCurrent:TKlass;
begin
  result:=TKlass(FCollection.Items[FPosition]);
end;

function TKlassEnumerator.MoveNext: Boolean;
begin
  inc(FPosition);
  result:=FPosition<FCollection.Count;
  if not result then FCollection.Free;
end;

{ TKlassList }

function TKlassList.GetItems(Index: integer): TKlass;
begin
  result:=TKlass(FList.Items[Index]);
end;

procedure TKlassList.SetItems(Index: integer; AValue: TKlass);
begin
  TKlass(FList.Items[Index]).Free;
  FList.Items[Index]:=AValue;
  //会用到吗？
end;

function TKlassList.GetCount:Integer;
begin
  result:=FList.Count;
end;

function TKlassList.GetRecursiveCount:Integer;
var idx:integer;
begin
  result:=FList.Count;
  idx:=0;
  while idx<FList.Count do begin
    result:=result+TKlass(FList[idx]).FKlassList.RecursiveCount;
    inc(idx);
  end;
end;

constructor TKlassList.Create(AOwner:TKlass;data_set_type:TRTFP_DataSetType);
begin
  inherited Create;
  FList:=TList.Create;
  FKlassDir:='';
  FOwner:=AOwner;
  FDataSetType:=data_set_type;
end;

destructor TKlassList.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

function TKlassList.Add(AName:string;data_set_type:TRTFP_DataSetType): TKlass;
begin
  result:=TKlass.Create(data_set_type);
  result.FKlassDir:=FKlassDir;
  result.FKlassList.FKlassDir:=FKlassDir;
  if FOwner=nil then begin
    result.FPath:='';
  end else begin
    result.FPath:=FOwner.FName;
    if FOwner.FPath<>'' then result.FPath:=FOwner.FPath+'/'+result.FPath;
  end;
  result.FParentKlass:=FOwner;
  result.FName:=AName;
  result.FParentKlass:=FOwner;
  FList.Add(result);
end;

function TKlassList.Remove(AKlass:TKlass):boolean;
begin
  result:=FList.Remove(AKlass)>=0;
end;

procedure TKlassList.Clear;
begin
  while FList.Count>0 do begin
    TKlass(FList.Items[0]).Free;
    FList.Delete(0);
  end;
end;

function TKlassList.GetEnumerator:TKlassEnumerator;
begin
  result:=TKlassEnumerator.Create(Self);
end;

function TKlassList.FindItemIndexByName(AName:string):integer;
begin
  result:=0;
  while result<FList.Count do begin
    if TKlass(FList.Items[result]).Name=AName then exit;
    inc(result);
  end;
  result:=-1;
end;

function TKlassList.FindItemByName(AName:string):TKlass;
var index:integer;
begin
  index:=FindItemIndexByName(AName);
  if index<0 then result:=nil
  else result:=TKlass(FList.Items[index]);
end;

function TKlassList.AllUnChecked:boolean;
var pi:integer;
    tmpKL:TKlass;
begin
  result:=false;
  for pi:=0 to FList.Count-1 do begin
    tmpKL:=TKlass(FList.Items[pi]);
    if tmpKL.FilterEnabled then exit;
    if not tmpKL.AllUnChecked then exit;
  end;
  result:=true;
end;

procedure TKlassList.LoadFromPath;
var search_path,file_path,pathname,klassname:string;
    regexp:TRegExpr;
    FileList:TStringList;
    tmpKL:TKlass;
begin
  Clear;
  search_path:=FKlassDir;
  if FOwner<>nil then begin
    if FOwner.FPath<>'' then search_path:=search_path+'/'+FOwner.FPath;
    search_path:=search_path+'/'+FOwner.FName;
  end;

  regexp:=TRegExpr.Create;
  case FDataSetType of
    dstDBF:regexp.Expression:='[^_run]\.dbf$';
    dstBUF:regexp.Expression:='\S\.buf$';
  end;
  FileList:=TStringList.Create;
  try
    FindAllFiles(FileList,search_path,'',false,faAnyFile);
    for file_path in FileList do begin
      if not regexp.Exec(file_path) then continue;
      klassname:=ExtractFilename(file_path);
      System.delete(klassname,length(klassname)-3,4);
      Self.Add(klassname,FDataSetType);
    end;
    FileList.Clear;
    FindAllDirectories(FileList,search_path,false);
    for file_path in FileList do begin
      klassname:=ExtractFilename(file_path);
      if pos('.',klassname)>0 then continue;
      tmpKL:=FindItemByName(klassname);
      if tmpKL=nil then tmpKL:=Self.Add(klassname,FDataSetType);
      tmpKL.FKlassList.LoadFromPath;
    end;
  finally
    FileList.Free;
    regexp.Free;
  end;

end;

end.

