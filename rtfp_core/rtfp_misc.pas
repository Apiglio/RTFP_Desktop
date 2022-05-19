//
//  这个单元存放一些杂项的小类
//
//


unit rtfp_misc;

{$mode objfpc}{$H+}
{$asmMode intel}

interface

uses
  Classes, SysUtils, Graphics;

const
  _fc0:Single   = 0.0;
  _fc1:Single   = 1.0;
  _fc6:Single   = 6.0;
  _fc60:Single  = 60.0;
  _fc255:Single = 255.0;
  _fc360:Single = 360.0;

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


procedure ColorToHSV(var H,S,V:Single;Color:TColor);
function HSVToColor(H,S,V:Single):TColor;
function HSVLinearCombination(c1,c2:TColor;position:single):TColor;

function LongestCommonSubString(s1,s2:string):string;//最大共同子串
function LongestOrdinalCombination(s1,s2:string):string;//最大共同子串组合

implementation


procedure ColorToHSV(var H,S,V:Single;Color:TColor);
var max,min,delta,R,G,B,add:byte;
    eax:longint;
begin
  R:=Color and $ff;
  G:=(Color shr 8) and $ff;
  B:=(Color shr 16) and $ff;
  if R>G then begin max:=R;min:=G;end
  else begin max:=G;min:=R;end;
  if B>max then max:=B;
  if B<min then min:=B;
  V:=max/255*100;
  delta:=max-min;
  if delta=0 then begin H:=0;S:=0;exit;end;
  S:=delta/max*100;
  if R=max then begin eax:=G-B;add:=0;end;
  if G=max then begin eax:=B-R;add:=120;end;
  if B=max then begin eax:=R-G;add:=240;end;
  H:=eax*60/delta+add;
end;

function HSVToColor(H,S,V:Single):TColor;
var i,difs:integer;
    min,max,adj:byte;
    r,g,b:byte;
begin
  // R,G,B from 0-255, H from 0-360, S,V from 0-100
  max:=round(V*2.55);
  min:=round(max*(100-s)) div 100;
  i:=round(H) div 60;
  difs:=round(H) mod 60;// factorial part of h
  // RGB adjustment amount by hue
  adj:=(max-min)*difs div 60;
  case i of
    0:begin
        r:=(max);
        g:=(min+adj);
        b:=(min);
      end;
    1:begin
        r:=(max-adj);
        g:=(max);
        b:=(min);
      end;
    2:begin
        r:=(min);
        g:=(max);
        b:=(min+adj);
      end;
    3:begin
        r:=(min);
        g:=(max-adj);
        b:=(max);
      end;
    4:begin
        r:=(min+adj);
        g:=(min);
        b:=(max);
      end
    else
      begin
        r:=(max);
        g:=(min);
        b:=(max-adj);
      end;
  end;
  result:=$00000000 or (b shl 16) or (g shl 8) or r;
end;

function HSVLinearCombination(c1,c2:TColor;position:single):TColor;
var h1,h2,s1,s2,v1,v2:single;
begin
  ColorToHSV(h1,s1,v1,c1);
  ColorToHSV(h2,s2,v2,c2);
  while h2<h1 do h2:=h2+360;
  if position<0 then begin result:=c1;exit end;
  if position>1 then begin result:=c2;exit end;
  h2:=position*(h2-h1)+h1;
  s2:=position*(s2-s1)+s1;
  v2:=position*(v2-v1)+v1;
  while h2>=360 do h2:=h2-360;
  result:=HSVToColor(h2,s2,v2);
end;

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

