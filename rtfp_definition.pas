//引用PDF里的图片
//字段选项化，进度表可以是checkboxlist的形式
//网页下载要研究一下JS
//字段更新日志(有必要吗)
//增刊期数的导入有问题
//Memo字段的搜索
//统一NodeEdit部分的编辑保存询问，下方的几个Tab共用一套Modified
//尽快将所有弹窗统一样式（在做了，有点小问题，按键中文或者自动布局还没有处理好）
//TKlass准备增加一个TKlassGroup类，和Attrs一样格式，这样才能保证ACL_ListView可以不重新折叠
//FormatEdit的管理
//增加替换URL的加载模式用以适用不同的webvpn
//每一个formatEditComponent增加Modified属性用来判断是否修改，在editable和uneditable之间加一个freeze
//uneditable改为提交数据时提示不能修改
//FWaitForm加进度条
//FormatEdit没有的字段要有专门的表示
//“待注脚知识元”
//FormatEdit快捷键提交
//截图转文字想想办法，试试内嵌python
//单元格设色属性、分类与属性组折叠等界面属性需要储存
//FormatEdit中的Image通道化不能立刻更新！！！              //procedure TFmtImage.BandSolo(band:byte);
//纳入分类要两次以上，不知道啥原因
//分类字段清除后字段数据还在dbf中，没有pack
//新建工程后的属性列表全部展开，而非打开工程后的全部折叠
//我他妈服了，DBF的文件错误也太多了吧？？？？
//异常关闭的恢复
//formatEditComponent在图像字段数据有误时的解决方案需要明细


//{$define insert}
{$define test}

unit RTFP_definition;

{$mode objfpc}{$H+}
{$inline on}


interface

uses
  Classes, SysUtils, Dialogs, ValEdit, LazUTF8, StdCtrls, ComCtrls, ExtCtrls, Forms,
  ACL_ListView, Controls, Graphics,

  {$ifdef Windows}
  Windows,
  {$endif}

  {$ifndef insert}
  Apiglio_Useful, auf_ram_var, rtfp_pdfobj, rtfp_files, rtfp_class, rtfp_field,
  rtfp_constants, rtfp_type, rtfp_tags, rtfp_format_component, rtfp_dialog, rtfp_misc,
  {$endif}
  db, dbf, dbf_common, dbf_fields, sqldb, memds;


type
  {
  RTFP_ID=string;//六位64进制数
  TPIDNotifyEvent = procedure(Sender:TObject;PID:RTFP_ID) of object;

  TFieldTypeSet = set of TFieldType;
  TAttrExtendUnit = (aeFailIfNoPID,aeFailIfNoField,aeFailIfTypeDismatch,
                     aeCreateIfNoField,aeForceEditIfTypeDismatch);
  TAttrExtend = set of TAttrExtendUnit;
  TablesUse = set of byte;
  TAddPaperMethod = (apmFullBackup,apmCutBackup,apmAddress,apmWebsite,apmReference);
  //几种文档入库方式: 复制备份/本地链接/网址链接/数据入库

  TSimChkOption = (scoFileName,scoTitle,scoFileHash,scoWeblnk,scoDOI,
                   scoMetaTitle,scoMetaSubject,scoMetaCreator,scoMetaProduce,
                   scoEqual,scoContain,scoHalffit,scoHalffitUnsigned,  //匹配模式：完全相等、包含和半长度匹配(典型/无符号)
                   scoDB,scoDS);                                       //匹配总体：PaperDB、PaperDS

  TSimChkOptions = set of TSimChkOption;
  }
  TFieldSelectMode = (fsmMain,fsmVice,fsmBoth,fsmNone);
  PFieldSelectOption = ^TFieldSelectOption;
  TFieldSelectOption = record
    field:TAttrsField;
    select_mode:TFieldSelectMode;
  end;
  TFieldSelectOptions = TList;

  AttrsError=class(Exception)
  end;
  AttrsNoPIDErr=class(AttrsError)
  end;
  AttrsNoFieldErr=class(AttrsError)
  end;
  AttrsTypeDismatchErr=class(AttrsError)
  end;

  TRTFP_Auf=class(TAuf)
  public
    RTFP:TObject;
  end;

  TRTFP = class(TComponent)
  private
    FProjectTags:TTags;
    FPaperDB,FImageDB,FNotesDB:TDbf;
    FUserList,FFormatList:TStringList;

    FKlassList:TKlassList;
    FFileList:TRTFP_FileList;
    FFieldList:TAttrsGroupList;

  private
    FAuf:TAuf;
    FFilePath:string;//完整路径
    FFileName:string;//文件名
    FFileFullName:string;//完整文件名
    FRootFolder:string;//根文件夹（不带拓展名的文件名前加点）
  protected
    function GetCurrentPathFull:string;
  public
    property CurrentFileFull:string read FFileFullName;
    property CurrentPathFull:string read GetCurrentPathFull;

  protected
    procedure SetUser(str:string);
    function GetUser:string;
    procedure SetTitle(str:string);
    function GetTitle:string;
    procedure SetVersion(str:string);
    function GetVersion:string;

    procedure SetTag(index:string;str:string);
    function GetTag(index:string):string;

    function GetOpenPdfExe:ansistring;
    function GetOpenCajExe:ansistring;

    function GetPaperCount:integer;
    function GetBackupPaperCount:integer;
    function GetExternPaperCount:integer;
    function GetWeblnkPaperCount:integer;

  public //工程基本属性
    property User:string read GetUser write SetUser;
    property Title:string read GetTitle write SetTitle;
    property Version:string read GetVersion write SetVersion;
    property OpenPdfExe:ansistring read GetOpenPdfExe;
    property OpenCajExe:ansistring read GetOpenCajExe;

    property Tag[index:string]:string read GetTag write SetTag;

    property UserList:TStringList read FUserList;
    property FormatList:TStringList read FFormatList;
    property KlassList:TKlassList read FKlassList;
    property FieldList:TAttrsGroupList read FFieldList;

    property CountPaper:integer read GetPaperCount;
    property CountBackupPaper:integer read GetBackupPaperCount;
    property CountExternPaper:integer read GetExternPaperCount;
    property CountWeblnkPaper:integer read GetWeblnkPaperCount;

  public
    procedure SetAuf(AAuf:TAuf);
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
    function PackDbf(Dbf:TDbf):boolean;


  public //工程状态选项记录



    procedure LoadProjectOption(AAuf:TAuf);
    procedure SaveProjectOption(filename:string='');

  public //FormatEdit
    function AddFormatDefault:boolean;
    function AddFormatEditNull(filename:string):boolean;
    function RenFormatEdit(filename,newname:string):boolean;
    function DelFormatEdit(filename:string):boolean;
  private
    procedure LoadFormatEditList;
    procedure LoadFormatList;inline;
    function SaveFormatList:boolean;inline;
    function CloseFormatList:boolean;inline;

    //Attrs
  public
    function AddAttrs(AName:string):TAttrsGroup;
    function FindAttrs(AName:string):TAttrsGroup;
    procedure DeleteAttrs(AName:string);

    function AddField(AName:string;AAttrsName:string;AType:TFieldType{;ASize:word}):TAttrsField;
    function FindField(AName:string;AAttrsName:string):TAttrsField;
    procedure DeleteField(AName:string;AAttrsName:string);

    function CheckField(AName:string;AAttrsName:string;AType:TFieldType):boolean;
    function CheckField(AName:string;AAttrsName:string;ATypes:TFieldTypeSet):boolean;
    function GetField(AName:string;AAttrsName:string;PID:RTFP_ID;NewPidIfNotExists:boolean):TField;
  private
    procedure LoadAttrs;//包含了原先的New
    procedure SaveAttrs;
    procedure CloseAttrs;
    procedure CheckAttrs;unimplemented;//用于存档版本检验，追加和修改字段

  public
    function GetFieldType(attrNa,fieldNa:string):TFieldType;

    function ReadBasicField(AAttrsName:string;PID:RTFP_ID):string;//和GetPaperAttrs重复
    procedure EditBasicField(AAttrsName:string;PID:RTFP_ID;value:string);
    function ReadBasicBool(AAttrsName:string;PID:RTFP_ID):boolean;
    procedure EditBasicBool(AAttrsName:string;PID:RTFP_ID;value:boolean);

    function ReadFieldAsString(AName,AAttrsName:string;PID:RTFP_ID;AE:TAttrExtend):string;
    function ReadFieldAsInteger(AName,AAttrsName:string;PID:RTFP_ID;AE:TAttrExtend):int64;
    function ReadFieldAsBoolean(AName,AAttrsName:string;PID:RTFP_ID;AE:TAttrExtend):boolean;
    function ReadFieldAsDateTime(AName,AAttrsName:string;PID:RTFP_ID;AE:TAttrExtend):TDateTime;
    function ReadFieldAsDouble(AName,AAttrsName:string;PID:RTFP_ID;AE:TAttrExtend):double;

    procedure EditFieldAsString(AName,AAttrsName:string;PID:RTFP_ID;value:string;AE:TAttrExtend);
    procedure EditFieldAsInteger(AName,AAttrsName:string;PID:RTFP_ID;value:int64;AE:TAttrExtend);
    procedure EditFieldAsBoolean(AName,AAttrsName:string;PID:RTFP_ID;value:boolean;AE:TAttrExtend);
    procedure EditFieldAsDateTime(AName,AAttrsName:string;PID:RTFP_ID;value:TDateTime;AE:TAttrExtend);
    procedure EditFieldAsDouble(AName,AAttrsName:string;PID:RTFP_ID;value:double;AE:TAttrExtend);

    procedure ReadFieldAsMemo(AName,AAttrsName:string;PID:RTFP_ID;buf:TStrings;AE:TAttrExtend);
    procedure EditFieldAsMemo(AName,AAttrsName:string;PID:RTFP_ID;buf:TStrings;AE:TAttrExtend);
    procedure ReadFieldAsBitmap(AName,AAttrsName:string;PID:RTFP_ID;buf:Graphics.TBitMap;AE:TAttrExtend);
    procedure EditFieldAsBitmap(AName,AAttrsName:string;PID:RTFP_ID;buf:Graphics.TBitMap;AE:TAttrExtend);

    //Klass
  public
    function AddKlass(klassname:string;pathname:string='\'):TKlass;
    function FindKlass(klassname:string):TKlass;
    procedure DeleteKlass(klassname:string);
  private
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

  public //记录编辑
    //Paper
    function AddPaper(fullfilename:string;AddPaperMethod:TAddPaperMethod=apmFullBackup):RTFP_ID;//新增一个文献到工程
    function FindPaper(fullfilename:string):RTFP_ID;//查找具体文件在工程中的PID，未找到返回000000
    function DeletePaper(PID:RTFP_ID;PreserveFileNoAsk:boolean=false):boolean;//移除指定PID的文献，第二参数true在MergePaper中使用
    function UpdatePaper(PID:RTFP_ID;fullfilename:string;AddPaperMethod:TAddPaperMethod):boolean;//更新指定PID的文件
    function MergePaper(PID_Main,PID_Vice:RTFP_ID;AFieldSelectOption:TFieldSelectOptions):boolean;//合并两个文献节点

    procedure GetPIDList(AList:TStrings);
    procedure GetPIDList_DS(AList:TStrings);
    procedure GetSimilarPIDList(AList:TStrings;ASimChkOption:TSimChkOptions;PB:TProgressBar=nil);
    function GetPaperAttrs(AFieldName:string;PID:RTFP_ID):string;deprecated;
    procedure GetPaperKlass(PID:RTFP_ID;str:TStrings);

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
    function KlassIncludeFromCombo(PID:RTFP_ID;active:boolean):boolean;//若显示不止一个分类，弹出选项由用户选择分类

    //References
  private
    function InitBasic(PID:RTFP_ID):TFields;
    procedure PostBasic;
    procedure EditBasic;
    procedure ReEditBasic;

  public
    procedure LoadFromEStudy(PID:RTFP_ID;str:TStrings);
    procedure LoadFromRefWork(PID:RTFP_ID;str:TStrings);
    procedure LoadFromEndNote(PID:RTFP_ID;str:TStrings);
    procedure LoadFromNoteExpress(PID:RTFP_ID;str:TStrings);
    procedure LoadFromNoteFirst(PID:RTFP_ID;str:TStrings);
    procedure LoadFromRIS(PID:RTFP_ID;str:TStrings);

    procedure SaveToEStudy(PID:RTFP_ID;str:TStrings);
    procedure SaveToRefWork(PID:RTFP_ID;str:TStrings);
    procedure SaveToEndNote(PID:RTFP_ID;str:TStrings);
    procedure SaveToNoteExpress(PID:RTFP_ID;str:TStrings);
    procedure SaveToNoteFirst(PID:RTFP_ID;str:TStrings);
    procedure SaveToRIS(PID:RTFP_ID;str:TStrings);

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

    function GetRef_InOrder(PID:RTFP_ID):string;
    function GetRef_AurYear(PID:RTFP_ID):string;

    procedure ImportPapersFromEStudy(str:TStrings;DefaultCl:TKlass);
    procedure ImportPapersFromRefWork(str:TStrings;DefaultCl:TKlass);
    procedure ImportPapersFromEndNote(str:TStrings;DefaultCl:TKlass);
    procedure ImportPapersFromNoteExpress(str:TStrings;DefaultCl:TKlass);
    procedure ImportPapersFromNoteFirst(str:TStrings;DefaultCl:TKlass);
    procedure ImportPapersFromRIS(str:TStrings;DefaultCl:TKlass);

  private //显示连接
    FPaperDS:TMemDataSet;
    FPaperDSFieldDefs:TList;
    FFormatEditComponentList:TList;


  public //连接显示
    property PaperDS:TMemDataSet read FPaperDS;//筛选后的总表，直接连接DBGrid
    property PaperDSFieldDefs:TList read FPaperDSFieldDefs write FPaperDSFieldDefs;
    property FormatComponents:TList read FFormatEditComponentList;

  public //连接显示

    procedure UpdatePIDExpr(PID:RTFP_ID;AufScpt:TAufScript);//将选中的节点PID赋值给@CPID

    procedure ProjectPropertiesValidate(AValueListEditor:TValueListEditor);
    procedure ProjectPropertiesDataPost(AValueListEditor:TValueListEditor);

    procedure RebuildMainGrid;
    procedure UpdateCurrentRec(PID:RTFP_ID);
    procedure TableFilter(cmd:string);

    procedure FieldListValidate(AListView:TListView);
    procedure KlassListValidate(AListView:TListView);

    //procedure NodeViewValidate(PID:RTFP_ID;AValueListEditor:TValueListEditor);
    //procedure NodeViewDataPost(PID:RTFP_ID;AValueListEditor:TValueListEditor);

    procedure FmtCmtValidate(PID:RTFP_ID;AttrName,FieldName:string;Memo:TMemo);
    procedure FmtCmtDataPost(PID:RTFP_ID;AttrName,FieldName:string;Memo:TMemo);
    procedure AttrNameValidate(AItems:TStrings);
    procedure FieldNameValidate(AAttrName:string;AItems:TStrings);

    procedure FormatEditScrollBoxResize(Sender:TObject);
    procedure FormatEditBuild(AScrollBox:TScrollBox;AFormatFile:string);
    procedure FormatEditBuild(AScrollBox:TScrollBox;AFormat:TStrings);
    procedure FormatEditClear(AScrollBox:TScrollBox);
    procedure FormatEditValidate(PID:string);
    procedure FormatEditDataPost(PID:string);

  private
    FIsOpen:boolean;
    FIsChanged:boolean;
    //FIsUpdating:boolean;//true时不触发onChange
    FUpdatingLevel:integer;//为0时触发onChange，每次BeginUpdate+1，EndUpdate-1

    FOnNew,FOnNewDone:TNotifyEvent;
    FOnOpen,FOnOpenDone:TNotifyEvent;
    FOnSave,FOnSaveDone:TNotifyEvent;
    FOnSaveAs,FOnSaveAsDone:TNotifyEvent;
    FOnClose,FOnCloseDone:TNotifyEvent;

    //FOnTableValidateDone:TNotifyEvent;
    FOnMainGridRebuilding,FOnMainGridRebuildDone:TNotifyEvent;

    FOnFirstEdit,FOnChange:TNotifyEvent;
    FOnDataChange,FOnFieldChange,FOnRecordChange:TNotifyEvent;
    FOnClassChange,FOnUsersChange,FOnFormatListChange:TNotifyEvent;

  protected
    function GetIsUpdating:boolean;

  public
    property IsOpen:boolean read FIsOpen;
    property IsChanged:boolean read FIsChanged;
    property IsUpdating:boolean read GetIsUpdating;
  public
    procedure BeginUpdate;
    procedure EndUpdate;
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

    //property OnTableValidateDone:TNotifyEvent read FOnTableValidateDone write FOnTableValidateDone;
    property OnMainGridRebuilding:TNotifyEvent read FOnMainGridRebuilding write FOnMainGridRebuilding;
    property OnMainGridRebuildDone:TNotifyEvent read FOnMainGridRebuildDone write FOnMainGridRebuildDone;

    property onFirstEdit:TNotifyEvent read FOnFirstEdit write FOnFirstEdit;
    property onChange:TNotifyEvent read FOnChange write FOnChange;
    //以下On*Change事件会触发OnChange
    property onDataChange:TNotifyEvent read FOnDataChange write FOnDataChange;
    property onFieldChange:TNotifyEvent read FOnFieldChange write FOnFieldChange;
    property onRecordChange:TNotifyEvent read FOnRecordChange write FOnRecordChange;
    property onClassChange:TNotifyEvent read FOnClassChange write FOnClassChange;
    property onUsersChange:TNotifyEvent read FOnUsersChange write FOnUsersChange;
    property onFormatListChange:TNotifyEvent read FOnFormatListChange write FOnFormatListChange;

  public
    procedure Change;//用于标记工程已经发生改变，如果之前未改变，会触发OnFirstEdit
    procedure DataChange(PID:RTFP_ID);//数据修改，也会触发Change事件
    procedure FieldChange;//字段修改，也会触发DataChange和Change事件
    procedure RecordChange;//记录修改，也会触发DataChange和Change事件
    procedure FieldAndRecordChange(not_change_at_the_beginning:boolean=false);//记录和字段同时修改，也会触发DataChange和Change事件
    procedure ClassChange(not_change_at_the_beginning:boolean=false);//分类修改，也会触发Change事件
    procedure UsersChange;//用户列表修改，也会触发Change事件
    procedure FormatListChange;//编辑样式修改，也会触发Change事件


  protected//与存档版本更新有关
    procedure Update_0_1_1_alpha_18;
    procedure Update_0_1_2_alpha_8;unimplemented;

  public//与存档版本更新有关
    procedure Update(save_version:string);

  {类方法}
  public
    class function NumToID(Num:dword):RTFP_ID;
    class function IDToNum(ID:RTFP_ID):dword;

    class function GetDateTimeStr:string;inline;
    class function GetDateDir:string;inline;

    class function IsProjectFile(filename:ansistring):boolean;
    class function IsKlassName(klassname:ansistring):boolean;
    class function IsAttrsName(attrsname:ansistring):boolean;
    class function IsFieldName(fieldname:ansistring):boolean;
    class function IsRTFPID(PID:string):boolean;

    class function FieldMinWidth(AFieldDef:TFieldDef):integer;
    class function FieldOptWidth(AFieldDef:TFieldDef):integer;


    //class function BackupDbf(ADBF:TDbf):boolean;
    //class function RecoverDbf(ADBF:TDbf):boolean;

    class function CanBuildName(projname:string):boolean;
    class function CanBuildPath(pathname:string):boolean;
    class function CanBuildPLen(pathname:string):boolean;
    class function CanBuildFile(fullname:string):boolean;
    class function CanBuildDisc(discchar:char):boolean;

    class function FileHash(AFileStream:TStream):string;//返回一个239长度的文件Hash
    class function FileCopy(source,dest:string;bFailIfExist:boolean):boolean;//utf8的string版本
    class function FileDelete(source:string):boolean;//utf8的string版本
    class function FileMove(source,dest:string;bFailIfExist:boolean):boolean;
    class function FileRename(oldname,newname:string):boolean;
    class function MakeDir(filename:string):boolean;inline;
    class function OpenDir(filename:string):boolean;inline;
    class function OpenFile(filename:string;exefile:string=''):boolean;inline;
    class function OpenLink(linkage:string):boolean;inline;

    class function VersionCheck(check,target:string):boolean;

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
    arv:TAufRamVar;
    PID:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,filename) then exit;
  if AAuf.ArgsCount>2 then
    begin
      if not AAuf.TryArgToARV(2,6,6,[ARV_Char],arv) then exit;
    end
  else arv.VarType:=ARV_Raw;
  PID:=CurrentRTFP.AddPaper(filename);
  if arv.VarType=ARV_Raw then
    begin
      if PID<>'000000' then AufScpt.writeln('新节点['+PID+']已生成。')
      else AufScpt.writeln('节点创建失败！');
    end
  else initiate_arv_str(PID,arv);
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
  if CurrentRTFP.DeletePaper(PID) then AufScpt.writeln('节点['+PID+']删除成功。')
  else AufScpt.writeln('节点['+PID+']删除失败！');

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

  CurrentRTFP.EditFieldAsString(AFieldName,AAttrName,APID,AMEMO,[aeCreateIfNoField,aeForceEditIfTypeDismatch]);


end;
procedure aufunc_ReadAttr(Sender:TObject);//attr.read PID,AttrName,FieldName,out
var AufScpt:TAufScript;
    AAuf:TAuf;
    APID,AFieldName,AAttrName,AValue:string;
    arv:TAufRamVar;
    show_message:boolean;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(4) then exit;
  if not AAuf.TryArgToString(1,APID) then exit;
  if not AAuf.TryArgToString(2,AAttrName) then exit;
  if not AAuf.TryArgToString(3,AFieldName) then exit;
  if AAuf.ArgsCount>4 then
    begin
      AAuf.TryArgToARV(4,256,256,[ARV_Char],arv);
      show_message:=false;
    end
  else show_message:=true;

  try
    AValue:=CurrentRTFP.ReadFieldAsString(AFieldName,AAttrName,APID,[aeFailIfNoPID,aeFailIfNoField]);
  except
    on AttrsNoPIDErr do begin AufScpt.writeln('找不到节点，读取失败。');AValue:='~NPErr';end;
    on AttrsNoFieldErr do begin AufScpt.writeln('找不到字段，读取失败。');AValue:='~NFErr';end;
    on AttrsTypeDismatchErr do begin AufScpt.writeln('属性类型不符，读取失败。');AValue:='~TDErr';end;
  end;
  if show_message then AufScpt.writeln('Fields['+AAttrName+','+AFieldName+']='+AValue)
  else initiate_arv_str(AValue,arv);

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
    //AFieldSize:byte;
    dt:TFieldType;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs({5}4) then exit;
  if not AAuf.TryArgToString(1,AAttrName) then exit;
  if not AAuf.TryArgToString(2,AFieldName) then exit;
  if not AAuf.TryArgToString(3,AFieldType) then exit;
  //if not AAuf.TryArgToByte(4,AFieldSize) then exit;

  case lowercase(AFieldType) of
    'memo':dt:=ftMemo;
    'string','str':dt:=ftString;
    'largeint','long':dt:=ftLargeInt;
    'boolean','bool':dt:=ftBoolean;
    'smallint','small':dt:=ftSmallInt;
    'float','double':dt:=ftFloat;
    'date':dt:=ftDate;
    'time':dt:=ftTime;
    'datetime':dt:=ftDateTime;
    else begin
      AufScpt.writeln('无效的字段类型，字段未创建。');
      exit;
    end;
  end;

  CurrentRTFP.AddField(AFieldName,AAttrName,dt{,AFieldSize});
  AufScpt.writeln('字段创建成功。');
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
  AufScpt.writeln('字段删除成功。');
end;

procedure aufunc_RebuildFormatEdit(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
    filename:string;
    str:TStringList;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,filename) then exit;
  filename:=CurrentRTFP.FFilePath+CurrentRTFP.FRootFolder+'\format\'+filename;
  if FileExists(filename) then begin
    str:=TStringList.Create;
    try
      str.LoadFromFile(filename);
      CurrentRTFP.FormatEditClear(FormDesktop.ScrollBox_Node_FormatEdit);
      CurrentRTFP.FormatEditBuild(FormDesktop.ScrollBox_Node_FormatEdit,str);
      AufScpt.writeln('成功加载'+filename+'布局文件。');
    finally
      str.Free;
    end;
  end else AufScpt.writeln('未找到'+filename+'布局文件！');
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

procedure aufunc_PID_First(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
    PID:string;
    arv:TAufRamVar;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToARV(1,6,6,[ARV_Char],arv) then exit;
  with CurrentRTFP.FPaperDB do begin
    if not Active then Open;
    First;
    PID:=FieldByName(_Col_PID_).AsString;
  end;
  initiate_arv_str(PID,arv);
end;

procedure aufunc_PID_NextJump(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
    pid:string;
    arv:TAufRamVar;
    addr:pRam;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(3) then exit;
  if not AAuf.TryArgToARV(1,6,6,[ARV_Char],arv) then exit;
  if not AAuf.TryArgToAddr(2,addr) then exit;
  PID:=arv_to_s(arv);
  with CurrentRTFP.FPaperDB do begin
    if not Active then Open;
    First;
    repeat
      if FieldByName(_Col_PID_).AsString=PID then break;
      Next;
    until EOF;
    Next;
    if not EOF then begin
      initiate_arv_str(FieldByName(_Col_PID_).AsString,arv);
      AufScpt.jump_addr(addr);
    end else begin
      initiate_arv_str('000000',arv);
      //AufScpt.next_addr;
    end;
  end;
end;





procedure aufunc_set_field_option(Sender:TObject);//option.attrs.set Attrs Field Key value
var AufScpt:TAufScript;
    AAuf:TAuf;
    NA,NF,NO,stmp:string;
    AG:TAttrsGroup;
    AF:TAttrsField;
    slon:longint;
    function getbo(str:string):boolean;
    begin
      case lowercase(str) of
        'on','t','true','1':result:=true;
        else result:=false;
      end;
    end;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(5) then exit;
  if not AAuf.TryArgToString(1,NA) then exit;
  if not AAuf.TryArgToString(2,NF) then exit;
  if not AAuf.TryArgToString(3,NO) then exit;
  case lowercase(NO) of
    'visible','checked','folded':
      begin
        if not AAuf.TryArgToString(4,stmp) then exit;
        AG:=CurrentRTFP.FieldList.FindItemByName(NA);
        if AG=nil then begin
          AufScpt.send_error('错误：无属性组“'+NA+'”。');
          exit;
        end;
        if lowercase(NO[1])='f' then
          begin
            AG.GroupShown:=getbo(stmp);
            exit;
          end;
        AF:=AG.FieldList.FindItemByName(NF);
        if AF=nil then begin
          AufScpt.send_error('错误：无属性“'+NF+'”。');
          exit;
        end;
        AF.Shown:=getbo(stmp);
      end;
    'width','w','display_width':
      begin
        if not AAuf.TryArgToLong(4,slon) then exit;
        AG:=CurrentRTFP.FieldList.FindItemByName(NA);
        if AG=nil then begin
          AufScpt.send_error('错误：无属性组“'+NA+'”。');
          exit;
        end;
        AF:=AG.FieldList.FindItemByName(NF);
        if AF=nil then begin
          AufScpt.send_error('错误：无属性“'+NF+'”。');
          exit;
        end;
        AF.FFieldDisplayOption.display_width:=slon;
      end;
    else
      begin
        AufScpt.send_error('错误：key名称无意义。');
      end;
  end;


end;

procedure aufunc_update_case(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
    stmp,ppid:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(2) then exit;
  if not AAuf.TryArgToString(1,stmp) then exit;
  if not AAuf.TryArgToString(2,ppid) then ppid:='000000';
  case lowercase(stmp) of
    'rebuild_mg':CurrentRTFP.RebuildMainGrid;
    'update_cur':CurrentRTFP.UpdateCurrentRec(ppid);
    'change':CurrentRTFP.Change;
    'datachange':CurrentRTFP.DataChange(ppid);
    'fieldchange':CurrentRTFP.FieldChange;
    'recordchange':CurrentRTFP.RecordChange;
    'classchange':CurrentRTFP.ClassChange;
    else AufScpt.writeln('无效的更新测试');
  end;
end;

{$ifdef test}

procedure aufunc_test(Sender:TObject);
var AufScpt:TAufScript;
    AAuf:TAuf;
    check,target:string;
begin
  AufScpt:=Sender as TAufScript;
  AAuf:=AufScpt.Auf as TAuf;
  if not AAuf.CheckArgs(3) then exit;
  if not AAuf.TryArgToString(1,check) then exit;
  if not AAuf.TryArgToString(2,target) then exit;

  if TRTFP.VersionCheck(check,target) then
    AufScpt.writeln('T') else AufScpt.writeln('F');


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


    Script.add_func('paper.add',@aufunc_AddPaper,'filename','新建Paper节点');
    Script.add_func('paper.del',@aufunc_DeletePaper,'PID','删除Paper节点');

    Script.add_func('attrs.rec.edit',@aufunc_EditAttr,'PID,AttrName,FieldName,Memo','修改PID节点中第AttrNo表的FieldName字段为Memo');
    Script.add_func('attrs.rec.read',@aufunc_ReadAttr,'PID,AttrName,FieldName,arv','修改PID节点中第AttrNo表的FieldName字段为Memo');

    //Script.add_func('attrs.ag.add',@aufunc_AddAttrGroup,'AttrName','在第AttrNo表中创建FieldName字段');
    //Script.add_func('attrs.ag.del',@aufunc_DelAttrGroup,'AttrName','在第AttrNo表中创建FieldName字段');
    Script.add_func('attrs.af.add',@aufunc_AddAttrField,'AttrName,FieldName','在第AttrNo表中创建FieldName字段');
    Script.add_func('attrs.af.del',@aufunc_DelAttrField,'AttrName,FieldName','在第AttrNo表中创建FieldName字段');

    Script.add_func('class.add',@aufunc_addKlass,'KlassName, Path','创建分类表');
    Script.add_func('class.del',@aufunc_DeleteKlass,'KlassName','删除分类表');
    Script.add_func('class.include',@aufunc_KlassInclude,'KlassName, PID','将PID节点加入分类');
    Script.add_func('class.exclude',@aufunc_KlassExclude,'KlassName, PID','将PID节点移除分类');


    Script.add_func('pdf.meta',@aufunc_ShowMeta,'filename','检查pdf文件的meta数据');
    Script.add_func('pdf.view',@aufunc_ShowView,'filename,page','预览pdf的page页');

    Script.add_func('update.begin',@aufunc_BeginUpdate,'filename','开始更新模式');
    Script.add_func('update.end',@aufunc_EndUpdate,'filename','结束更新模式');
    Script.add_func('update.test',@aufunc_update_case,'mode','测试更新过程');


    Script.add_func('fmt.rebuild',@aufunc_RebuildFormatEdit,'filename','从filename中加载FormatEdit布局');
    //把FmtCmp改掉，取消泛型

    Script.add_func('hash',@aufunc_FileHash,'filename','返回FileHash');
    Script.add_func('save',@aufunc_save,'','强制保存');

    Script.add_func('pid.first',@aufunc_PID_First,'@str','寻找第一个PID，并赋值给@str');
    Script.add_func('pid.next_jump',@aufunc_PID_NextJump,'@str,:addr','寻找第下一个PID，下一个存在则赋值给@str并跳转到:addr');



    Script.add_func('option.attrs.set',@aufunc_set_field_option,'attrs,field,key,value','字段显示设置');


    {$ifdef test}
    Script.add_func('test',@aufunc_test,'*arg','测试');
    {$endif}


  end;
end;








constructor TRTFP.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);

  FPaperDS:=TMemDataset.Create(Self);
  PaperDSFieldDefs:=TList.Create;
  FFormatEditComponentList:=TList.Create;

  //ProjectFileValue:=TValueListEditor.Create(nil);
  //ProjectFileValue.Parent:=AOwner;
  //ProjectFileValue.Hide;
  FProjectTags:=TTags.Create;

  FPaperDB:=TDbf.Create(Self);
  FImageDB:=TDbf.Create(Self);
  FNotesDB:=TDbf.Create(Self);



  FKlassList:=TKlassList.Create(Self);
  FFileList:=TRTFP_FileList.Create(Self,'');
  FFieldList:=TAttrsGroupList.Create(Self);

  FUserList:=TStringList.Create;
  FFormatList:=TStringList.Create;
  FFormatList.Sorted:=true;

  FFilePath:='';
  FFileName:='';

  FIsChanged:=false;
  FIsOpen:=false;
  //FIsUpdating:=false;
  FUpdatingLevel:=0;

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

  //FOnTableValidateDone:=nil;
  FOnMainGridRebuildDone:=nil;
  FOnMainGridRebuilding:=nil;

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

  //ProjectFileValue.Free;
  FProjectTags.Free;

  FPaperDS.Free;
  PaperDSFieldDefs.Free;
  FFormatEditComponentList.Free;

  inherited Destroy;
end;

procedure TRTFP.SetAuf(AAuf:TAuf);
begin
  FAuf:=AAuf;
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
    if not Dbf.Active then Dbf.Open;
    Dbf.CloseIndexFile('id');
    Dbf.DeleteIndex('id');
    Dbf.Close;

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

function TRTFP.PackDbf(Dbf:TDbf):boolean;
begin
  //Dbf.Exclusive := True;
  if not Dbf.Active then Dbf.Open;
  Dbf.PackTable;
  // let's also rebuild all the indexes
  Dbf.RegenerateIndexes;
  Dbf.Close;
  //Dbf.Exclusive := False;
  Dbf.Open;
end;

function TRTFP.AddAttrs(AName:string):TAttrsGroup;
var tmp:TAttrsGroup;
begin
  result:=nil;
  if not TRTFP.IsAttrsName(AName) then exit;
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
    tmp.LoadFieldListFromDbf;
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

function TRTFP.AddField(AName:string;AAttrsName:string;AType:TFieldType{;ASize:word}):TAttrsField;
var tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
begin
  result:=nil;
  if not TRTFP.IsAttrsName(AAttrsName) then exit;
  if not TRTFP.IsFieldName(AName) then exit;
  tmpAG:=FindAttrs(AAttrsName);
  if tmpAG=nil then tmpAG:=AddAttrs(AAttrsName);
  tmpAF:=tmpAG.FieldList.FindItemByName(AName);
  if tmpAF=nil then
    with tmpAG do begin
      if not Dbf.Active then Dbf.Open;
      Dbf.TryExclusive;
      case AType of
        ftString:Dbf.DbfFieldDefs.Add(AName,AType,16);
        ftFloat:Dbf.DbfFieldDefs.Add(AName,AType,8);
        else Dbf.DbfFieldDefs.Add(AName,AType{,ASize});
      end;
      Dbf.PackTable;
      Dbf.Close;
      Dbf.Open;
      Dbf.RegenerateIndexes;
      tmpAG.AddField(Dbf.FieldDefs.Find(AName));//LoadFieldListFromDbf;
      FieldChange;
    end;
  result:=tmpAG.FieldList.FindItemByName(AName);
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
      tmpAG.DelField(AName);//LoadFieldListFromDbf;
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

function TRTFP.GetField(AName:string;AAttrsName:string;PID:RTFP_ID;NewPidIfNotExists:boolean):TField;
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
      IndexName:='id';
      if not SearchKey(PID,stEqual) then begin
        if not NewPidIfNotExists then exit;
        Append;
        Edit;
        FieldByName(_Col_PID_).AsString:=PID;
        Post;
      end;
      result:=FieldByName(AName);
    end;

end;

function TRTFP.GetFieldType(attrNa,fieldNa:string):TFieldType;
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

function TRTFP.ReadBasicField(AAttrsName:string;PID:RTFP_ID):string;
begin
  with FPaperDB do begin
    if not Active then Open;
    IndexName:='id';
    if not SearchKey(PID,stEqual) then
      begin
        assert(false,'未找到PID');
        exit;
      end;
    result:=FieldByName(AAttrsName).AsString;
  end;
end;

procedure TRTFP.EditBasicField(AAttrsName:string;PID:RTFP_ID;value:string);
begin
  with FPaperDB do begin
    if not Active then Open;
    IndexName:='id';
    if not SearchKey(PID,stEqual) then
      begin
        assert(false,'未找到PID');
        exit;
      end;
    Edit;
    FieldByName(AAttrsName).AsString:=value;
    Post;
    DataChange(PID);
  end;
end;

function TRTFP.ReadBasicBool(AAttrsName:string;PID:RTFP_ID):boolean;
begin
  with FPaperDB do begin
    if not Active then Open;
    IndexName:='id';
    if not SearchKey(PID,stEqual) then
      begin
        assert(false,'未找到PID');
        exit;
      end;
    result:=FieldByName(AAttrsName).AsBoolean;
  end;
end;

procedure TRTFP.EditBasicBool(AAttrsName:string;PID:RTFP_ID;value:boolean);
begin
  with FPaperDB do begin
    if not Active then Open;
    IndexName:='id';
    if not SearchKey(PID,stEqual) then
      begin
        assert(false,'未找到PID');
        exit;
      end;
    Edit;
    FieldByName(AAttrsName).AsBoolean:=value;
    Post;
    DataChange(PID);
  end;
end;

function TRTFP.ReadFieldAsString(AName,AAttrsName:string;PID:RTFP_ID;AE:TAttrExtend):string;
var tmpField:TField;
begin
  result:='';
  if GetFieldType(AAttrsName,AName)=ftUnknown then
    begin
      if aeFailIfNoField in AE then
        raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
      else exit;
    end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    result:=tmpField.AsString
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

function TRTFP.ReadFieldAsInteger(AName,AAttrsName:string;PID:RTFP_ID;AE:TAttrExtend):int64;
var tmpField:TField;
begin
  result:=0;
  if GetFieldType(AAttrsName,AName)=ftUnknown then
    begin
      if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
      else exit;
    end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    result:=tmpField.AsLargeInt
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

function TRTFP.ReadFieldAsBoolean(AName,AAttrsName:string;PID:RTFP_ID;AE:TAttrExtend):boolean;
var tmpField:TField;
begin
  result:=false;
  if GetFieldType(AAttrsName,AName)=ftUnknown then
    begin
      if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
      else exit;
    end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    result:=tmpField.AsBoolean
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

function TRTFP.ReadFieldAsDateTime(AName,AAttrsName:string;PID:RTFP_ID;AE:TAttrExtend):TDateTime;
var tmpField:TField;
begin
  result:=0;
  if GetFieldType(AAttrsName,AName)=ftUnknown then
    begin
      if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
      else exit;
    end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    result:=tmpField.AsDateTime
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

function TRTFP.ReadFieldAsDouble(AName,AAttrsName:string;PID:RTFP_ID;AE:TAttrExtend):double;
var tmpField:TField;
begin
  result:=0;
  if GetFieldType(AAttrsName,AName)=ftUnknown then
    begin
      if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
      else exit;
    end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    result:=tmpField.AsFloat
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

procedure TRTFP.EditFieldAsString(AName,AAttrsName:string;PID:RTFP_ID;value:string;AE:TAttrExtend);
var tmpAG:TAttrsGroup;
    tmpField:TField;
begin
  case GetFieldType(AAttrsName,AName) of
    ftUnknown:
      begin
        if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
        else begin
          if aeCreateIfNoField in AE then
            begin
              AddField(AName,AAttrsName,ftString{,255});
            end
          else exit;
        end;
      end;
    ftString:;
    else
      begin
        if aeFailIfTypeDismatch in AE then raise AttrsTypeDismatchErr.Create('字段'+AName+'.'+AAttrsName+'类型错误！')
        else begin
          if aeForceEditIfTypeDismatch in AE then
          else exit;
        end;
      end;
  end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    begin
      tmpAG:=FindAttrs(AAttrsName);
      tmpAG.Dbf.Edit;
      tmpField.AsString:=value;
      tmpAG.Dbf.Post;
      DataChange(PID);
    end
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

procedure TRTFP.EditFieldAsInteger(AName,AAttrsName:string;PID:RTFP_ID;value:int64;AE:TAttrExtend);
var tmpAG:TAttrsGroup;
    tmpField:TField;
begin
  case GetFieldType(AAttrsName,AName) of
    ftUnknown:
      begin
        if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
        else begin
          if aeCreateIfNoField in AE then
            begin
              AddField(AName,AAttrsName,ftLargeint{,0});
            end
          else exit;
        end;
      end;
    ftInteger,ftLargeint,ftSmallint:;
    else
      begin
        if aeFailIfTypeDismatch in AE then raise AttrsTypeDismatchErr.Create('字段'+AName+'.'+AAttrsName+'类型错误！')
        else begin
          if aeForceEditIfTypeDismatch in AE then
          else exit;
        end;
      end;
  end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    begin
      tmpAG:=FindAttrs(AAttrsName);
      tmpAG.Dbf.Edit;
      tmpField.AsInteger:=value;
      tmpAG.Dbf.Post;
      DataChange(PID);
    end
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

procedure TRTFP.EditFieldAsBoolean(AName,AAttrsName:string;PID:RTFP_ID;value:boolean;AE:TAttrExtend);
var tmpAG:TAttrsGroup;
    tmpField:TField;
begin
  case GetFieldType(AAttrsName,AName) of
    ftUnknown:
      begin
        if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
        else begin
          if aeCreateIfNoField in AE then
            begin
              AddField(AName,AAttrsName,ftBoolean{,0});
            end
          else exit;
        end;
      end;
    ftBoolean:;
    else
      begin
        if aeFailIfTypeDismatch in AE then raise AttrsTypeDismatchErr.Create('字段'+AName+'.'+AAttrsName+'类型错误！')
        else begin
          if aeForceEditIfTypeDismatch in AE then
          else exit;
        end;
      end;
  end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    begin
      tmpAG:=FindAttrs(AAttrsName);
      tmpAG.Dbf.Edit;
      tmpField.AsBoolean:=value;
      tmpAG.Dbf.Post;
      DataChange(PID);
    end
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

procedure TRTFP.EditFieldAsDateTime(AName,AAttrsName:string;PID:RTFP_ID;value:TDateTime;AE:TAttrExtend);
var tmpAG:TAttrsGroup;
    tmpField:TField;
begin
  case GetFieldType(AAttrsName,AName) of
    ftUnknown:
      begin
        if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
        else begin
          if aeCreateIfNoField in AE then
            begin
              AddField(AName,AAttrsName,ftDateTime{,0});
            end
          else exit;
        end;
      end;
    ftDate,ftDateTime,ftTime:;
    else
      begin
        if aeFailIfTypeDismatch in AE then raise AttrsTypeDismatchErr.Create('字段'+AName+'.'+AAttrsName+'类型错误！')
        else begin
          if aeForceEditIfTypeDismatch in AE then
          else exit;
        end;
      end;
  end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    begin
      tmpAG:=FindAttrs(AAttrsName);
      tmpAG.Dbf.Edit;
      tmpField.AsDateTime:=value;
      tmpAG.Dbf.Post;
      DataChange(PID);
    end
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

procedure TRTFP.EditFieldAsDouble(AName,AAttrsName:string;PID:RTFP_ID;value:double;AE:TAttrExtend);
var tmpAG:TAttrsGroup;
    tmpField:TField;
begin
  case GetFieldType(AAttrsName,AName) of
    ftUnknown:
      begin
        if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
        else begin
          if aeCreateIfNoField in AE then
            begin
              AddField(AName,AAttrsName,ftFloat{,0});
            end
          else exit;
        end;
      end;
    ftFloat:;
    else
      begin
        if aeFailIfTypeDismatch in AE then raise AttrsTypeDismatchErr.Create('字段'+AName+'.'+AAttrsName+'类型错误！')
        else begin
          if aeForceEditIfTypeDismatch in AE then
          else exit;
        end;
      end;
  end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    begin
      tmpAG:=FindAttrs(AAttrsName);
      tmpAG.Dbf.Edit;
      tmpField.AsFloat:=value;
      tmpAG.Dbf.Post;
      DataChange(PID);
    end
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

procedure TRTFP.ReadFieldAsMemo(AName,AAttrsName:string;PID:RTFP_ID;buf:TStrings;AE:TAttrExtend);
var tmpField:TField;
begin
  if buf=nil then exit;
  buf.Clear;
  if GetFieldType(AAttrsName,AName)=ftUnknown then
    begin
      if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
      else exit;
    end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then begin
    buf.Text:=tmpField.AsString;
  end else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

procedure TRTFP.EditFieldAsMemo(AName,AAttrsName:string;PID:RTFP_ID;buf:TStrings;AE:TAttrExtend);
var tmpAG:TAttrsGroup;
    tmpField:TField;
begin
  if buf=nil then exit;
  case GetFieldType(AAttrsName,AName) of
    ftUnknown:
      begin
        if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
        else begin
          if aeCreateIfNoField in AE then
            begin
              AddField(AName,AAttrsName,ftMemo{,0});
            end
          else exit;
        end;
      end;
    ftMemo:;
    else
      begin
        if aeFailIfTypeDismatch in AE then raise AttrsTypeDismatchErr.Create('字段'+AName+'.'+AAttrsName+'类型错误！')
        else begin
          if aeForceEditIfTypeDismatch in AE then
          else exit;
        end;
      end;
  end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    begin
      tmpAG:=FindAttrs(AAttrsName);
      tmpAG.Dbf.Edit;
      tmpField.AsString:=buf.Text;
      tmpAG.Dbf.Post;
      DataChange(PID);
    end
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

procedure TRTFP.ReadFieldAsBitmap(AName,AAttrsName:string;PID:RTFP_ID;buf:Graphics.TBitMap;AE:TAttrExtend);
var tmpField:TField;
    str:TMemoryStream;
begin
  if buf=nil then exit;
  //buf.Clear;
  if GetFieldType(AAttrsName,AName)=ftUnknown then
    begin
      if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
      else exit;
    end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then begin
    str:=TMemoryStream.Create;
    try
      //TBlobField(tmpField).SaveToFile('img_convert_tmp.bmp');
      //buf.Picture.Bitmap.LoadFromFile('img_convert_tmp.bmp');
      TBlobField(tmpField).SaveToStream(str);
      str.Position:=0;
      buf.LoadFromStream(str);
    finally
      str.Free;
    end;
  end else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

procedure TRTFP.EditFieldAsBitmap(AName,AAttrsName:string;PID:RTFP_ID;buf:Graphics.TBitMap;AE:TAttrExtend);
var tmpAG:TAttrsGroup;
    tmpField:TField;
    str:TMemoryStream;
begin
  if buf=nil then exit;
  case GetFieldType(AAttrsName,AName) of
    ftUnknown:
      begin
        if aeFailIfNoField in AE then raise AttrsNoFieldErr.Create('找不到字段'+AAttrsName+'.'+AName+'！')
        else begin
          if aeCreateIfNoField in AE then
            begin
              AddField(AName,AAttrsName,ftMemo{,0});
            end
          else exit;
        end;
      end;
    ftBlob:;
    else
      begin
        if aeFailIfTypeDismatch in AE then raise AttrsTypeDismatchErr.Create('字段'+AName+'.'+AAttrsName+'类型错误！')
        else begin
          //if aeForceEditIfTypeDismatch in AE then else //不存在强制编辑可能性
            exit;
        end;
      end;
  end;
  tmpField:=GetField(AName,AAttrsName,PID,not (aeFailIfNoPID in AE));
  if tmpField<>nil then
    begin
      tmpAG:=FindAttrs(AAttrsName);
      tmpAG.Dbf.Edit;
      str:=TMemoryStream.Create;
      try
        //buf.Picture.Bitmap.SaveToFile('img_convert_tmp.bmp');
        //TBlobField(tmpField).LoadFromFile('img_convert_tmp.bmp');
        buf.SaveToStream(str);
        str.Position:=0;
        TBlobField(tmpField).LoadFromStream(str);
      finally
        str.Free;
      end;
      tmpAG.Dbf.Post;
      DataChange(PID);
    end
  else begin
    if aeFailIfNoPID in AE then raise AttrsNoPIDErr.Create('找不到PID['+PID+']！');
  end;
end;

procedure TRTFP.LoadAttrs;
var tmpAttrs:TAttrsGroup;
begin
  //BeginUpdate;
  FFieldList.LoadFromPath('attr\');
  for tmpAttrs in FFieldList do
    begin
      if not OpenDbf(tmpAttrs.FullPath,tmpAttrs.Dbf) then
        NewDbf(tmpAttrs.FullPath,tmpAttrs.Dbf);
      tmpAttrs.Dbf.Exclusive:=true;
      tmpAttrs.Dbf.Open;
      tmpAttrs.GroupShown:=false;
    end;
  //如果没有才会新建
  AddAttrs(_Attrs_Basic_);
  AddAttrs(_Attrs_Class_);
  AddAttrs(_Attrs_Notes_);
  AddAttrs(_Attrs_Metas_);
  AddAttrs(_Attrs_Relat_);
  for tmpAttrs in FFieldList do tmpAttrs.LoadFieldListFromDbf;
  //EndUpdate;
  //FieldChange;
end;

procedure TRTFP.SaveAttrs;
var tmpAttrs:TAttrsGroup;
begin
  for tmpAttrs in FFieldList do
    begin
      while not SaveDbf(tmpAttrs.FullPath,tmpAttrs.Dbf) do
        case ShowMsgRetryIgnore('错误','属性组保存失败！') of
          'Retry':;
          'Ignore':break;
        end;
    end;
end;

procedure TRTFP.CloseAttrs;
var tmpAttrs:TAttrsGroup;
begin
  for tmpAttrs in FFieldList do
    begin
      while not CloseDbf(tmpAttrs.FullPath,tmpAttrs.Dbf) do
        case ShowMsgRetryIgnore('错误','属性组关闭失败！') of
          'Retry':;
          'Ignore':break;
        end;
    end;
end;

procedure TRTFP.CheckAttrs;
begin
  //
  //
  //
end;



function TRTFP.AddKlass(klassname:string;pathname:string='\'):TKlass;
var tmp:TKlass;
begin
  result:=nil;
  if not TRTFP.IsKlassName(klassname) then exit;
  if FKlassList.FindItemIndexByName(klassname)>=0 then exit;
  tmp:=FKlassList.AddEx('class\'+pathname+'\'+klassname,klassname);
  ForceDirectories(FFilePath+FRootFolder+'\class\'+pathname);
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
var index,recNumber:integer;
    tmp:TKlass;
    PID:RTFP_ID;
    str:TStringList;
    attrs_modified:boolean;
begin
  index:=FKlassList.FindItemIndexByName(klassname);
  if index<0 then exit;
  tmp:=FKlassList.Items[index];

  str:=TStringList.Create;
  str.Sorted:=true;
  attrs_modified:=false;
  BeginUpdate;
  try
    with tmp.Dbf do begin
      if not Active then Open;
      First;
      if not EOF then attrs_modified:=true;
      while not EOF do
        begin
          PID:=FieldByName(_Col_PID_).AsString;
          ReadFieldAsMemo(_Col_class_DefaultCl_,_Attrs_Class_,PID,str,[]);
          if str.Find(tmp.Name,recNumber) then str.Delete(recNumber);
          EditFieldAsMemo(_Col_class_DefaultCl_,_Attrs_Class_,PID,str,[]);
          Next;
        end;
    end;
  finally
    str.Free;
  end;
  EndUpdate;
  CloseDbf(tmp.FullPath,tmp.Dbf);
  DeleteDbf(tmp.FullPath,tmp.Dbf);
  FKlassList.Delete(index);
  ClassChange;
  if attrs_modified then RebuildMainGrid{DataChange};
end;


procedure TRTFP.LoadKlass;
var tmpKlass:TKlass;
begin
  //BeginUpdate;
  FKlassList.LoadFromPath('class\');
  for tmpKlass in FKlassList do
    begin
      if not OpenDbf(tmpKlass.FullPath,tmpKlass.Dbf) then
        NewDbf(tmpKlass.FullPath,tmpKlass.Dbf);
    end;
  //EndUpdate;
  //ClassChange;
end;

procedure TRTFP.SaveKlass;
var tmpKlass:TKlass;
begin
  for tmpKlass in FKlassList do
    begin
      while not SaveDbf(tmpKlass.FullPath,tmpKlass.Dbf) do
        case ShowMsgRetryIgnore('错误','分类文件保存失败！') of
          'Retry':;
          'Ignore':break;
        end;
    end;
end;

procedure TRTFP.CloseKlass;
var tmpKlass:TKlass;
begin
  for tmpKlass in FKlassList do
    begin
      while not CloseDbf(tmpKlass.FullPath,tmpKlass.Dbf) do
        case ShowMsgRetryIgnore('错误','分类文件关闭失败！') of
          'Retry':;
          'Ignore':break;
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
  //Dbf.FieldDefs.Add(_Col_basic_Has_Ext_, ftSmallint, 1, false);//是否有BasicExt数据，是1 否0 //0.2.1-a.1开始删除这个字段

  //会议、专利、标准等就用BasicExt属性组好了

  //0.1.2-alpha.8 新增
  Dbf.FieldDefs.Add(_Col_basic_Degree_, ftString, 16, false);
  Dbf.FieldDefs.Add(_Col_basic_Teacher_, ftMemo, 0, false);
  Dbf.FieldDefs.Add(_Col_basic_City_, ftMemo, 0, false);
  Dbf.FieldDefs.Add(_Col_basic_Meeting_, ftMemo, 0, false);
  Dbf.FieldDefs.Add(_Col_basic_Sponsor_, ftMemo, 0, false);
  Dbf.FieldDefs.Add(_Col_basic_CN_, ftString, 16, false);

  //之后考虑将早期的String[255]改成Memo
  //String不在出现长度大于16的字段
  //同时增加转换字段类型的函数工具

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

  tmpProjectFile.Add('最后保存版本,'+C_VERSION_NUMBER);

  repeat
    retry:=false;
    try
      tmpProjectFile.SaveToFile(FFileFullName);
      //ProjectFileValue.LoadFromCSVFile(FFileFullName);
      FProjectTags.LoadFromFile(FFileFullName);
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
  //ProjectFileValue.LoadFromCSVFile(FFileFullName);
  FProjectTags.LoadFromFile(FFileFullName);
  result:=true;
end;

function TRTFP.SaveProjectFile:boolean;
begin
  //ProjectFileValue.SaveToCSVFile(FFileFullName);
  Version:=C_VERSION_NUMBER;
  FProjectTags.SaveToFile(FFileFullName);
  result:=true;
end;

function TRTFP.CloseProjectFile:boolean;
begin
  //ProjectFileValue.Clear;
  FProjectTags.Clear;
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

procedure TRTFP.LoadProjectOption(AAuf:TAuf);
var str:TStringList;
begin
  str:=TStringList.Create;
  try
    try
      str.LoadFromFile(GetCurrentPathFull+'\option.lay.auf');
      //str.Add('option.attrs.rebuild_mg');
      AAuf.Script.command(str);
    except
      //
    end;
  finally
    str.Free;
  end;
end;

procedure TRTFP.SaveProjectOption(filename:string='');
var AG:TAttrsGroup;
    AF:TAttrsField;
    str:TStringList;
    function con(boo:boolean):string;
    begin
      result:='off';
      if not boo then exit;
      result:='on';
    end;

begin
  str:=TStringList.Create;
  try
    for AG in FFieldList do
      begin
        str.Add('option.attrs.set "'+AG.Name+'","","folded",'+con(not AG.GroupShown));
        for AF in AG.FieldList do
          begin
            str.Add('option.attrs.set "'+AG.Name+'","'+AF.FieldName+'","visible",'+con(AF.Shown));
            str.Add('option.attrs.set "'+AG.Name+'","'+AF.FieldName+'","display_width",'+IntToStr(AF.FFieldDisplayOption.display_width));
          end;
      end;
    if filename='' then filename:='option.lay.auf';
    str.SaveToFile(GetCurrentPathFull+filename);
  finally
    str.Free;
  end;
end;

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

procedure TRTFP.New(filename:ansistring;p_title:string;p_user:string);
var md:boolean;
begin
  if FOnNew <> nil then FOnNew(Self);

  Self.SetPaths(WinCPToUTF8(filename));
  repeat
    md:=true;
    md:=md and TRTFP.MakeDir(Self.FFilePath+Self.FRootFolder);
    md:=md and TRTFP.MakeDir(Self.FFilePath+Self.FRootFolder+'\paper');
    md:=md and TRTFP.MakeDir(Self.FFilePath+Self.FRootFolder+'\class');
    md:=md and TRTFP.MakeDir(Self.FFilePath+Self.FRootFolder+'\note');
    md:=md and TRTFP.MakeDir(Self.FFilePath+Self.FRootFolder+'\image');
    md:=md and TRTFP.MakeDir(Self.FFilePath+Self.FRootFolder+'\format');
    md:=md and TRTFP.MakeDir(Self.FFilePath+Self.FRootFolder+'\attr');
    if not md then begin
      case ShowMsgRetryIgnore('新建工程','工程文件夹创建失败。') of
        'Retry':;
        else exit;
      end;
    end;
  until md;

  NewProjectFile(WinCPToUTF8(p_title),WinCPToUTF8(p_user));
  NewUserList;
  LoadFormatList;//NewFormatList;

  GenPaperAttribute(Self.FPaperDB);
  NewDbf('paper',Self.FPaperDB);
  GenImageAttribute(Self.FImageDB);
  NewDbf('image',Self.FImageDB);
  GenNoteAttribute(Self.FNotesDB);
  NewDbf('note',Self.FNotesDB);

  BeginUpdate;

  LoadAttrs;
  LoadKlass;

  EndUpdate;

  if FOnNewDone <> nil then FOnNewDone(Self);
  Self.FIsOpen:=true;
  Self.FIsChanged:=false;
  if FOnOpenDone <> nil then FOnOpenDone(Self);

  //以下更新显示需要PaperDS和ACLClassList的链接，所以放在onOpenDone之后
  RebuildMainGrid;
  ClassChange(true);
  FieldAndRecordChange(true);
end;

Procedure TRTFP.Open(filename:ansistring);
begin
  if FOnOpen <> nil then FOnOpen(Self);

  Self.SetPaths(WinCPToUTF8(filename));
  OpenProjectFile;
  if Version='' then Version:='0.1.1-alpha.17及以前';
  if not OpenUserList then NewUserList;
  LoadFormatList;//if not OpenFormatList then NewFormatList;

  if not OpenDbf('paper',Self.FPaperDB) then NewDbf('paper',Self.FPaperDB);
  if not OpenDbf('image',Self.FImageDB) then NewDbf('image',Self.FImageDB);
  if not OpenDbf('note',Self.FNotesDB) then NewDbf('note',Self.FNotesDB);

  BeginUpdate;

  LoadAttrs;
  LoadKlass;

  Update(Version);
  LoadProjectOption(FAuf);

  EndUpdate;

  Self.FIsOpen:=true;
  Self.FIsChanged:=false;
  if FOnOpenDone <> nil then FOnOpenDone(Self);

  //以下更新显示需要PaperDS和ACLClassList的链接，所以放在onOpenDone之后
  RebuildMainGrid;
  ClassChange(true);
  FieldAndRecordChange(true);
end;

procedure TRTFP.Save;
var msg:string;
begin
  if FOnSave <> nil then FOnSave(Self);

  if Version<>C_VERSION_NUMBER then
    begin
      msg:='当前工程的上一次保存版本为"'+Version+'"，'+#13#10+'是否使用当前版本('+C_VERSION_NUMBER+')进行保存？';
      if TRTFP.VersionCheck(C_VERSION_NUMBER,Version) then
        msg:=msg+#13#10+'保存为新版本：可能导致老版本打开工程异常。'
      else
        msg:=msg+#13#10+'保存为老版本：程序版本较老，建议更新程序。';
      case MessageDlg('版本兼容警告',msg,mtInformation,[mbYes,mbCancel],0) of
        rnmbYes:;
        rnmbCancel:exit;
      end;
    end;

  Self.Tag['修改日期']:=TRTFP.GetDateTimeStr;

  SaveProjectFile;
  SaveUserList;
  SaveFormatList;
  SaveProjectOption;
  SaveDbf('paper',Self.FPaperDB);
  SaveDbf('image',Self.FImageDB);
  SaveDbf('note',Self.FNotesDB);

  BeginUpdate;

  SaveAttrs;
  SaveKlass;

  EndUpdate;

  ClassChange;
  //FieldAndRecordChange;

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
      case ShowMsgYesNoCancel('未保存','关闭工程时是否保存工程？') of
        'Yes':Self.Save;
        'No':;
        'Cancel':exit;
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



procedure TRTFP.Update_0_1_1_alpha_18;
var DbfList:TList;
    klass:TKlass;
    attrs:TAttrsGroup;
    ptr:Pointer;
    pid:string;
begin
  //将RTFPID中的+-改成{}
  DbfList:=TList.Create;
  try
    DbfList.Add(FPaperDB);
    DbfList.Add(FImageDB);
    DbfList.Add(FNotesDB);
    for klass in FKlassList do DbfList.Add(klass.Dbf);
    for attrs in FFieldList do DbfList.Add(attrs.Dbf);
    for ptr in DbfList do with TDbf(ptr) do
      begin
        if not Active then Open;
        First;
        while not EOF do
          begin
            pid:=FieldByName(_Col_PID_).AsString;
            pid:=StringReplace(pid,'+','{',[rfReplaceAll]);
            pid:=StringReplace(pid,'-','}',[rfReplaceAll]);
            Edit;
            FieldByName(_Col_PID_).AsString:=pid;
            Post;
            Next;
          end;
      end;
  finally
    DbfList.Free;
  end;
end;
procedure TRTFP.Update_0_1_2_alpha_8;//暂时不要这个了，字段可能不能用DBF这个，效果太差
var tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
begin
  {
  tmpAG:=FFieldList.FindItemByName(_Attrs_Basic_);
  assert(tmpAG<>nil,'tmpAG此时不会是nil');

  BeginUpdate;

  tmpAF:=tmpAG.FieldList.FindItemByName(_Col_basic_Degree_);
  if tmpAF=nil then tmpAF:=AddField(_Col_basic_Degree_,_Attrs_Basic_,ftString);
  tmpAF:=tmpAG.FieldList.FindItemByName(_Col_basic_Teacher_);
  if tmpAF=nil then tmpAF:=AddField(_Col_basic_Teacher_,_Attrs_Basic_,ftMemo);
  tmpAF:=tmpAG.FieldList.FindItemByName(_Col_basic_City_);
  if tmpAF=nil then tmpAF:=AddField(_Col_basic_City_,_Attrs_Basic_,ftMemo);
  tmpAF:=tmpAG.FieldList.FindItemByName(_Col_basic_Meeting_);
  if tmpAF=nil then tmpAF:=AddField(_Col_basic_Meeting_,_Attrs_Basic_,ftMemo);
  tmpAF:=tmpAG.FieldList.FindItemByName(_Col_basic_Sponsor_);
  if tmpAF=nil then tmpAF:=AddField(_Col_basic_Sponsor_,_Attrs_Basic_,ftMemo);
  tmpAF:=tmpAG.FieldList.FindItemByName(_Col_basic_CN_);
  if tmpAF=nil then tmpAF:=AddField(_Col_basic_CN_,_Attrs_Basic_,ftString);
  EndUpdate;
  }

  //tmpDbf:=FFieldList.FindItemByName(_Attrs_Basic_).Dbf;
  {
  with FFieldList.FindItemByName(_Attrs_Basic_).Dbf do begin

    if not Active then Open;
    TryExclusive;

    DbfFieldDefs.Add(_Col_basic_Degree_, ftString, 16, false);
    DbfFieldDefs.Add(_Col_basic_Teacher_, ftMemo, 0, false);
    DbfFieldDefs.Add(_Col_basic_City_, ftMemo, 0, false);
    DbfFieldDefs.Add(_Col_basic_Meeting_, ftMemo, 0, false);
    DbfFieldDefs.Add(_Col_basic_Sponsor_, ftMemo, 0, false);
    DbfFieldDefs.Add(_Col_basic_CN_, ftString, 16, false);

    PackTable;
    Close;
    Open;
    EndExclusive;
    RegenerateIndexes;


  end;
  }
end;

procedure TRTFP.Update(save_version:string);
begin
  if not TRTFP.VersionCheck(save_version,'0.1.1-alpha.18') then Update_0_1_1_alpha_18;
  //if not TRTFP.VersionCheck(save_version,'0.1.2-alpha.8') then Update_0_1_2_alpha_8;

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
    //is_updating:boolean;
begin
  result:='000000';
  if not (AddPaperMethod in [apmFullBackup,apmCutBackup,apmReference,apmAddress]) then
    begin
      assert(false,'暂不支持apmWebsite的方式。');
      exit;
    end;

  tmpPDF:=TRTFP_PDF.Create(nil);
  TRY

    IF fullfilename<>'' THEN BEGIN
      case AddPaperMethod of
        apmFullBackup,apmCutBackup:
          begin
            DateDir:=TRTFP.GetDateDir;
            FileName:=ExtractFileName(fullfilename);
            TargetDir:=FFilePath+FRootFolder+'\paper\'+DateDir;
            if FileExists(TargetDir+'\'+FileName) then
              case ShowMsgYesNoAll('相同的备份路径','正在导入的文件“'+fullfilename
              +'”的默认备份地址存在重名，覆盖会导致两个文献节点共用一个备份文件。'
              +'若两个文件不相同，会导致旧版本备份文件被覆盖，且难以复原。'
              +'是否覆盖？',true) of
                'Yes':{do nothing};
                'No':exit;
            end;
          end;
        apmAddress:
          begin
            DateDir:='extern';
            FileName:=fullfilename;
            if length(FileName)>240 then exit;
            //TargetDir:=FFilePath+FRootFolder+'\paper\'+DateDir;
          end;
      end;
      tmpPDF.LoadPdf(fullfilename);
    END ELSE BEGIN
      if AddPaperMethod in [apmFullBackup,apmCutBackup,apmAddress] then exit;
      DateDir:='';
      FileName:='';
    END;

    //is_updating:=IsUpdating;
    //if not is_updating then BeginUpdate;
    BeginUpdate;

    PID:=NewPaperID;
    //FPaperDB.Last;//此时游标已经在Last位置
    with FPaperDB do begin
      Insert;
      FieldByName(_Col_PID_).AsString:=PID;
      FieldByName(_Col_Paper_Is_Backup_).AsBoolean:=(AddPaperMethod in [apmFullBackup,apmCutBackup]);
      FieldByName(_Col_Paper_Folder_).AsString:=DateDir;
      FieldByName(_Col_Paper_FileName_).AsString:=FileName;
      FieldByName(_Col_Paper_FileSize_).AsLargeInt:=tmpPDF.Size;
      FieldByName(_Col_Paper_FileHash_).AsString:=tmpPDF.Hash;
      Post;
    end;

    //0-文献基本信息要专门的算法
    EditFieldAsString(_Col_basic_doi_,_Attrs_Basic_,PID,'',[]);

    //1-分类
    EditFieldAsBoolean(_Col_class_Is_Read_,_Attrs_Class_,PID,false,[]);

    //2-注解
    //这里之后要考虑不是pdf或者pdf读取错误的情况
    //这不是一个好做法，会大量浪费算力，但是现在先让他爬起来吧，再优化
    EditFieldAsInteger(_Col_notes_User_,_Attrs_Notes_,PID,0,[]);
    EditFieldAsDateTime(_Col_notes_CreateTime_,_Attrs_Notes_,PID,Now,[]);
    EditFieldAsDateTime(_Col_notes_ModifyTime_,_Attrs_Notes_,PID,Now,[]);
    EditFieldAsDateTime(_Col_notes_CheckTime_,_Attrs_Notes_,PID,Now,[]);

    //3-元数据
    //这里之后要考虑不是pdf或者pdf读取错误的情况
    //这不是一个好做法，会大量浪费算力，但是现在先让他爬起来吧，再优化
    EditFieldAsString(_Col_metas_Title_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Title']^,[aeForceEditIfTypeDismatch]);
    EditFieldAsString(_Col_metas_Authors_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Author']^,[aeForceEditIfTypeDismatch]);
    EditFieldAsString(_Col_metas_Subject_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Subject']^,[aeForceEditIfTypeDismatch]);
    EditFieldAsString(_Col_metas_Keyword_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Keywords']^,[aeForceEditIfTypeDismatch]);
    EditFieldAsString(_Col_metas_Creator_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Creator']^,[aeForceEditIfTypeDismatch]);
    EditFieldAsString(_Col_metas_Produce_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Producer']^,[aeForceEditIfTypeDismatch]);
    EditFieldAsString(_Col_metas_CreDate_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:CreationDate']^,[aeForceEditIfTypeDismatch]);
    EditFieldAsString(_Col_metas_ModDate_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:ModDate']^,[aeForceEditIfTypeDismatch]);

    //if not is_updating then EndUpdate;
    EndUpdate;

    IF fullfilename<>'' THEN BEGIN
      case AddPaperMethod of
        apmFullBackup:
          begin
            ForceDirectories(TargetDir);
            //tmpPDF.CopyTo(TargetDir+'\'+FileName);//为什么不用copy？
            TRTFP.FileCopy(fullfilename,TargetDir+'\'+FileName,false);
            //尚未加入长度检验
          end;
        apmCutBackup:
          begin
            ForceDirectories(TargetDir);
            //tmpPDF.CopyTo(TargetDir+'\'+FileName);//为什么不用copy？
            TRTFP.FileMove(fullfilename,TargetDir+'\'+FileName,false);
            //尚未加入长度检验
          end;

      end;
      tmpPDF.ClosePdf;
    END;

  FINALLY
    tmpPDF.Free;
  END;
  RecordChange;
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
              repeat try
                retry:=false;
                CpStr.LoadFromFile(FName);
                if CompareMem(FileStream.Memory,CpStr.Memory,FileStream.Size) then PID:=FieldByName(_Col_PID_).AsString;
              except
                case ShowMsgRetryIgnore('错误','疑似相同文件被占用！') of
                  'Retry':retry:=true;
                  'Ignore':;
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

function TRTFP.DeletePaper(PID:RTFP_ID;PreserveFileNoAsk:boolean=false):boolean;//移除指定PID的文献
var AG:TAttrsGroup;
    klass_list:TStringList;
    klass_name:string;
begin
  result:=false;
  if not TRTFP.IsRTFPID(PID) then exit;
  with FPaperDB do begin
    if not Active then Open;
    IndexName:='id';
    if SearchKey(PID,stEqual) then
      begin
        if FieldByName(_Col_Paper_Is_Backup_).AsBoolean then
          if not PreserveFileNoAsk then
            case ShowMsgYesNoAll('删除确认','删除文献节点对应的文件可能会导致其他共用此文件的节点失去文件连接，并且操作后无法恢复，是否继续？',true) of
              'Yes':TRTFP.FileDelete(FFilePath+FRootFolder+'\paper\'+FieldByName(_Col_Paper_Folder_).AsString+'\'+FieldByName(_Col_Paper_FileName_).AsString);
              else ;
            end
          else ;//PreserveFileNoAsk=true时直接不删除
        Delete;
      end;
  end;
  klass_list:=TStringList.Create;
  try
    GetPaperKlass(PID,klass_list);
    for klass_name in klass_list do KlassExclude(klass_name,PID);
  finally
    klass_list.Free;
  end;
  for AG in FFieldList do with AG.Dbf do
    begin
      if not Active then Open;
      IndexName:='id';
      if SearchKey(PID,stEqual) then Delete;
    end;
  RecordChange;
  result:=true;
end;

function TRTFP.UpdatePaper(PID:RTFP_ID;fullfilename:string;AddPaperMethod:TAddPaperMethod):boolean;//更新指定PID的文件
var old_dir,old_file:string;
    old_backup:boolean;
    DateDir,FileName,TargetDir:string;
    tmpPDF:TRTFP_PDF;
begin
  result:=false;
  if not TRTFP.IsRTFPID(PID) then exit;
  assert(AddPaperMethod in [apmFullBackup,apmCutBackup,apmAddress],'不接受apmFullBackup、apmCutBackup和apmAddress以外的方式');

  with FPaperDB do begin
    if not Active then Open;
    IndexName:='id';
    if not SearchKey(PID,stEqual) then begin
      ShowMsgOK('未找到记录','没有找到PID为'+PID+'的文献节点');
      exit;
    end;
    old_backup:=FieldByName(_Col_Paper_Is_Backup_).AsBoolean;
    if old_backup then begin
      old_file:=FieldByName(_Col_Paper_FileName_).AsString;
      old_dir:=FieldByName(_Col_Paper_Folder_).AsString;
    end;
  end;

  case AddPaperMethod of
    apmFullBackup,apmCutBackup:
      begin
        DateDir:=TRTFP.GetDateDir;
        FileName:=ExtractFileName(fullfilename);
        TargetDir:=FFilePath+FRootFolder+'\paper\'+DateDir;
        if FileExists(TargetDir+'\'+FileName) then
          case ShowMsgYesNoAll('相同的备份路径','正在导入的文件“'+fullfilename
          +'”的默认备份地址存在重名，覆盖会导致两个文献节点共用一个备份文件。'
          +'若两个文件不相同，会导致旧版本备份文件被覆盖，且难以复原。'
          +'是否覆盖？',true) of
            'Yes':{do nothing};
            else exit;
        end;
      end;
    apmAddress:
      begin
        DateDir:='extern';
        FileName:=fullfilename;
        TargetDir:=fullfilename;
      end;
  end;

  tmpPDF:=TRTFP_PDF.Create(nil);
  TRY
    tmpPDF.LoadPdf(fullfilename);

    BeginUpdate;

    //此时游标已经在PID位置
    with FPaperDB do begin
      Edit;
      FieldByName(_Col_Paper_Is_Backup_).AsBoolean:=AddPaperMethod=apmFullBackup;
      FieldByName(_Col_Paper_Folder_).AsString:=DateDir;
      FieldByName(_Col_Paper_FileName_).AsString:=FileName;
      FieldByName(_Col_Paper_FileSize_).AsLargeInt:=tmpPDF.Size;
      FieldByName(_Col_Paper_FileHash_).AsString:=tmpPDF.Hash;
      Post;
    end;

    //2-注解
    EditFieldAsDateTime(_Col_notes_ModifyTime_,_Attrs_Notes_,PID,Now,[]);

    //3-元数据
    //这里之后要考虑不是pdf或者pdf读取错误的情况
    //这不是一个好做法，会大量浪费算力，但是现在先让他爬起来吧，再优化
    EditFieldAsString(_Col_metas_Title_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Title']^,[]);
    EditFieldAsString(_Col_metas_Authors_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Author']^,[]);
    EditFieldAsString(_Col_metas_Subject_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Subject']^,[]);
    EditFieldAsString(_Col_metas_Keyword_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Keywords']^,[]);
    EditFieldAsString(_Col_metas_Creator_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Creator']^,[]);
    EditFieldAsString(_Col_metas_Produce_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:Producer']^,[]);
    EditFieldAsString(_Col_metas_CreDate_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:CreationDate']^,[]);
    EditFieldAsString(_Col_metas_ModDate_,_Attrs_Metas_,PID,tmpPDF.Meta.pFields['DocInfo:ModDate']^,[]);

    EndUpdate;

    //这里有个大问题，如果更新之前有文件，那么替换的时候又不在同一个文件夹，怎么处理
    case AddPaperMethod of
      apmFullBackup:
        begin
          ForceDirectories(TargetDir);
          tmpPDF.CopyTo(TargetDir+'\'+FileName);//改了，不用这个了
          TRTFP.FileCopy(fullfilename,TargetDir+'\'+FileName,false);
          //尚未加入长度检验
        end;
      apmCutBackup:
        begin
          ForceDirectories(TargetDir);
          tmpPDF.CopyTo(TargetDir+'\'+FileName);//改了，不用这个了
          TRTFP.FileMove(fullfilename,TargetDir+'\'+FileName,false);
          //尚未加入长度检验
        end;
    end;
    if old_backup then begin
      TRTFP.FileDelete(FFilePath+FRootFolder+'\paper\'+old_dir+'\'+old_file);
      FPaperDB.FieldByName(_Col_Paper_Is_Backup_).AsBoolean:=true;
    end;

    tmpPDF.ClosePdf;
  FINALLY
    tmpPDF.Free;
  END;
  RecordChange;
  result:=true;
end;

function TRTFP.MergePaper(PID_Main,PID_Vice:RTFP_ID;AFieldSelectOption:TFieldSelectOptions):boolean;
var b1,b2:boolean;
    f1,f2,n1,n2,h1,h2:string;
    s1,s2:int64;
    UseVicePaperAttr:boolean;
    tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
    tmpOpt:PFieldSelectOption;
    stmp:string;
    klass_list:TStringList;
    function FindFieldOpt(AField:TAttrsField):PFieldSelectOption;
    var index:integer;
    begin
      with AFieldSelectOption do
        for index:=0 to Count-1 do
          begin
            result:=PFieldSelectOption(Items[index]);
            if result^.field=AField then exit;
          end;
      result:=nil;
    end;

begin
  result:=false;
  s1:=0;s2:=0;
  if TRTFP.IsRTFPID(PID_Main) and TRTFP.IsRTFPID(PID_Vice) then ELSE exit;
  with FPaperDB do
    begin
      if not Active then Open;
      IndexName:='id';
      if not SearchKey(PID_Vice,stEqual) then exit;
      b2:=FieldByName(_Col_Paper_Is_Backup_).AsBoolean;
      f2:=FieldByName(_Col_Paper_Folder_).AsString;
      n2:=FieldByName(_Col_Paper_FileName_).AsString;
      h2:=FieldByName(_Col_Paper_FileHash_).AsString;
      s2:=FieldByName(_Col_Paper_FileSize_).AsLargeInt;
      if not SearchKey(PID_Main,stEqual) then exit;
      b1:=FieldByName(_Col_Paper_Is_Backup_).AsBoolean;
      f1:=FieldByName(_Col_Paper_Folder_).AsString;
      n1:=FieldByName(_Col_Paper_FileName_).AsString;
      h1:=FieldByName(_Col_Paper_FileHash_).AsString;
      s1:=FieldByName(_Col_Paper_FileSize_).AsLargeInt;
      if (f2='') and (f1<>'') then begin
        UseVicePaperAttr:=false;
      end else if (f2<>'') and (f1='') then begin
        UseVicePaperAttr:=true;
      end else begin
        if (s1<>s2) or (h1<>h2) then
          case ShowMsgYesNoAll('合并','两个文献节点均有链接文件，是否用副节点备份文献替换主节点备份？') of
            'Yes':UseVicePaperAttr:=true;
            else UseVicePaperAttr:=false;
          end
        else UseVicePaperAttr:=false;
      end;
      if UseVicePaperAttr then
        begin
          Edit;
          FieldByName(_Col_Paper_Is_Backup_).AsBoolean:=b2;
          FieldByName(_Col_Paper_Folder_).AsString:=f2;
          FieldByName(_Col_Paper_FileName_).AsString:=n2;
          FieldByName(_Col_Paper_FileHash_).AsString:=h2;
          FieldByName(_Col_Paper_FileSize_).AsLargeInt:=s2;
          Post;
        end;
    end;
  for tmpAG in FieldList do
    begin
      for tmpAF in tmpAG.FieldList do
        begin
           tmpOpt:=FindFieldOpt(tmpAF);
           if tmpOpt<>nil then
             begin
               if (tmpAG.Name=_Attrs_Class_) and (tmpAF.FieldDef.DataType=ftMemo) then continue;//分类字段另外合并
               case tmpOpt^.select_mode of
                 fsmNone:{暂时还没有删除字段的方法};
                 fsmMain:{啥也不做};
                 fsmVice:
                   begin
                     stmp:=ReadFieldAsString(tmpAF.FieldName,tmpAG.Name,PID_Vice,[]);
                     EditFieldAsString(tmpAF.FieldName,tmpAG.Name,PID_Main,stmp,[aeForceEditIfTypeDismatch]);
                   end;
                 fsmBoth:
                   begin
                     stmp:=ReadFieldAsString(tmpAF.FieldName,tmpAG.Name,PID_Main,[]);
                     stmp:=stmp+#13#10+ReadFieldAsString(tmpAF.FieldName,tmpAG.Name,PID_Vice,[]);
                     EditFieldAsString(tmpAF.FieldName,tmpAG.Name,PID_Main,stmp,[]);
                   end;
               end;
             end;
        end;
    end;
  klass_list:=TStringList.Create;
  try
    GetPaperKlass(PID_Vice,klass_list);
    for stmp in klass_list do KlassInclude(stmp,PID_Main);
  finally
    klass_list.Free;
  end;
  result:=DeletePaper(PID_Vice,true);
end;

procedure TRTFP.GetPIDList(AList:TStrings);
begin
  with FPaperDB do
    begin
      if not Active then Open;
      First;
      while not EOF do
        begin
          AList.Add(FieldByName(_Col_PID_).AsString);
          Next;
        end;
    end;
end;
procedure TRTFP.GetPIDList_DS(AList:TStrings);
var bm:TBookMark;
begin
  with FPaperDS do
    begin
      BeginUpdate;
      bm:=Bookmark;
      First;
      while not EOF do
        begin
          AList.Add(FieldByName(_Col_PID_).AsString);
          Next;
        end;
      GotoBookmark(bm);
      EndUpdate;
    end;
end;
procedure TRTFP.GetSimilarPIDList(AList:TStrings;ASimChkOption:TSimChkOptions;PB:TProgressBar=nil);
var PIDs,lst1,lst2:TStringList;
    id1,id2:RTFP_ID;
    stmp:string;
    index,pi:integer;
    function EqualCompare:boolean;
    var s1,s2:string;
    begin
      result:=true;
      for s1 in lst1 do
        for s2 in lst2 do
          if s1=s2 then exit;
      result:=false;
    end;
    function ContainCompare:boolean;
    var s1,s2:string;
    begin
      result:=true;
      for s1 in lst1 do
        for s2 in lst2 do
          if (pos(s1,s2)>0) or (pos(s2,s1)>0) then exit;
      result:=false;
    end;
    function HalffitCompare:boolean;
    var s1,s2:string;
        len1,len2,len:integer;
    begin
      result:=true;
      for s1 in lst1 do for s2 in lst2 do
        begin
          len:=length(LongestCommonSubString(s1,s2));
          len1:=length(s1) div 2;
          len2:=length(s2) div 2;
          if (len>len1) and (len>len2) then exit;
        end;
      result:=false;
    end;
    function unsign_string(str:string):string;
    var index:integer;
    begin
      index:=1;
      result:=str;
      while index<=length(result) do
        begin
          if byte(ord(result[index])) <128 then delete(result,index,1)
          else inc(index);
        end;
    end;
    function HalffitUnsignedCompare:boolean;
    var s1,s2:string;
        len1,len2,len:integer;
    begin
      result:=true;
      for s1 in lst1 do for s2 in lst2 do
        begin
          len:=length(LongestCommonSubString(unsign_string(s1),unsign_string(s2)));
          len1:=length(s1) div 2;
          len2:=length(s2) div 2;
          if (len>len1) and (len>len2) then exit;
        end;
      result:=false;
    end;

begin
  PIDs:=TStringList.Create;
  lst1:=TStringList.Create;
  lst2:=TStringList.Create;
  with FPaperDB do if not Active then Open;
  try
    if scoDB in ASimChkOption then GetPIDList(PIDs)
    else {if scoDS in ASimChkOption then }GetPIDList_DS(PIDs);
    if PB<>nil then begin
      PB.Max:=PIDs.Count*PIDs.Count div 2;
      PB.Position:=0;
    end;
    pi:=0;
    for id1 in PIDs do
      begin
        for id2 in PIDs do
          begin
            inc(pi);
            if PB<>nil then begin
              PB.Position:=pi;
              Application.ProcessMessages;
            end;
            if id1=id2 then break;
            lst1.Clear;
            lst2.Clear;
            if scoFileName in ASimChkOption then
              begin
                FPaperDB.IndexName:='id';
                if not FPaperDB.SearchKey(id1,stEqual) then continue;
                lst1.Add(FPaperDB.FieldByName(_Col_Paper_FileName_).AsString);
                if not FPaperDB.SearchKey(id2,stEqual) then continue;
                lst2.Add(FPaperDB.FieldByName(_Col_Paper_FileName_).AsString);
              end;
            if scoFileHash in ASimChkOption then
              begin
                FPaperDB.IndexName:='id';
                if not FPaperDB.SearchKey(id1,stEqual) then continue;
                lst1.Add(FPaperDB.FieldByName(_Col_Paper_FileHash_).AsString);
                if not FPaperDB.SearchKey(id2,stEqual) then continue;
                lst2.Add(FPaperDB.FieldByName(_Col_Paper_FileHash_).AsString);
              end;
            if scoTitle in ASimChkOption then
              begin
                lst1.Add(ReadFieldAsString(_Col_basic_Title_,_Attrs_Basic_,id1,[]));
                lst2.Add(ReadFieldAsString(_Col_basic_Title_,_Attrs_Basic_,id2,[]));
              end;
            if scoWeblnk in ASimChkOption then
              begin
                lst1.Add(ReadFieldAsString(_Col_basic_Link_,_Attrs_Basic_,id1,[]));
                lst2.Add(ReadFieldAsString(_Col_basic_Link_,_Attrs_Basic_,id2,[]));
              end;
            if scoDOI in ASimChkOption then
              begin
                lst1.Add(ReadFieldAsString(_Col_basic_doi_,_Attrs_Basic_,id1,[]));
                lst2.Add(ReadFieldAsString(_Col_basic_doi_,_Attrs_Basic_,id2,[]));
              end;
            if scoMetaTitle in ASimChkOption then
              begin
                lst1.Add(ReadFieldAsString(_Col_metas_Title_,_Attrs_Metas_,id1,[]));
                lst2.Add(ReadFieldAsString(_Col_metas_Title_,_Attrs_Metas_,id2,[]));
              end;
            if scoMetaSubject in ASimChkOption then
              begin
                lst1.Add(ReadFieldAsString(_Col_metas_Subject_,_Attrs_Metas_,id1,[]));
                lst2.Add(ReadFieldAsString(_Col_metas_Subject_,_Attrs_Metas_,id2,[]));
              end;
            if scoMetaCreator in ASimChkOption then
              begin
                lst1.Add(ReadFieldAsString(_Col_metas_Creator_,_Attrs_Metas_,id1,[]));
                lst2.Add(ReadFieldAsString(_Col_metas_Creator_,_Attrs_Metas_,id2,[]));
              end;
            if scoMetaProduce in ASimChkOption then
              begin
                lst1.Add(ReadFieldAsString(_Col_metas_Produce_,_Attrs_Metas_,id1,[]));
                lst2.Add(ReadFieldAsString(_Col_metas_Produce_,_Attrs_Metas_,id2,[]));
              end;

            lst1.Sorted:=true;
            lst2.Sorted:=true;
            while lst1.Find('',index) do lst1.Delete(index);
            while lst2.Find('',index) do lst2.Delete(index);
            //ShowMessageFmt('lst1[%d],lst2[%d]',[lst1.Count,lst2.Count]);
            if scoEqual in ASimChkOption then
              begin
                if EqualCompare then AList.Add(id1+'-'+id2);
              end
            else if scoContain in ASimChkOption then
              begin
                if ContainCompare then AList.Add(id1+'-'+id2);
              end
            else if scoHalffit in ASimChkOption then
              begin
                if HalffitCompare then AList.Add(id1+'-'+id2);
              end
            else {if scoHalffitRough in ASimChkOption then}
              begin
                if HalffitUnsignedCompare then AList.Add(id1+'-'+id2);
              end;
          end;
      end;
    if PB<>nil then PB.Position:=PB.Max;
  finally
    PIDs.Free;
    lst1.Free;
    lst2.Free;
  end;

end;

function TRTFP.GetPaperAttrs(AFieldName:string;PID:RTFP_ID):string;
begin
  with FPaperDB do
    begin
      if not Active then Open;
      IndexName:='id';
      if SearchKey(PID,stEqual) then
        begin
          result:=FieldByName(AFieldName).AsString;
        end
      else result:='';
    end;
end;

procedure TRTFP.GetPaperKlass(PID:RTFP_ID;str:TStrings);
begin
  with FieldList.FindItemByName(_Attrs_Class_).Dbf do
    begin
      if not Active then Open;
      IndexName:='id';
      if not SearchKey(PID,stEqual) then exit;
      str.Text:=FieldByName(_Col_class_DefaultCl_).AsString;
    end;
end;

procedure TRTFP.OpenPaper(PID:RTFP_ID;exename:string='');
var filename:string;
begin
  with FPaperDB do begin
    if not Active then Open;
    IndexName:='id';
    if not SearchKey(PID,stEqual) then
      begin
        assert(false,'未找到PID');
        exit;
      end;
    if FieldByName(_Col_Paper_Is_Backup_).AsBoolean then
      filename:=Utf8ToWinCP(FFilePath+FRootFolder+'\paper\'
        +FieldByName(_Col_Paper_Folder_).AsString+'\'
        +FieldByName(_Col_Paper_FileName_).AsString)
    else begin
      case FieldByName(_Col_Paper_Folder_).AsString of
        'extern':filename:=Utf8ToWinCP(FieldByName(_Col_Paper_FileName_).AsString);
        'weblnk':
          begin
            filename:=ReadFieldAsString(_Col_basic_Link_,_Attrs_Basic_,PID,[]);
            if filename='' then filename:=ReadFieldAsString(_Col_basic_doi_,_Attrs_Basic_,PID,[]);
          end;
        else begin ShowMsgOK('警告','非备份文献节点不能通过此方法打开！');exit;end;
      end;
    end;
    if filename<>'' then TRTFP.OpenFile(filename,exename);
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
    if not Active then Open;
    IndexName:='id';
    if not SearchKey(PID,stEqual) then
      begin
        assert(false,'未找到PID');
        exit;
      end;
    if FieldByName(_Col_Paper_Is_Backup_).AsBoolean then
      filename:=Utf8ToWinCP(FFilePath+FRootFolder+'\paper\'
        +FieldByName(_Col_Paper_Folder_).AsString+'\'
        +FieldByName(_Col_Paper_FileName_).AsString)
    else begin
      case FieldByName(_Col_Paper_Folder_).AsString of
        'extern':filename:=Utf8ToWinCP(FieldByName(_Col_Paper_FileName_).AsString);
        else begin ShowMsgOK('警告','非备份文献节点不能通过此方法打开！');exit;end;
      end;
    end;
    TRTFP.OpenDir(filename);
  end;
end;

procedure TRTFP.OpenPaperLink(PID:RTFP_ID);
var linkage:string;
begin
  linkage:=ReadFieldAsString(_Col_basic_Link_,_Attrs_Basic_,PID,[]);
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
    IndexName:='id';
    if not SearchKey(PID,stEqual) then begin
      Last;//有必要吗？
      Insert;
      FieldByName(_Col_PID_).AsString:=PID;
      Post;
    end;
  end;
  //修改字段
  stmp:=TStringList.Create;
  stmp.Sorted:=true;
  try
    ReadFieldAsMemo(_Col_class_DefaultCl_,_Attrs_Class_,PID,stmp,[]);
    if not stmp.Find(klassname,index) then stmp.Add(klassname);
    EditFieldAsMemo(_Col_class_DefaultCl_,_Attrs_Class_,PID,stmp,[]);
  finally
    stmp.Free;
  end;

  FormDesktop.debugline('PID['+PID+']->'+klassname);
  //RebuildMainGrid;
  DataChange(PID);
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
    IndexName:='id';
    if SearchKey(PID,stEqual) then Delete;
  end;
  //修改字段
  stmp:=TStringList.Create;
  stmp.Sorted:=true;
  try
    ReadFieldAsMemo(_Col_class_DefaultCl_,_Attrs_Class_,PID,stmp,[]);
    if stmp.Find(klassname,index) then stmp.Delete(index);
    EditFieldAsMemo(_Col_class_DefaultCl_,_Attrs_Class_,PID,stmp,[]);
  finally
    stmp.Free;
  end;

  FormDesktop.debugline('PID['+PID+']<-'+klassname);
  //RebuildMainGrid;
  DataChange(PID);
  result:=true;
end;

function TRTFP.KlassIncludeFromCombo(PID:RTFP_ID;active:boolean):boolean;
var CL:TStringList;
    KL:TKlass;
    stmp:string;
begin
  CL:=TStringList.Create;
  try
    for KL in FKlassList do
      if KL.FilterEnabled or not active then
        begin
          CL.Add(KL.Name);
          CL.Objects[CL.Count-1]:=KL;
        end;
    if CL.Count>0 then
      begin
        if CL.Count=1 then KlassInclude(CL[0],PID)
        else begin
          stmp:=ShowMsgCombo('纳入分类','选择文件拟纳入的分类',CL);
          if stmp<>'' then KlassInclude(stmp,PID);
        end;
      end;
  finally
    CL.Free;
  end;
  result:=true;
end;

procedure TRTFP.ReNewCreateTime(PID:RTFP_ID);
begin
  EditFieldAsDateTime(_Col_notes_CreateTime_,_Attrs_Notes_,PID,Now,[]);
end;

procedure TRTFP.ReNewModifyTime(PID:RTFP_ID);
begin
  EditFieldAsDateTime(_Col_notes_ModifyTime_,_Attrs_Notes_,PID,Now,[]);
end;

procedure TRTFP.ReNewCheckTime(PID:RTFP_ID);
begin
  EditFieldAsDateTime(_Col_notes_CheckTime_,_Attrs_Notes_,PID,Now,[]);
end;

procedure TRTFP.ReNewModifyTimeWithoutChange(PID:RTFP_ID);
begin
  BeginUpdate;
  EditFieldAsDateTime(_Col_notes_ModifyTime_,_Attrs_Notes_,PID,Now,[]);
  EndUpdate;
end;

procedure TRTFP.ReNewCheckTimeWithoutChange(PID:RTFP_ID);
begin
  BeginUpdate;
  EditFieldAsDateTime(_Col_notes_CheckTime_,_Attrs_Notes_,PID,Now,[]);
  EndUpdate;
end;

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
    IndexName:='id';
    if not SearchKey(PID,stEqual) then
      begin
        assert(false,'不应该找不到才对');
        Append;
        FieldByName(_Col_PID_).AsString:=PID;
        Post;
      end;
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

procedure TRTFP.EditBasic;
var AG:TAttrsGroup;
begin
  AG:=FindAttrs(_Attrs_Basic_);
  AG.Dbf.Edit;
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

function decodeRISRefType(str:string):string;
begin
  result:=str;
end;

function encodeRISRefType(str:string):string;
begin
  result:=str;
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
          'Author-作者','Author-发明人','Source-起草单位':
            begin
              while attr[length(attr)]=';' do
                begin
                  delete(attr,length(attr),1);
                  if attr='' then break;
                end;
              FieldByName(_Col_basic_Author_).AsString:=attr;
            end;
          'Title-题名','Title-正标题','Title-书名','Title-专利名称','Title-中文标准名称':FieldByName(_Col_basic_Title_).AsString:=attr;
          'Source-刊名','Source-学位授予单位','Source-报纸中文名','Author-发布单位名称','Source-文献来源':
            FieldByName(_Col_basic_Source_).AsString:=attr;
          'Year-年','Year-年鉴年份':FieldByName(_Col_basic_Year_).AsString:=attr;
          'PubTime-出版时间','PubTime-发表时间':
            begin
              {zan}poss:=pos(' ',attr);
              if poss>0 then delete(attr,poss,length(attr));
              try
                TryStrToDate(attr,tmpDate,'YYYYMMDD','-');
              except
              end;
              FieldByName(_Col_basic_PubTime_).AsDateTime:=tmpDate;
            end;
          'Period-期':FieldByName(_Col_basic_Issue_).AsString:=attr;
          'Roll-卷':FieldByName(_Col_basic_Volume_).AsString:=attr;
          'Keyword-关键词':FieldByName(_Col_basic_Keyword_).AsString:=attr;
          'Summary-摘要','Summary-快照':FieldByName(_Col_basic_Summary_).AsString:=attr;
          'PageCount-页数':FieldByName(_Col_basic_PageCount_).AsString:=attr;
          'Page-页码':FieldByName(_Col_basic_Page_).AsString:=attr;
          //'SrcDatabase-来源库':FieldByName(_Col_basic_来源库_).AsString:=attr;
          'Organ-机构','Organ-大学','Organ-出版社','文献来源'{专利},'Organ-出版者'{年鉴}:
            FieldByName(_Col_basic_Organ_).AsString:=attr;
          'Link-链接':FieldByName(_Col_basic_Link_).AsString:=StringReplace(attr,'&amp;','&',[rfReplaceAll]);
          'Degree-学位':FieldByName(_Col_basic_Degree_).AsString:=attr;
          'Teacher-导师','Teacher-申请人':FieldByName(_Col_basic_Teacher_).AsString:=attr;
          'City-会议地点','City-地址':FieldByName(_Col_basic_City_).AsString:=attr;
          'Meeting-会议名称':FieldByName(_Col_basic_Meeting_).AsString:=attr;
          'Notes-标准号':FieldByName(_Col_basic_ISBN_ISSN_).AsString:=attr;

        end;
      except
        error_str:=error_str+'    '+header+#13#10;
      end;
      ReEditBasic;
      //PostBasic;
      //EditBasic;
    end;
  end;
  if error_str<>#13#10 then ShowMsgOKAll('导入错误','以下字段导入时发生错误：'+error_str);//这里最好加一个本次不再提示
  PostBasic;
  FieldAndRecordChange;//DataChange;
end;
procedure TRTFP.LoadFromRefWork(PID:RTFP_ID;str:TStrings);
begin
  ShowMsgOK('警告','暂不支持导入RefWork');
end;
procedure TRTFP.LoadFromEndNote(PID:RTFP_ID;str:TStrings);
var stmp,attr:string;
    has_author:boolean;
    reftype:string;
begin
  has_author:=false;
  reftype:='';
  with InitBasic(PID) do begin
    for stmp in str do begin
      if length(stmp)<3 then continue;
      if (stmp[1]<>'%') or (stmp[3]<>' ') then continue;
      attr:=stmp;
      delete(attr,1,3);
      case stmp[2] of
        '0':
          begin
            reftype:=decodeEndNoteRefType(attr);
            FieldByName(_Col_basic_RefType_).AsString:=reftype;
          end;
        'A':
          begin
            attr:=StringReplace(attr,' %A ',';',[rfReplaceAll]);
            if has_author then attr:=FieldByName(_Col_basic_Author_).AsString+';'+attr;
            FieldByName(_Col_basic_Author_).AsString:=attr;
            has_author:=true;
          end;
        '+':FieldByName(_Col_basic_Organ_).AsString:=attr;
        'T':FieldByName(_Col_basic_Title_).AsString:=attr;
        'J','I':FieldByName(_Col_basic_Source_).AsString:=attr;
        'D':FieldByName(_Col_basic_Year_).AsString:=attr;
        'V':case reftype of
              '标准规范':FieldByName(_Col_basic_ISBN_ISSN_).AsString:=attr;
              else FieldByName(_Col_basic_Issue_).AsString:=attr;
            end;
        'N':FieldByName(_Col_basic_Volume_).AsString:=attr;
        'K':FieldByName(_Col_basic_Keyword_).AsString:=attr;
        'X':FieldByName(_Col_basic_Summary_).AsString:=attr;
        'P':FieldByName(_Col_basic_Page_).AsString:=attr;
        '@':FieldByName(_Col_basic_ISBN_ISSN_).AsString:=attr;
        'L':FieldByName(_Col_basic_CN_).AsString:=attr;
        //'W':FieldByName(_Col_basic_DataProv_).AsString:=attr;
        'Y':FieldByName(_Col_basic_Teacher_).AsString:=attr;
        '9':FieldByName(_Col_basic_Degree_).AsString:=attr;//也指专利类型
        'C':FieldByName(_Col_basic_City_).AsString:=attr;
        'B':FieldByName(_Col_basic_Meeting_).AsString:=attr;
        '?':FieldByName(_Col_basic_Sponsor_).AsString:=attr;
        '8':FieldByName(_Col_basic_PubTime_).AsString:=attr;//专利的发表时间

      end;
      ReEditBasic;
    end;
  end;
  PostBasic;
  FieldAndRecordChange;//DataChange;
end;
procedure TRTFP.LoadFromNoteExpress(PID:RTFP_ID;str:TStrings);
begin
  ShowMsgOK('警告','暂不支持导入NoteExpress');
end;
procedure TRTFP.LoadFromNoteFirst(PID:RTFP_ID;str:TStrings);
begin
  ShowMsgOK('警告','暂不支持导入NoteFirst');
end;
procedure TRTFP.LoadFromRIS(PID:RTFP_ID;str:TStrings);
var stmp,attr:string;
    has_author,has_keyword:boolean;
    tmpDate:TDate;
begin
  has_author:=false;
  has_keyword:=false;
  with InitBasic(PID) do begin
    for stmp in str do begin
      if length(stmp)<6 then continue;
      if (stmp[3]<>' ') or (stmp[4]<>' ') or (stmp[5]<>'-') or (stmp[6]<>' ') then continue;
      attr:=stmp;
      delete(attr,1,6);
      case uppercase(stmp[1]+stmp[2]) of
        'TY':FieldByName(_Col_basic_RefType_).AsString:=decodeRISRefType(attr);
        'AU','A1','A2','A3','A4','A5','A6','A7','A8':
          begin
            if has_author then attr:=FieldByName(_Col_basic_Author_).AsString+';'+attr;
            FieldByName(_Col_basic_Author_).AsString:=attr;
            has_author:=true;
          end;
        'DA':
          begin
            try
              TryStrToDate(attr,tmpDate,'YYYYMMDD','/');
            except
            end;
            FieldByName(_Col_basic_PubTime_).AsDateTime:=tmpDate;
          end;
        'KW':
          begin
            if has_keyword then attr:=FieldByName(_Col_basic_Keyword_).AsString+';'+attr;
            FieldByName(_Col_basic_Keyword_).AsString:=attr;
            has_keyword:=true;
          end;
        'ER':{do nothing};
        'T1':FieldByName(_Col_basic_Title_).AsString:=attr;
        'JO','JF':FieldByName(_Col_basic_Source_).AsString:=attr;
        'PY':FieldByName(_Col_basic_Year_).AsString:=attr;
        'VL':FieldByName(_Col_basic_Volume_).AsString:=attr;
        'AB':FieldByName(_Col_basic_Summary_).AsString:=attr;
        'SN':FieldByName(_Col_basic_ISBN_ISSN_).AsString:=attr;
        'DO':FieldByName(_Col_basic_doi_).AsString:=attr;
        'UR':FieldByName(_Col_basic_Link_).AsString:=attr;
        'DB':FieldByName(_Col_basic_DataProv_).AsString:=attr;
        'DP':FieldByName(_Col_basic_DataProv_).AsString:=attr;
        //'AU':FieldByName(Author Address).AsString:=attr;
        //'AN':FieldByName(Accession Number).AsString:=attr;
        //'AV':FieldByName(Location in Archives).AsString:=attr;
        //'SP':FieldByName(Start Page).AsString:=attr;
        //'EP':FieldByName(End Page).AsString:=attr;
        //'LA':FieldByName(_Col_basic_Language).AsString:=attr;

      end;
      ReEditBasic;
    end;
  end;
  PostBasic;
  FieldAndRecordChange;//DataChange;
end;

procedure TRTFP.SaveToEStudy(PID:RTFP_ID;str:TStrings);
begin
  ShowMsgOK('警告','暂不支持导出EStudy');
end;
procedure TRTFP.SaveToRefWork(PID:RTFP_ID;str:TStrings);
begin
  ShowMsgOK('警告','暂不支持导出RefWork');
end;
procedure TRTFP.SaveToEndNote(PID:RTFP_ID;str:TStrings);
var stmp,reftype:string;
    ntmp:integer;
begin
  str.Clear;
  with InitBasic(PID) do begin
    stmp:=FieldByName(_Col_basic_RefType_).AsString;
    if stmp<>'' then str.Add('%0 '+encodeEndNoteRefType(stmp));
    reftype:=stmp;
    stmp:=FieldByName(_Col_basic_Author_).AsString;
    if stmp<>'' then str.Add('%A '+StringReplace(stmp,';',' %A ',[rfReplaceAll]));
    stmp:=FieldByName(_Col_basic_Organ_).AsString;
    if stmp<>'' then str.Add('%+ '+stmp);
    stmp:=FieldByName(_Col_basic_Title_).AsString;
    if stmp<>'' then str.Add('%T '+stmp);

    stmp:=FieldByName(_Col_basic_Source_).AsString;
    if reftype = '学位论文' then begin
      if stmp<>'' then str.Add('%I '+stmp);
    end else begin
      if stmp<>'' then str.Add('%J '+stmp);
    end;

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
    stmp:=FieldByName(_Col_basic_CN_).AsString;
    if stmp<>'' then str.Add('%L '+stmp);
    stmp:=FieldByName(_Col_basic_DataProv_).AsString;
    if stmp<>'' then str.Add('%W '+stmp);
    stmp:=FieldByName(_Col_basic_Teacher_).AsString;
    if stmp<>'' then str.Add('%Y '+stmp);
    stmp:=FieldByName(_Col_basic_Degree_).AsString;
    if stmp<>'' then str.Add('%9 '+stmp);
    stmp:=FieldByName(_Col_basic_City_).AsString;
    if stmp<>'' then str.Add('%C '+stmp);
    stmp:=FieldByName(_Col_basic_Meeting_).AsString;
    if stmp<>'' then str.Add('%B '+stmp);
    stmp:=FieldByName(_Col_basic_Sponsor_).AsString;
    if stmp<>'' then str.Add('%? '+stmp);

  end;
  PostBasic;
end;
procedure TRTFP.SaveToNoteExpress(PID:RTFP_ID;str:TStrings);
begin
  ShowMsgOK('警告','暂不支持导出NoteExpress');
end;
procedure TRTFP.SaveToNoteFirst(PID:RTFP_ID;str:TStrings);
begin
  ShowMsgOK('警告','暂不支持导出NoteFirst');
end;
procedure TRTFP.SaveToRIS(PID:RTFP_ID;str:TStrings);
begin
  ShowMsgOK('警告','暂不支持导出RIS');
end;

procedure TRTFP.SetGBT7714(PID:RTFP_ID;str:string);
begin
  ShowMsgOK('警告','暂不支持导入GB/T 7714');
end;
procedure TRTFP.SetCAJCD(PID:RTFP_ID;str:string);
begin
  ShowMsgOK('警告','暂不支持导入CAJ/CD');
end;
procedure TRTFP.SetMLA(PID:RTFP_ID;str:string);
begin
  ShowMsgOK('警告','暂不支持导入MLA');
end;
procedure TRTFP.SetAPA(PID:RTFP_ID;str:string);
begin
  ShowMsgOK('警告','暂不支持导入APA');
end;
procedure TRTFP.SetChaXin(PID:RTFP_ID;str:string);
begin
  ShowMsgOK('警告','暂不支持导入查新');
end;

function TRTFP.GetGBT7714(PID:RTFP_ID):string;
var stmp:string;
    tmpDateTime:TDateTime;
begin
  //ShowMsgOK('警告','unimplemented');
  result:='';
  with InitBasic(PID) do
    begin
      case FieldByName(_Col_basic_RefType_).AsString of
        '期刊论文':
          begin
            result:='[PID='+PID+']';
            result:=result+StringReplace(FieldByName(_Col_basic_Author_).AsString,';',',',[rfReplaceAll]);
            result:=result+'.';
            result:=result+FieldByName(_Col_basic_Title_).AsString;
            result:=result+'[J].';
            result:=result+FieldByName(_Col_basic_Source_).AsString;
            result:=result+',';
            result:=result+FieldByName(_Col_basic_Year_).AsString;
            result:=result+',';
            result:=result+FieldByName(_Col_basic_Volume_).AsString;
            result:=result+'(';
            result:=result+FieldByName(_Col_basic_Issue_).AsString;
            result:=result+'):';
            result:=result+FieldByName(_Col_basic_Page_).AsString;
            result:=result+'.';
          end;
        '学位论文':
          begin
            result:='[PID='+PID+']';
            result:=result+FieldByName(_Col_basic_Author_).AsString;
            result:=result+'.';
            result:=result+FieldByName(_Col_basic_Title_).AsString;
            result:=result+'[D].';
            result:=result+FieldByName(_Col_basic_Source_).AsString;
            result:=result+',';
            result:=result+FieldByName(_Col_basic_Year_).AsString;
            result:=result+'.';
          end;
        '会议论文':
          begin
            result:='[PID='+PID+']';
            result:=result+StringReplace(FieldByName(_Col_basic_Author_).AsString,';',',',[rfReplaceAll]);
            result:=result+'. ';
            result:=result+FieldByName(_Col_basic_Title_).AsString;
            result:=result+'[A]. ';
            result:=result+FieldByName(_Col_basic_Sponsor_).AsString;
            result:=result+'.';
            result:=result+FieldByName(_Col_basic_Source_).AsString;
            result:=result+'[C]';
            result:=result+FieldByName(_Col_basic_Sponsor_).AsString;
            result:=result+':';
            result:=result+FieldByName(_Col_basic_Meeting_).AsString;
            result:=result+',';
            result:=result+FieldByName(_Col_basic_Year_).AsString;
            result:=result+':';
            result:=result+FieldByName(_Col_basic_PageCount_).AsString;
            result:=result+'.';
          end;
        '报纸':
          begin
            result:='[PID='+PID+']';
            result:=result+StringReplace(FieldByName(_Col_basic_Author_).AsString,';',',',[rfReplaceAll]);
            result:=result+'. ';
            result:=result+FieldByName(_Col_basic_Title_).AsString;
            result:=result+'[N]. ';
            result:=result+FieldByName(_Col_basic_Source_).AsString;
            result:=result+',';
            result:=result+FieldByName(_Col_basic_PubTime_).AsString;
            result:=result+'(';
            result:=result+FieldByName(_Col_basic_PageCount_).AsString;
            result:=result+').';
          end;
        '专著':
          begin
            result:='[PID='+PID+']';
            result:=result+StringReplace(FieldByName(_Col_basic_Author_).AsString,';',',',[rfReplaceAll]);
            result:=result+'.';
            result:=result+FieldByName(_Col_basic_Title_).AsString;
            result:=result+'[M].';
            //result:=result+FieldByName(_Col_basic_出版社城市_).AsString;
            //result:=result+':';
            result:=result+FieldByName(_Col_basic_Organ_).AsString;
            result:=result+',';

            stmp:=FieldByName(_Col_basic_Year_).AsString;
            if stmp='' then
              begin
                tmpDateTime:=FieldByName(_Col_basic_PubTime_).AsDateTime;
                if tmpDateTime<>0 then
                  begin
                    DateTimeToString(stmp,'yyyy',tmpDateTime,[]);
                    result:=result+stmp;
                  end;
              end
            else result:=result+stmp;

            stmp:=FieldByName(_Col_basic_Page_).AsString;
            if stmp<>'' then
              begin
                result:=result+':';
                result:=result+stmp;
              end;

            result:=result+'.';
          end;
        '年鉴':
          begin
            result:='暂不支持此类型';
          end;
        '专利':
          begin
            result:='[PID='+PID+']';
            result:=result+StringReplace(FieldByName(_Col_basic_Author_).AsString,';',',',[rfReplaceAll]);
            result:=result+'. ';
            result:=result+FieldByName(_Col_basic_Title_).AsString;

            stmp:=FieldByName(_Col_basic_ISBN_ISSN_).AsString;
            if stmp<>'' then result:=result+': '+stmp;
            result:=result+'[P].';
            stmp:=FieldByName(_Col_basic_PubTime_).AsString;
            if stmp<>'' then result:=' '+result+stmp+'.';
          end;
        '其它文献':
          begin
            result:='暂不支持此类型';
          end;
        '标准规范':
          begin
            result:='[PID='+PID+']';
            result:=result+StringReplace(FieldByName(_Col_basic_Author_).AsString,';',',',[rfReplaceAll]);
            result:=result+'. ';
            result:=result+FieldByName(_Col_basic_Title_).AsString;
            result:=result+': ';
            result:=result+FieldByName(_Col_basic_ISBN_ISSN_).AsString;
            result:=result+'[S].';
            //result:=result+FieldByName(_Col_basic_City_).AsString;
            //result:=result+':';
            //result:=result+FieldByName(_Col_basic_Organ_).AsString;
            //result:=result+',';
            tmpDateTime:=FieldByName(_Col_basic_PubTime_).AsDateTime;
            if tmpDateTime<>0 then
              begin
                DateTimeToString(stmp,'yyyy:mm',tmpDateTime,[]);
                if length(stmp)=7 then result:=result+stmp+'.';
              end;
          end;
        else result:='暂不支持此类型';
      end;
    end;
end;
function TRTFP.GetCAJCD(PID:RTFP_ID):string;
begin
  ShowMsgOK('警告','暂不支持导出CAJ/CD');
end;
function TRTFP.GetMLA(PID:RTFP_ID):string;
begin
  ShowMsgOK('警告','暂不支持导出MLA');
end;
function TRTFP.GetAPA(PID:RTFP_ID):string;
begin
  ShowMsgOK('警告','暂不支持导出APA');
end;
function TRTFP.GetChaXin(PID:RTFP_ID):string;
begin
  ShowMsgOK('警告','暂不支持导出查新');
end;
function TRTFP.GetRef_InOrder(PID:RTFP_ID):string;
begin
  result:='^[PID='+PID+']';
end;
function TRTFP.GetRef_AurYear(PID:RTFP_ID):string;
var stmp,clip:string;
    str:TStringList;
    poss:integer;
    function IsAscii(str:string):boolean;
    var index:integer;
    begin
      for index:=1 to length(str) do if str[index] in [#128..#255] then begin result:=false;exit end;
      result:=true;
    end;

begin
  result:='(';
  with InitBasic(PID) do
    begin
      stmp:=FieldByName(_Col_basic_Author_).AsString;
      str:=TStringList.Create;
      try
        poss:=pos(';',stmp);
        while poss>0 do
          begin
            clip:=stmp;
            delete(clip,poss,length(clip));
            str.Add(clip);
            delete(stmp,1,poss);
            poss:=pos(';',stmp);
          end;
        str.Add(stmp);
        result:=result+str[0];
        if str.Count>1 then begin
          if IsAscii(str[0]) then result:=result+' et al.'
          else result:=result+' 等';
        end;
      finally
        str.Free;
      end;
      result:=result+', '+FieldByName(_Col_basic_Year_).AsString;
    end;
  result:=result+')';
end;

procedure TRTFP.ImportPapersFromEStudy(str:TStrings;DefaultCl:TKlass);
var stmp:TStringList;
    PID,line,header:string;
    poss:integer;
begin
  CurrentRTFP.BeginUpdate;
  stmp:=TStringList.Create;
  ConfirmState.Enable;
  try
    for line in str do
      begin
        header:=line;
        poss:=pos(': ',header);
        if poss>0 then delete(header,poss,length(header));
        stmp.Add(line);
        case header of
          'Link-链接','Link','链接':
            begin
              PID:=AddPaper('',apmReference);
              if DefaultCl<>nil then KlassInclude(DefaultCl.Name,PID);
              LoadFromEStudy(PID,stmp);
              stmp.Clear;
            end;
        end;
      end;
  finally
    stmp.Free;
    CurrentRTFP.EndUpdate;
    CurrentRTFP.FieldAndRecordChange;
    ConfirmState.Disable;
  end;
end;
procedure TRTFP.ImportPapersFromRefWork(str:TStrings;DefaultCl:TKlass);
begin
  ShowMsgOK('警告','暂不支持批量导入RefWork');
end;
procedure TRTFP.ImportPapersFromEndNote(str:TStrings;DefaultCl:TKlass);
begin
  ShowMsgOK('警告','暂不支持批量导入EndNote');
end;
procedure TRTFP.ImportPapersFromNoteExpress(str:TStrings;DefaultCl:TKlass);
begin
  ShowMsgOK('警告','暂不支持批量导入NoteExpress');
end;
procedure TRTFP.ImportPapersFromNoteFirst(str:TStrings;DefaultCl:TKlass);
begin
  ShowMsgOK('警告','暂不支持批量导入NoteFirst');
end;
procedure TRTFP.ImportPapersFromRIS(str:TStrings;DefaultCl:TKlass);
var stmp:TStringList;
    PID,line,header:string;
begin
  CurrentRTFP.BeginUpdate;
  stmp:=TStringList.Create;
  try
    for line in str do
      begin
        header:=line;
        delete(header,3,length(header));
        stmp.Add(line);
        case uppercase(header) of
          'ER':
            begin
              PID:=AddPaper('',apmReference);
              if DefaultCl<>nil then KlassInclude(DefaultCl.Name,PID);
              LoadFromRIS(PID,stmp);
              stmp.Clear;
            end;
        end;
      end;
  finally
    stmp.Free;
    CurrentRTFP.EndUpdate;
    CurrentRTFP.FieldAndRecordChange;
  end;
end;

procedure TRTFP.UpdatePIDExpr(PID:RTFP_ID;AufScpt:TAufScript);
begin
  AufScpt.Expression.Global.TryAddExp('CPID',narg('"',PID,'"'));
end;

procedure TRTFP.ProjectPropertiesValidate(AValueListEditor:TValueListEditor);
begin
  AValueListEditor.Values['工程标题']:=Self.Title;
  AValueListEditor.Values['创建用户']:=Self.User;

  AValueListEditor.Values['创建日期']:=Self.Tag['创建日期'];
  AValueListEditor.Values['修改日期']:=Self.Tag['修改日期'];

  AValueListEditor.Values['PDF打开方式']:=Self.Tag['PDF打开方式'];
  AValueListEditor.Values['CAJ打开方式']:=Self.Tag['CAJ打开方式'];

  AValueListEditor.Values['最后保存版本']:=Version;


end;

procedure TRTFP.ProjectPropertiesDataPost(AValueListEditor:TValueListEditor);
begin
  Self.Title:=AValueListEditor.Values['工程标题'];
  Self.User:=AValueListEditor.Values['创建用户'];

  Self.Tag['PDF打开方式']:=AValueListEditor.Values['PDF打开方式'];
  Self.Tag['CAJ打开方式']:=AValueListEditor.Values['CAJ打开方式'];
end;

procedure TRTFP.RebuildMainGrid;
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
    klass:TKlass;

    procedure DoInsertPaperDS(PID:RTFP_ID);
    var NextPID:RTFP_ID;
    begin
      with FPaperDS do
        begin
          if not EOF then
            begin
              Next;
              NextPID:=FieldByName(_Col_PID_).AsString;
              Prior;
            end
          else NextPID:='000000';
          if NextPID <> PID then
            begin
              Insert;
              FieldByName(_Col_PID_).AsString:=PID;
              Post;
            end;
        end;
    end;
    procedure InsertPaperDS(PID:RTFP_ID);
    var crl,crh,mid:longint;
        npid,tmpid:dword;
    begin
      npid:=TRTFP.IDToNum(PID);
      crl:=0;crh:=FPaperDS.RecordCount-1;
      if crh<0 then begin
        DoInsertPaperDS(PID);
        exit;
      end;
      WITH FPaperDS DO BEGIN
        while crl<>crh do
          begin
            mid:=(crl+crh) div 2;
            RecNo:=mid;
            tmpid:=TRTFP.IDToNum(FieldByName(_Col_PID_).AsString);
            if tmpid=npid then exit else
              begin
                if tmpid>npid then crh:=mid
                else crl:=mid + (crl+crh) mod 2;
              end;
          end;
        RecNo:=crl;
        DoInsertPaperDS(PID);
      END;
    end;

begin

  if (not IsUpdating) and (FOnMainGridRebuilding<>nil) then FOnMainGridRebuilding(Self);
  BeginUpdate;
  try
    bm:=FPaperDS.GetBookmark;
    FPaperDS.Clear;
    PaperDSFieldDefs.Clear;
    tmpDbf:=FPaperDB;
    fields_cnt:=0;
    for pcol:=0 to tmpDbf.FieldDefs.Count-1 do
      begin
        tmpFieldDef:=tmpDbf.FieldDefs.Items[pcol];
        //case
        FPaperDS.FieldDefs.Add(tmpFieldDef.Name,tmpFieldDef.DataType,tmpFieldDef.Size);
        fields_ref[fields_cnt].AG:=nil;
        fields_ref[fields_cnt].FI:=tmpFieldDef.Index;
        PaperDSFieldDefs.Add(nil);//基础的PaperAttrs没有对应的AttrsField，所以用nil代替。
        inc(fields_cnt);
        //end
      end;
    paperDB_cnt:=fields_cnt;
    pi:=-1;
    for tmpAG in FFieldList do begin
      inc(pi);
      attr_range[pi].max:=-1;
      attr_range[pi].min:=fields_cnt;
      for tmpAF in tmpAG.FieldList do
        begin
          if not tmpAF.Shown then continue;
          attr_range[pi].max:=fields_cnt;
          tmpFieldDef:=tmpAF.FieldDef;

          dat_type:=tmpFieldDef.DataType;
          case dat_type of
            ftMemo,ftWideMemo,ftFmtMemo:
              FPaperDS.FieldDefs.Add(tmpFieldDef.Name+'('+tmpAG.Name+')',ftString,255);
            else
              FPaperDS.FieldDefs.Add(tmpFieldDef.Name+'('+tmpAG.Name+')',dat_type,tmpFieldDef.Size);
          end;
          fields_ref[fields_cnt].AG:=tmpAG;
          fields_ref[fields_cnt].FI:=tmpFieldDef.Index;
          PaperDSFieldDefs.Add(tmpAF);
          inc(fields_cnt);
        end;
    end;
    max_attr:=pi;

    FPaperDS.CreateTable;
    FPaperDS.Open;
    FPaperDS.Last;

    IF (FKlassList.Count=0) or (FKlassList.AllUnChecked) THEN BEGIN
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
    END ELSE BEGIN
      for klass in FKlassList do
        begin
          with klass.Dbf do begin
            if not klass.FilterEnabled then continue;
            if not Active then Open;
            First;
            while not EOF do
              begin
                InsertPaperDS(FieldByName(_Col_PID_).AsString);
                Next;
              end;
          end;
        end;
      FPaperDS.First;
      if not FPaperDS.Active then FPaperDB.Open;
      FPaperDB.IndexName:='id';
      while not FPaperDS.EOF do begin
        if FPaperDB.SearchKey(FPaperDS.FieldByName(_Col_PID_).AsString,stEqual) then
          begin
            FPaperDS.Edit;
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
            FPaperDS.Post;
          end;
        FPaperDS.Next;
      end;
    END;

    IF FPaperDS.EOF and FPaperDS.BOF THEN ELSE BEGIN
      for pj:=0 to max_attr do
        begin
          if attr_range[pj].min > attr_range[pj].max then continue;
          tmpDbf:=FFieldList[pj].Dbf;
          if tmpDbf.EOF and tmpDbf.BOF then continue;

          FPaperDS.First;
          if not FPaperDS.EOF then repeat
            PID:=FPaperDS.FieldByName(_Col_PID_).AsString;
            tmpDbf.IndexName:='id';
            if tmpDbf.SearchKey(PID,stEqual) then begin
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
          until FPaperDS.EOF;
        end;
    END;
    if FPaperDS.BookmarkValid(bm) then FPaperDS.GotoBookmark(bm);
  finally
    EndUpdate;
    if (not IsUpdating) and (FOnMainGridRebuildDone<>nil) then FOnMainGridRebuildDone(Self);
  end;
end;

procedure TRTFP.UpdateCurrentRec(PID:RTFP_ID);
var nowPID:RTFP_ID;
    fieldname,attrsname:string;
    field_index,poss,len:integer;
    bm:TBookMark;
begin
  nowPID:=FPaperDS.FieldByName(_Col_PID_).AsString;
  if PID='' then PID:=NowPID;
  BeginUpdate;
  if nowPID<>PID then with FPaperDS do begin
    bm:=Bookmark;
    First;
    while not EOF do
      begin
        if FieldByName(_Col_PID_).AsString=PID then break;
        Next;
      end;
    if EOF then begin
      ShowMsgOK('错误','UpdateCurrentRec找不到PID['+PID+']');
      EndUpdate;exit;
    end;
  end;

  FPaperDS.Edit;

  for field_index:=0 to FPaperDS.FieldDefs.Count-1 do
    begin
      fieldname:=FPaperDS.FieldDefs[field_index].Name;
      if fieldname=_Col_PID_ then continue;
      poss:=pos('(',fieldname);
      if poss>0 then begin
        len:=length(fieldname);
        attrsname:=fieldname;
        delete(fieldname,poss,len);
        delete(attrsname,1,poss);
        delete(attrsname,length(attrsname),1);
        FPaperDS.Fields[field_index].AsString:=ReadFieldAsString(fieldname,attrsname,PID,[]);
      end else begin
        FPaperDS.Fields[field_index].AsString:=GetPaperAttrs(fieldname,PID);
      end;
    end;

  FPaperDS.Post;

  if nowPID<>PID then with FPaperDS do begin
    if BookmarkValid(bm) then GotoBookmark(bm);
  end;
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

  if (not IsUpdating) and (FOnMainGridRebuilding<>nil) then FOnMainGridRebuilding(Self);
  BeginUpdate;
  try

    StringReplace(cmd,'=',' eql ',[rfReplaceAll]);
    StringReplace(cmd,'!=',' neq ',[rfReplaceAll]);
    StringReplace(cmd,'<>',' neq ',[rfReplaceAll]);
    StringReplace(cmd,'>',' gtr ',[rfReplaceAll]);
    StringReplace(cmd,'>=',' gtq ',[rfReplaceAll]);
    StringReplace(cmd,'<',' les ',[rfReplaceAll]);
    StringReplace(cmd,'<=',' leq ',[rfReplaceAll]);

    FAuf.Script.IO_fptr.error:=nil;
    FAuf.Script.IO_fptr.print:=nil;
    FAuf.Script.IO_fptr.echo:=nil;
    FAuf.ReadArgs(cmd);
    if FAuf.ArgsCount<2 then exit;

    colname:=FAuf.nargs[0].arg;
    method:=FAuf.nargs[1].arg;
    value:=FAuf.nargs[2].arg;

    case method of
      'true','false':;
      else if FAuf.ArgsCount<3 then exit;
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

      end;
  finally
    EndUpdate;
    if (not IsUpdating) and (FOnMainGridRebuildDone<>nil) then FOnMainGridRebuildDone(Self);
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
      (AListView as TACL_ListView).GetShellNodeItem(tmpAG.Name).Data:=tmpAG;
    end;
  AListView.EndUpdate;
  for tmpAG in FFieldList do
    begin
      if tmpAG.GroupShown then (AListView as TACL_ListView).CheckShellNodeItem(tmpAG.Name,true);
      for tmpAF in tmpAG.FieldList do
        if tmpAF.Shown then (AListView as TACL_ListView).CheckShellNodeItem(tmpAG.Name+'\'+tmpAF.FieldName,true);
    end;
  //这部分不知道那个地方有问题，条目不能正确勾选。
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
  (AListView as TACL_ListView).CheckShellNodeItem('class',true);
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

{
procedure TRTFP.NodeViewValidate(PID:RTFP_ID;AValueListEditor:TValueListEditor);
var tmpDef:TFieldDef;
    tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
begin
  AValueListEditor.Clear;
  for tmpAG in FFieldList do
    begin
      with tmpAG.Dbf do
        begin
          IndexName:='id';
          if not SearchKey(PID,stEqual) then continue;
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
            EditFieldAsString(FieldName,tmpAttrName,PID,AValueListEditor.Values[ColName],[aeForceEditIfTypeDismatch]);
          ftInteger,ftLargeint,ftSmallint,ftWord:
            EditFieldAsInteger(FieldName,tmpAttrName,PID,Usf.to_i(AValueListEditor.Values[ColName]),[]);
          ftFloat:
            EditFieldAsDouble(FieldName,tmpAttrName,PID,Usf.to_f(AValueListEditor.Values[ColName]),[]);
          //ftDateTime,ftDate,ftTime:
          //  EditFieldAsDateTime(FieldName,tmpAttrName,PID,StrToDateTime(AValueListEditor.Values[ColName]),[]);
          else assert(false,'没有合适提交方式的字段类型！');
        end;
      end;
    end;
  EndUpdate;
  ReNewModifyTime(PID);
end;
}
procedure TRTFP.FmtCmtValidate(PID:RTFP_ID;AttrName,FieldName:string;Memo:TMemo);
begin
  Memo.Clear;
  if CheckField(FieldName,AttrName,[ftMemo,ftWideMemo,ftFmtMemo]) then begin
    //Memo.Lines.CommaText:=StringReplace(ReadFieldAsString(FieldName,AttrName,PID,[]),Comma_Symbol,#13#10,[rfReplaceAll]);
    ReadFieldAsMemo(FieldName,AttrName,PID,Memo.Lines,[]);
  end;
  ReNewCheckTimeWithoutChange(PID);//如果Change会导致Validate更新，这个需要重构以下UI逻辑，暂时先不管
  //ReNewCheckTime(PID);
end;

procedure TRTFP.FmtCmtDataPost(PID:RTFP_ID;AttrName,FieldName:string;Memo:TMemo);
begin
  BeginUpdate;
  if CheckField(FieldName,AttrName,[ftMemo,ftWideMemo,ftFmtMemo]) then begin
    //EditFieldAsString(FieldName,AttrName,PID,StringReplace(Memo.Lines.CommaText,#13#10,Comma_Symbol,[rfReplaceAll]),[]);
    EditFieldAsMemo(FieldName,AttrName,PID,Memo.Lines,[]);
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


procedure TRTFP.FormatEditScrollBoxResize(Sender:TObject);
var HexaWidth,TriWidth,FullWidth:integer;
begin
  with FFormatEditComponentList do begin
    if Count<5 then exit;
    if TObject(Items[0]).ClassType<>TSplitter then exit;
    if TObject(Items[1]).ClassType<>TSplitter then exit;
    if TObject(Items[2]).ClassType<>TSplitter then exit;
    if TObject(Items[3]).ClassType<>TSplitter then exit;
    if TObject(Items[4]).ClassType<>TSplitter then exit;
    FullWidth:=(Sender as TScrollBox).Width;
    HexaWidth:=(FullWidth - 7*6) div 6;
    TriWidth:=(FullWidth - 7*6) div 3;
    TSplitter(Items[0]).Left:=HexaWidth + 6;
    TSplitter(Items[1]).Left:=TriWidth + 12;
    TSplitter(Items[2]).Left:=(FullWidth - 6) div 2;
    TSplitter(Items[3]).Left:=FullWidth - TriWidth - 12;
    TSplitter(Items[4]).Left:=FullWidth - HexaWidth - 6;

  end;
end;

procedure TRTFP.FormatEditBuild(AScrollBox:TScrollBox;AFormatFile:string);
var str:TStringList;
begin
  str:=TStringList.Create;
  try
    try
      str.LoadFromFile(Self.FFilePath+Self.FRootFolder+'\format\'+AFormatFile);
      Self.FormatEditBuild(AScrollBox,str);
    except
      assert(false,'Format文件未找到。');
    end;
  finally
    str.Free;
  end;
end;

procedure TRTFP.FormatEditBuild(AScrollBox:TScrollBox;AFormat:TStrings);
var SplitterObj:TSplitter;
    FormatPanel:TFormatEditPanel;
    index:integer;
    stmp,is_editable,str_editable:string;
    tmp:integer;
begin
  assert(FFormatEditComponentList.Count=0,'FormatEditBuild之前需要FormatEditClear！');
  with FFormatEditComponentList do begin
    for index:=0 to 4 do begin
      SplitterObj:=TSplitter.Create(AScrollBox);
      with SplitterObj do
        begin
          Parent:=AScrollBox;
          Align:=alNone;
          ResizeAnchor:=akLeft;
          Width:=6;
          Top:=0;
          Height:=6;
          Enabled:=false;
        end;
      Add(SplitterObj);
    end;
    //在这里写format-script
    for stmp in AFormat do begin
      //CmpType AttrsName FieldName DisplayName Top Height Left_Col Right_Col
      Auf.ReadArgs(stmp);
      if Auf.ArgsCount<8 then continue;
      case lowercase(Auf.nargs[0].arg) of
        'memo':FormatPanel:=TFormatEditPanel.Create(TMemo);
        'edit':FormatPanel:=TFormatEditPanel.Create(TEdit);
        'combo':FormatPanel:=TFormatEditPanel.Create(TComboBox);
        'check':FormatPanel:=TFormatEditPanel.Create(TCheckBox);
        'image':FormatPanel:=TFormatEditPanel.Create(TFmtImage);
        'list':FormatPanel:=TFormatEditPanel.Create(TListBox);
        else continue;
      end;

      is_editable:='';
      if Auf.ArgsCount>8 then Auf.TryArgToString(8,is_editable);
      if lowercase(is_editable)='editable' then begin
        FormatPanel.Editable:=true;
        str_editable:='';
        //FormatPanel.BevelColor:=clGreen;//在formatEdit中重写Paint改颜色，目前临时用标题改好了
      end else begin
        FormatPanel.Editable:=false;
        str_editable:='(只读)';
        //FormatPanel.BevelColor:=clRed;//在formatEdit中重写Paint改颜色，目前临时用标题改好了
      end;

      Add(FormatPanel);
      FormatPanel.AttrsName:=Auf.nargs[1].arg;
      FormatPanel.FieldName:=Auf.nargs[2].arg;
      FormatPanel.DisplayName:=Auf.nargs[3].arg;
      FormatPanel.TitleLabel.Caption:=Auf.nargs[3].arg+str_editable+': ';
      with FormatPanel do begin
        Parent:=AScrollBox;
        BeginUpdateBounds;
        Anchors:=[akTop,akLeft,akRight];

        //TControl(Component).Enabled:=Editable;

        case lowercase(Auf.nargs[6].arg) of
          '0','l':begin
                AnchorSideLeft.Control:=AScrollBox;
                AnchorSideLeft.Side:=asrLeft;
                BorderSpacing.Left:=6;
              end;
          'lm':begin
                AnchorSideLeft.Control:=TSplitter(Items[0]);
                AnchorSideLeft.Side:=asrRight;
              end;
          '1','ml':begin
                AnchorSideLeft.Control:=TSplitter(Items[1]);
                AnchorSideLeft.Side:=asrRight;
              end;
          '2','m':begin
                AnchorSideLeft.Control:=TSplitter(Items[2]);
                AnchorSideLeft.Side:=asrRight;
              end;
          '3','mr':begin
                AnchorSideLeft.Control:=TSplitter(Items[3]);
                AnchorSideLeft.Side:=asrRight;
              end;
          'rm':begin
                AnchorSideLeft.Control:=TSplitter(Items[4]);
                AnchorSideLeft.Side:=asrRight;
              end;
          else ;
        end;
        case lowercase(Auf.nargs[7].arg) of
          '4','r':begin
                AnchorSideRight.Control:=AScrollBox;
                AnchorSideRight.Side:=asrRight;
                BorderSpacing.Right:=6;
              end;
          'rm':begin
                AnchorSideRight.Control:=TSplitter(Items[4]);
                AnchorSideRight.Side:=asrLeft;
              end;
          '3','mr':begin
                AnchorSideRight.Control:=TSplitter(Items[3]);
                AnchorSideRight.Side:=asrLeft;
              end;
          '2','m':begin
                AnchorSideRight.Control:=TSplitter(Items[2]);
                AnchorSideRight.Side:=asrLeft;
              end;
          '1','ml':begin
                AnchorSideRight.Control:=TSplitter(Items[1]);
                AnchorSideRight.Side:=asrLeft;
              end;
          'lm':begin
                AnchorSideRight.Control:=TSplitter(Items[0]);
                AnchorSideRight.Side:=asrLeft;
              end;
          else ;
        end;

        AnchorSideTop.Control:=AScrollBox;
        AnchorSideTop.Side:=asrTop;
        BorderSpacing.Top:=Usf.to_i(Auf.nargs[4].arg);
        EndUpdateBounds;
        tmp:=Usf.to_i(Auf.nargs[5].arg);
        Height:=tmp;
      end;
    end;
  end;

  AScrollBox.OnResize:=@FormatEditScrollBoxResize;
  AScrollBox.OnResize(AScrollBox);
end;

procedure TRTFP.FormatEditClear(AScrollBox:TScrollBox);
begin
  with FFormatEditComponentList do
    while Count<>0 do
      begin
        if TObject(Items[0]).ClassType=TSplitter then TSplitter(Items[0]).Free
        else TFormatEditPanel(Items[0]).Free;
        Delete(0);
      end;
end;

procedure TRTFP.FormatEditValidate(PID:string);
var Item:Pointer;
begin
  for Item in FFormatEditComponentList do begin
    if TObject(Item).ClassType=TSplitter then continue;
    with TFormatEditPanel(Item) do begin
      try
        case ComponentClass.ClassName of
          'TEdit':AsString:=ReadFieldAsString(FieldName,AttrsName,PID,[aeFailIfNoPID,aeFailIfNoField]);
          'TMemo':ReadFieldAsMemo(FieldName,AttrsName,PID,AsMemo,[aeFailIfNoPID,aeFailIfNoField]);
          'TCheckBox':AsBoolean:=ReadFieldAsBoolean(FieldName,AttrsName,PID,[aeFailIfNoPID,aeFailIfNoField]);
          'TComboBox':AsString:=ReadFieldAsString(FieldName,AttrsName,PID,[aeFailIfNoPID,aeFailIfNoField]);
          'TFmtImage':ReadFieldAsBitmap(FieldName,AttrsName,PID,AsBitmap,[aeFailIfNoPID,aeFailIfNoField]);
          'TListBox':ReadFieldAsMemo(FieldName,AttrsName,PID,AsMemo,[aeFailIfNoPID,aeFailIfNoField]);
        end;
        RestoreState;
      except
        on E:AttrsNoFieldErr do case ComponentClass.ClassName of
          'TEdit','TComboBox':begin
            AsString:='';
            State:=fesNoField;
          end;
          'TCheckBox':begin
            AsBoolean:=false;
            State:=fesNoField;
          end;
          'TMemo','TListBox':begin
            AsMemo.Clear;
            State:=fesNoField;
          end;
          'TFmtImage':begin
            AsBitmap.Clear;
            State:=fesNoField;
          end;
        end;
        on E:AttrsNoPIDErr do case ComponentClass.ClassName of
          'TEdit','TComboBox':begin
            AsString:='';
            State:=fesNodata;
          end;
          'TCheckBox':begin
            AsBoolean:=false;
            State:=fesNodata;
          end;
          'TMemo','TListBox':begin
            AsMemo.Clear;
            State:=fesNodata;
          end;
          'TFmtImage':begin
            AsBitmap.Clear;
            State:=fesNodata;
          end;
        end;
      end;
    end;
  end;
end;

procedure TRTFP.FormatEditDataPost(PID:string);
var Item:Pointer;
begin
  BeginUpdate;
  for Item in FFormatEditComponentList do begin
    if TObject(Item).ClassType=TSplitter then continue;
    with TFormatEditPanel(Item) do begin
      case ComponentClass.ClassName of
        'TEdit':EditFieldAsString(FieldName,AttrsName,PID,AsString,[aeForceEditIfTypeDismatch]);
        'TMemo':EditFieldAsMemo(FieldName,AttrsName,PID,AsMemo,[]);
        'TCheckBox':EditFieldAsBoolean(FieldName,AttrsName,PID,AsBoolean,[]);
        'TComboBox':EditFieldAsString(FieldName,AttrsName,PID,AsString,[]);
        'TFmtImage':EditFieldAsBitmap(FieldName,AttrsName,PID,AsBitmap,[]);
        'TListBox':EditFieldAsMemo(FieldName,AttrsName,PID,AsMemo,[]);
      end;
      RestoreState;
    end;
  end;
  EndUpdate;
  DataChange(PID);
end;

function TRTFP.GetCurrentPathFull:string;
begin
  result:=FFilePath+FRootFolder+'\';
end;

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

function TRTFP.GetPaperCount:integer;
var acc:integer;
begin
  acc:=0;
  with FPaperDB do begin
    if not Active then Open;
    First;
    while not EOF do
      begin
        inc(acc);
        Next;
      end;
    result:=acc;
  end;
end;
function TRTFP.GetBackupPaperCount:integer;
begin
  result:=0;
  with FPaperDB do begin
    if not Active then Open;
    First;
    while not EOF do begin
      if FieldByName(_Col_Paper_Is_Backup_).AsBoolean then inc(result);
      Next;
    end;
  end;
end;
function TRTFP.GetExternPaperCount:integer;
begin
  result:=0;
  with FPaperDB do begin
    if not Active then Open;
    First;
    while not EOF do begin
      if FieldByName(_Col_Paper_Folder_).AsString='extern' then inc(result);
      Next;
    end;
  end;
end;
function TRTFP.GetWeblnkPaperCount:integer;
begin
  result:=0;
  with FPaperDB do begin
    if not Active then Open;
    First;
    while not EOF do begin
      if FieldByName(_Col_Paper_Folder_).AsString='weblnk' then inc(result);
      Next;
    end;
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
      '+':result:=result+62;//0.1.1-alpha.18以前
      '-':result:=result+63;//0.1.1-alpha.18以前
      '{':result:=result+62;
      '}':result:=result+63;
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
class function TRTFP.IsKlassName(klassname:ansistring):boolean;
var acc:integer;
begin
  result:=false;
  acc:=0;
  if klassname='' then exit;
  while klassname<>'' do
    begin
      if not (klassname[1] in ['a'..'z','A'..'Z','0'..'9',#128..#255,#32,'(',')','_','-','&','+',':','"','''']) then exit;
      inc(acc);
      if acc>40 then exit;
      delete(klassname,1,1);
    end;
  result:=true;
end;
class function TRTFP.IsAttrsName(attrsname:ansistring):boolean;
var acc:integer;
begin
  result:=false;
  acc:=0;
  if attrsname='' then exit;
  while attrsname<>'' do
    begin
      if not (attrsname[1] in ['a'..'z','A'..'Z','0'..'9',#128..#255,'_','-']) then exit;
      inc(acc);
      if acc>20 then exit;
      delete(attrsname,1,1);
    end;
  result:=true;
end;
class function TRTFP.IsFieldName(fieldname:ansistring):boolean;
var acc:integer;
begin
  result:=false;
  acc:=0;
  if fieldname='' then exit;
  while fieldname<>'' do
    begin
      if not (fieldname[1] in ['a'..'z','A'..'Z','0'..'9',#128..#255,'_','-']) then exit;
      inc(acc);
      if acc>12 then exit;
      delete(fieldname,1,1);
    end;
  result:=true;
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
  case AFieldDef.DisplayName of
    _Col_Paper_Folder_:begin result:=2;exit end;
    _Col_Paper_FileHash_:begin result:=2;exit end;
    _Col_Paper_FileSize_:begin result:=2;exit end;
    _Col_OID_:begin result:=2;exit end;
    else ;
  end;
  result:=40;
  NameSize:=length(AFieldDef.DisplayName)*8+16;
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
  if result<NameSize then result:=NameSize;
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
var d1,d2,d3:qword;
begin
  GetDiskFreeSpaceEx(pchar(discchar+':\'),@d1,@d2,@d3);
  {
  ShowMsgOK('',
    'DISC '+discchar+':'+#13+#10+
    '  d1='+IntToStr(d1)+#13+#10+
    '  d2='+IntToStr(d2)+#13+#10+
    '  d3='+IntToStr(d3)+#13+#10+
    #13+#10+
    '  可用字节大小='+IntToStr(d1)+'('+FloatToStr(d1/1024/1024/1024)+'GB)'+#13+#10+
    '  总字节大小='+IntToStr(d2)+'('+FloatToStr(d2/1024/1024/1024)+'GB)'+#13+#10+
    '  剩余字节大小='+IntToStr(d3)+'('+FloatToStr(d3/1024/1024/1024)+'GB)'+#13+#10
  );
  }
  if d1<$ffffffff then result:=false
  else result:=true;

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
  {$ifdef Windows}
  result:=false;
  if not ForceDirectories(ExtractFilePath(dest)) then exit;
  result:=CopyFile(pchar(UTF8ToWinCP(source)),pchar(UTF8ToWinCP(dest)),bFailIfExist);
  {$endif}
end;

class function TRTFP.FileDelete(source:string):boolean;
begin
  {$ifdef Windows}
  result:=DeleteFile(pchar(UTF8ToWinCP(source)));
  {$endif}
end;

class function TRTFP.FileMove(source,dest:string;bFailIfExist:boolean):boolean;
begin
  result:=false;
  {$ifdef Windows}
  if CopyFile(pchar(UTF8ToWinCP(source)),pchar(UTF8ToWinCP(dest)),bFailIfExist) then
    result:=DeleteFile(pchar(UTF8ToWinCP(source)))
  else
    result:=false;
  {$endif}

end;

class function TRTFP.FileRename(oldname,newname:string):boolean;
begin
  result:=ReNameFile(oldname,newname);
end;

class function TRTFP.MakeDir(filename:string):boolean;
begin
  result:=false;
  result:=ForceDirectories(filename);
end;

class function TRTFP.OpenDir(filename:string):boolean;
begin
  {$ifdef Windows}
  ShellExecute(0,'open','explorer',pchar('/select,"'+filename+'"'),nil,SW_NORMAL);
  {$endif}
end;

class function TRTFP.OpenFile(filename:string;exefile:string=''):boolean;
begin
  {$ifdef Windows}
  if exefile='' then
    ShellExecute(0,'open',pchar('"'+filename+'"'),'','',SW_NORMAL)
  else
    ShellExecute(0,'open',pchar(exefile),pchar('"'+filename+'"'),'',SW_NORMAL);
  {$endif}
end;

class function TRTFP.OpenLink(linkage:string):boolean;
begin
  {$ifdef Windows}
  ShellExecute(0,'open',pchar(linkage),'','',SW_NORMAL);
  {$endif}
end;

class function TRTFP.VersionCheck(check,target:string):boolean;
var s1,s2:TStringList;
    pi,v1,v2:integer;
begin
  //0.1.1-alpha.18 加入
  if check='' then check:='0.0.0-alpha.0';
  result:=true;
  s1:=TStringList.Create;
  s2:=TStringList.Create;
  try
    s1.CommaText:=StringReplace(StringReplace(check,'-',',',[rfReplaceAll]),'.',',',[rfReplaceAll]);
    s2.CommaText:=StringReplace(StringReplace(target,'-',',',[rfReplaceAll]),'.',',',[rfReplaceAll]);
    if (s1.Count<=0) or (s1.Count <> s2.Count) then raise Exception.Create('');
    for pi:=0 to s1.Count-1 do
      begin
        try
          v1:=StrToInt(s1[pi]);
          v2:=StrToInt(s2[pi]);
          if v1<>v2 then begin
            if v1<v2 then result:=false;
            exit;
          end;
        except
          v1:=strcomp(pchar(s1[pi]),pchar(s2[pi]));
          if v1<>0 then begin
            if v1<0 then result:=false;
            exit;
          end;
        end;
      end;
  finally
    s1.Free;
    s2.Free;
  end;
end;

end.

