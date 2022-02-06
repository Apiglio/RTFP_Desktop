//ImportFiles的UI语言改进 (partially solved)
//已读标记改成ftBoolean (solved)
//FmtCmt的覆盖提交保存提醒
//引用PDF里的图片
//字段选项化，进度表可以是checkboxlist的形式




//{$define insert}
{$define test}

unit RTFP_definition;

{$mode objfpc}{$H+}
{$inline on}


interface

uses
  Classes, SysUtils, Dialogs, ValEdit, Windows, LazUTF8, StdCtrls, ComCtrls,
  {$ifndef insert}
  Apiglio_Useful, auf_ram_var, rtfp_pdfobj, rtfp_files, rtfp_class, rtfp_field,
  rtfp_constants,
  //AufScript_Frame,
  {$endif}
  db, dbf, dbf_fields, sqldb, memds;

  //{$I pdfium\fpdfview.h}


type

  RTFP_ID=string;//六位64进制数

  TAttrExtendUnit = (aeFailIfNoPID,aeFailIfNoField);
  TAttrExtend = set of TAttrExtendUnit;
  TablesUse = set of byte;
  TAddPaperMethod = (apmFullBackup,apmAddress,apmWebsite,apmReference);
  //几种文档入库方式: 复制备份/本地链接/网址链接/数据入库

  TRTFP_Auf=class(TAuf)
  public
    RTFP:TObject;
  end;

  TRTFP = class(TComponent)
  public
    ProjectFileValue:TValueListEditor;//加载 #{project_name}.rtfp 到内存(CSV)
  private
    FPaperDB,FImageDB,FNotesDB:TDbf;
    FUserList,FFormatList:TStringList;

    FKlassList:TKlassList;
    FFileList:TRTFP_FileList;
    FFieldList:TAttrsGroupList;


  private
    FFilePath:string;//完整路径
    FFileName:string;//文件名
    FFileFullName:string;//完整文件名
    FRootFolder:string;//根文件夹（不带拓展名的文件名）

    FIsOpen:boolean;
    FIsChanged:boolean;
    FIsUpdating:boolean;//true时不触发onChange

  protected
    procedure SetUser(str:string);
    function GetUser:string;
    procedure SetTitle(str:string);
    function GetTitle:string;


    procedure SetTag(index:string;str:string);
    function GetTag(index:string):string;


    function GetAttrFieldDataTypeS(attrNa,fieldNa:string):TFieldType;


    function GetOpenPdfExe:ansistring;
    function GetOpenCajExe:ansistring;


  public
    //工程基本属性
    property User:string read GetUser write SetUser;
    property Title:string read GetTitle write SetTitle;
    property OpenPdfExe:ansistring read GetOpenPdfExe;
    property OpenCajExe:ansistring read GetOpenCajExe;

    property Tag[index:string]:string read GetTag write SetTag;

    //工程运行状态
    property IsOpen:boolean read FIsOpen;
    property IsChanged:boolean read FIsChanged;

    property PaperDB:TDbf read FPaperDB;
    property ImageDB:TDbf read FImageDB;
    property NotesDB:TDbf read FNotesDB;

    property AttrFieldDataTypeS[attrNa,fieldNa:string]:TFieldType read GetAttrFieldDataTypeS;



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

    procedure GenAttrMetasAttribute(Dbf:TDbf);inline;
    procedure GenAttrBasicAttribute(Dbf:TDbf);inline;
    procedure GenAttrClassAttribute(Dbf:TDbf);inline;
    procedure GenAttrNotesAttribute(Dbf:TDbf);inline;
    procedure GenAttrDefaultAttribute(Dbf:TDbf);inline;
    procedure GenAttrRelatAttribute(Dbf:TDbf);inline;



    function OpenDbf(dbf_name_no_ext:string;Dbf:TDbf):boolean;
    function NewDbf(dbf_name_no_ext:string;Dbf:TDbf):boolean;
    function SaveDbf(dbf_name_no_ext:string;Dbf:TDbf):boolean;
    function CloseDbf(dbf_name_no_ext:string;Dbf:TDbf):boolean;
    function DeleteDbf(dbf_name_no_ext:string;Dbf:TDbf):boolean;


    //ATTRS

    function AddAttrs(AName:string):TAttrsGroup;
    function FindAttrs(AName:string):TAttrsGroup;
    procedure DeleteAttrs(AName:string);

    function AddField(AName:string;AAttrsName:string;AType:TFieldType;ASize:word):TAttrsField;
    function FindField(AName:string;AAttrsName:string):TAttrsField;
    procedure DeleteField(AName:string;AAttrsName:string);

    procedure LoadAttrs;//包含了原先的New
    procedure SaveAttrs;
    procedure CloseAttrs;
    procedure CheckAttrs;unimplemented;//用于存档版本检验，追加和修改字段

    //Klass

    function AddKlass(klassname:string;pathname:string='\'):TKlass;
    function FindKlass(klassname:string):TKlass;
    procedure DeleteKlass(klassname:string);

    procedure LoadKlass;//包含了原先的New
    procedure SaveKlass;
    procedure CloseKlass;

  public //工程打开关闭操作
    procedure New(filename:ansistring;p_title:string;p_user:string);
    Procedure Open(filename:ansistring);
    procedure Save;
    procedure SaveAs(filename:ansistring);
    function Close:boolean;

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

    procedure BeginUpdate;
    procedure EndUpdate;


    //这些用于在属性组表中增加指定PID的记录                                    // Edit  Post  Change  defalt-result
    function FindAttrRecord(PID:RTFP_ID;Attrs:TAttrsGroup):TFields;            //  O     X      X       nil
    function NewAttrRecord(PID:RTFP_ID;Attrs:TAttrsGroup):TFields;             //  O     X      O       -
    function PostAttrRecord(Attrs:TAttrsGroup):boolean;                        //  X     O      O       false
    function CancelAttrRecord(Attrs:TAttrsGroup):boolean;                      //  X     O      X       false
    function DeleteAttrRecord(PID:RTFP_ID;Attrs:TAttrsGroup):boolean;          //  -     -      O       false

    function ExistAttrField(FieldName:string;Attrs:TAttrsGroup):TFieldDef;     //  -     -      O       nil
    function AddAttrField(FieldName:string;Attrs:TAttrsGroup;
      FieldType:TFieldType;FieldSize:word):TFieldDef;                          //  -     -      O       -
    function DeleteAttrField(FieldName:string;Attrs:TAttrsGroup):boolean;      //  -     -      O       false

    function FindAttrRecord(PID:RTFP_ID;AttrName:string):TFields;
    function NewAttrRecord(PID:RTFP_ID;AttrName:string):TFields;
    function PostAttrRecord(AttrName:string):boolean;
    function CancelAttrRecord(AttrName:string):boolean;
    function DeleteAttrRecord(PID:RTFP_ID;AttrName:string):boolean;

    function ExistAttrField(FieldName:string;AttrName:string):TFieldDef;
    function AddAttrField(FieldName:string;AttrName:string;
      FieldType:TFieldType;FieldSize:word):TFieldDef;
    function DeleteAttrField(FieldName:string;AttrName:string):boolean;


  public //记录编辑
    //Paper
    function AddPaper(fullfilename:string;AddPaperMethod:TAddPaperMethod=apmFullBackup):RTFP_ID;//新增一个文献到工程
    function FindPaper(fullfilename:string):RTFP_ID;//查找具体文件在工程中的PID，未找到返回000000
    function DeletePaper(PID:RTFP_ID):boolean;//移除指定PID的文献

    procedure OpenPaper(PID:RTFP_ID;exename:string='');
    procedure OpenPaperAsPDF(PID:RTFP_ID);inline;
    procedure OpenPaperAsCAJ(PID:RTFP_ID);inline;

    //Image
    function AddImage(fullfilename:string):RTFP_ID;//新增一个图片到工程
    procedure DeleteImage(IID:RTFP_ID);//移除指定IID的图片

    //Notes
    function AddNote(fullfilename:string):RTFP_ID;//新增一个注解到工程
    procedure DeleteNote(NID:RTFP_ID);//移除指定NID的注解


    //Attrs
    function EditAttrField(PID:RTFP_ID;Attrs:TAttrsGroup;FieldName:string;FailOption:TAttrExtend;value:string):boolean;
    function ReadAttrField(PID:RTFP_ID;Attrs:TAttrsGroup;FieldName:string;FailOption:TAttrExtend;var value:string):boolean;

    //Klass
    function KlassInclude(klassname:string;PID:RTFP_ID):boolean;
    function KlassExclude(klassname:string;PID:RTFP_ID):boolean;


  private //显示连接
    FPaperDS:TMemDataSet;

  public //连接显示
    property PaperDS:TMemDataSet read FPaperDS;//筛选后的总表，直接连接DBGrid
    property each_class:TKlassList read FKlassList;
    property each_attrs:TAttrsGroupList read FFieldList;

  public //连接显示
    procedure ProjectPropertiesValidate(AValueListEditor:TValueListEditor);
    procedure ProjectPropertiesDataPost(AValueListEditor:TValueListEditor);

    procedure TableValidate;
    procedure TableFilter(cmd:string);

    procedure FieldListValidate(AListView:TListView);
    procedure KlassListValidate(AListView:TListView);


    procedure NodeViewValidate(PID:RTFP_ID;AValueListEditor:TValueListEditor);
    procedure NodeViewDataPost(PID:RTFP_ID;AValueListEditor:TValueListEditor);


    procedure FmtCmtValidate(PID:RTFP_ID;AttrName,FieldName:string;Memo:TMemo);
    procedure FmtCmtDataPost(PID:RTFP_ID;AttrName,FieldName:string;Memo:TMemo);
    procedure AttrNameValidate(AItems:TStrings);
    procedure FieldNameValidate(AAttrName:string;AItems:TStrings);

  private
    FOnNew,FOnNewDone:TNotifyEvent;
    FOnOpen,FOnOpenDone:TNotifyEvent;
    FOnSave,FOnSaveDone:TNotifyEvent;
    FOnSaveAs,FOnSaveAsDone:TNotifyEvent;
    FOnClose,FOnCloseDone:TNotifyEvent;
    FOnFirstEdit,FOnChange:TNotifyEvent;
    FOnDataChange,FOnFieldChange,FOnRecordChange,FOnClassChange:TNotifyEvent;

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
    //以下On*Change事件会触发OnChange
    property onDataChange:TNotifyEvent read FOnDataChange write FOnDataChange;
    property onFieldChange:TNotifyEvent read FOnFieldChange write FOnFieldChange;
    property onRecordChange:TNotifyEvent read FOnRecordChange write FOnRecordChange;
    property onClassChange:TNotifyEvent read FOnClassChange write FOnClassChange;

  public
    procedure Change;//用于标记工程已经发生改变，如果之前未改变，会触发OnFirstEdit
    procedure DataChange;//数据修改，也会触发Change事件
    procedure FieldChange;//字段修改，也会触发Change事件
    procedure RecordChange;//记录修改，也会触发Change事件
    procedure ClassChange;//分类修改，也会触发Change事件


  {类方法}
  public
    class function NumToID(Num:dword):RTFP_ID;
    class function IDToNum(ID:RTFP_ID):dword;

    class function GetDateTimeStr:string;inline;
    class function GetDateDir:string;inline;

    class function IsProjectFile(filename:ansistring):boolean;
    class function IsRTFPID(PID:string):boolean;

    //class function BackupDbf(ADBF:TDbf):boolean;
    //class function RecoverDbf(ADBF:TDbf):boolean;

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


procedure AufScriptFuncDefineRTFP(Auf:TAuf);


implementation
uses RTFP_main;


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

procedure aufunc_DeletePaper(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
    PID:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,PID) then exit;

  if CurrentRTFP.DeletePaper(PID) then
  AufScpt.writeln('成功');

end;


procedure aufunc_addKlass(Sender:TObject);//class.add KlassName,Path
var AufScpt:TAufScript;
    AAuf:TAuf;
    s1,s2:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(3) then exit;
  if not AAuf.TryArgToString(1,s1) then exit;
  if not AAuf.TryArgToString(2,s2) then exit;
  CurrentRTFP.AddKlass(s1,s2);
  AufScpt.writeln('成功');
end;

procedure aufunc_deleteKlass(Sender:TObject);//class.delete KlassName
var AufScpt:TAufScript;
    AAuf:TAuf;
    s1:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,s1) then exit;
  CurrentRTFP.DeleteKlass(s1);
  AufScpt.writeln('成功');
end;
{
procedure aufunc_newKlassF(Sender:TObject);//class.newf KlassName
var AufScpt:TAufScript;
    AAuf:TAuf;
    s1:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,s1) then exit;
  CurrentRTFP.NewKlassFile(s1);
  AufScpt.writeln('成功');
end;

procedure aufunc_openKlassF(Sender:TObject);//class.openf KlassName
var AufScpt:TAufScript;
    AAuf:TAuf;
    s1:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,s1) then exit;
  CurrentRTFP.OpenKlassFile(s1);
  AufScpt.writeln('成功');
end;

procedure aufunc_saveKlassF(Sender:TObject);//class.savef KlassName
var AufScpt:TAufScript;
    AAuf:TAuf;
    s1:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,s1) then exit;
  CurrentRTFP.SaveKlassFile(s1);
  AufScpt.writeln('成功');
end;

procedure aufunc_closeKlassF(Sender:TObject);//class.closef KlassName
var AufScpt:TAufScript;
    AAuf:TAuf;
    s1:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,s1) then exit;
  CurrentRTFP.CloseKlassFile(s1);
  AufScpt.writeln('成功');
end;
}
procedure aufunc_KlassInclude(Sender:TObject);//class.include KlassName, PID
var AufScpt:TAufScript;
    AAuf:TAuf;
    s1,s2:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(3) then exit;
  if not AAuf.TryArgToString(1,s1) then exit;
  if not AAuf.TryArgToString(2,s2) then exit;
  CurrentRTFP.KlassInclude(s1,s2);
  AufScpt.writeln('成功');
end;

procedure aufunc_KlassExclude(Sender:TObject);//class.exclude KlassName, PID
var AufScpt:TAufScript;
    AAuf:TAuf;
    s1,s2:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(3) then exit;
  if not AAuf.TryArgToString(1,s1) then exit;
  if not AAuf.TryArgToString(2,s2) then exit;
  CurrentRTFP.KlassExclude(s1,s2);
  AufScpt.writeln('成功');
end;




procedure aufunc_EditAttr(Sender:TObject);//attr.edit PID,AttrName,FieldName,"memo"
var AufScpt:TAufScript;
    AAuf:TAuf;
    APID,AMEMO,AFieldName,AAttrName:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(5) then exit;
  if not AAuf.TryArgToString(1,APID) then exit;
  if not AAuf.TryArgToString(2,AAttrName) then exit;
  if not AAuf.TryArgToString(3,AFieldName) then exit;
  if not AAuf.TryArgToString(4,AMEMO) then exit;

  CurrentRTFP.EditAttrField(APID,CurrentRTFP.FFieldList.FindItemByName(AAttrName),AFieldName,[],AMEMO);

  AufScpt.writeln('Note添加成功。');

end;
procedure aufunc_ReadAttr(Sender:TObject);//attr.read PID,AttrName,FieldName,out
var AufScpt:TAufScript;
    AAuf:TAuf;
    APID,AFieldName,AAttrName,AValue:string;
    arv:TAufRamVar;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(5) then exit;
  if not AAuf.TryArgToString(1,APID) then exit;
  if not AAuf.TryArgToString(2,AAttrName) then exit;
  if not AAuf.TryArgToString(3,AFieldName) then exit;
  if not AAuf.TryArgToARV(4,256,256,[ARV_Char],arv) then exit;

  CurrentRTFP.ReadAttrField(APID,CurrentRTFP.FFieldList.FindItemByName(AAttrName),AFieldName,[],AValue);
  initiate_arv_str(AValue,arv);

  AufScpt.writeln('Fields['+AAttrName+','+AFieldName+']='+AValue);

end;

{
procedure aufunc_BackupDBF(Sender:TObject);//dbf.backup AttrNo
var AufScpt:TAufScript;
    AAuf:TAuf;
    AAttrNo:byte;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToByte(1,AAttrNo) then exit;

  TRTFP.BackupDbf(CurrentRTFP.FAttrGroupList[AAttrNo].Dbf);
  AufScpt.writeln(CurrentRTFP.FAttrGroupList[AAttrNo].Name+'备份成功！');
end;

procedure aufunc_RecoverDBF(Sender:TObject);//dbf.recover AttrNo
var AufScpt:TAufScript;
    AAuf:TAuf;
    AAttrNo:byte;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToByte(1,AAttrNo) then exit;

  TRTFP.RecoverDbf(CurrentRTFP.FAttrGroupList[AAttrNo].Dbf);
  AufScpt.writeln(CurrentRTFP.FAttrGroupList[AAttrNo].Name+'还原成功！');
end;
}

procedure aufunc_AddAttrField(Sender:TObject);//attrs.field.add AttrName,FieldName,type,size
var AufScpt:TAufScript;
    AAuf:TAuf;
    AFieldName,AAttrName,AFieldType:string;
    AFieldSize:byte;
    dt:TFieldType;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(5) then exit;
  if not AAuf.TryArgToString(1,AAttrName) then exit;
  if not AAuf.TryArgToString(2,AFieldName) then exit;
  if not AAuf.TryArgToString(3,AFieldType) then exit;
  if not AAuf.TryArgToByte(4,AFieldSize) then exit;

  case lowercase(AFieldType) of
    'memo':dt:=ftMemo;
    'string','str':dt:=ftString;
    'largeint','long':dt:=ftLargeInt;
    'boolean','bool':dt:=ftBoolean;
    'smallint','small':dt:=ftSmallInt;
    else dt:=ftMemo;
  end;

  //CurrentRTFP.AddAttrField(AFieldName,CurrentRTFP.FFieldList.FindItemByName(AAttrName),dt,AFieldSize);
  CurrentRTFP.AddField(AFieldName,AAttrName,dt,AFieldSize);
  AufScpt.writeln('成功。');
end;

procedure aufunc_DelAttrField(Sender:TObject);//attrs.field.drop AttrNo,FieldName
var AufScpt:TAufScript;
    AAuf:TAuf;
    AFieldName,AAttrName:string;

begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(3) then exit;
  if not AAuf.TryArgToString(1,AAttrName) then exit;
  if not AAuf.TryArgToString(2,AFieldName) then exit;

  //CurrentRTFP.DeleteAttrField(AFieldName,CurrentRTFP.FFieldList.FindItemByName(AAttrName));
  CurrentRTFP.DeleteField(AFieldName,AAttrName);
  AufScpt.writeln('成功。');
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

    //Script.add_func('dbf.backup',@aufunc_BackupDBF,'AttrNo','备份第AttrNo个属性组');
    //Script.add_func('dbf.recover',@aufunc_RecoverDBF,'AttrNo','还原第AttrNo个属性组');


    //Script.add_func('paper.add',@aufunc_AddPaper,'filename','新建Paper节点');
    //Script.add_func('paper.delete',@aufunc_DeletePaper,'PID','删除Paper节点');

    Script.add_func('attrs.rec.edit',@aufunc_EditAttr,'PID,AttrName,FieldName,Memo','修改PID节点中第AttrNo表的FieldName字段为Memo');
    Script.add_func('attrs.rec.read',@aufunc_ReadAttr,'PID,AttrName,FieldName,arv','修改PID节点中第AttrNo表的FieldName字段为Memo');

    //Script.add_func('attrs.ag.add',@aufunc_AddAttrGroup,'AttrName','在第AttrNo表中创建FieldName字段');
    //Script.add_func('attrs.ag.del',@aufunc_DelAttrGroup,'AttrName','在第AttrNo表中创建FieldName字段');
    Script.add_func('attrs.af.add',@aufunc_AddAttrField,'AttrName,FieldName','在第AttrNo表中创建FieldName字段');
    Script.add_func('attrs.af.del',@aufunc_DelAttrField,'AttrName,FieldName','在第AttrNo表中创建FieldName字段');

    Script.add_func('class.add',@aufunc_addKlass,'KlassName, Path','创建分类表');
    Script.add_func('class.delete',@aufunc_DeleteKlass,'KlassName','删除分类表');
    Script.add_func('class.include',@aufunc_KlassInclude,'KlassName, PID','将PID节点加入分类');
    Script.add_func('class.exclude',@aufunc_KlassExclude,'KlassName, PID','将PID节点移除分类');


    Script.add_func('pdf.meta',@aufunc_ShowMeta,'filename','检查pdf文件的meta数据');
    Script.add_func('pdf.view',@aufunc_ShowView,'filename,page','预览pdf的page页');


    Script.add_func('hash',@aufunc_FileHash,'filename','返回FileHash');
    Script.add_func('save',@aufunc_save,'','强制保存');

    {$ifdef test}
    Script.add_func('test',@aufunc_test,'*arg','测试');
    {$endif}


  end;
end;








constructor TRTFP.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);

  FPaperDS:=TMemDataset.Create(Self);

  ProjectFileValue:=TValueListEditor.Create(nil);
  //ProjectFileValue.Parent:=AOwner;
  ProjectFileValue.Hide;

  FPaperDB:=TDbf.Create(Self);
  FImageDB:=TDbf.Create(Self);
  FNotesDB:=TDbf.Create(Self);



  FKlassList:=TKlassList.Create(Self);
  FFileList:=TRTFP_FileList.Create(Self,'');
  FFieldList:=TAttrsGroupList.Create(Self);

  FUserList:=TStringList.Create;
  FFormatList:=TStringList.Create;

  FFilePath:='';
  FFileName:='';

  FIsChanged:=false;
  FIsOpen:=false;
  FIsUpdating:=false;

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
  FOnChange:=nil;
  FOnDataChange:=nil;
  FOnFieldChange:=nil;
  FOnRecordChange:=nil;


end;


destructor TRTFP.Destroy;
begin
  FUserList.Free;
  FFormatList.Free;

  FKlassList.Free;
  FFileList.Free;
  FFieldList.Free;


  FPaperDB.Free;
  FImageDB.Free;
  FNotesDB.Free;

  ProjectFileValue.Free;

  FPaperDS.Free;

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

  FKlassList.Path:=FFilePath+FRootFolder;
  FFieldList.Path:=FFilePath+FRootFolder;


end;

function TRTFP.OpenDbf(dbf_name_no_ext:string;Dbf:TDbf):boolean;
var dbfpath,datfile,runfile,run_dbt,dat_dbt,name_no_ext:string;
begin
  result:=false;
  dbfpath:=Self.FFilePath+Self.FRootFolder+'\'+dbf_name_no_ext;
  name_no_ext:=ExtractFileName(dbfpath);
  dbfpath:=ExtractFilePath(dbfpath);
  datfile:=name_no_ext+'.dbf';
  runfile:=name_no_ext+'_run.dbf';
  dat_dbt:=name_no_ext+'.dbt';
  run_dbt:=name_no_ext+'_run.dbt';

  if not FileExists(dbfpath+datfile) then exit;
  TRTFP.FileCopy((dbfpath+datfile),(dbfpath+runfile),false);
  if FileExists(dbfpath+dat_dbt) then TRTFP.FileCopy((dbfpath+dat_dbt),(dbfpath+run_dbt),false);

  Dbf.FilePathFull:=dbfpath;
  Dbf.TableName:=runfile;
  Dbf.Exclusive:=true;
  try
    Dbf.Open;
    Dbf.AddIndex('Id',Dbf.DbfFieldDefs.Items[1].FieldName,[ixPrimary, ixUnique]);
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
  runfile:=name_no_ext+'_run.dbf';
  dat_dbt:=name_no_ext+'.dbt';
  run_dbt:=name_no_ext+'_run.dbt';

  Dbf.FilePathFull:=dbfpath;
  Dbf.TableName:=runfile;
  try
    Dbf.TableLevel:=7;
    Dbf.Exclusive:=true;
    Dbf.CreateTable;
    Dbf.Open;
    Dbf.AddIndex('Id',Dbf.DbfFieldDefs.Items[1].FieldName,[ixPrimary, ixUnique]);
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
  runfile:=name_no_ext+'_run.dbf';
  dat_dbt:=name_no_ext+'.dbt';
  run_dbt:=name_no_ext+'_run.dbt';

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
var dbfpath,{datfile,}runfile,run_dbt,{dat_dbt,}name_no_ext:string;
begin
  result:=false;
  dbfpath:=Self.FFilePath+Self.FRootFolder+'\'+dbf_name_no_ext;
  name_no_ext:=ExtractFileName(dbfpath);
  dbfpath:=ExtractFilePath(dbfpath);
  //datfile:=name_no_ext+'.dbf';
  runfile:=name_no_ext+'_run.dbf';
  //dat_dbt:=name_no_ext+'.dbt';
  run_dbt:=name_no_ext+'_run.dbt';

  try
    if Dbf.Active then begin
      Dbf.CloseIndexFile('id');
      Dbf.DeleteIndex('id');
      Dbf.Close;
    end;
    if not TRTFP.FileDelete((dbfpath+runfile)) then exit;
    if FileExists(dbfpath+run_dbt) then begin
      if not TRTFP.FileDelete((dbfpath+run_dbt)) then exit;
    end;
  except
    exit;
  end;
  result:=true;
end;

function TRTFP.DeleteDbf(dbf_name_no_ext:string;Dbf:TDbf):boolean;
var dbfpath,datfile,runfile,run_dbt,dat_dbt,name_no_ext:string;
begin

  result:=false;
  dbfpath:=Self.FFilePath+Self.FRootFolder+'\'+dbf_name_no_ext;
  name_no_ext:=ExtractFileName(dbfpath);
  dbfpath:=ExtractFilePath(dbfpath);
  datfile:=name_no_ext+'.dbf';
  runfile:=name_no_ext+'_run.dbf';
  dat_dbt:=name_no_ext+'.dbt';
  run_dbt:=name_no_ext+'_run.dbt';

  try
    if Dbf.Active then begin
      Dbf.CloseIndexFile('id');
      Dbf.DeleteIndex('id');
      Dbf.Close;
    end;
    TRTFP.FileDelete((dbfpath+runfile));
    TRTFP.FileDelete((dbfpath+datfile));
    TRTFP.FileDelete((dbfpath+run_dbt));
    TRTFP.FileDelete((dbfpath+dat_dbt));
  except
    exit;
  end;
  result:=true;

end;

function TRTFP.AddAttrs(AName:string):TAttrsGroup;
var tmp:TAttrsGroup;
begin
  if FFieldList.FindItemIndexByName(AName)>=0 then exit;
  tmp:=FFieldList.AddEx('attr\'+AName,AName);
  if not OpenDbf(tmp.FullPath,tmp.Dbf) then begin
    case AName of
      _Attrs_Basic_:GenAttrBasicAttribute(tmp.Dbf);
      _Attrs_Class_:GenAttrClassAttribute(tmp.Dbf);
      _Attrs_Notes_:GenAttrNotesAttribute(tmp.Dbf);
      _Attrs_Metas_:GenAttrMetasAttribute(tmp.Dbf);
      _Attrs_Relat_:GenAttrRelatAttribute(tmp.Dbf);
      else GenAttrDefaultAttribute(tmp.Dbf);
    end;
    NewDbf(tmp.FullPath,tmp.Dbf);
  end;
  FieldChange;
  result:=tmp;
end;

function TRTFP.FindAttrs(AName:string):TAttrsGroup;
begin
  result:=FFieldList.FindItemByName(AName);
end;

procedure TRTFP.DeleteAttrs(AName:string);
var index:integer;
    tmp:TAttrsGroup;
begin
  index:=FFieldList.FindItemIndexByName(AName);
  if index<0 then exit;
  tmp:=FFieldList.Items[index];
  CloseDbf(tmp.FullPath,tmp.Dbf);
  DeleteDbf(tmp.FullPath,tmp.Dbf);
  FFieldList.Delete(index);
  FieldChange;
end;

function TRTFP.AddField(AName:string;AAttrsName:string;AType:TFieldType;ASize:word):TAttrsField;
var tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
begin
  tmpAG:=FindAttrs(AAttrsName);
  if tmpAG=nil then tmpAG:=AddAttrs(AAttrsName);
  tmpAF:=tmpAG.FieldList.FindItemByName(AName);
  if tmpAF=nil then
    with tmpAG do begin
      if not Dbf.Active then Dbf.Open;
      Dbf.TryExclusive;
      Dbf.DbfFieldDefs.Add(AName,AType,ASize);
      Dbf.PackTable;
      Dbf.Close;
      Dbf.Open;
      Dbf.RegenerateIndexes;
      LoadFieldListFromDbf;
      FieldChange;
    end;
  result:=tmpAF;
end;

function TRTFP.FindField(AName:string;AAttrsName:string):TAttrsField;
var tmpAG:TAttrsGroup;
begin
  result:=nil;
  tmpAG:=FindAttrs(AAttrsName);
  if tmpAG=nil then exit;
  result:=tmpAG.FieldList.FindItemByName(AName);
end;

procedure TRTFP.DeleteField(AName:string;AAttrsName:string);
var tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
    pi:integer;
begin
  tmpAG:=FindAttrs(AAttrsName);
  if tmpAG=nil then exit;
  tmpAF:=tmpAG.FieldList.FindItemByName(AName);
  if tmpAF<>nil then
    with tmpAG do begin
      if not Dbf.Active then Dbf.Open;
      Dbf.TryExclusive;
      pi:=0;
      while pi<Dbf.DbfFieldDefs.Count do
        begin
          if Dbf.DbfFieldDefs.Items[pi].FieldName=AName then break;
          inc(pi);
        end;
      if pi<Dbf.DbfFieldDefs.Count then
        begin
          Dbf.DbfFieldDefs.Delete(pi);
          Dbf.PackTable;
        end
      else ;
      Dbf.Close;
      Dbf.Open;
      Dbf.EndExclusive;
      Dbf.RegenerateIndexes;
      LoadFieldListFromDbf;
      FieldChange;
    end;
  if tmpAG.IsEmpty then DeleteAttrs(tmpAG.Name);
end;

procedure TRTFP.LoadAttrs;
var tmpAttrs:TAttrsGroup;
begin
  BeginUpdate;
  FFieldList.LoadFromPath('attr\');
  for tmpAttrs in FFieldList do
    begin
      if not OpenDbf(tmpAttrs.FullPath,tmpAttrs.Dbf) then
        NewDbf(tmpAttrs.FullPath,tmpAttrs.Dbf);
      tmpAttrs.Dbf.Exclusive:=true;
      tmpAttrs.Dbf.Open;
    end;
  //如果没有才会新建
  AddAttrs(_Attrs_Basic_);
  AddAttrs(_Attrs_Class_);
  AddAttrs(_Attrs_Notes_);
  AddAttrs(_Attrs_Metas_);
  AddAttrs(_Attrs_Relat_);
  for tmpAttrs in FFieldList do
    begin
      tmpAttrs.LoadFieldListFromDbf;
    end;
  EndUpdate;
  FieldChange;
end;

procedure TRTFP.SaveAttrs;
var tmpAttrs:TAttrsGroup;
begin
  for tmpAttrs in FFieldList do
    begin
      while not SaveDbf(tmpAttrs.FullPath,tmpAttrs.Dbf) do
        case MessageDlg('错误','属性组保存失败！',mtError,[mbRetry,mbIgnore],0) of
          rnmbRetry:;
          rnmbIgnore:break;
        end;
    end;
end;

procedure TRTFP.CloseAttrs;
var tmpAttrs:TAttrsGroup;
begin
  for tmpAttrs in FFieldList do
    begin
      while not CloseDbf(tmpAttrs.FullPath,tmpAttrs.Dbf) do
        case MessageDlg('错误','属性组关闭失败！',mtError,[mbRetry,mbIgnore],0) of
          rnmbRetry:;
          rnmbIgnore:break;
        end;
    end;
end;

procedure TRTFP.CheckAttrs;
begin

end;



function TRTFP.AddKlass(klassname:string;pathname:string='\'):TKlass;
var tmp:TKlass;
begin
  if FKlassList.FindItemIndexByName(klassname)>=0 then exit;
  tmp:=FKlassList.AddEx('class\'+pathname+'\'+klassname,klassname);
  if not OpenDbf(tmp.FullPath,tmp.Dbf) then begin
    GenAttrDefaultAttribute(tmp.Dbf);
    NewDbf(tmp.FullPath,tmp.Dbf);
  end;
  ClassChange;
  result:=tmp;
end;

function TRTFP.FindKlass(klassname:string):TKlass;
begin
  result:=FKlassList.FindItemByName(klassname);
end;

procedure TRTFP.DeleteKlass(klassname:string);
var index:integer;
    tmp:TKlass;
begin
  index:=FKlassList.FindItemIndexByName(klassname);
  if index<0 then exit;
  tmp:=FKlassList.Items[index];
  CloseDbf(tmp.FullPath,tmp.Dbf);
  DeleteDbf(tmp.FullPath,tmp.Dbf);
  FKlassList.Delete(index);
  ClassChange;
end;


procedure TRTFP.LoadKlass;
var tmpKlass:TKlass;
begin
  BeginUpdate;
  FKlassList.LoadFromPath('class\');
  for tmpKlass in FKlassList do
    begin
      if not OpenDbf(tmpKlass.FullPath,tmpKlass.Dbf) then
        NewDbf(tmpKlass.FullPath,tmpKlass.Dbf);
    end;
  EndUpdate;
  ClassChange;
end;

procedure TRTFP.SaveKlass;
var tmpKlass:TKlass;
begin
  for tmpKlass in FKlassList do
    begin
      while not SaveDbf(tmpKlass.FullPath,tmpKlass.Dbf) do
        case MessageDlg('错误','分类文件保存失败！',mtError,[mbRetry,mbIgnore],0) of
          rnmbRetry:;
          rnmbIgnore:break;
        end;
    end;
end;

procedure TRTFP.CloseKlass;
var tmpKlass:TKlass;
begin
  for tmpKlass in FKlassList do
    begin
      while not CloseDbf(tmpKlass.FullPath,tmpKlass.Dbf) do
        case MessageDlg('错误','分类文件关闭失败！',mtError,[mbRetry,mbIgnore],0) of
          rnmbRetry:;
          rnmbIgnore:break;
        end;
    end;
end;

{
function TRTFP.NewKlassFile(klassname:string):boolean;
var index:integer;
begin
  result:=false;
  index:=FKlassList.FindItemIndexByName(klassname);
  if index<0 then exit;
  GenAttrDefaultAttribute(FKlassList[index].Dbf);
  NewDbf(FKlassList[index].FullPath,FKlassList[index].Dbf);
  Change;
  result:=true;
end;

function TRTFP.OpenKlassFile(klassname:string):boolean;
var index:integer;
begin
  result:=false;
  index:=FKlassList.FindItemIndexByName(klassname);
  if index<0 then exit;
  if not OpenDbf(FKlassList[index].FullPath,FKlassList[index].Dbf) then begin
    GenAttrDefaultAttribute(FKlassList[index].Dbf);
    NewDbf(FKlassList[index].FullPath,FKlassList[index].Dbf);
    Change;
  end;
  result:=true;
end;

function TRTFP.SaveKlassFile(klassname:string):boolean;
var index:integer;
begin
  result:=false;
  index:=FKlassList.FindItemIndexByName(klassname);
  if index<0 then exit;
  SaveDbf(FKlassList[index].FullPath,FKlassList[index].Dbf);
  result:=true;
end;

function TRTFP.CloseKlassFile(klassname:string):boolean;
var index:integer;
begin
  result:=false;
  index:=FKlassList.FindItemIndexByName(klassname);
  if index<0 then exit;
  CloseDbf(FKlassList[index].FullPath,FKlassList[index].Dbf);
  result:=true;
end;
}

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

procedure TRTFP.GenAttrClassAttribute(Dbf:TDbf);
begin
  Dbf.FieldDefs.Add(_Col_OID_, ftAutoInc, 0, True);
  Dbf.FieldDefs.Add(_Col_PID_, ftString, 8, True);

  Dbf.FieldDefs.Add(_Col_class_Is_Read_, {ftSmallint}ftBoolean, 0, True);//是否已读         否0 是1

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

procedure TRTFP.GenAttrRelatAttribute(Dbf:TDbf);
begin
  Dbf.FieldDefs.Add(_Col_OID_, ftAutoInc, 0, True);
  Dbf.FieldDefs.Add(_Col_PID_, ftString, 8, True);

  Dbf.FieldDefs.Add(_Col_relat_Parent_, ftMemo, 8, True);//父节点
  Dbf.FieldDefs.Add(_Col_relat_Children_, ftMemo, 8, True);//子节点

  Dbf.FieldDefs.Add(_Col_relat_Cited_, ftMemo, 8, True);//引证文献
  Dbf.FieldDefs.Add(_Col_relat_References_, ftMemo, 8, True);//参考文献

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

  tmpProjectFile.Add('属性组00,'+_Attrs_Basic_);
  tmpProjectFile.Add('属性组01,'+_Attrs_Class_);
  tmpProjectFile.Add('属性组02,'+_Attrs_Notes_);
  tmpProjectFile.Add('属性组03,'+_Attrs_Metas_);
  tmpProjectFile.Add('属性组04,'+_Attrs_Relat_);


  repeat
    retry:=false;
    try
      tmpProjectFile.SaveToFile(FFileFullName);
      ProjectFileValue.LoadFromCSVFile(FFileFullName);
    except
      case MessageDlg('错误','文件占用导致工程文档创建异常！',mtError,[mbRetry,mbCancel],0) of
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

  NewProjectFile(WinCPToUTF8(p_title),WinCPToUTF8(p_user));
  NewUserList;
  NewFormatList;

  GenPaperAttribute(Self.FPaperDB);
  NewDbf('paper',Self.FPaperDB);
  GenImageAttribute(Self.FImageDB);
  NewDbf('image',Self.FImageDB);
  GenNoteAttribute(Self.FNotesDB);
  NewDbf('note',Self.FNotesDB);

  LoadAttrs;
  LoadKlass;

  if FOnNewDone <> nil then FOnNewDone(Self);
  Self.FIsOpen:=true;
  Self.FIsChanged:=false;
  if FOnOpenDone <> nil then FOnOpenDone(Self);
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
  if not OpenDbf('note',Self.FNotesDB) then NewDbf('note',Self.FNotesDB);;

  LoadAttrs;
  LoadKlass;

  Self.FIsOpen:=true;
  Self.FIsChanged:=false;
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
  SaveDbf('note',Self.FNotesDB);

  SaveAttrs;
  SaveKlass;

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
  CloseDbf('note',Self.FNotesDB);

  CloseAttrs;
  CloseKlass;

  Self.FIsOpen:=false;
  if FOnCloseDone <> nil then FOnCloseDone(Self);
  result:=true;
end;

procedure TRTFP.Change;
begin
  if (not Self.FIsChanged) and (@onFirstEdit<>nil) then Self.onFirstEdit(Self);
  Self.FIsChanged:=true;
  if (not FIsUpdating) and (FOnChange<>nil) then FOnChange(Self);
end;

procedure TRTFP.DataChange;
begin
  if (not FIsUpdating) and (FOnDataChange<>nil) then FOnDataChange(Self);
  Change;
end;
procedure TRTFP.FieldChange;
begin
  if (not FIsUpdating) and (FOnFieldChange<>nil) then FOnFieldChange(Self);
  Change;
end;
procedure TRTFP.RecordChange;
begin
  if (not FIsUpdating) and (FOnRecordChange<>nil) then FOnRecordChange(Self);
  Change;
end;
procedure TRTFP.ClassChange;
begin
  if (not FIsUpdating) and (FOnClassChange<>nil) then FOnClassChange(Self);
  Change;
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
  FNotesDB.Last;
  if FNotesDB.BOF then num:=0
  else num:=TRTFP.IDToNum((FNotesDB.FieldByName(_Col_NID_).AsString));
  inc(num);
  result:=TRTFP.NumToID(num);
end;


function TRTFP.AddPaper(fullfilename:string;AddPaperMethod:TAddPaperMethod=apmFullBackup):RTFP_ID;//新增一个文献到工程
var PID:RTFP_ID;
    DateDir,TargetDir,FileName:string;
    tmpPDF:TRTFP_PDF;
    tmpAttr:TFields;
begin
  result:='000000';
  if (AddPaperMethod<>apmFullBackup) and (AddPaperMethod<>apmReference) then
    begin
      assert(false,'暂不支持apmFullBackup和apmReference以外的方式。');
      exit;
    end;

  DateDir:=TRTFP.GetDateDir;
  FileName:=ExtractFileName(fullfilename);

  if AddPaperMethod=apmFullBackup then begin
    TargetDir:=FFilePath+FRootFolder+'\paper\'+DateDir;
    if FileExists(TargetDir+'\'+FileName) then
      case MessageDlg('相同的备份路径','正在导入的文件“'+fullfilename
      +'”的默认备份地址存在重名，覆盖会导致两个文献节点共用一个备份文件。'
      +'若两个文件不相同，会导致旧版本备份文件被覆盖，且难以复原。'
      +'是否覆盖？',mtWarning,[mbYes,mbNo],0) of
        rnmbYes:{do nothing};
        rnmbNo:exit;
    end;
  end;

  tmpPDF:=TRTFP_PDF.Create(nil);
  tmpPDF.LoadPdf(fullfilename);

  PID:=NewPaperID;
  //FPaperDB.Last;//此时游标已经在Last位置
  with FPaperDB do begin
    Insert;
    FieldByName(_Col_PID_).AsString:=PID;
    FieldByName(_Col_Paper_Is_Backup_).AsBoolean:=(AddPaperMethod=apmFullBackup);
    FieldByName(_Col_Paper_Folder_).AsString:=DateDir;
    FieldByName(_Col_Paper_FileName_).AsString:=FileName;
    FieldByName(_Col_Paper_FileSize_).AsLargeInt:=tmpPDF.Size;
    FieldByName(_Col_Paper_FileHash_).AsString:=tmpPDF.Hash;
    Post;
  end;

  //0-文献基本信息要专门的算法
  tmpAttr:=FindAttrRecord(PID,_Attrs_Basic_);
  if tmpAttr = nil then tmpAttr:=NewAttrRecord(PID,_Attrs_Basic_);
  tmpAttr.FieldByName(_Col_basic_Has_Ext_).AsInteger:=0;
  PostAttrRecord(_Attrs_Basic_);

  //1-分类
  tmpAttr:=FindAttrRecord(PID,_Attrs_Class_);
  if tmpAttr = nil then tmpAttr:=NewAttrRecord(PID,_Attrs_Class_);
  tmpAttr.FieldByName(_Col_class_Is_Read_).AsInteger:=0;
  PostAttrRecord(_Attrs_Class_);

  //2-注解
  tmpAttr:=FindAttrRecord(PID,_Attrs_Notes_);
  if tmpAttr = nil then tmpAttr:=NewAttrRecord(PID,_Attrs_Notes_);
  //这里之后要考虑不是pdf或者pdf读取错误的情况
  tmpAttr.FieldByName(_Col_notes_User_).AsInteger:=0;
  tmpAttr.FieldByName(_Col_notes_CreateTime_).AsDateTime:=Now;
  tmpAttr.FieldByName(_Col_notes_ModifyTime_).AsDateTime:=Now;
  tmpAttr.FieldByName(_Col_notes_CheckTime_).AsDateTime:=Now;
  PostAttrRecord(_Attrs_Notes_);

  //3-元数据
  tmpAttr:=FindAttrRecord(PID,_Attrs_Metas_);
  if tmpAttr = nil then tmpAttr:=NewAttrRecord(PID,_Attrs_Metas_);
  //这里之后要考虑不是pdf或者pdf读取错误的情况
  tmpAttr.FieldByName(_Col_metas_Title_).AsString:=tmpPDF.Meta.pFields['DocInfo:Title']^;
  tmpAttr.FieldByName(_Col_metas_Authors_).AsString:=tmpPDF.Meta.pFields['DocInfo:Author']^;
  tmpAttr.FieldByName(_Col_metas_Subject_).AsString:=tmpPDF.Meta.pFields['DocInfo:Subject']^;
  tmpAttr.FieldByName(_Col_metas_Keyword_).AsString:=tmpPDF.Meta.pFields['DocInfo:Keywords']^;
  tmpAttr.FieldByName(_Col_metas_Creator_).AsString:=tmpPDF.Meta.pFields['DocInfo:Creator']^;
  tmpAttr.FieldByName(_Col_metas_Produce_).AsString:=tmpPDF.Meta.pFields['DocInfo:Producer']^;
  tmpAttr.FieldByName(_Col_metas_CreDate_).AsString:=tmpPDF.Meta.pFields['DocInfo:CreationDate']^;
  tmpAttr.FieldByName(_Col_metas_ModDate_).AsString:=tmpPDF.Meta.pFields['DocInfo:ModDate']^;
  PostAttrRecord(_Attrs_Metas_);

  if AddPaperMethod=apmFullBackup then begin
    //TargetDir:=FFilePath+FRootFolder+'\paper\'+DateDir;
    ForceDirectories(TargetDir);
    tmpPDF.CopyTo(TargetDir+'\'+FileName);//尚未加入长度检验
  end;

  RecordChange;

  tmpPDF.ClosePdf;
  tmpPDF.Free;
  result:=PID;
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
      if FieldByName(_Col_Paper_FileSize_).AsLongint = FileStream.Size then
        begin
          if FHash='' then FHash:=TRTFP.FileHash(FileStream);
          if FieldByName(_Col_Paper_FileHash_).AsString = FHash then
            begin
              if not cps then begin CpStr:=TMemoryStream.Create;cps:=true end;
              FName:=FFilePath+FRootFolder+'\paper\'+FieldByName(_Col_Paper_Folder_).AsString+'\'+FieldByName(_Col_Paper_FileName_).AsString;
              retry:=false;
              repeat try
                CpStr.LoadFromFile(FName);
                if CompareMem(FileStream.Memory,CpStr.Memory,FileStream.Size) then PID:=FieldByName(_Col_PID_).AsString;
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

function TRTFP.DeletePaper(PID:RTFP_ID):boolean;//移除指定PID的文献
var AG:TAttrsGroup;
begin
  result:=false;
  if not TRTFP.IsRTFPID(PID) then exit;
  with FPaperDB do begin
    if not Active then Open;
    First;
    while not EOF do
      begin
        if FieldByName(_Col_PID_).AsString=PID then begin
          Delete;
          break;
        end;
        Next;
      end;
  end;
  for AG in FFieldList do with AG.Dbf do
    begin
      if not Active then Open;
      First;
      while not EOF do
        begin
          if FieldByName(_Col_PID_).AsString=PID then begin
            Delete;
            break;
          end;
          Next;
        end;
    end;
  RecordChange;
  result:=true;
end;

procedure TRTFP.OpenPaper(PID:RTFP_ID;exename:string='');
var filename:string;
begin
  with FPaperDB do begin
    First;
    while not EOF do
      begin
        if FieldByName(_Col_PID_).AsString=PID then break;
        Next;
      end;
    if EOF then begin assert(false,'未找到PID');exit;end;
    if FieldByName(_Col_Paper_Is_Backup_).AsBoolean then begin
      filename:=Utf8ToWinCP(FFilePath+FRootFolder+'\paper\'
        +FieldByName(_Col_Paper_Folder_).AsString+'\'
        +FieldByName(_Col_Paper_FileName_).AsString);
      if exename='' then
        ShellExecute(0,'open',pchar('"'+filename+'"'),'','',SW_NORMAL)
      else
        ShellExecute(0,'open',pchar(exename),pchar('"'+filename+'"'),'',SW_NORMAL);
    end else
      ShowMessage('非备份文献节点不能通过此方法打开！');
  end;
end;

procedure TRTFP.OpenPaperAsPDF(PID:RTFP_ID);
begin
  OpenPaper(PID,OpenPdfExe);
end;

procedure TRTFP.OpenPaperAsCAJ(PID:RTFP_ID);
begin
  OpenPaper(PID,OpenCajExe);
end;


function TRTFP.EditAttrField(PID:RTFP_ID;Attrs:TAttrsGroup;FieldName:string;FailOption:TAttrExtend;value:string):boolean;
var tmpFieldDef:TFieldDef;
    tmpFields:TFields;
begin
  result:=false;
  tmpFieldDef:=ExistAttrField(FieldName,Attrs);
  if tmpFieldDef=nil then
    begin
      if aeFailIfNoField in FailOption then exit
      else tmpFieldDef:=AddAttrField(FieldName,Attrs,ftMemo,0);
    end;
  //tmpFieldDef.ID;
  tmpFields:=FindAttrRecord(PID,Attrs);
  if tmpFields=nil then
    begin
      if aeFailIfNoPID in FailOption then exit
      else tmpFields:=NewAttrRecord(PID,Attrs);
    end;

  case tmpFieldDef.DataType of
    ftString,ftMemo:{tmpFields[tmpDbfFieldDef.ID]}tmpFields.FieldByName(FieldName).AsString:=value;
    ftBoolean:tmpFields.FieldByName(FieldName).AsBoolean:=(lowercase(value) = 'true') or (lowercase(value) = 't');
    ftFloat:tmpFields.FieldByName(FieldName).AsFloat:=StrToFloat(value);
    ftInteger:tmpFields.FieldByName(FieldName).AsInteger:=StrToInt(value);
    ftLargeint:tmpFields.FieldByName(FieldName).AsLargeInt:=StrToInt(value);
    ftSmallint,ftWord:tmpFields.FieldByName(FieldName).AsLongint:=StrToInt(value);
    ftWideString,ftFixedWideChar,ftWideMemo:tmpFields.FieldByName(FieldName).AsWideString:=widestring(value);
    else assert(false,'ftType未预设。');
  end;

  PostAttrRecord(Attrs);
  ReNewModifyTime(PID);
  result:=true;
end;

function TRTFP.ReadAttrField(PID:RTFP_ID;Attrs:TAttrsGroup;FieldName:string;FailOption:TAttrExtend;var value:string):boolean;
var tmpFieldDef:TFieldDef;
    tmpFields:TFields;
begin
  result:=false;
  tmpFieldDef:=ExistAttrField(FieldName,Attrs);
  if tmpFieldDef=nil then
    begin
      if aeFailIfNoField in FailOption then exit
      else tmpFieldDef:=AddAttrField(FieldName,Attrs,ftMemo,0);
    end;
  //tmpDbfFieldDef.ID;
  tmpFields:=FindAttrRecord(PID,Attrs);
  if tmpFields=nil then
    begin
      if aeFailIfNoPID in FailOption then exit
      else tmpFields:=NewAttrRecord(PID,Attrs);
    end;

  case tmpFieldDef.DataType of
    ftString,ftMemo:value:={tmpFields[tmpDbfFieldDef.ID]}tmpFields.FieldByName(FieldName).AsString;
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




function TRTFP.KlassInclude(klassname:string;PID:RTFP_ID):boolean;
var index:integer;
begin
  result:=false;
  index:=FKlassList.FindItemIndexByName(klassname);
  if index<0 then exit;
  with FKlassList[index].Dbf do begin
    if not Active then Open;
    First;
    while not EOF do
      begin
        if FieldByName(_Col_PID_).AsString = PID then begin result:=true;exit end;
        Next;
      end;
    Insert;
    FieldByName(_Col_PID_).AsString:=PID;
    Post;
  end;
  DataChange;
  result:=true;
end;

function TRTFP.KlassExclude(klassname:string;PID:RTFP_ID):boolean;
var index:integer;
begin
  result:=false;
  index:=FKlassList.FindItemIndexByName(klassname);
  if index<0 then exit;
  with FKlassList[index].Dbf do begin
    if not Active then Open;
    First;
    while not EOF do
      begin
        if FieldByName(_Col_PID_).AsString = PID then begin Delete;Post;exit end;
        Next;
      end;
  end;
  DataChange;
  result:=true;
end;

procedure TRTFP.ReNewCreateTime(PID:RTFP_ID);
begin
  FindAttrRecord(PID,_Attrs_Notes_).FieldByName(_Col_notes_CreateTime_).AsDateTime:=Now;
  PostAttrRecord(_Attrs_Notes_);
end;

procedure TRTFP.ReNewModifyTime(PID:RTFP_ID);
begin
  FindAttrRecord(PID,_Attrs_Notes_).FieldByName(_Col_notes_ModifyTime_).AsDateTime:=Now;
  PostAttrRecord(_Attrs_Notes_);
end;

procedure TRTFP.ReNewCheckTime(PID:RTFP_ID);
begin
  FindAttrRecord(PID,_Attrs_Notes_).FieldByName(_Col_notes_CheckTime_).AsDateTime:=Now;
  PostAttrRecord(_Attrs_Notes_);
end;

procedure TRTFP.ReNewModifyTimeWithoutChange(PID:RTFP_ID);
begin
  FindAttrRecord(PID,_Attrs_Notes_).FieldByName(_Col_notes_ModifyTime_).AsDateTime:=Now;
  FFieldList.FindItemByName(_Attrs_Notes_).Dbf.Post;
end;

procedure TRTFP.ReNewCheckTimeWithoutChange(PID:RTFP_ID);
begin
  FindAttrRecord(PID,_Attrs_Notes_).FieldByName(_Col_notes_CheckTime_).AsDateTime:=Now;
  FFieldList.FindItemByName(_Attrs_Notes_).Dbf.Post;
end;

procedure TRTFP.BeginUpdate;
begin
  FIsUpdating:=true;
end;

procedure TRTFP.EndUpdate;
begin
  FIsUpdating:=false;
end;

function TRTFP.FindAttrRecord(PID:RTFP_ID;Attrs:TAttrsGroup):TFields;
begin
  result:=nil;
  with Attrs do begin
    Dbf.First;
    while not Dbf.EOF do begin
      if Dbf.FieldByName(_Col_PID_).AsString=PID then begin result:=Dbf.Fields;Dbf.Edit;exit end;
      Dbf.Next;
    end;
  end;
end;

function TRTFP.NewAttrRecord(PID:RTFP_ID;Attrs:TAttrsGroup):TFields;
begin
  result:=nil;
  with Attrs do begin
    Dbf.Last;
    Dbf.Insert;
    Dbf.FieldByName(_Col_PID_).AsString:=PID;
    result:=Dbf.Fields;
    Dbf.Post;
    Dbf.Edit;
  end;
  DataChange;
end;

function TRTFP.DeleteAttrRecord(PID:RTFP_ID;Attrs:TAttrsGroup):boolean;
begin
  result:=false;
  with Attrs do begin
    Dbf.First;
    while not Dbf.EOF do begin
      if Dbf.FieldByName(_Col_PID_).AsString=PID then begin Dbf.Delete;DataChange;result:=true;exit end;
      Dbf.Next;
    end;
  end;
end;

function TRTFP.PostAttrRecord(Attrs:TAttrsGroup):boolean;
begin
  //result:=false;
  Attrs.Dbf.Post;
  DataChange;
  result:=true;
end;

function TRTFP.CancelAttrRecord(Attrs:TAttrsGroup):boolean;
begin
  //result:=false;
  Attrs.Dbf.Cancel;
  result:=true;
end;

function TRTFP.ExistAttrField(FieldName:string;Attrs:TAttrsGroup):TFieldDef;
begin
  result:=Attrs.Dbf.FieldDefs.Find(FieldName);
end;

function TRTFP.AddAttrField(FieldName:string;Attrs:TAttrsGroup;FieldType:TFieldType;FieldSize:word):TFieldDef;
begin
  result:=nil;
  with Attrs.Dbf do begin
    FieldDefs.Add(FieldName,FieldType,FieldSize);
    PackTable;
    RegenerateIndexes;
    Close;
    Open;
  end;

  DataChange;
  result:=Attrs.Dbf.FieldDefs.Items[Attrs.Dbf.FieldDefs.Count-1];
end;

function TRTFP.DeleteAttrField(FieldName:string;Attrs:TAttrsGroup):boolean;
var tmp:integer;
begin
  result:=false;
  tmp:=0;

  with Attrs.Dbf do begin
    repeat
      if FieldDefs[tmp].Name=FieldName then break;
      inc(tmp);
    until tmp>=FieldDefs.Count;
    if tmp<FieldDefs.Count then FieldDefs.Delete(tmp);

    TryExclusive;
    PackTable;
    RegenerateIndexes;
    Close;
    Open;
    EndExclusive;
  end;

  DataChange;
  result:=true;
end;

function TRTFP.FindAttrRecord(PID:RTFP_ID;AttrName:string):TFields;
var tmp:TAttrsGroup;
begin
  tmp:=FFieldList.FindItemByName(AttrName);
  assert(tmp<>nil,'FFieldList.FindItemByName(AttrName) == NIL');
  if tmp=nil then exit;
  result:=FindAttrRecord(PID,tmp);
end;

function TRTFP.NewAttrRecord(PID:RTFP_ID;AttrName:string):TFields;
var tmp:TAttrsGroup;
begin
  tmp:=FFieldList.FindItemByName(AttrName);
  assert(tmp<>nil,'FFieldList.FindItemByName(AttrName) == NIL');
  if tmp=nil then exit;
  result:=NewAttrRecord(PID,tmp);
end;

function TRTFP.PostAttrRecord(AttrName:string):boolean;
var tmp:TAttrsGroup;
begin
  tmp:=FFieldList.FindItemByName(AttrName);
  assert(tmp<>nil,'FFieldList.FindItemByName(AttrName) == NIL');
  if tmp=nil then exit;
  result:=PostAttrRecord(tmp);
end;

function TRTFP.CancelAttrRecord(AttrName:string):boolean;
var tmp:TAttrsGroup;
begin
  tmp:=FFieldList.FindItemByName(AttrName);
  assert(tmp<>nil,'FFieldList.FindItemByName(AttrName) == NIL');
  if tmp=nil then exit;
  result:=CancelAttrRecord(tmp);
end;

function TRTFP.DeleteAttrRecord(PID:RTFP_ID;AttrName:string):boolean;
var tmp:TAttrsGroup;
begin
  tmp:=FFieldList.FindItemByName(AttrName);
  assert(tmp<>nil,'FFieldList.FindItemByName(AttrName) == NIL');
  if tmp=nil then exit;
  result:=DeleteAttrRecord(PID,tmp);
end;


function TRTFP.ExistAttrField(FieldName:string;AttrName:string):TFieldDef;
var tmp:TAttrsGroup;
begin
  tmp:=FFieldList.FindItemByName(AttrName);
  assert(tmp<>nil,'FFieldList.FindItemByName(AttrName) == NIL');
  if tmp=nil then exit;
  result:=ExistAttrField(FieldName,tmp);
end;

function TRTFP.AddAttrField(FieldName:string;AttrName:string;
  FieldType:TFieldType;FieldSize:word):TFieldDef;
var tmp:TAttrsGroup;
begin
  tmp:=FFieldList.FindItemByName(AttrName);
  assert(tmp<>nil,'FFieldList.FindItemByName(AttrName) == NIL');
  if tmp=nil then exit;
  result:=AddAttrField(FieldName,tmp,FieldType,FieldSize);
end;

function TRTFP.DeleteAttrField(FieldName:string;AttrName:string):boolean;
var tmp:TAttrsGroup;
begin
  tmp:=FFieldList.FindItemByName(AttrName);
  assert(tmp<>nil,'FFieldList.FindItemByName(AttrName) == NIL');
  if tmp=nil then exit;
  result:=DeleteAttrField(FieldName,tmp);
end;




function TRTFP.AddImage(fullfilename:string):RTFP_ID;//新增一个图片到工程
begin

end;

procedure TRTFP.DeleteImage(IID:RTFP_ID);//移除指定IID的图片
begin

end;

function TRTFP.AddNote(fullfilename:string):RTFP_ID;//新增一个注解到工程
begin

end;

procedure TRTFP.DeleteNote(NID:RTFP_ID);//移除指定NID的注解
begin

end;

procedure TRTFP.ProjectPropertiesValidate(AValueListEditor:TValueListEditor);
begin
  AValueListEditor.Values['工程标题']:=Self.Title;
  AValueListEditor.Values['创建用户']:=Self.User;

  AValueListEditor.Values['创建日期']:=Self.Tag['创建日期'];
  AValueListEditor.Values['修改日期']:=Self.Tag['修改日期'];

  AValueListEditor.Values['PDF打开方式']:=Self.Tag['PDF打开方式'];
  AValueListEditor.Values['CAJ打开方式']:=Self.Tag['CAJ打开方式'];

  {
  attrNo:=0;
  repeat
    AValueListEditor.Values['属性组'+Usf.zeroplus(attrNo,2)]:=FAttrGroupList[AttrNo].Name;
    inc(attrNo);
  until (not FAttrGroupList[AttrNo].Enabled) or (attrNo>99);
  }
  //for AG in FFieldList do ??????;

end;

procedure TRTFP.ProjectPropertiesDataPost(AValueListEditor:TValueListEditor);
begin
  Self.Title:=AValueListEditor.Values['工程标题'];
  Self.User:=AValueListEditor.Values['创建用户'];

  Self.Tag['PDF打开方式']:=AValueListEditor.Values['PDF打开方式'];
  Self.Tag['CAJ打开方式']:=AValueListEditor.Values['CAJ打开方式'];

  //其他属性为只读

end;

procedure TRTFP.TableValidate;
var tmpDbf:TDbf;
    tmpFieldDef:TFieldDef;
    PID:RTFP_ID;
    pi,pj,pcol,max_attr:integer;
    attr_range:array[0..99] of record
      min,max:integer;
    end;//记录分表字段在总表中的范围
    fields_ref:array[0..9999]of record
      AG:TAttrsGroup;//nil表示PaperDB
      FI:Integer;
    end;
    fields_cnt,paperDB_cnt:integer;
    tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
    dat_type:TFieldType;

begin
  FPaperDS.Clear;
  tmpDbf:=FPaperDB;
  fields_cnt:=0;
  for pcol:=0 to tmpDbf.FieldDefs.Count-1 do
    begin
      tmpFieldDef:=tmpDbf.FieldDefs.Items[pcol];
      {
      case tmpFieldDef.Name of
        _Col_OID_,_Col_PID_,_Col_Paper_FileName_:
          begin
            }
            FPaperDS.FieldDefs.Add(tmpFieldDef.Name,tmpFieldDef.DataType,tmpFieldDef.Size);
            fields_ref[fields_cnt].AG:=nil;
            fields_ref[fields_cnt].FI:=tmpFieldDef.Index;
            inc(fields_cnt);
            {
          end
        else;
      end;
      }
    end;
  paperDB_cnt:=fields_cnt;
  pi:=-1;
  for tmpAG in FFieldList do begin
    inc(pi);
    attr_range[pi].max:=-1;
    attr_range[pi].min:=fields_cnt;
    if not tmpAG.GroupShown then continue;
    for tmpAF in tmpAG.FieldList do
      begin
        if not tmpAF.Shown then continue;
        attr_range[pi].max:=fields_cnt;
        tmpFieldDef:=tmpAF.FieldDef;

        dat_type:=tmpFieldDef.DataType;
        case dat_type of
          ftMemo,ftWideMemo,ftFmtMemo:
            FPaperDS.FieldDefs.Add(Usf.zeroplus(pi,2)+tmpFieldDef.Name,ftString,255);
          else
            FPaperDS.FieldDefs.Add(Usf.zeroplus(pi,2)+tmpFieldDef.Name,dat_type,tmpFieldDef.Size);
        end;
        fields_ref[fields_cnt].AG:=tmpAG;
        fields_ref[fields_cnt].FI:=tmpFieldDef.Index;
        inc(fields_cnt);
      end;
  end;
  max_attr:=pi;

  FPaperDS.CreateTable;
  FPaperDS.Open;
  FPaperDS.Last;

  tmpDbf:=FPaperDB;
  tmpDbf.First;

  if not tmpDbf.EOF then repeat
    FPaperDS.Append;
    for pi:=0 to paperDB_cnt-1 do
      begin
        with FPaperDS.Fields[pi] do case DataType of
          ftString,ftMemo,ftWideString,ftFixedWideChar,ftWideMemo{,ftFmtMemo,ftFixedChar}:FPaperDS.Fields[pi].AsString:=tmpDbf.Fields[fields_ref[pi].FI].AsString;
          ftBoolean:FPaperDS.Fields[pi].AsBoolean:=tmpDbf.Fields[fields_ref[pi].FI].AsBoolean;
          ftFloat:FPaperDS.Fields[pi].AsFloat:=tmpDbf.Fields[fields_ref[pi].FI].AsFloat;
          ftInteger,ftLargeint,ftSmallint,ftWord:FPaperDS.Fields[pi].AsLargeInt:=tmpDbf.Fields[fields_ref[pi].FI].AsLargeInt;
          ftDateTime,ftDate,ftTime:FPaperDS.Fields[pi].AsDateTime:=tmpDbf.Fields[fields_ref[pi].FI].AsDateTime;
          else assert(false,'FPaperDS.Fields[pi].DataType未预设。');
        end;
      end;
    tmpDbf.Next;
  until tmpDbf.EOF;

  for pj:=0 to max_attr do
    begin
      //if pj in table_enabled then BEGIN
        if attr_range[pj].min > attr_range[pj].max then continue;
        tmpDbf:=FFieldList[pj].Dbf;
        tmpDbf.First;

        if not tmpDbf.EOF then repeat
          PID:=tmpDbf.FieldByName(_Col_PID_).AsString;
          FPaperDS.First;
          if not FPaperDS.EOF then repeat
            if FPaperDS.FieldByName(_Col_PID_).AsString=PID then break;
            FPaperDS.Next;
          until FPaperDS.EOF;
          if not FPaperDS.EOF then begin
            FPaperDS.Edit;
            for pi:=attr_range[pj].min to attr_range[pj].max do begin
              case FPaperDS.Fields[pi].DataType of
                ftString,ftMemo,ftWideString,ftFixedWideChar,ftWideMemo{,ftFmtMemo,ftFixedChar}:
                  FPaperDS.Fields[pi].AsString:=tmpDbf.Fields[fields_ref[pi].FI].AsString;
                ftBoolean:
                  FPaperDS.Fields[pi].AsBoolean:=tmpDbf.Fields[fields_ref[pi].FI].AsBoolean;
                ftFloat:
                  FPaperDS.Fields[pi].AsFloat:=tmpDbf.Fields[fields_ref[pi].FI].AsFloat;
                ftInteger,ftLargeint,ftSmallint,ftWord:
                  FPaperDS.Fields[pi].AsLargeInt:=tmpDbf.Fields[fields_ref[pi].FI].AsLargeInt;
                ftDateTime,ftDate,ftTime:
                  FPaperDS.Fields[pi].AsDateTime:=tmpDbf.Fields[fields_ref[pi].FI].AsDateTime
                else assert(false,'FPaperDS.Fields[pi].DataType未预设。');
              end;
            end;
            FPaperDS.Post;
          end else assert(false,'分表有主表没有的PID');
          tmpDbf.Next;
        until tmpDbf.EOF;
      //END;
    end;
end;

procedure TRTFP.TableFilter(cmd:string);
var colname,method,value,stmp:string;
    col_num:integer;
begin
  //= eql         相等
  //!= <> neq     不相等
  //has           包含有
  //in            在其内
  StringReplace(cmd,'=',' eql ',[rfReplaceAll]);
  StringReplace(cmd,'!=',' neq ',[rfReplaceAll]);
  StringReplace(cmd,'<>',' neq ',[rfReplaceAll]);

  Auf.Script.IO_fptr.error:=nil;
  Auf.Script.IO_fptr.print:=nil;
  Auf.Script.IO_fptr.echo:=nil;
  Auf.ReadArgs(cmd);
  if Auf.ArgsCount<3 then exit;

  colname:=Auf.nargs[0].arg;
  method:=Auf.nargs[1].arg;
  value:=Auf.nargs[2].arg;

  col_num:=0;
  while col_num<FPaperDS.FieldDefs.Count do
    begin
      if FPaperDS.FieldDefs[col_num].Name=colname then break;
      inc(col_num);
    end;
  if col_num>=FPaperDS.FieldDefs.Count then exit;
  case FPaperDS.FieldDefs[col_num].DataType of
    ftMemo,ftString:;
    else begin assert(false,'暂不支持的筛选格式');exit end;
  end;

  with FPaperDS do
    begin
      if not Active then Open;//没有必要吧
      BeginUpdate;
      First;
      while not EOF do
        begin
          stmp:=Fields[Col_num].AsString;
          case lowercase(method) of
            'eql':if stmp<>value then Delete else Next;
            'neq':if stmp=value then Delete else Next;
            'in':if pos(stmp,value)<=0 then Delete else Next;
            'has':if pos(value,stmp)<=0 then Delete else Next;
            else exit;
          end;
        end;
      EndUpdate;
    end;
end;

procedure TRTFP.FieldListValidate(AListView:TListView);
var tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
begin
  AListView.BeginUpdate;
  AListView.Clear;
  for tmpAG in FFieldList do
    begin
      for tmpAF in tmpAG.FieldList do
        begin
          AListView.AddItem(tmpAG.Name+'\'+tmpAF.FieldName,tmpAF);
          AListView.Items[AListView.Items.Count-1].Checked:=tmpAF.Shown;
        end;
    end;
  AListView.EndUpdate;
  AListView.Repaint;
end;


procedure TRTFP.KlassListValidate(AListView:TListView);
var tmpKL:TKlass;
begin
  AListView.BeginUpdate;
  AListView.Clear;
  for tmpKL in FKlassList do
    begin
      AListView.AddItem(tmpKL.Name,tmpKL);
      AListView.Items[AListView.Items.Count-1].Checked:=tmpKL.FilterEnabled;
    end;
  AListView.EndUpdate;
  AListView.Repaint;
end;


{
function DBConvertToString(inp:boolean):string;
begin
  if inp then result:='true'
  else result:='false';
end;
}
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
    tmpDef:TFieldDef;
    tmpAttrName:string;
    tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
begin

  for tmpAG in FFieldList do
    begin
      with tmpAG.Dbf do
        begin
          First;
          while not EOF do
            begin
              if FieldByName(_Col_PID_).AsString=PID then break;
              Next;
            end;
        end;
      for tmpAF in tmpAG.FieldList do
        begin
          tmpDef:=tmpAF.FieldDef;
          if (tmpDef.Name<>'PID') and (tmpDef.Name<>'OID') then
            begin
              if tmpAG.Dbf.EOF then AValueListEditor.Values[tmpAG.Name+'#'+tmpDef.Name]:=''
              else case tmpDef.DataType of
                ftString,ftMemo,ftWideString,ftFixedWideChar,ftWideMemo{,ftFmtMemo,ftFixedChar}:
                  AValueListEditor.Values[tmpAG.Name+'#'+tmpDef.Name]:=tmpAG.Dbf.Fields[tmpDef.Index].AsString;
                ftBoolean:;
                ftFloat:
                  AValueListEditor.Values[tmpAG.Name+'#'+tmpDef.Name]:=DBConvertToString(tmpAG.Dbf.Fields[tmpDef.Index].AsFloat);
                ftInteger,ftLargeint,ftSmallint,ftWord:
                  AValueListEditor.Values[tmpAG.Name+'#'+tmpDef.Name]:=DBConvertToString(tmpAG.Dbf.Fields[tmpDef.Index].AsLargeInt);
                ftDateTime,ftDate,ftTime:
                  AValueListEditor.Values[tmpAG.Name+'#'+tmpDef.Name]:=DBConvertToString(tmpAG.Dbf.Fields[tmpDef.Index].AsDateTime);
                else assert(false,'ADataSet.Fields[pi].DataType未预设。');
              end;
            end;
        end;
    end;
  {
  attrNo:=0;
  AValueListEditor.Values['PID']:=PID;
  repeat
    tmpAttrName:=FFieldList[attrNo].Name;
    tmpFields:=FindAttrRecord(PID,tmpAttrName);
    if tmpFields<>nil then begin
      tmpDefs:=FFieldList[attrNo].Dbf.DbfFieldDefs;
      for defNo:=0 to tmpDefs.Count-1 do
        begin
          if (tmpDefs.Items[defNo].FieldName<>'PID') and (tmpDefs.Items[defNo].FieldName<>'OID') then case tmpDefs.Items[defNo].FieldType of
            ftString,ftMemo,ftWideString,ftFixedWideChar,ftWideMemo{,ftFmtMemo,ftFixedChar}:
              AValueListEditor.Values[tmpAttrName+'#'+tmpDefs.Items[defNo].FieldName]:=tmpFields[defNo].AsString;
            ftBoolean:{
              if tmpFields[defNo].AsBoolean then
                AValueListEditor.Values[tmpAttrName+'#'+tmpDefs[defNo].Name]:='true'
              else AValueListEditor.Values[tmpAttrName+'#'+tmpDefs[defNo].Name]:='false'};
            ftFloat:
              AValueListEditor.Values[tmpAttrName+'#'+tmpDefs.Items[defNo].FieldName]:=DBConvertToString(tmpFields[defNo].AsFloat);
            ftInteger,ftLargeint,ftSmallint,ftWord:
              AValueListEditor.Values[tmpAttrName+'#'+tmpDefs.Items[defNo].FieldName]:=DBConvertToString(tmpFields[defNo].AsLargeInt);
            ftDateTime,ftDate,ftTime:
              AValueListEditor.Values[tmpAttrName+'#'+tmpDefs.Items[defNo].FieldName]:=DBConvertToString(tmpFields[defNo].AsDateTime);
            else assert(false,'ADataSet.Fields[pi].DataType未预设。');
          end;
        end;
    end;
    inc(attrNo);
  until attrNo>=FFieldList.Count;
  ReNewCheckTimeWithoutChange(PID);//如果Change会导致Validate更新，这个需要重构以下UI逻辑，暂时先不管
  }
end;

procedure TRTFP.NodeViewDataPost(PID:RTFP_ID;AValueListEditor:TValueListEditor);
var ColName,tmpAttrName,FieldName:string;
    pcol,posi,len:integer;
begin
  BeginUpdate;
  for pcol:=1 to AValueListEditor.RowCount-1 do
    begin
      ColName:=AValueListEditor.Keys[pcol];
      if ColName<>'PID' then begin
        tmpAttrName:=AValueListEditor.Keys[pcol];
        FieldName:=tmpAttrName;
        len:=Length(tmpAttrName);
        posi:=Pos('#',tmpAttrName);
        delete(tmpAttrName,posi,len);
        delete(FieldName,1,posi);
        EditAttrField(PID,FFieldList.FindItemByName(tmpAttrName),FieldName,[aeFailIfNoPID,aeFailIfNoField],AValueListEditor.Values[ColName]);
      end;
    end;
  ReNewModifyTime(PID);//这一句在解决主表更新问题后移到EndUpdate之下
  EndUpdate;
end;

procedure TRTFP.FmtCmtValidate(PID:RTFP_ID;AttrName,FieldName:string;Memo:TMemo);
var tmpField:TField;
    tmpFields:TFields;
begin
  Memo.Clear;
  tmpFields:=FindAttrRecord(PID,AttrName);
  if tmpFields<>nil then begin
    tmpField:=FFieldList.FindItemByName(AttrName).Dbf.FieldByName(FieldName);
      case tmpField.DataType of
        ftMemo,ftWideMemo,ftFmtMemo:
          Memo.Lines.CommaText:=StringReplace(tmpFields.FieldByName(FieldName).AsString,Comma_Symbol,#13#10,[rfReplaceAll]);
        else exit;
      end;
  end;
  ReNewCheckTimeWithoutChange(PID);//如果Change会导致Validate更新，这个需要重构以下UI逻辑，暂时先不管
end;

procedure TRTFP.FmtCmtDataPost(PID:RTFP_ID;AttrName,FieldName:string;Memo:TMemo);
var tmpField:TField;
    tmpFields:TFields;
begin
  BeginUpdate;
  tmpFields:=FindAttrRecord(PID,AttrName);
  if tmpFields<>nil then begin
    tmpField:=FFieldList.FindItemByName(AttrName).Dbf.FieldByName(FieldName);
      case tmpField.DataType of
        ftMemo,ftWideMemo,ftFmtMemo:
          tmpFields.FieldByName(FieldName).AsString:=StringReplace(Memo.Lines.CommaText,#13#10,Comma_Symbol,[rfReplaceAll]);
        else exit;
      end;
  end;
  ReNewModifyTime(PID);//这一句在解决主表更新问题后移到EndUpdate之下
  EndUpdate;
end;

procedure TRTFP.AttrNameValidate(AItems:TStrings);
var tmpAG:TAttrsGroup;
begin
  AItems.Clear;
  for tmpAG in FFieldList do AItems.Add(tmpAG.Name);
end;

procedure TRTFP.FieldNameValidate(AAttrName:string;AItems:TStrings);
var tmpAF:TAttrsField;
begin
  AItems.Clear;
  for tmpAF in FFieldList.FindItemByName(AAttrName).FieldList do
    AItems.Add(tmpAF.FieldName);
end;

procedure TRTFP.SetUser(str:string);
begin
  if ProjectFileValue.Values['创建用户']<>str then
    begin
      ProjectFileValue.Values['创建用户']:=str;
      DataChange;
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
      DataChange;
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
      DataChange;
    end;
end;

function TRTFP.GetTag(index:string):string;
begin
  result:=ProjectFileValue.Values[index];
end;

function TRTFP.GetAttrFieldDataTypeS(attrNa,fieldNa:string):TFieldType;
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

class function TRTFP.IsProjectFile(filename:ansistring):boolean;
var ext:ansistring;
    po:integer;
begin
  result:=false;
  if filename = '' then exit;
  ext:=filename;
  po:=pos('.',ext);
  if po<=0 then exit
  else repeat
    delete(ext,1,po);
    po:=pos('.',ext);
  until po<=0;
  if lowercase(ext)='rtfp' then result:=true;
end;

class function TRTFP.IsRTFPID(PID:string):boolean;
var pi:integer;
begin
  result:=false;
  if length(PID)<>6 then exit;
  for pi:=1 to 6 do if not (PID[pi] in RTFP_ID_CHARSET) then exit;
  result:=true;
end;

{
class function TRTFP.BackupDbf(ADBF:TDbf):boolean;
var tmpDbf:TDbf;
    tmpDbfFieldDef:TDbfFieldDef;
    tmpField:TField;
    col,row:integer;
begin
  result:=false;
  if not assigned(ADBF) then exit;
  tmpDbf:=TDbf.Create(nil);

  ADBF.Open;
  tmpDbf.FilePathFull:=ADBF.FilePathFull;
  tmpDbf.TableName:=ADBF.TableName+'.bak';
  tmpDbf.TableLevel:=ADBF.TableLevel;
  col:=0;
  while col<ADBF.DbfFieldDefs.Count do
    begin
      tmpDbfFieldDef:=ADBF.DbfFieldDefs.Items[col];
      tmpDbf.DbfFieldDefs.Add(tmpDbfFieldDef.FieldName,tmpDbfFieldDef.FieldType,tmpDbfFieldDef.Size);
      inc(col);
    end;
  tmpDbf.CreateTable;
  tmpDbf.Open;
  ADBF.First;
  tmpDbf.First;
  while not ADBF.EOF do
    begin
      tmpDbf.Insert;
      row:=0;
      while row<tmpDbf.Fields.Count do
        begin
          tmpField:=ADBF.Fields[row];            //此处在新加字段时不能正常工作
          tmpDbf.Fields[row].Assign(tmpField);
          inc(row);
        end;
      tmpDbf.Post;
      ADBF.Next;
    end;
  tmpDbf.Close;
  tmpDbf.Free;
  result:=true;
end;

class function TRTFP.RecoverDbf(ADBF:TDbf):boolean;
var dbfpath,runfile,run_dbt,name_no_ext:string;
begin
  result:=false;

  ADBF.Close;

  dbfpath:=ADbf.FilePathFull;
  runfile:=ADbf.TableName;
  name_no_ext:=runfile;
  delete(name_no_ext,length(name_no_ext)-7,8);
  run_dbt:=name_no_ext+'_run.dbt';

  //此处没有存在检验
  TRTFP.FileCopy((dbfpath+runfile+'.bak'),(dbfpath+runfile),false);
  TRTFP.FileCopy((dbfpath+runfile+'.dbt'),(dbfpath+run_dbt),false);

  ADBF.Open;

  result:=true;
end;
}
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
  result:=false;
  ForceDirectories(filename);
end;

end.

