//将存档转换成高版本的方法，按照存档最后一次保存的版本编号依次检查需要转换的过程

procedure TRTFP.Update_0_1_1_alpha_18;
var DbfList:TList;
    klass:TKlass;
    attrs:TAttrsGroup;
    ptr:Pointer;
    pid:string;
begin
  //将RTFPID中的+-改成{}
  DbfList:=TList.Create;
  try
    DbfList.Add(FPaperDB);
    DbfList.Add(FImageDB);
    DbfList.Add(FNotesDB);
    for klass in FKlassList do DbfList.Add(klass.Dbf);
    for attrs in FFieldList do DbfList.Add(attrs.Dbf);
    for ptr in DbfList do with TDataSet(ptr) do
      begin
        if not Active then Open;
        First;
        while not EOF do
          begin
            pid:=FieldByName(_Col_PID_).AsString;
            pid:=StringReplace(pid,'+','{',[rfReplaceAll]);
            pid:=StringReplace(pid,'-','}',[rfReplaceAll]);
            Edit;
            FieldByName(_Col_PID_).AsString:=pid;
            Post;
            Next;
          end;
      end;
  finally
    DbfList.Free;
  end;
end;
procedure TRTFP.Update_0_1_2_alpha_8;//暂时不要这个了，字段可能不能用DBF这个，效果太差
var tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
begin
  {
  tmpAG:=FFieldList.FindItemByName(_Attrs_Basic_);
  assert(tmpAG<>nil,'tmpAG此时不会是nil');

  BeginUpdate;

  tmpAF:=tmpAG.FieldList.FindItemByName(_Col_basic_Degree_);
  if tmpAF=nil then tmpAF:=AddField(_Col_basic_Degree_,_Attrs_Basic_,ftString);
  tmpAF:=tmpAG.FieldList.FindItemByName(_Col_basic_Teacher_);
  if tmpAF=nil then tmpAF:=AddField(_Col_basic_Teacher_,_Attrs_Basic_,ftMemo);
  tmpAF:=tmpAG.FieldList.FindItemByName(_Col_basic_City_);
  if tmpAF=nil then tmpAF:=AddField(_Col_basic_City_,_Attrs_Basic_,ftMemo);
  tmpAF:=tmpAG.FieldList.FindItemByName(_Col_basic_Meeting_);
  if tmpAF=nil then tmpAF:=AddField(_Col_basic_Meeting_,_Attrs_Basic_,ftMemo);
  tmpAF:=tmpAG.FieldList.FindItemByName(_Col_basic_Sponsor_);
  if tmpAF=nil then tmpAF:=AddField(_Col_basic_Sponsor_,_Attrs_Basic_,ftMemo);
  tmpAF:=tmpAG.FieldList.FindItemByName(_Col_basic_CN_);
  if tmpAF=nil then tmpAF:=AddField(_Col_basic_CN_,_Attrs_Basic_,ftString);
  EndUpdate;
  }

  //tmpDbf:=FFieldList.FindItemByName(_Attrs_Basic_).Dbf;
  {
  with FFieldList.FindItemByName(_Attrs_Basic_).Dbf do begin

    if not Active then Open;
    TryExclusive;

    DbfFieldDefs.Add(_Col_basic_Degree_, ftString, 16, false);
    DbfFieldDefs.Add(_Col_basic_Teacher_, ftMemo, 0, false);
    DbfFieldDefs.Add(_Col_basic_City_, ftMemo, 0, false);
    DbfFieldDefs.Add(_Col_basic_Meeting_, ftMemo, 0, false);
    DbfFieldDefs.Add(_Col_basic_Sponsor_, ftMemo, 0, false);
    DbfFieldDefs.Add(_Col_basic_CN_, ftString, 16, false);

    PackTable;
    Close;
    Open;
    EndExclusive;
    RegenerateIndexes;

  end;
  }
end;
procedure TRTFP.Update_0_2_5_alpha_3;
begin
  //新增“引注标识码”Tag
  Tag['引注标识码']:='';
  if FOnChange<>nil then FOnChange(Self);
end;
procedure TRTFP.Update_0_2_7_alpha_4;
begin
  //新增“字段关联路径”Tag
  Tag['字段关联路径']:='';
  Tag['字段关联后缀']:='';
  Tag['编辑属性布局']:='default.fmt';
  if FOnChange<>nil then FOnChange(Self);
  //实际上并不会在打开旧文件后有修改星号
  //这是因为触发OnOpenDone之后会复原成未修改状态
end;


procedure TRTFP.Update(save_version:string);
begin
  if not TRTFP.VersionCheck(save_version,'0.1.1-alpha.18') then Update_0_1_1_alpha_18;
  //if not TRTFP.VersionCheck(save_version,'0.1.2-alpha.8') then Update_0_1_2_alpha_8;
  if not TRTFP.VersionCheck(save_version,'0.2.5-alpha.3') then Update_0_2_5_alpha_3;
  if not TRTFP.VersionCheck(save_version,'0.2.7-alpha.4') then Update_0_2_7_alpha_4;

end;

class function TRTFP.VersionCheck(check,target:string):boolean;
var s1,s2:TStringList;
    pi,v1,v2:integer;
begin
  //0.1.1-alpha.18 加入
  if check='' then check:='0.0.0-alpha.0';
  result:=true;
  s1:=TStringList.Create;
  s2:=TStringList.Create;
  try
    s1.CommaText:=StringReplace(StringReplace(check,'-',',',[rfReplaceAll]),'.',',',[rfReplaceAll]);
    s2.CommaText:=StringReplace(StringReplace(target,'-',',',[rfReplaceAll]),'.',',',[rfReplaceAll]);
    if (s1.Count<=0) or (s1.Count <> s2.Count) then raise Exception.Create('');
    for pi:=0 to s1.Count-1 do
      begin
        try
          v1:=StrToInt(s1[pi]);
          v2:=StrToInt(s2[pi]);
          if v1<>v2 then begin
            if v1<v2 then result:=false;
            exit;
          end;
        except
          v1:=strcomp(pchar(s1[pi]),pchar(s2[pi]));
          if v1<>0 then begin
            if v1<0 then result:=false;
            exit;
          end;
        end;
      end;
  finally
    s1.Free;
    s2.Free;
  end;
end;
