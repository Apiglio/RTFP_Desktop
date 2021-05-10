//{$define insert}
{$define test}

unit RTFP_definition;

{$mode objfpc}{$H+}
{$inline on}


interface

uses
  Classes, SysUtils, Dialogs, ValEdit, Windows, LazUTF8,
  {$ifndef insert}
  Apiglio_Useful, auf_ram_var,
  //AufScript_Frame,
  {$endif}
  db, dbf, memds;

  //{$I pdfium\fpdfview.h}


const

  {Real Number of MessageBox}
  rnmbOK     = 1;
  rnmbCancel = 2;
  rnmbAbort  = 3;
  rnmbRetry  = 4;
  rnmbIgnore = 5;
  rnmbYes    = 6;
  rnmbNo     = 7;


  RTFP_ID_ORDER = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+-';
  DefaultOpenExe = ''; //cmd.exe /c

  _Col_OID_ = 'OID';
  _Col_PID_ = 'PID';
  _Col_IID_ = 'IID';
  _Col_NID_ = 'NID';

  _Col_Paper_Is_Backup_ = '是否备份';
  _Col_Paper_Folder_ = '目录';
  _Col_Paper_FileName_ = '文件名';
  _Col_Paper_FileSize_ = '文件大小';
  _Col_Paper_FileHash_ = '文件哈希';

  _Num_Paper_OID_ = 0;
  _Num_Paper_PID_ = 1;
  _Num_Paper_Is_Backup_ = 2;
  _Num_Paper_Folder_ = 3;
  _Num_Paper_FileName_ = 4;
  _Num_Paper_FileSize_ = 5;
  _Num_Paper_FileHash_ = 6;

  _Num_Attr_OID_ = 0;
  _Num_Attr_PID_ = 1;

  _Col_Image_FileSize_ = '文件大小';
  _Col_Image_FileHash_ = '文件哈希';
  _Col_Image_Folder_ = '目录';
  _Col_Image_FileName_ = '文件名';
  _Col_Image_Width_ = '宽度';
  _Col_Image_Height_ = '高度';
  _Col_Note_Folder_ = '目录';
  _Col_Note_FileName_ = '文件名';
  _Col_basic_RefType_ = '类型';
  _Col_basic_Title_ = '标题';
  _Col_basic_Author_ = '作者';
  _Col_basic_Corresp_ = '通讯作者';
  _Col_basic_Source_ = '来源';
  _Col_basic_PubTime_ = '发表时间';
  _Col_basic_Keyword_ = '关键词';
  _Col_basic_Summary_ = '摘要';
  _Col_basic_Organ_ = '单位';
  _Col_basic_Year_ = '年份';
  _Col_basic_Volume_ = '卷';
  _Col_basic_Issue_ = '期';
  _Col_basic_PageCount_ = '页数';
  _Col_basic_Page_ = '页码';
  _Col_basic_Fund_ = '基金';
  _Col_basic_Link_ = '链接';
  _Col_basic_doi_ = 'DOI';
  _Col_basic_CLC_ = '中图号';
  _Col_basic_ISBN_ISSN_ = 'ISBN';
  _Col_basic_Note_ = '注释';
  _Col_basic_DataProv_ = 'DataProv.';
  _Col_basic_Has_Ext_ = 'Has_Ext';
  _Col_metas_Title_ = 'Title';
  _Col_metas_Authors_ = 'Authors';
  _Col_metas_Subject_ = 'Subject';
  _Col_metas_KeyWord_ = 'KeyWord';
  _Col_metas_Creator_ = 'Creator';
  _Col_metas_Produce_ = 'Produce';
  _Col_metas_CreDate_ = 'CreDate';
  _Col_metas_ModDate_ = 'ModDate';
  _Col_metas_Trapped_ = 'Trapped';
  _Col_class_Is_Read_ = '是否已读';
  _Col_class_DefaultCl_ = '默认分类';
  _Col_notes_Usage_ = '用途';
  _Col_notes_Rank_ = '评分';
  _Col_notes_Comment_ = '笔记';
  _Col_notes_User_ = '入库用户';
  _Col_notes_CreateTime_ = '入库时间';
  _Col_notes_ModifyTime_ = '最近修改';
  _Col_notes_CheckTime_ = '最近查询';
  _Col_notes_FurtherCmt_ = 'FurtherCmt';
  _Col_notes_Format_ = 'Format';



type

  RTFP_ID=string;//六位64进制数

  TAttrExtendUnit = (aeFailIfNoPID,aeFailIfNoField);
  TAttrExtend = set of TAttrExtendUnit;
  TablesUse = set of byte;
  TAddPaperMethod = (apmFullBackup,apmAddress,apmWebsite,apmReference);
  //三种文档入库方式: 复制备份/本地链接/网址链接/数据入库

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
    FUserList,FFormatList:TStringList;
    FAttrGroupList:array[0..99]of record
      Enabled:boolean;
      Name:string;//属性组名称
      DataBase:string;//路径
      Dbf:TDbf;
    end;

  private
    FFilePath:string;//完整路径
    FFileName:string;//文件名
    FFileFullName:string;//完整文件名
    FRootFolder:string;//根文件夹（不带拓展名的文件名）

    FIsOpen:boolean;
    FIsChanged:boolean;

  protected
    procedure SetUser(str:string);
    function GetUser:string;
    procedure SetTitle(str:string);
    function GetTitle:string;


    procedure SetTag(index:string;str:string);
    function GetTag(index:string):string;

    function GetAttrsDB(index:byte):TDbf;
    function GetAttrsName(index:byte):string;
    function GetAttrsByName(index:string):byte;//找不到返回255

    function GetOpenPdfExe:ansistring;
    function GetOpenCajExe:ansistring;


  public
    //工程基本属性
    property User:string read GetUser write SetUser;
    property Title:string read GetTitle write SetTitle;

    property Tag[index:string]:string read GetTag write SetTag;
    property AttrsName[index:byte]:string read GetAttrsName;
    property AttrsByName[index:string]:byte read GetAttrsByName;

    property OpenPdfExe:ansistring read GetOpenPdfExe;
    property OpenCajExe:ansistring read GetOpenCajExe;


    //工程运行状态
    property IsOpen:boolean read FIsOpen;
    property IsChanged:boolean read FIsChanged;


    property PaperDB:TDbf read FPaperDB;
    property ImageDB:TDbf read FImageDB;
    property NoteDB:TDbf read FNoteDB;
    property AttrsDB[index:byte]:TDbf read GetAttrsDB;

  private
    procedure SetPaths(filename:string);

    function NewProjectFile(p_title,p_user:string):boolean;inline;
    function OpenProjectFile:boolean;inline;
    function SaveProjectFile:boolean;inline;
    function CloseProjectFile:boolean;inline;

    function NewUserList:boolean;inline;
    function OpenUserList:boolean;inline;
    function SaveUserList:boolean;inline;
    function CloseUserList:boolean;inline;

    function NewFormatList:boolean;inline;
    function OpenFormatList:boolean;inline;
    function SaveFormatList:boolean;inline;
    function CloseFormatList:boolean;inline;


    procedure GenPaperAttribute(Dbf:TDbf);inline;
    procedure GenImageAttribute(Dbf:TDbf);inline;
    procedure GenNoteAttribute(Dbf:TDbf);inline;

    procedure GenAttrMetasAttribute(Dbf:TDbf);
    procedure GenAttrBasicAttribute(Dbf:TDbf);inline;
    procedure GenAttrClassAttribute(Dbf:TDbf);inline;
    procedure GenAttrNotesAttribute(Dbf:TDbf);inline;
    procedure GenAttrDefaultAttribute(Dbf:TDbf);inline;



    function OpenDbf(dbf_name_no_ext:string;Dbf:TDbf):boolean;
    function NewDbf(dbf_name_no_ext:string;Dbf:TDbf):boolean;
    function SaveDbf(dbf_name_no_ext:string;Dbf:TDbf):boolean;
    function CloseDbf(dbf_name_no_ext:string;Dbf:TDbf):boolean;

    //基于ProjectFileValue
    procedure NewAttrDbfs;
    procedure OpenAttrDbfs;
    procedure SaveAttrDbfs;
    procedure CloseAttrDbfs;


  public //工程打开关闭操作
    procedure New(filename:ansistring;p_title:string;p_user:string);
    Procedure Open(filename:ansistring);
    procedure Save;
    procedure SaveAs(filename:ansistring);
    function Close:boolean;

    procedure Change;//用于标记工程已经发生改变，如果之前未改变，会触发OnFirstEdit


  private
    function UserID(AUser:string):integer;
    function FormatID(AFormat:string):integer;

    function NewPaperID:RTFP_ID;
    function NewImageID:RTFP_ID;
    function NewNoteID:RTFP_ID;


    procedure ReNewCreateTime(PID:RTFP_ID);
    procedure ReNewModifyTime(PID:RTFP_ID);
    procedure ReNewCheckTime(PID:RTFP_ID);

    procedure ReNewModifyTimeWithoutChange(PID:RTFP_ID);
    procedure ReNewCheckTimeWithoutChange(PID:RTFP_ID);


    //这些用于在属性组表中增加指定PID的记录
    //这两个会打开Edit模式：
    function FindAttrRecord(PID:RTFP_ID;AttrNo:byte):TFields;//未找到返回nil，这个函数用于调用TFields，一般用来修改数据，调用之后需要加PostAttrRecord用于保存更新和表示工程修改
    function NewAttrRecord(PID:RTFP_ID;AttrNo:byte):TFields;
    //这两个会关闭Edit模式：
    function PostAttrRecord(AttrNo:byte):boolean;//会调用Change;
    function CancelAttrRecord(AttrNo:byte):boolean;

    function DeleteAttrRecord(PID:RTFP_ID;AttrNo:byte):boolean;//会调用Change;

    function ExistAttrField(FieldName:string;AttrNo:byte):TFieldDef;//未找到返回nil
    function AddAttrField(FieldName:string;AttrNo:byte;FieldType:TFieldType;FieldSize:word):TFieldDef;
    function DeleteAttrField(FieldName:string;AttrNo:byte):boolean;


  public //记录编辑
    function AddPaper(fullfilename:string;AddPaperMethod:TAddPaperMethod=apmFullBackup):RTFP_ID;//新增一个文献到工程
    function FindPaper(fullfilename:string):RTFP_ID;//查找具体文件在工程中的PID，未找到返回000000
    procedure DeletePaper(PID:RTFP_ID);//移除指定PID的文献

    procedure OpenPaperAsPDF(PID:RTFP_ID);
    procedure OpenPaperAsCAJ(PID:RTFP_ID);


    {
    procedure EditPaperData(PID:RTFP_ID;col_name,value:string);//修改指定PID文献的属性
    function ReadPaperData(PID:RTFP_ID;col_name:string):string;//读取指定PID文献的属性
    }
    function EditAttrField(PID:RTFP_ID;AttrNo:byte;FieldName:string;FailOption:TAttrExtend;value:string):boolean;
    function ReadAttrField(PID:RTFP_ID;AttrNo:byte;FieldName:string;FailOption:TAttrExtend;var value:string):boolean;



    function AddImage(fullfilename:string):RTFP_ID;//新增一个图片到工程
    procedure DeleteImage(IID:RTFP_ID);//移除指定IID的图片
    procedure EditImageData(IID:RTFP_ID;col_name,value:string);//修改指定IID图片的属性
    function ReadImageData(IID:RTFP_ID;col_name:string):string;//读取指定IID图片的属性

    function AddNote(fullfilename:string):RTFP_ID;//新增一个注解到工程
    procedure DeleteNote(NID:RTFP_ID);//移除指定NID的注解
    procedure EditNoteData(NID:RTFP_ID;col_name,value:string);//修改指定NID注解的属性
    function ReadNoteData(NID:RTFP_ID;col_name:string):string;//读取指定NID注解的属性


    {
    procedure AddAttrGroup(id:byte;group_name:string);//新增一个字段组表到工程
    procedure DeleteAttrGroup(id:byte);//移除指定Name的字段组表
    }

  public //连接显示
    procedure ProjectPropertiesValidate(AValueListEditor:TValueListEditor);
    procedure ProjectPropertiesDataPost(AValueListEditor:TValueListEditor);


    procedure TableValidate(ADataSet:TMemDataSet;table_enabled:TablesUse);
    procedure NodeViewValidate(PID:RTFP_ID;AValueListEditor:TValueListEditor);
    procedure NodeViewDataPost(PID:RTFP_ID;AValueListEditor:TValueListEditor);




  private
    FOnNew,FOnNewDone:TNotifyEvent;
    FOnOpen,FOnOpenDone:TNotifyEvent;
    FOnSave,FOnSaveDone:TNotifyEvent;
    FOnSaveAs,FOnSaveAsDone:TNotifyEvent;
    FOnClose,FOnCloseDone:TNotifyEvent;
    FOnFirstEdit,FOnChange:TNotifyEvent;

  public
    property onNew:TNotifyEvent read FOnNew write FOnNew;
    property onNewDone:TNotifyEvent read FOnNewDone write FOnNewDone;
    property onOpen:TNotifyEvent read FOnOpen write FOnOpen;
    property onOpenDone:TNotifyEvent read FOnOpenDone write FOnOpenDone;
    property onSave:TNotifyEvent read FOnSave write FOnSave;
    property onSaveDone:TNotifyEvent read FOnSaveDone write FOnSaveDone;
    property onSaveAs:TNotifyEvent read FOnSaveAs write FOnSaveAs;
    property onSaveAsDone:TNotifyEvent read FOnSaveAsDone write FOnSaveAsDone;
    property onClose:TNotifyEvent read FOnClose write FOnClose;
    property onCloseDone:TNotifyEvent read FOnCloseDone write FOnCloseDone;
    property onFirstEdit:TNotifyEvent read FOnFirstEdit write FOnFirstEdit;
    property onChange:TNotifyEvent read FOnChange write FOnChange;

  {类方法}
  public
    class function NumToID(Num:dword):RTFP_ID;
    class function IDToNum(ID:RTFP_ID):dword;

    class function GetDateTimeStr:string;inline;
    class function GetDateDir:string;inline;

    class function CanBuildName(projname:string):boolean;
    class function CanBuildPath(pathname:string):boolean;
    class function CanBuildPLen(pathname:string):boolean;
    class function CanBuildFile(fullname:string):boolean;
    class function CanBuildDisc(discchar:char):boolean;unimplemented;

    class function FileHash(AFileStream:TStream):string;//返回一个239长度的文件Hash
    class function FileCopy(source,dest:string;bFailIfExist:boolean):boolean;//utf8的string版本
    class function FileDelete(source:string):boolean;//utf8的string版本
    class function MakeDir(filename:string):boolean;

  {构造与析构}
  public
    constructor Create(AOwner:TComponent);virtual;
    destructor Destroy;override;



  end;


//var CurrentRTFP:TRTFP;


procedure AufScriptFuncDefineRTFP(Auf:TAuf);


implementation
uses RTFP_main, rtfp_pdfobj;


{
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
}

{
procedure aufunc_XXX(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  //
end;
}
procedure aufunc_FileHash(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
    filename:string;
    FileStream:TMemoryStream;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,filename) then exit;
  FileStream:=TMemoryStream.Create;
  FileStream.LoadFromFile(filename);

  AufScpt.writeln(TRTFP.FileHash(FileStream));
  FileStream.Free;
end;

procedure aufunc_AddPaper(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
    filename:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,filename) then exit;

  AufScpt.writeln(CurrentRTFP.AddPaper(filename));

end;

procedure aufunc_AddPaperNote(Sender:TObject);//AddNote PID,"memo"
var AufScpt:TAufScript;
    AAuf:TAuf;
    APID,AMEMO:string;
    tmp:TFields;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(3) then exit;
  if not AAuf.TryArgToString(1,APID) then exit;
  if not AAuf.TryArgToString(2,AMEMO) then exit;


  tmp:=CurrentRTFP.FindAttrRecord(APID,2);
  if tmp=nil then tmp:=CurrentRTFP.NewAttrRecord(APID,2);
  tmp.FieldByName('Comment').AsString:=AMEMO;
  CurrentRTFP.PostAttrRecord(2);


  AufScpt.writeln('Note添加成功。');

end;

procedure aufunc_EditAttr(Sender:TObject);//edit.attr PID,AttrNo,FieldName,"memo"
var AufScpt:TAufScript;
    AAuf:TAuf;
    APID,AMEMO,AFieldName:string;
    AAttrNo:byte;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(5) then exit;
  if not AAuf.TryArgToString(1,APID) then exit;
  if not AAuf.TryArgToByte(2,AAttrNo) then exit;
  if not AAuf.TryArgToString(3,AFieldName) then exit;
  if not AAuf.TryArgToString(4,AMEMO) then exit;

  CurrentRTFP.EditAttrField(APID,AAttrNo,AFieldName,[],AMEMO);

  AufScpt.writeln('Note添加成功。');

end;
procedure aufunc_ReadAttr(Sender:TObject);//read.attr PID,AttrNo,FieldName,out
var AufScpt:TAufScript;
    AAuf:TAuf;
    APID,AFieldName,AValue:string;
    AAttrNo:byte;
    arv:TAufRamVar;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(5) then exit;
  if not AAuf.TryArgToString(1,APID) then exit;
  if not AAuf.TryArgToByte(2,AAttrNo) then exit;
  if not AAuf.TryArgToString(3,AFieldName) then exit;
  if not AAuf.TryArgToARV(4,256,256,[ARV_Char],arv) then exit;

  CurrentRTFP.ReadAttrField(APID,AAttrNo,AFieldName,[],AValue);
  initiate_arv_str(AValue,arv);

  AufScpt.writeln('Fields['+IntToStr(AAttrNo)+','+AFieldName+']='+AValue);

end;

procedure aufunc_ShowPaperNote(Sender:TObject);//AddNote PID
var AufScpt:TAufScript;
    AAuf:TAuf;
    APID,AMEMO:string;
    tmp:TFields;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,APID) then exit;

  tmp:=CurrentRTFP.FindAttrRecord(APID,2);
  if tmp=nil then exit;
  AMEMO:=tmp.FieldByName('Comment').AsString;
  CurrentRTFP.CancelAttrRecord(2);

  AufScpt.writeln('Note='+AMemo);

end;

procedure aufunc_newPaperId(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  AufScpt.writeln(CurrentRTFP.NewPaperID);
end;
procedure aufunc_newImageId(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  AufScpt.writeln(CurrentRTFP.NewImageID);
end;
procedure aufunc_newNoteId(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  AufScpt.writeln(CurrentRTFP.NewNoteID);
end;

procedure aufunc_ShowMeta(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
    filename:string;
    RTFP_PDF:TRTFP_PDF;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,filename) then exit;

  RTFP_PDF:=TRTFP_PDF.Create(nil);
  RTFP_PDF.LoadPdf(filename);

  AufScpt.writeln(RTFP_PDF.Meta.ToString);

  RTFP_PDF.ClosePdf;
  RTFP_PDF.Free;

end;

procedure aufunc_ShowView(Sender:TObject);//没成功
var AufScpt:TAufScript;
    AAuf:TAuf;
    filename:string;
    RTFP_PDF:TRTFP_PDF;
    page:dword;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,filename) then exit;

  RTFP_PDF:=TRTFP_PDF.Create(nil);
  RTFP_PDF.LoadPdf(filename);

  RTFP_PDF.ShowPage(FormDesktop.Image_PDF_View.Picture.Bitmap.Canvas.Handle,page);
  //AufScpt.writeln(RTFP_PDF.Meta.ToString);

  RTFP_PDF.ClosePdf;
  RTFP_PDF.Free;
end;

procedure aufunc_save(Sender:TObject);
var AufScpt:TAufScript;
begin
  AufScpt:=Sender as TAufScript;
  if not assigned(CurrentRTFP) then begin AufScpt.writeln('工程对象未指派！');exit end;
  if not CurrentRTFP.IsOpen then begin AufScpt.writeln('工程未打开！');exit end;
  CurrentRTFP.Save;
  AufScpt.writeln('强制保存成功。');
end;



{$ifdef test}

procedure aufunc_test(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
    filename:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,filename) then exit;

  //

end;

{$endif}



procedure AufScriptFuncDefineRTFP(Auf:TAuf);
begin
  with Auf do begin
    Script.add_func('new.pid',@aufunc_newPaperId,'','返回一个可用的PID');
    Script.add_func('new.iid',@aufunc_newImageId,'','返回一个可用的IID');
    Script.add_func('new.nid',@aufunc_newNoteId,'','返回一个可用的NID');
    Script.add_func('filehash',@aufunc_FileHash,'filename','返回FileHash');
    Script.add_func('add.paper',@aufunc_AddPaper,'filename','新建Paper节点');
    Script.add_func('add.paper.notes',@aufunc_AddPaperNote,'PID, MEMO','修改Paper节点的Comment字段');
    Script.add_func('show.paper.notes',@aufunc_ShowPaperNote,'PID','显示Paper节点的Comment字段');
    Script.add_func('edit.attr',@aufunc_EditAttr,'PID,AttrNo,FieldName,Memo','修改PID节点中第AttrNo表的FieldName字段为Memo');
    Script.add_func('read.attr',@aufunc_ReadAttr,'PID,AttrNo,FieldName,arv','修改PID节点中第AttrNo表的FieldName字段为Memo');

    Script.add_func('pdf.meta',@aufunc_ShowMeta,'filename','检查pdf文件的meta数据');
    Script.add_func('pdf.view',@aufunc_ShowView,'filename,page','预览pdf的page页');


    Script.add_func('save',@aufunc_save,'','强制保存');

    {$ifdef test}
    Script.add_func('test',@aufunc_test,'*arg','测试');
    {$endif}


  end;
end;








constructor TRTFP.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);


  ProjectFileValue:=TValueListEditor.Create(nil);
  //ProjectFileValue.Parent:=AOwner;
  ProjectFileValue.Hide;

  FPaperDB:=TDbf.Create(Self);
  FImageDB:=TDbf.Create(Self);
  FNoteDB:=TDbf.Create(Self);

  FUserList:=TStringList.Create;
  FFormatList:=TStringList.Create;


  FFilePath:='';
  FFileName:='';

  FIsChanged:=false;
  FIsOpen:=false;

  FOnNew:=nil;
  FOnNewDone:=nil;
  FOnOpen:=nil;
  FOnOpenDone:=nil;
  FOnSave:=nil;
  FOnSaveDone:=nil;
  FOnSaveAs:=nil;
  FOnSaveAsDone:=nil;
  FOnClose:=nil;
  FOnCloseDone:=nil;
  FOnFirstEdit:=nil;

end;


destructor TRTFP.Destroy;
begin
  FPaperDB.Free;
  FImageDB.Free;
  FNoteDB.Free;

  FUserList.Free;
  FFormatList.Free;

  ProjectFileValue.Free;

  inherited Destroy;
end;


procedure TRTFP.SetPaths(filename:string);
var len:integer;
    stmp:string;
begin
  Self.FFileName:=ExtractFileName(filename);
  Self.FFilePath:=ExtractFilePath(filename);
  Self.FRootFolder:='.'+Self.FFileName;
  Self.FFileFullName:=Self.FFilePath+Self.FFileName;
  len:=length(Self.FRootFolder);
  if len>=5 then begin
    stmp:=Self.FRootFolder;
    delete(stmp,1,len-5);
    if stmp='.rtfp' then delete(Self.FRootFolder,len-4,5);
  end;
end;

function TRTFP.OpenDbf(dbf_name_no_ext:string;Dbf:TDbf):boolean;
var dbfpath,datfile,runfile,run_dbt,dat_dbt,name_no_ext:string;
begin
  result:=false;
  dbfpath:=Self.FFilePath+Self.FRootFolder+'\'+dbf_name_no_ext;
  name_no_ext:=ExtractFileName(dbfpath);
  dbfpath:=ExtractFilePath(dbfpath);
  datfile:=name_no_ext+'.dbf';
  runfile:=name_no_ext+'.run.dbf';
  dat_dbt:=name_no_ext+'.dbt';
  run_dbt:=name_no_ext+'.run.dbt';

  if not FileExists(dbfpath+datfile) then exit;
  TRTFP.FileCopy((dbfpath+datfile),(dbfpath+runfile),false);
  if FileExists(dbfpath+dat_dbt) then TRTFP.FileCopy((dbfpath+dat_dbt),(dbfpath+run_dbt),false);

  Dbf.FilePathFull:=dbfpath;
  Dbf.TableName:=runfile;
  try
    Dbf.Open;
  except
    exit;
  end;
  result:=true;
end;

function TRTFP.NewDbf(dbf_name_no_ext:string;Dbf:TDbf):boolean;
var dbfpath,datfile,runfile,run_dbt,dat_dbt,name_no_ext:string;
begin
  result:=false;
  dbfpath:=Self.FFilePath+Self.FRootFolder+'\'+dbf_name_no_ext;
  name_no_ext:=ExtractFileName(dbfpath);
  dbfpath:=ExtractFilePath(dbfpath);
  datfile:=name_no_ext+'.dbf';
  runfile:=name_no_ext+'.run.dbf';
  dat_dbt:=name_no_ext+'.dbt';
  run_dbt:=name_no_ext+'.run.dbt';

  Dbf.FilePathFull:=dbfpath;
  Dbf.TableName:=runfile;
  try
    Dbf.TableLevel:=7;
    Dbf.Exclusive:=true;
    Dbf.CreateTable;
    Dbf.Open;
  except
    exit;
  end;
  TRTFP.FileCopy((dbfpath+runfile),(dbfpath+datfile),false);
  if FileExists(dbfpath+run_dbt) then TRTFP.FileCopy((dbfpath+run_dbt),(dbfpath+dat_dbt),false);
  result:=true;
end;

function TRTFP.SaveDbf(dbf_name_no_ext:string;Dbf:TDbf):boolean;
var dbfpath,datfile,runfile,run_dbt,dat_dbt,name_no_ext:string;
begin
  result:=false;
  dbfpath:=Self.FFilePath+Self.FRootFolder+'\'+dbf_name_no_ext;
  name_no_ext:=ExtractFileName(dbfpath);
  dbfpath:=ExtractFilePath(dbfpath);
  datfile:=name_no_ext+'.dbf';
  runfile:=name_no_ext+'.run.dbf';
  dat_dbt:=name_no_ext+'.dbt';
  run_dbt:=name_no_ext+'.run.dbt';

  try
    if Dbf.Active then
      begin
        Dbf.Close;
        Dbf.Open;
      end;
    TRTFP.FileCopy((dbfpath+runfile),(dbfpath+datfile),false);
    if FileExists(dbfpath+run_dbt) then TRTFP.FileCopy((dbfpath+run_dbt),(dbfpath+dat_dbt),false);
  except
    exit;
  end;
  result:=true;
end;

function TRTFP.CloseDbf(dbf_name_no_ext:string;Dbf:TDbf):boolean;
var dbfpath,datfile,runfile,run_dbt,dat_dbt,name_no_ext:string;
begin
  result:=false;
  dbfpath:=Self.FFilePath+Self.FRootFolder+'\'+dbf_name_no_ext;
  name_no_ext:=ExtractFileName(dbfpath);
  dbfpath:=ExtractFilePath(dbfpath);
  datfile:=name_no_ext+'.dbf';
  runfile:=name_no_ext+'.run.dbf';
  dat_dbt:=name_no_ext+'.dbt';
  run_dbt:=name_no_ext+'.run.dbt';

  try
    if Dbf.Active then Dbf.Close;
    if not TRTFP.FileDelete((dbfpath+runfile)) then exit;
    if FileExists(dbfpath+run_dbt) then begin
      if not TRTFP.FileDelete((dbfpath+run_dbt)) then exit;
    end;
  except
    exit;
  end;
  result:=true;
end;

procedure TRTFP.NewAttrDbfs;
var attr_i:byte;
    attr_name:string;
begin
  attr_i:=0;
  repeat
    attr_name:=Tag['属性组'+Usf.zeroplus(attr_i,2)];
    if attr_name='' then break;
    with FAttrGroupList[attr_i] do begin
      Enabled:=true;
      Name:=attr_name;
      DataBase:='attr\'+Name;
      Dbf:=TDbf.Create(Self);
      case attr_i of
        0:GenAttrBasicAttribute(Dbf);
        1:GenAttrClassAttribute(Dbf);
        2:GenAttrNotesAttribute(Dbf);
        3:GenAttrMetasAttribute(Dbf);
        else assert(false,'新建工程不能出现非默认属性组。');
      end;
      NewDbf(DataBase,Dbf);
    end;
    inc(attr_i);
  until attr_i>99;
end;

procedure TRTFP.OpenAttrDbfs;
var attr_i:byte;
    attr_name:string;
begin
  attr_i:=0;
  repeat
    attr_name:=Tag['属性组'+Usf.zeroplus(attr_i,2)];
    if attr_name='' then break;
    with FAttrGroupList[attr_i] do begin
      Enabled:=true;
      Name:=attr_name;
      DataBase:='attr\'+Name;
      Dbf:=TDbf.Create(Self);
      if not OpenDbf(DataBase,Dbf) then begin
        case attr_i of
          0:GenAttrBasicAttribute(Dbf);
          1:GenAttrClassAttribute(Dbf);
          2:GenAttrNotesAttribute(Dbf);
          3:GenAttrMetasAttribute(Dbf);
          else genAttrDefaultAttribute(Dbf);
        end;
        NewDbf(DataBase,Dbf);
      end;
    end;
    inc(attr_i);
  until attr_i>99;
end;

procedure TRTFP.SaveAttrDbfs;
var attr_i:byte;
begin
  attr_i:=0;
  repeat
    with FAttrGroupList[attr_i] do begin
      //if not Enabled then break;
      if not SaveDbf(DataBase,Dbf) then assert(false,'有未保存的Attr');
    end;
    inc(attr_i);
  until (not FAttrGroupList[attr_i].Enabled) or (attr_i>99);
end;

procedure TRTFP.CloseAttrDbfs;
var attr_i:byte;
begin
  attr_i:=0;
  repeat
    with FAttrGroupList[attr_i] do begin
      //if not Enabled then break;
      if not CloseDbf(DataBase,Dbf) then assert(false,'有未关闭的Attr');
      Dbf.Free;
      Enabled:=false;
      Name:='';
      DataBase:='';
    end;
    inc(attr_i);
  until (not FAttrGroupList[attr_i].Enabled) or (attr_i>99);
end;


procedure TRTFP.GenPaperAttribute(Dbf:TDbf);
begin
  Dbf.FieldDefs.Add(_Col_OID_, ftAutoInc, 0, True);
  Dbf.FieldDefs.Add(_Col_PID_, ftString, 8, True);

  Dbf.FieldDefs.Add(_Col_Paper_Is_Backup_, ftBoolean, 0, True);//是否为文档记录   否0 是1

  //文件位置
  Dbf.FieldDefs.Add(_Col_Paper_Folder_, ftString, 8, True);
  Dbf.FieldDefs.Add(_Col_Paper_FileName_, ftString, 240, True);
  //重复检验
  Dbf.FieldDefs.Add(_Col_Paper_FileSize_, ftLargeInt, 8, True);
  Dbf.FieldDefs.Add(_Col_Paper_FileHash_, ftString, 255, True);

end;

procedure TRTFP.GenImageAttribute(Dbf:TDbf);
begin
  Dbf.FieldDefs.Add(_Col_OID_, ftAutoInc, 0, True);
  Dbf.FieldDefs.Add(_Col_IID_, ftString, 8, True);
  //重复检验
  Dbf.FieldDefs.Add(_Col_Image_FileSize_, ftLargeInt, 8, True);
  Dbf.FieldDefs.Add(_Col_Image_FileHash_, ftString, 255, True);
  //文件位置
  Dbf.FieldDefs.Add(_Col_Image_Folder_, ftString, 8, True);
  Dbf.FieldDefs.Add(_Col_Image_FileName_, ftString, 240, True);
  //基础信息
  Dbf.FieldDefs.Add(_Col_Image_Width_, ftInteger, 4, True);
  Dbf.FieldDefs.Add(_Col_Image_Height_, ftInteger, 4, True);

end;

procedure TRTFP.GenNoteAttribute(Dbf:TDbf);
begin
  Dbf.FieldDefs.Add(_Col_OID_, ftAutoInc, 0, True);
  Dbf.FieldDefs.Add(_Col_NID_, ftString, 8, True);
  //文件位置
  Dbf.FieldDefs.Add(_Col_Note_Folder_, ftString, 8, True);
  Dbf.FieldDefs.Add(_Col_Note_FileName_, ftString, 240, True);
end;

procedure TRTFP.GenAttrBasicAttribute(Dbf:TDbf);
begin
  Dbf.FieldDefs.Add(_Col_OID_, ftAutoInc, 0, True);
  Dbf.FieldDefs.Add(_Col_PID_, ftString, 8, True);

  Dbf.FieldDefs.Add(_Col_basic_RefType_, ftString, 32, false);//引用类型（期刊、会议、专利……）
  Dbf.FieldDefs.Add(_Col_basic_Title_, ftMemo, 0, false);//标题
  Dbf.FieldDefs.Add(_Col_basic_Author_, ftString, 255, false);//作者，半角逗号隔开
  Dbf.FieldDefs.Add(_Col_basic_Corresp_, ftString, 32, false);//通讯作者
  Dbf.FieldDefs.Add(_Col_basic_Source_, ftString, 64, false);//来源(期刊或出版社)
  Dbf.FieldDefs.Add(_Col_basic_PubTime_, ftDate, 0, false);//发表日期
  Dbf.FieldDefs.Add(_Col_basic_Keyword_, ftString, 255, false);//关键词，半角逗号隔开
  Dbf.FieldDefs.Add(_Col_basic_Summary_, ftMemo, 0, false);//摘要
  Dbf.FieldDefs.Add(_Col_basic_Organ_, ftMemo, 0, false);//单位，半角逗号隔开
  Dbf.FieldDefs.Add(_Col_basic_Year_, ftSmallint, 0, false);//年
  Dbf.FieldDefs.Add(_Col_basic_Volume_, ftSmallint, 0, false);//卷
  Dbf.FieldDefs.Add(_Col_basic_Issue_, ftSmallint, 0, false);//期
  Dbf.FieldDefs.Add(_Col_basic_PageCount_, ftSmallint, 0, false);//页数
  Dbf.FieldDefs.Add(_Col_basic_Page_, ftString, 64, false);//页码
  Dbf.FieldDefs.Add(_Col_basic_Fund_, ftString, 255, false);//基金
  Dbf.FieldDefs.Add(_Col_basic_Link_, ftString, 255, false);//链接
  Dbf.FieldDefs.Add(_Col_basic_doi_, ftString, 255, false);//DOI
  Dbf.FieldDefs.Add(_Col_basic_CLC_, ftString, 32, false);//中图分类号
  Dbf.FieldDefs.Add(_Col_basic_ISBN_ISSN_, ftString, 32, false);
  Dbf.FieldDefs.Add(_Col_basic_Note_, ftString, 32, false);
  Dbf.FieldDefs.Add(_Col_basic_DataProv_, ftString, 255, false);//DataProvider
  Dbf.FieldDefs.Add(_Col_basic_Has_Ext_, ftSmallint, 1, false);//是否有BasicExt数据，是1 否0
  //会议、专利、标准等就用BasicExt属性组好了

end;
procedure TRTFP.GenAttrMetasAttribute(Dbf:TDbf);
begin
  Dbf.FieldDefs.Add(_Col_OID_, ftAutoInc, 0, True);
  Dbf.FieldDefs.Add(_Col_PID_, ftString, 8, True);
  //pdf默认meta
  Dbf.FieldDefs.Add(_Col_metas_Title_, ftMemo, 0, True);
  Dbf.FieldDefs.Add(_Col_metas_Authors_, ftMemo, 0, True);
  Dbf.FieldDefs.Add(_Col_metas_Subject_, ftMemo, 8, True);
  Dbf.FieldDefs.Add(_Col_metas_KeyWord_, ftMemo, 8, True);
  Dbf.FieldDefs.Add(_Col_metas_Creator_, ftMemo, 8, True);
  Dbf.FieldDefs.Add(_Col_metas_Produce_, ftMemo, 8, True);
  Dbf.FieldDefs.Add(_Col_metas_CreDate_, ftString, 64, True);
  Dbf.FieldDefs.Add(_Col_metas_ModDate_, ftString, 64, True);
  Dbf.FieldDefs.Add(_Col_metas_Trapped_, ftMemo, 0, True);

end;

{
------------------E-Study--------------------------
DataType: 3
Title-题名: 多方共治:西安共享单车停放优化策略研究
Author-作者: 陈霈琛;董欣;
Source-来源: 共享与品质——2018中国城市规划年会论文集（14规划实施与管理）
Year-年: 2018
PubTime-出版日期: 2018-10
Keyword-关键词: 共享单车;网络爬虫数据;多方共治;停放策略;堆积程度;使用热度
Summary-摘要: 本文通过对摩拜共享单车客户端数据的抓取与分析,构建了"堆积程度"与"使用热度"两个指标来衡量共享单车的分布情况与运行状态。发现西安的共享单车具有以下特征:首先,西安城区范围内共享单车呈现"才"字型分布,西安二环以内借还车行为分布均匀,但借还车高峰区域分布在二环外侧的多个节点;其次,车辆堆积越严重,空间的边际借还数量越低;第三,车辆高使用率地区通常位于用地性质单一的区域和公交可进入性差的边缘地区;第四,在一些地段自组织地出现了位置固定的单车"准车站"。根据以上特征提出:共享单车的停放策略应综合考虑城市土地利用现状与发展规划,与公共交通设施互补发展,与城市规划、城市建设相协调。
PageCount-页码: 11
SrcDatabase-来源库: 中国会议
City-会议地点: 中国浙江杭州
Meeting-会议名称: 2018中国城市规划年会
Organ-作者机构: 西北大学城市与环境学院城乡规划系;
Link-链接: https://kns.cnki.net/kcms/detail/detail.aspx?FileName=ZHCG201811014021&DbName=CPFD2019
}

{
------------------------RefMan---------------------------
TY  - JOUR
AU  - Butts, Danielle M.
AU  - McNeil, Patricia E.
AU  - Marszewski, Michal
AU  - Lan, Esther
AU  - Galy, Tiphaine
AU  - Li, Man
AU  - Kang, Joon Sang
AU  - Ashby, David
AU  - King, Sophia
AU  - Tolbert, Sarah H.
AU  - Hu, Yongjie
AU  - Pilon, Laurent
AU  - Dunn, Bruce S.
PY  - 2021
DA  - 2021/11/16
TI  - Engineering mesoporous silica for superior optical and thermal properties
JO  - MRS Energy & Sustainability
SP  - 39
VL  - 7
IS  - 1
AB  - We report a significant advance in thermally insulating transparent materials: silica-based monoliths with controlled porosity which exhibit the transparency of windows in combination with a thermal conductivity comparable to aerogels.
SN  - 2329-2237
UR  - https://doi.org/10.1557/mre.2020.40
DO  - 10.1557/mre.2020.40
ID  - Butts2021
ER  -
}

{
---------------EndNote----------------------
%0 Journal Article
%A 蔺卿 %A 罗格平 %A 陈曦
%+ 中国科学院新疆生态与地理研究所,中国科学院新疆生态与地理研究所,中国科学院新疆生态与地理研究所 新疆 乌鲁术齐 830011 中国科学院研究生院,北京 100039 ,新疆 乌鲁术齐 830011 ,新疆 乌鲁术齐 830011
%T LUCC驱动力模型研究综述
%J 地理科学进展
%D 2005
%N 05
%K 土地利用/土地覆被变化;驱动力;模型;土地利用系统
%X 驱动力研究是土地利用变化研究中的核心问题。土地利用变化驱动力模型是分析土地利用变化原因和结果的有力工具.模型通过情景分析可为土地利用规划与决策提供依据。基于不同理论的驱动力研究方法很多.论文选取了几种国内外应用较多的LUCC驱动力模型进行综述,分析了每个模型的优缺点及适用范围.最后得出结论:1)基于过程的动态模型更适于研究复杂的土地利用系统。2)基于经验的统计模型能弥补基于过程的动态模型的不足。3)基于不同学科背景的模型进一步集成将是LUCC驱动力模型未来的发展趋势。
%P 81-89
%@ 1007-6301
%L 11-3858/P
%W CNKI
}


procedure TRTFP.GenAttrClassAttribute(Dbf:TDbf);
begin
  Dbf.FieldDefs.Add(_Col_OID_, ftAutoInc, 0, True);
  Dbf.FieldDefs.Add(_Col_PID_, ftString, 8, True);

  Dbf.FieldDefs.Add(_Col_class_Is_Read_, ftSmallint, 0, True);//是否已读         否0 是1

  Dbf.FieldDefs.Add(_Col_class_DefaultCl_, ftMemo, 8, True);//默认类型（半角逗号隔开）

end;

procedure TRTFP.GenAttrNotesAttribute(Dbf:TDbf);
begin
  Dbf.FieldDefs.Add(_Col_OID_, ftAutoInc, 0, True);
  Dbf.FieldDefs.Add(_Col_PID_, ftString, 8, True);

  Dbf.FieldDefs.Add(_Col_notes_Usage_, ftString, 50, True);//主标记（例如综述、例证、消遣、反例）
  Dbf.FieldDefs.Add(_Col_notes_Rank_, ftSmallint, 0, True);//评级1-100分，0表示未赋值
  Dbf.FieldDefs.Add(_Col_notes_Comment_, ftMemo, 0, True);//入库评价
  Dbf.FieldDefs.Add(_Col_notes_User_, ftSmallint, 0, True);//入库用户（UserID）
  Dbf.FieldDefs.Add(_Col_notes_CreateTime_, ftDateTime, 0, True);//入库日期
  Dbf.FieldDefs.Add(_Col_notes_ModifyTime_, ftDateTime, 0, True);//修改日期
  Dbf.FieldDefs.Add(_Col_notes_CheckTime_, ftDateTime, 0, True);//查看日期
  Dbf.FieldDefs.Add(_Col_notes_FurtherCmt_, ftMemo, 8, True);//更多评价（结构化文本格式，例如rubyHash）
  Dbf.FieldDefs.Add(_Col_notes_Format_, ftSmallint, 0, True);//预览显示格式（FormatID）


end;

procedure TRTFP.GenAttrDefaultAttribute(Dbf:TDbf);
begin
  Dbf.FieldDefs.Add(_Col_OID_, ftAutoInc, 0, True);
  Dbf.FieldDefs.Add(_Col_PID_, ftString, 8, True);

end;



function TRTFP.NewProjectFile(p_title,p_user:string):boolean;
var tmpProjectFile:TStringList;
    retry:boolean;
begin
  result:=false;
  tmpProjectFile:=TStringList.Create;

  tmpProjectFile.Add('属性,值');
  tmpProjectFile.Add('工程标题,'+p_title);
  tmpProjectFile.Add('创建用户,'+p_user);
  tmpProjectFile.Add('创建日期,'+TRTFP.GetDateTimeStr);
  tmpProjectFile.Add('修改日期,'+TRTFP.GetDateTimeStr);

  tmpProjectFile.Add('PDF打开方式,'+DefaultOpenExe);
  tmpProjectFile.Add('CAJ打开方式,'+DefaultOpenExe);

  tmpProjectFile.Add('属性组00,文献基础信息');
  tmpProjectFile.Add('属性组01,分类');
  tmpProjectFile.Add('属性组02,注解');
  tmpProjectFile.Add('属性组03,元数据');


  repeat
    retry:=false;
    try
      tmpProjectFile.SaveToFile(FFileFullName);
      ProjectFileValue.LoadFromCSVFile(FFileFullName);
    except
      case MessageDlg('错误','文件占用导致工程文档创建异常！',mtConfirmation,[mbRetry,mbCancel],0) of
        rnmbRetry:retry:=true;
        rnmbCancel:begin tmpProjectFile.Free;exit end;
      end;
    end;
  until not retry;

  tmpProjectFile.Free;
  result:=true;
end;

function TRTFP.OpenProjectFile:boolean;
begin
  ProjectFileValue.LoadFromCSVFile(FFileFullName);
  result:=true;
end;

function TRTFP.SaveProjectFile:boolean;
begin
  ProjectFileValue.SaveToCSVFile(FFileFullName);
  result:=true;
end;

function TRTFP.CloseProjectFile:boolean;
begin
  ProjectFileValue.Clear;
  result:=true;
end;

function TRTFP.NewUserList:boolean;
begin
  with FUserList do
    begin
      Clear;
      Add(Self.User);
      SaveToFile(Self.FFilePath+Self.FRootFolder+'\user.dat');
    end;
  result:=true;
end;

function TRTFP.OpenUserList:boolean;
begin
  result:=false;
  try with FUserList do
    begin
      Clear;
      LoadFromFile(Self.FFilePath+Self.FRootFolder+'\user.dat');
    end;
  except
    exit;
  end;
  result:=true;
end;

function TRTFP.SaveUserList:boolean;
begin
  FUserList.SaveToFile(Self.FFilePath+Self.FRootFolder+'\user.dat');
  result:=true;
end;

function TRTFP.CloseUserList:boolean;
begin
  FUserList.Clear;
  result:=true;
end;

function TRTFP.NewFormatList:boolean;
begin
  with FFormatList do
    begin
      Clear;
      //Add('default.html');//?
      SaveToFile(Self.FFilePath+Self.FRootFolder+'\format.dat');
    end;
  result:=true;
end;

function TRTFP.OpenFormatList:boolean;
begin
  result:=false;
  try with FFormatList do
    begin
      Clear;
      LoadFromFile(Self.FFilePath+Self.FRootFolder+'\format.dat');
    end;
  except
    exit;
  end;
  result:=true;
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





procedure TRTFP.New(filename:ansistring;p_title:string;p_user:string);
begin
  if FOnNew <> nil then FOnNew(Self);

  Self.SetPaths(WinCPToUTF8(filename));
  TRTFP.MakeDir(Self.FFilePath+Self.FRootFolder);
  TRTFP.MakeDir(Self.FFilePath+Self.FRootFolder+'\paper');
  TRTFP.MakeDir(Self.FFilePath+Self.FRootFolder+'\class');
  TRTFP.MakeDir(Self.FFilePath+Self.FRootFolder+'\note');
  TRTFP.MakeDir(Self.FFilePath+Self.FRootFolder+'\image');
  TRTFP.MakeDir(Self.FFilePath+Self.FRootFolder+'\format');
  TRTFP.MakeDir(Self.FFilePath+Self.FRootFolder+'\attr');

  NewProjectFile(p_title,p_user);
  NewUserList;
  NewFormatList;

  GenPaperAttribute(Self.FPaperDB);
  NewDbf('paper',Self.FPaperDB);
  GenImageAttribute(Self.FImageDB);
  NewDbf('image',Self.FImageDB);
  GenNoteAttribute(Self.FNoteDB);
  NewDbf('note',Self.FNoteDB);

  NewAttrDbfs;

  Self.FIsOpen:=true;
  if FOnNewDone <> nil then FOnNewDone(Self);
end;

Procedure TRTFP.Open(filename:ansistring);
begin
  if FOnOpen <> nil then FOnOpen(Self);

  Self.SetPaths(WinCPToUTF8(filename));
  OpenProjectFile;
  if not OpenUserList then NewUserList;
  if not OpenFormatList then NewFormatList;
  if not OpenDbf('paper',Self.FPaperDB) then NewDbf('paper',Self.FPaperDB);;
  if not OpenDbf('image',Self.FImageDB) then NewDbf('image',Self.FImageDB);;
  if not OpenDbf('note',Self.FNoteDB) then NewDbf('note',Self.FNoteDB);;

  OpenAttrDbfs;

  Self.FIsOpen:=true;
  if FOnOpenDone <> nil then FOnOpenDone(Self);
end;

procedure TRTFP.Save;
begin
  if FOnSave <> nil then FOnSave(Self);

  Self.Tag['修改日期']:=TRTFP.GetDateTimeStr;

  SaveProjectFile;
  SaveUserList;
  SaveFormatList;
  SaveDbf('paper',Self.FPaperDB);
  SaveDbf('image',Self.FImageDB);
  SaveDbf('note',Self.FNoteDB);

  SaveAttrDbfs;

  Self.FIsChanged:=false;
  if FOnSaveDone <> nil then FOnSaveDone(Self);
end;

procedure TRTFP.SaveAs(filename:ansistring);
begin
  if FOnSaveAs <> nil then FOnSaveAs(Self);

  //暂未实现

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

  CloseProjectFile;
  CloseUserList;
  CloseFormatList;
  CloseDbf('paper',Self.FPaperDB);
  CloseDbf('image',Self.FImageDB);
  CloseDbf('note',Self.FNoteDB);

  CloseAttrDbfs;

  Self.FIsOpen:=false;
  if FOnCloseDone <> nil then FOnCloseDone(Self);
  result:=true;
end;

procedure TRTFP.Change;
begin
  if (not Self.FIsChanged) and (@onFirstEdit<>nil) then Self.onFirstEdit(Self);
  Self.FIsChanged:=true;
  if FOnChange<>nil then FOnChange(Self);
end;




function TRTFP.UserID(AUser:string):integer;
var stmp:string;
begin
  result:=0;
  for stmp in FUserList do begin
    if stmp=AUser then exit;
    inc(result);
  end;
  FUserList.Add(AUser);
end;

function TRTFP.FormatID(AFormat:string):integer;
var stmp:string;
begin
  result:=0;
  for stmp in FFormatList do begin
    if stmp=AFormat then exit;
    inc(result);
  end;
  FFormatList.Add(AFormat);
end;

function TRTFP.NewPaperID:RTFP_ID;
var num:dword;
begin
  FPaperDB.Last;
  if FPaperDB.BOF then num:=0
  else num:=TRTFP.IDToNum((FPaperDB.FieldByName(_Col_PID_).AsString));
  inc(num);
  result:=TRTFP.NumToID(num);
end;

function TRTFP.NewImageID:RTFP_ID;
var num:dword;
begin
  FImageDB.Last;
  if FImageDB.BOF then num:=0
  else num:=TRTFP.IDToNum((FImageDB.FieldByName(_Col_IID_).AsString));
  inc(num);
  result:=TRTFP.NumToID(num);
end;

function TRTFP.NewNoteID:RTFP_ID;
var num:dword;
begin
  FNoteDB.Last;
  if FNoteDB.BOF then num:=0
  else num:=TRTFP.IDToNum((FNoteDB.FieldByName(_Col_NID_).AsString));
  inc(num);
  result:=TRTFP.NumToID(num);
end;






function TRTFP.AddPaper(fullfilename:string;AddPaperMethod:TAddPaperMethod=apmFullBackup):RTFP_ID;//新增一个文献到工程
var PID:RTFP_ID;
    DateDir,DateTime,TargetDir,FileName:string;
    tmpPDF:TRTFP_PDF;
    tmpAttr:TFields;
begin
  if (AddPaperMethod<>apmFullBackup) and (AddPaperMethod<>apmReference) then
    begin
      assert(false,'暂不支持apmFullBackup和apmReference以外的方式。');
      exit;
    end;

  tmpPDF:=TRTFP_PDF.Create(nil);
  tmpPDF.LoadPdf(fullfilename);

  DateDir:=TRTFP.GetDateDir;
  DateTime:=TRTFP.GetDateTimeStr;
  FileName:=ExtractFileName(fullfilename);

  PID:=NewPaperID;
  //FPaperDB.Last;//此时游标已经在Last位置
  with FPaperDB do begin
    Insert;
    Fields[_Num_Paper_PID_].AsString:=PID;
    {
    if AddPaperMethod=apmFullBackup then Fields[_Num_Paper_Is_Backup_].AsInteger:=1
      else Fields[_Num_Paper_Is_Backup_].AsInteger:=0;
    }
    Fields[_Num_Paper_Is_Backup_].AsBoolean:=(AddPaperMethod=apmFullBackup);

    Fields[_Num_Paper_Folder_].AsString:=DateDir;
    Fields[_Num_Paper_FileName_].AsString:=FileName;
    Fields[_Num_Paper_FileSize_].AsLargeInt:=tmpPDF.Size;
    Fields[_Num_Paper_FileHash_].AsString:=tmpPDF.Hash;
    Post;
  end;

  //0-文献基本信息要专门的算法
  tmpAttr:=FindAttrRecord(PID,0);
  if tmpAttr = nil then tmpAttr:=NewAttrRecord(PID,0);
  tmpAttr.FieldByName(_Col_basic_Has_Ext_).AsInteger:=0;
  PostAttrRecord(0);

  //1-分类
  tmpAttr:=FindAttrRecord(PID,1);
  if tmpAttr = nil then tmpAttr:=NewAttrRecord(PID,1);
  tmpAttr.FieldByName(_Col_class_Is_Read_).AsInteger:=0;
  PostAttrRecord(1);

  //2-注解
  tmpAttr:=FindAttrRecord(PID,2);
  if tmpAttr = nil then tmpAttr:=NewAttrRecord(PID,2);
  //这里之后要考虑不是pdf或者pdf读取错误的情况
  tmpAttr.FieldByName(_Col_notes_User_).AsInteger:=0;
  //tmpAttr.FieldByName(_Col_notes_CreateTime_).AsString:=DateTime;
  tmpAttr.FieldByName(_Col_notes_CreateTime_).AsDateTime:=Now;
  tmpAttr.FieldByName(_Col_notes_ModifyTime_).AsDateTime:=Now;
  tmpAttr.FieldByName(_Col_notes_CheckTime_).AsDateTime:=Now;
  PostAttrRecord(2);

  //3-元数据
  tmpAttr:=FindAttrRecord(PID,3);
  if tmpAttr = nil then tmpAttr:=NewAttrRecord(PID,3);
  //这里之后要考虑不是pdf或者pdf读取错误的情况
  tmpAttr.FieldByName(_Col_metas_Title_).AsString:=tmpPDF.Meta.pFields['DocInfo:Title']^;
  tmpAttr.FieldByName(_Col_metas_Authors_).AsString:=tmpPDF.Meta.pFields['DocInfo:Author']^;
  tmpAttr.FieldByName(_Col_metas_Subject_).AsString:=tmpPDF.Meta.pFields['DocInfo:Subject']^;
  tmpAttr.FieldByName(_Col_metas_Keyword_).AsString:=tmpPDF.Meta.pFields['DocInfo:Keywords']^;
  tmpAttr.FieldByName(_Col_metas_Creator_).AsString:=tmpPDF.Meta.pFields['DocInfo:Creator']^;
  tmpAttr.FieldByName(_Col_metas_Produce_).AsString:=tmpPDF.Meta.pFields['DocInfo:Producer']^;
  tmpAttr.FieldByName(_Col_metas_CreDate_).AsString:=tmpPDF.Meta.pFields['DocInfo:CreationDate']^;
  tmpAttr.FieldByName(_Col_metas_ModDate_).AsString:=tmpPDF.Meta.pFields['DocInfo:ModDate']^;
  PostAttrRecord(3);

  if AddPaperMethod=apmFullBackup then begin
    TargetDir:=FFilePath+FRootFolder+'\paper\'+DateDir;
    ForceDirectories(TargetDir);
    tmpPDF.CopyTo(TargetDir+'\'+FileName);//尚未加入长度检验
  end;

  Change;


  tmpPDF.ClosePdf;
  tmpPDF.Free;

end;

function TRTFP.FindPaper(fullfilename:string):RTFP_ID;//查找具体文件在工程中的PID，未找到返回000000
var PID:RTFP_ID;
    FHash,FName:string;
    FileStream,CpStr:TMemoryStream;
    retry,cps:boolean;
begin
  FHash:='';
  PID:='';
  cps:=false;

  FileStream:=TMemoryStream.Create;
  FileStream.LoadFromFile(fullfilename);



  with FPaperDB do begin
    First;
    repeat
      if Fields[_Num_Paper_FileSize_].AsLongint = FileStream.Size then
        begin
          if FHash='' then FHash:=TRTFP.FileHash(FileStream);
          if Fields[_Num_Paper_FileHash_].AsString = FHash then
            begin
              if not cps then begin CpStr:=TMemoryStream.Create;cps:=true end;
              FName:=FFilePath+FRootFolder+'\paper\'+Fields[_Num_Paper_Folder_].AsString+'\'+Fields[_Num_Paper_FileName_].AsString;
              retry:=false;
              repeat try
                CpStr.LoadFromFile(FName);
                if CompareMem(FileStream.Memory,CpStr.Memory,FileStream.Size) then PID:=Fields[_Num_Paper_PID_].AsString;
              except
                case MessageDlg('错误','疑似相同文件被占用！',mtError,[mbRetry,mbIgnore],0) of
                  rnmbRetry:retry:=true;
                  rnmbIgnore:;
                end;
              end until not retry;
            end;
        end;
      Next;
    until EOF or (PID<>'');


  end;

  if cps then CpStr.Free;

  if PID='' then result:='000000' else result:=PID;

  FileStream.Free;
end;

procedure TRTFP.DeletePaper(PID:RTFP_ID);//移除指定PID的文献
begin

end;

procedure TRTFP.OpenPaperAsPDF(PID:RTFP_ID);
var filename,exename:string;
begin
  with FPaperDB do begin
    First;
    while not EOF do
      begin
        if Fields[_Num_Paper_PID_].AsString=PID then break;
        Next;
      end;
    if EOF then begin assert(false,'未找到PID');exit;end;
    if Fields[_Num_Paper_Is_Backup_].AsBoolean then begin
      exename:=OpenPdfExe;
      filename:=Utf8ToWinCP(FFilePath+FRootFolder+'\paper\'
        +Fields[_Num_Paper_Folder_].AsString+'\'
        +Fields[_Num_Paper_FileName_].AsString);
      if exename='' then
        ShellExecute(0,'open',pchar(filename),'','',SW_NORMAL)
      else
        ShellExecute(0,'open',pchar(exename),pchar(filename),'',SW_NORMAL);
    end else
      ShowMessage('非备份文献节点不能通过此方法打开！');
  end;
end;

procedure TRTFP.OpenPaperAsCAJ(PID:RTFP_ID);
var filename,exename:string;
begin
  with FPaperDB do begin
    First;
    while not EOF do
      begin
        if Fields[_Num_Paper_PID_].AsString=PID then break;
        Next;
      end;
    if EOF then begin assert(false,'未找到PID');exit;end;
    if Fields[_Num_Paper_Is_Backup_].AsBoolean then begin
      exename:=OpenCajExe;
      filename:=Utf8ToWinCP(FFilePath+FRootFolder+'\paper\'
        +Fields[_Num_Paper_Folder_].AsString+'\'
        +Fields[_Num_Paper_FileName_].AsString);
      if exename='' then
        ShellExecute(0,'open',pchar(filename),'','',SW_NORMAL)
      else
        ShellExecute(0,'open',pchar(exename),pchar(filename),'',SW_NORMAL);
    end else
      ShowMessage('非备份文献节点不能通过此方法打开！');
  end;
end;

function TRTFP.EditAttrField(PID:RTFP_ID;AttrNo:byte;FieldName:string;FailOption:TAttrExtend;value:string):boolean;
var tmpFieldDef:TFieldDef;
    tmpFields:TFields;
begin
  result:=false;
  tmpFieldDef:=ExistAttrField(FieldName,AttrNo);
  if tmpFieldDef=nil then
    begin
      if aeFailIfNoField in FailOption then exit
      else tmpFieldDef:=AddAttrField(FieldName,AttrNo,ftMemo,0);
    end;
  //tmpFieldDef.ID;
  tmpFields:=FindAttrRecord(PID,AttrNo);
  if tmpFields=nil then
    begin
      if aeFailIfNoPID in FailOption then exit
      else tmpFields:=NewAttrRecord(PID,AttrNo);
    end;

  case tmpFieldDef.DataType of
    ftString,ftMemo:{tmpFields[tmpFieldDef.ID]}tmpFields.FieldByName(FieldName).AsString:=value;
    ftBoolean:tmpFields.FieldByName(FieldName).AsBoolean:=(lowercase(value) = 'true') or (lowercase(value) = 't');
    ftFloat:tmpFields.FieldByName(FieldName).AsFloat:=StrToFloat(value);
    ftInteger:tmpFields.FieldByName(FieldName).AsInteger:=StrToInt(value);
    ftLargeint:tmpFields.FieldByName(FieldName).AsLargeInt:=StrToInt(value);
    ftSmallint,ftWord:tmpFields.FieldByName(FieldName).AsLongint:=StrToInt(value);
    ftWideString,ftFixedWideChar,ftWideMemo:tmpFields.FieldByName(FieldName).AsWideString:=widestring(value);
    else assert(false,'ftType未预设。');
  end;

  PostAttrRecord(AttrNo);
  ReNewModifyTime(PID);
  result:=true;
end;

function TRTFP.ReadAttrField(PID:RTFP_ID;AttrNo:byte;FieldName:string;FailOption:TAttrExtend;var value:string):boolean;
var tmpFieldDef:TFieldDef;
    tmpFields:TFields;
begin
  result:=false;
  tmpFieldDef:=ExistAttrField(FieldName,AttrNo);
  if tmpFieldDef=nil then
    begin
      if aeFailIfNoField in FailOption then exit
      else tmpFieldDef:=AddAttrField(FieldName,AttrNo,ftMemo,0);
    end;
  //tmpFieldDef.ID;
  tmpFields:=FindAttrRecord(PID,AttrNo);
  if tmpFields=nil then
    begin
      if aeFailIfNoPID in FailOption then exit
      else tmpFields:=NewAttrRecord(PID,AttrNo);
    end;

  case tmpFieldDef.DataType of
    ftString,ftMemo:value:={tmpFields[tmpFieldDef.ID]}tmpFields.FieldByName(FieldName).AsString;
    ftBoolean:if tmpFields.FieldByName(FieldName).AsBoolean then value:='true' else value:='false';
    ftFloat:value:=FormatFloat('0.00',tmpFields.FieldByName(FieldName).AsFloat);
    ftInteger:value:=IntToStr(tmpFields.FieldByName(FieldName).AsInteger);
    ftLargeint:value:=IntToStr(tmpFields.FieldByName(FieldName).AsLargeInt);
    ftSmallint,ftWord:value:=IntToStr(tmpFields.FieldByName(FieldName).AsLongint);
    ftWideString,ftFixedWideChar,ftWideMemo:value:=tmpFields.FieldByName(FieldName).AsWideString;
    else assert(false,'ftType未预设。');
  end;
  ReNewCheckTime(PID);
  result:=false;
end;


{
procedure TRTFP.EditPaperData(PID:RTFP_ID;col_name,value:string);//修改指定PID文献的属性
begin

end;

function TRTFP.ReadPaperData(PID:RTFP_ID;col_name:string):string;//读取指定PID文献的属性
begin

end;
}

procedure TRTFP.ReNewCreateTime(PID:RTFP_ID);
begin
  FindAttrRecord(PID,2).FieldByName(_Col_notes_CreateTime_).AsDateTime:=Now;
  PostAttrRecord(2);
end;

procedure TRTFP.ReNewModifyTime(PID:RTFP_ID);
begin
  FindAttrRecord(PID,2).FieldByName(_Col_notes_ModifyTime_).AsDateTime:=Now;
  PostAttrRecord(2);
end;

procedure TRTFP.ReNewCheckTime(PID:RTFP_ID);
begin
  FindAttrRecord(PID,2).FieldByName(_Col_notes_CheckTime_).AsDateTime:=Now;
  PostAttrRecord(2);
end;

procedure TRTFP.ReNewModifyTimeWithoutChange(PID:RTFP_ID);
begin
  FindAttrRecord(PID,2).FieldByName(_Col_notes_ModifyTime_).AsDateTime:=Now;
  FAttrGroupList[2].Dbf.Post;
end;

procedure TRTFP.ReNewCheckTimeWithoutChange(PID:RTFP_ID);
begin
  FindAttrRecord(PID,2).FieldByName(_Col_notes_CheckTime_).AsDateTime:=Now;
  FAttrGroupList[2].Dbf.Post;
end;

function TRTFP.FindAttrRecord(PID:RTFP_ID;AttrNo:byte):TFields;
begin
  result:=nil;
  with FAttrGroupList[AttrNo] do begin
    Dbf.First;
    while not Dbf.EOF do begin
      if Dbf.Fields[_Num_Attr_PID_].AsString=PID then begin result:=Dbf.Fields;Dbf.Edit;exit end;
      Dbf.Next;
    end;
  end;
end;

function TRTFP.NewAttrRecord(PID:RTFP_ID;AttrNo:byte):TFields;
begin
  result:=nil;
  with FAttrGroupList[AttrNo] do begin
    Dbf.Last;
    Dbf.Insert;
    Dbf.Fields[_Num_Attr_PID_].AsString:=PID;
    result:=Dbf.Fields;
    Dbf.Post;
    Dbf.Edit;
  end;
  Change;
end;

function TRTFP.DeleteAttrRecord(PID:RTFP_ID;AttrNo:byte):boolean;
begin
  result:=false;
  with FAttrGroupList[AttrNo] do begin
    Dbf.First;
    while not Dbf.EOF do begin
      if Dbf.Fields[_Num_Attr_PID_].AsString=PID then begin Dbf.Delete;Change;result:=true;exit end;
      Dbf.Next;
    end;
  end;
end;

function TRTFP.PostAttrRecord(AttrNo:byte):boolean;
begin
  //result:=false;
  FAttrGroupList[AttrNo].Dbf.Post;
  Change;
  result:=true;
end;

function TRTFP.CancelAttrRecord(AttrNo:byte):boolean;
begin
  //result:=false;
  FAttrGroupList[AttrNo].Dbf.Cancel;
  result:=true;
end;

function TRTFP.ExistAttrField(FieldName:string;AttrNo:byte):TFieldDef;
begin
  result:=FAttrGroupList[AttrNo].Dbf.FieldDefs.Find(FieldName);
end;

function TRTFP.AddAttrField(FieldName:string;AttrNo:byte;FieldType:TFieldType;FieldSize:word):TFieldDef;
begin
  result:=nil;
  FAttrGroupList[AttrNo].Dbf.FieldDefs.Add(FieldName,FieldType,FieldSize);
  Change;
  result:=FAttrGroupList[AttrNo].Dbf.FieldDefs[FAttrGroupList[AttrNo].Dbf.FieldDefs.Count-1];
end;

function TRTFP.DeleteAttrField(FieldName:string;AttrNo:byte):boolean;
var tmp:integer;
begin
  result:=false;
  tmp:=0;
  with FAttrGroupList[AttrNo].Dbf do begin
    repeat
      if FieldDefs[tmp].Name=FieldName then break;
      inc(tmp);
    until tmp>=FieldDefs.Count;
    if tmp<FieldDefs.Count then FieldDefs.Delete(tmp);
  end;
  Change;
  result:=true;
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


{
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
}

procedure TRTFP.ProjectPropertiesValidate(AValueListEditor:TValueListEditor);
var attrNo:byte;
begin
  AValueListEditor.Values['工程标题']:=Self.Title;
  AValueListEditor.Values['创建用户']:=Self.User;

  AValueListEditor.Values['创建日期']:=Self.Tag['创建日期'];
  AValueListEditor.Values['修改日期']:=Self.Tag['修改日期'];

  AValueListEditor.Values['PDF打开方式']:=Self.Tag['PDF打开方式'];
  AValueListEditor.Values['CAJ打开方式']:=Self.Tag['CAJ打开方式'];

  attrNo:=0;
  repeat
    AValueListEditor.Values['属性组'+Usf.zeroplus(attrNo,2)]:=FAttrGroupList[AttrNo].Name;
    inc(attrNo);
  until (not FAttrGroupList[AttrNo].Enabled) or (attrNo>99);

end;

procedure TRTFP.ProjectPropertiesDataPost(AValueListEditor:TValueListEditor);
begin
  Self.Title:=AValueListEditor.Values['工程标题'];
  Self.User:=AValueListEditor.Values['创建用户'];

  Self.Tag['PDF打开方式']:=AValueListEditor.Values['PDF打开方式'];
  Self.Tag['CAJ打开方式']:=AValueListEditor.Values['CAJ打开方式'];

  //其他属性为只读

end;

procedure TRTFP.TableValidate(ADataSet:TMemDataSet;table_enabled:TablesUse);
var tmpDbf:TDbf;
    tmpFieldDef:TFieldDef;
    PID:RTFP_ID;
    pi,pj,pcol,max_attr,ori_max:integer;
    fields_numbers:array[0..9999] of record
      AttrNo:byte;
      Column:byte;
    end;//记录总表字段与分表字段的列号关系
    attr_range:array[0..99] of record
      min,max:integer;
    end;//记录分表字段在总表中的范围

begin
  ADataSet.Clear;
  tmpDbf:=FPaperDB;
  for pcol:=0 to tmpDbf.FieldDefs.Count-1 do
    begin
      tmpFieldDef:=tmpDbf.FieldDefs[pcol];
      ADataSet.FieldDefs.Add(tmpFieldDef.Name,tmpFieldDef.DataType,tmpFieldDef.Size);
      fields_numbers[pcol].AttrNo:=255;//PaperDB 用 255 表示
      fields_numbers[pcol].Column:=pcol;
    end;
  ori_max:=pcol;
  inc(pcol);
  pj:=0;
  repeat
    if not (pj in table_enabled) then begin inc(pj);continue end;
    tmpDbf:=FAttrGroupList[pj].Dbf;
    attr_range[pj].min:=pcol;
    for pi:=0 to tmpDbf.FieldDefs.Count-1 do
      begin
        tmpFieldDef:=tmpDbf.FieldDefs[pi];
        if (tmpFieldDef.Name<>'OID') and (tmpFieldDef.Name<>'PID') then
          begin
            ADataSet.FieldDefs.Add(IntToStr(pj)+tmpFieldDef.Name,tmpFieldDef.DataType,tmpFieldDef.Size);
            fields_numbers[pcol].AttrNo:=pj;
            fields_numbers[pcol].Column:=pi;
            attr_range[pj].max:=pcol;
            inc(pcol);
          end;
      end;
    inc(pj);
    //if pj>99 then break;
  until (not FAttrGroupList[pj].Enabled) or (pj>99);
  if pj>99 then max_attr:=99 else max_attr:= pj-1;
  ADataSet.CreateTable;
  ADataSet.Open;
  ADataSet.Last;
  tmpDbf:=FPaperDB;
  tmpDbf.First;
  if not tmpDbf.EOF then repeat
    ADataSet.Append;
    for pi:=0 to ori_max do
      begin
        with ADataSet.Fields[pi] do case DataType of
          ftString,ftMemo,ftWideString,ftFixedWideChar,ftWideMemo{,ftFmtMemo,ftFixedChar}:ADataSet.Fields[pi].AsString:=tmpDbf.Fields[pi].AsString;
          ftBoolean:ADataSet.Fields[pi].AsBoolean:=tmpDbf.Fields[pi].AsBoolean;
          ftFloat:ADataSet.Fields[pi].AsFloat:=tmpDbf.Fields[pi].AsFloat;
          ftInteger,ftLargeint,ftSmallint,ftWord:ADataSet.Fields[pi].AsLargeInt:=tmpDbf.Fields[pi].AsLargeInt;
          ftDateTime,ftDate,ftTime:ADataSet.Fields[pi].AsDateTime:=tmpDbf.Fields[pi].AsDateTime;
          else assert(false,'ADataSet.Fields[pi].DataType未预设。');
        end;
      end;
    tmpDbf.Next;
  until tmpDbf.EOF;

  for pj:=0 to max_attr do
    begin
      if pj in table_enabled then BEGIN
        tmpDbf:=FAttrGroupList[pj].Dbf;
        tmpDbf.First;

        if not tmpDbf.EOF then repeat
          PID:=tmpDbf.Fields[_Num_Attr_PID_].AsString;
          ADataSet.First;
          if not ADataSet.EOF then repeat
            ADataSet.Next;
            if ADataSet.Fields[_Num_Attr_PID_].AsString=PID then break;
          until ADataSet.EOF;
          if not ADataSet.EOF then begin
            ADataSet.Edit;
            for pi:=attr_range[pj].min to attr_range[pj].max do begin
              case ADataSet.Fields[pi].DataType of
                ftString,ftMemo,ftWideString,ftFixedWideChar,ftWideMemo{,ftFmtMemo,ftFixedChar}:
                  ADataSet.Fields[pi].AsString:=tmpDbf.Fields[fields_numbers[pi].Column].AsString;
                ftBoolean:
                  ADataSet.Fields[pi].AsBoolean:=tmpDbf.Fields[fields_numbers[pi].Column].AsBoolean;
                ftFloat:
                  ADataSet.Fields[pi].AsFloat:=tmpDbf.Fields[fields_numbers[pi].Column].AsFloat;
                ftInteger,ftLargeint,ftSmallint,ftWord:
                  ADataSet.Fields[pi].AsLargeInt:=tmpDbf.Fields[fields_numbers[pi].Column].AsLargeInt;
                ftDateTime,ftDate,ftTime:
                  ADataSet.Fields[pi].AsDateTime:=tmpDbf.Fields[fields_numbers[pi].Column].AsDateTime
                else assert(false,'ADataSet.Fields[pi].DataType未预设。');
              end;
            end;
            ADataSet.Post;
          end else assert(false,'分表有主表没有的PID');
          tmpDbf.Next;
        until tmpDbf.EOF;
      END;
    end;
end;

function DBConvertToString(inp:boolean):string;
begin
  if inp then result:='true'
  else result:='false';
end;
function DBConvertToString(inp:int64):string;
begin
  result:=IntToStr(inp);
end;
function DBConvertToString(inp:extended):string;
begin
  result:=FormatFloat('0.00000',inp);
end;
function DBConvertToString(inp:TDateTime):string;
begin
  result:=FormatDateTime('yyyy-mm-dd hh:mm:ss',inp);
end;


procedure TRTFP.NodeViewValidate(PID:RTFP_ID;AValueListEditor:TValueListEditor);
var attrNo,defNo:byte;
    tmpFields:TFields;
    tmpDefs:TFieldDefs;
    AttrName:string;
begin
  attrNo:=0;
  AValueListEditor.Values['PID']:=PID;
  repeat
    AttrName:=FAttrGroupList[attrNo].Name;
    tmpFields:=FindAttrRecord(PID,attrNo);
    if tmpFields<>nil then begin
      tmpDefs:=FAttrGroupList[attrNo].Dbf.FieldDefs;
      for defNo:=0 to tmpDefs.Count-1 do
        begin
          if (tmpDefs[defNo].Name<>'PID') and (tmpDefs[defNo].Name<>'OID') then case tmpDefs[defNo].DataType of
            ftString,ftMemo,ftWideString,ftFixedWideChar,ftWideMemo{,ftFmtMemo,ftFixedChar}:
              AValueListEditor.Values[AttrName+'#'+tmpDefs[defNo].Name]:=tmpFields[defNo].AsString;
            ftBoolean:
              AValueListEditor.Values[AttrName+'#'+tmpDefs[defNo].Name]:=DBConvertToString(tmpFields[defNo].AsBoolean);
            ftFloat:
              AValueListEditor.Values[AttrName+'#'+tmpDefs[defNo].Name]:=DBConvertToString(tmpFields[defNo].AsFloat);
            ftInteger,ftLargeint,ftSmallint,ftWord:
              AValueListEditor.Values[AttrName+'#'+tmpDefs[defNo].Name]:=DBConvertToString(tmpFields[defNo].AsLargeInt);
            ftDateTime,ftDate,ftTime:
              AValueListEditor.Values[AttrName+'#'+tmpDefs[defNo].Name]:=DBConvertToString(tmpFields[defNo].AsDateTime);
            else assert(false,'ADataSet.Fields[pi].DataType未预设。');
          end;
        end;
    end;
    inc(attrNo);
  until (not FAttrGroupList[attrNo].Enabled) or (attrNo>99);
  ReNewCheckTimeWithoutChange(PID);//如果Change会导致Validate更新，这个需要重构以下UI逻辑，暂时先不管
end;

procedure TRTFP.NodeViewDataPost(PID:RTFP_ID;AValueListEditor:TValueListEditor);
var ColName,AttrName,FieldName:string;
    pcol,posi,len:integer;
begin
  for pcol:=1 to AValueListEditor.RowCount-1 do
    begin
      ColName:=AValueListEditor.Keys[pcol];
      if ColName<>'PID' then begin
        AttrName:=AValueListEditor.Keys[pcol];
        FieldName:=AttrName;
        len:=Length(AttrName);
        posi:=Pos('#',AttrName);
        delete(AttrName,posi,len);
        delete(FieldName,1,posi);
        EditAttrField(PID,AttrsByName[AttrName],FieldName,[aeFailIfNoPID,aeFailIfNoField],AValueListEditor.Values[ColName]);
        //连续调用这个太费时间，之后修改
      end;
    end;
end;



procedure TRTFP.SetUser(str:string);
begin
  if ProjectFileValue.Values['创建用户']<>str then
    begin
      ProjectFileValue.Values['创建用户']:=str;
      Change;
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
      Change;
    end;
end;

function TRTFP.GetUser:string;
begin
  result:=ProjectFileValue.Values['创建用户'];
end;



procedure TRTFP.SetTag(index:string;str:string);
begin
  if ProjectFileValue.Values[index]<>str then
    begin
      ProjectFileValue.Values[index]:=str;
      Change;
    end;
end;

function TRTFP.GetTag(index:string):string;
begin
  result:=ProjectFileValue.Values[index];
end;

function TRTFP.GetAttrsDB(index:byte):TDbf;
begin
  result:=nil;
  if index>99 then exit;
  if FAttrGroupList[index].Enabled then result:=FAttrGroupList[index].Dbf;
end;

function TRTFP.GetAttrsName(index:byte):String;
begin
  result:='';
  if index>99 then exit;
  if FAttrGroupList[index].Enabled then result:=FAttrGroupList[index].Name;
end;

function TRTFP.GetAttrsByName(index:string):byte;
begin
  result:=0;
  repeat
    if FAttrGroupList[result].Name = index then exit;
    inc(result);
  until (not FAttrGroupList[result].Enabled) or (result=0);
  result:=255;
end;

function TRTFP.GetOpenPdfExe:ansistring;
begin
  result:=Tag['PDF打开方式'];
  if result='' then
    begin
      result:=DefaultOpenExe;
      ProjectFileValue.Values['PDF打开方式']:=result;
    end;
end;

function TRTFP.GetOpenCajExe:ansistring;
begin
  result:=Tag['CAJ打开方式'];
  if result='' then
    begin
      result:=DefaultOpenExe;
      ProjectFileValue.Values['CAJ打开方式']:=result;
    end;
end;

class function TRTFP.NumToID(Num:dword):RTFP_ID;
begin
  result:='';
  repeat
      result:=RTFP_ID_ORDER[Num mod 64 +1]+result;
      Num:=Num shr 6;
  until {(Num=0) or }(length(result)=6);
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

class function TRTFP.GetDateTimeStr:string;
begin
  result:=FormatDateTime('yyyy-mm-dd hh:nn:ss',Now());
end;

class function TRTFP.GetDateDir:string;
begin
  result:=FormatDateTime('yyyymm',Now());
end;

class function TRTFP.CanBuildName(projname:ansistring):boolean;
var i,len:integer;
begin
  result:=false;
  len:=length(projname);
  if len=0 then exit;
  if len>50 then exit;
  i:=0;
  while i<=len do
    begin
      if pos(projname[i],'/\:*"<>|?')>0 then exit;
      inc(i);
    end;
  result:=true;
end;

class function TRTFP.CanBuildPath(pathname:ansistring):boolean;
begin
  result:=false;
  if DirectoryExists(WinCPToUTF8(pathname)) then exit;
  result:=true;
end;

class function TRTFP.CanBuildPLen(pathname:ansistring):boolean;
begin
  result:=false;
  if length(pathname)>150 then exit;
  result:=true;
end;

class function TRTFP.CanBuildFile(fullname:ansistring):boolean;
begin
  if FileExists(WinCPToUTF8(fullname)) then result:=false
  else result:=true;
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

class function TRTFP.FileHash(AFileStream:TStream):string;
var index:byte;
    byt:byte;
    arr:array [0..238] of byte;
    skip_byte:byte;
begin
  for index:=0 to 238 do arr[index]:=0;
  index:=0;
  with AFileStream do
    begin

      if Size<$200000 then skip_byte:=1
      else if Size<$400000 then skip_byte:=2
      else if Size<$800000 then skip_byte:=4
      else if Size<$1000000 then skip_byte:=8
      else if Size<$2000000 then skip_byte:=16
      else if Size<$4000000 then skip_byte:=32
      else if Size<$8000000 then skip_byte:=64
      else skip_byte:=128;

      Position:=0;
      while Position<Size do
        begin
          byt:=ReadByte;
          arr[index]:=arr[index]+byt;
          inc(index);
          if index>238 then index:=0;
          Seek(byt mod skip_byte,soFromCurrent);
        end;
    end;
  result:='';
  for index:=0 to 238 do
    begin
      arr[index]:=arr[index] and $3f;
      if (arr[index] and $30 = $30) then arr[index]:=arr[index] and $bf else
      arr[index]:=arr[index] or $40;
      result:=result+chr(arr[index]);
    end;
end;

class function TRTFP.FileCopy(source,dest:string;bFailIfExist:boolean):boolean;
begin
  result:=CopyFile(pchar(UTF8ToWinCP(source)),pchar(UTF8ToWinCP(dest)),bFailIfExist);
end;

class function TRTFP.FileDelete(source:string):boolean;
begin
  result:=DeleteFile(pchar(UTF8ToWinCP(source)));
end;

class function TRTFP.MakeDir(filename:string):boolean;
begin
  ForceDirectories(filename);
end;

{
initialization
  CurrentRTFP:=TRTFP.Create(FormDesktop);
  FormDesktop.EventLink(CurrentRTFP);


finalization
  CurrentRTFP.Free;
}
end.

