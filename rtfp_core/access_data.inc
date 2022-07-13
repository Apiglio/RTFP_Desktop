function TRTFP.GetFieldType(attrNa,fieldNa:string):TFieldType;
var tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
begin
  result:=ftUnknown;
  tmpAG:=FFieldList.FindItemByName(attrNa);
  if tmpAG=nil then exit;
  tmpAF:=tmpAG.FieldList.FindItemByName(fieldNa);
  if tmpAF=nil then exit;
  result:=tmpAF.FieldDef.DataType;
end;

function TRTFP.ReadBasicString(AName:string;PID:RTFP_ID;fail_if_no_pid:boolean=false):string;
begin
  if not FPaperDB.Active then FPaperDB.Open;
  if not LocatePID(FPaperDB,PID) then begin
    if fail_if_no_pid then raise AttrsNoPIDErr('找不到PID['+PID+']！');
    exit;
  end;
  result:=FPaperDB.FieldByName(AName).AsString;
end;

procedure TRTFP.EditBasicString(AName:string;PID:RTFP_ID;value:string;fail_if_no_pid:boolean=false);
begin
  if not FPaperDB.Active then FPaperDB.Open;
  if not LocatePID(FPaperDB,PID) then begin
    if fail_if_no_pid then raise AttrsNoPIDErr('找不到PID['+PID+']！');
    exit;
  end;
  FPaperDB.Edit;
  FPaperDB.FieldByName(AName).AsString:=value;
  FPaperDB.Post;
  DataChange(PID);
end;

function TRTFP.ReadBasicBool(AName:string;PID:RTFP_ID;fail_if_no_pid:boolean=false):boolean;
begin
  if not FPaperDB.Active then FPaperDB.Open;
  if not LocatePID(FPaperDB,PID) then begin
    if fail_if_no_pid then raise AttrsNoPIDErr('找不到PID['+PID+']！');
    exit;
  end;
  result:=FPaperDB.FieldByName(AName).AsBoolean;
end;

procedure TRTFP.EditBasicBool(AName:string;PID:RTFP_ID;value:boolean;fail_if_no_pid:boolean=false);
begin
  if not FPaperDB.Active then FPaperDB.Open;
  if not LocatePID(FPaperDB,PID) then begin
    if fail_if_no_pid then raise AttrsNoPIDErr('找不到PID['+PID+']！');
    exit;
  end;
  FPaperDB.Edit;
  FPaperDB.FieldByName(AName).AsBoolean:=value;
  FPaperDB.Post;
  DataChange(PID);
end;

function TRTFP.ReadBasicInteger(AName:string;PID:RTFP_ID;fail_if_no_pid:boolean=false):int64;
begin
  if not FPaperDB.Active then FPaperDB.Open;
  if not LocatePID(FPaperDB,PID) then begin
    if fail_if_no_pid then raise AttrsNoPIDErr('找不到PID['+PID+']！');
    exit;
  end;
  result:=FPaperDB.FieldByName(AName).AsInteger;
end;

procedure TRTFP.EditBasicInteger(AName:string;PID:RTFP_ID;value:int64;fail_if_no_pid:boolean=false);
begin
  if not FPaperDB.Active then FPaperDB.Open;
  if not LocatePID(FPaperDB,PID) then begin
    if fail_if_no_pid then raise AttrsNoPIDErr('找不到PID['+PID+']！');
    exit;
  end;
  FPaperDB.Edit;
  FPaperDB.FieldByName(AName).AsInteger:=value;
  FPaperDB.Post;
  DataChange(PID);
end;

function TRTFP.ReadFieldAsString(AName,AAttrsName:string;PID:RTFP_ID;AE:TAttrExtend):string;
var tmpField:TField;
begin
  result:='';
  if AAttrsName='' then begin
    if FPaperDB.FieldDefs.Find(AName)=nil then exit;
    result:=ReadBasicString(AName,PID);
    exit;
  end;
  if GetFieldType(AAttrsName,AName)=ftUnknown then
    begin
      if aeFailIfNoField in AE then
        raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
      else exit;
    end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    result:=tmpField.AsString
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

function TRTFP.ReadFieldAsInteger(AName,AAttrsName:string;PID:RTFP_ID;AE:TAttrExtend):int64;
var tmpField:TField;
begin
  result:=0;
  if AAttrsName='' then begin
    if FPaperDB.FieldDefs.Find(AName)=nil then begin
      if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！');
      exit;
    end;
    result:=ReadBasicInteger(AName,PID,aeFailIfNoPID in AE);
    exit;
  end;
  if GetFieldType(AAttrsName,AName)=ftUnknown then
    begin
      if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
      else exit;
    end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    result:=tmpField.AsLargeInt
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

function TRTFP.ReadFieldAsBoolean(AName,AAttrsName:string;PID:RTFP_ID;AE:TAttrExtend):boolean;
var tmpField:TField;
begin
  result:=false;
  if AAttrsName='' then begin
    if FPaperDB.FieldDefs.Find(AName)=nil then begin
      if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！');
      exit;
    end;
    result:=ReadBasicBool(AName,PID,aeFailIfNoPID in AE);
    exit;
  end;
  if GetFieldType(AAttrsName,AName)=ftUnknown then
    begin
      if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
      else exit;
    end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    result:=tmpField.AsBoolean
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

function TRTFP.ReadFieldAsDateTime(AName,AAttrsName:string;PID:RTFP_ID;AE:TAttrExtend):TDateTime;
var tmpField:TField;
begin
  result:=0;
  //基本属性没有日期格式
  if GetFieldType(AAttrsName,AName)=ftUnknown then
    begin
      if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
      else exit;
    end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    result:=tmpField.AsDateTime
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

function TRTFP.ReadFieldAsDouble(AName,AAttrsName:string;PID:RTFP_ID;AE:TAttrExtend):double;
var tmpField:TField;
begin
  result:=0;
  //基本属性没有浮点型格式
  if GetFieldType(AAttrsName,AName)=ftUnknown then
    begin
      if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
      else exit;
    end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    result:=tmpField.AsFloat
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

procedure TRTFP.EditFieldAsString(AName,AAttrsName:string;PID:RTFP_ID;value:string;AE:TAttrExtend);
var tmpAG:TAttrsGroup;
    tmpField:TField;
begin
  if AAttrsName='' then begin
    if FPaperDB.FieldDefs.Find(AName)=nil then begin
      if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！');
      exit;
    end;
    EditBasicString(AName,PID,value,aeFailIfNoPID in AE);
    exit;
  end;
  case GetFieldType(AAttrsName,AName) of
    ftUnknown:
      begin
        if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
        else begin
          if aeCreateIfNoField in AE then
            begin
              AddField(AName,AAttrsName,ftString{,255});
            end
          else exit;
        end;
      end;
    ftString:;
    else
      begin
        if aeFailIfTypeDismatch in AE then raise AttrsTypeDismatchErr.Create('字段'+AName+'.'+AAttrsName+'类型错误！')
        else begin
          if aeForceEditIfTypeDismatch in AE then
          else exit;
        end;
      end;
  end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    begin
      tmpAG:=FindAttrs(AAttrsName);
      tmpAG.Dbf.Edit;
      tmpField.AsString:=value;
      tmpAG.Dbf.Post;
      tmpAG.Modified:=true;
      DataChange(PID);
    end
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

procedure TRTFP.EditFieldAsInteger(AName,AAttrsName:string;PID:RTFP_ID;value:int64;AE:TAttrExtend);
var tmpAG:TAttrsGroup;
    tmpField:TField;
begin
  if AAttrsName='' then begin
    if FPaperDB.FieldDefs.Find(AName)=nil then begin
      if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！');
      exit;
    end;
    EditBasicInteger(AName,PID,value,aeFailIfNoPID in AE);
    exit;
  end;
  case GetFieldType(AAttrsName,AName) of
    ftUnknown:
      begin
        if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
        else begin
          if aeCreateIfNoField in AE then
            begin
              AddField(AName,AAttrsName,ftLargeint{,0});
            end
          else exit;
        end;
      end;
    ftInteger,ftLargeint,ftSmallint:;
    else
      begin
        if aeFailIfTypeDismatch in AE then raise AttrsTypeDismatchErr.Create('字段'+AName+'.'+AAttrsName+'类型错误！')
        else begin
          if aeForceEditIfTypeDismatch in AE then
          else exit;
        end;
      end;
  end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    begin
      tmpAG:=FindAttrs(AAttrsName);
      tmpAG.Dbf.Edit;
      tmpField.AsInteger:=value;
      tmpAG.Dbf.Post;
      tmpAG.Modified:=true;
      DataChange(PID);
    end
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

procedure TRTFP.EditFieldAsBoolean(AName,AAttrsName:string;PID:RTFP_ID;value:boolean;AE:TAttrExtend);
var tmpAG:TAttrsGroup;
    tmpField:TField;
begin
  if AAttrsName='' then begin
    if FPaperDB.FieldDefs.Find(AName)=nil then begin
      if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！');
      exit;
    end;
    EditBasicBool(AName,PID,value,aeFailIfNoPID in AE);
    exit;
  end;
  case GetFieldType(AAttrsName,AName) of
    ftUnknown:
      begin
        if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
        else begin
          if aeCreateIfNoField in AE then
            begin
              AddField(AName,AAttrsName,ftBoolean{,0});
            end
          else exit;
        end;
      end;
    ftBoolean:;
    else
      begin
        if aeFailIfTypeDismatch in AE then raise AttrsTypeDismatchErr.Create('字段'+AName+'.'+AAttrsName+'类型错误！')
        else begin
          if aeForceEditIfTypeDismatch in AE then
          else exit;
        end;
      end;
  end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    begin
      tmpAG:=FindAttrs(AAttrsName);
      tmpAG.Dbf.Edit;
      tmpField.AsBoolean:=value;
      tmpAG.Dbf.Post;
      tmpAG.Modified:=true;
      DataChange(PID);
    end
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

procedure TRTFP.EditFieldAsDateTime(AName,AAttrsName:string;PID:RTFP_ID;value:TDateTime;AE:TAttrExtend);
var tmpAG:TAttrsGroup;
    tmpField:TField;
begin
  //基本属性没有日期格式
  case GetFieldType(AAttrsName,AName) of
    ftUnknown:
      begin
        if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
        else begin
          if aeCreateIfNoField in AE then
            begin
              AddField(AName,AAttrsName,ftDateTime{,0});
            end
          else exit;
        end;
      end;
    ftDate,ftDateTime,ftTime:;
    else
      begin
        if aeFailIfTypeDismatch in AE then raise AttrsTypeDismatchErr.Create('字段'+AName+'.'+AAttrsName+'类型错误！')
        else begin
          if aeForceEditIfTypeDismatch in AE then
          else exit;
        end;
      end;
  end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    begin
      tmpAG:=FindAttrs(AAttrsName);
      tmpAG.Dbf.Edit;
      tmpField.AsDateTime:=value;
      tmpAG.Dbf.Post;
      tmpAG.Modified:=true;
      DataChange(PID);
    end
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

procedure TRTFP.EditFieldAsDouble(AName,AAttrsName:string;PID:RTFP_ID;value:double;AE:TAttrExtend);
var tmpAG:TAttrsGroup;
    tmpField:TField;
begin
  //基本属性没有浮点型格式
  case GetFieldType(AAttrsName,AName) of
    ftUnknown:
      begin
        if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
        else begin
          if aeCreateIfNoField in AE then
            begin
              AddField(AName,AAttrsName,ftFloat{,0});
            end
          else exit;
        end;
      end;
    ftFloat:;
    else
      begin
        if aeFailIfTypeDismatch in AE then raise AttrsTypeDismatchErr.Create('字段'+AName+'.'+AAttrsName+'类型错误！')
        else begin
          if aeForceEditIfTypeDismatch in AE then
          else exit;
        end;
      end;
  end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    begin
      tmpAG:=FindAttrs(AAttrsName);
      tmpAG.Dbf.Edit;
      tmpField.AsFloat:=value;
      tmpAG.Dbf.Post;
      tmpAG.Modified:=true;
      DataChange(PID);
    end
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

procedure TRTFP.ReadFieldAsMemo(AName,AAttrsName:string;PID:RTFP_ID;buf:TStrings;AE:TAttrExtend);
var tmpField:TField;
begin
  //基本属性没有memo格式
  if buf=nil then exit;
  buf.Clear;
  if GetFieldType(AAttrsName,AName)=ftUnknown then
    begin
      if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
      else exit;
    end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then begin
    buf.Text:=tmpField.AsString;
  end else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

procedure TRTFP.EditFieldAsMemo(AName,AAttrsName:string;PID:RTFP_ID;buf:TStrings;AE:TAttrExtend);
var tmpAG:TAttrsGroup;
    tmpField:TField;
begin
  //基本属性没有memo格式
  if buf=nil then exit;
  case GetFieldType(AAttrsName,AName) of
    ftUnknown:
      begin
        if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
        else begin
          if aeCreateIfNoField in AE then
            begin
              AddField(AName,AAttrsName,ftMemo{,0});
            end
          else exit;
        end;
      end;
    ftMemo:;
    else
      begin
        if aeFailIfTypeDismatch in AE then raise AttrsTypeDismatchErr.Create('字段'+AName+'.'+AAttrsName+'类型错误！')
        else begin
          if aeForceEditIfTypeDismatch in AE then
          else exit;
        end;
      end;
  end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    begin
      tmpAG:=FindAttrs(AAttrsName);
      tmpAG.Dbf.Edit;
      tmpField.AsString:=buf.Text;
      tmpAG.Dbf.Post;
      tmpAG.Modified:=true;
      DataChange(PID);
    end
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

procedure TRTFP.ReadFieldAsBitmap(AName,AAttrsName:string;PID:RTFP_ID;buf:Graphics.TBitMap;AE:TAttrExtend);
var tmpField:TField;
    str:TMemoryStream;
begin
  if buf=nil then exit;
  //buf.Clear;
  if GetFieldType(AAttrsName,AName)=ftUnknown then
    begin
      if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
      else exit;
    end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then begin
    str:=TMemoryStream.Create;
    try
      //TBlobField(tmpField).SaveToFile('img_convert_tmp.bmp');
      //buf.Picture.Bitmap.LoadFromFile('img_convert_tmp.bmp');
      TBlobField(tmpField).SaveToStream(str);
      str.Position:=0;
      buf.LoadFromStream(str);
    finally
      str.Free;
    end;
  end else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

procedure TRTFP.EditFieldAsBitmap(AName,AAttrsName:string;PID:RTFP_ID;buf:Graphics.TBitMap;AE:TAttrExtend);
var tmpAG:TAttrsGroup;
    tmpField:TField;
    str:TMemoryStream;
begin
  if buf=nil then exit;
  case GetFieldType(AAttrsName,AName) of
    ftUnknown:
      begin
        if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
        else begin
          if aeCreateIfNoField in AE then
            begin
              AddField(AName,AAttrsName,ftMemo{,0});
            end
          else exit;
        end;
      end;
    ftBlob:;
    else
      begin
        if aeFailIfTypeDismatch in AE then raise AttrsTypeDismatchErr.Create('字段'+AName+'.'+AAttrsName+'类型错误！')
        else begin
          //if aeForceEditIfTypeDismatch in AE then else //不存在强制编辑可能性
            exit;
        end;
      end;
  end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    begin
      tmpAG:=FindAttrs(AAttrsName);
      tmpAG.Dbf.Edit;
      str:=TMemoryStream.Create;
      try
        //buf.Picture.Bitmap.SaveToFile('img_convert_tmp.bmp');
        //TBlobField(tmpField).LoadFromFile('img_convert_tmp.bmp');
        buf.SaveToStream(str);
        str.Position:=0;
        TBlobField(tmpField).LoadFromStream(str);
      finally
        str.Free;
      end;
      tmpAG.Dbf.Post;
      tmpAG.Modified:=true;
      DataChange(PID);
    end
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;                                          
