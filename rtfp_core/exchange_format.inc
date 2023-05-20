//用于压缩储存和格式转换的文件定义
//使用zip压缩格式

procedure TRTFP.ZTFP_Importer(fullfilename:string);
begin
  //FDataSetType:=aDataSetType;
  //这里准备把FDataSetType改成property
  //New();
end;

procedure TRTFP.ZTFP_Exporter(fullfilename:string);
var zf:TZipper;
    stmp,path_base,stored_name:string;
    path_base_len:integer;
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
    path_base:=GetCurrentPathFull+'paper';
    path_base_len:=length(path_base)+1;
    FindAllFiles(filelist,path_base,'',true,faAnyFile);
    for stmp in filelist do begin
      stored_name:=stmp;
      delete(stored_name,1,path_base_len);
      stored_name:='paper\'+stored_name;
      zf.Entries.AddFileEntry(stmp,Utf8ToWinCP(stored_name));
    end;
    filelist.Clear;
    path_base:=GetCurrentPathFull+'image';
    path_base_len:=length(path_base)+1;
    FindAllFiles(filelist,path_base,'',true,faAnyFile);
    for stmp in filelist do begin
      stored_name:=stmp;
      delete(stored_name,1,path_base_len);
      stored_name:='image\'+stored_name;
      zf.Entries.AddFileEntry(stmp,Utf8ToWinCP(stored_name));
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
  jData.Strings['PID']:=PID;
  tmp:=TJSONObject.Create;
  case FDataSetType of
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
            jBlob:=TJSONObject.Create;
            jBlob.Add('type','blob');
            jBlob.Add('value',EncodeStringBase64(TBlobField(tmpAG.Dbf.FieldByName(tmpAF.FieldName)).AsString));
            TJSONObject(tmp).Add(tmpAF.FieldName,jBlob);
          end;
          else TJSONObject(tmp).Strings[tmpAF.FieldName]:='#';
        end;
      end;
    end;
  end;
  result:=jData;
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



