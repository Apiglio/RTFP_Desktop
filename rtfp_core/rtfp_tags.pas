unit rtfp_tags;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  TTag = class
  public
    key,value:string;
    ReadOnly:boolean;
  end;

  TTags = class
    FList:TList;
  protected
    function GetTag(akey:string):TTag;
    function GetValue(akey:string):string;
    procedure SetValue(akey:string;avalue:string);
  public
    function AddTag(akey,avalue:string):integer;
    function FindTag(akey:string):integer;
    function DeleteTag(akey:string):boolean;
    procedure Clear;
    property Tags[akey:string]:TTag read GetTag;
    property Values[akey:string]:string read GetValue write SetValue;
  public
    procedure LoadFromFile(filename:string);
    procedure SaveToFile(filename:string);
  public
    constructor Create;
    destructor Destroy;
  end;


implementation

function TTags.GetTag(akey:string):TTag;
var index:integer;
begin
  index:=FindTag(akey);
  if index>=0 then result:=TTag(FList.Items[index])
  else result:=nil;
end;
function TTags.GetValue(akey:string):string;
var tmpTag:TTag;
begin
  tmpTag:=Tags[akey];
  if tmpTag <> nil then result:=tmpTag.value
  else result:='';
end;
procedure TTags.SetValue(akey:string;avalue:string);
var tmpTag:TTag;
begin
  tmpTag:=Tags[akey];
  if tmpTag<>nil then tmpTag.value:=avalue
  else AddTag(akey,avalue);
end;
function TTags.AddTag(akey,avalue:string):integer;
var index:integer;
    tmpTag:TTag;
begin
  index:=FindTag(akey);
  if index<0 then
    begin
      tmpTag:=TTag.Create;
      tmpTag.key:=akey;
      tmpTag.value:=avalue;
      FList.Add(tmpTag);
      index:=FList.Count-1;
    end
  else TTag(FList.Items[index]).value:=avalue;
  result:=index;
end;
function TTags.FindTag(akey:string):integer;
var pi:integer;
begin
  result:=-1;
  for pi:=0 to FList.Count-1 do
    begin
      if TTag(FList.Items[pi]).key=akey then
        begin
          result:=pi;
          exit;
        end;
    end;
end;
function TTags.DeleteTag(akey:string):boolean;
var index:integer;
begin
  result:=false;
  index:=FindTag(akey);
  if index<0 then
    begin
      TTag(FList.Items[index]).Free;
      FList.Delete(index);
      result:=true;
    end;
end;
procedure TTags.Clear;
begin
  while FList.Count>0 do
    begin
      TTag(FList.Items[0]).Free;
      FList.Delete(0);
    end;
end;
procedure TTags.LoadFromFile(filename:string);
var str:TStringList;
    stmp,v1,v2:string;
    poss:integer;
    function non_quote(str:string):string;
    var len:integer;
    begin
      result:=str;
      len:=length(result);
      if len<2 then exit;
      if (result[1]='"') and (result[len]='"') then
        begin
          delete(result,len,1);
          delete(result,1,1);
        end;
    end;

begin
  str:=TStringList.Create;
  try
    str.LoadFromFile(filename);
    for stmp in str do
      begin
        poss:=pos(',',stmp);
        if poss<0 then continue;
        v1:=stmp;
        v2:=stmp;
        delete(v1,poss,length(v2));
        delete(v2,1,poss);
        AddTag(v1,non_quote(v2));
      end;
  finally
    str.Free;
  end;
end;
procedure TTags.SaveToFile(filename:string);
var str:TStringList;
    pi:integer;
    tmpTag:TTag;
begin
  str:=TStringList.Create;
  try
    for pi:=0 to FList.Count-1 do
      begin
        tmpTag:=TTag(FList.Items[pi]);
        if (pos(' ',tmpTag.key)>=0) or (pos(' ',tmpTag.value)>=0) then
          str.add(tmpTag.key+',"'+tmpTag.value+'"')
        else str.add(tmpTag.key+','+tmpTag.value);
      end;
    str.SaveToFile(filename);
  finally
    str.Free;
  end;
end;
constructor TTags.Create;
begin
  inherited Create;
  FList:=TList.Create;
end;
destructor TTags.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

end.

