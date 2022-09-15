//与控件对接的部分


{工程属性列表 Tags}
procedure TRTFP.ProjectPropertiesValidate(AValueListEditor:TValueListEditor);
begin
  AValueListEditor.Values['工程标题']:=Self.Title;
  AValueListEditor.Values['创建用户']:=Self.User;
  AValueListEditor.Values['创建日期']:=Self.Tag['创建日期'];
  AValueListEditor.Values['修改日期']:=Self.Tag['修改日期'];
  AValueListEditor.Values['PDF打开方式']:=Self.Tag['PDF打开方式'];
  AValueListEditor.Values['CAJ打开方式']:=Self.Tag['CAJ打开方式'];
  AValueListEditor.Values['最后保存版本']:=Version;
end;

procedure TRTFP.ProjectPropertiesDataPost(AValueListEditor:TValueListEditor);
begin
  Self.Title:=AValueListEditor.Values['工程标题'];
  Self.User:=AValueListEditor.Values['创建用户'];
  Self.Tag['PDF打开方式']:=AValueListEditor.Values['PDF打开方式'];
  Self.Tag['CAJ打开方式']:=AValueListEditor.Values['CAJ打开方式'];
end;


{段落查看控件 FmtCmt}
procedure TRTFP.FmtCmtValidate(PID:RTFP_ID;AttrName,FieldName:string;Memo:TMemo);
begin
  Memo.Clear;
  if CheckField(FieldName,AttrName,[ftMemo,ftWideMemo,ftFmtMemo]) then begin
    //Memo.Lines.CommaText:=StringReplace(ReadFieldAsString(FieldName,AttrName,PID,[]),Comma_Symbol,#13#10,[rfReplaceAll]);
    ReadFieldAsMemo(FieldName,AttrName,PID,Memo.Lines,[]);
  end;
  ReNewCheckTimeWithoutChange(PID);//如果Change会导致Validate更新，这个需要重构以下UI逻辑，暂时先不管
  //ReNewCheckTime(PID);
end;

procedure TRTFP.FmtCmtDataPost(PID:RTFP_ID;AttrName,FieldName:string;Memo:TMemo);
begin
  BeginUpdate;
  if CheckField(FieldName,AttrName,[ftMemo,ftWideMemo,ftFmtMemo]) then begin
    //EditFieldAsString(FieldName,AttrName,PID,StringReplace(Memo.Lines.CommaText,#13#10,Comma_Symbol,[rfReplaceAll]),[]);
    EditFieldAsMemo(FieldName,AttrName,PID,Memo.Lines,[]);
  end;
  EndUpdate;
  ReNewModifyTime(PID);
end;


{字段列表显示}
procedure TRTFP.FieldListValidate(AListView:TListView);
var tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
begin
  AListView.BeginUpdate;
  (AListView as TACL_ListView).Clear;
  for tmpAG in FFieldList do
    begin
      for tmpAF in tmpAG.FieldList do
        begin
          (AListView as TACL_ListView).AddShellNodeItem(tmpAG.Name+'\'+tmpAF.FieldName,tmpAF,tmpAF.Shown);
        end;
      (AListView as TACL_ListView).GetShellNodeItem(tmpAG.Name).Data:=tmpAG;
    end;
  AListView.EndUpdate;
  for tmpAG in FFieldList do
    begin
      if tmpAG.GroupShown then (AListView as TACL_ListView).CheckShellNodeItem(tmpAG.Name,true);
      for tmpAF in tmpAG.FieldList do
        if tmpAF.Shown then (AListView as TACL_ListView).CheckShellNodeItem(tmpAG.Name+'\'+tmpAF.FieldName,true);
    end;
  //这部分不知道那个地方有问题，条目不能正确勾选。
  AListView.Repaint;
end;


{分类列表显示}
procedure TRTFP.KlassListValidate(AListView:TListView);
var tmpKL:TKlass;
begin
  AListView.BeginUpdate;
  (AListView as TACL_ListView).Clear;
  for tmpKL in FKlassList do
    begin
      (AListView as TACL_ListView).AddShellNodeItem(tmpKL.FullPath,tmpKL,tmpKL.FilterEnabled);
    end;
  AListView.EndUpdate;
  (AListView as TACL_ListView).CheckShellNodeItem('class',true);
  AListView.Repaint;
end;


{主表显示}
procedure TRTFP.RebuildMainGrid;
var tmpDbf:{TDbf}TDataSet;
    tmpFieldDef:TFieldDef;
    PID:RTFP_ID;
    pi,pj,pcol,max_attr:integer;
    attr_range:array[0..99] of record
      min,max:integer;
    end;//记录分表字段在总表中的范围
    fields_ref:array[0..9999]of record
      AG:TAttrsGroup;//nil表示PaperDB
      FI:Integer;
    end;
    fields_cnt,paperDB_cnt:integer;
    tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
    dat_type:TFieldType;
    bm:TBookMark;
    klass:TKlass;

    procedure DoInsertPaperDS(PID:RTFP_ID);
    var NextPID:RTFP_ID;
    begin
      with FPaperDS do
        begin
          if not EOF then
            begin
              Next;
              NextPID:=FieldByName(_Col_PID_).AsString;
              Prior;
            end
          else NextPID:='000000';
          if NextPID <> PID then
            begin
              Insert;
              FieldByName(_Col_PID_).AsString:=PID;
              Post;
            end;
        end;
    end;
    procedure InsertPaperDS(PID:RTFP_ID);
    var crl,crh,mid:longint;
        npid,tmpid:dword;
    begin
      npid:=TRTFP.IDToNum(PID);
      crl:=0;crh:=FPaperDS.RecordCount-1;
      if crh<0 then begin
        DoInsertPaperDS(PID);
        exit;
      end;
      WITH FPaperDS DO BEGIN
        while crl<>crh do
          begin
            mid:=(crl+crh) div 2;
            RecNo:=mid;
            tmpid:=TRTFP.IDToNum(FieldByName(_Col_PID_).AsString);
            if tmpid=npid then exit else
              begin
                if tmpid>npid then crh:=mid
                else crl:=mid + (crl+crh) mod 2;
              end;
          end;
        RecNo:=crl;
        DoInsertPaperDS(PID);
      END;
    end;

begin

  if (not IsUpdating) and (FOnMainGridRebuilding<>nil) then FOnMainGridRebuilding(Self);
  BeginUpdate;
  try
    bm:=FPaperDS.GetBookmark;
    FPaperDS.Clear;
    PaperDSFieldDefs.Clear;
    tmpDbf:=FPaperDB;
    fields_cnt:=0;
    for pcol:=0 to tmpDbf.FieldDefs.Count-1 do
      begin
        tmpFieldDef:=tmpDbf.FieldDefs.Items[pcol];
        //case
        FPaperDS.FieldDefs.Add(tmpFieldDef.Name,tmpFieldDef.DataType,tmpFieldDef.Size);
        fields_ref[fields_cnt].AG:=nil;
        fields_ref[fields_cnt].FI:=tmpFieldDef.Index;
        PaperDSFieldDefs.Add(nil);//基础的PaperAttrs没有对应的AttrsField，所以用nil代替。
        inc(fields_cnt);
        //end
      end;
    paperDB_cnt:=fields_cnt;
    pi:=-1;
    for tmpAG in FFieldList do begin
      inc(pi);
      attr_range[pi].max:=-1;
      attr_range[pi].min:=fields_cnt;
      for tmpAF in tmpAG.FieldList do
        begin
          if not tmpAF.Shown then continue;
          attr_range[pi].max:=fields_cnt;
          tmpFieldDef:=tmpAF.FieldDef;

          dat_type:=tmpFieldDef.DataType;
          case dat_type of
            ftMemo,ftWideMemo,ftFmtMemo:
              FPaperDS.FieldDefs.Add(tmpFieldDef.Name+'('+tmpAG.Name+')',ftString,255);
            else
              FPaperDS.FieldDefs.Add(tmpFieldDef.Name+'('+tmpAG.Name+')',dat_type,tmpFieldDef.Size);
          end;
          fields_ref[fields_cnt].AG:=tmpAG;
          fields_ref[fields_cnt].FI:=tmpFieldDef.Index;
          PaperDSFieldDefs.Add(tmpAF);
          inc(fields_cnt);
        end;
    end;
    max_attr:=pi;

    FPaperDS.CreateTable;
    FPaperDS.Open;
    FPaperDS.Last;

    IF (FKlassList.Count=0) or (FKlassList.AllUnChecked) THEN BEGIN
      tmpDbf:=FPaperDB;
      tmpDbf.First;
      if not tmpDbf.EOF then repeat
        FPaperDS.Append;
        for pi:=0 to paperDB_cnt-1 do
          begin
            with FPaperDS.Fields[pi] do case DataType of
              ftString,ftMemo,ftWideString,ftFixedWideChar,ftWideMemo{,ftFmtMemo,ftFixedChar}:FPaperDS.Fields[pi].AsString:=tmpDbf.Fields[fields_ref[pi].FI].AsString;
              ftBoolean:FPaperDS.Fields[pi].AsBoolean:=tmpDbf.Fields[fields_ref[pi].FI].AsBoolean;
              ftFloat:FPaperDS.Fields[pi].AsFloat:=tmpDbf.Fields[fields_ref[pi].FI].AsFloat;
              ftInteger,ftLargeint,ftSmallint,ftWord:FPaperDS.Fields[pi].AsLargeInt:=tmpDbf.Fields[fields_ref[pi].FI].AsLargeInt;
              ftDateTime,ftDate,ftTime:FPaperDS.Fields[pi].AsDateTime:=tmpDbf.Fields[fields_ref[pi].FI].AsDateTime;
              ftBlob:FPaperDS.Fields[pi].Assign(tmpDbf.Fields[fields_ref[pi].FI]);
              else assert(false,'FPaperDS.Fields[pi].DataType未预设。');
            end;
          end;
        tmpDbf.Next;
      until tmpDbf.EOF;
    END ELSE BEGIN
      for klass in FKlassList do
        begin
          with klass.Dbf do begin
            if not klass.FilterEnabled then continue;
            if not Active then Open;
            First;
            while not EOF do
              begin
                InsertPaperDS(FieldByName(_Col_PID_).AsString);
                Next;
              end;
          end;
        end;
      FPaperDS.First;
      if not FPaperDS.Active then FPaperDB.Open;
      //TDbf(FPaperDB).IndexName:='id';
      while not FPaperDS.EOF do begin
        //if TDbf(FPaperDB).SearchKey(FPaperDS.FieldByName(_Col_PID_).AsString,stEqual) then
        if LocatePID(FPaperDB,FPaperDS.FieldByName(_Col_PID_).AsString) then
          begin
            FPaperDS.Edit;
            for pi:=0 to paperDB_cnt-1 do
              begin
                with FPaperDS.Fields[pi] do case DataType of
                  ftString,ftMemo,ftWideString,ftFixedWideChar,ftWideMemo{,ftFmtMemo,ftFixedChar}:FPaperDS.Fields[pi].AsString:=tmpDbf.Fields[fields_ref[pi].FI].AsString;
                  ftBoolean:FPaperDS.Fields[pi].AsBoolean:=tmpDbf.Fields[fields_ref[pi].FI].AsBoolean;
                  ftFloat:FPaperDS.Fields[pi].AsFloat:=tmpDbf.Fields[fields_ref[pi].FI].AsFloat;
                  ftInteger,ftLargeint,ftSmallint,ftWord:FPaperDS.Fields[pi].AsLargeInt:=tmpDbf.Fields[fields_ref[pi].FI].AsLargeInt;
                  ftDateTime,ftDate,ftTime:FPaperDS.Fields[pi].AsDateTime:=tmpDbf.Fields[fields_ref[pi].FI].AsDateTime;
                  ftBlob:FPaperDS.Fields[pi].Assign(tmpDbf.Fields[fields_ref[pi].FI]);
                  else assert(false,'FPaperDS.Fields[pi].DataType未预设。');
                end;
              end;
            FPaperDS.Post;
          end;
        FPaperDS.Next;
      end;
    END;

    IF FPaperDS.EOF and FPaperDS.BOF THEN ELSE BEGIN
      for pj:=0 to max_attr do
        begin
          if attr_range[pj].min > attr_range[pj].max then continue;
          tmpDbf:=FFieldList[pj].Dbf;
          if tmpDbf.EOF and tmpDbf.BOF then continue;

          FPaperDS.First;
          if not FPaperDS.EOF then repeat
            PID:=FPaperDS.FieldByName(_Col_PID_).AsString;
            //TDbf(tmpDbf).IndexName:='id';
            //if TDbf(tmpDbf).SearchKey(PID,stEqual) then begin
            if LocatePID(tmpDbf,PID) then begin
              FPaperDS.Edit;
              for pi:=attr_range[pj].min to attr_range[pj].max do begin
                case FPaperDS.Fields[pi].DataType of
                  ftString,ftMemo,ftWideString,ftFixedWideChar,ftWideMemo{,ftFmtMemo,ftFixedChar}:
                    FPaperDS.Fields[pi].AsString:=tmpDbf.Fields[fields_ref[pi].FI].AsString;
                  ftBoolean:
                    FPaperDS.Fields[pi].AsBoolean:=tmpDbf.Fields[fields_ref[pi].FI].AsBoolean;
                  ftFloat:
                    FPaperDS.Fields[pi].AsFloat:=tmpDbf.Fields[fields_ref[pi].FI].AsFloat;
                  ftInteger,ftLargeint,ftSmallint,ftWord:
                    FPaperDS.Fields[pi].AsLargeInt:=tmpDbf.Fields[fields_ref[pi].FI].AsLargeInt;
                  ftDateTime,ftDate,ftTime:
                    FPaperDS.Fields[pi].AsDateTime:=tmpDbf.Fields[fields_ref[pi].FI].AsDateTime;
                  ftBlob:
                    FPaperDS.Fields[pi].Assign(tmpDbf.Fields[fields_ref[pi].FI]);
                  else assert(false,'FPaperDS.Fields[pi].DataType未预设。');
                end;
              end;
              FPaperDS.Post;
            end;
            FPaperDS.Next;
          until FPaperDS.EOF;
        end;
    END;
    if RunPerformance.Filter_AutoRun then TableFilter;
    if FPaperDS.BookmarkValid(bm) then FPaperDS.GotoBookmark(bm);
  finally
    EndUpdate;
    if (not IsUpdating) and (FOnMainGridRebuildDone<>nil) then FOnMainGridRebuildDone(Self);
  end;
end;

procedure TRTFP.UpdateCurrentRec(PID:RTFP_ID);
var nowPID:RTFP_ID;
    fieldname,attrsname:string;
    field_index,poss,len:integer;
    bm:TBookMark;
begin
  nowPID:=FPaperDS.FieldByName(_Col_PID_).AsString;
  if PID='' then PID:=NowPID;
  BeginUpdate;
  if nowPID<>PID then with FPaperDS do begin
    bm:=Bookmark;
    First;
    while not EOF do
      begin
        if FieldByName(_Col_PID_).AsString=PID then break;
        Next;
      end;
    if EOF then begin
      ShowMsgOK('错误','UpdateCurrentRec找不到PID['+PID+']');
      EndUpdate;exit;
    end;
  end;

  FPaperDS.Edit;

  for field_index:=0 to FPaperDS.FieldDefs.Count-1 do
    begin
      fieldname:=FPaperDS.FieldDefs[field_index].Name;
      if fieldname=_Col_PID_ then continue;
      poss:=pos('(',fieldname);
      if poss>0 then begin
        len:=length(fieldname);
        attrsname:=fieldname;
        delete(fieldname,poss,len);
        delete(attrsname,1,poss);
        delete(attrsname,length(attrsname),1);
        //FPaperDS.Fields[field_index].AsString:=ReadFieldAsString(fieldname,attrsname,PID,[]);
        case FPaperDS.Fields[field_index].DataType of
          ftInteger,ftLargeint,ftSmallint:
            FPaperDS.Fields[field_index].AsInteger:=ReadFieldAsInteger(fieldname,attrsname,PID,[]);
          ftFloat:
            FPaperDS.Fields[field_index].AsFloat:=ReadFieldAsDouble(fieldname,attrsname,PID,[]);
          ftBoolean:
            FPaperDS.Fields[field_index].AsBoolean:=ReadFieldAsBoolean(fieldname,attrsname,PID,[]);
          ftDate,ftDateTime,ftTime:
            FPaperDS.Fields[field_index].AsDateTime:=ReadFieldAsDateTime(fieldname,attrsname,PID,[]);
          else
            FPaperDS.Fields[field_index].AsString:=ReadFieldAsString(fieldname,attrsname,PID,[]);
        end;
      end else begin
        FPaperDS.Fields[field_index].AsString:=GetPaperAttrs(fieldname,PID);
      end;
    end;

  FPaperDS.Post;

  if nowPID<>PID then with FPaperDS do begin
    if BookmarkValid(bm) then GotoBookmark(bm);
  end;
  EndUpdate;

end;

function CheckRegExpr(expr:string):boolean;
var regg:TRegExpr;
begin
  result:=false;
  if expr='' then exit;
  regg:=TRegExpr.Create(expr);
  try
    try
      //regg.Expression:=expr;
      if regg.Exec('-9~Ma中') then;
      except exit;
    end;
  finally
    regg.Free;
  end;
  result:=true;
end;

procedure TRTFP.TableFilter;
var colname,method,value:string;
    col_num:integer;
    regg:TRegExpr;
    cmd:string;
    bm:TBookMark;
    mem:TMemoryStream;
    tmp_pfunc:array[0..2]of pFuncAufStr;
begin
  //= eql         相等
  //!= <> neq     不相等
  //has,contains  包含有
  //in            在其内
  //true          是否为真
  //false         是否为假
  //>    gtr      大于
  //>=   gtq      大等
  //<    les      小于
  //<=   leq      小等
  //reg           正则表达式

  cmd:=RunPerformance.Filter_Command;

  if (not IsUpdating) and (FOnMainGridRebuilding<>nil) then FOnMainGridRebuilding(Self);
  regg:=TRegExpr.Create;
  mem:=TMemoryStream.Create;
  BeginUpdate;
  bm:=FPaperDS.Bookmark;
  try

    StringReplace(cmd,'=',' eql ',[rfReplaceAll]);
    StringReplace(cmd,'!=',' neq ',[rfReplaceAll]);
    StringReplace(cmd,'<>',' neq ',[rfReplaceAll]);
    StringReplace(cmd,'>',' gtr ',[rfReplaceAll]);
    StringReplace(cmd,'>=',' gtq ',[rfReplaceAll]);
    StringReplace(cmd,'<',' les ',[rfReplaceAll]);
    StringReplace(cmd,'<=',' leq ',[rfReplaceAll]);
    StringReplace(cmd,'=~',' reg ',[rfReplaceAll]);

    tmp_pfunc[0]:=FAuf.Script.IO_fptr.error;
    tmp_pfunc[1]:=FAuf.Script.IO_fptr.print;
    tmp_pfunc[2]:=FAuf.Script.IO_fptr.echo;
    FAuf.Script.IO_fptr.error:=nil;
    FAuf.Script.IO_fptr.print:=nil;
    FAuf.Script.IO_fptr.echo:=nil;
    FAuf.ReadArgs(cmd);
    if FAuf.ArgsCount<2 then exit;

    colname:=FAuf.nargs[0].arg;
    method:=FAuf.nargs[1].arg;
    value:=FAuf.nargs[2].arg;

    case method of
      'true','false','valid':;
      'reg':if CheckRegExpr(value) then regg.Expression:=value else exit;//主窗体的try except似乎没啥用，正则表达式不能判断错误，错误的表达式直接导致闪退
      else if FAuf.ArgsCount<3 then exit;
    end;


    col_num:=0;
    while col_num<FPaperDS.FieldDefs.Count do
      begin
        if FPaperDS.FieldDefs[col_num].Name=colname then break;
        inc(col_num);
      end;
    if col_num>=FPaperDS.FieldDefs.Count then exit;

    with FPaperDS do
      begin
        if not Active then Open;//没有必要吧

        First;
        while not EOF do
          begin
            case lowercase(method) of
              'eql':if Fields[Col_num].AsString<>value then Delete else Next;
              'neq':if Fields[Col_num].AsString=value then Delete else Next;
              'in':if pos(Fields[Col_num].AsString,value)<=0 then Delete else Next;
              'has','contains':if pos(value,Fields[Col_num].AsString)<=0 then Delete else Next;
              '!in':if pos(Fields[Col_num].AsString,value)>0 then Delete else Next;
              '!has','!contains':if pos(value,Fields[Col_num].AsString)>0 then Delete else Next;
              'true':if not Fields[Col_num].AsBoolean then Delete else Next;
              'false':if Fields[Col_num].AsBoolean then Delete else Next;
              'valid':begin
                if Fields[Col_num] is TBlobField then begin
                  mem.Clear;
                  TBlobField(Fields[Col_num]).SaveToStream(mem);
                  if mem.Size=0 then Delete else Next;
                end else begin
                  if Fields[Col_num].AsString='' then Delete else Next;
                end;
              end;
              'gtr':if Fields[Col_num].AsLargeInt<=Usf.to_f(value) then Delete else Next;
              'gtq':if Fields[Col_num].AsLargeInt<Usf.to_f(value) then Delete else Next;
              'les':if Fields[Col_num].AsLargeInt>=Usf.to_f(value) then Delete else Next;
              'leq':if Fields[Col_num].AsLargeInt>Usf.to_f(value) then Delete else Next;
              'reg':if not regg.Exec(Fields[Col_num].AsString) then Delete else Next;
              else exit;
            end;
          end;
      end;
  finally
    FAuf.Script.IO_fptr.error:=tmp_pfunc[0];
    FAuf.Script.IO_fptr.print:=tmp_pfunc[1];
    FAuf.Script.IO_fptr.echo:=tmp_pfunc[2];
    if FPaperDS.BookmarkValid(bm) then FPaperDS.GotoBookmark(bm);
    EndUpdate;
    regg.Free;
    mem.Free;
    if (not IsUpdating) and (FOnMainGridRebuildDone<>nil) then FOnMainGridRebuildDone(Self);
  end;
end;

procedure TRTFP.TableSorter;unimplemented;
var sort_option:TDataSetSortOption;
    field_count,field_no:byte;
    mode:TDataSetSortMode;
    stmp,cmd:string;
    tmp_pfunc:array[0..2]of pFuncAufStr;
begin

  cmd:=RunPerformance.Sorter_Command;

  if (not IsUpdating) and (FOnMainGridRebuilding<>nil) then FOnMainGridRebuilding(Self);
  BeginUpdate;
  //bm:=FPaperDS.Bookmark;//这个书签要单独找
  try
    sort_option:=TDataSetSortOption.Create;
    tmp_pfunc[0]:=FAuf.Script.IO_fptr.error;
    tmp_pfunc[1]:=FAuf.Script.IO_fptr.print;
    tmp_pfunc[2]:=FAuf.Script.IO_fptr.echo;
    FAuf.Script.IO_fptr.error:=nil;
    FAuf.Script.IO_fptr.print:=nil;
    FAuf.Script.IO_fptr.echo:=nil;
    FAuf.ReadArgs(cmd);
    field_count:=FAuf.ArgsCount;
    if field_count<1 then exit;
    mode:=smAscending;
    for field_no:=0 to field_count-1 do begin
      if not FAuf.TryArgToString(field_no,stmp) then continue;
      case lowercase(stmp) of
        'a','升序','+','up':mode:=smAscending;
        'd','降序','-','down':mode:=smDescending;
        else sort_option.Assign(stmp,mode);
      end;
    end;

    SortDataSet(FPaperDS,sort_option);
  finally
    sort_option.Free;
    FAuf.Script.IO_fptr.error:=tmp_pfunc[0];
    FAuf.Script.IO_fptr.print:=tmp_pfunc[1];
    FAuf.Script.IO_fptr.echo:=tmp_pfunc[2];
    //if FPaperDS.BookmarkValid(bm) then FPaperDS.GotoBookmark(bm);
    EndUpdate;
    if (not IsUpdating) and (FOnMainGridRebuildDone<>nil) then FOnMainGridRebuildDone(Self);
  end;
end;






