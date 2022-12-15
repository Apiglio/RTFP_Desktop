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
  if not FPaperDS.Active then exit;
  result:=FPaperDS.RecordCount;
end;


function export_con_string(boo:boolean):string;inline;
begin
  if boo then result:='True' else result:='False';
end;

function TRTFP.ExportDSToCSVOrTSV(sep:char):string;
var bm:TBookMark;
    idx,len,idx_f,len_f:integer;
    tmpAF:TAttrsField;
begin
  result:='';
  if not FPaperDS.Active then exit;
  bm:=FPaperDS.Bookmark;
  len_f:=FPaperDSFieldDefs.Count;
  len:=FPaperDS.RecordCount;
  //标题
  for idx_f:=0 to len_f-1 do begin
    tmpAF:=TAttrsField(FPaperDSFieldDefs.Items[idx_f]);
    if tmpAF=nil then continue;
    case tmpAF.FieldDef.DataType of
      ftString,ftMemo,ftWideString,ftFixedWideChar,ftWideMemo,
      //ftFmtMemo,ftFixedChar,
      //ftBlob,
      ftBoolean,
      ftFloat,
      ftInteger,ftLargeint,ftSmallint,ftWord,
      ftDateTime,ftDate,ftTime:
        result:=result+tmpAF.FieldDef.Name+sep;
    end;
  end;
  delete(result,length(result),1);
  result:=result+#13#10;
  //内容
  FPaperDS.First;
  for idx:=0 to len-1 do begin
    FPaperDS.RecNo:=idx;
    for idx_f:=0 to len_f-1 do begin
      tmpAF:=TAttrsField(FPaperDSFieldDefs.Items[idx_f]);
      if tmpAF=nil then continue;
      case tmpAF.FieldDef.DataType of
        ftString,ftMemo,ftWideString,ftFixedWideChar,ftWideMemo:
          result:=result+FPaperDS.Fields[idx_f].AsString+sep;
        //ftFmtMemo,ftFixedChar,
        //ftBlob,
        ftBoolean:
          result:=result+export_con_string(FPaperDS.Fields[idx_f].AsBoolean)+sep;
        ftFloat:
          result:=result+FloatToStr(FPaperDS.Fields[idx_f].AsFloat)+sep;
        ftInteger,ftLargeint,ftSmallint,ftWord:
          result:=result+IntToStr(FPaperDS.Fields[idx_f].AsLargeInt)+sep;
        ftDateTime,ftDate,ftTime:
          result:=result+DateTimeToStr(FPaperDS.Fields[idx_f].AsDateTime)+sep;
      end;
    end;
    delete(result,length(result),1);
    result:=result+#13#10;
  end;
  if FPaperDS.BookmarkValid(bm) then FPaperDS.GotoBookmark(bm);
end;

function TRTFP.ExportDSToRubyOrPython(sep:string):string;
var bm:TBookMark;
    idx,len,idx_f,len_f:integer;
    tmpAF:TAttrsField;
begin
  result:='[';
  if not FPaperDS.Active then exit;
  bm:=FPaperDS.Bookmark;
  len_f:=FPaperDSFieldDefs.Count;
  len:=FPaperDS.RecordCount;
  FPaperDS.First;
  for idx:=0 to len-1 do begin
    FPaperDS.RecNo:=idx;
    result:=result+'{';
    for idx_f:=0 to len_f-1 do begin
      tmpAF:=TAttrsField(FPaperDSFieldDefs.Items[idx_f]);
      if tmpAF=nil then continue;
      case tmpAF.FieldDef.DataType of
        ftString,ftMemo,ftWideString,ftFixedWideChar,ftWideMemo:
          result:=result+'"'+tmpAF.FieldName+'"'+sep+'"'+FPaperDS.Fields[idx_f].AsString+'",';
        //ftFmtMemo,ftFixedChar,
        //ftBlob,
        ftBoolean:
          result:=result+'"'+tmpAF.FieldName+'"'+sep+export_con_string(FPaperDS.Fields[idx_f].AsBoolean)+',';
        ftFloat:
          result:=result+'"'+tmpAF.FieldName+'"'+sep+FloatToStr(FPaperDS.Fields[idx_f].AsFloat)+',';
        ftInteger,ftLargeint,ftSmallint,ftWord:
          result:=result+'"'+tmpAF.FieldName+'"'+sep+IntToStr(FPaperDS.Fields[idx_f].AsLargeInt)+',';
        ftDateTime,ftDate,ftTime:
          result:=result+'"'+tmpAF.FieldName+'"'+sep+'"'+DateTimeToStr(FPaperDS.Fields[idx_f].AsDateTime)+'",';//可以考虑改成Time.mktime()
      end;
    end;
    delete(result,length(result),1);
    result:=result+'},';
  end;
  delete(result,length(result),1);
  result:=result+']';
  if FPaperDS.BookmarkValid(bm) then FPaperDS.GotoBookmark(bm);
end;




