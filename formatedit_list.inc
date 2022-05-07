//formatedit列表

function TRTFP.AddFormatDefault:boolean;
var str:TStringList;
    index:integer;
begin
  result:=false;
  if not FFormatList.Find('default.fmt',index) then FFormatList.Add('default.fmt');
  str:=TStringList.Create;
  try
    str.Add('edit '+_Attrs_Basic_+','+_Col_basic_Title_+',标题,0,70,0,2,editable');
    str.Add('edit '+_Attrs_Basic_+','+_Col_basic_Author_+',作者,70,70,0,1,editable');
    str.Add('edit '+_Attrs_Basic_+','+_Col_basic_Year_+',年份,70,70,1,2,editable');
    str.Add('edit '+_Attrs_Basic_+','+_Col_basic_Keyword_+',关键词,140,70,0,2,editable');
    str.Add('memo '+_Attrs_Basic_+','+_Col_basic_Summary_+',摘要,0,210,2,4,editable');
    str.Add('edit '+_Attrs_Basic_+','+_Col_basic_Source_+',来源,210,70,0,1,editable');
    str.Add('edit '+_Attrs_Notes_+','+_Col_notes_Rank_+',评分,210,70,1,2,editable');
    str.Add('check '+_Attrs_Class_+','+_Col_class_Is_Read_+',是否已读,210,70,2,3,editable');
    str.Add('edit '+_Attrs_Class_+','+_Col_class_DefaultCl_+',分类,210,70,3,4,uneditable');
    str.Add('memo '+_Attrs_Notes_+','+_Col_notes_Comment_+',笔记,280,280,0,4,editable');
    str.SaveToFile(Self.FFilePath+Self.FRootFolder+'\format\default.fmt');
  finally
    str.Free;
  end;
  result:=true;
end;
function TRTFP.AddFormatEditNull(filename:string):boolean;
var str:TStringList;
    index:integer;
begin
  result:=false;
  if not FFormatList.Find(filename,index) then FFormatList.Add(filename);
  str:=TStringList.Create;
  try
    str.SaveToFile(Self.FFilePath+Self.FRootFolder+'\format\'+filename);
  finally
    str.Free;
  end;
  FormatListChange;
  result:=true;
end;
function TRTFP.RenFormatEdit(filename,newname:string):boolean;
var index:integer;
    f:file of byte;
    old_f,new_f:string;
begin
  result:=false;
  if not FFormatList.Find(filename,index) then exit;
  old_f:=FFilePath+FRootFolder+'\format\';
  new_f:=old_f+newname;
  old_f:=old_f+filename;
  TRTFP.FileRename(old_f,new_f);
  FFormatList[index]:=newname;
  FormatListChange;
  result:=true;
end;
function TRTFP.DelFormatEdit(filename:string):boolean;
var index:integer;
begin
  result:=false;
  if not FFormatList.Find(filename,index) then exit;
  TRTFP.FileDelete(FFilePath+FRootFolder+'\format\'+filename);
  FFormatList.Delete(index);
  FormatListChange;
  result:=true;
end;
procedure TRTFP.LoadFormatEditList;
var tmpFileList:TRTFP_FileList;
    stmp:TCollectionItem;
    clip:string;
    poss:integer;
begin
  tmpFileList:=TRTFP_FileList.Create(nil,FFilePath+FRootFolder+'\format\');
  tmpFileList.RunDir;
  FFormatList.Clear;
  for stmp in tmpFileList do
    begin
      clip:=(stmp as TRTFP_FileItem).Name;
      poss:=pos('\',clip);
      while poss>0 do
        begin
          delete(clip,1,poss);
          poss:=pos('\',clip);
        end;
      FFormatList.Add(clip);
    end;
end;

procedure TRTFP.LoadFormatList;
var str:TStringList;
    tmp:integer;
    index:integer;
begin
  LoadFormatEditList;
  if not FFormatList.Find('default.fmt',index) then AddFormatDefault;
  //FFormatList.SaveToFile(Self.FFilePath+Self.FRootFolder+'\format.dat');
  FormatListChange;
end;

function TRTFP.SaveFormatList:boolean;
begin
  FFormatList.SaveToFile(Self.FFilePath+Self.FRootFolder+'\format.dat');
  result:=true;
end;

function TRTFP.CloseFormatList:boolean;
begin
  FFormatList.Clear;
  result:=true;
end;
