//与控件对接的部分


{工程属性列表 Tags}
procedure TRTFP.ProjectPropertiesValidate(AValueListEditor:TValueListEditor);
var str:TStringList;
    stmp:string;
begin
  AValueListEditor.Values['工程标题']:=Self.Title;
  AValueListEditor.Values['创建用户']:=Self.User;
  str:=TStringList.Create;
  try
    Self.FProjectTags.Keys(str);
    for stmp in str do
      if stmp<>'属性' then
        AValueListEditor.Values[stmp]:=Self.Tag[stmp];
  finally
    str.Free;
  end;

end;

procedure TRTFP.ProjectPropertiesDataPost(AValueListEditor:TValueListEditor);
var str:TStringList;
    stmp,old_value,new_value:string;
begin
  Self.Title:=AValueListEditor.Values['工程标题'];
  Self.User:=AValueListEditor.Values['创建用户'];
  str:=TStringList.Create;
  try
    Self.FProjectTags.Keys(str);
    for stmp in str do
      if FProjectTags.Editable[stmp] then begin
        old_value:=Self.Tag[stmp];
        new_value:=AValueListEditor.Values[stmp];
        if old_value<>new_value then begin
          Self.Tag[stmp]:=new_value;
          TagChange(stmp,new_value);
        end;
      end;
  finally
    str.Free;
  end;
end;

{字段列表显示}
procedure TRTFP.FieldListValidate(AListView:TListCheck);
var tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
    dispAG,dispAF:string;
    tmpNode:TListCheckNode;
begin
  //AListView.BeginUpdate;
  AListView.Root.Clear;
  AListView.Refresh;
  for tmpAG in FFieldList do
    begin
      if (tmpAG.DisplayName<>'') and (tmpAG.DisplayName<>tmpAG.Name) then
        dispAG:=tmpAG.DisplayName+' ('+tmpAG.Name+')'
      else
        dispAG:=tmpAG.Name;
      tmpNode:=AListView.Root.AddItem(tmpAG.Name,tmpAG);
      tmpNode.Unfold:=tmpAG.GroupShown;
      tmpNode.DisplayName:=dispAG;
      for tmpAF in tmpAG.FieldList do
        begin
          if (tmpAF.DisplayName<>'') and (tmpAF.DisplayName<>tmpAF.FieldName) then
            dispAF:=tmpAF.DisplayName+' ('+tmpAF.FieldName+')'
          else
            dispAF:=tmpAF.FieldName;
          with tmpNode.AddItem(tmpAF.FieldName,tmpAF) do begin
            DisplayName:=dispAF;
            Checked:=tmpAF.Shown;
          end;
        end;
    end;
  //AListView.EndUpdate;
  AListView.Refresh;
end;

procedure RecurKlassListValidate(ANode:TListCheckNode;AKlassList:TKlassList;show_rec_count:boolean);
var tmpKL:TKlass;
    tmpNode:TListCheckNode;
    pi:integer;
begin
  //追加一个可展开分类的filter开关
  if AKlassList.Owner<>nil then begin
    tmpNode:=ANode.AddItem('.',AKlassList.Owner);
    tmpNode.Checked:=AKlassList.Owner.FilterEnabled;
  end;
  for pi:=0 to AKlassList.Count-1 do begin
    //GetEnumerator已经是递归的了，所以不能使用for-in
    tmpKL:=AKlassList.Items[pi];
    if show_rec_count then begin
      if not tmpKL.Dbf.Active then tmpKL.Dbf.Open;
      tmpNode:=ANode.AddItem(tmpKL.Name+' ('+IntToStr(tmpKL.Dbf.RecordCount)+')',tmpKL);
    end else begin
      tmpNode:=ANode.AddItem(tmpKL.Name,tmpKL);
    end;
    tmpNode.Checked:=tmpKL.FilterEnabled;
    tmpNode.Unfold:=tmpKL.SubKlassShown;
    if tmpKL.KlassList.Count>0 then RecurKlassListValidate(tmpNode,tmpKL.KlassList,show_rec_count);
  end;
end;

{分类列表显示}
procedure TRTFP.KlassListValidate(AListView:TListCheck);
begin
  //AListView.BeginUpdate;
  AListView.Root.Clear;
  AListView.Refresh;
  RecurKlassListValidate(AListView.Root,FKlassList,RunPerformance.DisplayKlassListRecCount);
  //AListView.EndUpdate;
  AListView.Refresh;
end;


{主表显示}
//很显然InsertPaperDS的方法之后还需要再sort一遍，这样性能会非常差
//应该要兼顾Filter和Sorter重构
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
    procedure CopyFieldValue(dst,src:TField);
    begin
      case dst.DataType of
        ftString,ftWideString,ftFixedWideChar{,ftFixedChar}:dst.AsString:=src.AsString;
        ftMemo,ftWideMemo{,ftFmtMemo}:dst.AsString:=src.AsString;
        ftBoolean:dst.AsBoolean:=src.AsBoolean;
        ftFloat:dst.AsFloat:=src.AsFloat;
        ftInteger,ftLargeint,ftSmallint,ftWord:dst.AsLargeInt:=src.AsLargeInt;
        ftDateTime,ftDate,ftTime:dst.AsDateTime:=src.AsDateTime;
        ftBlob:dst.Assign(src);
        else assert(false,'FPaperDS.Fields[pi].DataType未预设。');
      end;
    end;
    procedure GenerateFields_WithoutKlassFilter;
    //从FPaperDB中直接照抄所有PID到FPaperDS
    var ppi:integer;
    begin
      FPaperDB.First;
      if not FPaperDB.EOF then repeat
        FPaperDS.Append;
        for ppi:=0 to paperDB_cnt-1 do CopyFieldValue(FPaperDS.Fields[ppi],FPaperDB.Fields[fields_ref[ppi].FI]);
        FPaperDS.Post;
        FPaperDB.Next;
      until FPaperDB.EOF;
    end;
    procedure GenerateFields_WithKlassFilter;
    //根据分类勾选情况筛选PID到FPaperDS
    //这是临时的一个实现方式，用PID的效率显然不如整型数
    type TCombineMethod = (smNOR,smOR,smAND,smNAND);
    var ppi,itmp:integer;
        pid_list,pop_list:TStringList;
        pid_exists:boolean;
        comb_method:TCombineMethod;
        stmp:string;
    begin
      with RunPerformance do
        if Klass_Filter_AND then begin
          if Klass_Filter_NOT then comb_method:=smNAND
          else comb_method:=smAND;
        end else begin
          if Klass_Filter_NOT then comb_method:=smNOR
          else comb_method:=smOR;
        end;

      //ins为真时初始为0，使用插入方法；为假时初始为全集，使用移除方法。
      //sub为真时最后额外进行补集操作。
      //..
      //     | CombMtd |  OpAND     OpNOT   |  Init       Method    Value
      //     +---------+--------------------+-----------------------------------
      //     | smNOR   |  False     True    |  Complete   Remove    Result
      //     | smOR    |  False     False   |  Empty      Insert    Result
      //     | smNAND  |  True      True    |  Empty      Insert    1 - Result
      //     | smAND   |  True      False   |  Complete   Remove    1 - Result
      //..

      pid_list:=TStringList.Create;
      pop_list:=TStringList.Create;
      pid_list.Sorted:=true;
      pop_list.Sorted:=true;
      pid_list.CaseSensitive:=true;
      pop_list.CaseSensitive:=true;
      try
        case comb_method of
          smNOR,smAND:GetPIDList(pid_list);
        end;
        for klass in FKlassList do begin
          if not klass.FilterEnabled then continue;
          with klass.Dbf do begin
            if not Active then Open;
            First;
            if EOF then continue;
            case comb_method of smAND,smNAND:
              begin
                //AND和NAND每一个Klass需要新建一个列表用于排除
                pop_list.Clear;
                GetPIDList(pop_list);
              end;
            end;
            while not EOF do begin
              stmp:=FieldByName(_Col_PID_).AsString;
              case comb_method of
                smNOR:begin
                  pid_exists:=pid_list.Find(stmp,itmp);
                  if pid_exists then pid_list.Delete(itmp);
                  if pid_list.Count=0 then break;
                end;
                smOR:begin
                  pid_exists:=pid_list.Find(stmp,itmp);
                  if not pid_exists then pid_list.Add(stmp);
                end;
                smAND,smNAND:begin
                  pid_exists:=pop_list.Find(stmp,itmp);
                  if pid_exists then pop_list.Delete(itmp);
                  if pop_list.Count=0 then break;
                end;
              end;
              Next;
            end;
            case comb_method of
              smAND:
              begin
                for stmp in pop_list do begin
                  if pid_list.Find(stmp,itmp) then pid_list.Delete(itmp);
                  if pid_list.Count=0 then break;
                end;
              end;
              smNAND:
              begin
                for stmp in pop_list do begin
                  if not pid_list.Find(stmp,itmp) then pid_list.Add(stmp);
                end;
              end;
            end;
          end;
        end;
        for stmp in pid_list do begin
          InsertPaperDS(stmp);
        end;
      finally
        pid_list.Free;
        pop_list.Free;
      end;
      FPaperDS.First;
      if not FPaperDS.Active then FPaperDB.Open;
      while not FPaperDS.EOF do begin
        if LocatePID(FPaperDB,FPaperDS.FieldByName(_Col_PID_).AsString) then
          begin
            FPaperDS.Edit;
            for ppi:=0 to paperDB_cnt-1 do CopyFieldValue(FPaperDS.Fields[ppi],tmpDbf.Fields[fields_ref[ppi].FI]);
            FPaperDS.Post;
          end;
        FPaperDS.Next;
      end;
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
              //FPaperDS.FieldDefs.Add(tmpFieldDef.Name+'('+tmpAG.Name+')',ftString,255);
              FPaperDS.FieldDefs.Add(tmpFieldDef.Name+'('+tmpAG.Name+')',ftMemo);
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
      GenerateFields_WithoutKlassFilter;
    END ELSE BEGIN
      GenerateFields_WithKlassFilter;
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
            if LocatePID(tmpDbf,PID) then begin
              FPaperDS.Edit;
              for pi:=attr_range[pj].min to attr_range[pj].max do begin
                CopyFieldValue(FPaperDS.Fields[pi],tmpDbf.Fields[fields_ref[pi].FI]);
              end;
              FPaperDS.Post;
            end;
            FPaperDS.Next;
          until FPaperDS.EOF;
        end;
    END;
    if RunPerformance.Filter_AutoRun then TableFilter;
    if RunPerformance.Sorter_AutoRun then TableSorter;//为啥不放这呢
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
//var regg:TRegExpr;
begin
  result:=false;
  if expr='' then exit;
  //regg:=TRegExpr.Create{(expr)};
  //try
  try
    //regg.Expression:=expr;
    //if regg.Exec('-9~Ma中') then;
    rtfp_reg.Expression:=expr;
    if rtfp_reg.Exec('-9~Ma中') then;
  except
    exit;
  end;
  //finally
    //regg.Free;
  //end;
  result:=true;
end;

procedure TRTFP.TableFilter;
var colname,method,value:string;
    col_num:integer;
    //regg:TRegExpr;
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
  //regg:=TRegExpr.Create;
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
      'reg':if CheckRegExpr(value) then rtfp_reg.Expression:=value else exit;
      //'reg':if CheckRegExpr(value) then regg.Expression:=value else exit;
      //主窗体的try except似乎没啥用，正则表达式不能判断错误，错误的表达式直接导致闪退
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
              //'reg':if not regg.Exec(Fields[Col_num].AsString) then Delete else Next;
              'reg':if not rtfp_reg.Exec(Fields[Col_num].AsString) then Delete else Next;
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
    //regg.Free;
    mem.Free;
    if (not IsUpdating) and (FOnMainGridRebuildDone<>nil) then FOnMainGridRebuildDone(Self);
  end;
end;

procedure TRTFP.TableSorter;
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






