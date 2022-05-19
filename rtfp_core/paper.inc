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

function TRTFP.AddPaper(fullfilename:string;AddPaperMethod:TAddPaperMethod=apmFullBackup):RTFP_ID;//新增一个文献到工程
var PID:RTFP_ID;
    DateDir,TargetDir,FileName:string;
    tmpPDF:TRTFP_PDF;
    //is_updating:boolean;
begin
  result:='000000';
  if not (AddPaperMethod in [apmFullBackup,apmCutBackup,apmReference,apmAddress]) then
    begin
      assert(false,'暂不支持apmWebsite的方式。');
      exit;
    end;

  tmpPDF:=TRTFP_PDF.Create(nil);
  TRY

    IF fullfilename<>'' THEN BEGIN
      case AddPaperMethod of
        apmFullBackup,apmCutBackup:
          begin
            DateDir:=TRTFP.GetDateDir;
            FileName:=ExtractFileName(fullfilename);
            TargetDir:=FFilePath+FRootFolder+'\paper\'+DateDir;
            if FileExists(TargetDir+'\'+FileName) then
              case ShowMsgYesNoAll('相同的备份路径','正在导入的文件“'+fullfilename
              +'”的默认备份地址存在重名，覆盖会导致两个文献节点共用一个备份文件。'
              +'若两个文件不相同，会导致旧版本备份文件被覆盖，且难以复原。'
              +'是否覆盖？',true) of
                'Yes':{do nothing};
                'No':exit;
            end;
          end;
        apmAddress:
          begin
            DateDir:='extern';
            FileName:=fullfilename;
            if length(FileName)>240 then exit;
            //TargetDir:=FFilePath+FRootFolder+'\paper\'+DateDir;
          end;
      end;
      tmpPDF.LoadPdf(fullfilename);
    END ELSE BEGIN
      if AddPaperMethod in [apmFullBackup,apmCutBackup,apmAddress] then exit;
      DateDir:='';
      FileName:='';
    END;

    //is_updating:=IsUpdating;
    //if not is_updating then BeginUpdate;
    BeginUpdate;

    PID:=NewPaperID;
    //FPaperDB.Last;//此时游标已经在Last位置
    with FPaperDB do begin
      Append;//Insert;
      FieldByName(_Col_PID_).AsString:=PID;
      FieldByName(_Col_Paper_Is_Backup_).AsBoolean:=(AddPaperMethod in [apmFullBackup,apmCutBackup]);
      FieldByName(_Col_Paper_Folder_).AsString:=DateDir;
      FieldByName(_Col_Paper_FileName_).AsString:=FileName;
      FieldByName(_Col_Paper_FileSize_).AsLargeInt:=tmpPDF.Size;
      FieldByName(_Col_Paper_FileHash_).AsString:=tmpPDF.Hash;
      Post;
    end;

    //0-文献基本信息要专门的算法
    EditFieldAsString(_Col_basic_doi_,_Attrs_Basic_,PID,'',[]);

    //1-分类
    EditFieldAsBoolean(_Col_class_Is_Read_,_Attrs_Class_,PID,false,[]);

    //2-注解
    //这里之后要考虑不是pdf或者pdf读取错误的情况
    //这不是一个好做法，会大量浪费算力，但是现在先让他爬起来吧，再优化，现在再优化需要考虑TAttrsGroup.Modified
    EditFieldAsInteger(_Col_notes_User_,_Attrs_Notes_,PID,0,[]);
    EditFieldAsDateTime(_Col_notes_CreateTime_,_Attrs_Notes_,PID,Now,[]);
    EditFieldAsDateTime(_Col_notes_ModifyTime_,_Attrs_Notes_,PID,Now,[]);
    EditFieldAsDateTime(_Col_notes_CheckTime_,_Attrs_Notes_,PID,Now,[]);

    //3-元数据
    //这里之后要考虑不是pdf或者pdf读取错误的情况
    //这不是一个好做法，会大量浪费算力，但是现在先让他爬起来吧，再优化，现在再优化需要考虑TAttrsGroup.Modified
    EditFieldAsString(_Col_metas_Title_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Title']^,[aeForceEditIfTypeDismatch]);
    EditFieldAsString(_Col_metas_Authors_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Author']^,[aeForceEditIfTypeDismatch]);
    EditFieldAsString(_Col_metas_Subject_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Subject']^,[aeForceEditIfTypeDismatch]);
    EditFieldAsString(_Col_metas_Keyword_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Keywords']^,[aeForceEditIfTypeDismatch]);
    EditFieldAsString(_Col_metas_Creator_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Creator']^,[aeForceEditIfTypeDismatch]);
    EditFieldAsString(_Col_metas_Produce_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Producer']^,[aeForceEditIfTypeDismatch]);
    EditFieldAsString(_Col_metas_CreDate_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:CreationDate']^,[aeForceEditIfTypeDismatch]);
    EditFieldAsString(_Col_metas_ModDate_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:ModDate']^,[aeForceEditIfTypeDismatch]);

    //if not is_updating then EndUpdate;
    EndUpdate;

    IF fullfilename<>'' THEN BEGIN
      case AddPaperMethod of
        apmFullBackup:
          begin
            ForceDirectories(TargetDir);
            //tmpPDF.CopyTo(TargetDir+'\'+FileName);//为什么不用copy？
            TRTFP.FileCopy(fullfilename,TargetDir+'\'+FileName,false);
            //尚未加入长度检验
          end;
        apmCutBackup:
          begin
            ForceDirectories(TargetDir);
            //tmpPDF.CopyTo(TargetDir+'\'+FileName);//为什么不用copy？
            TRTFP.FileMove(fullfilename,TargetDir+'\'+FileName,false);
            //尚未加入长度检验
          end;

      end;
      tmpPDF.ClosePdf;
    END;

  FINALLY
    tmpPDF.Free;
  END;
  RecordChange;
  result:=PID;
end;

function TRTFP.FindPaper(fullfilename:string):RTFP_ID;//查找具体文件在工程中的PID，未找到返回000000
var PID:RTFP_ID;
    FHash,FName:string;
    FileStream,CpStr:TMemoryStream;
    retry,cps:boolean;
begin
  FHash:='';
  PID:='';
  cps:=false;

  FileStream:=TMemoryStream.Create;
  FileStream.LoadFromFile(fullfilename);

  with FPaperDB do begin
    First;
    repeat
      if FieldByName(_Col_Paper_FileSize_).AsLongint = FileStream.Size then
        begin
          if FHash='' then FHash:=TRTFP.FileHash(FileStream);
          if FieldByName(_Col_Paper_FileHash_).AsString = FHash then
            begin
              if not cps then begin CpStr:=TMemoryStream.Create;cps:=true end;
              FName:=FFilePath+FRootFolder+'\paper\'+FieldByName(_Col_Paper_Folder_).AsString+'\'+FieldByName(_Col_Paper_FileName_).AsString;
              repeat try
                retry:=false;
                CpStr.LoadFromFile(FName);
                if CompareMem(FileStream.Memory,CpStr.Memory,FileStream.Size) then PID:=FieldByName(_Col_PID_).AsString;
              except
                case ShowMsgRetryIgnore('错误','疑似相同文件被占用！') of
                  'Retry':retry:=true;
                  'Ignore':;
                end;
              end until not retry;
            end;
        end;
      Next;
    until EOF or (PID<>'');
  end;

  if cps then CpStr.Free;

  if PID='' then result:='000000' else result:=PID;

  FileStream.Free;
end;

function TRTFP.DeletePaper(PID:RTFP_ID;PreserveFileNoAsk:boolean=false):boolean;//移除指定PID的文献
var AG:TAttrsGroup;
    klass_list:TStringList;
    klass_name:string;
begin
  result:=false;
  if not TRTFP.IsRTFPID(PID) then exit;
  if not FPaperDB.Active then FPaperDB.Open;
  if LocatePID(FPaperDB,PID) then with FPaperDB do begin
    if FieldByName(_Col_Paper_Is_Backup_).AsBoolean then
      if not PreserveFileNoAsk then
        case ShowMsgYesNoAll('删除确认','删除文献节点对应的文件可能会导致其他共用此文件的节点失去文件连接，并且操作后无法恢复，是否继续？',true) of
          'Yes':TRTFP.FileDelete(FFilePath+FRootFolder+'\paper\'+FieldByName(_Col_Paper_Folder_).AsString+'\'+FieldByName(_Col_Paper_FileName_).AsString);
          else ;
        end
      else ;//PreserveFileNoAsk=true时直接不删除
    Delete;
  end;
  klass_list:=TStringList.Create;
  try
    GetPaperKlass(PID,klass_list);
    for klass_name in klass_list do KlassExclude(klass_name,PID);
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

function TRTFP.UpdatePaper(PID:RTFP_ID;fullfilename:string;AddPaperMethod:TAddPaperMethod):boolean;//更新指定PID的文件
var old_dir,old_file:string;
    old_backup:boolean;
    DateDir,FileName,TargetDir:string;
    tmpPDF:TRTFP_PDF;
begin
  result:=false;
  if not TRTFP.IsRTFPID(PID) then exit;
  case AddPaperMethod of
    apmFullBackup,apmCutBackup,apmAddress:;
    else begin
      assert(false,'不接受apmFullBackup、apmCutBackup和apmAddress以外的方式');
      exit
    end;
  end;
  if not LocatePID(FPaperDB,PID) then begin
    ShowMsgOK('未找到记录','没有找到PID为'+PID+'的文献节点');
    exit;
  end;
  with FPaperDB do begin
    old_backup:=FieldByName(_Col_Paper_Is_Backup_).AsBoolean;
    if old_backup then begin
      old_file:=FieldByName(_Col_Paper_FileName_).AsString;
      old_dir:=FieldByName(_Col_Paper_Folder_).AsString;
    end;
  end;

  case AddPaperMethod of
    apmFullBackup,apmCutBackup:
      begin
        DateDir:=TRTFP.GetDateDir;
        FileName:=ExtractFileName(fullfilename);
        TargetDir:=FFilePath+FRootFolder+'\paper\'+DateDir;
        if FileExists(TargetDir+'\'+FileName) then
          case ShowMsgYesNoAll('相同的备份路径','正在导入的文件“'+fullfilename
          +'”的默认备份地址存在重名，覆盖会导致两个文献节点共用一个备份文件。'
          +'若两个文件不相同，会导致旧版本备份文件被覆盖，且难以复原。'
          +'是否覆盖？',true) of
            'Yes':{do nothing};
            else exit;
        end;
      end;
    apmAddress:
      begin
        DateDir:='extern';
        FileName:=fullfilename;
        TargetDir:=fullfilename;
      end;
  end;

  tmpPDF:=TRTFP_PDF.Create(nil);
  TRY
    tmpPDF.LoadPdf(fullfilename);

    BeginUpdate;

    //此时游标已经在PID位置
    with FPaperDB do begin
      Edit;
      FieldByName(_Col_Paper_Is_Backup_).AsBoolean:=AddPaperMethod=apmFullBackup;
      FieldByName(_Col_Paper_Folder_).AsString:=DateDir;
      FieldByName(_Col_Paper_FileName_).AsString:=FileName;
      FieldByName(_Col_Paper_FileSize_).AsLargeInt:=tmpPDF.Size;
      FieldByName(_Col_Paper_FileHash_).AsString:=tmpPDF.Hash;
      Post;
    end;

    //2-注解
    EditFieldAsDateTime(_Col_notes_ModifyTime_,_Attrs_Notes_,PID,Now,[]);

    //3-元数据
    //这里之后要考虑不是pdf或者pdf读取错误的情况
    //这不是一个好做法，会大量浪费算力，但是现在先让他爬起来吧，再优化
    EditFieldAsString(_Col_metas_Title_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Title']^,[]);
    EditFieldAsString(_Col_metas_Authors_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Author']^,[]);
    EditFieldAsString(_Col_metas_Subject_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Subject']^,[]);
    EditFieldAsString(_Col_metas_Keyword_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Keywords']^,[]);
    EditFieldAsString(_Col_metas_Creator_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Creator']^,[]);
    EditFieldAsString(_Col_metas_Produce_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Producer']^,[]);
    EditFieldAsString(_Col_metas_CreDate_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:CreationDate']^,[]);
    EditFieldAsString(_Col_metas_ModDate_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:ModDate']^,[]);

    EndUpdate;

    //这里有个大问题，如果更新之前有文件，那么替换的时候又不在同一个文件夹，怎么处理
    case AddPaperMethod of
      apmFullBackup:
        begin
          ForceDirectories(TargetDir);
          tmpPDF.CopyTo(TargetDir+'\'+FileName);//改了，不用这个了
          TRTFP.FileCopy(fullfilename,TargetDir+'\'+FileName,false);
          //尚未加入长度检验
        end;
      apmCutBackup:
        begin
          ForceDirectories(TargetDir);
          tmpPDF.CopyTo(TargetDir+'\'+FileName);//改了，不用这个了
          TRTFP.FileMove(fullfilename,TargetDir+'\'+FileName,false);
          //尚未加入长度检验
        end;
    end;
    if old_backup then begin
      TRTFP.FileDelete(FFilePath+FRootFolder+'\paper\'+old_dir+'\'+old_file);
      FPaperDB.FieldByName(_Col_Paper_Is_Backup_).AsBoolean:=true;
    end;

    tmpPDF.ClosePdf;
  FINALLY
    tmpPDF.Free;
  END;
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
    for stmp in klass_list do KlassInclude(stmp,PID_Main);
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
      filename:=Utf8ToWinCP(FFilePath+FRootFolder+'\paper\'
        +FieldByName(_Col_Paper_Folder_).AsString+'\'
        +FieldByName(_Col_Paper_FileName_).AsString)
    else begin
      case FieldByName(_Col_Paper_Folder_).AsString of
        'extern':filename:=Utf8ToWinCP(FieldByName(_Col_Paper_FileName_).AsString);
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
      filename:=Utf8ToWinCP(FFilePath+FRootFolder+'\paper\'
        +FieldByName(_Col_Paper_Folder_).AsString+'\'
        +FieldByName(_Col_Paper_FileName_).AsString)
    else begin
      case FieldByName(_Col_Paper_Folder_).AsString of
        'extern':filename:=Utf8ToWinCP(FieldByName(_Col_Paper_FileName_).AsString);
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




