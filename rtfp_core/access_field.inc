//与字段相关的方法

function TRTFP.AddField(AName:string;AAttrsName:string;AType:TFieldType{;ASize:word}):TAttrsField;
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
          ftString:DbfFieldDefs.Add(AName,AType,16);
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
        ftString:tmpDefs:=AddFieldInBuf(TBufDataSet(tmpAG.Dbf),AName,Atype,16);
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
  if tmpAF<>nil then case FDataSetType of
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
  tmpAG.Modified:=true;
  if tmpAG.IsEmpty then DeleteAttrs(tmpAG.Name);
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


