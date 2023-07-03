// 计划要做单独字段管理
// 开始给每一个attrs一个单独的modified属性，需要在definition.pas里实现


unit rtfp_field;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, dbf, fpjson, rtfp_constants, Graphics, BufDataset;

type

  TAttrsFieldList = class;
  TAttrsGroup = class;
  TAttrsGroupList = class;

  TColorizeProcess = function(v1,v2:double;c1,c2:TColor;expresion:string;Value:TField):TColor;
  TFIeldDisplayMode = (fdmDisabled=0, fdmSuccessive=1, fdmIdentical=2, fdmRegexpr=3);
  TFieldDisplayOption = class
  private
    FMode:TFIeldDisplayMode;
    FDispWidth:integer;
    FDispName:string;
    FValues:TStringList;
    FColors:TList;
    FFloats:array of double;//仅用于fdmSuccessive的颜色获取，在CheckSuccessive中更新
  private
    function CheckSuccessive:boolean;
  protected
    function GetValue(index:integer):string;
    function GetColor(index:integer):TColor;
    procedure SetValue(index:integer;value:string);
    procedure SetColor(index:integer;color:TColor);
    function GetCount:integer;
  public
    procedure InsertValue(index:integer;value:string);
    procedure InsertColor(index:integer;color:TColor);
    procedure DeleteValue(index:integer);
    procedure DeleteColor(index:integer);
    property Values[index:integer]:string read GetValue write SetValue;
    property Colors[index:integer]:TColor read GetColor write SetColor;
    property Mode:TFIeldDisplayMode read FMode write FMode;
    property Count:integer read GetCount;
    property DispName:string read FDispName write FDispName;
    property DispWidth:integer read FDispWidth write FDispWidth;
  public
    procedure Assign(source:TFieldDisplayOption);
    procedure Clear;
    procedure LoadFromJSON(str:string);
    function ExportToJSON:TJSONData;
    function SaveToJSON:string;
    function GetFieldColor(Value:TField):TColor;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TAttrsField = class(TCollectionItem)
  private
    FFieldName:string;
    FFieldDef:TFieldDef;
    FAttrsGroup:TAttrsGroup;
    FShown:boolean;
    FOnChangeVisibility:TNotifyEvent;
    FUpdating:boolean;
    FComboItem:TStringList;
  public//暂时改成公共
    FFieldDisplayOption:TFieldDisplayOption;
  protected
    procedure SetShown(value:boolean);
    function GetDisplayName:string;
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;

    property Shown:boolean read FShown write SetShown;
    property OnChangeVisibility:TNotifyEvent read FOnChangeVisibility write FOnChangeVisibility;
    property FieldDef:TFieldDef read FFieldDef;
    property FieldName:string read FFieldName write FFieldName;
    property AttrsGroup:TAttrsGroup read FAttrsGroup;
    property FieldDisplayOption:TFieldDisplayOption read FFieldDisplayOption{ write FFieldDisplayOption};
    property DisplayName:string read GetDisplayName;

  public
    procedure ResetFieldDef(AFieldDef:TFieldDef);

  protected
    function GetIsCombo:boolean;
  public
    procedure ClearCombo;
    procedure AddCombo(Item:string);
    property IsCombo:boolean read GetIsCombo;
    property ComboItem:TStringList read FComboItem write FComboItem;
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
    FDisplayName:string;
    FDbf:{TDbf}TDataSet;
    FFieldList:TAttrsFieldList;
    FGroupShown:boolean;
    FModified:boolean;
  protected
    function GetIsEmpty:boolean;
  public
    property Name:string read FName;
    property DisplayName:string read FDisplayName write FDisplayName;
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
    procedure Rename(ANewName:string);
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
    procedure LoadFromPath(APath:string='/';data_set_type:string='dbf');//相对地址
  end;


implementation
uses rtfp_files, rtfp_misc, RegExpr;
var display_reg:TRegexpr;

{ TFieldDisplayOption }

function TFieldDisplayOption.CheckSuccessive:boolean;
var pi,len:integer;
begin
  //这个函数并没有搞得很清楚，没有涉及排序和实时的数据更新
  //目前只在Assign和LoadFromJSON的末尾进行一次
  //0.2.5-alpha.2
  result:=true;
  SetLength(FFloats,0);
  len:=FValues.Count;
  SetLength(FFloats,len);
  try
    for pi:=0 to len-1 do FFloats[pi]:=StrToFloat(FValues[pi]);
  except
    result:=false;
  end;
end;

function TFieldDisplayOption.GetValue(index:integer):string;
begin
  if index<FValues.Count then result:=FValues[index]
  else result:='';
end;

function TFieldDisplayOption.GetColor(index:integer):TColor;
begin
  if index<FColors.Count then result:=TColor(pdword(FColors[index]))
  else result:=$ff000000;
end;

procedure TFieldDisplayOption.SetValue(index:integer;value:string);
begin
  if index<FValues.Count then FValues[index]:=value;
end;

procedure TFieldDisplayOption.SetColor(index:integer;color:TColor);
begin
  if index<FColors.Count then FColors[index]:=pdword(color);
end;

function TFieldDisplayOption.GetCount:integer;
var lv,lc:integer;
begin
  lv:=FValues.Count;
  lc:=FColors.Count;
  if lv<lc then result:=lv
  else result:=lc;
end;

procedure TFieldDisplayOption.InsertValue(index:integer;value:string);
var len:integer;
begin
  len:=FValues.Count;
  if (index<0) or (index>len) then
    raise Exception.Create('TFieldDisplayOption: InsertValue index('+IntToStr(index)+')下标超界。')
  else
    FValues.Insert(index,value);
end;

procedure TFieldDisplayOption.InsertColor(index:integer;color:TColor);
var len:integer;
begin
  len:=FColors.Count;
  if (index<0) or (index>len) then
    raise Exception.Create('TFieldDisplayOption: InsertColor index('+IntToStr(index)+')下标超界。')
  else
    FColors.Insert(index,pdword(color));
end;

procedure TFieldDisplayOption.DeleteValue(index:integer);
var len:integer;
begin
  len:=FValues.Count;
  if (index<0) or (index>len-1) then begin
    raise Exception.Create('TFieldDisplayOption: DeleteValue index('+IntToStr(index)+')下标超界。');
  end else if index=len-1 then begin
    FValues.Delete(index);
  end;
end;

procedure TFieldDisplayOption.DeleteColor(index:integer);
var len:integer;
begin
  len:=FColors.Count;
  if (index<0) or (index>len-1) then begin
    raise Exception.Create('TFieldDisplayOption: DeleteColor index('+IntToStr(index)+')下标超界。');
  end else if index=len-1 then begin
    FColors.Delete(index);
  end;
end;

function ColorToHex(color:TColor):string;
begin
  result:=IntToHex(int32(color),8);
end;

function HexToColor(str:string):TColor;
var tmp:integer;
begin
  tmp:=0;
  while str<>'' do begin
    tmp:=tmp shl 4;
    if str[1] in ['0'..'9'] then begin
      tmp:=tmp or (ord(str[1])-48)
    end else if str[1] in ['A'..'F'] then begin
      tmp:=tmp or (ord(str[1])-55)
    end else if str[1] in ['a'..'f'] then begin
      tmp:=tmp or (ord(str[1])-87)
    end;
    delete(str,1,1);
  end;
  result:=TColor(tmp);
end;

procedure TFieldDisplayOption.Assign(source:TFieldDisplayOption);
var pi,len:integer;
begin
  Clear;
  Self.FMode:=source.FMode;
  len:=source.FValues.Count;
  for pi:=0 to len-1 do Self.FValues.Add(source.FValues[pi]);
  len:=source.FColors.Count;
  for pi:=0 to len-1 do Self.FColors.Add(source.FColors[pi]);
  Self.FDispName:=source.FDispName;
  Self.FDispWidth:=source.FDispWidth;
  if FMode=fdmSuccessive then CheckSuccessive;
end;

procedure TFieldDisplayOption.Clear;
begin
  Self.FMode:=fdmDisabled;
  Self.FDispName:='';
  Self.FDispWidth:=-1;
  Self.FValues.Clear;
  Self.FColors.Clear;
end;

procedure TFieldDisplayOption.LoadFromJSON(str:string);
var data,tmp:TJSONData;
    pi,len:integer;
begin
  Clear;
  str:=StringReplace(str,'''','"',[rfReplaceAll]);
  try
    data:=GetJSON(str);
    tmp:=data.FindPath('disp_name');
    if tmp=nil then FDispName:=''
    else FDispName:=tmp.AsString;
    tmp:=data.FindPath('disp_width');
    if tmp=nil then FDispWidth:=-1
    else FDispWidth:=tmp.AsInteger;
    tmp:=data.FindPath('mode');
    if tmp=nil then FMode:=fdmDisabled
    else case uppercase(tmp.AsString) of
      'DISABLED':FMode:=fdmDisabled;
      'SUCCESSIVE':FMode:=fdmSuccessive;
      'IDENTICAL':FMode:=fdmIdentical;
      'REGEXPR':FMode:=fdmRegexpr;
      else FMode:=fdmDisabled;
    end;
    tmp:=data.FindPath('values');
    if tmp<>nil then begin
      len:=tmp.Count;
      for pi:=0 to len-1 do FValues.Add(tmp.Items[pi].AsString);
    end;
    tmp:=data.FindPath('colors');
    if tmp<>nil then begin
      len:=tmp.Count;
      for pi:=0 to len-1 do FColors.Add(pdword(HexToColor(tmp.Items[pi].AsString)));
    end;
  except
    {nop}
  end;
  if assigned(data) then FreeAndNil(data);
  if FMode=fdmSuccessive then CheckSuccessive;
end;

function TFieldDisplayOption.ExportToJSON:TJSONData;
var pi:integer;
    data:TJSONObject;
    jValues,jColors:TJSONArray;
begin
  data:=TJSONObject.Create;
  data.Add('disp_name',TJSONString.Create(FDispName));
  data.Add('disp_width',TJSONInt64Number.Create(FDispWidth));
  case FMode of
    fdmDisabled:data.Strings['mode']:='DISABLED';
    fdmSuccessive:data.Strings['mode']:='SUCCESSIVE';
    fdmIdentical:data.Strings['mode']:='IDENTICAL';
    fdmRegexpr:data.Strings['mode']:='REGEXPR';
    else data.Strings['mode']:='UNKNOWN';
  end;
  jValues:=TJSONArray.Create;
  jColors:=TJSONArray.Create;
  data.Add('values',jValues);
  data.Add('colors',jColors);
  jValues:=data.Arrays['values'];
  jColors:=data.Arrays['colors'];
  for pi:=0 to FValues.Count-1 do begin
    jValues.Add(FValues[pi]);
    jColors.Add(ColorToHex(dword(FColors[pi])));
  end;
  result:=data;
end;

function TFieldDisplayOption.SaveToJSON:string;
begin
  result:='';
  with ExportToJSON do begin
    result:=StringReplace(AsJSON,'"','''',[rfReplaceAll]);
    Clear;
    Free;
  end;
end;

function TFieldDisplayOption.GetFieldColor(Value:TField):TColor;
var pi,len:integer;
    dtmp,port:double;
begin
  len:=Self.Count;
  case FMode of
    fdmSuccessive:
      begin
        //这个要先实数初始化
        dtmp:=Value.AsFloat;
        if dtmp<FFloats[0] then begin
          result:=Colors[0];
          exit;
        end else begin
          for pi:=1 to len-1 do begin
            if dtmp<FFloats[pi] then begin
              port:=(dtmp-FFloats[pi-1])/(FFloats[pi]-FFloats[pi-1]);
              result:=HSVLinearCombination(Colors[pi-1],Colors[pi],port);
              exit;
            end;
          end;
          result:=Colors[len-1];
        end;
      end;
    fdmIdentical:
      begin
        for pi:=0 to len-1 do begin
          if Value.AsString=FValues[pi] then begin
            result:=Self.Colors[pi];
            exit;
          end;
        end;
      end;
    fdmRegexpr:
      begin
        for pi:=0 to len-1 do begin
          display_reg.Expression:=FValues[pi];
          if display_reg.Exec(Value.AsString) then begin
            result:=Self.Colors[pi];
            exit;
          end;
        end;
      end;
  end;
  result:=$ff000000;
end;

constructor TFieldDisplayOption.Create;
begin
  inherited Create;
  FValues:=TStringList.Create;
  FColors:=TList.Create;
end;

destructor TFieldDisplayOption.Destroy;
begin
  FValues.Free;
  FColors.Free;
  SetLength(FFloats,0);
  inherited Destroy;
end;

{ TAttrsField }

procedure TAttrsField.SetShown(value:boolean);
begin
  if FShown<>value then begin
    FShown:=value;
    if (not FUpdating) and (FOnChangeVisibility<>nil) then FOnChangeVisibility(Self);
  end;
end;

function TAttrsField.GetDisplayName:string;
begin
  result:=Self.FFieldDisplayOption.DispName;
end;

constructor TAttrsField.Create(ACollection: TCollection);
begin
  if Assigned(ACollection) and (ACollection is TAttrsFieldList) then
    inherited Create(ACollection)
  else raise Exception.Create('TAttrsField.Create: unassigned or wrong ListType');
  FUpdating:=false;
  FOnChangeVisibility:=nil;
  FFieldDisplayOption:=TFieldDisplayOption.Create;
  FFieldDisplayOption.FDispWidth:=90;
  FFieldDisplayOption.FDispName:='';
  FComboItem:=TStringList.Create;
  FComboItem.Sorted:=true;
end;
destructor TAttrsField.Destroy;
begin
  FComboItem.Free;
  FFieldDisplayOption.Free;
  inherited Destroy;
end;

procedure TAttrsField.BeginUpdate;
begin
  FUpdating:=true;
end;

procedure TAttrsField.EndUpdate;
begin
  FUpdating:=false;
end;

procedure TAttrsField.ResetFieldDef(AFieldDef:TFieldDef);
begin
  FFieldDef:=AFieldDef;
end;

function TAttrsField.GetIsCombo:boolean;
begin
  result:=(FComboItem.Count>0);
end;

procedure TAttrsField.ClearCombo;
begin
  FComboItem.Clear;
end;

procedure TAttrsField.AddCombo(Item:string);
begin
  FComboItem.Add(Item);
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
  Result.FFieldDisplayOption.FDispWidth:=-1;
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
  FModified:=false;
  FDisplayName:='';
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

procedure TAttrsGroup.Rename(ANewName:string);
begin
  FName:=ANewName;
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
  AFullPath:=StringReplace(AFullPath,'\','/',[rfReplaceAll]);//不会吧，不是这里的问题吧
  AFullPath:=StringReplace(AFullPath,'//','/',[rfReplaceAll]);//不会吧，不是这里的问题吧
  AFullPath:=StringReplace(AFullPath,'//','/',[rfReplaceAll]);//斜杠要整理一下
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


procedure TAttrsGroupList.LoadFromPath(APath:string='/';data_set_type:string='dbf');
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
    'dbf':regexp.Expression:='[^_run]\.dbf$';
    'buf':regexp.Expression:='\S\.buf$';
  end;
  try
    tmpFileList.RunDir;
    for stmp in tmpFileList do
      begin
        pathname:=(stmp as TRTFP_FileItem).Name;
        if not regexp.Exec(pathname) then continue;
        groupname:=ExtractFileName(pathname);
        System.delete(groupname,length(groupname)-3,4);
        System.delete(pathname,length(pathname)-3,4);
        Self.AddEx(APath+'/'+pathname,groupname,data_set_type);
      end;
  finally
    tmpFileList.Free;
    regexp.Free;
  end;

end;

initialization
  display_reg:=TRegexpr.Create;

finalization
  display_reg.Free;

end.

