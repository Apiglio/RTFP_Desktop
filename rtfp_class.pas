unit rtfp_class;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dbf;

type

  TRTFP_ClassList = class;

  TRTFP_ClassItem = class(TCollectionItem)
  private
    FName,FFullPath:string;
    FDbf:TDbf;
  public
    property Name:string read FName;
    property FullPath:string read FFullPath;
    property Dbf:Tdbf read FDbf;
  public
    constructor Create(ACollection:TCollection);override;
    destructor Destroy;override;
  end;


  TRTFP_ClassEnumerator = class(TCollectionEnumerator)
  private
    FCollection: TRTFP_ClassList;
    FPosition: Integer;
  public
    constructor Create(ACollection: TCollection);
    function GetCurrent:string;
    function MoveNext: Boolean;
    property Current:string read GetCurrent;
  end;

  TRTFP_ClassList = class(TCollection)
  private
    FOwner:TComponent;
    FFullPath:string;
  private
    function GetItems(Index: integer): TRTFP_ClassItem;
    procedure SetItems(Index: integer; AValue: TRTFP_ClassItem);
  public
    constructor Create(AOwner:TComponent);
  public
    function Add: TRTFP_ClassItem;
    function AddEx(AFullPath,AName:string): TRTFP_ClassItem;
    procedure Clear;
    function GetEnumerator: TRTFP_ClassEnumerator;
    function FindItemIndexByName(AName:string):integer;
    property Items[Index: integer]: TRTFP_ClassItem read GetItems write SetItems; default;
    property Path:string read FFullPath write FFullPath;
  public
    procedure LoadFromPath(APath:string='\');//相对地址
    //procedure SaveToPath(APath:string='\');//暂未发现此方法的必要性

  end;


implementation
uses rtfp_files;


{ TRTFP_ClassItem }

constructor TRTFP_ClassItem.Create(ACollection: TCollection);
begin
  if Assigned(ACollection) then
    inherited Create(ACollection)
  else raise Exception.Create('TRTFP_ClassItem.Create: unassigned');
  FDbf:=TDbf.Create(nil);
end;

destructor TRTFP_ClassItem.Destroy;
begin
  FDbf.Free;
  Inherited Destroy;
end;

{ TRTFP_ClassEnumerator }

constructor TRTFP_ClassEnumerator.Create(ACollection: TCollection);
begin
  if Assigned(ACollection) then
    inherited Create(ACollection)
  else raise Exception.Create('TRTFP_ClassEnumerator.Create: unassigned');
end;

function TRTFP_ClassEnumerator.GetCurrent:string;
begin
  result:=(inherited GetCurrent as TRTFP_ClassItem).FFullPath;
end;

function TRTFP_ClassEnumerator.MoveNext: Boolean;
begin
  result:=inherited MoveNext;
end;

{ TRTFP_ClassList }

function TRTFP_ClassList.GetItems(Index: integer): TRTFP_ClassItem;
begin
  Result := TRTFP_ClassItem(inherited Items[Index]);
end;

procedure TRTFP_ClassList.SetItems(Index: integer; AValue: TRTFP_ClassItem);
begin
  Items[Index].Assign(AValue);
end;

constructor TRTFP_ClassList.Create(AOwner:TComponent);
begin
  inherited Create(TRTFP_ClassItem);
end;

function TRTFP_ClassList.Add: TRTFP_ClassItem;
begin
  Result := inherited Add as TRTFP_ClassItem;
end;

function TRTFP_ClassList.AddEx(AFullPath,AName:string): TRTFP_ClassItem;
begin
  Result := inherited Add as TRTFP_ClassItem;
  result.FFullPath:=AFullPath;
  result.FName:=AName;
  result.FDbf:=TDbf.Create(Self.FOwner);
end;

procedure TRTFP_ClassList.Clear;
begin
  inherited Clear;
end;

function TRTFP_ClassList.GetEnumerator:TRTFP_ClassEnumerator;
begin
  Result := TRTFP_ClassEnumerator.Create(Self);
end;

function TRTFP_ClassList.FindItemIndexByName(AName:string):integer;
begin
  result:=0;
  while result<Count do begin
    if Items[result].Name=AName then exit;
    inc(result);
  end;
  result:=-1;
end;

procedure TRTFP_ClassList.LoadFromPath(APath:string='\');
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
        if lowercase(ExtractFileExt(klassname))='.dbf' then klassname:=Copy(klassname,1,length(klassname)-4);
        if lowercase(ExtractFileExt(pathname))='.dbf' then pathname:=Copy(pathname,1,length(pathname)-4);
        //ShowMessage(klassname+#13#10+pathname);
        Self.AddEx(pathname,klassname);
      end;

  finally
    tmpFileList.Free;
  end;

end;

{
procedure TRTFP_ClassList.SaveToPath(APath:string='\');
begin
  assert(APath<>'','TRTFP_ClassList.SaveToPath: APath=""');
  if APath='' then exit;

end;
}

end.

