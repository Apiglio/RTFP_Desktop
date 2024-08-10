//用于压缩储存和格式转换的文件定义
//使用zip压缩格式

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

procedure TRTFP.ZTFP_Importer(fullfilename:string;importToEmptyProject:boolean);
var zf:TUnZipper;
    unzip_temp_path:string;
    //user_list:TStringList;
    info_json:TFileStream;
    project_info,jtmp,jtmp_2,jtmp_3,jtmp_4,jtmp_5:TJSONData;
    import_project_id,AGN,AFN,KLS,TYP,PID,FN1,FN2:string;
    SIZ:integer;
    len,acc,len_2,acc_2,len_3,acc_3:integer;
    tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;

begin
  //如果在是新建的工程，就复制全部字段和分类信息，否则查重，用户重新构建

  //前期文件夹清理工作
  unzip_temp_path:=CurrentPathFull+'import_temp';
  if DirectoryExists(unzip_temp_path) then DeleteDirectory(unzip_temp_path,true);
  ForceDirectories(unzip_temp_path);

  zf:=TUnZipper.Create;
  zf.FileName:=fullfilename;
  //user_list:=TStringList.Create;
  //暂时是单用户，不需要涉及用户归并
  BeginUpdate;
  try
    zf.OutputPath:=unzip_temp_path;
    zf.Examine;
    zf.UnZipAllFiles;
    for acc:=zf.Entries.Count-1 downto 0 do begin
      //unzip文件名编码需要手动改名，真搞笑
      {tmp}AFN:=zf.Entries.Entries[acc].ArchiveFileName;
      {tmp}AGN:=WinCPToUTF8({tmp}AFN);
      TRTFP.FileRename(unzip_temp_path+'/'+{tmp}AFN,unzip_temp_path+'/'+{tmp}AGN);
    end;
    project_info:=nil;
    info_json:=TFileStream.Create(unzip_temp_path+'/'+'info.json',fmOpenRead);
    try
      info_json.Position:=0;
      project_info:=GetJSON(info_json);

      //基础信息部分
      import_project_id:='';
      jtmp:=TJSONObject(project_info).Objects['tags'];
      if jtmp<>nil then begin
        import_project_id:='';
        jtmp_2:=TJSONObject(jtmp).Find('引注标识码');
        if (jtmp_2<>nil) and (jtmp_2 is TJSONString) then begin
          import_project_id:=jtmp_2.AsString;
          if importToEmptyProject then Tag['引注标识码']:=import_project_id;
        end;
        if import_project_id='' then begin
          jtmp_2:=TJSONObject(jtmp).Find('工程标题');
          if (jtmp_2<>nil) and (jtmp_2 is TJSONString) then import_project_id:=jtmp_2.AsString;
        end;
      end;

      //用户列表暂时不导入
      //format部分暂时不导入

      //属性组与字段部分
      jtmp:=TJSONObject(project_info).Arrays['attributes'];
      if jtmp<>nil then begin
        len:=TJSONArray(jtmp).Count;
        for acc:=0 to len-1 do begin
          jtmp_2:=TJSONArray(jtmp).Items[acc];
          if not (jtmp_2 is TJSONObject) then continue;
          AGN:='';
          jtmp_3:=TJSONObject(jtmp_2).Find('Name');
          if (jtmp_3<>nil) and (jtmp_3 is TJSONString) then AGN:=jtmp_3.AsString;
          if AGN='' then continue;
          tmpAG:=FindAttrs(AGN);
          if tmpAG=nil then begin
            //新建属性组，同时也导入属性组设置
            tmpAG:=AddAttrs(AGN);
            if tmpAG<>nil then begin
              jtmp_3:=TJSONObject(jtmp_2).Find('Shown');
              if (jtmp_3<>nil) and (jtmp_2 is TJSONBoolean) then tmpAG.GroupShown:=jtmp_3.AsBoolean;
              jtmp_3:=TJSONObject(jtmp_2).Find('DispName');
              if (jtmp_3<>nil) and (jtmp_3 is TJSONString) then tmpAG.DisplayName:=jtmp_3.AsString;
            end;
          end;
          if tmpAG<>nil then begin
            jtmp_3:=TJSONObject(jtmp_2).Arrays['fields'];
            if jtmp_3<>nil then begin
              len_2:=TJSONArray(jtmp_3).Count;
              for acc_2:=0 to len_2-1 do begin
                jtmp_4:=TJSONArray(jtmp_3).Items[acc_2];
                if not (jtmp_4 is TJSONObject) then continue;
                AFN:='';
                jtmp_5:=TJSONObject(jtmp_4).Find('Name');
                if (jtmp_5<>nil) and (jtmp_5 is TJSONString) then AFN:=jtmp_5.AsString;
                if AFN='' then continue;
                tmpAF:=FindField(AFN,AGN);
                if tmpAF=nil then begin
                  //新建字段列，同时也导入字段列设置
                  TYP:='Memo';
                  jtmp_5:=TJSONObject(jtmp_4).Find('Type');
                  if (jtmp_5<>nil) and (jtmp_5 is TJSONString) then TYP:=jtmp_5.AsString;
                  SIZ:=0;
                  jtmp_5:=TJSONObject(jtmp_4).Find('Size');
                  if (jtmp_5<>nil) and (jtmp_5 is TJSONIntegerNumber) then SIZ:=jtmp_5.AsInteger;
                  tmpAF:=AddField(AFN,AGN,StrToFieldType(TYP),SIZ);
                  if tmpAF<>nil then begin
                    jtmp_5:=TJSONObject(jtmp_4).Objects['display'];
                    if jtmp_5<>nil then tmpAF.FFieldDisplayOption.LoadFromJSON(jtmp_5.AsJSON);
                    jtmp_5:=TJSONObject(jtmp_4).Arrays['combo'];
                    if jtmp_5<>nil then begin
                      len_3:=TJSONArray(jtmp_5).Count;
                      for acc_3:=0 to len_3-1 do tmpAF.ComboItem.Add(TJSONArray(jtmp_5).Items[acc_3].AsString);
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
      //too ugly

      //分类部分info json还没涉及，暂时先不写

      //导入paper部分（images和notes部分基于papers一并导入）
      jtmp:=TJSONObject(project_info).Arrays['papers'];
      if jtmp<>nil then begin
        len:=TJSONArray(jtmp).Count;
        for acc:=0 to len-1 do begin
          jtmp_2:=TJSONArray(jtmp).Items[acc];
          if not (jtmp_2 is TJSONObject) then continue;

          jtmp_3:=TJSONObject(jtmp_2).Find('sys.pid');
          if (jtmp_3<>nil) and (jtmp_3 is TJSONString) then PID:=TJSONString(jtmp_3).AsString;
          if PID='' then PID:='000000';

          jtmp_3:=TJSONObject(jtmp_2).Find('paper.buf');
          if jtmp_3=nil then jtmp_3:=TJSONObject(jtmp_2).Find('paper.dbf');
          if (jtmp_3<>nil) and (jtmp_3 is TJSONObject) then begin
            {tmp}AGN:='';
            {tmp}AFN:='';
            jtmp_4:=TJSONObject(jtmp_3).Find(_Col_Paper_Folder_);
            if (jtmp_4<>nil) and (jtmp_4 is TJSONString) then {tmp}AGN:=jtmp_4.AsString;
            jtmp_4:=TJSONObject(jtmp_3).Find(_Col_Paper_FileName_);
            if (jtmp_4<>nil) and (jtmp_4 is TJSONString) then {tmp}AFN:=jtmp_4.AsString;

            if importToEmptyProject then begin
              MakeSurePaperID(PID);
            end else begin
              PID:=AddPaper('',apmReference);
            end;
            SetJSON_Paper(PID,jtmp_2,true);
            case {tmp}AGN of '','weblnk','extern':; else begin
              FN1:=unzip_temp_path+'/'+'paper'+'/'+{tmp}AGN+'/'+{tmp}AFN;
              FN2:=TRTFP.FileNameUniq(CurrentPathFull+'paper'+'/'+{tmp}AGN,{tmp}AFN);
              ForceDirectories(CurrentPathFull+'paper'+'/'+{tmp}AGN);
              TRTFP.FileMove(FN1,CurrentPathFull+'paper'+'/'+{tmp}AGN+'/'+FN2,false);
              EditBasicString(_Col_Paper_Folder_,PID,{tmp}AGN);
              EditBasicString(_Col_Paper_FileName_,PID,FN2);
            end;end;
          end;

        end;
      end;
      //too ugly


    finally
      if project_info<>nil then project_info.Free;
      info_json.Free;
    end;
    DeleteDirectory(unzip_temp_path,false);

  finally
    EndUpdate;
    FieldAndRecordChange;
    //ClassChange;
    //UsersChange;
    //FormatListChange;
    zf.Free;
  end;
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

procedure TRTFP.SetJSON_Paper(PID:RTFP_ID;data:TJSONData;DoNotBackup:boolean=false);
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
                _Col_Paper_Folder_:
                begin
                  case value of
                    '','extern','weblnk':folder:=value;
                    else if (not DoNotBackup) then folder:=value;
                  end;
                  //额外备份需要新创建月份文件夹，所以跳过
                end;
                _Col_Paper_FileName_:filename:=value;
              end;
              EditFieldAsString(key,'',PID,value,[aeForceEditIfTypeDismatch,aeCreateIfNoField]);
            end;
            else begin
              if is_blob then begin
                //图片字段值的粘贴暂时不实现，把图片字段和Image搞清楚再说。
                //没那么简单，还涉及两种图片字段的格式
              end else begin
                case GetFieldType(objname,key) of
                  ftInteger,ftLargeint,ftSmallint,ftWord,ftFloat:
                    if not (value='#') then
                      EditFieldAsString(key,objname,PID,value,[aeForceEditIfTypeDismatch,aeCreateIfNoField]);
                  else EditFieldAsString(key,objname,PID,value,[aeForceEditIfTypeDismatch,aeCreateIfNoField]);
                end;
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
  IF NOT DoNotBackup THEN BEGIN
    case lowercase(folder) of
      '','weblnk','extern':;
      else begin
        TRTFP.FileCopy(ori_path+'/paper/'+folder+'/'+filename,CurrentPathFull+'/paper/'+folder+'/'+filename,false);
      end;
    end;
  END;
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



