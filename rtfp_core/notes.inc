//这部分源自最初的想法，是一种超文本的储存方式，但是现在是否还有意义有待商榷

function TRTFP.NewNoteID:RTFP_ID;
var num:dword;
begin
  FNotesDB.Last;
  if FNotesDB.BOF then num:=0
  else num:=TRTFP.IDToNum((FNotesDB.FieldByName(_Col_NID_).AsString));
  inc(num);
  result:=TRTFP.NumToID(num);
end;

procedure TRTFP.MakeSureNoteID(PID:RTFP_ID);
begin

end;

function TRTFP.AddNote(fullfilename:string):RTFP_ID;//新增一个注解到工程
begin

end;

procedure TRTFP.DeleteNote(NID:RTFP_ID);//移除指定NID的注解
begin

end;
