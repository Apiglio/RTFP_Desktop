//与属性组相关的方法

function TRTFP.AddAttrs(AName:string):TAttrsGroup;
var tmp:TAttrsGroup;
begin
  result:=nil;
  if not TRTFP.IsAttrsName(AName) then exit;
  if FFieldList.FindItemIndexByName(AName)>=0 then exit;
  case DataSetType of
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

function TRTFP.RenameAttrs(AName,ANewName:string):boolean;
var tmpAG:TAttrsGroup;
    oldname,newname:string;
begin
  result:=false;
  tmpAG:=FFieldList.FindItemByName(AName);
  if tmpAG=nil then exit;
  if FFieldList.FindItemByName(ANewName)<>nil then exit;
  case DataSetType of
    dstDBF:
      begin
        ShowMsgOK('重命名字段','DBF格式工程暂不支持重命名属性组，推荐使用BUF格式。');
        exit;
      end;
    dstBUF:
      begin
        if tmpAG.Dbf.Active then tmpAG.Dbf.Close;
        oldname:=CurrentPathFull+'attr\'+AName+'.buf';
        newname:=CurrentPathFull+'attr\'+ANewName+'.buf';
        if not TRTFP.FileCopy(oldname,newname,true) then begin
          ShowMsgOK('重命名属性组','重命名属性组失败，未能成功创建属性组文件。');
          exit;
        end;
        if not TRTFP.FileDelete(oldname) then ShowMsgOK('重命名属性组','旧属性组文件删除失败，请手动删除。');
        tmpAG.Rename(ANewName);
        TBufDataset(tmpAG.Dbf).FileName:=newname;
        tmpAG.Dbf.Open;
      end;
    else ;
  end;
  FieldAndRecordChange;
  result:=true;
end;

procedure TRTFP.DeleteAttrs(AName:string);
var index:integer;
    tmp:TAttrsGroup;
    image_folder:string;
begin
  index:=FFieldList.FindItemIndexByName(AName);
  if index<0 then exit;
  tmp:=FFieldList.Items[index];
  CloseDbf(tmp.FullPath,tmp.Dbf);
  DeleteDbf(tmp.FullPath,tmp.Dbf);
  image_folder:=CurrentPathFull+'image\'+tmp.Name+'\';
  if DirectoryExists(image_folder) then
    if not TRTFP.DeleteDir(image_folder,true) then
      ShowMsgOK('删除属性组','image文件夹中属性组文件夹删除失败，请手动删除。');
  FFieldList.Delete(index);
  tmp.Modified:=true;//这里tmp不会泄漏吗？
  FieldChange;
end;


