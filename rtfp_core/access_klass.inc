//与分类相关的方法

function TRTFP.AddKlass(klassname:string;pathname:string=''):TKlass;
var tmp:TKlass;
begin
  result:=nil;
  if not TRTFP.IsKlassName(klassname) then exit;
  if FKlassList.FindItemIndexByName(klassname)>=0 then exit;
  if pathname<>'' then pathname:=pathname+'/';
  case DataSetType of
    dstDBF:tmp:=FKlassList.AddEx('class/'+pathname+klassname,klassname,'dbf');
    dstBUF:tmp:=FKlassList.AddEx('class/'+pathname+klassname,klassname,'buf');
  end;
  ForceDirectories(FFilePath+FRootFolder+'/class/'+pathname);
  if not OpenDbf(tmp.FullPath,tmp.Dbf) then begin
    GenAttrDefaultAttribute(tmp.Dbf);
    NewDbf(tmp.FullPath,tmp.Dbf);
  end;
  ClassChange;
  result:=tmp;
end;

function TRTFP.FindKlass(klassname:string):TKlass;
begin
  result:=FKlassList.FindItemByName(klassname);
end;

procedure TRTFP.DeleteKlass(klassname:string);
var index,recNumber:integer;
    tmp:TKlass;
    PID:RTFP_ID;
    str:TStringList;
    attrs_modified:boolean;
begin
  index:=FKlassList.FindItemIndexByName(klassname);
  if index<0 then exit;
  tmp:=FKlassList.Items[index];

  str:=TStringList.Create;
  str.Sorted:=true;
  attrs_modified:=false;
  BeginUpdate;
  try
    with tmp.Dbf do begin
      if not Active then Open;
      First;
      if not EOF then attrs_modified:=true;
      while not EOF do
        begin
          PID:=FieldByName(_Col_PID_).AsString;
          ReadFieldAsMemo(_Col_class_DefaultCl_,_Attrs_Class_,PID,str,[]);
          if str.Find(tmp.Name,recNumber) then str.Delete(recNumber);
          EditFieldAsMemo(_Col_class_DefaultCl_,_Attrs_Class_,PID,str,[]);
          Next;
        end;
    end;
  finally
    str.Free;
  end;
  EndUpdate;
  CloseDbf(tmp.FullPath,tmp.Dbf);
  DeleteDbf(tmp.FullPath,tmp.Dbf);
  FKlassList.Delete(index);
  ClassChange;
  if attrs_modified then RebuildMainGrid{DataChange};
end;

function TRTFP.KlassInclude(klassname:string;PID:RTFP_ID):boolean;
var index:integer;
    stmp:TStringList;
    tmpDbf:TDataSet;
begin
  result:=false;
  //索引文件更新
  index:=FKlassList.FindItemIndexByName(klassname);
  if index<0 then exit;
  tmpDbf:=FKlassList[index].Dbf;
  with tmpDbf do begin
    if not Active then Open;
    if not LocatePID(tmpDbf,PID) then begin
      Append;
      FieldByName(_Col_PID_).AsString:=PID;
      Post;
    end;
  end;
  //修改字段
  stmp:=TStringList.Create;
  stmp.Sorted:=true;
  try
    ReadFieldAsMemo(_Col_class_DefaultCl_,_Attrs_Class_,PID,stmp,[]);
    if not stmp.Find(klassname,index) then stmp.Add(klassname);
    EditFieldAsMemo(_Col_class_DefaultCl_,_Attrs_Class_,PID,stmp,[]);
  finally
    stmp.Free;
  end;
  DataChange(PID);
  result:=true;
end;

function TRTFP.KlassExclude(klassname:string;PID:RTFP_ID):boolean;
var index:integer;
    stmp:TStringList;
    tmpDbf:TDataSet;
begin
  result:=false;
  //索引文件更新
  index:=FKlassList.FindItemIndexByName(klassname);
  if index<0 then exit;
  tmpDbf:=FKlassList[index].Dbf;
  with tmpDbf do begin
    if not Active then Open;
    if LocatePID(tmpDbf,PID) then Delete;
  end;
  //修改字段
  stmp:=TStringList.Create;
  stmp.Sorted:=true;
  try
    ReadFieldAsMemo(_Col_class_DefaultCl_,_Attrs_Class_,PID,stmp,[]);
    if stmp.Find(klassname,index) then stmp.Delete(index);
    EditFieldAsMemo(_Col_class_DefaultCl_,_Attrs_Class_,PID,stmp,[]);
  finally
    stmp.Free;
  end;
  DataChange(PID);
  result:=true;
end;

function TRTFP.KlassIncludeFromCombo(PID:RTFP_ID;active:boolean):boolean;
var CL:TStringList;
    KL:TKlass;
    stmp:string;
begin
  CL:=TStringList.Create;
  try
    for KL in FKlassList do
      if KL.FilterEnabled or not active then
        begin
          CL.Add(KL.Name);
          CL.Objects[CL.Count-1]:=KL;
        end;
    if CL.Count>0 then
      begin
        if CL.Count=1 then KlassInclude(CL[0],PID)
        else begin
          stmp:=ShowMsgCombo('纳入分类','选择文件拟纳入的分类',CL);
          if stmp<>'' then KlassInclude(stmp,PID);
        end;
      end;
  finally
    CL.Free;
  end;
  result:=true;
end;



