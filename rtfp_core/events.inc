//事件定义与禁用事件的方法

function TRTFP.GetIsUpdating:boolean;
begin
  result:=FUpdatingLevel<>0;
end;
procedure TRTFP.BeginUpdate;
begin
  //FIsUpdating:=true;
  inc(FUpdatingLevel);
end;

procedure TRTFP.EndUpdate;
begin
  //IsUpdating:=false;
  dec(FUpdatingLevel);
end;

procedure TRTFP.Change;
begin
  if (not FIsChanged) and (FOnFirstEdit<>nil) then Self.FOnFirstEdit(Self);
  if (not IsUpdating) and (FOnChange<>nil) then FOnChange(Self);
  Self.FIsChanged:=true;
end;

procedure TRTFP.DataChange(PID:RTFP_ID);
begin
  if not IsUpdating then
    begin
      if FOnDataChange<>nil then FOnDataChange(Self);
      UpdateCurrentRec(PID);
    end;
  Change;
end;

procedure TRTFP.FieldChange;
begin
  if not IsUpdating then
    begin
      if FOnFieldChange<>nil then FOnFieldChange(Self);
      RebuildMainGrid;
    end;
  {Data}Change;
end;

procedure TRTFP.RecordChange;
begin
  if not IsUpdating then
    begin
      if FOnRecordChange<>nil then FOnRecordChange(Self);
      RebuildMainGrid;
    end;
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
  if not not_change_at_the_beginning then {Data}Change;
end;

procedure TRTFP.ClassChange(not_change_at_the_beginning:boolean=false);
begin
  if (not IsUpdating) and (FOnClassChange<>nil) then FOnClassChange(Self);
  if not not_change_at_the_beginning then Change;
end;

procedure TRTFP.UsersChange;
begin
  if (not IsUpdating) and (FOnUsersChange<>nil) then FOnUsersChange(Self);
  Change;
end;

procedure TRTFP.FormatListChange;
begin
  if (not IsUpdating) and (FOnFormatListChange<>nil) then FOnFormatListChange(Self);
  Change;
end;



