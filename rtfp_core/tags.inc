//与工程基本属性有关的方法

procedure TRTFP.SetUser(str:string);
begin
  if FProjectTags.Values['创建用户']<>str then
    begin
      FProjectTags.Values['创建用户']:=str;
      Change;
    end;
end;
function TRTFP.GetTitle:string;
begin
  result:=FProjectTags.Values['工程标题'];
end;

procedure TRTFP.SetTitle(str:string);
begin
  if FProjectTags.Values['工程标题']<>str then
    begin
      FProjectTags.Values['工程标题']:=str;
      Change;
    end;
end;

function TRTFP.GetVersion:string;
begin
  result:=FProjectTags.Values['最后保存版本'];
end;

procedure TRTFP.SetVersion(str:string);
begin
  if FProjectTags.Values['最后保存版本']<>str then
    begin
      FProjectTags.Values['最后保存版本']:=str;
      Change;
    end;
end;

function TRTFP.GetUser:string;
begin
  result:=FProjectTags.Values['创建用户'];
end;

procedure TRTFP.SetTag(index:string;str:string);
begin
  if FProjectTags.Values[index]<>str then
    begin
      FProjectTags.Values[index]:=str;
      Change;
    end;
end;

function TRTFP.GetTag(index:string):string;
begin
  result:=FProjectTags.Values[index];
end;

function TRTFP.GetOpenPdfExe:ansistring;
begin
  result:=Tag['PDF打开方式'];
  if result='' then
    begin
      result:=DefaultOpenExe;
      FProjectTags.Values['PDF打开方式']:=result;
    end;
end;

function TRTFP.GetOpenCajExe:ansistring;
begin
  result:=Tag['CAJ打开方式'];
  if result='' then
    begin
      result:=DefaultOpenExe;
      FProjectTags.Values['CAJ打开方式']:=result;
    end;
end;



