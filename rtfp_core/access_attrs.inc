//与属性组相关的方法

function TRTFP.AddAttrs(AName:string):TAttrsGroup;
var tmp:TAttrsGroup;
begin
  result:=nil;
  if not TRTFP.IsAttrsName(AName) then exit;
  if FFieldList.FindItemIndexByName(AName)>=0 then exit;
  case FDataSetType of
    dstDBF:tmp:=FFieldList.AddEx('attr\'+AName,AName,'dbf');
    dstBUF:tmp:=FFieldList.AddEx('attr\'+AName,AName,'buf');
    else raise Exception.Create('无效DataSetType。');
  end;

  if not OpenDbf(tmp.FullPath,tmp.Dbf) then begin
    case AName of
      _Attrs_Basic_:GenAttrBasicAttribute(tmp.Dbf);
      _Attrs_Class_:GenAttrClassAttribute(tmp.Dbf);
      _Attrs_Notes_:GenAttrNotesAttribute(tmp.Dbf);
      _Attrs_Metas_:GenAttrMetasAttribute(tmp.Dbf);
      _Attrs_Relat_:GenAttrRelatAttribute(tmp.Dbf);
      else GenAttrDefaultAttribute(tmp.Dbf);
    end;
    NewDbf(tmp.FullPath,tmp.Dbf);
    tmp.LoadFieldListFromDbf;
  end;
  tmp.Modified:=true;
  FieldChange;
  result:=tmp;
end;

function TRTFP.FindAttrs(AName:string):TAttrsGroup;
begin
  result:=FFieldList.FindItemByName(AName);
end;

procedure TRTFP.DeleteAttrs(AName:string);
var index:integer;
    tmp:TAttrsGroup;
begin
  index:=FFieldList.FindItemIndexByName(AName);
  if index<0 then exit;
  tmp:=FFieldList.Items[index];
  CloseDbf(tmp.FullPath,tmp.Dbf);
  DeleteDbf(tmp.FullPath,tmp.Dbf);
  FFieldList.Delete(index);
  tmp.Modified:=true;
  FieldChange;
end;


