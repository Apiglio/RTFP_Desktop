//与分类相关的方法

function TRTFP.AddKlass(klassname:string;parentklass:TKlass=nil):TKlass;
var tmpKL:TKlass;
    tmpKlassList:TKlassList;
    mkdir_path:string;
begin
  result:=nil;
  if not TRTFP.IsKlassName(klassname) then exit;
  if parentklass=nil then tmpKlassList:=FKlassList else tmpKlassList:=parentklass.KlassList;
  if tmpKlassList.FindItemIndexByName(klassname)>=0 then exit;
  if parentklass<>nil then begin
    mkdir_path:=FKlassList.KlassDir;
    if parentklass.Path<>'' then mkdir_path:=mkdir_path+'\'+parentklass.Path;
    mkdir_path:=mkdir_path+'\'+parentklass.Name;
    ForceDirectories(mkdir_path);
  end;
  tmpKL:=tmpKlassList.Add(klassname,DataSetType);
  if not OpenDbf(tmpKL.FullPath(CurrentPathFull),tmpKL.Dbf) then begin
    GenAttrDefaultAttribute(tmpKL.Dbf);
    NewDbf(tmpKL.FullPath(CurrentPathFull),tmpKL.Dbf);
  end;
  ClassChange;
  result:=tmpKL;
end;

function StringSplit(Source,Delimiter:string):TStringList;
var stmp,segm:string;
    dlen,posi:Integer;
begin
  stmp:=Source;
  dlen:=Length(Delimiter);
  result:=TStringList.Create;
  repeat
    posi:=pos(Delimiter,stmp);
    if posi>0 then begin
      segm:=stmp;
      System.Delete(segm,posi,length(segm));
      System.Delete(stmp,1,posi+dlen-1);
      result.Add(segm);
    end;
  until posi<=0;
  result.Add(stmp);
end;

function TRTFP.AddKlass(KlassnameSeries:string;Delimiter:Char):TKlass;
var kNAME:string;
    tmpKL,nxtKL:TKlass;
    tmpKlassList:TKlassList;
    pi:Integer;

begin
  result:=nil;
  with StringSplit(KlassnameSeries,delimiter) do begin
    tmpKL:=nil;
    for pi:=0 to Count-1 do begin
      kNAME:=Strings[pi];
      if kNAME='' then continue;
      if tmpKL=nil then tmpKlassList:=FKlassList else tmpKlassList:=tmpKL.KlassList;
      nxtKL:=tmpKlassList.FindItemByName(kNAME);
      if nxtKL=nil then nxtKL:=AddKlass(kNAME,tmpKL);
      tmpKL:=nxtKL;
    end;
    Free;
  end;
  result:=tmpKL;
end;

function TRTFP.FindKlass(KlassnameSeries:string;Delimiter:Char):TKlass;
var kNAME:string;
    tmpKL,nxtKL:TKlass;
    tmpKlassList:TKlassList;
    pi:Integer;

begin
  result:=nil;
  with StringSplit(KlassnameSeries,delimiter) do begin
    tmpKL:=nil;
    for pi:=0 to Count-1 do begin
      kNAME:=Strings[pi];
      if kNAME='' then continue;
      if tmpKL=nil then tmpKlassList:=FKlassList else tmpKlassList:=tmpKL.KlassList;
      nxtKL:=tmpKlassList.FindItemByName(kNAME);
      tmpKL:=nxtKL;
      if tmpKL=nil then break;
    end;
    Free;
  end;
  result:=tmpKL;
end;

procedure TRTFP.DeleteKlass(klass:TKlass);
var recNumber:integer;
    PID:RTFP_ID;
    str:TStringList;
    attrs_modified:boolean;
begin
  str:=TStringList.Create;
  str.Sorted:=true;
  attrs_modified:=false;
  BeginUpdate;
  try
    with klass.Dbf do begin
      if not Active then Open;
      First;
      if not EOF then attrs_modified:=true;
      while not EOF do
        begin
          PID:=FieldByName(_Col_PID_).AsString;
          ReadFieldAsMemo(_Col_class_DefaultCl_,_Attrs_Class_,PID,str,[]);
          if str.Find(klass.Name,recNumber) then str.Delete(recNumber);
          EditFieldAsMemo(_Col_class_DefaultCl_,_Attrs_Class_,PID,str,[]);
          Next;
        end;
    end;
  finally
    str.Free;
  end;
  EndUpdate;
  CloseDbf(klass.FullPath(CurrentPathFull),klass.Dbf);
  DeleteDbf(klass.FullPath(CurrentPathFull),klass.Dbf);

  ClassChange;
  if attrs_modified then RebuildMainGrid{DataChange};
end;

procedure TRTFP.DeleteKlass(KlassnameSeries:string;Delimiter:Char);
var tmpKL:TKlass;
begin
  tmpKL:=FindKlass(KlassnameSeries,Delimiter);
  if tmpKL=nil then exit;
  DeleteKlass(tmpKL);
end;

function TRTFP.KlassInclude(klassname:string;PID:RTFP_ID):boolean;
var index:integer;
    stmp:TStringList;
    tmpDbf:TDataSet;
    tmpKL:TKlass;
begin
  result:=false;
  //索引文件更新
  tmpKL:=FindKlass(klassname,'.');
  if tmpKL=nil then exit;
  tmpDbf:=tmpKL.Dbf;

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
    tmpKL:TKlass;
begin
  result:=false;
  //索引文件更新
  tmpKL:=FindKlass(klassname,'.');
  if tmpKL=nil then exit;
  tmpDbf:=tmpKL.Dbf;

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



