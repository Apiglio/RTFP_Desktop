//FmtCmt的覆盖提交保存提醒
//引用PDF里的图片
//字段选项化，进度表可以是checkboxlist的形式
//ACL_ListView折叠属性组时，字段不会随着子项勾选的取消而关闭




//{$define insert}
{$define test}

unit RTFP_definition;

{$mode objfpc}{$H+}
{$inline on}


interface

uses
  Classes, SysUtils, Dialogs, ValEdit, Windows, LazUTF8, StdCtrls, ComCtrls,
  ACL_ListView,
  {$ifndef insert}
  Apiglio_Useful, auf_ram_var, rtfp_pdfobj, rtfp_files, rtfp_class, rtfp_field,
  rtfp_constants,
  //AufScript_Frame,
  {$endif}
  db, dbf, dbf_fields, sqldb, memds;


type

  RTFP_ID=string;//六位64进制数

  TFieldTypeSet = set of TFieldType;
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


    //Attrs
  private
    function AddAttrs(AName:string):TAttrsGroup;
    function FindAttrs(AName:string):TAttrsGroup;
    procedure DeleteAttrs(AName:string);

    function AddField(AName:string;AAttrsName:string;AType:TFieldType;ASize:word):TAttrsField;
    function FindField(AName:string;AAttrsName:string):TAttrsField;
    procedure DeleteField(AName:string;AAttrsName:string);

    function CheckField(AName:string;AAttrsName:string;AType:TFieldType):boolean;
    function CheckField(AName:string;AAttrsName:string;ATypes:TFieldTypeSet):boolean;
    function GetField(AName:string;AAttrsName:string;PID:RTFP_ID):TField;

    procedure LoadAttrs;//包含了原先的New
    procedure SaveAttrs;
    procedure CloseAttrs;
    procedure CheckAttrs;unimplemented;//用于存档版本检验，追加和修改字段

  public
    function ReadFieldAsString(AName,AAttrsName:string;PID:RTFP_ID):string;
    function ReadFieldAsInteger(AName,AAttrsName:string;PID:RTFP_ID):int64;
    function ReadFieldAsBoolean(AName,AAttrsName:string;PID:RTFP_ID):boolean;
    function ReadFieldAsDateTime(AName,AAttrsName:string;PID:RTFP_ID):TDateTime;
    function ReadFieldAsDouble(AName,AAttrsName:string;PID:RTFP_ID):double;

    procedure EditFieldAsString(AName,AAttrsName:string;PID:RTFP_ID;value:string);
    procedure EditFieldAsInteger(AName,AAttrsName:string;PID:RTFP_ID;value:int64);
    procedure EditFieldAsBoolean(AName,AAttrsName:string;PID:RTFP_ID;value:boolean);
    procedure EditFieldAsDateTime(AName,AAttrsName:string;PID:RTFP_ID;value:TDateTime);
    procedure EditFieldAsDouble(AName,AAttrsName:string;PID:RTFP_ID;value:double);

    procedure ReadFieldAsMemo(AName,AAttrsName:string;PID:RTFP_ID;buf:TStrings);
    procedure EditFieldAsMemo(AName,AAttrsName:string;PID:RTFP_ID;buf:TStrings);


    //Klass
  private
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

  public
    procedure BeginUpdate;
    procedure EndUpdate;

  public //记录编辑
    //Paper
    function AddPaper(fullfilename:string;AddPaperMethod:TAddPaperMethod=apmFullBackup):RTFP_ID;//新增一个文献到工程
    function FindPaper(fullfilename:string):RTFP_ID;//查找具体文件在工程中的PID，未找到返回000000
    function DeletePaper(PID:RTFP_ID):boolean;//移除指定PID的文献
    function UpdatePaper(PID:RTFP_ID;fullfilename:string):boolean;//更新指定PID的文件

    procedure OpenPaper(PID:RTFP_ID;exename:string='');
    procedure OpenPaperAsPDF(PID:RTFP_ID);inline;
    procedure OpenPaperAsCAJ(PID:RTFP_ID);inline;
    procedure OpenPaperDir(PID:RTFP_ID);inline;
    procedure OpenPaperLink(PID:RTFP_ID);inline;

    //Image
    function AddImage(fullfilename:string):RTFP_ID;//新增一个图片到工程
    procedure DeleteImage(IID:RTFP_ID);//移除指定IID的图片

    //Notes
    function AddNote(fullfilename:string):RTFP_ID;//新增一个注解到工程
    procedure DeleteNote(NID:RTFP_ID);//移除指定NID的注解

    //Klass
    function KlassInclude(klassname:string;PID:RTFP_ID):boolean;
    function KlassExclude(klassname:string;PID:RTFP_ID):boolean;

    //References
  private
    function InitBasic(PID:RTFP_ID):TFields;
    procedure PostBasic;
    procedure ReEditBasic;

  public
    procedure LoadFromEStudy(PID:RTFP_ID;str:TStrings);
    procedure LoadFromRefWork(PID:RTFP_ID;str:TStrings);
    procedure LoadFromEndNote(PID:RTFP_ID;str:TStrings);
    procedure LoadFromNoteExpress(PID:RTFP_ID;str:TStrings);
    procedure LoadFromNoteFirst(PID:RTFP_ID;str:TStrings);

    procedure SaveToEStudy(PID:RTFP_ID;str:TStrings);
    procedure SaveToRefWork(PID:RTFP_ID;str:TStrings);
    procedure SaveToEndNote(PID:RTFP_ID;str:TStrings);
    procedure SaveToNoteExpress(PID:RTFP_ID;str:TStrings);
    procedure SaveToNoteFirst(PID:RTFP_ID;str:TStrings);

    procedure SetGBT7714(PID:RTFP_ID;str:string);
    procedure SetCAJCD(PID:RTFP_ID;str:string);
    procedure SetMLA(PID:RTFP_ID;str:string);
    procedure SetAPA(PID:RTFP_ID;str:string);
    procedure SetChaXin(PID:RTFP_ID;str:string);

    function GetGBT7714(PID:RTFP_ID):string;
    function GetCAJCD(PID:RTFP_ID):string;
    function GetMLA(PID:RTFP_ID):string;
    function GetAPA(PID:RTFP_ID):string;
    function GetChaXin(PID:RTFP_ID):string;



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
    procedure NodeViewDataPost(PID:RTFP_ID;AValueListEditor:TValueListEditor);unimplemented;


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

    class function FieldMinWidth(AFieldDef:TFieldDef):integer;
    class function FieldOptWidth(AFieldDef:TFieldDef):integer;


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
    class function MakeDir(filename:string):boolean;inline;
    class function OpenDir(pathname:string):boolean;inline;
    class function OpenFile(filename:string;exefile:string=''):boolean;inline;
    class function OpenLink(linkage:string):boolean;inline;

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


procedure aufunc_BeginUpdate(Sender:TObject);
begin
  CurrentRTFP.BeginUpdate;
end;

procedure aufunc_EndUpdate(Sender:TObject);
begin
  CurrentRTFP.EndUpdate;
end;

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

  if CurrentRTFP.CheckField(AFieldName,AAttrName,[ftString,ftMemo]) then
    begin
      CurrentRTFP.GetField(AFieldName,AAttrName,APID).AsString:=AMEMO;
      AufScpt.writeln('属性修改成功。');
    end
  else AufScpt.writeln('属性类型不符，修改失败。');

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

  if CurrentRTFP.CheckField(AFieldName,AAttrName,[ftString,ftMemo]) then
    begin
      AValue:=CurrentRTFP.GetField(AFieldName,AAttrName,APID).AsString;
      initiate_arv_str(AValue,arv);
      AufScpt.writeln('Fields['+AAttrName+','+AFieldName+']='+AValue);
    end
  else AufScpt.writeln('属性类型不符，读取失败。');

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

    Script.add_func('update.begin',@aufunc_BeginUpdate,'filename','开始更新模式');
    Script.add_func('update.end',@aufunc_EndUpdate,'filename','结束更新模式');


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
      //FieldChange;//为什么会在这个
    end;
  if tmpAG.IsEmpty then DeleteAttrs(tmpAG.Name);
  FieldChange;//应该在这
end;

function TRTFP.CheckField(AName:string;AAttrsName:string;AType:TFieldType):boolean;
begin
  result:=CheckField(AName,AAttrsName,[AType]);
end;

function TRTFP.CheckField(AName:string;AAttrsName:string;ATypes:TFieldTypeSet):boolean;
var tmpAF:TAttrsField;
begin
  result:=false;
  tmpAF:=FindField(AName,AAttrsName);
  if tmpAF=nil then exit;
  result:=tmpAF.FieldDef.DataType in ATypes;
end;

function TRTFP.GetField(AName:string;AAttrsName:string;PID:RTFP_ID):TField;
var tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
begin
  result:=nil;
  tmpAF:=FindField(AName,AAttrsName);
  if tmpAF=nil then exit;//所以没有的字段读取就会报错 nil.AsString之类的错误
  tmpAG:=FindAttrs(AAttrsName);
  with tmpAG.Dbf do
    begin
      if not Active then Open;
      First;
      while not EOF do
        begin
          if FieldByName(_Col_PID_).AsString=PID then break;
          Next;
        end;
      if EOF then begin
        Append;
        Edit;
        FieldByName(_Col_PID_).AsString:=PID;
        Post;
      end;
      result:=FieldByName(AName);
    end;
end;

function TRTFP.ReadFieldAsString(AName,AAttrsName:string;PID:RTFP_ID):string;
begin
  result:=GetField(AName,AAttrsName,PID).AsString;
end;

function TRTFP.ReadFieldAsInteger(AName,AAttrsName:string;PID:RTFP_ID):int64;
begin
  result:=GetField(AName,AAttrsName,PID).AsLargeInt;
end;

function TRTFP.ReadFieldAsBoolean(AName,AAttrsName:string;PID:RTFP_ID):boolean;
begin
  result:=GetField(AName,AAttrsName,PID).AsBoolean;
end;

function TRTFP.ReadFieldAsDateTime(AName,AAttrsName:string;PID:RTFP_ID):TDateTime;
begin
  result:=GetField(AName,AAttrsName,PID).AsDateTime;
end;

function TRTFP.ReadFieldAsDouble(AName,AAttrsName:string;PID:RTFP_ID):double;
begin
  result:=GetField(AName,AAttrsName,PID).AsFloat;
end;

procedure TRTFP.EditFieldAsString(AName,AAttrsName:string;PID:RTFP_ID;value:string);
var tmpAG:TAttrsGroup;
    tmpField:TField;
begin
  tmpField:=GetField(AName,AAttrsName,PID);
  tmpAG:=FindAttrs(AAttrsName);
  tmpAG.Dbf.Edit;
  tmpField.AsString:=value;
  tmpAG.Dbf.Post;
  DataChange;
end;

procedure TRTFP.EditFieldAsInteger(AName,AAttrsName:string;PID:RTFP_ID;value:int64);
var tmpAG:TAttrsGroup;
    tmpField:TField;
begin
  tmpField:=GetField(AName,AAttrsName,PID);
  tmpAG:=FindAttrs(AAttrsName);
  tmpAG.Dbf.Edit;
  tmpField.AsLargeInt:=value;
  tmpAG.Dbf.Post;
  DataChange;
end;

procedure TRTFP.EditFieldAsBoolean(AName,AAttrsName:string;PID:RTFP_ID;value:boolean);
var tmpAG:TAttrsGroup;
    tmpField:TField;
begin
  tmpField:=GetField(AName,AAttrsName,PID);
  tmpAG:=FindAttrs(AAttrsName);
  tmpAG.Dbf.Edit;
  tmpField.AsBoolean:=value;
  tmpAG.Dbf.Post;
  DataChange;
end;

procedure TRTFP.EditFieldAsDateTime(AName,AAttrsName:string;PID:RTFP_ID;value:TDateTime);
var tmpAG:TAttrsGroup;
    tmpField:TField;
begin
  tmpField:=GetField(AName,AAttrsName,PID);
  tmpAG:=FindAttrs(AAttrsName);
  tmpAG.Dbf.Edit;
  tmpField.AsDateTime:=value;
  tmpAG.Dbf.Post;
  DataChange;
end;

procedure TRTFP.EditFieldAsDouble(AName,AAttrsName:string;PID:RTFP_ID;value:double);
var tmpAG:TAttrsGroup;
    tmpField:TField;
begin
  tmpField:=GetField(AName,AAttrsName,PID);
  tmpAG:=FindAttrs(AAttrsName);
  tmpAG.Dbf.Edit;
  tmpField.AsFloat:=value;
  tmpAG.Dbf.Post;
  DataChange;
end;

procedure TRTFP.ReadFieldAsMemo(AName,AAttrsName:string;PID:RTFP_ID;buf:TStrings);
begin
  //buf.Assign(GetField(AName,AAttrsName,PID));
  buf.CommaText:=GetField(AName,AAttrsName,PID).AsString;
end;

procedure TRTFP.EditFieldAsMemo(AName,AAttrsName:string;PID:RTFP_ID;buf:TStrings);
var tmpAG:TAttrsGroup;
    tmpField:TField;
begin
  tmpField:=GetField(AName,AAttrsName,PID);
  tmpAG:=FindAttrs(AAttrsName);
  tmpAG.Dbf.Edit;
  //tmpField.Assign(buf);
  tmpField.AsString:=buf.CommaText;
  tmpAG.Dbf.Post;
  DataChange;
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

  //0 Unknown                                         未知
  //1 Journal Article / JournalArticle                期刊论文
  //2 Thesis                                          学位论文
  //3 Conference Proceeding(s)                        会议论文
  //4 Newspaper Article                               报纸
  //5 Book                                            图书
  //6 Standard / Legal Rule or Regulation / Reference 年鉴
  //60 Patent                                         专利
  //61 Other Article / TechReport                     其他成果
  //62 Standard / Legal Rule or Regulation            标准规范
  Dbf.FieldDefs.Add(_Col_basic_RefType_, ftString, 32, false);//引用类型
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

  BeginUpdate;

  Self.Tag['修改日期']:=TRTFP.GetDateTimeStr;

  SaveProjectFile;
  SaveUserList;
  SaveFormatList;
  SaveDbf('paper',Self.FPaperDB);
  SaveDbf('image',Self.FImageDB);
  SaveDbf('note',Self.FNotesDB);

  SaveAttrs;
  SaveKlass;

  EndUpdate;
  Change;

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

  BeginUpdate;

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
  EditFieldAsInteger(_Col_basic_Has_Ext_,_Attrs_Basic_,PID,0);

  //1-分类
  EditFieldAsBoolean(_Col_class_Is_Read_,_Attrs_Class_,PID,false);

  //2-注解
  //这里之后要考虑不是pdf或者pdf读取错误的情况
  //这不是一个好做法，会大量浪费算力，但是现在先让他爬起来吧，再优化
  EditFieldAsInteger(_Col_notes_User_,_Attrs_Notes_,PID,0);
  EditFieldAsDateTime(_Col_notes_CreateTime_,_Attrs_Notes_,PID,Now);
  EditFieldAsDateTime(_Col_notes_ModifyTime_,_Attrs_Notes_,PID,Now);
  EditFieldAsDateTime(_Col_notes_CheckTime_,_Attrs_Notes_,PID,Now);

  //3-元数据
  //这里之后要考虑不是pdf或者pdf读取错误的情况
  //这不是一个好做法，会大量浪费算力，但是现在先让他爬起来吧，再优化
  EditFieldAsString(_Col_metas_Title_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Title']^);
  EditFieldAsString(_Col_metas_Authors_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Author']^);
  EditFieldAsString(_Col_metas_Subject_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Subject']^);
  EditFieldAsString(_Col_metas_Keyword_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Keywords']^);
  EditFieldAsString(_Col_metas_Creator_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Creator']^);
  EditFieldAsString(_Col_metas_Produce_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Producer']^);
  EditFieldAsString(_Col_metas_CreDate_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:CreationDate']^);
  EditFieldAsString(_Col_metas_ModDate_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:ModDate']^);

  EndUpdate;

  if AddPaperMethod=apmFullBackup then begin
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
          case MessageDlg('删除确认','删除文献节点对应的文件可能会导致其他共用此文件的节点失去文件连接，并且操作后无法恢复，是否继续？',mtWarning,[mbYes,mbNo],0) of
            rnmbYes:TRTFP.FileDelete(FFilePath+FRootFolder+'\paper\'
                                    +FieldByName(_Col_Paper_Folder_).AsString
                                    +'\'+FieldByName(_Col_Paper_FileName_).AsString
                                    );
            rnmbNo:;
          end;
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

function TRTFP.UpdatePaper(PID:RTFP_ID;fullfilename:string):boolean;//更新指定PID的文件
var old_dir,old_file:string;
    old_backup:boolean;
    DateDir,FileName,TargetDir:string;
    tmpPDF:TRTFP_PDF;
begin
  result:=false;
  if not TRTFP.IsRTFPID(PID) then exit;

  with FPaperDB do begin
    if not Active then Open;
    First;
    while not EOF do
      begin
        if FieldByName(_Col_PID_).AsString=PID then begin
          break;
        end;
        Next;
      end;
    if EOF then begin
      MessageDlg('未找到记录','没有找到PID为'+PID+'的文献节点',mtError,[mbCancel],0);
      exit;
    end;
    old_backup:=FieldByName(_Col_Paper_Is_Backup_).AsBoolean;
    if old_backup then begin
      old_file:=FieldByName(_Col_Paper_FileName_).AsString;
      old_dir:=FieldByName(_Col_Paper_Folder_).AsString;
    end;
  end;

  DateDir:=TRTFP.GetDateDir;
  FileName:=ExtractFileName(fullfilename);

  TargetDir:=FFilePath+FRootFolder+'\paper\'+DateDir;
  if FileExists(TargetDir+'\'+FileName) then
    case MessageDlg('相同的备份路径','正在导入的文件“'+fullfilename
    +'”的默认备份地址存在重名，覆盖会导致两个文献节点共用一个备份文件。'
    +'若两个文件不相同，会导致旧版本备份文件被覆盖，且难以复原。'
    +'是否覆盖？',mtWarning,[mbYes,mbNo],0) of
      rnmbYes:{do nothing};
      rnmbNo:exit;
  end;

  tmpPDF:=TRTFP_PDF.Create(nil);
  tmpPDF.LoadPdf(fullfilename);

  BeginUpdate;

  //此时游标已经在PID位置
  with FPaperDB do begin
    Edit;
    FieldByName(_Col_Paper_Is_Backup_).AsBoolean:=true;
    FieldByName(_Col_Paper_Folder_).AsString:=DateDir;
    FieldByName(_Col_Paper_FileName_).AsString:=FileName;
    FieldByName(_Col_Paper_FileSize_).AsLargeInt:=tmpPDF.Size;
    FieldByName(_Col_Paper_FileHash_).AsString:=tmpPDF.Hash;
    Post;
  end;

  //2-注解
  EditFieldAsDateTime(_Col_notes_ModifyTime_,_Attrs_Notes_,PID,Now);

  //3-元数据
  //这里之后要考虑不是pdf或者pdf读取错误的情况
  //这不是一个好做法，会大量浪费算力，但是现在先让他爬起来吧，再优化
  EditFieldAsString(_Col_metas_Title_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Title']^);
  EditFieldAsString(_Col_metas_Authors_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Author']^);
  EditFieldAsString(_Col_metas_Subject_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Subject']^);
  EditFieldAsString(_Col_metas_Keyword_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Keywords']^);
  EditFieldAsString(_Col_metas_Creator_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Creator']^);
  EditFieldAsString(_Col_metas_Produce_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Producer']^);
  EditFieldAsString(_Col_metas_CreDate_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:CreationDate']^);
  EditFieldAsString(_Col_metas_ModDate_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:ModDate']^);

  EndUpdate;

  ForceDirectories(TargetDir);
  tmpPDF.CopyTo(TargetDir+'\'+FileName);//尚未加入长度检验
  if old_backup then begin
    TRTFP.FileDelete(FFilePath+FRootFolder+'\paper\'+old_dir+'\'+old_file);
    FPaperDB.FieldByName(_Col_Paper_Is_Backup_).AsBoolean:=true;
  end;

  tmpPDF.ClosePdf;
  tmpPDF.Free;

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
      {
      if exename='' then
        ShellExecute(0,'open',pchar('"'+filename+'"'),'','',SW_NORMAL)
      else
        ShellExecute(0,'open',pchar(exename),pchar('"'+filename+'"'),'',SW_NORMAL);
      }
      TRTFP.OpenFile(filename,exename);
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

procedure TRTFP.OpenPaperDir(PID:RTFP_ID);
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
        +FieldByName(_Col_Paper_Folder_).AsString+'\');
      TRTFP.OpenDir(filename);
    end else
      ShowMessage('非备份文献节点不能通过此方法打开！');
  end;
end;

procedure TRTFP.OpenPaperLink(PID:RTFP_ID);
var linkage:string;
begin
  linkage:=ReadFieldAsString(_Col_basic_Link_,_Attrs_Basic_,PID);
  if linkage<>'' then TRTFP.OpenLink(Linkage);
end;

function TRTFP.KlassInclude(klassname:string;PID:RTFP_ID):boolean;
var index:integer;
    stmp:TStringList;
begin
  result:=false;
  //索引文件更新
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
  //修改字段
  stmp:=TStringList.Create;
  stmp.Sorted:=true;
  try
    ReadFieldAsMemo(_Col_class_DefaultCl_,_Attrs_Class_,PID,stmp);
    if not stmp.Find(klassname,index) then stmp.Add(klassname);
    EditFieldAsMemo(_Col_class_DefaultCl_,_Attrs_Class_,PID,stmp);
  finally
    stmp.Free;
  end;

  DataChange;
  result:=true;
end;

function TRTFP.KlassExclude(klassname:string;PID:RTFP_ID):boolean;
var index:integer;
    stmp:TStringList;
begin
  result:=false;
  //索引文件更新
  index:=FKlassList.FindItemIndexByName(klassname);
  if index<0 then exit;
  with FKlassList[index].Dbf do begin
    if not Active then Open;
    First;
    while not EOF do
      begin
        if FieldByName(_Col_PID_).AsString = PID then begin Delete;break end;
        Next;
      end;
  end;
  //修改字段
  stmp:=TStringList.Create;
  stmp.Sorted:=true;
  try
    ReadFieldAsMemo(_Col_class_DefaultCl_,_Attrs_Class_,PID,stmp);
    if stmp.Find(klassname,index) then stmp.Delete(index);
    EditFieldAsMemo(_Col_class_DefaultCl_,_Attrs_Class_,PID,stmp);
  finally
    stmp.Free;
  end;

  DataChange;
  result:=true;
end;

procedure TRTFP.ReNewCreateTime(PID:RTFP_ID);
begin
  EditFieldAsDateTime(_Col_notes_CreateTime_,_Attrs_Notes_,PID,Now);
end;

procedure TRTFP.ReNewModifyTime(PID:RTFP_ID);
begin
  EditFieldAsDateTime(_Col_notes_ModifyTime_,_Attrs_Notes_,PID,Now);
end;

procedure TRTFP.ReNewCheckTime(PID:RTFP_ID);
begin
  EditFieldAsDateTime(_Col_notes_CheckTime_,_Attrs_Notes_,PID,Now);
end;

procedure TRTFP.ReNewModifyTimeWithoutChange(PID:RTFP_ID);
begin
  BeginUpdate;
  EditFieldAsDateTime(_Col_notes_ModifyTime_,_Attrs_Notes_,PID,Now);
  EndUpdate;
end;

procedure TRTFP.ReNewCheckTimeWithoutChange(PID:RTFP_ID);
begin
  BeginUpdate;
  EditFieldAsDateTime(_Col_notes_CheckTime_,_Attrs_Notes_,PID,Now);
  EndUpdate;
end;

procedure TRTFP.BeginUpdate;
begin
  FIsUpdating:=true;
end;

procedure TRTFP.EndUpdate;
begin
  FIsUpdating:=false;
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


function TRTFP.InitBasic(PID:RTFP_ID):TFields;
var AG:TAttrsGroup;
begin
  result:=nil;
  AG:=FindAttrs(_Attrs_Basic_);
  if AG=nil then AG:=AddAttrs(_Attrs_Basic_);
  //CheckBasicFields;
  with AG.Dbf do begin
    if not Active then Open;
    First;
    while not EOF do
      begin
        if FieldByName(_Col_PID_).AsString=PID then break;
        Next;
      end;
    if EOF then Append;
    Edit;
    result:=Fields;
  end;
end;

procedure TRTFP.PostBasic;
var AG:TAttrsGroup;
begin
  AG:=FindAttrs(_Attrs_Basic_);
  AG.Dbf.Post;
end;

procedure TRTFP.ReEditBasic;
var AG:TAttrsGroup;
begin
  AG:=FindAttrs(_Attrs_Basic_);
  AG.Dbf.Post;
  AG.Dbf.Edit;
end;

function decodeEStudyRefType(str:string):string;
begin
  case str of
    '1':result:='期刊论文';
    '2':result:='学位论文';
    '3':result:='会议论文';
    '4':result:='报纸';
    '5':result:='专著';
    '6':result:='年鉴';
    '60':result:='专利';
    '61':result:='其他文献';
    '62':result:='标准规范';
    else result:='未知';
  end;
end;

function encodeEStudyRefType(str:string):string;
begin
  case str of
    '期刊论文':result:='1';
    '学位论文':result:='2';
    '会议论文':result:='3';
    '报纸':result:='4';
    '专著':result:='5';
    '年鉴':result:='6';
    '专利':result:='60';
    '其他文献':result:='61';
    '标准规范':result:='62';
    else result:='0';
  end;
end;

function decodeEndNoteRefType(str:string):string;
begin
  case str of
    'Journal Article':result:='期刊论文';
    'Thesis':result:='学位论文';
    'Conference Proceedings':result:='会议论文';
    'Newspaper Article':result:='报纸';
    'Book':result:='专著';
    //'Legal Rule or Regulation':result:='年鉴';
    'Patent':result:='专利';
    'Other Article':result:='其他文献';
    'Legal Rule or Regulation':result:='标准规范';
    else result:='未知';
  end;
end;

function encodeEndNoteRefType(str:string):string;
begin
  case str of
    '期刊论文':result:='Journal Article';
    '学位论文':result:='Thesis';
    '会议论文':result:='Conference Proceedings';
    '报纸':result:='Newspaper Article';
    '专著':result:='Book';
    '年鉴':result:='Legal Rule or Regulation';
    '专利':result:='Patent';
    '其他文献':result:='Other Article';
    '标准规范':result:='Legal Rule or Regulation';
    else result:='Unknown';
  end;
end;

procedure TRTFP.LoadFromEStudy(PID:RTFP_ID;str:TStrings);
var stmp,header,attr:string;
    poss:integer;
    tmpDate:TDate;
    error_str:string;
begin
  error_str:=#13#10;
  with InitBasic(PID) do begin
    for stmp in str do begin
      poss:=pos(': ',stmp);
      if poss<=0 then continue;
      header:=stmp;
      attr:=stmp;
      delete(header,poss,length(stmp));
      delete(attr,1,poss+1);
      if attr='' then continue;

      try
        case header of
          'DataType':FieldByName(_Col_basic_RefType_).AsString:=decodeEStudyRefType(attr);
          'Author-作者','Author','作者':
            begin
              while attr[length(attr)]=';' do
                begin
                  delete(attr,length(attr),1);
                  if attr='' then break;
                end;
              FieldByName(_Col_basic_Author_).AsString:=attr;
            end;
          'Title-题名','Title','题名','Title-正标题','正标题':FieldByName(_Col_basic_Title_).AsString:=attr;
          'Source-刊名','Source','刊名','Source-学位授予单位',
          '学位授予单位','Source-报纸中文名','报纸中文名':
            FieldByName(_Col_basic_Source_).AsString:=attr;
          'Year-年','Year','年':FieldByName(_Col_basic_Year_).AsString:=attr;
          'PubTime-出版时间','PubTime','出版时间':
            begin
              try
                TryStrToDate(attr,tmpDate,'YYYYMMDD','-');
              except
              end;
              FieldByName(_Col_basic_PubTime_).AsDateTime:=tmpDate;
            end;
          'Period-期','Period','期':FieldByName(_Col_basic_Issue_).AsString:=attr;
          'Roll-卷','Roll','卷':FieldByName(_Col_basic_Volume_).AsString:=attr;
          'Keyword-关键词','Keyword','关键词':FieldByName(_Col_basic_Keyword_).AsString:=attr;
          'Summary-摘要','Summary','摘要','Summary-快照','快照':
            FieldByName(_Col_basic_Summary_).AsString:=attr;
          'PageCount-页数','PageCount','页数':FieldByName(_Col_basic_PageCount_).AsString:=attr;
          'Page-页码','Page','页码':FieldByName(_Col_basic_Page_).AsString:=attr;
          //'SrcDatabase-来源库':FieldByName(_Col_basic_来源库_).AsString:=attr;
          'Organ-机构','Organ','机构','Organ-大学','大学':FieldByName(_Col_basic_Organ_).AsString:=attr;
          'Link-链接','Link','链接':FieldByName(_Col_basic_Link_).AsString:=attr;
          //'Degree-学位','Degree','学位':FieldByName(_Col_basic_学位_).AsString:=attr;
          //'Teacher-导师','Teacher','导师':FieldByName(_Col_basic_导师_).AsString:=attr;

        end;
      except
        error_str:=error_str+'    '+header+#13#10;
      end;
      ReEditBasic;
    end;
  end;
  if error_str<>#13#10 then MessageDlg('导入错误','以下字段导入时发生错误：'+error_str,mtInformation,[mbOK],0);
  PostBasic;
  DataChange;
end;
procedure TRTFP.LoadFromRefWork(PID:RTFP_ID;str:TStrings);
begin
  ShowMessage('unimplemented');
end;
procedure TRTFP.LoadFromEndNote(PID:RTFP_ID;str:TStrings);
var stmp,attr:string;
    has_author:boolean;
begin
  has_author:=false;
  with InitBasic(PID) do begin
    for stmp in str do begin
      if length(stmp)<3 then continue;
      if (stmp[1]<>'%') or (stmp[3]<>' ') then continue;
      attr:=stmp;
      delete(attr,1,3);
      case stmp[2] of
        '0':FieldByName(_Col_basic_RefType_).AsString:=decodeEndNoteRefType(attr);
        'A':
          begin
            attr:=StringReplace(attr,' %A ',';',[rfReplaceAll]);
            if has_author then attr:=FieldByName(_Col_basic_Author_).AsString+';'+attr;
            FieldByName(_Col_basic_Author_).AsString:=attr;
            if not has_author then has_author:=true;
          end;
        '+':FieldByName(_Col_basic_Organ_).AsString:=attr;
        'T':FieldByName(_Col_basic_Title_).AsString:=attr;
        'J':FieldByName(_Col_basic_Source_).AsString:=attr;
        'D':FieldByName(_Col_basic_Year_).AsString:=attr;
        'V':FieldByName(_Col_basic_Issue_).AsString:=attr;
        'N':FieldByName(_Col_basic_Volume_).AsString:=attr;
        'K':FieldByName(_Col_basic_Keyword_).AsString:=attr;
        'X':FieldByName(_Col_basic_Summary_).AsString:=attr;
        'P':FieldByName(_Col_basic_Page_).AsString:=attr;
        '@':FieldByName(_Col_basic_ISBN_ISSN_).AsString:=attr;
        //'L':FieldByName(_Col_basic_期刊号).AsString:=attr;
        'W':FieldByName(_Col_basic_DataProv_).AsString:=attr;
        //'Y':FieldByName(_Col_basic_导师).AsString:=attr;
        //'I':FieldByName(_Col_basic_学校).AsString:=attr;
        //'9':FieldByName(_Col_basic_学位类型).AsString:=attr;

      end;
      ReEditBasic;
    end;
  end;
  PostBasic;
  DataChange;
end;
procedure TRTFP.LoadFromNoteExpress(PID:RTFP_ID;str:TStrings);
begin
  ShowMessage('unimplemented');
end;
procedure TRTFP.LoadFromNoteFirst(PID:RTFP_ID;str:TStrings);
begin
  ShowMessage('unimplemented');
end;

procedure TRTFP.SaveToEStudy(PID:RTFP_ID;str:TStrings);
begin
  ShowMessage('unimplemented');
end;
procedure TRTFP.SaveToRefWork(PID:RTFP_ID;str:TStrings);
begin
  ShowMessage('unimplemented');
end;
procedure TRTFP.SaveToEndNote(PID:RTFP_ID;str:TStrings);
var stmp:string;
    ntmp:integer;
begin
  str.Clear;
  with InitBasic(PID) do begin
    stmp:=FieldByName(_Col_basic_RefType_).AsString;
    if stmp<>'' then str.Add('%0 '+encodeEndNoteRefType(stmp));
    stmp:=FieldByName(_Col_basic_Author_).AsString;
    if stmp<>'' then str.Add('%A '+StringReplace(stmp,';',' %A ',[rfReplaceAll]));
    stmp:=FieldByName(_Col_basic_Organ_).AsString;
    if stmp<>'' then str.Add('%+ `'+stmp);
    stmp:=FieldByName(_Col_basic_Title_).AsString;
    if stmp<>'' then str.Add('%T '+stmp);
    stmp:=FieldByName(_Col_basic_Source_).AsString;
    if stmp<>'' then str.Add('%J '+stmp);
    ntmp:=FieldByName(_Col_basic_Year_).AsInteger;
    if ntmp<>0 then str.Add('%D '+IntToStr(ntmp));
    ntmp:=FieldByName(_Col_basic_Issue_).AsInteger;
    if ntmp<>0 then str.Add('%V '+IntToStr(ntmp));
    ntmp:=FieldByName(_Col_basic_Volume_).AsInteger;
    if ntmp<>0 then str.Add('%N '+IntToStr(ntmp));
    stmp:=FieldByName(_Col_basic_Keyword_).AsString;
    if stmp<>'' then str.Add('%K '+stmp);
    stmp:=FieldByName(_Col_basic_Summary_).AsString;
    if stmp<>'' then str.Add('%X '+stmp);
    stmp:=FieldByName(_Col_basic_Page_).AsString;
    if stmp<>'' then str.Add('%P '+stmp);
    stmp:=FieldByName(_Col_basic_ISBN_ISSN_).AsString;
    if stmp<>'' then str.Add('%@ '+stmp);
    //stmp:=FieldByName(_Col_basic_期刊号).AsString;
    //if stmp<>'' then str.Add('%L '+stmp);
    stmp:=FieldByName(_Col_basic_DataProv_).AsString;
    if stmp<>'' then str.Add('%W '+stmp);
    //stmp:=FieldByName(_Col_basic_导师).AsString;
    //if stmp<>'' then str.Add('%Y '+stmp);
    //stmp:=FieldByName(_Col_basic_学校).AsString;
    //if stmp<>'' then str.Add('%I '+stmp);
    //stmp:=FieldByName(_Col_basic_学位类型).AsString;
    //if stmp<>'' then str.Add('%9 '+stmp);
  end;
  PostBasic;
end;
procedure TRTFP.SaveToNoteExpress(PID:RTFP_ID;str:TStrings);
begin
  ShowMessage('unimplemented');
end;
procedure TRTFP.SaveToNoteFirst(PID:RTFP_ID;str:TStrings);
begin
  ShowMessage('unimplemented');
end;

procedure TRTFP.SetGBT7714(PID:RTFP_ID;str:string);
begin
  ShowMessage('unimplemented');
end;
procedure TRTFP.SetCAJCD(PID:RTFP_ID;str:string);
begin
  ShowMessage('unimplemented');
end;
procedure TRTFP.SetMLA(PID:RTFP_ID;str:string);
begin
  ShowMessage('unimplemented');
end;
procedure TRTFP.SetAPA(PID:RTFP_ID;str:string);
begin
  ShowMessage('unimplemented');
end;
procedure TRTFP.SetChaXin(PID:RTFP_ID;str:string);
begin
  ShowMessage('unimplemented');
end;

function TRTFP.GetGBT7714(PID:RTFP_ID):string;
begin
  ShowMessage('unimplemented');
end;
function TRTFP.GetCAJCD(PID:RTFP_ID):string;
begin
  ShowMessage('unimplemented');
end;
function TRTFP.GetMLA(PID:RTFP_ID):string;
begin
  ShowMessage('unimplemented');
end;
function TRTFP.GetAPA(PID:RTFP_ID):string;
begin
  ShowMessage('unimplemented');
end;
function TRTFP.GetChaXin(PID:RTFP_ID):string;
begin
  ShowMessage('unimplemented');
end;




procedure TRTFP.ProjectPropertiesValidate(AValueListEditor:TValueListEditor);
begin
  AValueListEditor.Values['工程标题']:=Self.Title;
  AValueListEditor.Values['创建用户']:=Self.User;

  AValueListEditor.Values['创建日期']:=Self.Tag['创建日期'];
  AValueListEditor.Values['修改日期']:=Self.Tag['修改日期'];

  AValueListEditor.Values['PDF打开方式']:=Self.Tag['PDF打开方式'];
  AValueListEditor.Values['CAJ打开方式']:=Self.Tag['CAJ打开方式'];

end;

procedure TRTFP.ProjectPropertiesDataPost(AValueListEditor:TValueListEditor);
begin
  Self.Title:=AValueListEditor.Values['工程标题'];
  Self.User:=AValueListEditor.Values['创建用户'];

  Self.Tag['PDF打开方式']:=AValueListEditor.Values['PDF打开方式'];
  Self.Tag['CAJ打开方式']:=AValueListEditor.Values['CAJ打开方式'];
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
    bm:TBookMark;
    init_rec_no1,init_rec_no2:longint;

begin
  BeginUpdate;
  bm:=FPaperDS.GetBookmark;
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

  IF FPaperDS.EOF and FPaperDS.BOF THEN ELSE BEGIN

  //这里要改成循环检索，不要从头检索了，太慢了
  for pj:=0 to max_attr do
    begin
      if attr_range[pj].min > attr_range[pj].max then continue;
      tmpDbf:=FFieldList[pj].Dbf;
      if tmpDbf.EOF and tmpDbf.BOF then continue;

      {
      if tmpDbf.EOF then tmpDbf.First;
      init_rec_no1:=tmpDbf.RecNo;
      repeat
        PID:=tmpDbf.FieldByName(_Col_PID_).AsString;
        if FPaperDS.EOF then FPaperDS.First;
        init_rec_no2:=FPaperDS.RecNo;
        repeat
          if FPaperDS.FieldByName(_Col_PID_).AsString=PID then
            begin
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
            end;
          FPaperDS.Next;
          if FPaperDS.EOF then FPaperDS.First;
        until FPaperDS.RecNo=init_rec_no2;
        tmpDbf.Next;
        if tmpDbf.EOF then tmpDbf.First;
      until tmpDbf.RecNo=init_rec_no1;
      }


      //{
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
      //}

    end;

  END;

  if FPaperDS.BookmarkValid(bm) then FPaperDS.GotoBookmark(bm);
  EndUpdate;
end;

procedure TRTFP.TableFilter(cmd:string);
var colname,method,value:string;
    col_num:integer;
begin
  //= eql         相等
  //!= <> neq     不相等
  //has           包含有
  //in            在其内
  //true          是否为真
  //false         是否为假
  //>    gtr      大于
  //>=   gtq      大等
  //<    les      小于
  //<=   leq      小等

  StringReplace(cmd,'=',' eql ',[rfReplaceAll]);
  StringReplace(cmd,'!=',' neq ',[rfReplaceAll]);
  StringReplace(cmd,'<>',' neq ',[rfReplaceAll]);
  StringReplace(cmd,'>',' gtr ',[rfReplaceAll]);
  StringReplace(cmd,'>=',' gtq ',[rfReplaceAll]);
  StringReplace(cmd,'<',' les ',[rfReplaceAll]);
  StringReplace(cmd,'<=',' leq ',[rfReplaceAll]);

  Auf.Script.IO_fptr.error:=nil;
  Auf.Script.IO_fptr.print:=nil;
  Auf.Script.IO_fptr.echo:=nil;
  Auf.ReadArgs(cmd);
  if Auf.ArgsCount<2 then exit;

  colname:=Auf.nargs[0].arg;
  method:=Auf.nargs[1].arg;
  value:=Auf.nargs[2].arg;

  case method of
    'true','false':;
    else if Auf.ArgsCount<3 then exit;
  end;

  col_num:=0;
  while col_num<FPaperDS.FieldDefs.Count do
    begin
      if FPaperDS.FieldDefs[col_num].Name=colname then break;
      inc(col_num);
    end;
  if col_num>=FPaperDS.FieldDefs.Count then exit;
  with FPaperDS do
    begin
      if not Active then Open;//没有必要吧
      BeginUpdate;
      First;
      while not EOF do
        begin
          case lowercase(method) of
            'eql':if Fields[Col_num].AsString<>value then Delete else Next;
            'neq':if Fields[Col_num].AsString=value then Delete else Next;
            'in':if pos(Fields[Col_num].AsString,value)<=0 then Delete else Next;
            'has':if pos(value,Fields[Col_num].AsString)<=0 then Delete else Next;
            'true':if not Fields[Col_num].AsBoolean then Delete else Next;
            'false':if Fields[Col_num].AsBoolean then Delete else Next;
            'gtr':if Fields[Col_num].AsLargeInt<=Usf.to_f(value) then Delete else Next;
            'gtq':if Fields[Col_num].AsLargeInt<Usf.to_f(value) then Delete else Next;
            'les':if Fields[Col_num].AsLargeInt>=Usf.to_f(value) then Delete else Next;
            'leq':if Fields[Col_num].AsLargeInt>Usf.to_f(value) then Delete else Next;
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
  (AListView as TACL_ListView).Clear;
  for tmpAG in FFieldList do
    begin
      for tmpAF in tmpAG.FieldList do
        begin
          (AListView as TACL_ListView).AddShellNodeItem(tmpAG.Name+'\'+tmpAF.FieldName,tmpAF,tmpAF.Shown);
        end;
    end;
  AListView.EndUpdate;
  AListView.Repaint;
end;


procedure TRTFP.KlassListValidate(AListView:TListView);
var tmpKL:TKlass;
begin
  AListView.BeginUpdate;
  (AListView as TACL_ListView).Clear;
  for tmpKL in FKlassList do
    begin
      (AListView as TACL_ListView).AddShellNodeItem(tmpKL.FullPath,tmpKL,tmpKL.FilterEnabled);
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
var tmpDef:TFieldDef;
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
  ReNewCheckTimeWithoutChange(PID);//如果Change会导致Validate更新，这个需要重构以下UI逻辑，暂时先不管
end;

procedure TRTFP.NodeViewDataPost(PID:RTFP_ID;AValueListEditor:TValueListEditor);
var ColName,tmpAttrName,FieldName:string;
    pcol,posi,len:integer;
    tmpAF:TAttrsField;
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
        tmpAF:=FindField(FieldName,tmpAttrName);
        case tmpAF.FieldDef.DataType of
          ftString,ftMemo,ftWideString,ftFixedWideChar,ftWideMemo{,ftFmtMemo,ftFixedChar}:
            EditFieldAsString(FieldName,tmpAttrName,PID,AValueListEditor.Values[ColName]);
          ftInteger,ftLargeint,ftSmallint,ftWord:
            EditFieldAsInteger(FieldName,tmpAttrName,PID,Usf.to_i(AValueListEditor.Values[ColName]));
          ftFloat:
            EditFieldAsDouble(FieldName,tmpAttrName,PID,Usf.to_f(AValueListEditor.Values[ColName]));
          //ftDateTime,ftDate,ftTime:
          //  EditFieldAsDateTime(FieldName,tmpAttrName,PID,StrToDateTime(AValueListEditor.Values[ColName]));
          else assert(false,'没有合适提交方式的字段类型！');
        end;
      end;
    end;
  EndUpdate;
  ReNewModifyTime(PID);
end;

procedure TRTFP.FmtCmtValidate(PID:RTFP_ID;AttrName,FieldName:string;Memo:TMemo);
begin
  Memo.Clear;
  if CheckField(FieldName,AttrName,[ftMemo,ftWideMemo,ftFmtMemo]) then begin
    Memo.Lines.CommaText:=StringReplace(ReadFieldAsString(FieldName,AttrName,PID),Comma_Symbol,#13#10,[rfReplaceAll]);
  end;
  ReNewCheckTimeWithoutChange(PID);//如果Change会导致Validate更新，这个需要重构以下UI逻辑，暂时先不管
end;

procedure TRTFP.FmtCmtDataPost(PID:RTFP_ID;AttrName,FieldName:string;Memo:TMemo);
begin
  BeginUpdate;
  if CheckField(FieldName,AttrName,[ftMemo,ftWideMemo,ftFmtMemo]) then begin
    EditFieldAsString(FieldName,AttrName,PID,StringReplace(Memo.Lines.CommaText,#13#10,Comma_Symbol,[rfReplaceAll]));
  end;
  EndUpdate;
  ReNewModifyTime(PID);
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
  if not assigned(CurrentRTFP) then exit;
  if not CurrentRTFP.IsOpen then exit;
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

class function TRTFP.FieldMinWidth(AFieldDef:TFieldDef):integer;
begin
  result:=40;
  case AFieldDef.DataType of
    ftBoolean:result:=40;
    ftMemo:result:=75;
    ftInteger,ftSmallint:result:=50;
    ftLargeint,ftFloat:result:=75;
    ftDateTime,ftDate,ftTime:result:=100;
    ftString:
      begin
        result:=AFieldDef.Size*8;
        if result>200 then result:=200;
      end;
  end;
end;

class function TRTFP.FieldOptWidth(AFieldDef:TFieldDef):integer;
var NameSize:integer;
begin
  case AFieldDef.Name of
    _Col_Paper_Folder_:begin result:=2;exit end;
    _Col_Paper_FileHash_:begin result:=2;exit end;
    _Col_Paper_FileSize_:begin result:=2;exit end;
    _Col_OID_:begin result:=2;exit end;
    else ;
  end;
  result:=40;
  NameSize:=length(AFieldDef.Name)*8+16;
  if NameSize>80 then NameSize:=80;
  case AFieldDef.DataType of
    ftBoolean:result:=40;
    ftMemo:result:=75;
    ftInteger,ftSmallint:result:=50;
    ftLargeint,ftFloat:result:=75;
    ftDateTime,ftDate,ftTime:result:=100;
    ftString:
      begin
        result:=AFieldDef.Size*8;
        if result>200 then result:=200;
      end;
  end;
  result:=max(result,NameSize);
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
  result:=ForceDirectories(filename);
end;

class function TRTFP.OpenDir(pathname:string):boolean;
begin
  ShellExecute(0,'open','explorer.exe',pchar('"'+pathname+'"'),'',SW_NORMAL);
end;

class function TRTFP.OpenFile(filename:string;exefile:string=''):boolean;
begin
  if exefile='' then
    ShellExecute(0,'open',pchar('"'+filename+'"'),'','',SW_NORMAL)
  else
    ShellExecute(0,'open',pchar(exefile),pchar('"'+filename+'"'),'',SW_NORMAL);
end;

class function TRTFP.OpenLink(linkage:string):boolean;
begin
  ShellExecute(0,'open',pchar(linkage),'','',SW_NORMAL);
end;

end.

