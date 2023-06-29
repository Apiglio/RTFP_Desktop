//用于压缩储存和格式转换的文件定义
//使用zip压缩格式

procedure TRTFP.ZTFP_Importer(fullfilename:string);
const folder_name:array[0..2] of string = ('paper','image','format');
var zf:TUnZipper;
begin
  //理想状态下是新建空白工程后
  //
end;

procedure TRTFP.ZTFP_Exporter(fullfilename:string);
const folder_name:array[0..2] of string = ('paper','image','format');
var zf:TZipper;
    stmp,path_base,stored_name:string;
    path_base_len,pi:integer;
    af:text;
    filelist:TStringList;
begin
  assignfile(af,Self.CurrentPathFull+'tmp_info.json');
  rewrite(af);
  with GetJSON_Project do begin
    write(af,FormatJSON);
    Clear;
    Free;
  end;
  closefile(af);
  zf:=TZipper.Create;
  filelist:=TStringList.Create;
  try
    zf.FileName:=fullfilename;
    zf.Entries.AddFileEntry(Self.CurrentPathFull+'tmp_info.json','info.json');
    for pi:=0 to 2 do begin
      path_base:=GetCurrentPathFull+folder_name[pi];
      path_base_len:=length(path_base)+1;
      FindAllFiles(filelist,path_base,'',true,faAnyFile);
      for stmp in filelist do begin
        stored_name:=stmp;
        delete(stored_name,1,path_base_len);
        stored_name:=folder_name[pi]+'/'+stored_name;
        zf.Entries.AddFileEntry(stmp,Utf8ToWinCP(stored_name));
      end;
      filelist.Clear;
    end;
    zf.SaveToFile(fullfilename);
  finally
    zf.Free;
    filelist.Free;
  end;
  erase(af);

end;

function TRTFP.GetJSON_Project:TJSONObject;
var jData:TJSONObject;
    tmp:TJSONData;
begin
  result:=nil;
  jData:=TJSONObject.Create;
  jData.Add('tags',GetJSON_TagList);
  jData.Add('user',GetJSON_UserList);
  jData.Add('formats',GetJSON_FormatList);
  jData.Add('attributes',GetJSON_AttrsList);
  jData.Add('papers',GetJSON_PaperList);
  jData.Add('images',GetJSON_ImageList);
  jData.Add('notes',GetJSON_NotesList);
  result:=jData;
end;

function TRTFP.GetJSON_TagList:TJSONData;
begin
  result:=nil;
  result:=FProjectTags.ExportToJSON;
end;

function TRTFP.GetJSON_PaperList:TJSONData;
var jData:TJSONArray;
    PID:RTFP_ID;
begin
  result:=nil;
  jData:=TJSONArray.Create;
  if not FPaperDB.Active then FPaperDB.Open;
  FPaperDB.First;
  while not FPaperDB.EOF do begin
    PID:=FPaperDB.FieldByName(_Col_PID_).AsString;
    jData.Add(GetJSON_Paper(PID));
    FPaperDB.Next;
  end;
  result:=jData;
end;

function TRTFP.GetJSON_ImageList:TJSONData;
var jData:TJSONArray;
begin
  result:=nil;
  jData:=TJSONArray.Create;
  result:=jData;
end;

function TRTFP.GetJSON_NotesList:TJSONData;
var jData:TJSONArray;
begin
  result:=nil;
  jData:=TJSONArray.Create;
  result:=jData;
end;

function TRTFP.GetJSON_AttrsList:TJSONData;
var jData:TJSONArray;
    tmp:TJSONObject;
    tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
begin
  result:=nil;
  jData:=TJSONArray.Create;
  for tmpAG in FFieldList do begin
    tmp:=GetJSON_Attrs(tmpAG) as TJSONObject;
    tmp.Add('fields',TJSONArray.Create);
    for tmpAF in tmpAG.FieldList do begin
      case tmpAF.FieldName of _Col_PID_,_Col_OID_:continue;end;
      tmp.Arrays['fields'].Add(GetJSON_Field(tmpAF));
    end;
    jData.Add(tmp);
  end;
  result:=jData;
end;

function TRTFP.GetJSON_UserList:TJSONData;
var stmp:string;
    jData:TJSONArray;
begin
  result:=nil;
  jData:=TJSONArray.Create;
  for stmp in FUserList do jData.Add(stmp);
  result:=jData;
end;

function TRTFP.GetJSON_FormatList:TJSONData;
var stmp:string;
    jData:TJSONArray;
begin
  result:=nil;
  jData:=TJSONArray.Create;
  for stmp in FFormatList do jData.Add(stmp);
  result:=jData;
end;

function TRTFP.GetJSON_Paper(PID:RTFP_ID):TJSONData;
var jData:TJSONObject;
    jBlob:TJSONObject;
    tmp:TJSONData;
    tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
begin
  result:=nil;
  jData:=TJSONObject.Create;
  jData.Strings['sys.pid']:=PID;
  jData.Strings['sys.ref']:=Cite_format;
  jData.Strings['sys.path']:=CurrentPathFull;
  tmp:=TJSONObject.Create;
  case DataSetType of
    dstDBF:jData.Add('paper.dbf',tmp);
    else   jData.Add('paper.buf',tmp);
  end;
  if not FPaperDB.Active then FPaperDB.Open;
  if FPaperDB.Locate(_Col_PID_,PID,[]) then begin
    TJSONObject(tmp).Booleans[_Col_Paper_Is_Backup_]:=FPaperDB.FieldByName(_Col_Paper_Is_Backup_).AsBoolean;
    TJSONObject(tmp).Strings[_Col_Paper_Folder_]:=FPaperDB.FieldByName(_Col_Paper_Folder_).AsString;
    TJSONObject(tmp).Strings[_Col_Paper_FileName_]:=FPaperDB.FieldByName(_Col_Paper_FileName_).AsString;
    TJSONObject(tmp).Int64s[_Col_Paper_FileSize_]:=FPaperDB.FieldByName(_Col_Paper_FileSize_).AsLargeInt;
    TJSONObject(tmp).Strings[_Col_Paper_FileHash_]:=FPaperDB.FieldByName(_Col_Paper_FileHash_).AsString;
  end;
  for tmpAG in FFieldList do begin
    if not tmpAG.Dbf.Active then tmpAG.Dbf.Open;
    if tmpAG.Dbf.Locate(_Col_PID_,PID,[]) then begin
      tmp:=TJSONObject.Create;
      jData.Add(tmpAG.Name,tmp);
      for tmpAF in tmpAG.FieldList do begin
        case tmpAF.FieldName of _Col_OID_,_Col_PID_:continue;end;
        case tmpAF.FieldDef.DataType of
          ftString,ftMemo:TJSONObject(tmp).Strings[tmpAF.FieldName]:=tmpAG.Dbf.FieldByName(tmpAF.FieldName).AsString;
          ftDate,ftTime,ftDateTime:TJSONObject(tmp).Strings[tmpAF.FieldName]:=tmpAG.Dbf.FieldByName(tmpAF.FieldName).AsString;
          ftInteger,ftLargeint,ftSmallint,ftWord:TJSONObject(tmp).Int64s[tmpAF.FieldName]:=tmpAG.Dbf.FieldByName(tmpAF.FieldName).AsLargeInt;
          ftBoolean:TJSONObject(tmp).Booleans[tmpAF.FieldName]:=tmpAG.Dbf.FieldByName(tmpAF.FieldName).AsBoolean;
          ftBlob:begin
            //jBlob:=TJSONObject.Create;
            //jBlob.Add('type','blob');
            //jBlob.Add('value',EncodeStringBase64(TBlobField(tmpAG.Dbf.FieldByName(tmpAF.FieldName)).AsString));
            //TJSONObject(tmp).Add(tmpAF.FieldName,jBlob);
            //图片字段值的粘贴暂时不实现，把图片字段和Image搞清楚再说。
            TJSONObject(tmp).Strings[tmpAF.FieldName]:='#';
          end;
          else TJSONObject(tmp).Strings[tmpAF.FieldName]:='#';
        end;
      end;
    end;
  end;
  result:=jData;
end;

procedure TRTFP.SetJSON_Paper(PID:RTFP_ID;data:TJSONData);
var root,attrs:TJSONObject;
    tmp:TJSONData;
    pi,pj:integer;
    objname,key,value,ori_pid,ori_ref,ori_path,folder,filename:string;
    is_blob:boolean;
begin
  if not (data is TJSONObject) then exit;
  root:=TJSONObject(data);
  BeginUpdate;
  pi:=0;
  ori_pid:='';
  ori_ref:='';
  while pi<root.Count do begin
    objname:=root.Names[pi];
    tmp:=root.Elements[objname];
    case tmp.JSONType of
      jtString:begin
        case objname of
          'sys.pid':ori_pid:=tmp.AsString;
          'sys.ref':ori_ref:=tmp.AsString;
          'sys.path':ori_path:=tmp.AsString;
        end;
      end;
      jtObject:begin
        pj:=0;
        attrs:=TJSONObject(tmp);
        while pj<attrs.Count do begin
          key:=attrs.Names[pj];
          tmp:=attrs.Elements[key];
          if tmp.JSONType=jtObject then begin
            value:=TJSONObject(tmp).Strings['value'];
            is_blob:=true;
          end else begin
            value:=tmp.AsString;
            is_blob:=false;
          end;
          case objname of
            'paper.buf','paper.dbf':begin
              case key of
                _Col_Paper_Folder_  : folder   := value;
                _Col_Paper_FileName_: filename := value;
              end;
              EditFieldAsString(key,'',PID,value,[aeForceEditIfTypeDismatch,aeCreateIfNoField]);
            end;
            else begin
              if is_blob then begin
                //图片字段值的粘贴暂时不实现，把图片字段和Image搞清楚再说。
                //没那么简单，还涉及两种图片字段的格式
              end else begin
                EditFieldAsString(key,objname,PID,value,[aeForceEditIfTypeDismatch,aeCreateIfNoField]);
              end;
            end;
          end;
          inc(pj);
        end;
      end;
    end;
    inc(pi);
  end;
  //复制备份文件 apmFullBackup;
  case lowercase(folder) of
    '','weblnk','extern':;
    else begin
      TRTFP.FileCopy(ori_path+'/paper/'+folder+'/'+filename,CurrentPathFull+'/paper/'+folder+'/'+filename,false);
    end;
  end;

  //追加跨工程引用信息
  if (ori_ref<>'') and (ori_ref<>Cite_format) then begin
    {zan}objname:=ReadFieldAsString(_Col_notes_FurtherCmt_,_Attrs_Notes_,PID,[]);
    EditFieldAsString(_Col_notes_FurtherCmt_,_Attrs_Notes_,PID,ori_ref+'_'+ori_pid+#13#10+{zan}objname,[aeForceEditIfTypeDismatch]);
  end;
  EndUpdate;
  DataChange(PID);
end;

function TRTFP.GetJSON_Image(IID:RTFP_ID):TJSONData;
begin
  result:=nil;
end;

function TRTFP.GetJSON_Notes(NID:RTFP_ID):TJSONData;
begin
  result:=nil;
end;

function TRTFP.GetJSON_Klass(klass:TKlass):TJSONData;
begin
  result:=nil;
end;

function TRTFP.GetJSON_Attrs(attrs:TAttrsGroup):TJSONData;
var jData:TJSONObject;
    tmp:TJSONData;
begin
  result:=nil;
  jData:=TJSONObject.Create;
  jData.Strings['Name']:=attrs.Name;
  jData.Booleans['Shown']:=attrs.GroupShown;
  jData.Strings['DispName']:=attrs.DisplayName;
  result:=jData;
end;

function FieldTypeToStr(ft:TFieldType):string;
begin
  case ft of
    ftString:     result:='String';
    ftSmallint:   result:='Smallint';
    ftInteger:    result:='Integer';
    ftWord:       result:='Word';
    ftBoolean:    result:='Boolean';
    ftFloat:      result:='Float';
    ftDate:       result:='Date';
    ftTime:       result:='Time';
    ftDateTime:   result:='DateTime';
    ftBlob:       result:='Blob';
    ftMemo:       result:='Memo';
    ftFmtMemo:    result:='FmtMemo';
    ftWideString: result:='WideString';
    ftLargeint:   result:='Largeint';
    ftWideMemo:   result:='WideMemo';
    else          result:='Unknown';
  end;
end;

function StrToFieldType(str:string):TFieldType;
begin
  case str of
    'String':     result:=ftString;
    'Smallint':   result:=ftSmallint;
    'Integer':    result:=ftInteger;
    'Word':       result:=ftWord;
    'Boolean':    result:=ftBoolean;
    'Float':      result:=ftFloat;
    'Date':       result:=ftDate;
    'Time':       result:=ftTime;
    'DateTime':   result:=ftDateTime;
    'Blob':       result:=ftBlob;
    'Memo':       result:=ftMemo;
    'FmtMemo':    result:=ftFmtMemo;
    'WideString': result:=ftWideString;
    'Largeint':   result:=ftLargeint;
    'WideMemo':   result:=ftWideMemo;
    else          result:=ftUnknown;
  end;
end;

function TRTFP.GetJSON_Field(field:TAttrsField):TJSONData;
var jData:TJSONObject;
    tmp:TJSONData;
    tmpAF:TAttrsField;
    stmp:string;
begin
  result:=nil;
  jData:=TJSONObject.Create;
  jData.Strings['Name']:=field.FieldName;
  jData.Booleans['Shown']:=field.Shown;
  jData.Strings['Type']:=FieldTypeToStr(field.FieldDef.DataType);
  jData.Int64s['Size']:=field.FieldDef.Size;
  tmp:=GetJSON(field.FieldDisplayOption.SaveToJSON);
  jData.Add('display',tmp);
  tmp:=TJSONArray.Create;
  jData.Add('combo',tmp);
  for stmp in field.ComboItem do TJSONArray(tmp).Add(stmp);
  result:=jData;
end;



