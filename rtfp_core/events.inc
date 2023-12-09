//事件定义与禁用事件的方法

function TRTFP.GetIsUpdating:boolean;
begin
  result:=FUpdatingLevel<>0;
end;
procedure TRTFP.BeginUpdate;
begin
  inc(FUpdatingLevel);
end;

procedure TRTFP.EndUpdate;
begin
  if FUpdatingLevel>0 then dec(FUpdatingLevel);
end;

procedure TRTFP.Change;
var first_edit:boolean;
begin
  first_edit:=(not FIsChanged) and (FOnFirstEdit<>nil);//把FirstEdit的操作放在Change之后
  if (not IsUpdating) and (FOnChange<>nil) then FOnChange(Self);
  if first_edit then Self.FOnFirstEdit(Self);
  Self.FIsChanged:=true;
  LogLine('Change');
end;

procedure TRTFP.TagChange(key,value:string);
begin
  if not IsUpdating then
    begin
      if FOnTagChange<>nil then FOnTagChange(Self,key,value);
    end;
  LogLine('TagChange');
  Change;
end;

procedure TRTFP.DataChange(PID:RTFP_ID);
begin
  if not IsUpdating then
    begin
      if FOnDataChange<>nil then FOnDataChange(Self);
      UpdateCurrentRec(PID);
    end;
  LogLine('DataChange '+PID);
  Change;
end;

procedure TRTFP.FieldChange;
begin
  if not IsUpdating then
    begin
      if FOnFieldChange<>nil then FOnFieldChange(Self);
      RebuildMainGrid;
    end;
  LogLine('FieldChange');
  {Data}Change;
end;

procedure TRTFP.RecordChange;
begin
  if not IsUpdating then
    begin
      if FOnRecordChange<>nil then FOnRecordChange(Self);
      RebuildMainGrid;
    end;
  LogLine('RecordChange');
  {Data}Change;
end;

procedure TRTFP.FieldAndRecordChange(not_change_at_the_beginning:boolean=false);
begin
  if not IsUpdating then
    begin
      if FOnFieldChange<>nil then FOnFieldChange(Self);
      if FOnRecordChange<>nil then FOnRecordChange(Self);
      RebuildMainGrid;
    end;
  if not_change_at_the_beginning then LogLine('FieldAndRecordChange true') else LogLine('FieldAndRecordChange false');
  if not not_change_at_the_beginning then {Data}Change;
end;

procedure TRTFP.ClassIncludeChange(PID:RTFP_ID);
begin
  if (not IsUpdating) and (FOnClassIncludeChange<>nil) then FOnClassIncludeChange(Self);
  LogLine('ClassIncludeChange '+PID);
  DataChange(PID);
end;

procedure TRTFP.ClassChange(not_change_at_the_beginning:boolean=false);
begin
  if (not IsUpdating) and (FOnClassChange<>nil) then FOnClassChange(Self);
  if not_change_at_the_beginning then LogLine('ClassChange true') else LogLine('ClassChange false');
  if not not_change_at_the_beginning then Change;
end;

procedure TRTFP.UsersChange;
begin
  if (not IsUpdating) and (FOnUsersChange<>nil) then FOnUsersChange(Self);
  LogLine('UsersChange');
  Change;
end;

procedure TRTFP.FormatListChange(rename:string='default.fmt');
begin
  if (not IsUpdating) and (FOnFormatListChange<>nil) then FOnFormatListChange(Self,rename);
  LogLine('FormatListChange '+rename);
  Change;
end;

procedure TRTFP.FormatEditChange(fe_new,fe_old:string);
begin
  if (not IsUpdating) and (FOnFormatEditChange<>nil) then FOnFormatEditChange(Self,fe_new,fe_old);
  LogLine('FormatEditChange '+fe_new+', '+fe_old);
  Change;
end;
