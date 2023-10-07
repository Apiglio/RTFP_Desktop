unit rtfp_dataset_sorter;

{$mode objfpc}{$H+}
//{$define ListDialogTest}

interface

uses
  Classes, SysUtils,
  {$ifdef ListDialogTest}
  rtfp_dialog, rtfp_constants,
  {$endif}
  db;

type
  TDataSetSortMode = (smUnassigned,smAscending,smDescending);
  TDataSetSortOption = class
    FieldName:string;
    SortMode:TDataSetSortMode;
    NextOption:TObject;
  public
    constructor Create;
    destructor Destroy; override;
  public
    procedure Assign(AFieldName:string;AMode:TDataSetSortMode);
    procedure Clear;
  end;
  PDataSetSortFunc = function(Item1,Item2:Pointer;ds:TDataSet=nil;AOptions:TDataSetSortOption=nil):integer;
  PFuncPtrStr = function(ptr:Pointer):string;

  TSortingBinaryTree = class;
  TSortingBinaryTreeEnumerator = class
  private
    FCursor:TSortingBinaryTree;
  private
    procedure DownToLeftest;        //在初始化枚举和枚举右子节点时查找最小的节点
    function UpToFirstRight:boolean;//在没有右节点时向上查找第一个右边的节点
  public
    constructor Create(ARoot:TSortingBinaryTree);
    function GetCurrent:Pointer;
    function MoveNext:Boolean;
    property Current:Pointer read GetCurrent;
  end;

  TSortingBinaryTree = class
  private
    FItem:Pointer;
    FLeft:TSortingBinaryTree;
    FRight:TSortingBinaryTree;
    FParent:TSortingBinaryTree;
    FKind:Integer; //0表示是根节点 -1表示为父节点的左支 +1表示为父节点的右支
  public
    constructor Create;
    destructor Destroy;override;
    procedure AddItem(AItem:Pointer;ASortMethod:PDataSetSortFunc;ds:TDataSet=nil;AOptions:TDataSetSortOption=nil);
    function ExportToString(AMethod:PFuncPtrStr):string;
  public
    function GetEnumerator:TSortingBinaryTreeEnumerator;
  end;

procedure SortDataSet(ds:TDataSet;DSSOption:TDataSetSortOption);

implementation

{ TDataSetSortOption }

constructor TDataSetSortOption.Create;
begin
  inherited Create;
  NextOption:=nil;
  FieldName:='';
  SortMode:=smUnassigned;
end;

destructor TDataSetSortOption.Destroy;
begin
  if Assigned(NextOption) then (NextOption as TDataSetSortOption).Free;
  inherited Destroy;
end;

procedure TDataSetSortOption.Assign(AFieldName:string;AMode:TDataSetSortMode);
var tmpDataSetSortOption:TDataSetSortOption;
begin
  if SortMode=smUnassigned then begin
    FieldName:=AFieldName;
    SortMode:=AMode;
  end else begin
    tmpDataSetSortOption:=TDataSetSortOption.Create;
    NextOption:=tmpDataSetSortOption;
    (NextOption as TDataSetSortOption).Assign(AFieldName,AMode);
  end;
end;

procedure TDataSetSortOption.Clear;
begin
  if not Assigned(NextOption) then begin
    SortMode:=smUnassigned;
  end else begin
    (NextOption as TDataSetSortOption).Clear;
    (NextOption as TDataSetSortOption).Free;
  end;
end;

{ TSortingBinaryTreeEnumerator }

procedure TSortingBinaryTreeEnumerator.DownToLeftest;
var tmpNode:TSortingBinaryTree;
begin
  tmpNode := FCursor;
  while tmpNode.FLeft <> nil do tmpNode := tmpNode.FLeft;
  FCursor := tmpNode;
end;

function TSortingBinaryTreeEnumerator.UpToFirstRight:boolean;
var tmpNode:TSortingBinaryTree;
begin
  result  := false;
  tmpNode := FCursor;
  while tmpNode.FKind>0 do begin
    tmpNode := tmpNode.FParent;
    if tmpNode = nil then exit;
  end;
  if tmpNode.FKind = 0 then exit;
  FCursor := tmpNode.FParent;
  result  := true;
end;

constructor TSortingBinaryTreeEnumerator.Create(ARoot:TSortingBinaryTree);
begin
  inherited Create;
  FCursor  := ARoot;
  DownToLeftest;
end;

function TSortingBinaryTreeEnumerator.GetCurrent:Pointer;
begin
  result := FCursor.FItem;
end;

function TSortingBinaryTreeEnumerator.MoveNext:Boolean;
begin
  if FCursor.FRight = nil then begin
    result := UpToFirstRight;
  end else begin
    FCursor := FCursor.FRight;
    DownToLeftest;
    result  := true;
  end;
end;


{ SortingBinaryTree }

constructor TSortingBinaryTree.Create;
begin
  inherited Create;
  FLeft:=nil;
  FRight:=nil;
  FItem:=nil;
  FParent:=nil;
  FKind:=0;
end;

destructor TSortingBinaryTree.Destroy;
begin
  if FLeft<>nil then FreeAndNil(FLeft);
  if FRight<>nil then FreeAndNil(FRight);
  inherited Destroy;
end;

procedure TSortingBinaryTree.AddItem(AItem:Pointer;ASortMethod:PDataSetSortFunc;ds:TDataSet=nil;AOptions:TDataSetSortOption=nil);
begin
  if FItem=nil then begin
    FItem:=AItem;
    exit;
  end;
  case ASortMethod(AItem,FItem,ds,AOptions) of
    -1:begin
      if FRight=nil then begin
        FRight:=TSortingBinaryTree.Create;
        (FRight as TSortingBinaryTree).FItem:=AItem;
        (FRight as TSortingBinaryTree).FKind:=+1;
        (FRight as TSortingBinaryTree).FParent:=Self;
      end
      else (FRight as TSortingBinaryTree).AddItem(AItem,ASortMethod,ds,AOptions);
    end;
    else begin
      if FLeft=nil then begin
        FLeft:=TSortingBinaryTree.Create;
        (FLeft as TSortingBinaryTree).FItem:=AItem;
        (FLeft as TSortingBinaryTree).FKind:=-1;
        (FLeft as TSortingBinaryTree).FParent:=Self;
      end
      else (FLeft as TSortingBinaryTree).AddItem(AItem,ASortMethod,ds,AOptions);
    end;
  end;
end;

function TSortingBinaryTree.ExportToString(AMethod:PFuncPtrStr):string;
var s1,s2:string;
begin
  s1:='null';
  s2:='null';
  if FLeft<>nil then
    s1:=TSortingBinaryTree(FLeft).ExportToString(AMethod);
  if FRight<>nil then
    s2:=TSortingBinaryTree(FRight).ExportToString(AMethod);
  if (s1=s2) and (s1='null') then result:=AMethod(FItem)
  else result:='{'+AMethod(FItem)+':['+s1+','+s2+']}';
end;

function TSortingBinaryTree.GetEnumerator:TSortingBinaryTreeEnumerator;
begin
  Result:=TSortingBinaryTreeEnumerator.Create(Self);
end;

function Intern_DSSortMethod(Item1,Item2:Pointer;ds:TDataSet=nil;AOptions:TDataSetSortOption=nil):integer;
var tmpDSSOption:TDataSetSortOption;
    v1,v2:Variant;
    reverse,fs,fi:integer;
    no_field:boolean;
begin
  result:=0;
  tmpDSSOption:=AOptions;
  while true do begin
    if tmpDSSOption=nil then exit;
    fs:=ds.FieldCount;
    no_field:=true;
    for fi:=0 to fs-1 do if ds.FieldDefs.Items[fi].Name=tmpDSSOption.FieldName then begin no_field:=false;break;end;
    if no_field then begin
      tmpDSSOption:=tmpDSSOption.NextOption as TDataSetSortOption;
      continue;
    end;
    if tmpDSSOption.SortMode<>smAscending then reverse:=1
    else reverse:=-1;
    ds.RecNo:=plongint(Item1)^+1;
    v1:=ds.FieldByName(tmpDSSOption.FieldName).AsVariant;
    ds.RecNo:=plongint(Item2)^+1;
    v2:=ds.FieldByName(tmpDSSOption.FieldName).AsVariant;
    if v1=v2 then begin
      tmpDSSOption:=tmpDSSOption.NextOption as TDataSetSortOption;
      continue;
    end;
    if v1>v2 then result:=reverse else result:=-reverse;
    exit;
  end;
end;

function temp_intern_ptr_str(ptr:Pointer):string;
begin
  result:=IntToStr(pLongint(ptr)^);
end;

procedure SortDataSet(ds:TDataSet;DSSOption:TDataSetSortOption);
var index,index_sub,field_no,dssize,fdcount:longint;
    binary_tree_sort:TSortingBinaryTree;
    order,fixed_order:array of longint;
    field_var:array of Variant;
    ptr:Pointer;

begin
  if DSSOption=nil then exit;
  dssize:=ds.RecordCount;
  if dssize<=1 then exit;
  fdcount:=ds.FieldCount;

  binary_tree_sort:=TSortingBinaryTree.Create;
  SetLength(order,dssize);
  SetLength(fixed_order,dssize);
  SetLength(field_var,fdcount);
  for index:=0 to dssize-1 do fixed_order[index]:=index;//0就是nil，nil就相当于没有，还得整这一出。
  try
    for index:=0 to dssize-1 do begin
      binary_tree_sort.AddItem(@(fixed_order[index]),@Intern_DSSortMethod,ds,DSSOption);
    end;
    index:=0;
    for ptr in binary_tree_sort do begin
      order[index]:=plongint(ptr)^+1;
      inc(index);
    end;
    for index:=0 to dssize-1 do begin
      ds.RecNo:=order[index];
      for field_no:=0 to fdcount-1 do field_var[field_no]:=ds.Fields[field_no].AsVariant;
      ds.Append;
      for field_no:=0 to fdcount-1 do ds.Fields[field_no].AsVariant:=field_var[field_no];
      ds.Post;
      ds.RecNo:=order[index];
      ds.Delete;
      for index_sub:=index+1 to dssize-1 do
        if order[index_sub]>=order[index] then
          dec(order[index_sub]);
    end;

  finally
    binary_tree_sort.Free;
    SetLength(order,0);
    SetLength(fixed_order,0);
  end;
end;

end.

