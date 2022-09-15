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

  TSortingBinaryTreeEnumerator = class
  private
    FRoot:TObject;
    FList:TList;
    FPosition:integer;
  private
    procedure Recursion(ANode:TObject);
  public
    constructor Create(ARoot:TObject);
    function GetCurrent:Pointer;
    function MoveNext:Boolean;
    property Current:Pointer read GetCurrent;
  end;

  TSortingBinaryTree = class
  public
    Item:Pointer;
    Left:TObject;
    Right:TObject;
  public
    constructor Create;
    destructor Destroy;override;
    procedure Compare(AItem:Pointer;ASortMethod:PDataSetSortFunc;ds:TDataSet=nil;AOptions:TDataSetSortOption=nil);
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
var tmpDataSetSortOption:TDataSetSortOption;
begin
  if not Assigned(NextOption) then begin
    SortMode:=smUnassigned;
  end else begin
    (NextOption as TDataSetSortOption).Clear;
    (NextOption as TDataSetSortOption).Free;
  end;
end;

{ TSortingBinaryTreeEnumerator }

procedure TSortingBinaryTreeEnumerator.Recursion(ANode:TObject);
var tmpNode:TSortingBinaryTree;
begin
  tmpNode:=ANode as TSortingBinaryTree;
  if tmpNode.Left<>nil then Recursion(tmpNode.Left);
  FList.Add(tmpNode.Item);
  if tmpNode.Right<>nil then Recursion(tmpNode.Right);
end;

constructor TSortingBinaryTreeEnumerator.Create(ARoot:TObject);
begin
  inherited Create;
  FList:=TList.Create;
  FRoot:=ARoot;
  Recursion(ARoot);
  FPosition:=-1;
end;

function TSortingBinaryTreeEnumerator.GetCurrent:Pointer;
begin
  result:=FList.Items[FPosition]
end;

function TSortingBinaryTreeEnumerator.MoveNext:Boolean;
begin
  result:=true;
  inc(FPosition);
  if FPosition<FList.Count then exit;
  FList.Free;//返回false时释放FList内存
  result:=false;
end;


{ SortingBinaryTree }

constructor TSortingBinaryTree.Create;
begin
  inherited Create;
  Left:=nil;
  Right:=nil;
  Item:=nil;
end;

destructor TSortingBinaryTree.Destroy;
begin
  if Left<>nil then FreeAndNil(Left);
  if Right<>nil then FreeAndNil(Right);
  inherited Destroy;
end;

procedure TSortingBinaryTree.Compare(AItem:Pointer;ASortMethod:PDataSetSortFunc;ds:TDataSet=nil;AOptions:TDataSetSortOption=nil);
begin
  if Item=nil then begin
    Item:=AItem;
    exit;
  end;
  case ASortMethod(AItem,Item,ds,AOptions) of
    -1:begin
      if Right=nil then begin
        Right:=TSortingBinaryTree.Create;
        (Right as TSortingBinaryTree).Item:=AItem;
      end
      else (Right as TSortingBinaryTree).Compare(AItem,ASortMethod,ds,AOptions);
    end;
    else begin
      if Left=nil then begin
        Left:=TSortingBinaryTree.Create;
        (Left as TSortingBinaryTree).Item:=AItem;
      end
      else (Left as TSortingBinaryTree).Compare(AItem,ASortMethod,ds,AOptions);
    end;
  end;
end;

function TSortingBinaryTree.ExportToString(AMethod:PFuncPtrStr):string;
var s1,s2:string;
begin
  s1:='null';
  s2:='null';
  if Left<>nil then
    s1:=TSortingBinaryTree(Left).ExportToString(AMethod);
  if Right<>nil then
    s2:=TSortingBinaryTree(Right).ExportToString(AMethod);
  if (s1=s2) and (s1='null') then result:=AMethod(Item)
  else result:='{'+AMethod(Item)+':['+s1+','+s2+']}';
end;

function TSortingBinaryTree.GetEnumerator:TSortingBinaryTreeEnumerator;
begin
  Result:=TSortingBinaryTreeEnumerator.Create(Self);
end;

function Intern_DSSortMethod(Item1,Item2:Pointer;ds:TDataSet=nil;AOptions:TDataSetSortOption=nil):integer;
var tmpDSSOption:TDataSetSortOption;
    v1,v2:Variant;
    reverse:integer;
begin
  result:=0;
  tmpDSSOption:=AOptions;
  while true do begin
    if tmpDSSOption=nil then exit;
    if ds.FieldByName(tmpDSSOption.FieldName)=nil then begin
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
    {$ifdef ListDialogTest}
    tmpStrList:TStringList;
    {$endif}

begin
  if DSSOption=nil then exit;
  dssize:=ds.RecordCount;
  if dssize<=1 then exit;
  fdcount:=ds.FieldCount;

  binary_tree_sort:=TSortingBinaryTree.Create;
  {$ifdef ListDialogTest}
  tmpStrList:=TStringList.Create;
  {$endif}
  SetLength(order,dssize);
  SetLength(fixed_order,dssize);
  SetLength(field_var,fdcount);
  for index:=0 to dssize-1 do fixed_order[index]:=index;//0就是nil，nil就相当于没有，还得整这一出。
  try
    for index:=0 to dssize-1 do begin
      binary_tree_sort.Compare(@(fixed_order[index]),@Intern_DSSortMethod,ds,DSSOption);
    end;
    index:=0;
    for ptr in binary_tree_sort do begin
      order[index]:=plongint(ptr)^+1;
      {$ifdef ListDialogTest}
      ds.RecNo:=plongint(ptr)^+1;
      tmpStrList.Add('CunID['+IntToStr(order[index])+']'+ds.FieldByName('编号(村落属性)').AsString);
      {$endif}
      inc(index);
    end;
    {$ifdef ListDialogTest}
    ShowMsgEdit('','',binary_tree_sort.ExportToString(@temp_intern_ptr_str));
    ShowMsgList('主表排序测试','sort_dateset_list: ',tmpStrList);
    {$endif}
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
    {$ifdef ListDialogTest}
    tmpStrList.Free;
    {$endif}
  end;
end;

end.

