//formatedit列表

function TRTFP.AddFormatDefault:boolean;
var str:TStringList;
    index:integer;
begin
  result:=false;
  if not FFormatList.Find('default.fmt',index) then FFormatList.Add('default.fmt');
  str:=TStringList.Create;
  try
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_Title_+'","标题",0,70,0,2,"editable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_Author_+'","作者",70,70,0,1,"editable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_Year_+'","年份",70,70,1,2,"editable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_Keyword_+'","关键词",140,70,0,2,"editable"');
    str.Add('memo "'+_Attrs_Basic_+'","'+_Col_basic_Summary_+'","摘要",0,210,2,4,"editable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_Source_+'","来源",210,70,0,1,"editable"');
    str.Add('edit "'+_Attrs_Notes_+'","'+_Col_notes_Rank_+'","评分",210,70,1,2,"editable"');
    str.Add('check "'+_Attrs_Class_+'","'+_Col_class_Is_Read_+'","是否已读",210,70,2,3,"editable"');
    str.Add('edit "'+_Attrs_Class_+'","'+_Col_class_DefaultCl_+'","分类",210,70,3,4,"uneditable"');
    str.Add('memo "'+_Attrs_Notes_+'","'+_Col_notes_Comment_+'","笔记",280,280,0,4,"editable"');
    str.SaveToFile(Self.FFilePath+Self.FRootFolder+'\format\default.fmt');
  finally
    str.Free;
  end;
  result:=true;
end;

function TRTFP.AddFormatDefault_All:boolean;
var str:TStringList;
    index:integer;
begin
  result:=false;
  if not FFormatList.Find('all.fmt',index) then FFormatList.Add('all.fmt');
  str:=TStringList.Create;
  try
    str.Add('edit "'+_Attrs_Metas_+'","'+_Col_metas_Title_+'","meta.Title",0,70,"L","LM","uneditable"');
    str.Add('edit "'+_Attrs_Metas_+'","'+_Col_metas_Authors_+'","meta.Authors",0,70,"LM","ML","uneditable"');
    str.Add('edit "'+_Attrs_Metas_+'","'+_Col_metas_Subject_+'","meta.Subject",0,70,"ML","M","uneditable"');
    str.Add('edit "'+_Attrs_Metas_+'","'+_Col_metas_KeyWord_+'","meta.Keywords",0,70,"M","MR","uneditable"');
    str.Add('edit "'+_Attrs_Metas_+'","'+_Col_metas_Creator_+'","meta.Creator",0,70,"MR","RM","uneditable"');
    str.Add('edit "'+_Attrs_Metas_+'","'+_Col_metas_Produce_+'","meta.Producer",0,70,"RM","R","uneditable"');
    str.Add('edit "'+_Attrs_Metas_+'","'+_Col_metas_CreDate_+'","meta.CreateTime",70,70,"L","LM","uneditable"');
    str.Add('edit "'+_Attrs_Metas_+'","'+_Col_metas_ModDate_+'","meta.ModifyTime",70,70,"LM","ML","uneditable"');
    str.Add('edit "'+_Attrs_Metas_+'","'+_Col_metas_Trapped_+'","meta.Trapped",70,70,"ML","M","uneditable"');

    str.Add('check "'+_Attrs_Class_+'","'+_Col_class_Is_Read_+'","是否已读",140,70,"L","LM","uneditable"');
    str.Add('list "'+_Attrs_Class_+'","'+_Col_class_DefaultCl_+'","分类",140,70,"LM","ML","uneditable"');

    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_RefType_+'","类型",210,70,"L","LM","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_Title_+'","标题",210,70,"LM","M","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_Author_+'","作者",210,70,"M","MR","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_Corresp_+'","通讯作者",210,70,"MR","RM","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_Source_+'","来源",210,70,"RM","R","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_PubTime_+'","发表时间",280,70,"L","LM","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_Keyword_+'","关键词",280,70,"LM","ML","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_Summary_+'","摘要",280,140,"M","R","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_Organ_+'","单位",280,70,"ML","M","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_Year_+'","年份",350,70,"L","LM","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_Volume_+'","卷",350,70,"LM","ML","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_Issue_+'","期",350,70,"ML","M","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_PageCount_+'","页数",350,70,"M","MR","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_Page_+'","页码",350,70,"MR","RM","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_Fund_+'","基金",350,70,"RM","R","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_Link_+'","链接",420,70,"L","LM","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_doi_+'","DOI",420,70,"LM","ML","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_CLC_+'","中图号",420,70,"ML","M","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_ISBN_ISSN_+'","ISBN",420,70,"M","MR","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_Note_+'","注释",420,70,"MR","RM","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_DataProv_+'","DataProvider",420,70,"RM","R","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_Degree_+'","学位",490,70,"L","LM","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_Teacher_+'","导师",490,70,"LM","ML","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_City_+'","会议城市",490,70,"ML","M","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_Meeting_+'","会议名称",490,70,"M","MR","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_Sponsor_+'","赞助机构",490,70,"MR","RM","uneditable"');
    str.Add('edit "'+_Attrs_Basic_+'","'+_Col_basic_CN_+'","CN号",490,70,"RM","R","uneditable"');

    str.Add('edit "'+_Attrs_Notes_+'","'+_Col_notes_Usage_+'","用途",560,70,"L","LM","uneditable"');
    str.Add('edit "'+_Attrs_Notes_+'","'+_Col_notes_Rank_+'","评分",630,70,"L","LM","uneditable"');
    str.Add('edit "'+_Attrs_Notes_+'","'+_Col_notes_User_+'","入库用户",700,70,"L","LM","uneditable"');
    str.Add('edit "'+_Attrs_Notes_+'","'+_Col_notes_CreateTime_+'","入库时间",560,70,"LM","ML","uneditable"');
    str.Add('edit "'+_Attrs_Notes_+'","'+_Col_notes_ModifyTime_+'","最近修改",630,70,"LM","ML","uneditable"');
    str.Add('edit "'+_Attrs_Notes_+'","'+_Col_notes_CheckTime_+'","最近查询",700,70,"LM","ML","uneditable"');
    str.Add('memo "'+_Attrs_Notes_+'","'+_Col_notes_Comment_+'","笔记",560,210,"ML","MR","uneditable"');
    str.Add('memo "'+_Attrs_Notes_+'","'+_Col_notes_FurtherCmt_+'","其他笔记",560,140,"MR","R","uneditable"');
    str.Add('edit "'+_Attrs_Notes_+'","'+_Col_notes_Format_+'","格式",700,70,"MR","RM","uneditable"');

    str.SaveToFile(Self.FFilePath+Self.FRootFolder+'\format\all.fmt');
  finally
    str.Free;
  end;
  result:=true;
end;

function TRTFP.AddFormatDefault_SysMgr:boolean;
var str:TStringList;
    index:integer;
begin
  result:=false;
  if not FFormatList.Find('sys.fmt',index) then FFormatList.Add('sys.fmt');
  str:=TStringList.Create;
  try

    str.Add('edit "","'+_Col_Paper_Folder_+'","目录",0,70,"L","LM","uneditable"');
    str.Add('list "'+_Attrs_Class_+'","'+_Col_class_DefaultCl_+'","分类",0,70,"LM","ML","uneditable"');
    str.Add('edit "'+_Attrs_Notes_+'","'+_Col_notes_CreateTime_+'","入库时间",0,70,"ML","M","uneditable"');
    str.Add('edit "'+_Attrs_Notes_+'","'+_Col_notes_ModifyTime_+'","最近修改",0,70,"M","MR","uneditable"');
    str.Add('edit "'+_Attrs_Notes_+'","'+_Col_notes_CheckTime_+'","最近查询",0,70,"MR","RM","uneditable"');
    str.Add('edit "'+_Attrs_Notes_+'","'+_Col_notes_User_+'","入库用户",0,70,"RM","R","uneditable"');

    str.SaveToFile(Self.FFilePath+Self.FRootFolder+'\format\sys.fmt');
  finally
    str.Free;
  end;
  result:=true;
end;

//以下是默认属性的呈现，但是我还是把它禁用掉吧，或者至少加一个全局开关
{
edit "","文件大小","size",0,70,"L","LM",uneditable
edit "","目录","dir",0,70,"LM","ML",uneditable
check "","是否备份","backup?",0,70,"ML","M",uneditable
edit "","文件名","filename",0,70,"M","R",uneditable
edit "","文件哈希","hash",70,70,"L","R",uneditable
}
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
  FormatEditChange(newname,filename);
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
  FormatEditChange('',filename);
  result:=true;
end;

procedure TRTFP.LoadFromFormatEdit(filename:string;str:TStrings);
begin
  if not assigned(str) then exit;
  str.LoadFromFile(CurrentPathFull+'format\'+filename);
end;

procedure TRTFP.SaveToFormatEdit(filename:string;str:TStrings);
begin
  if not assigned(str) then exit;
  str.SaveToFile(CurrentPathFull+'format\'+filename);
  FormatEditChange(filename,filename);
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
  if not FFormatList.Find('all.fmt',index) then AddFormatDefault_All;
  if not FFormatList.Find('sys.fmt',index) then AddFormatDefault_SysMgr;
  //FFormatList.SaveToFile(Self.FFilePath+Self.FRootFolder+'\format.dat');
  FormatListChange;
end;

function TRTFP.SaveFormatList:boolean;
begin
  FFormatList.SaveToFile(Self.FFilePath+Self.FRootFolder+'\format.dat');//这个文件的存在仅为了保持兼容性
  result:=true;
end;

function TRTFP.CloseFormatList:boolean;
begin
  FFormatList.Clear;
  result:=true;
end;
