//与字段相关的方法

function TRTFP.AddField(AName:string;AAttrsName:string;AType:TFieldType;ASize:word=0):TAttrsField;
var tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
    tmpDefs:TFieldDef;
begin
  result:=nil;
  if not TRTFP.IsAttrsName(AAttrsName) then exit;
  if not TRTFP.IsFieldName(AName) then exit;
  tmpAG:=FindAttrs(AAttrsName);
  if tmpAG=nil then tmpAG:=AddAttrs(AAttrsName);
  tmpAF:=tmpAG.FieldList.FindItemByName(AName);
  if tmpAF=nil then case FDataSetType of
    dstDBF:begin
      with TDbf(tmpAG.Dbf) do begin
        if not Active then Open;
        TryExclusive;
        case AType of
          ftString:begin
                     if ASize=0 then exit;
                     DbfFieldDefs.Add(AName,AType,ASize);
                   end;
          ftFloat:DbfFieldDefs.Add(AName,AType,8);
          else DbfFieldDefs.Add(AName,AType{,ASize});
        end;
        PackTable;
        Close;
        Open;
        RegenerateIndexes;
        tmpAG.AddField(FieldDefs.Find(AName));//LoadFieldListFromDbf;
        tmpAG.Modified:=true;
        FieldChange;
      end;
    end;
    dstBUF:begin
      case AType of
        ftString:begin
          if ASize=0 then exit;
          tmpDefs:=AddFieldInBuf(TBufDataSet(tmpAG.Dbf),AName,Atype,ASize);
        end;
        ftFloat:tmpDefs:=AddFieldInBuf(TBufDataSet(tmpAG.Dbf),AName,Atype,8);
        else tmpDefs:=AddFieldInBuf(TBufDataSet(tmpAG.Dbf),AName,Atype);
      end;
      if tmpDefs=nil then exit;
      tmpAG.AddField(tmpDefs);//LoadFieldListFromDbf;
      tmpAG.Modified:=true;
      FieldChange;
    end;
  end;
  result:=tmpAG.FieldList.FindItemByName(AName);
end;

function TRTFP.FindField(AName:string;AAttrsName:string):TAttrsField;
var tmpAG:TAttrsGroup;
begin
  result:=nil;
  tmpAG:=FindAttrs(AAttrsName);
  if tmpAG=nil then exit;
  result:=tmpAG.FieldList.FindItemByName(AName);
end;

procedure TRTFP.DeleteField(AName:string;AAttrsName:string);
var tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
    pi:integer;
begin
  tmpAG:=FindAttrs(AAttrsName);
  if tmpAG=nil then exit;
  tmpAF:=tmpAG.FieldList.FindItemByName(AName);
  if tmpAF<>nil then begin
    //删除image文件中的关联图片
    if tmpAF.FieldDef.DataType=ftBlob then begin
      case ShowMsgYesNoAll('删除图像字段','是否删除image文件夹中对应的图像文件？') of
        'Yes':if not TRTFP.DeleteDir(CurrentPathFull+'image\'+tmpAG.Name+'\'+tmpAF.FieldName+'\',true) then
          ShowMsgOK('删除图像字段','image文件夹中图像文件删除失败，请手动删除。');
      end;
    end;
    case FDataSetType of
      dstDBF:begin
        with TDbf(tmpAG.Dbf) do begin
          if not Active then Open;
          TryExclusive;
          pi:=0;
          while pi<DbfFieldDefs.Count do
            begin
              if DbfFieldDefs.Items[pi].FieldName=AName then break;
              inc(pi);
            end;
          if pi<DbfFieldDefs.Count then
            begin
              DbfFieldDefs.Delete(pi);
              PackTable;
            end
          else ;
          Close;
          Open;
          EndExclusive;
          RegenerateIndexes;
          tmpAG.DelField(AName);//LoadFieldListFromDbf;
        end;
      end;
      dstBUF:begin
         if not DeleteFieldInBuf(TBufDataset(tmpAG.Dbf),AName) then exit;
         tmpAG.DelField(AName);//LoadFieldListFromDbf;
      end;
    end;
  end;
  tmpAG.Modified:=true;
  if tmpAG.IsEmpty then DeleteAttrs(tmpAG.Name);
  FieldChange;
end;

procedure TRTFP.RenameField(AOldName,ANewName:string;AAttrsName:string);
var tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
    pi:integer;
    tmpBool:boolean;
    old_image_folder,new_image_folder:string;
begin
  tmpAG:=FindAttrs(AAttrsName);
  if tmpAG=nil then exit;
  tmpAF:=tmpAG.FieldList.FindItemByName(AOldName);
  if tmpAF<>nil then case FDataSetType of
    dstDBF:begin
      ShowMsgOK('重命名字段','DBF格式工程暂不支持重命名字段，推荐使用BUF格式。');
      exit;
    end;
    dstBUF:begin
       if not RenameFieldInBuf(TBufDataset(tmpAG.Dbf),AOldName,ANewName) then exit;
       tmpBool:=tmpAF.Shown;
       tmpAG.DelField(AOldName);
       tmpAG.AddField(TBufDataset(tmpAG.Dbf).FieldDefs.Find(ANewName));
       tmpAG.FieldList.FindItemByName(ANewName).Shown:=tmpBool;
       //此处重命名或是改类型后局部更新字段列表会造成ListView中顺序不同于真实顺序，在重新打开工程后恢复。
       //另外*InBuf方法中的重建数据库可能导致AF对应FieldDef不是当前数据库的版本，是否如此？目前还未遇见相关bug。
       old_image_folder:=CurrentPathFull+'image\'+tmpAG.Name+'\'+AOldName+'\';
       new_image_folder:=CurrentPathFull+'image\'+tmpAG.Name+'\'+ANewName+'\';
       if DirectoryExists(old_image_folder) then begin
         if not RenameFile(old_image_folder,new_image_folder) then
           ShowMsgOK('重命名字段','字段在image文件夹下的同名文件夹重命名失败，请手动修改。');
       end;
    end;
  end;
  tmpAG.Modified:=true;
  FieldChange;
end;

procedure TRTFP.ReTypeField(AName:string;AAttrsName:string;NewType:TFieldType;NewSize:Integer=0);
var tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
    pi:integer;
    tmpBool:boolean;
begin
  tmpAG:=FindAttrs(AAttrsName);
  if tmpAG=nil then exit;
  tmpAF:=tmpAG.FieldList.FindItemByName(AName);
  if tmpAF<>nil then case FDataSetType of
    dstDBF:begin
      ShowMsgOK('重命名字段','DBF格式工程暂不支持重命名字段，推荐使用BUF格式。');
    end;
    dstBUF:begin
       if not ChangeTypeInBuf(TBufDataset(tmpAG.Dbf),AName,NewType,NewSize) then exit;
       tmpBool:=tmpAF.Shown;
       tmpAG.DelField(AName);
       tmpAG.AddField(TBufDataset(tmpAG.Dbf).FieldDefs.Find(AName));
       tmpAG.FieldList.FindItemByName(AName).Shown:=tmpBool;
       //此处重命名或是改类型后局部更新字段列表会造成ListView中顺序不同于真实顺序，在重新打开工程后恢复。
       //另外*InBuf方法中的重建数据库可能导致AF对应FieldDef不是当前数据库的版本，是否如此？目前还未遇见相关bug。
    end;
  end;
  tmpAG.Modified:=true;
  FieldChange;
end;

function TRTFP.CheckField(AName:string;AAttrsName:string;AType:TFieldType):boolean;
begin
  result:=CheckField(AName,AAttrsName,[AType]);
end;

function TRTFP.CheckField(AName:string;AAttrsName:string;ATypes:TFieldTypeSet):boolean;
var tmpAF:TAttrsField;
begin
  result:=false;
  tmpAF:=FindField(AName,AAttrsName);
  if tmpAF=nil then exit;
  result:=tmpAF.FieldDef.DataType in ATypes;
end;

function TRTFP.GetField(AName:string;AAttrsName:string;PID:RTFP_ID;NewPidIfNotExists:boolean):TField;
var tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
begin
  result:=nil;
  tmpAF:=FindField(AName,AAttrsName);
  if tmpAF=nil then exit;//所以没有的字段读取就会报错 nil.AsString之类的错误
  tmpAG:=FindAttrs(AAttrsName);

  case FDataSetType of
    dstDBF:begin
      with TDbf(tmpAG.Dbf) do
        begin
          if not Active then Open;
          IndexName:='id';
          if not SearchKey(PID,stEqual) then begin
            if not NewPidIfNotExists then exit;
            Append;
            Edit;
            FieldByName(_Col_PID_).AsString:=PID;
            Post;
          end;
          result:=FieldByName(AName);
        end;
    end;
    dstBUF:begin
      with TBufDataset(tmpAG.Dbf) do
        begin
          if not Active then Open;
          //IndexName:='id';
          if not Locate(_Col_PID_,PID,[]) then begin
            if not NewPidIfNotExists then exit;
            Append;
            Edit;
            FieldByName(_Col_PID_).AsString:=PID;
            Post;
          end;
          result:=FieldByName(AName);
        end;
    end;
    else raise Exception.Create('无效DataSetType。');
  end;
end;

class function TRTFP.FieldMinWidth(AFieldDef:TFieldDef):integer;
begin
  result:=40;
  case AFieldDef.DataType of
    ftBoolean:result:=40;
    ftMemo:result:=75;
    ftInteger,ftSmallint:result:=50;
    ftLargeint,ftFloat:result:=75;
    ftDateTime,ftDate,ftTime:result:=100;
    ftString:
      begin
        result:=AFieldDef.Size*8;
        if result>200 then result:=200;
      end;
  end;
end;

class function TRTFP.FieldOptWidth(AFieldDef:TFieldDef):integer;
var NameSize:integer;
begin
  case AFieldDef.DisplayName of
    _Col_Paper_Folder_:begin result:=3;exit end;
    _Col_Paper_FileHash_:begin result:=3;exit end;
    _Col_Paper_FileSize_:begin result:=3;exit end;
    _Col_Paper_Is_Backup_:begin result:=40;exit end;
    _Col_OID_:begin result:=3;exit end;
    else ;
  end;
  result:=40;
  NameSize:=length(AFieldDef.DisplayName)*8+16;
  if NameSize>80 then NameSize:=80;
  case AFieldDef.DataType of
    ftBoolean:result:=40;
    ftMemo:result:=75;
    ftInteger,ftSmallint:result:=50;
    ftLargeint,ftFloat:result:=75;
    ftDateTime,ftDate,ftTime:result:=100;
    ftString:
      begin
        result:=AFieldDef.Size*8;
        if result>200 then result:=200;
      end;
  end;
  if result<NameSize then result:=NameSize;
end;


