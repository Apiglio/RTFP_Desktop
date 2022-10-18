//计数器与状态返回

function TRTFP.GetPaperCount:integer;
var acc:integer;
begin
  acc:=0;
  with FPaperDB do begin
    if not Active then Open;
    First;
    while not EOF do
      begin
        inc(acc);
        Next;
      end;
    result:=acc;
  end;
end;

function TRTFP.GetBackupPaperCount:integer;
begin
  result:=0;
  with FPaperDB do begin
    if not Active then Open;
    First;
    while not EOF do begin
      if FieldByName(_Col_Paper_Is_Backup_).AsBoolean then inc(result);
      Next;
    end;
  end;
end;

function TRTFP.GetExternPaperCount:integer;
begin
  result:=0;
  with FPaperDB do begin
    if not Active then Open;
    First;
    while not EOF do begin
      if FieldByName(_Col_Paper_Folder_).AsString='extern' then inc(result);
      Next;
    end;
  end;
end;

function TRTFP.GetWeblnkPaperCount:integer;
begin
  result:=0;
  with FPaperDB do begin
    if not Active then Open;
    First;
    while not EOF do begin
      if FieldByName(_Col_Paper_Folder_).AsString='weblnk' then inc(result);
      Next;
    end;
  end;
end;

function TRTFP.GetMainGridCount:integer;
begin
  result:=0;
  if not PaperDS.Active then exit;
  result:=PaperDS.RecordCount;
end;



