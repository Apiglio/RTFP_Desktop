//对接AufScript的部分


procedure TRTFP.SetAuf(AAuf:TAuf);
begin
  FAuf:=AAuf;
end;

procedure TRTFP.UpdatePIDExpr(PID:RTFP_ID;AufScpt:TAufScript);
begin
  AufScpt.Expression.Global.TryAddExp('CPID',narg('"',PID,'"'));
end;

{
procedure aufunc_XXX(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  //
end;
}

procedure aufunc_BeginUpdate(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  CurrentRTFP.BeginUpdate;
end;

procedure aufunc_EndUpdate(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  CurrentRTFP.EndUpdate;
end;

procedure aufunc_FileHash(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
    filename:string;
    FileStream:TMemoryStream;
    rc:integer;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,filename) then exit;
  FileStream:=TMemoryStream.Create;
  FileStream.LoadFromFile(filename);

  AufScpt.writeln(TRTFP_PDF.CalcHash(FileStream,rc));
  AufScpt.writeln('file size  = '+IntToStr(FileStream.Size));
  AufScpt.writeln('read count = '+IntToStr(rc));
  FileStream.Free;
end;

procedure aufunc_AddPaper(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
    filename:string;
    arv:TAufRamVar;
    PID,mode:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,filename) then exit;
  if AAuf.ArgsCount>2 then
    begin
      if not AAuf.TryArgToARV(2,6,6,[ARV_Char],arv) then exit;
    end
  else arv.VarType:=ARV_Raw;
  if AAuf.ArgsCount>3 then
    begin
      if not AAuf.TryArgToString(3,mode) then exit;
    end
  else mode:='fb';
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  case lowercase(mode) of
    'fullbackup','full','fb':PID:=CurrentRTFP.AddPaper(filename,apmFullBackup);
    'cutbackup','cut','cb':PID:=CurrentRTFP.AddPaper(filename,apmCutBackup);
    'reference','ref':PID:=CurrentRTFP.AddPaper(filename,apmReference);
    'address','addr':PID:=CurrentRTFP.AddPaper(filename,apmAddress);
    'website','web':PID:=CurrentRTFP.AddPaper(filename,apmWebsite);
    else PID:=CurrentRTFP.AddPaper(filename);//默认也是apmFullBackup
  end;
  if arv.VarType=ARV_Raw then
    begin
      if PID<>'000000' then AufScpt.writeln('新节点['+PID+']已生成。')
      else AufScpt.writeln('节点创建失败！');
    end
  else initiate_arv_str(PID,arv);
end;

procedure aufunc_DeletePaper(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
    PID:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,PID) then exit;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  if CurrentRTFP.DeletePaper(PID) then AufScpt.writeln('节点【'+PID+'】删除成功。')
  else AufScpt.send_error('节点【'+PID+'】删除失败！');
end;

procedure aufunc_addKlass(Sender:TObject);//class.add KlassName
var AufScpt:TAufScript;
    AAuf:TAuf;
    s1:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,s1) then exit;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  if CurrentRTFP.AddKlass(s1,'.')<>nil then AufScpt.writeln('成功创建【'+s1+'】分类。');
  CurrentRTFP.ClassChange;
end;

procedure aufunc_deleteKlass(Sender:TObject);//class.delete KlassName
var AufScpt:TAufScript;
    AAuf:TAuf;
    s1:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,s1) then exit;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  CurrentRTFP.DeleteKlass(s1,'.');
  AufScpt.writeln('成功删除【'+s1+'】分类。');
  CurrentRTFP.ClassChange;
end;

procedure aufunc_enableKlass(Sender:TObject);//class.enable KlassName
var AufScpt:TAufScript;
    AAuf:TAuf;
    s1:string;
    tmpKL:TKlass;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,s1) then exit;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  tmpKL:=CurrentRTFP.FindKlass(s1,'.');
  if tmpKL<>nil then begin
    tmpKL.FilterEnabled:=true;
    CurrentRTFP.ClassChange;
  end else AufScpt.send_error('未找到【'+s1+'】分类，代码未执行。');
end;

procedure aufunc_disableKlass(Sender:TObject);//class.disable KlassName
var AufScpt:TAufScript;
    AAuf:TAuf;
    s1:string;
    tmpKL:TKlass;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,s1) then exit;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  tmpKL:=CurrentRTFP.FindKlass(s1,'.');
  if tmpKL<>nil then begin
    tmpKL.FilterEnabled:=false;
    CurrentRTFP.ClassChange;
  end else AufScpt.send_error('未找到【'+s1+'】分类，代码未执行。');
end;

procedure aufunc_KlassFilterMode(Sender:TObject);//class.filtermode and | or | not
var AufScpt:TAufScript;
    AAuf:TAuf;
    s1,s2:string;
    mode:set of (mdAND, mdOR, mdNOT);
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToStrParam(1,['and','or','not'],false,s1) then exit;
  if AAuf.ArgsCount>=3 then begin
    if not AAuf.TryArgToStrParam(2,['and','or','not'],false,s2) then exit;
  end else begin
    s2:='so';
  end;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  mode:=[];
  case lowercase(s1) of
    'and': mode:=mode+[mdAND];
    'or' : mode:=mode+[mdOR];
    'not': mode:=mode+[mdNOT];
  end;
  case lowercase(s2) of
    'and': mode:=mode+[mdAND];
    'or' : mode:=mode+[mdOR];
    'not': mode:=mode+[mdNOT];
  end;
  if (mdAND in mode) and (not (mdOR in mode)) then begin
    CurrentRTFP.RunPerformance.Klass_Filter_AND := true;
  end else if (not (mdAND in mode)) and (mdOR in mode) then begin
    CurrentRTFP.RunPerformance.Klass_Filter_AND := false;
  end else begin
      AufScpt.send_error('不支持同时选择and和or模式。');
      exit;
  end;
  CurrentRTFP.RunPerformance.Klass_Filter_NOT := mdNOT in mode;
  FormDesktop.RadioButton_KlassAND.Checked:=CurrentRTFP.RunPerformance.Klass_Filter_AND;
  FormDesktop.RadioButton_KlassOR.Checked:=not CurrentRTFP.RunPerformance.Klass_Filter_AND;
  FormDesktop.CheckBox_KlassNot.Checked:=CurrentRTFP.RunPerformance.Klass_Filter_NOT;
  CurrentRTFP.ClassChange;
end;

procedure aufunc_KlassFilterClear(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
    tmpKL:TKlass;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  for tmpKL in CurrentRTFP.FKlassList do tmpKL.AllUnChecked:=true;
  CurrentRTFP.ClassChange;
end;

procedure aufunc_KlassInclude(Sender:TObject);//class.include KlassName, PID
var AufScpt:TAufScript;
    AAuf:TAuf;
    s1,s2:string;
    tmpKL:TKlass;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(3) then exit;
  if not AAuf.TryArgToString(1,s1) then exit;
  if not AAuf.TryArgToString(2,s2) then exit;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  tmpKL:=CurrentRTFP.FindKlass(s1,'.');
  if tmpKL=nil then begin
    AufScpt.send_error('警告：未找到分类【'+s1+'】，未执行纳入。');
    exit;
  end;
  if CurrentRTFP.KlassInclude(tmpKL,s2) then AufScpt.writeln('成功将节点【'+s2+'】纳入【'+s1+'】分类');
end;

procedure aufunc_KlassExclude(Sender:TObject);//class.exclude KlassName, PID
var AufScpt:TAufScript;
    AAuf:TAuf;
    s1,s2:string;
    tmpKL:TKlass;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(3) then exit;
  if not AAuf.TryArgToString(1,s1) then exit;
  if not AAuf.TryArgToString(2,s2) then exit;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  tmpKL:=CurrentRTFP.FindKlass(s1,'.');
  if tmpKL=nil then begin
    AufScpt.send_error('警告：未找到分类【'+s1+'】，未执行移出。');
    exit;
  end;
  if CurrentRTFP.KlassExclude(tmpKL,s2) then AufScpt.writeln('成功将节点【'+s2+'】移出【'+s1+'】分类');
end;

procedure aufunc_KlassIncludeDS(Sender:TObject);//class.include_ds KlassName
var AufScpt:TAufScript;
    AAuf:TAuf;
    s1,pid:string;
    pids:TStringList;
    tmpKL:TKlass;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,s1) then exit;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  tmpKL:=CurrentRTFP.FindKlass(s1,'.');
  if tmpKL=nil then begin
    AufScpt.send_error('警告：未找到分类【'+s1+'】，未执行纳入。');
    exit;
  end;
  pids:=TStringList.Create;
  CurrentRTFP.BeginUpdate;
  try
    CurrentRTFP.GetPIDList_DS(pids);
    for pid in pids do CurrentRTFP.KlassInclude(tmpKL,pid);
    AufScpt.writeln('成功将'+IntToStr(pids.Count)+'个节点纳入【'+s1+'】分类');
  finally
    CurrentRTFP.EndUpdate;
    CurrentRTFP.ClassChange;
    pids.Free;
  end;
end;

procedure aufunc_KlassExcludeDS(Sender:TObject);//class.exclude_ds KlassName
var AufScpt:TAufScript;
    AAuf:TAuf;
    s1,pid:string;
    pids:TStringList;
    tmpKL:TKlass;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,s1) then exit;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  tmpKL:=CurrentRTFP.FindKlass(s1,'.');
  if tmpKL=nil then begin
    AufScpt.send_error('警告：未找到分类【'+s1+'】，未执行移出。');
    exit;
  end;
  pids:=TStringList.Create;
  CurrentRTFP.BeginUpdate;
  try
    CurrentRTFP.GetPIDList_DS(pids);
    for pid in pids do CurrentRTFP.KlassExclude(tmpKL,pid);
    AufScpt.writeln('成功将'+IntToStr(pids.Count)+'个节点移出【'+s1+'】分类');
  finally
    CurrentRTFP.EndUpdate;
    CurrentRTFP.ClassChange;
    pids.Free;
  end;
end;

procedure aufunc_EditAttr(Sender:TObject);//attr.edit PID,AttrName,FieldName,"memo"
var AufScpt:TAufScript;
    AAuf:TAuf;
    APID,AMEMO,AFieldName,AAttrName:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(5) then exit;
  if not AAuf.TryArgToString(1,APID) then exit;
  if not AAuf.TryArgToString(2,AAttrName) then exit;
  if not AAuf.TryArgToString(3,AFieldName) then exit;
  if not AAuf.TryArgToString(4,AMEMO) then exit;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  CurrentRTFP.EditFieldAsString(AFieldName,AAttrName,APID,AMEMO,[aeCreateIfNoField,aeForceEditIfTypeDismatch]);
end;
procedure aufunc_EditImage(Sender:TObject);//attr.edit_image PID,AttrName,FieldName,filename
var AufScpt:TAufScript;
    AAuf:TAuf;
    APID,filename,AFieldName,AAttrName:string;
    APicture:TPicture;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(5) then exit;
  if not AAuf.TryArgToString(1,APID) then exit;
  if not AAuf.TryArgToString(2,AAttrName) then exit;
  if not AAuf.TryArgToString(3,AFieldName) then exit;
  if not AAuf.TryArgToString(4,filename) then exit;

  if not FileExists(filename) then begin
    AufScpt.writeln('警告：找不到 '+filename+' 文件，'+Auf.args[0]+'未执行。');
    exit
  end;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  APicture:=TPicture.Create;
  try
    APicture.LoadFromFile(filename);
    CurrentRTFP.EditFieldAsBitmap(AFieldName,AAttrName,APID,APicture.Bitmap,[aeCreateIfNoField]);
  finally
    APicture.Free;
  end;
end;
procedure aufunc_ReadAttr(Sender:TObject);//attr.read PID,AttrName,FieldName,out
var AufScpt:TAufScript;
    AAuf:TAuf;
    APID,AFieldName,AAttrName,AValue:string;
    arv:TAufRamVar;
    show_message:boolean;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(4) then exit;
  if not AAuf.TryArgToString(1,APID) then exit;
  if not AAuf.TryArgToString(2,AAttrName) then exit;
  if not AAuf.TryArgToString(3,AFieldName) then exit;
  if AAuf.ArgsCount>4 then
    begin
      AAuf.TryArgToARV(4,256,256,[ARV_Char],arv);
      show_message:=false;
    end
  else show_message:=true;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  try
    AValue:=CurrentRTFP.ReadFieldAsString(AFieldName,AAttrName,APID,[aeFailIfNoPID,aeFailIfNoField]);
  except
    on AttrsNoPIDErr do begin AufScpt.writeln('找不到节点，读取失败。');AValue:='~NPErr';end;
    on AttrsNoFieldErr do begin AufScpt.writeln('找不到字段，读取失败。');AValue:='~NFErr';end;
    on AttrsTypeDismatchErr do begin AufScpt.writeln('属性类型不符，读取失败。');AValue:='~TDErr';end;
  end;
  if show_message then AufScpt.writeln('Fields['+AAttrName+','+AFieldName+']='+AValue)
  else initiate_arv_str(AValue,arv);
end;

procedure aufunc_AddAttrField(Sender:TObject);//attrs.field.add AttrName,FieldName,type,size
var AufScpt:TAufScript;
    AAuf:TAuf;
    AFieldName,AAttrName,AFieldType:string;
    //AFieldSize:byte;
    dt:TFieldType;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs({5}4) then exit;
  if not AAuf.TryArgToString(1,AAttrName) then exit;
  if not AAuf.TryArgToString(2,AFieldName) then exit;
  if not AAuf.TryArgToString(3,AFieldType) then exit;
  //if not AAuf.TryArgToByte(4,AFieldSize) then exit;

  case lowercase(AFieldType) of
    'memo':dt:=ftMemo;
    'string','str':dt:=ftString;
    'largeint','long':dt:=ftLargeInt;
    'boolean','bool':dt:=ftBoolean;
    'smallint','small':dt:=ftSmallInt;
    'float','double':dt:=ftFloat;
    'date':dt:=ftDate;
    'time':dt:=ftTime;
    'datetime':dt:=ftDateTime;
    else begin
      AufScpt.send_error('无效的字段类型，字段未创建。');
      exit;
    end;
  end;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  if CurrentRTFP.AddField(AFieldName,AAttrName,dt{,AFieldSize})<>nil then AufScpt.writeln('成功创建【'+AAttrName+'.'+AFieldName+'】字段。');
end;

procedure aufunc_DelAttrField(Sender:TObject);//attrs.field.del AttrNo,FieldName
var AufScpt:TAufScript;
    AAuf:TAuf;
    AFieldName,AAttrName:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(3) then exit;
  if not AAuf.TryArgToString(1,AAttrName) then exit;
  if not AAuf.TryArgToString(2,AFieldName) then exit;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  CurrentRTFP.DeleteField(AFieldName,AAttrName);
  AufScpt.writeln('成功删除【'+AAttrName+'.'+AFieldName+'】字段。');
end;

procedure aufunc_EnableAttrField(Sender:TObject);//field.enable AttrNo,FieldName
var AufScpt:TAufScript;
    AAuf:TAuf;
    AFieldName,AAttrName:string;
    tmpAF:TAttrsField;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(3) then exit;
  if not AAuf.TryArgToString(1,AAttrName) then exit;
  if not AAuf.TryArgToString(2,AFieldName) then exit;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  tmpAF:=CurrentRTFP.FindField(AFieldName,AAttrName);
  if tmpAF<>nil then begin
    tmpAF.Shown:=true;
    CurrentRTFP.FieldAndRecordChange;
  end else AufScpt.send_error('未能找到【'+AAttrName+'.'+AFieldName+'】字段。');
end;

procedure aufunc_DisableAttrField(Sender:TObject);//field.disable AttrNo,FieldName
var AufScpt:TAufScript;
    AAuf:TAuf;
    AFieldName,AAttrName:string;
    tmpAF:TAttrsField;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(3) then exit;
  if not AAuf.TryArgToString(1,AAttrName) then exit;
  if not AAuf.TryArgToString(2,AFieldName) then exit;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  tmpAF:=CurrentRTFP.FindField(AFieldName,AAttrName);
  if tmpAF<>nil then begin
    tmpAF.Shown:=false;
    CurrentRTFP.FieldAndRecordChange;
  end else AufScpt.send_error('未能找到【'+AAttrName+'.'+AFieldName+'】字段。');
end;


procedure aufunc_RebuildFormatEdit(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
    filename:string;
    str:TStringList;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,filename) then exit;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  filename:=CurrentRTFP.FFilePath+CurrentRTFP.FRootFolder+'/format/'+filename;
  if FileExists(filename) then begin
    str:=TStringList.Create;
    try
      str.LoadFromFile(filename);
      CurrentRTFP.FormatEditClear(FormDesktop.ScrollBox_Node_FormatEdit);
      CurrentRTFP.FormatEditBuild(FormDesktop.ScrollBox_Node_FormatEdit,str);
      AufScpt.writeln('成功加载'+filename+'布局文件。');
    finally
      str.Free;
    end;
  end else AufScpt.send_error('未找到'+filename+'布局文件！');
end;

procedure aufunc_newPaperId(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  AufScpt.writeln(CurrentRTFP.NewPaperID);
end;

procedure aufunc_newImageId(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  AufScpt.writeln(CurrentRTFP.NewImageID);
end;

procedure aufunc_newNoteId(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  AufScpt.writeln(CurrentRTFP.NewNoteID);
end;

procedure aufunc_ShowMeta(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
    filename:string;
    RTFP_PDF:TRTFP_PDF;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,filename) then exit;

  RTFP_PDF:=TRTFP_PDF.Create(nil,filename);

  AufScpt.writeln(RTFP_PDF.Meta.ToString);

  RTFP_PDF.Free;

end;

procedure aufunc_ShowView(Sender:TObject);//没成功
var AufScpt:TAufScript;
    AAuf:TAuf;
    filename:string;
    RTFP_PDF:TRTFP_PDF;
    page:dword;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,filename) then exit;

  RTFP_PDF:=TRTFP_PDF.Create(nil,filename);
  {$ifdef WINDOWS}
  RTFP_PDF.ShowPage(FormDesktop.Image_PDF_View.Picture.Bitmap.Canvas.Handle,page);
  //AufScpt.writeln(RTFP_PDF.Meta.ToString);
  {$endif}
  RTFP_PDF.Free;
end;

procedure aufunc_save(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  CurrentRTFP.Save;
  AufScpt.writeln('强制保存成功。');
end;

procedure aufunc_PID_First(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
    PID:string;
    arv:TAufRamVar;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToARV(1,6,6,[ARV_Char],arv) then exit;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  with CurrentRTFP.FPaperDB do begin
    if not Active then Open;
    First;
    PID:=FieldByName(_Col_PID_).AsString;
  end;
  initiate_arv_str(PID,arv);
end;

procedure aufunc_PID_NextJump(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
    pid:string;
    arv:TAufRamVar;
    addr:pRam;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(3) then exit;
  if not AAuf.TryArgToARV(1,6,6,[ARV_Char],arv) then exit;
  if not AAuf.TryArgToAddr(2,addr) then exit;
  PID:=arv_to_s(arv);
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  with CurrentRTFP.FPaperDB do begin
    if not Active then Open;
    First;
    repeat
      if FieldByName(_Col_PID_).AsString=PID then break;
      Next;
    until EOF;
    Next;
    if not EOF then begin
      initiate_arv_str(FieldByName(_Col_PID_).AsString,arv);
      AufScpt.jump_addr(addr);
    end else begin
      initiate_arv_str('000000',arv);
      //AufScpt.next_addr;
    end;
  end;
end;

procedure aufunc_set_field_option(Sender:TObject);//option.attrs.set Attrs Field Key value
var AufScpt:TAufScript;
    AAuf:TAuf;
    NA,NF,NO,stmp:string;
    AG:TAttrsGroup;
    AF:TAttrsField;
    slon:longint;
    function getbo(str:string):boolean;
    begin
      case lowercase(str) of
        'on','t','true','1':result:=true;
        else result:=false;
      end;
    end;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(5) then exit;
  if not AAuf.TryArgToString(1,NA) then exit;
  if not AAuf.TryArgToString(2,NF) then exit;
  if not AAuf.TryArgToString(3,NO) then exit;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  case lowercase(NO) of
    'visible','checked','folded':
      begin
        if not AAuf.TryArgToString(4,stmp) then exit;
        AG:=CurrentRTFP.FieldList.FindItemByName(NA);
        if AG=nil then begin
          AufScpt.send_error('错误：无属性组“'+NA+'”。');
          exit;
        end;
        if lowercase(NO[1])='f' then
          begin
            AG.GroupShown:=not getbo(stmp);
            exit;
          end;
        AF:=AG.FieldList.FindItemByName(NF);
        if AF=nil then begin
          AufScpt.send_error('错误：无属性“'+NF+'”。');
          exit;
        end;
        AF.Shown:=getbo(stmp);
      end;
    'width','w','display_width':
      begin
        //不再在option.lay.auf中设置，只留作脚本选项
        if not AAuf.TryArgToLong(4,slon) then exit;
        AF:=CurrentRTFP.FindField(NF,NA);
        if AF=nil then begin
          AufScpt.send_error('错误：找不到属性组“'+NA+'.'+NF+'”。');
          exit;
        end;
        AF.FFieldDisplayOption.DispWidth:=slon;
      end;
    'display_name','disp':
      begin
        //不再在option.lay.auf中设置，只留作脚本选项
        if not AAuf.TryArgToString(4,stmp) then exit;
        if NF='' then begin
          AG:=CurrentRTFP.FieldList.FindItemByName(NA);
          if AG=nil then begin
            AufScpt.send_error('错误：无属性组“'+NA+'”。');
            exit;
          end;
          AG.DisplayName:=stmp;
          exit;
        end;
        AF:=CurrentRTFP.FindField(NF,NA);
        if AF=nil then begin
          AufScpt.send_error('错误：找不到属性组“'+NA+'.'+NF+'”。');
          exit;
        end;
        AF.FFieldDisplayOption.DispName:=stmp;
      end;
    'display_option':
      begin
        if not AAuf.TryArgToString(4,stmp) then exit;
        if NF='' then begin
          AufScpt.send_error('错误：不能给属性组“'+NA+'”设置显示信息。');
          exit;
        end;
        AF:=CurrentRTFP.FindField(NF,NA);
        if AF=nil then begin
          AufScpt.send_error('错误：找不到属性组“'+NA+'.'+NF+'”。');
          exit;
        end;
        AF.FFieldDisplayOption.LoadFromJSON(stmp);
      end;
    'add_combo':
      begin
        if not AAuf.TryArgToString(4,stmp) then exit;
        AF:=CurrentRTFP.FindField(NF,NA);
        if AF=nil then begin
          AufScpt.send_error('错误：找不到属性组“'+NA+'.'+NF+'”。');
          exit;
        end;
        AF.AddCombo(stmp);
      end;
    'clear_combo':
      begin
        AF:=CurrentRTFP.FindField(NF,NA);
        if AF=nil then begin
          AufScpt.send_error('错误：找不到属性组“'+NA+'.'+NF+'”。');
          exit;
        end;
        AF.ClearCombo;
      end;
    else
      begin
        AufScpt.send_error('错误：key名称无意义。');
      end;
  end;
end;

procedure aufunc_update_case(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
    stmp,ppid:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToStrParam(1,['rebuild_mg','update_cur','change','datachange','fieldchange','recordchange','classchange'],false,stmp) then exit;
  if not AAuf.TryArgToString(2,ppid) then ppid:='000000';
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  case lowercase(stmp) of
    'rebuild_mg':CurrentRTFP.RebuildMainGrid;
    'update_cur':CurrentRTFP.UpdateCurrentRec(ppid);
    'change':CurrentRTFP.Change;
    'datachange':CurrentRTFP.DataChange(ppid);
    'fieldchange':CurrentRTFP.FieldChange;
    'recordchange':CurrentRTFP.RecordChange;
    'classchange':CurrentRTFP.ClassChange;
    else AufScpt.writeln('无效的更新模式。');
  end;
end;

procedure aufunc_maingrid_filter(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
    criterion:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,criterion) then exit;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  CurrentRTFP.RunPerformance.Filter_Command:=criterion;
  CurrentRTFP.TableFilter;
end;

procedure aufunc_maingrid_sorter(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
    criterion:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,criterion) then exit;
  if ProjectInvalid then begin AufScpt.send_error('未打开工程，代码未执行。');exit;end;
  CurrentRTFP.RunPerformance.Sorter_Command:=criterion;
  CurrentRTFP.TableSorter;
end;



{$ifdef test}

procedure aufunc_test(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
    check,target:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(3) then exit;
  if not AAuf.TryArgToString(1,check) then exit;
  if not AAuf.TryArgToString(2,target) then exit;

  if TRTFP.VersionCheck(check,target) then
    AufScpt.writeln('T') else AufScpt.writeln('F');
end;

{$endif}

procedure AufScriptFuncDefineRTFP(Auf:TAuf);
begin
  with Auf do begin
    Script.add_func('new.pid',@aufunc_newPaperId,'','返回一个可用的PID');
    Script.add_func('new.iid',@aufunc_newImageId,'','返回一个可用的IID');
    Script.add_func('new.nid',@aufunc_newNoteId,'','返回一个可用的NID');

    Script.add_func('paper.add',@aufunc_AddPaper,'filename,@out_pid,mode="fb"','新建Paper节点');
    Script.add_func('paper.del',@aufunc_DeletePaper,'PID','删除Paper节点');

    Script.add_func('paper.edit',@aufunc_EditAttr,'PID,AttrName,FieldName,Memo','修改PID节点中AttrName属性组的FieldName字段为Memo');
    Script.add_func('paper.edit_image',@aufunc_EditImage,'PID,AttrName,FieldName,filename','修改PID节点中AttrName属性组的FieldName图像字段为filename图像');
    Script.add_func('paper.read',@aufunc_ReadAttr,'PID,AttrName,FieldName,arv','修改PID节点中AttrName属性组的FieldName字段为Memo');

    //Script.add_func('attrs.ag.add',@aufunc_AddAttrGroup,'AttrName','在第AttrNo表中创建FieldName字段');
    //Script.add_func('attrs.ag.del',@aufunc_DelAttrGroup,'AttrName','在第AttrNo表中创建FieldName字段');
    Script.add_func('field.add',@aufunc_AddAttrField,'AttrName,FieldName','在AttrName属性组中创建FieldName字段');
    Script.add_func('field.del',@aufunc_DelAttrField,'AttrName,FieldName','在AttrName属性组中创建FieldName字段');
    Script.add_func('field.enable',@aufunc_EnableAttrField,'AttrName,FieldName','在主表中显示AttrName属性组中的FieldName字段');
    Script.add_func('field.disable',@aufunc_DisableAttrField,'AttrName,FieldName','在主表中隐藏AttrName属性组中的FieldName字段');

    Script.add_func('class.add',@aufunc_addKlass,'KlassName','创建分类表');
    Script.add_func('class.del',@aufunc_deleteKlass,'KlassName','删除分类表');
    Script.add_func('class.enable',@aufunc_enableKlass,'KlassName','勾选KlassName分类');
    Script.add_func('class.disable',@aufunc_disableKlass,'KlassName','取消勾选KlassName分类');
    Script.add_func('class.filtermode',@aufunc_KlassFilterMode,'and | or | not','选择分类筛选模式');
    Script.add_func('class.filterclear',@aufunc_KlassFilterClear,'','取消勾选所有分类');

    Script.add_func('class.include',@aufunc_KlassInclude,'KlassName, PID','将PID节点加入分类');
    Script.add_func('class.exclude',@aufunc_KlassExclude,'KlassName, PID','将PID节点移出分类');
    Script.add_func('class.include_ds',@aufunc_KlassIncludeDS,'KlassName','将主表中所有节点加入分类');
    Script.add_func('class.exclude_ds',@aufunc_KlassExcludeDS,'KlassName','将主表中所有节点移出分类');

    Script.add_func('pdf.meta',@aufunc_ShowMeta,'filename','检查pdf文件的meta数据');
    Script.add_func('pdf.view',@aufunc_ShowView,'filename,page','预览pdf的page页');

    Script.add_func('update.begin',@aufunc_BeginUpdate,'','开始更新模式');
    Script.add_func('update.end',@aufunc_EndUpdate,'','结束更新模式');
    Script.add_func('update.apply',@aufunc_update_case,'mode','触发更新过程');

    Script.add_func('mg.filter',@aufunc_maingrid_filter,'criterion','修改主表筛选条件');
    Script.add_func('mg.sorter',@aufunc_maingrid_sorter,'criterion','修改主表排序条件');


    Script.add_func('fmt.rebuild',@aufunc_RebuildFormatEdit,'filename','从filename中加载FormatEdit布局');
    //把FmtCmp改掉，取消泛型

    Script.add_func('hash',@aufunc_FileHash,'filename','返回FileHash');
    Script.add_func('save',@aufunc_save,'','强制保存');

    Script.add_func('pid.first',@aufunc_PID_First,'@str','寻找第一个PID，并赋值给@str');
    Script.add_func('pid.next_jump',@aufunc_PID_NextJump,'@str,:addr','寻找第下一个PID，下一个存在则赋值给@str并跳转到:addr');

    Script.add_func('option.attrs.set',@aufunc_set_field_option,'attrs,field,key,value','字段显示设置');

    {$ifdef test}
    Script.add_func('test',@aufunc_test,'*arg','测试');


    {$endif}

  end;
end;



