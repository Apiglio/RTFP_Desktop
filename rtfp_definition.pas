//{$define insert}

unit RTFP_definition;

{$mode objfpc}{$H+}
{$inline on}

interface

uses
  Classes, SysUtils, Dialogs, ValEdit, Windows,
  {$ifndef insert}
  Apiglio_Useful,
  {$endif}
  db, dbf;


const

  rnmbOK     = 1;
  rnmbCancel = 2;
  rnmbAbort  = 3;
  rnmbRetry  = 4;
  rnmbIgnore = 5;
  rnmbYes    = 6;
  rnmbNo     = 7;


  RTFP_ID_ORDER='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+-';

type

  RTFP_ID=string;//六位64进制数

  TRTFP_Auf=class(TAuf)
  public
    RTFP:TObject;
  end;


  TRTFP = class(TComponent)
  public
    //Auf:TRTFP_Auf;
    ProjectFileValue:TValueListEditor;//加载 #{project_name}.rtfp 到内存(CSV)
  private
    FPaperDB,FImageDB,FNoteDB:TDbf;
    FAttrGroupList:array[0..99]of record
      Enabled:boolean;
      Name:string;
      DataBase:string;
      Dbf:TDbf;
    end;

  private
    FFilePath:string;//完整路径
    FFileName:string;//文件名
    FFileFullName:string;//完整文件名
    FRootFolder:string;//根文件夹（不带拓展名的文件名）
    //FTitle:string;//标题
    //FUser:string;//用户

    FIsOpen:boolean;
    FIsChanged:boolean;

  protected
    procedure SetUser(str:string);
    function GetUser:string;
    procedure SetTitle(str:string);
    function GetTitle:string;


    procedure SetTag(str:string;index:string);
    function GetTag(index:string):string;


  public

    property User:string read GetUser write SetUser;
    property Title:string read GetTitle write SetTitle;


    property Tag[index:string]:string read GetTag write SetTag;

    property IsOpen:boolean read FIsOpen;
    property IsChanged:boolean read FIsChanged;


    property PaperDB:TDbf read FPaperDB;
    property ImageDB:TDbf read FImageDB;
    property NoteDB:TDbf read FNoteDB;



  public
    procedure New(filename:string;p_title:string;p_user:string);
    Procedure Open(filename:string);
    procedure Save;
    procedure SaveAs(filename:string);
    function Close:boolean;


  public
    function AddPaper(fullfilename:string):RTFP_ID;//新增一个文献到工程
    function FindPaper(fullfilename:string):RTFP_ID;//查找具体文件在工程中的PID，未找到返回000000
    procedure DeletePaper(PID:RTFP_ID);//移除指定PID的文献
    procedure EditPaperData(PID:RTFP_ID;col_name,value:string);//修改指定PID文献的属性
    function ReadPaperData(PID:RTFP_ID;col_name:string):string;//读取指定PID文献的属性

    function AddImage(fullfilename:string):RTFP_ID;//新增一个图片到工程
    procedure DeleteImage(IID:RTFP_ID);//移除指定IID的图片
    procedure EditImageData(IID:RTFP_ID;col_name,value:string);//修改指定IID图片的属性
    function ReadImageData(IID:RTFP_ID;col_name:string):string;//读取指定IID图片的属性

    function AddNote(fullfilename:string):RTFP_ID;//新增一个注解到工程
    procedure DeleteNote(NID:RTFP_ID);//移除指定NID的注解
    procedure EditNoteData(NID:RTFP_ID;col_name,value:string);//修改指定NID注解的属性
    function ReadNoteData(NID:RTFP_ID;col_name:string):string;//读取指定NID注解的属性

    procedure AddAttrGroup(id:byte;group_name:string);//新增一个字段组表到工程
    procedure DeleteAttrGroup(id:byte);//移除指定Name的字段组表


  private
    FOnNew,FOnNewDone:TNotifyEvent;
    FOnOpen,FOnOpenDone:TNotifyEvent;
    FOnSave,FOnSaveDone:TNotifyEvent;
    FOnSaveAs,FOnSaveAsDone:TNotifyEvent;
    FOnClose,FOnCloseDone:TNotifyEvent;

  public
    property onNew:TNotifyEvent read FOnNew write FOnNew;
    property onNewDone:TNotifyEvent read FOnNewDone write FOnNewDone;
    property onOpen:TNotifyEvent read FOnOpen write FOnOpen;
    property onOpenDone:TNotifyEvent read FOnOpenDone write FOnOpenDone;
    property onSave:TNotifyEvent read FOnSave write FOnSave;
    property onSaveDone:TNotifyEvent read FOnSaveDone write FOnSaveDone;
    property onSaveAs:TNotifyEvent read FOnSaveAs write FOnSaveAs;
    property onSaveAsDone:TNotifyEvent read FOnSaveAsDone write FOnSaveAsDone;
    property onClose:TNotifyEvent read FOnClose write FOnCLose;
    property onCloseDone:TNotifyEvent read FOnCloseDone write FOnCloseDone;


  public {类方法}
    class function NumToID(Num:dword):RTFP_ID;
    class function IDToNum(ID:RTFP_ID):dword;

    class function DateTimeStr:string;

    class function CanBuildName(projname:string):boolean;
    class function CanBuildPath(pathname:string):boolean;
    class function CanBuildFile(fullname:string):boolean;
    class function CanBuildDisc(discchar:char):boolean;

  public
    constructor Create(AOwner:TComponent);
    //destructor Destroy;override;



  end;



//procedure AufScriptFuncDefine(Auf:TAuf);




implementation

{
procedure p_IO_output(Sender:TObject;str:string);
var obj_str:string;
begin
  if Sender is TRTFP_Auf then
    obj_str:=((Sender as TRTFP_Auf).RTFP as TRTFP).FTitle
  else obj_str:='untitled';
  ShowMessage('工程'+obj_str+': '+str);
end;

procedure p_name(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TRTFP_Auf;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TRTFP_Auf;
  (AAuf.RTFP as TRTFP).FTitle:=AAuf.nargs[1].arg;
end;
procedure p_user(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TRTFP_Auf;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TRTFP_Auf;
  (AAuf.RTFP as TRTFP).FUser:=AAuf.nargs[1].arg;
end;
procedure add_attr(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TRTFP_Auf;
    id:byte;
    group_name:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TRTFP_Auf;
  if not AAuf.CheckArgs(3) then exit;
  if not AAuf.TryArgToByte(1,id) then exit;
  if not AAuf.TryArgToString(2,group_name) then exit;
  (AAuf.RTFP as TRTFP).AddAttrGroup(id,group_name);
end;
procedure delete_attr(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TRTFP_Auf;
    id:byte;
    group_name:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TRTFP_Auf;
  if not AAuf.TryArgToByte(1,id) then begin ShowMessage('函数'+AAuf.nargs[0].arg+'的id参数无效！');exit end;
  (AAuf.RTFP as TRTFP).DeleteAttrGroup(id);
end;
procedure add_class(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TRTFP_Auf;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TRTFP_Auf;
  //
end;

procedure AufScriptFuncDefine(Auf:TAuf);
begin
  with Auf do begin
    Script.add_func('p_name',@p_name,'project_name','工程名称');
    Script.add_func('p_user',@p_user,'project_user','工程用户');
    Script.add_func('add_attr',@add_attr,'attr_id,attr_name','新增字段组表');
    Script.add_func('add_class',@add_class,'class_path','新增类节点');
  end;
end;

}



constructor TRTFP.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);


  ProjectFileValue:=TValueListEditor.Create(AOwner);
  //ProjectFileValue.Parent:=AOwner;
  ProjectFileValue.Hide;

  FPaperDB:=TDbf.Create(Self);
  FImageDB:=TDbf.Create(Self);
  FNoteDB:=TDbf.Create(Self);
  {
  Self.Auf:=TRTFP_Auf.Create(AOwner);
  Self.Auf.RTFP:=Self;
  Self.Auf.Script.IO_fptr.echo:=nil;
  Self.Auf.Script.IO_fptr.print:=nil;
  Self.Auf.Script.IO_fptr.error:=@p_IO_output;
  AufScriptFuncDefine(Self.Auf);
  }
  FFilePath:='';
  FFileName:='';

  FIsChanged:=false;
  FIsOpen:=false;


end;

{
destructor TRTFP.Destory;
begin
  FPaperDB.Free;
  FImageDB.Free;
  FNoteDB.Free;

  Auf.Free;


  ProjectFileValue.Free;

  inherited Destory;
end;
}

procedure TRTFP.New(filename:string;p_title:string;p_user:string);
var tmpProjectFile:TStringList;
    retry:boolean;
    len:integer;
    stmp:string;
begin
  if FOnNew <> nil then FOnNew(Self);


  //StringReplace(filename,'/','\',[rfReplaceAll]);
  Self.FFileName:=ExtractFileName(filename);
  Self.FFilePath:=ExtractFilePath(filename);
  Self.FRootFolder:=Self.FFileName;
  Self.FFileFullName:=Self.FFilePath+Self.FFileName;
  len:=length(Self.FRootFolder);
  if len>=5 then begin
    stmp:=Self.FRootFolder;
    delete(stmp,1,len-5);
    if stmp='.rtfp' then delete(Self.FRootFolder,len-4,5);
  end;

  tmpProjectFile:=TStringList.Create;

  tmpProjectFile.Add('属性,值');
  tmpProjectFile.Add('工程标题,'+p_title);
  tmpProjectFile.Add('创建用户,'+p_user);
  tmpProjectFile.Add('创建日期,'+TRTFP.DateTimeStr);
  tmpProjectFile.Add('修改日期,'+TRTFP.DateTimeStr);

  tmpProjectFile.Add('属性组00,文献基础信息');
  tmpProjectFile.Add('属性组01,分类');
  tmpProjectFile.Add('属性组02,注解');

  repeat
    retry:=false;
    try
      tmpProjectFile.SaveToFile(filename);
      ForceDirectories(Self.FFilePath+Self.FRootFolder);
      Self.ProjectFileValue.LoadFromCSVFile(filename);
    except
      case MessageDlg('错误','文件占用导致工程文档创建异常！',mtConfirmation,[mbRetry,mbCancel],0) of
        rnmbRetry:retry:=true;
        rnmbCancel:exit;
      end;
    end;
  until not retry;



  tmpProjectFile.Free;



  if FOnNewDone <> nil then FOnNewDone(Self);
  Self.FIsOpen:=true;
end;

Procedure TRTFP.Open(filename:string);
begin
  if FOnOpen <> nil then FOnOpen(Self);


  if FOnOpenDone <> nil then FOnOpenDone(Self);
  Self.FIsOpen:=true;
end;

procedure TRTFP.Save;
begin
  if FOnSave <> nil then FOnSave(Self);


  Self.Tag['修改日期']:=TRTFP.DateTimeStr;//必须在IsChanged还原之前
  if FOnSaveDone <> nil then FOnSaveDone(Self);
  Self.FIsChanged:=false;
end;

procedure TRTFP.SaveAs(filename:string);
begin
  if FOnSaveAs <> nil then FOnSaveAs(Self);

  if FOnSaveAsDone <> nil then FOnSaveAsDone(Self);
end;

function TRTFP.Close:boolean;
begin
  result:=false;
  if FOnClose <> nil then FOnClose(Self);
  if Self.FIsChanged then
    begin

      case MessageDlg('未保存','关闭工程时是否保存工程？',mtConfirmation,[mbYes,mbNo,mbCancel],0) of
        rnmbYes:Self.Save;
        rnmbNo:;
        rnmbCancel:exit;
      end;
    end;

  //

  if FOnCloseDone <> nil then FOnCloseDone(Self);
  Self.FIsOpen:=false;
  result:=true;
end;




function TRTFP.AddPaper(fullfilename:string):RTFP_ID;//新增一个文献到工程
begin

end;

function TRTFP.FindPaper(fullfilename:string):RTFP_ID;//查找具体文件在工程中的PID，未找到返回000000
begin

end;

procedure TRTFP.DeletePaper(PID:RTFP_ID);//移除指定PID的文献
begin

end;

procedure TRTFP.EditPaperData(PID:RTFP_ID;col_name,value:string);//修改指定PID文献的属性
begin

end;

function TRTFP.ReadPaperData(PID:RTFP_ID;col_name:string):string;//读取指定PID文献的属性
begin

end;


function TRTFP.AddImage(fullfilename:string):RTFP_ID;//新增一个图片到工程
begin

end;

procedure TRTFP.DeleteImage(IID:RTFP_ID);//移除指定IID的图片
begin

end;

procedure TRTFP.EditImageData(IID:RTFP_ID;col_name,value:string);//修改指定IID图片的属性
begin

end;

function TRTFP.ReadImageData(IID:RTFP_ID;col_name:string):string;//读取指定IID图片的属性
begin

end;


function TRTFP.AddNote(fullfilename:string):RTFP_ID;//新增一个注解到工程
begin

end;

procedure TRTFP.DeleteNote(NID:RTFP_ID);//移除指定NID的注解
begin

end;

procedure TRTFP.EditNoteData(NID:RTFP_ID;col_name,value:string);//修改指定NID注解的属性
begin

end;

function TRTFP.ReadNoteData(NID:RTFP_ID;col_name:string):string;//读取指定NID注解的属性
begin

end;



procedure TRTFP.AddAttrGroup(id:byte;group_name:string);//新增一个字段组表到工程
begin
  if id>99 then exit;
  if not IsOpen then exit;
  WITH Self.FAttrGroupList[id] DO BEGIN
    Name:=group_name;
    DataBase:=FFilePath+'\'+FFileName+'\attr\'+group_name+'.dbf';

    if assigned(Dbf) then Dbf.Free;
    Dbf:=TDbf.Create(Self);
    Dbf.FilePathFull:=DataBase;

    if FileExists(Dbf.FilePathFull) then
      begin
        Dbf.Open;
        //Append;
        //Fields[1].AsString:='28D+eS';
        //Fields[2].AsInteger:=1;
        //Post;
      end
    else
      begin
        Dbf.TableLevel:=7;
        Dbf.Exclusive:=true;
        Dbf.FieldDefs.Add('OID', ftAutoInc, 0, True);
        Dbf.FieldDefs.Add('PID', ftString, 8, True);
        Dbf.FieldDefs.Add('PaperLine', ftInteger, 0, True);
        Dbf.CreateTable;
        Dbf.Open;
        //Dbf.Append;
        //Dbf.Fields[1].AsString:='000000';
        //Dbf.Fields[2].AsInteger:=0;
        //Dbf.Post;
      end;
    Enabled:=true;
  END;
end;

procedure TRTFP.DeleteAttrGroup(id:byte);//移除指定Name的字段组表
begin
  if id>99 then exit;
  if not IsOpen then exit;
  WITH Self.FAttrGroupList[id] DO BEGIN
    Name:='';
    DataBase:='';
    if assigned(Dbf) then begin
      if FileExists(Dbf.FilePathFull) then Dbf.Close;
      Dbf.Free;
    end;
    Dbf:=nil;
    Enabled:=false;
  END;
end;







procedure TRTFP.SetUser(str:string);
begin
  if ProjectFileValue.Values['创建用户']<>str then
    begin
      ProjectFileValue.Values['创建用户']:=str;
      FIsChanged:=true;
    end;
end;

function TRTFP.GetTitle:string;
begin
  result:=ProjectFileValue.Values['工程标题'];
end;

procedure TRTFP.SetTitle(str:string);
begin
  if ProjectFileValue.Values['工程标题']<>str then
    begin
      ProjectFileValue.Values['工程标题']:=str;
      FIsChanged:=true;
    end;
end;

function TRTFP.GetUser:string;
begin
  result:=ProjectFileValue.Values['创建用户'];
end;



procedure TRTFP.SetTag(str:string;index:string);
begin
  if ProjectFileValue.Values[index]<>str then
    begin
      ProjectFileValue.Values[index]:=str;
      FIsChanged:=true;
    end;
end;

function TRTFP.GetTag(index:string):string;
begin
  result:=ProjectFileValue.Values[index];
end;




class function TRTFP.NumToID(Num:dword):RTFP_ID;
begin
  result:='';
  repeat
      result:=RTFP_ID_ORDER[Num mod 64 +1]+result;
      Num:=Num shr 6;
  until (Num=0) or (length(result)=6);
end;

class function TRTFP.IDToNum(ID:RTFP_ID):dword;
begin
  result:=0;
  if ID='' then exit;
  repeat
    result:=result shl 6;
    case ID[1] of
      '0'..'9':result:=result+ord(ID[1])-ord('0');
      'A'..'Z':result:=result+ord(ID[1])-ord('A')+10;
      'a'..'z':result:=result+ord(ID[1])-ord('a')+36;
      '+':result:=result+62;
      '-':result:=result+63;
      else raise Exception.Create('Apiglio: IDToNum发现非64进制编码。');
    end;
    delete(ID,1,1);
  until ID='';
end;

class function TRTFP.DateTimeStr:string;inline;
begin
  result:=FormatDateTime('yyyy-mm-dd hh:nn:ss',Now());
end;

class function TRTFP.CanBuildName(projname:string):boolean;
var i,len:integer;
begin
  result:=false;
  len:=length(projname);
  if len=0 then exit;
  i:=0;
  while i<=len do
    begin
      if pos(projname[i],'/\:*"<>|?')>0 then exit;
      inc(i);
    end;
  result:=true;
end;

class function TRTFP.CanBuildPath(pathname:string):boolean;
begin
  if DirectoryExists(pathname) then result:=false
  else result:=true;
  //ShowMessage(pathname);
end;

class function TRTFP.CanBuildFile(fullname:string):boolean;
begin
  if fileExists(fullname) then result:=false
  else result:=true;
  //ShowMessage(fullname);
end;

class function TRTFP.CanBuildDisc(discchar:char):boolean;
var available_bytes,total_bytes:int64;
begin
  {
  GetDiskFreeSpaceEx(@discchar,@available_bytes,@total_bytes,nil);
  ShowMessage(
    'DISC '+discchar+':'+#13+#10+
    '  avail='+IntToStr(available_bytes)+#13+#10+
    '  total='+IntToStr(total_bytes)+#13+#10
    //'  free='+IntToStr(free_bytes)
  );
  }
  result:=true;

end;



end.

