//这部分源自最初的想法，是一种图片的储存方式，但是现在由于有图像字段，是否还有存在必要有待商榷

function TRTFP.NewImageID:RTFP_ID;
var num:dword;
begin
  FImageDB.Last;
  if FImageDB.BOF then num:=0
  else num:=TRTFP.IDToNum((FImageDB.FieldByName(_Col_IID_).AsString));
  inc(num);
  result:=TRTFP.NumToID(num);
end;

function TRTFP.AddImage(fullfilename:string):RTFP_ID;//新增一个图片到工程
begin

end;

procedure TRTFP.DeleteImage(IID:RTFP_ID);//移除指定IID的图片
begin

end;
