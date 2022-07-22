//访问存档数据库文件的基础方法

{$ifdef save_xml}
procedure CopyDbfToBuf(ADbf:TDbf;ABuf:TBufDataset);
var field_count,pi:integer;
    dbname:string;
begin
  dbname:=ADbf.FilePath+ADbf.TableName;
  delete(dbname,length(dbname)-3,4);
  ABuf.FileName:=dbname;
  ABuf.FieldDefs.Assign(ADbf.FieldDefs);
  field_count:=ABuf.FieldDefs.Count;
  ABuf.CreateDataset;
  ABuf.Open;
  ADbf.Open;
  ADbf.First;
  while not ADbf.EOF do
    begin
      ABuf.Append;
      for pi:=0 to field_count-1 do ABuf.Fields[pi].Value:=ADbf.Fields[pi].Value;
      Abuf.Post;
      ADbf.Next;
    end;
end;
{$endif}



function AddFieldInBuf(buf:TBufDataset;FieldName:string;ADataType:TFieldType;ASize:word=0):TFieldDef;
var tmpBuf:TBufDataset;
    pi,max_col:integer;
    res:TFieldDef;
begin
  result:=nil;
  if buf.FieldDefs.IndexOf(FieldName)>=0 then exit;//存在同名即退出
  tmpBuf:=TBufDataset.Create(nil);
  tmpBuf.FileName:=buf.FileName+'_bak';
  try
    tmpBuf.FieldDefs.Assign(buf.FieldDefs);
    tmpBuf.CreateDataset;
    max_col:=buf.FieldDefs.Count;
    buf.First;
    while not buf.EOF do
      begin
        tmpBuf.Append;
        for pi:=0 to max_col-1 do tmpBuf.Fields[pi].Assign(buf.Fields[pi]);
        tmpBuf.Post;
        buf.Next;
      end;
    tmpBuf.Close;
    tmpBuf.Open;
    buf.Close;
    buf.Clear;
    for pi:=0 to max_col-1 do
      begin
        {zan}res:=tmpBuf.FieldDefs[pi];
        buf.FieldDefs.Add({zan}res.Name,{zan}res.DataType,{zan}res.Size);
      end;
    buf.FieldDefs.Add(FieldName,ADataType,ASize);
    buf.CreateDataset;
    buf.Open;
    tmpBuf.First;
    while not tmpBuf.EOF do
      begin
        buf.Append;
        for pi:=0 to max_col-1 do buf.Fields[pi].Assign(tmpBuf.Fields[pi]);
        buf.Post;
        tmpBuf.Next;
      end;
  finally
    tmpBuf.Close;
    TRTFP.FileDelete(tmpBuf.FileName);
    tmpBuf.Free;
  end;
  result:=buf.FieldDefs[max_col];
end;

function DeleteFieldInBuf(buf:TBufDataset;FieldName:string):boolean;
var tmpBuf:TBufDataset;
    pi,del_id,max_col:integer;
    res:TFieldDef;
begin
  result:=false;
  del_id:=buf.FieldDefs.IndexOf(FieldName);
  if del_id<0 then exit;//不存在同名则退出
  tmpBuf:=TBufDataset.Create(nil);
  tmpBuf.FileName:=buf.FileName+'_bak';
  try
    if not buf.Active then buf.Open;
    tmpBuf.FieldDefs.Assign(buf.FieldDefs);
    tmpBuf.CreateDataset;
    tmpBuf.Open;
    max_col:=buf.FieldDefs.Count;
    buf.First;
    while not buf.EOF do
      begin
        tmpBuf.Append;
        for pi:=0 to max_col-1 do tmpBuf.Fields[pi].Assign(buf.Fields[pi]);
        tmpBuf.Post;
        buf.Next;
      end;
    tmpBuf.Close;
    tmpBuf.Open;
    buf.Close;
    buf.Clear;
    for pi:=0 to max_col-1 do
      begin
        if pi=del_id then continue;
        {zan}res:=tmpBuf.FieldDefs[pi];
        buf.FieldDefs.Add({zan}res.Name,{zan}res.DataType,{zan}res.Size);
      end;
    buf.CreateDataset;
    buf.Open;
    tmpBuf.First;
    while not tmpBuf.EOF do
      begin
        buf.Append;
        for pi:=0 to del_id-1 do buf.Fields[pi].Assign(tmpBuf.Fields[pi]);
        for pi:=del_id+1 to max_col-1 do buf.Fields[pi-1].Assign(tmpBuf.Fields[pi]);
        buf.Post;
        tmpBuf.Next;
      end;
  finally
    tmpBuf.Close;
    TRTFP.FileDelete(tmpBuf.FileName);
    tmpBuf.Free;
  end;
  result:=true;
end;

function RenameFieldInBuf(buf:TBufDataset;OldFieldName,NewFieldName:string):boolean;
var tmpBuf:TBufDataset;
    pi,ren_id,max_col:integer;
    res:TFieldDef;
begin
  result:=false;
  ren_id:=buf.FieldDefs.IndexOf(OldFieldName);
  if ren_id<0 then exit;//不存在同名则退出
  tmpBuf:=TBufDataset.Create(nil);
  tmpBuf.FileName:=buf.FileName+'_bak';
  try
    tmpBuf.FieldDefs.Assign(buf.FieldDefs);
    tmpBuf.CreateDataset;
    max_col:=buf.FieldDefs.Count;
    buf.First;
    while not buf.EOF do
      begin
        tmpBuf.Append;
        for pi:=0 to max_col-1 do tmpBuf.Fields[pi].Assign(buf.Fields[pi]);
        tmpBuf.Post;
        buf.Next;
      end;
    tmpBuf.Close;
    tmpBuf.Open;
    buf.Close;
    buf.Clear;
    for pi:=0 to max_col-1 do
      begin
        {zan}res:=tmpBuf.FieldDefs[pi];
        if pi=ren_id then
          buf.FieldDefs.Add(NewFieldName,{zan}res.DataType,{zan}res.Size)
        else
          buf.FieldDefs.Add({zan}res.Name,{zan}res.DataType,{zan}res.Size);
      end;
    buf.CreateDataset;
    buf.Open;
    tmpBuf.First;
    while not tmpBuf.EOF do
      begin
        buf.Append;
        for pi:=0 to max_col-1 do buf.Fields[pi].Assign(tmpBuf.Fields[pi]);
        buf.Post;
        tmpBuf.Next;
      end;
  finally
    tmpBuf.Close;
    TRTFP.FileDelete(tmpBuf.FileName);
    tmpBuf.Free;
  end;
  result:=true;
end;

function ChangeTypeInBuf(buf:TBufDataset;FieldName:string;NewDataType:TFieldType;NewSize:integer=0):boolean;
var tmpBuf:TBufDataset;
    pi,ren_id,max_col:integer;
    res:TFieldDef;
    convertProc:pConvertFunc;
begin
  result:=false;
  ren_id:=buf.FieldDefs.IndexOf(FieldName);
  if ren_id<0 then exit;//不存在同名则退出
  FieldTypeChangeMode(buf.FieldDefs[ren_id].DataType,NewDataType,convertProc);
  if convertProc=nil then exit;
  tmpBuf:=TBufDataset.Create(nil);
  tmpBuf.FileName:=buf.FileName+'_bak';
  try
    tmpBuf.FieldDefs.Assign(buf.FieldDefs);
    tmpBuf.CreateDataset;
    max_col:=buf.FieldDefs.Count;
    buf.First;
    while not buf.EOF do
      begin
        tmpBuf.Append;
        for pi:=0 to max_col-1 do tmpBuf.Fields[pi].Assign(buf.Fields[pi]);
        tmpBuf.Post;
        buf.Next;
      end;
    tmpBuf.Close;
    tmpBuf.Open;
    buf.Close;
    buf.Clear;
    for pi:=0 to max_col-1 do
      begin
        {zan}res:=tmpBuf.FieldDefs[pi];
        if pi=ren_id then
          case NewDataType of
            ftString:buf.FieldDefs.Add(FieldName,NewDataType,NewSize);
            else buf.FieldDefs.Add(FieldName,NewDataType);
          end
        else
          buf.FieldDefs.Add({zan}res.Name,{zan}res.DataType,{zan}res.Size);
      end;
    buf.CreateDataset;
    buf.Open;
    tmpBuf.First;
    while not tmpBuf.EOF do
      begin
        buf.Append;
        for pi:=0 to ren_id-1 do buf.Fields[pi].Assign(tmpBuf.Fields[pi]);
        convertProc(tmpBuf.Fields[ren_id],buf.Fields[ren_id]);
        for pi:=ren_id+1 to max_col-1 do buf.Fields[pi].Assign(tmpBuf.Fields[pi]);
        buf.Post;
        tmpBuf.Next;
      end;
  finally
    tmpBuf.Close;
    TRTFP.FileDelete(tmpBuf.FileName);
    tmpBuf.Free;
  end;
  result:=true;
end;




function TRTFP.LocatePID(buf:TDataset;PID:RTFP_ID):boolean;
begin
  result:=false;
  case FDataSetType of
    dstDBF:begin
      if not (buf is TDbf) then raise Exception.Create('数据库文件非DBF格式');
      if not buf.Active then buf.Open;
      with TDbf(buf) do begin
        IndexName:='Id';
        result:=SearchKey(PID,stEqual);
      end;
    end;
    dstBUF:begin
      if not (buf is TBufDataset) then raise Exception.Create('数据库文件非DBF格式');
      if not buf.Active then buf.Open;
      with TBufDataset(buf) do begin
        result:=Locate(_Col_PID_,PID,[]);
      end;
    end;
  end;
  assert(result,'PID未找到。');
end;

function TRTFP.OpenDbf(dbf_name_no_ext:string;Dbf:{TDbf}TDataSet):boolean;
var dbfpath,datfile,runfile,run_dbt,dat_dbt,name_no_ext:string;
begin
  result:=false;
  case FDataSetType of
    dstDBF:begin
      dbfpath:=Self.FFilePath+Self.FRootFolder+'\'+dbf_name_no_ext;
      name_no_ext:=ExtractFileName(dbfpath);
      dbfpath:=ExtractFilePath(dbfpath);
      datfile:=name_no_ext+'.dbf';
      runfile:=name_no_ext+'_run.dbf';
      dat_dbt:=name_no_ext+'.dbt';
      run_dbt:=name_no_ext+'_run.dbt';

      if not FileExists(dbfpath+datfile) then exit;
      TRTFP.FileCopy((dbfpath+datfile),(dbfpath+runfile),false);
      if FileExists(dbfpath+dat_dbt) then TRTFP.FileCopy((dbfpath+dat_dbt),(dbfpath+run_dbt),false);

      with TDbf(Dbf) do begin
        FilePathFull:=dbfpath;
        TableName:=runfile;
        Exclusive:=true;
        try
          Open;
          AddIndex('Id',DbfFieldDefs.Items[1].FieldName,[ixPrimary, ixUnique]);
        except
          exit;
        end;
      end;
    end;
    dstBUF:begin
      with TBufDataset(Dbf) do begin
        FileName:=Self.FFilePath+Self.FRootFolder+'\'+dbf_name_no_ext+'.buf';
        try
          Open;
        except
          exit;
        end;
      end;
    end;
    else raise Exception.Create('无效DataSetType。');
  end;
  result:=true;
end;

function TRTFP.NewDbf(dbf_name_no_ext:string;Dbf:{TDbf}TDataSet):boolean;
var dbfpath,datfile,runfile,run_dbt,dat_dbt,name_no_ext:string;
begin
  result:=false;
  case FDataSetType of
    dstDBF:begin
      dbfpath:=Self.FFilePath+Self.FRootFolder+'\'+dbf_name_no_ext;
      name_no_ext:=ExtractFileName(dbfpath);
      dbfpath:=ExtractFilePath(dbfpath);
      datfile:=name_no_ext+'.dbf';
      runfile:=name_no_ext+'_run.dbf';
      dat_dbt:=name_no_ext+'.dbt';
      run_dbt:=name_no_ext+'_run.dbt';
      with TDbf(Dbf) do begin
        FilePathFull:=dbfpath;
        TableName:=runfile;
        try
          TableLevel:=7;
          Exclusive:=true;
          CreateTable;
          Open;
          AddIndex('Id',DbfFieldDefs.Items[1].FieldName,[ixPrimary, ixUnique]);
        except
          exit;
        end;
      end;
      TRTFP.FileCopy((dbfpath+runfile),(dbfpath+datfile),false);
      if FileExists(dbfpath+run_dbt) then TRTFP.FileCopy((dbfpath+run_dbt),(dbfpath+dat_dbt),false);
    end;
    dstBUF:begin
      //Buf模式不要蹩脚的run备份了
      with TBufDataset(Dbf) do begin
        FileName:=Self.FFilePath+Self.FRootFolder+'\'+dbf_name_no_ext+'.buf';
        try
          //MaxIndexesCount:=10;
          //AddIndex('Id',FieldDefs.Items[1].Name,[ixPrimary, ixUnique]);
          CreateDataset;
          Open;
        except
          exit;
        end;
      end;
    end;
    else raise Exception.Create('无效DataSetType。');
  end;
  result:=true;
end;

function TRTFP.SaveDbf(dbf_name_no_ext:string;Dbf:{TDbf}TDataSet):boolean;
var dbfpath,datfile,runfile,run_dbt,dat_dbt,name_no_ext:string;
    {$ifdef save_xml}
    aBuf:TBufDataset;
    {$endif}
begin
  result:=false;
  case FDataSetType of
    dstDBF:begin
      dbfpath:=Self.FFilePath+Self.FRootFolder+'\'+dbf_name_no_ext;
      name_no_ext:=ExtractFileName(dbfpath);
      dbfpath:=ExtractFilePath(dbfpath);
      datfile:=name_no_ext+'.dbf';
      runfile:=name_no_ext+'_run.dbf';
      dat_dbt:=name_no_ext+'.dbt';
      run_dbt:=name_no_ext+'_run.dbt';
      try
        if Dbf.Active then
          begin
            Dbf.Close;
            Dbf.Open;
          end;
        TRTFP.FileCopy((dbfpath+runfile),(dbfpath+datfile),false);
        if FileExists(dbfpath+run_dbt) then TRTFP.FileCopy((dbfpath+run_dbt),(dbfpath+dat_dbt),false);
        {$ifdef save_xml}
        aBuf:=TBufDataset.Create(nil);
        try
          CopyDbfToBuf(TDbf(Dbf),aBuf);
          aBuf.SaveToFile(GetCurrentPathFull+dbf_name_no_ext+'.xml',dfXML);
        finally
          aBuf.Free;
        end;
        {$endif}
      except
        exit;
      end;
    end;
    dstBUF:begin
      if Dbf.Active then
        begin
          Dbf.Close;
          Dbf.Open;
        end;
      {$ifdef save_xml}
      TBufDataset(Dbf).SaveToFile(GetCurrentPathFull+dbf_name_no_ext+'.xml',dfXML);
      {$endif}
    end;
    else raise Exception.Create('无效DataSetType。');
  end;

  result:=true;
end;

function TRTFP.CloseDbf(dbf_name_no_ext:string;Dbf:{TDbf}TDataSet):boolean;
var dbfpath,{datfile,}runfile,run_dbt,{dat_dbt,}name_no_ext:string;
begin
  result:=false;
  case FDataSetType of
    dstDBF:begin
      dbfpath:=Self.FFilePath+Self.FRootFolder+'\'+dbf_name_no_ext;
      name_no_ext:=ExtractFileName(dbfpath);
      dbfpath:=ExtractFilePath(dbfpath);
      //datfile:=name_no_ext+'.dbf';
      runfile:=name_no_ext+'_run.dbf';
      //dat_dbt:=name_no_ext+'.dbt';
      run_dbt:=name_no_ext+'_run.dbt';
      with TDbf(Dbf) do begin
        try
          if not Active then Open;
          CloseIndexFile('id');
          DeleteIndex('id');
          Close;
          if not TRTFP.FileDelete((dbfpath+runfile)) then exit;
          if FileExists(dbfpath+run_dbt) then begin
            if not TRTFP.FileDelete((dbfpath+run_dbt)) then exit;
          end;
        except
          exit;
        end;
      end;
    end;
    dstBUF:begin
      with TBufDataset(Dbf) do begin
        try
          if not Active then Open;
          Close;
          ClearIndexes;
        except
          exit;
        end;
      end;
    end;
    else raise Exception.Create('无效DataSetType。');
  end;
  result:=true;
end;

function TRTFP.DeleteDbf(dbf_name_no_ext:string;Dbf:{TDbf}TDataSet):boolean;
var dbfpath,datfile,runfile,run_dbt,dat_dbt,name_no_ext:string;
begin

  result:=false;
  case FDataSetType of
    dstDBF:begin
      dbfpath:=Self.FFilePath+Self.FRootFolder+'\'+dbf_name_no_ext;
      name_no_ext:=ExtractFileName(dbfpath);
      dbfpath:=ExtractFilePath(dbfpath);
      datfile:=name_no_ext+'.dbf';
      runfile:=name_no_ext+'_run.dbf';
      dat_dbt:=name_no_ext+'.dbt';
      run_dbt:=name_no_ext+'_run.dbt';
      with TDbf(Dbf) do begin
        try
          if Active then begin
            CloseIndexFile('id');
            DeleteIndex('id');
            Close;
          end;
          TRTFP.FileDelete((dbfpath+runfile));
          TRTFP.FileDelete((dbfpath+datfile));
          TRTFP.FileDelete((dbfpath+run_dbt));
          TRTFP.FileDelete((dbfpath+dat_dbt));
        except
          exit;
        end;
      end;
    end;
    dstBUF:begin
      with TBufDataset(Dbf) do begin
        try
          if Active then begin
            Close;
          end;
          ClearIndexes;
          TRTFP.FileDelete(FileName);
        except
          exit;
        end;
      end;
    end;
    else raise Exception.Create('无效DataSetType。');
  end;

  result:=true;

end;

function TRTFP.PackDbf(Dbf:{TDbf}TDataSet):boolean;
begin
  case FDataSetType of
    dstDBF:begin
      with TDbf(Dbf) do begin
        if not Active then Open;
        PackTable;
        RegenerateIndexes;
        Close;
        Open;
      end;
    end;
    dstBUF:;//BufDataset需要pack吗？
    else raise Exception.Create('无效DataSetType。');
  end;
end;





