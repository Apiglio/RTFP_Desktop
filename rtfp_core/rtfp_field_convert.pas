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
procedure convert_frac_int(src,dst:TField);
procedure convert_str_int(src,dst:TField);
procedure convert_int_frac(src,dst:TField);
procedure convert_str_frac(src,dst:TField);
procedure convert_str_bool(src,dst:TField);
procedure convert_str_time(src,dst:TField);
procedure convert_time_str(src,dst:TField);


implementation


function FieldTypeChangeMode(origin,target:TFieldType;out convert_proc:pConvertFunc):string;
begin
  case target of
    ftMemo,ftString:
      case origin of
        ftMemo,ftString:begin result:='直接转换。字段长度不足则截断。';convert_proc:=@convert_directly end;
        ftSmallint,ftLargeint:begin result:='整型数转为字符串。字段长度不足则截断。';convert_proc:=@convert_int_str end;
        ftFloat:begin result:='浮点数转为字符串。按三位小数转换，字段长度不足则截断。';convert_proc:=@convert_frac_str end;
        ftBoolean:begin result:='若为真记为“Y”，若为假记为“N”。';convert_proc:=@convert_boo_str; end;
        ftDateTime,ftDate,ftTime:begin result:='时间类型转字符串。格式为“yyyy/mm/dd hh:mm”。';convert_proc:=@convert_time_str; end;
        else begin result:='不支持保留数值的转换。';convert_proc:=nil end;
      end;
    ftSmallint,ftLargeint:
      case origin of
        ftMemo,ftString:begin result:='字符串转为整数。存在数字以外的字符则舍弃值。';convert_proc:=@convert_str_int end;
        ftSmallint,ftLargeint:begin result:='直接转换。字段长度不足则取余数。';convert_proc:=@convert_directly end;
        ftFloat:begin result:='浮点数取整数部分。字段长度不足则取余数。';convert_proc:=@convert_frac_int end;
        ftBoolean:begin result:='不支持保留数值的转换。';convert_proc:=nil end;
        else begin result:='不支持保留数值的转换。';convert_proc:=nil end;
      end;
    ftBoolean:
      case origin of
        ftMemo,ftString:begin result:='字符串转为布尔型，非空字符串则转换为真。';convert_proc:=@convert_str_bool end;
        //ftSmallint,ftLargeint:begin result:='直接转换，字段长度不足则取余数。';convert_proc:=@convert_int_bool end;
        //ftFloat:begin result:='取整数部分，字段长度不足则取余数。';convert_proc:=@convert_frac_bool end;
        ftBoolean:begin result:='无需转换。';convert_proc:=nil end;
        //ftBlob:begin result:='有图片记录为真，无记录为假。';convert_proc:=@convert_img_bool end;
        else begin result:='不支持保留数值的转换。';convert_proc:=nil end;
      end;
    ftFloat:
      case origin of
        ftMemo,ftString:begin result:='字符串转为浮点数，不合规的记录则舍弃值。';convert_proc:=@convert_frac_str; end;
        ftSmallint,ftLargeint:begin result:='整型数转为浮点数，长度过大的整数可能失效。';convert_proc:=@convert_frac_int; end;
        ftFloat:begin result:='直接转换。字段长度不足则截断有效位数。';convert_proc:=@convert_directly; end;
        ftBoolean:begin result:='不支持保留数值的转换。';convert_proc:=nil end;
        else begin result:='不支持保留数值的转换。';convert_proc:=nil end;
      end;
    ftDate,ftDateTime,ftTime:
      case origin of
        ftString:begin result:='字符串转换为时间类型。格式为“yyyy/mm/dd hh:mm”。';convert_proc:=@convert_str_time end;
        else begin result:='不支持保留数值的转换。';convert_proc:=nil end;
      end;
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
procedure convert_frac_int(src,dst:TField);
begin
  dst.AsLargeInt:=trunc(src.AsFloat);
end;
procedure convert_str_int(src,dst:TField);
var stmp:string;
    pi,len:integer;
begin
  stmp:=src.AsString;
  len:=length(stmp);
  pi:=1;
  while pi<=len do begin
    if not (stmp[pi] in ['0'..'9']) then exit;
    inc(pi);
  end;
  dst.AsLargeInt:=StrToInt(stmp);
end;
procedure convert_int_frac(src,dst:TField);
begin
  dst.AsFloat:=src.AsLargeInt;
end;
procedure convert_str_frac(src,dst:TField);
var stmp:string;
    codee:integer;
    value:double;
begin
  stmp:=src.AsString;
  val(stmp,value,codee);
  if codee=0 then dst.AsFloat:=value;
end;
procedure convert_str_bool(src,dst:TField);
begin
  dst.AsBoolean:=(src.AsString<>'');
end;
procedure convert_str_time(src,dst:TField);
var stmp:string;
    value:TDateTime;
begin
  stmp:=src.AsString;
  if TryStrToDateTime(stmp,value) then dst.AsDateTime:=value;
end;
procedure convert_time_str(src,dst:TField);
var stmp:string;
    value:TDateTime;
begin
  value:=src.AsDateTime;
  dst.AsString:=DateTimeToStr(value);
end;

end.

