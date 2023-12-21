//文献节点方法

function TRTFP.NewPaperID:RTFP_ID;
var num:dword;
begin
  FPaperDB.Last;
  if FPaperDB.BOF then num:=0
  else num:=TRTFP.IDToNum((FPaperDB.FieldByName(_Col_PID_).AsString));
  inc(num);
  result:=TRTFP.NumToID(num);
end;

function TRTFP.AddPaper_Reference:RTFP_ID;
var PID:RTFP_ID;
begin
  result:='000000';
  BeginUpdate;
  PID:=NewPaperID;
  with FPaperDB do begin
    Append;
    FieldByName(_Col_PID_).AsString:=PID;
    FieldByName(_Col_Paper_Is_Backup_).AsBoolean:=false;
    FieldByName(_Col_Paper_Folder_).AsString:='';
    FieldByName(_Col_Paper_FileName_).AsString:='';
    FieldByName(_Col_Paper_FileSize_).AsLargeInt:=0;
    FieldByName(_Col_Paper_FileHash_).AsString:='';
    Post;
  end;
  EditFieldAsString(_Col_basic_Link_,_Attrs_Basic_,PID,'',[]);
  EditFieldAsBoolean(_Col_class_Is_Read_,_Attrs_Class_,PID,false,[]);
  EditFieldAsInteger(_Col_notes_User_,_Attrs_Notes_,PID,0,[]);
  EditFieldAsDateTime(_Col_notes_CreateTime_,_Attrs_Notes_,PID,Now,[]);
  EditFieldAsDateTime(_Col_notes_ModifyTime_,_Attrs_Notes_,PID,Now,[]);
  EditFieldAsDateTime(_Col_notes_CheckTime_,_Attrs_Notes_,PID,Now,[]);
  EndUpdate;
  RecordChange;
  result:=PID;
end;

function TRTFP.AddPaper_Website(website:string):RTFP_ID;
var PID:RTFP_ID;
begin
  result:='000000';
  BeginUpdate;
  PID:=NewPaperID;
  with FPaperDB do begin
    Append;
    FieldByName(_Col_PID_).AsString:=PID;
    FieldByName(_Col_Paper_Is_Backup_).AsBoolean:=false;
    FieldByName(_Col_Paper_Folder_).AsString:='weblnk';
    FieldByName(_Col_Paper_FileName_).AsString:=website;
    FieldByName(_Col_Paper_FileSize_).AsLargeInt:=0;
    FieldByName(_Col_Paper_FileHash_).AsString:='';
    Post;
  end;
  EditFieldAsString(_Col_basic_Link_,_Attrs_Basic_,PID,website,[]);
  EditFieldAsBoolean(_Col_class_Is_Read_,_Attrs_Class_,PID,false,[]);
  EditFieldAsInteger(_Col_notes_User_,_Attrs_Notes_,PID,0,[]);
  EditFieldAsDateTime(_Col_notes_CreateTime_,_Attrs_Notes_,PID,Now,[]);
  EditFieldAsDateTime(_Col_notes_ModifyTime_,_Attrs_Notes_,PID,Now,[]);
  EditFieldAsDateTime(_Col_notes_CheckTime_,_Attrs_Notes_,PID,Now,[]);
  EndUpdate;
  RecordChange;
  result:=PID;
end;

function TRTFP.AddPaper_Address(fullfilename:string;get_hash:boolean):RTFP_ID;
var PID:RTFP_ID;
    FileName,FileHash:string;
    tmpPDF:TRTFP_PDF;
begin
  result:='000000';
  if not FileExists(fullfilename) then begin ShowMsgOK('新建文献','文件路径无效，无法创建文献节点。');exit;end;
  if length(fullfilename)>240 then begin ShowMsgOK('新建文献','文件路径过长，无法创建文献节点。');exit;end;
  if get_hash then FileName:=fullfilename else FileName:='';

  tmpPDF:=TRTFP_PDF.Create(nil,FileName,Tag['文件哈希方法']);
  PID:=NewPaperID;
  BeginUpdate;
  try
    if get_hash then FileHash:=tmpPDF.Hash else FileHash:='';
    tmpPDF.Size:=FileSize(fullfilename);
    with FPaperDB do begin
      Append;
      FieldByName(_Col_PID_).AsString:=PID;
      FieldByName(_Col_Paper_Is_Backup_).AsBoolean:=false;
      FieldByName(_Col_Paper_Folder_).AsString:='extern';
      FieldByName(_Col_Paper_FileName_).AsString:=fullfilename;
      FieldByName(_Col_Paper_FileSize_).AsLargeInt:=tmpPDF.Size;
      FieldByName(_Col_Paper_FileHash_).AsString:=FileHash;
      Post;
    end;
    if get_hash then with FFieldList.FindItemByName(_Attrs_Metas_).Dbf do begin
      if not Active then Open;
      if Locate(_Col_PID_,PID,[]) then Edit
      else begin
        Append;
        FieldByName(_Col_PID_).AsString:=PID;
      end;
      FieldByName(_Col_metas_Title_  ).AsString := tmpPDF.Meta.pFields['DocInfo:Title']^;
      FieldByName(_Col_metas_Authors_).AsString := tmpPDF.Meta.pFields['DocInfo:Author']^;
      FieldByName(_Col_metas_Subject_).AsString := tmpPDF.Meta.pFields['DocInfo:Subject']^;
      FieldByName(_Col_metas_Keyword_).AsString := tmpPDF.Meta.pFields['DocInfo:Keywords']^;
      FieldByName(_Col_metas_Creator_).AsString := tmpPDF.Meta.pFields['DocInfo:Creator']^;
      FieldByName(_Col_metas_Produce_).AsString := tmpPDF.Meta.pFields['DocInfo:Producer']^;
      FieldByName(_Col_metas_CreDate_).AsString := tmpPDF.Meta.pFields['DocInfo:CreationDate']^;
      FieldByName(_Col_metas_ModDate_).AsString := tmpPDF.Meta.pFields['DocInfo:ModDate']^;
      Post;
    end;
    EditFieldAsString(_Col_basic_Link_,_Attrs_Basic_,PID,fullfilename,[]);
    EditFieldAsBoolean(_Col_class_Is_Read_,_Attrs_Class_,PID,false,[]);
    EditFieldAsInteger(_Col_notes_User_,_Attrs_Notes_,PID,0,[]);
    EditFieldAsDateTime(_Col_notes_CreateTime_,_Attrs_Notes_,PID,Now,[]);
    EditFieldAsDateTime(_Col_notes_ModifyTime_,_Attrs_Notes_,PID,Now,[]);
    EditFieldAsDateTime(_Col_notes_CheckTime_,_Attrs_Notes_,PID,Now,[]);
  finally
    EndUpdate;
    RecordChange;
    tmpPDF.Free;
  end;
  result:=PID;
end;

function TRTFP.AddPaper_Backup(fullfilename:string;cut_origin:boolean):RTFP_ID;
const caption_bak_exists = '相同的备份路径';
      prompts_bak_exists = '正在导入的文件“%s”的默认备份地址“%s”已存在文件，覆盖保存会导致两个文献节点共用一个备份文件，旧有文件将无法恢复。是否覆盖？';

var PID:RTFP_ID;
    DateDir,TargetDir,FileName,BackupFullName:string;
    tmpPDF:TRTFP_PDF;
begin
  result:='000000';
  if not FileExists(fullfilename) then begin ShowMsgOK('新建文献','文件路径无效，无法创建文献节点。');exit;end;
  DateDir:=TRTFP.GetDateDir;
  FileName:=ExtractFileName(fullfilename);
  TargetDir:=FFilePath+FRootFolder+'/paper/'+DateDir;
  BackupFullName:=TargetDir+'/'+FileName;
  if length(BackupFullName)>240 then begin ShowMsgOK('新建文献','文件路径过长，无法创建文献节点。');exit;end;
  if FileExists(BackupFullName) then
    case ShowMsgYesNoAll(caption_bak_exists,Format(prompts_bak_exists,[fullfilename,BackupFullName]),true) of
      'Yes':;
      'No':exit;
    end;

  tmpPDF:=TRTFP_PDF.Create(nil,fullfilename,Tag['文件哈希方法']);
  PID:=NewPaperID;
  BeginUpdate;
  try
    with FPaperDB do begin
      Append;
      FieldByName(_Col_PID_).AsString:=PID;
      FieldByName(_Col_Paper_Is_Backup_).AsBoolean:=true;
      FieldByName(_Col_Paper_Folder_).AsString:=DateDir;
      FieldByName(_Col_Paper_FileName_).AsString:=FileName;
      FieldByName(_Col_Paper_FileSize_).AsLargeInt:=tmpPDF.Size;
      FieldByName(_Col_Paper_FileHash_).AsString:=tmpPDF.Hash;
      Post;
    end;

    EditFieldAsString(_Col_basic_doi_,_Attrs_Basic_,PID,'',[]);
    EditFieldAsBoolean(_Col_class_Is_Read_,_Attrs_Class_,PID,false,[]);
    EditFieldAsInteger(_Col_notes_User_,_Attrs_Notes_,PID,0,[]);
    EditFieldAsDateTime(_Col_notes_CreateTime_,_Attrs_Notes_,PID,Now,[]);
    EditFieldAsDateTime(_Col_notes_ModifyTime_,_Attrs_Notes_,PID,Now,[]);
    EditFieldAsDateTime(_Col_notes_CheckTime_,_Attrs_Notes_,PID,Now,[]);

    with FFieldList.FindItemByName(_Attrs_Metas_).Dbf do begin
      if not Active then Open;
      if Locate(_Col_PID_,PID,[]) then Edit
      else begin
        Append;
        FieldByName(_Col_PID_).AsString:=PID;
      end;
      FieldByName(_Col_metas_Title_  ).AsString := tmpPDF.Meta.pFields['DocInfo:Title']^;
      FieldByName(_Col_metas_Authors_).AsString := tmpPDF.Meta.pFields['DocInfo:Author']^;
      FieldByName(_Col_metas_Subject_).AsString := tmpPDF.Meta.pFields['DocInfo:Subject']^;
      FieldByName(_Col_metas_Keyword_).AsString := tmpPDF.Meta.pFields['DocInfo:Keywords']^;
      FieldByName(_Col_metas_Creator_).AsString := tmpPDF.Meta.pFields['DocInfo:Creator']^;
      FieldByName(_Col_metas_Produce_).AsString := tmpPDF.Meta.pFields['DocInfo:Producer']^;
      FieldByName(_Col_metas_CreDate_).AsString := tmpPDF.Meta.pFields['DocInfo:CreationDate']^;
      FieldByName(_Col_metas_ModDate_).AsString := tmpPDF.Meta.pFields['DocInfo:ModDate']^;
      Post;
    end;
  finally
    EndUpdate;
    RecordChange;
    result:=PID;
    tmpPDF.Free;
  end;
  //在析构tmpPDF之后最后移动或复制文件
  if result<>'000000' then begin
    ForceDirectories(TargetDir);
    if cut_origin then
      TRTFP.FileMove(fullfilename,BackupFullName,false)
    else
      TRTFP.FileCopy(fullfilename,BackupFullName,false);
  end;
end;

function TRTFP.AddPaper(fullfilename:string;AddPaperMethod:TAddPaperMethod=apmFullBackup):RTFP_ID;//新增一个文献到工程
begin
  case AddPaperMethod of
    apmFullBackup: result:=AddPaper_Backup(fullfilename,false);
    apmCutBackup : result:=AddPaper_Backup(fullfilename,true);
    apmWebsite:    result:=AddPaper_Website(fullfilename);
    apmReference:  result:=AddPaper_Reference;
    apmAddress:    result:=AddPaper_Address(fullfilename,false);
  end;

end;

function TRTFP.CompareFile(hash1,fn1,fn2:string;empty_hash_rebuild:boolean=false):boolean;
var rc:integer;//哈希计算的次数返回
    fs1,fs2:TFileStream;
begin
  result:=false;
  if (hash1='') and (not empty_hash_rebuild) then exit;
  if FileSize(fn1)<>FileSize(fn2) then exit;
  fs1:=TFileStream.Create(fn1,fmOpenRead);
  fs2:=TFileStream.Create(fn2,fmOpenRead);
  try
    if hash1='' then hash1:=TRTFP_PDF.CalcHash(fs1,rc,Self.Tag['文件哈希方法']);
    if hash1<>TRTFP_PDF.CalcHash(fs2,rc,Self.Tag['文件哈希方法']) then exit;
    fs1.Position:=0;
    fs2.Position:=0;
    while fs1.Position<fs1.Size do begin
      {$ifdef cpu64}
      if fs1.Size-fs1.Position>=8 then begin
        if fs1.ReadQWord<>fs2.ReadQWord then exit;
      end
      {$else}
      if fs1.Size-fs1.Position>=4 then begin
        if fs1.ReadDWord<>fs2.ReadDWord then exit;
      end
      {$endif}
      else begin
        if fs1.ReadByte<>fs2.ReadByte then exit;
      end;
    end;
  finally
    fs1.Free;
    fs2.Free;
  end;
  result:=true;
end;

function TRTFP.FindPaper(fullfilename:string):RTFP_ID;//查找具体文件在工程中的PID，未找到返回000000
var PID:RTFP_ID;
    fn1,fn2,hash:string;
begin
  PID:='';
  with FPaperDB do begin
    First;
    repeat
      if not FieldByName(_Col_Paper_Is_Backup_).AsBoolean then begin Next;continue;end;//只检测备份节点的hash
      hash:=FieldByName(_Col_Paper_FileHash_).AsString;
      fn1:=FFilePath+FRootFolder+'/paper/'+FieldByName(_Col_Paper_Folder_).AsString+'/'+FieldByName(_Col_Paper_FileName_).AsString;
      fn2:=fullfilename;
      if not FileExists(fn1) then begin Next;continue;end;
      if CompareFile(hash,fn1,fn2) then begin
        PID:=FieldByName(_Col_PID_).AsString;
      end;
      Next;
    until EOF or (PID<>'');
  end;
  if PID='' then result:='000000' else result:=PID;
end;

function TRTFP.DeletePaper(PID:RTFP_ID;PreserveFileNoAsk:boolean=false):boolean;//移除指定PID的文献
var AG:TAttrsGroup;
    klass_list:TStringList;
    klass_name:string;
    tmpKL:TKlass;
begin
  result:=false;
  if not TRTFP.IsRTFPID(PID) then exit;
  if not FPaperDB.Active then FPaperDB.Open;
  if LocatePID(FPaperDB,PID) then with FPaperDB do begin
    if FieldByName(_Col_Paper_Is_Backup_).AsBoolean then
      if not PreserveFileNoAsk then
        case ShowMsgYesNoAll('删除确认','删除文献节点对应的文件可能会导致其他共用此文件的节点失去文件连接，并且操作后无法恢复，是否继续？',true) of
          'Yes':TRTFP.FileDelete(FFilePath+FRootFolder+'/paper/'+FieldByName(_Col_Paper_Folder_).AsString+'/'+FieldByName(_Col_Paper_FileName_).AsString);
          else ;
        end
      else ;//PreserveFileNoAsk=true时直接不删除
    Delete;
  end;
  klass_list:=TStringList.Create;
  try
    GetPaperKlass(PID,klass_list);
    for klass_name in klass_list do begin
      tmpKL:=FindKlass(klass_name,'.');
      KlassExclude(tmpKL,PID);
    end;
  finally
    klass_list.Free;
  end;
  for AG in FFieldList do
    begin
      if not AG.Dbf.Active then AG.Dbf.Open;
      if LocatePID(AG.Dbf,PID) then AG.Dbf.Delete;
      AG.Modified:=true;
    end;
  RecordChange;
  result:=true;
end;

function TRTFP.MergePaper(PID_Main,PID_Vice:RTFP_ID;AFieldSelectOption:TFieldSelectOptions):boolean;
var b1,b2:boolean;
    f1,f2,n1,n2,h1,h2:string;
    s1,s2:int64;
    UseVicePaperAttr:boolean;
    tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
    tmpOpt:PFieldSelectOption;
    stmp:string;
    klass_list:TStringList;
    tmpKL:TKlass;
    function FindFieldOpt(AField:TAttrsField):PFieldSelectOption;
    var index:integer;
    begin
      with AFieldSelectOption do
        for index:=0 to Count-1 do
          begin
            result:=PFieldSelectOption(Items[index]);
            if result^.field=AField then exit;
          end;
      result:=nil;
    end;

begin
  result:=false;
  s1:=0;s2:=0;
  if TRTFP.IsRTFPID(PID_Main) and TRTFP.IsRTFPID(PID_Vice) then ELSE exit;
  with FPaperDB do
    begin
      if not Active then Open;
      if not LocatePID(FPaperDB,PID_Vice) then exit;
      b2:=FieldByName(_Col_Paper_Is_Backup_).AsBoolean;
      f2:=FieldByName(_Col_Paper_Folder_).AsString;
      n2:=FieldByName(_Col_Paper_FileName_).AsString;
      h2:=FieldByName(_Col_Paper_FileHash_).AsString;
      s2:=FieldByName(_Col_Paper_FileSize_).AsLargeInt;
      if not LocatePID(FPaperDB,PID_Main) then exit;
      b1:=FieldByName(_Col_Paper_Is_Backup_).AsBoolean;
      f1:=FieldByName(_Col_Paper_Folder_).AsString;
      n1:=FieldByName(_Col_Paper_FileName_).AsString;
      h1:=FieldByName(_Col_Paper_FileHash_).AsString;
      s1:=FieldByName(_Col_Paper_FileSize_).AsLargeInt;
      if (f2='') and (f1<>'') then begin
        UseVicePaperAttr:=false;
      end else if (f2<>'') and (f1='') then begin
        UseVicePaperAttr:=true;
      end else begin
        if (s1<>s2) or (h1<>h2) then
          case ShowMsgYesNoAll('合并','两个文献节点均有链接文件，是否用副节点备份文献替换主节点备份？') of
            'Yes':UseVicePaperAttr:=true;
            else UseVicePaperAttr:=false;
          end
        else UseVicePaperAttr:=false;
      end;
      if UseVicePaperAttr then begin
        Edit;
        FieldByName(_Col_Paper_Is_Backup_).AsBoolean:=b2;
        FieldByName(_Col_Paper_Folder_).AsString:=f2;
        FieldByName(_Col_Paper_FileName_).AsString:=n2;
        FieldByName(_Col_Paper_FileHash_).AsString:=h2;
        FieldByName(_Col_Paper_FileSize_).AsLargeInt:=s2;
        Post;
      end;
    end;
  for tmpAG in FieldList do
    begin
      for tmpAF in tmpAG.FieldList do
        begin
           tmpOpt:=FindFieldOpt(tmpAF);
           if tmpOpt<>nil then
             begin
               if (tmpAG.Name=_Attrs_Class_) and (tmpAF.FieldDef.DataType=ftMemo) then continue;//分类字段另外合并
               case tmpOpt^.select_mode of
                 fsmNone:{暂时还没有删除字段的方法};
                 fsmMain:{啥也不做};
                 fsmVice:
                   begin
                     stmp:=ReadFieldAsString(tmpAF.FieldName,tmpAG.Name,PID_Vice,[]);
                     EditFieldAsString(tmpAF.FieldName,tmpAG.Name,PID_Main,stmp,[aeForceEditIfTypeDismatch]);
                   end;
                 fsmBoth:
                   begin
                     stmp:=ReadFieldAsString(tmpAF.FieldName,tmpAG.Name,PID_Main,[]);
                     stmp:=stmp+#13#10+ReadFieldAsString(tmpAF.FieldName,tmpAG.Name,PID_Vice,[]);
                     EditFieldAsString(tmpAF.FieldName,tmpAG.Name,PID_Main,stmp,[]);
                   end;
               end;
             end;
        end;
    end;
  klass_list:=TStringList.Create;
  try
    GetPaperKlass(PID_Vice,klass_list);
    for stmp in klass_list do begin
      tmpKL:=FindKlass(stmp,'.');
      KlassInclude(tmpKL,PID_Main);

    end;
  finally
    klass_list.Free;
  end;
  result:=DeletePaper(PID_Vice,true);
end;


procedure TRTFP.OpenPaper(PID:RTFP_ID;exename:string='');
var filename:string;
begin
  //这里没有性能要求，可以直接改成ReadBasicField
  with FPaperDB do begin
    if not Active then Open;
    if not LocatePID(FPaperDB,PID) then exit;
    if FieldByName(_Col_Paper_Is_Backup_).AsBoolean then
      filename:={Utf8ToWinCP}(FFilePath+FRootFolder+'/paper/'
        +FieldByName(_Col_Paper_Folder_).AsString+'/'
        +FieldByName(_Col_Paper_FileName_).AsString)
    else begin
      case FieldByName(_Col_Paper_Folder_).AsString of
        'extern':filename:={Utf8ToWinCP}(FieldByName(_Col_Paper_FileName_).AsString);
        'weblnk':
          begin
            filename:=ReadFieldAsString(_Col_basic_Link_,_Attrs_Basic_,PID,[]);
            if filename='' then filename:=ReadFieldAsString(_Col_basic_doi_,_Attrs_Basic_,PID,[]);
          end;
        else begin ShowMsgOK('警告','非备份文献节点不能通过此方法打开！');exit;end;
      end;
    end;
    if filename<>'' then TRTFP.OpenFile(filename,exename);
  end;
end;

procedure TRTFP.OpenPaperAsPDF(PID:RTFP_ID);
begin
  OpenPaper(PID,OpenPdfExe);
end;

procedure TRTFP.OpenPaperAsCAJ(PID:RTFP_ID);
begin
  OpenPaper(PID,OpenCajExe);
end;

procedure TRTFP.OpenPaperDir(PID:RTFP_ID);
var filename:string;
begin
  with FPaperDB do begin
    if not Active then Open;
    if not LocatePID(FPaperDB,PID) then exit;
    if FieldByName(_Col_Paper_Is_Backup_).AsBoolean then
      filename:={Utf8ToWinCP}(FFilePath+FRootFolder+'/paper/'
        +FieldByName(_Col_Paper_Folder_).AsString+'/'
        +FieldByName(_Col_Paper_FileName_).AsString)
    else begin
      case FieldByName(_Col_Paper_Folder_).AsString of
        'extern':filename:={Utf8ToWinCP}(FieldByName(_Col_Paper_FileName_).AsString);
        else begin ShowMsgOK('警告','非备份文献节点不能通过此方法打开！');exit;end;
      end;
    end;
    TRTFP.OpenDir(filename);
  end;
end;

procedure TRTFP.OpenPaperLink(PID:RTFP_ID);
var linkage:string;
begin
  linkage:=ReadFieldAsString(_Col_basic_Link_,_Attrs_Basic_,PID,[]);
  if linkage<>'' then TRTFP.OpenLink(Linkage);
end;




