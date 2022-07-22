unit rtfp_field_convert;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db;

type pConvertFunc = procedure(src,dst:TField);

function FieldTypeChangeMode(origin,target:TFieldType;out convert_proc:pConvertFunc):string;

procedure convert_directly(src,dst:TField);
procedure convert_boo_str(src,dst:TField);
procedure convert_int_str(src,dst:TField);
procedure convert_frac_str(src,dst:TField);
procedure convert_date_str(src,dst:TField);

implementation


function FieldTypeChangeMode(origin,target:TFieldType;out convert_proc:pConvertFunc):string;
begin
  case target of
    ftMemo,ftString:
      case origin of
        ftMemo,ftString:begin result:='直接转换，字段长度不足则截断。';convert_proc:=@convert_directly end;
        ftSmallint,ftLargeint:begin result:='数字转换为字符串，字段长度不足则截断。';convert_proc:=@convert_int_str; end;
        ftFloat:begin result:='浮点型按三位小数转换，字段长度不足则截断。';convert_proc:=@convert_frac_str; end;
        ftBoolean:begin result:='若为真记为“Y”，若为假记为“N”。';convert_proc:=@convert_boo_str; end;
        else begin result:='不支持保留数值的转换。';convert_proc:=nil;end;
      end;
    ftSmallint,ftLargeint:begin result:='不支持保留数值的转换。';convert_proc:=nil;end;
    ftBoolean:begin result:='不支持保留数值的转换。';convert_proc:=nil;end;
    ftFloat:begin result:='不支持保留数值的转换。';convert_proc:=nil;end;
    ftDate,ftDateTime:begin result:='不支持保留数值的转换。';convert_proc:=nil;end;
    ftBlob:begin result:='不支持保留数值的转换。';convert_proc:=nil;end;
    ftAutoInc:begin result:='不支持保留数值的转换。';convert_proc:=nil;end;
  end;
end;

procedure convert_directly(src,dst:TField);
begin
  dst.Assign(src);
end;
procedure convert_boo_str(src,dst:TField);
begin
  if src.AsBoolean then dst.AsString:='Y'
  else dst.AsString:='N';
end;
procedure convert_int_str(src,dst:TField);
begin
  dst.AsString:=IntToStr(src.AsLargeInt);
end;
procedure convert_frac_str(src,dst:TField);
begin
  dst.AsString:=FloatToStrF(src.AsFloat,ffFixed,3,9);//这个或许需要更包容的做法
end;
procedure convert_date_str(src,dst:TField);
begin
  dst.AsString:=DateTimeToStr(src.AsDateTime);
end;

end.

