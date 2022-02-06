//
//  这个单元存放一些杂项的小类
//
//


unit rtfp_misc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;


function LongestCommonSubString(s1,s2:string):string;

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


end.

