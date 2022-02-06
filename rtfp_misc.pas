//
//  这个单元存放一些杂项的小类
//
//


unit rtfp_misc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type


  TStrHashItem = class(TObject)
  public
    Name:string;
    Count:int64;
  end;

  TStrHash = class(TList)
  protected
    function FindByName(str:string):TStrHashItem;
    function GetNamedItemCount(str:string):int64;
    procedure SetNamedItemCount(str:string;value:int64);
    procedure Clear;
  public
    procedure NamedItemAddCount(str:string;value:int64=1);
    property NamedItem[str:string]:int64 read GetNamedItemCount write SetNamedItemCount;default;
  end;



function LongestCommonSubString(s1,s2:string):string;//最大共同子串
function LongestOrdinalCombination(s1,s2:string):string;//最大共同子串组合

implementation

function LongestCommonSubString(s1,s2:string):string;
var len1,len2,pi,pj,diag:integer;
    diag_max,diag_now:integer;
    hdi:integer;
    mem:TMemoryStream;
begin
  len1:=length(s1);
  len2:=length(s2);
  mem:=TMemoryStream.Create;
  try
    mem.SetSize(len1*len2);
    mem.Position:=0;
    for pi:=1 to len1 do
      for pj:=1 to len2 do
        if s1[pi]=s2[pj] then mem.WriteByte(1) else mem.WriteByte(0);
    diag_max:=0;
    for diag:=0 to len1-1 do
      begin
        pi:=diag;pj:=0;
        diag_now:=0;
        while (pj<len2) and (pi<len1) do
          begin
            mem.Position:=pi*len2+pj;
            if mem.ReadByte<>0 then inc(diag_now) else diag_now:=0;
            if diag_now>diag_max then
              begin
                hdi:=pi;
                diag_max:=diag_now;
              end;
            inc(pi);inc(pj);
          end;
      end;
    for diag:=1 to len2-1 do
      begin
        pj:=diag;pi:=0;
        diag_now:=0;
        while (pj<len2) and (pi<len1) do
          begin
            mem.Position:=pi*len2+pj;
            if mem.ReadByte<>0 then inc(diag_now) else diag_now:=0;
            if diag_now>diag_max then
              begin
                hdi:=pi;
                diag_max:=diag_now;
              end;
            inc(pi);inc(pj);
          end;
      end;
    result:=copy(s1,hdi+2-diag_max,diag_max);
  finally
    mem.Free;
  end;


end;

function LongestOrdinalCombination(s1,s2:string):string;
begin
  //心态崩了，逻辑有点复杂
  //大概的意思是在对比矩阵的基础上寻找最大非零对角线，然后同行同列全部置0，重复直到全0
end;


function TStrHash.FindByName(str:string):TStrHashItem;
var index:integer;
begin
  result:=nil;
  index:=0;
  while index<Count do
    begin
      if TStrHashItem(Items[index]).Name=str then
        begin
          result:=TStrHashItem(Items[index]);
          exit;
        end;
      inc(index);
    end;
end;
function TStrHash.GetNamedItemCount(str:string):int64;
var tmpItem:TStrHashItem;
begin
  result:=-1;
  tmpItem:=FindByName(str);
  if tmpItem=nil then exit;
  result:=tmpItem.Count;
end;
procedure TStrHash.SetNamedItemCount(str:string;value:int64);
var tmpItem:TStrHashItem;
begin
  tmpItem:=FindByName(str);
  if tmpItem=nil then
    begin
      tmpItem:=TStrHashItem.Create;
      tmpItem.Name:=str;
      tmpItem.Count:=value;
      Add(tmpItem);
    end
  else tmpItem.Count:=value;
end;
procedure TStrHash.Clear;
begin
  while Count>0 do
    begin
      TStrHashItem(Items[0]).Free;
      Delete(0);
    end;
end;
procedure TStrHash.NamedItemAddCount(str:string;value:int64=1);
var tmpItem:TStrHashItem;
begin
  tmpItem:=FindByName(str);
  if tmpItem=nil then
    begin
      tmpItem:=TStrHashItem.Create;
      tmpItem.Name:=str;
      tmpItem.Count:=value;
      Add(tmpItem);
    end
  else tmpItem.Count:=tmpItem.Count+value;
end;

end.

