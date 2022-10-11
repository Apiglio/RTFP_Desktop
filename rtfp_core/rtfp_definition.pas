//引用PDF里的图片
//网页下载要研究一下JS
//字段更新日志(有必要吗)
//Memo字段的搜索
//尽快将所有弹窗统一样式（在做了，有点小问题，按键中文或者自动布局还没有处理好）
//【真的有难度】TKlass准备增加一个TKlassGroup类，和Attrs一样格式，这样才能保证ACL_ListView可以不重新折叠
//增加替换URL的加载模式用以适用不同的webvpn
//FWaitForm加进度条
//“待注脚知识元”
//FormatEdit快捷键提交
//截图转文字想想办法，试试内嵌python
//单元格设色属性、分类与属性组折叠等界面属性需要储存
//【快别说了，整个功能用不了了】FormatEdit中的Image通道化不能立刻更新！！！//procedure TFmtImage.BandSolo(band:byte);
//分类字段清除后字段数据还在dbf中，没有pack
//我他妈服了，DBF的文件错误也太多了吧？？？？
//异常关闭的恢复
//formatEditComponent在图像字段数据有误时的解决方案需要明细
//FormatEdit中图像压缩方法，图像字段目前来看太占地方了


//FUNCTION TO IMPLEMENT
//  工程属性加一个简介给自己记录东西
//  报表工具增加进度条工具，结合rtfp_dialog来做

//KNOWN FEATURES
//  图片FormatEdit编辑中所有都是NoData，有一张编辑成Saved以后其他所有也都会变成Saved，重新NodeValidate之后NoData就恢复了
//  为什么AufScriptFrame的两个Dialog初始地址不能改？在projectOpenDone里头。

//KNOWN BUGS
//  在主表中显示的字段不能直接删除，否则报错，出自RebuildMainGrid
//  【FATAL】TableFilter中使用无效的正则表达式会导致崩溃，并且主窗体中try except不能解决问题

//AG和AF的DisplayName
//FieldCalc的主表模式
//FieldMatch的正则模式
//FormatEdit界面右键增加项，替换原本的样式管理


//{$define insert}
{$define save_xml}
{$define test}

unit RTFP_definition;

{$mode objfpc}{$H+}
{$inline on}



interface

uses
  Classes, SysUtils, Dialogs, ValEdit, LazUTF8, StdCtrls, ComCtrls, ExtCtrls, Forms, FileUtil,
  ACL_ListView, Controls, Graphics, RegExpr,

  {$ifdef Windows}
  Windows,
  {$endif}

  {$ifndef insert}
  Apiglio_Useful, auf_ram_var, rtfp_pdfobj, rtfp_files, rtfp_class, rtfp_field,
  rtfp_constants, rtfp_type, rtfp_tags, rtfp_format_component, rtfp_dialog, rtfp_misc, rtfp_dataset_sorter,
  {$endif}
  BufDataset, xmldatapacketreader,
  db, dbf, dbf_common, dbf_fields, sqldb, memds;


type
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

    FDataSetType:TRTFP_DataSetType;

    FProjectTags:TTags;
    FPaperDB,FImageDB,FNotesDB:{TDbf}TDataSet;
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
    FIsOpen:boolean;
  private
    procedure SetPaths(filename:string);
    function UserID(AUser:string):integer;
    function FormatID(AFormat:string):integer;
  protected
    function GetCurrentPathFull:string;
  public
    property IsOpen:boolean read FIsOpen;
    property CurrentFileFull:string read FFileFullName;
    property CurrentPathFull:string read GetCurrentPathFull;
    property UserList:TStringList read FUserList;
    property FormatList:TStringList read FFormatList;

  public
    //这部分设置只与UI设置对接，工程文件本身不存储
    RunPerformance:record
      Backup_SaveXml:boolean;//是否在保存数据库是额外保存xml格式备份
      Fields_ImgFile:boolean;//将FormatEdit的图像保存在image文件夹中
      ForceSaveField:boolean;//在Saved的状态也保存字段属性

      Filter_Command:string;
      Filter_AutoRun:boolean;
      Sorter_Command:string;
      Sorter_AutoRun:boolean;

      Klass_Filter_NOT:boolean;
      Klass_Filter_AND:boolean;//false则为OR

    end;


  //AUFUNC.INC AufScript定义
  public
    procedure SetAuf(AAuf:TAuf);
    procedure UpdatePIDExpr(PID:RTFP_ID;AufScpt:TAufScript);//将选中的节点PID赋值给@CPID

  //TAGS.INC 工程基本属性
  protected
    procedure SetUser(str:string);
    function GetUser:string;
    procedure SetTitle(str:string);
    function GetTitle:string;
    procedure SetVersion(str:string);
    function GetVersion:string;
    function GetOpenPdfExe:ansistring;
    function GetOpenCajExe:ansistring;

    procedure SetTag(index:string;str:string);
    function GetTag(index:string):string;

  public
    property User:string read GetUser write SetUser;
    property Title:string read GetTitle write SetTitle;
    property Version:string read GetVersion write SetVersion;
    property OpenPdfExe:ansistring read GetOpenPdfExe;
    property OpenCajExe:ansistring read GetOpenCajExe;

    property Tag[index:string]:string read GetTag write SetTag;

  //ACCESS_BASE.INC 基本数据库文件操作
  private
    function OpenDbf(dbf_name_no_ext:string;Dbf:{TDbf}TDataSet):boolean;
    function NewDbf(dbf_name_no_ext:string;Dbf:{TDbf}TDataSet):boolean;
    function SaveDbf(dbf_name_no_ext:string;Dbf:{TDbf}TDataSet;save_xml:boolean=false):boolean;
    function CloseDbf(dbf_name_no_ext:string;Dbf:{TDbf}TDataSet):boolean;
    function DeleteDbf(dbf_name_no_ext:string;Dbf:{TDbf}TDataSet):boolean;
    function PackDbf(Dbf:{TDbf}TDataSet):boolean;
  public
    function LocatePID(buf:TDataset;PID:RTFP_ID):boolean;

  //ACCESS_DATA.INC 字段值读写
  public
    function GetFieldType(attrNa,fieldNa:string):TFieldType;

    function ReadBasicString(AName:string;PID:RTFP_ID;fail_if_no_pid:boolean=false):string;//和GetPaperAttrs重复
    procedure EditBasicString(AName:string;PID:RTFP_ID;value:string;fail_if_no_pid:boolean=false);
    function ReadBasicBool(AName:string;PID:RTFP_ID;fail_if_no_pid:boolean=false):boolean;
    procedure EditBasicBool(AName:string;PID:RTFP_ID;value:boolean;fail_if_no_pid:boolean=false);
    function ReadBasicInteger(AName:string;PID:RTFP_ID;fail_if_no_pid:boolean=false):int64;
    procedure EditBasicInteger(AName:string;PID:RTFP_ID;value:int64;fail_if_no_pid:boolean=false);

    function ReadFieldAsString(AName,AAttrsName:string;PID:RTFP_ID;AE:TAttrExtend):string;
    function ReadFieldAsInteger(AName,AAttrsName:string;PID:RTFP_ID;AE:TAttrExtend):int64;
    function ReadFieldAsBoolean(AName,AAttrsName:string;PID:RTFP_ID;AE:TAttrExtend):boolean;
    function ReadFieldAsDateTime(AName,AAttrsName:string;PID:RTFP_ID;AE:TAttrExtend):TDateTime;
    function ReadFieldAsDouble(AName,AAttrsName:string;PID:RTFP_ID;AE:TAttrExtend):double;

    procedure EditFieldAsString(AName,AAttrsName:string;PID:RTFP_ID;value:string;AE:TAttrExtend);
    procedure EditFieldAsInteger(AName,AAttrsName:string;PID:RTFP_ID;value:int64;AE:TAttrExtend);
    procedure EditFieldAsBoolean(AName,AAttrsName:string;PID:RTFP_ID;value:boolean;AE:TAttrExtend);
    procedure EditFieldAsDateTime(AName,AAttrsName:string;PID:RTFP_ID;value:TDateTime;AE:TAttrExtend;modified_time:boolean=true);
    procedure EditFieldAsDouble(AName,AAttrsName:string;PID:RTFP_ID;value:double;AE:TAttrExtend);

    procedure ReadFieldAsMemo(AName,AAttrsName:string;PID:RTFP_ID;buf:TStrings;AE:TAttrExtend);
    procedure EditFieldAsMemo(AName,AAttrsName:string;PID:RTFP_ID;buf:TStrings;AE:TAttrExtend);
    procedure ReadFieldAsBitmap(AName,AAttrsName:string;PID:RTFP_ID;buf:Graphics.TBitMap;AE:TAttrExtend);
    procedure EditFieldAsBitmap(AName,AAttrsName:string;PID:RTFP_ID;buf:Graphics.TBitMap;AE:TAttrExtend);
    procedure EditFieldFromImageFile(AName,AAttrsName:string;PID:RTFP_ID;filename:string;AE:TAttrExtend);
    function GetImgFilePath(AName,AAttrsName:string):string;inline;
    function GetImgFileName(PID:RTFP_ID):string;inline;

  //ACCESS_ATTRS.INC 属性组
  public
    function AddAttrs(AName:string):TAttrsGroup;
    function FindAttrs(AName:string):TAttrsGroup;
    procedure DeleteAttrs(AName:string);

    property FieldList:TAttrsGroupList read FFieldList;

  //ACCESS_FIELD.INC 字段
  private
    procedure DeleteFieldImageFolder(AF:TAttrsField);
    //procedure RenameFieldImageFolder(AF:TAttrsField);
  public
    function AddField(AName:string;AAttrsName:string;AType:TFieldType;ASize:word=0):TAttrsField;
    function FindField(AName:string;AAttrsName:string):TAttrsField;
    procedure DeleteField(AName:string;AAttrsName:string);
    procedure RenameField(AOldName,ANewName:string;AAttrsName:string);
    procedure ReTypeField(AName:string;AAttrsName:string;NewType:TFieldType;NewSize:Integer=0);

    function CheckField(AName:string;AAttrsName:string;AType:TFieldType):boolean;
    function CheckField(AName:string;AAttrsName:string;ATypes:TFieldTypeSet):boolean;
    function GetField(AName:string;AAttrsName:string;PID:RTFP_ID;NewPidIfNotExists:boolean):TField;

    class function FieldMinWidth(AFieldDef:TFieldDef):integer;
    class function FieldOptWidth(AFieldDef:TFieldDef):integer;

  //ACCESS_KLASS.INC 分类
  public
    function AddKlass(klassname:string;pathname:string=''):TKlass;
    function FindKlass(klassname:string):TKlass;
    procedure DeleteKlass(klassname:string);

    function KlassInclude(klassname:string;PID:RTFP_ID):boolean;
    function KlassExclude(klassname:string;PID:RTFP_ID):boolean;
    function KlassIncludeFromCombo(PID:RTFP_ID;active:boolean):boolean;//若显示不止一个分类，弹出选项由用户选择分类

    property KlassList:TKlassList read FKlassList;

  //CITE_TOOL.INC 引注格式
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

  //PAPER.INC 文献节点
  private
    function NewPaperID:RTFP_ID;

  public
    function AddPaper(fullfilename:string;AddPaperMethod:TAddPaperMethod=apmFullBackup):RTFP_ID;//新增一个文献到工程
    function FindPaper(fullfilename:string):RTFP_ID;//查找具体文件在工程中的PID，未找到返回000000
    function DeletePaper(PID:RTFP_ID;PreserveFileNoAsk:boolean=false):boolean;//移除指定PID的文献，第二参数true在MergePaper中使用
    function UpdatePaper(PID:RTFP_ID;fullfilename:string;AddPaperMethod:TAddPaperMethod):boolean;//更新指定PID的文件
    function MergePaper(PID_Main,PID_Vice:RTFP_ID;AFieldSelectOption:TFieldSelectOptions):boolean;//合并两个文献节点

    procedure OpenPaper(PID:RTFP_ID;exename:string='');
    procedure OpenPaperAsPDF(PID:RTFP_ID);inline;
    procedure OpenPaperAsCAJ(PID:RTFP_ID);inline;
    procedure OpenPaperDir(PID:RTFP_ID);inline;
    procedure OpenPaperLink(PID:RTFP_ID);inline;

  //IMAGE.INC 图片节点
  private
    function NewImageID:RTFP_ID;
  public
    function AddImage(fullfilename:string):RTFP_ID;//新增一个图片到工程
    procedure DeleteImage(IID:RTFP_ID);//移除指定IID的图片

  //NODES.INC 注解节点
  private
    function NewNoteID:RTFP_ID;

  public
    function AddNote(fullfilename:string):RTFP_ID;//新增一个注解到工程
    procedure DeleteNote(NID:RTFP_ID);//移除指定NID的注解

  //FORMATEDIT_LIST.INC 样式列表
  public
    function AddFormatDefault:boolean;
    function AddFormatDefault_All:boolean;
    function AddFormatDefault_SysMgr:boolean;
    function AddFormatEditNull(filename:string):boolean;
    function RenFormatEdit(filename,newname:string):boolean;
    function DelFormatEdit(filename:string):boolean;
  private
    procedure LoadFormatEditList;
    procedure LoadFormatList;inline;
    function SaveFormatList:boolean;inline;
    function CloseFormatList:boolean;inline;

  //FORMATEDIT_COMPONENT.INC 样式控件
  private
    FFormatEditComponentList:TList;
  public
    procedure FormatEditScrollBoxResize(Sender:TObject);
    procedure FormatEditBuild(AScrollBox:TScrollBox;AFormatFile:string);
    procedure FormatEditBuild(AScrollBox:TScrollBox;AFormat:TStrings);
    procedure FormatEditClear(AScrollBox:TScrollBox);
    procedure FormatEditValidate(PID:string);
    procedure FormatEditDataPost(PID:string);

    property FormatComponents:TList read FFormatEditComponentList;

  //UPDATE.INC 存档更新
  protected
    procedure Update_0_1_1_alpha_18;
    procedure Update_0_1_2_alpha_8;unimplemented;

  public
    procedure Update(save_version:string);
    class function VersionCheck(check,target:string):boolean;

  //CONTROL_INTERFACE.INC 控件接口（除了FormatEditComponent）
  private
    FPaperDS:TMemDataSet;
    FPaperDSFieldDefs:TList;

  public
    property PaperDS:TMemDataSet read FPaperDS;//筛选后的总表，直接连接DBGrid
    property PaperDSFieldDefs:TList read FPaperDSFieldDefs write FPaperDSFieldDefs;

  public
    procedure ProjectPropertiesValidate(AValueListEditor:TValueListEditor);
    procedure ProjectPropertiesDataPost(AValueListEditor:TValueListEditor);

    procedure RebuildMainGrid;
    procedure UpdateCurrentRec(PID:RTFP_ID);
    procedure TableFilter;
    procedure TableSorter;

    procedure FieldListValidate(AListView:TListView);
    procedure KlassListValidate(AListView:TListView);

    procedure FmtCmtValidate(PID:RTFP_ID;AttrName,FieldName:string;Memo:TMemo);
    procedure FmtCmtDataPost(PID:RTFP_ID;AttrName,FieldName:string;Memo:TMemo);
    procedure AttrNameValidate(AItems:TStrings);
    procedure FieldNameValidate(AAttrName:string;AItems:TStrings);

  //EVENTS.INC 事件与禁用事件
  private
    FIsChanged:boolean;
    FUpdatingLevel:integer;//为0时触发onChange，每次BeginUpdate+1，EndUpdate-1

    FOnNew,FOnNewDone,FOnOpen,FOnOpenDone,FOnSave,FOnSaveDone,
    FOnSaveAs,FOnSaveAsDone,FOnClose,FOnCloseDone:TNotifyEvent;

    //FOnTableValidateDone:TNotifyEvent;
    FOnMainGridRebuilding,FOnMainGridRebuildDone:TNotifyEvent;

    FOnFirstEdit,FOnChange,FOnDataChange,FOnFieldChange,FOnRecordChange,
    FOnClassChange,FOnUsersChange,FOnFormatListChange:TNotifyEvent;

  protected
    function GetIsUpdating:boolean;

  public
    procedure BeginUpdate;
    procedure EndUpdate;

  public
    property IsChanged:boolean read FIsChanged;
    property IsUpdating:boolean read GetIsUpdating;

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

  //PACKED_FORMAT.INC 用于压缩与转换的单文件格式
  public
    procedure ZTFP_Importer(fullfilename:string);unimplemented;//重复性检验之类的问题比较麻烦
    procedure ZTFP_Exporter(fullfilename:string);//PID筛选、备份选项未定

  //未分类
  protected
    function GetPaperCount:integer;
    function GetBackupPaperCount:integer;
    function GetExternPaperCount:integer;
    function GetWeblnkPaperCount:integer;

  public
    property CountPaper:integer read GetPaperCount;
    property CountBackupPaper:integer read GetBackupPaperCount;
    property CountExternPaper:integer read GetExternPaperCount;
    property CountWeblnkPaper:integer read GetWeblnkPaperCount;

  private
    function NewProjectFile(p_title,p_user:string):boolean;inline;
    function OpenProjectFile:boolean;inline;
    function SaveProjectFile:boolean;inline;
    function CloseProjectFile:boolean;inline;

    function NewUserList:boolean;inline;
    function OpenUserList:boolean;inline;
    function SaveUserList:boolean;inline;
    function CloseUserList:boolean;inline;

    procedure GenPaperAttribute(Dbf:{TDbf}TDataSet);inline;
    procedure GenImageAttribute(Dbf:{TDbf}TDataSet);inline;
    procedure GenNoteAttribute(Dbf:{TDbf}TDataSet);inline;

    procedure GenAttrMetasAttribute(Dbf:{TDbf}TDataSet);inline;
    procedure GenAttrBasicAttribute(Dbf:{TDbf}TDataSet);inline;
    procedure GenAttrClassAttribute(Dbf:{TDbf}TDataSet);inline;
    procedure GenAttrNotesAttribute(Dbf:{TDbf}TDataSet);inline;
    procedure GenAttrDefaultAttribute(Dbf:{TDbf}TDataSet);inline;
    procedure GenAttrRelatAttribute(Dbf:{TDbf}TDataSet);inline;

  public //工程状态选项记录
    procedure LoadProjectOption(AAuf:TAuf);
    procedure SaveProjectOption(filename:string='');

    //Attrs
  private
    procedure LoadAttrs;//包含了原先的New
    procedure SaveAttrs;
    procedure CloseAttrs;
    procedure CheckAttrs;unimplemented;//用于存档版本检验，追加和修改字段

    //Klass
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
    procedure ReNewCreateTime(PID:RTFP_ID);
    procedure ReNewModifyTime(PID:RTFP_ID);
    procedure ReNewCheckTime(PID:RTFP_ID);
    procedure ReNewModifyTimeWithoutChange(PID:RTFP_ID);
    procedure ReNewCheckTimeWithoutChange(PID:RTFP_ID);

  public
    procedure GetPIDList(AList:TStrings);
    procedure GetPIDList_DS(AList:TStrings);
    procedure GetSimilarPIDList(AList:TStrings;ASimChkOption:TSimChkOptions;PB:TProgressBar=nil);
    function GetPaperAttrs(AFieldName:string;PID:RTFP_ID):string;deprecated;
    procedure GetPaperKlass(PID:RTFP_ID;str:TStrings);

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
    class function DeleteDir(filename:string;force_delete:boolean=false):boolean;inline;
    class function OpenDir(filename:string):boolean;inline;
    class function OpenFile(filename:string;exefile:string=''):boolean;inline;
    class function OpenLink(linkage:string):boolean;inline;

  {构造与析构}
  public
    constructor Create(AOwner:TComponent;ADatasetType:TRTFP_DataSetType=dstDBF);virtual;
    destructor Destroy;override;

  end;


procedure AufScriptFuncDefineRTFP(Auf:TAuf);


implementation
uses RTFP_main, rtfp_field_convert, Zipper;
var rtfp_reg:TRegExpr;

{$I aufunc.inc}
{$I events.inc}
{$I control_interface.inc}

{$I access_base.inc}
{$I access_attrs.inc}
{$I access_field.inc}
{$I access_klass.inc}
{$I access_data.inc}

{$I tags.inc}
{$I paper.inc}
{$I image.inc}
{$I notes.inc}

{$I packed_format.inc}

{$I cite_tool.inc}
{$I formatedit_component.inc}
{$I formatedit_list.inc}

{$I update.inc}



constructor TRTFP.Create(AOwner:TComponent;ADatasetType:TRTFP_DataSetType=dstDBF);
begin
  inherited Create(AOwner);
  FDataSetType:=ADatasetType;

  FPaperDS:=TMemDataset.Create(Self);
  PaperDSFieldDefs:=TList.Create;
  FFormatEditComponentList:=TList.Create;

  //ProjectFileValue:=TValueListEditor.Create(nil);
  //ProjectFileValue.Parent:=AOwner;
  //ProjectFileValue.Hide;
  FProjectTags:=TTags.Create;

  case FDataSetType of
    dstDBF:begin
      FPaperDB:=TDbf.Create(Self);
      FImageDB:=TDbf.Create(Self);
      FNotesDB:=TDbf.Create(Self);
    end;
    dstBUF:begin
      FPaperDB:=TBufDataset.Create(Self);
      FImageDB:=TBufDataset.Create(Self);
      FNotesDB:=TBufDataset.Create(Self);
    end;
    else raise Exception.Create('无效DataSetType。');
  end;

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

procedure TRTFP.LoadAttrs;
var tmpAttrs:TAttrsGroup;
begin
  //BeginUpdate;
  case FDataSetType of
    dstDBF:FFieldList.LoadFromPath('attr\','dbf');
    dstBUF:FFieldList.LoadFromPath('attr\','buf');
    else raise Exception.Create('无效DataSetType。');
  end;

  for tmpAttrs in FFieldList do
    begin
      if not OpenDbf(tmpAttrs.FullPath,tmpAttrs.Dbf) then
        NewDbf(tmpAttrs.FullPath,tmpAttrs.Dbf);
      case FDataSetType of
        dstDBF:TDbf(tmpAttrs.Dbf).Exclusive:=true;
      end;
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
      if not tmpAttrs.Modified then begin
        //ShowMsgOK('无需保存提示（临时）',tmpAttrs.Name);
        continue;
      end;
      while not SaveDbf(tmpAttrs.FullPath,tmpAttrs.Dbf,RunPerformance.Backup_SaveXml) do
        case ShowMsgRetryIgnore('错误','属性组保存失败！') of
          'Retry':;
          'Ignore':break;
        end;
      tmpAttrs.Modified:=false;
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
end;

procedure TRTFP.LoadKlass;
var tmpKlass:TKlass;
begin
  //BeginUpdate;
  case FDataSetType of
    dstDBF:FKlassList.LoadFromPath('class\','dbf');
    dstBUF:FKlassList.LoadFromPath('class\','buf');
    else raise Exception.Create('无效DataSetType。');
  end;
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
      while not SaveDbf(tmpKlass.FullPath,tmpKlass.Dbf,RunPerformance.Backup_SaveXml) do
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

procedure TRTFP.GenPaperAttribute(Dbf:{TDbf}TDataSet);
begin
  Dbf.FieldDefs.Add(_Col_OID_, ftAutoInc, 0{, True});
  Dbf.FieldDefs.Add(_Col_PID_, ftString, 8{, True});

  Dbf.FieldDefs.Add(_Col_Paper_Is_Backup_, ftBoolean, 0{, True});//是否为文档记录   否0 是1

  //文件位置
  Dbf.FieldDefs.Add(_Col_Paper_Folder_, ftString, 8{, True});
  Dbf.FieldDefs.Add(_Col_Paper_FileName_, ftString, 240{, True});
  //重复检验
  Dbf.FieldDefs.Add(_Col_Paper_FileSize_, ftLargeInt, 8{, True});
  Dbf.FieldDefs.Add(_Col_Paper_FileHash_, ftString, 255{, True});

end;

procedure TRTFP.GenImageAttribute(Dbf:{TDbf}TDataSet);
begin
  Dbf.FieldDefs.Add(_Col_OID_, ftAutoInc, 0{, True});
  Dbf.FieldDefs.Add(_Col_IID_, ftString, 8{, True});
  //重复检验
  Dbf.FieldDefs.Add(_Col_Image_FileSize_, ftLargeInt, 8{, True});
  Dbf.FieldDefs.Add(_Col_Image_FileHash_, ftString, 255{, True});
  //文件位置
  Dbf.FieldDefs.Add(_Col_Image_Folder_, ftString, 8{, True});
  Dbf.FieldDefs.Add(_Col_Image_FileName_, ftString, 240{, True});
  //基础信息
  Dbf.FieldDefs.Add(_Col_Image_Width_, ftInteger, 4{, True});
  Dbf.FieldDefs.Add(_Col_Image_Height_, ftInteger, 4{, True});

end;

procedure TRTFP.GenNoteAttribute(Dbf:{TDbf}TDataSet);
begin
  Dbf.FieldDefs.Add(_Col_OID_, ftAutoInc, 0{, True});
  Dbf.FieldDefs.Add(_Col_NID_, ftString, 8{, True});
  //文件位置
  Dbf.FieldDefs.Add(_Col_Note_Folder_, ftString, 8{, True});
  Dbf.FieldDefs.Add(_Col_Note_FileName_, ftString, 240{, True});

end;

procedure TRTFP.GenAttrBasicAttribute(Dbf:{TDbf}TDataSet);
begin
  Dbf.FieldDefs.Add(_Col_OID_, ftAutoInc, 0{, True});
  Dbf.FieldDefs.Add(_Col_PID_, ftString, 8{, True});

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
procedure TRTFP.GenAttrMetasAttribute(Dbf:{TDbf}TDataSet);
begin
  Dbf.FieldDefs.Add(_Col_OID_, ftAutoInc, 0{, True});
  Dbf.FieldDefs.Add(_Col_PID_, ftString, 8{, True});
  //pdf默认meta
  Dbf.FieldDefs.Add(_Col_metas_Title_, ftMemo, 0{, True});
  Dbf.FieldDefs.Add(_Col_metas_Authors_, ftMemo, 0{, True});
  Dbf.FieldDefs.Add(_Col_metas_Subject_, ftMemo, 8{, True});
  Dbf.FieldDefs.Add(_Col_metas_KeyWord_, ftMemo, 8{, True});
  Dbf.FieldDefs.Add(_Col_metas_Creator_, ftMemo, 8{, True});
  Dbf.FieldDefs.Add(_Col_metas_Produce_, ftMemo, 8{, True});
  Dbf.FieldDefs.Add(_Col_metas_CreDate_, ftString, 64{, True});
  Dbf.FieldDefs.Add(_Col_metas_ModDate_, ftString, 64{, True});
  Dbf.FieldDefs.Add(_Col_metas_Trapped_, ftMemo, 0{, True});

end;

procedure TRTFP.GenAttrClassAttribute(Dbf:{TDbf}TDataSet);
begin
  Dbf.FieldDefs.Add(_Col_OID_, ftAutoInc, 0{, True});
  Dbf.FieldDefs.Add(_Col_PID_, ftString, 8{, True});

  Dbf.FieldDefs.Add(_Col_class_Is_Read_, {ftSmallint}ftBoolean, 0{, True});//是否已读         否0 是1

  Dbf.FieldDefs.Add(_Col_class_DefaultCl_, ftMemo, 8{, True});//默认类型（半角逗号隔开）

end;

procedure TRTFP.GenAttrNotesAttribute(Dbf:{TDbf}TDataSet);
begin
  Dbf.FieldDefs.Add(_Col_OID_, ftAutoInc, 0{, True});
  Dbf.FieldDefs.Add(_Col_PID_, ftString, 8{, True});

  Dbf.FieldDefs.Add(_Col_notes_Usage_, ftString, 50{, True});//主标记（例如综述、例证、消遣、反例）
  Dbf.FieldDefs.Add(_Col_notes_Rank_, ftSmallint, 0{, True});//评级1-100分，0表示未赋值
  Dbf.FieldDefs.Add(_Col_notes_Comment_, ftMemo, 0{, True});//入库评价
  Dbf.FieldDefs.Add(_Col_notes_User_, ftSmallint, 0{, True});//入库用户（UserID）
  Dbf.FieldDefs.Add(_Col_notes_CreateTime_, ftDateTime, 0{, True});//入库日期
  Dbf.FieldDefs.Add(_Col_notes_ModifyTime_, ftDateTime, 0{, True});//修改日期
  Dbf.FieldDefs.Add(_Col_notes_CheckTime_, ftDateTime, 0{, True});//查看日期
  Dbf.FieldDefs.Add(_Col_notes_FurtherCmt_, ftMemo, 8{, True});//更多评价（结构化文本格式，例如rubyHash）
  Dbf.FieldDefs.Add(_Col_notes_Format_, ftSmallint, 0{, True});//预览显示格式（FormatID）

end;

procedure TRTFP.GenAttrRelatAttribute(Dbf:{TDbf}TDataSet);
begin
  Dbf.FieldDefs.Add(_Col_OID_, ftAutoInc, 0{, True});
  Dbf.FieldDefs.Add(_Col_PID_, ftString, 8{, True});

  Dbf.FieldDefs.Add(_Col_relat_Parent_, ftMemo, 8{, True});//父节点
  Dbf.FieldDefs.Add(_Col_relat_Children_, ftMemo, 8{, True});//子节点

  Dbf.FieldDefs.Add(_Col_relat_Cited_, ftMemo, 8{, True});//引证文献
  Dbf.FieldDefs.Add(_Col_relat_References_, ftMemo, 8{, True});//参考文献

end;


procedure TRTFP.GenAttrDefaultAttribute(Dbf:{TDbf}TDataSet);
begin
  Dbf.FieldDefs.Add(_Col_OID_, ftAutoInc, 0{, True});
  Dbf.FieldDefs.Add(_Col_PID_, ftString, 8{, True});

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
    stmp:string;
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
            str.Add('option.attrs.set "'+AG.Name+'","'+AF.FieldName+'","display_name",'+AF.FFieldDisplayOption.display_name);
            if AF.IsCombo then for stmp in AF.ComboItem do
              str.Add('option.attrs.set "'+AG.Name+'","'+AF.FieldName+'","add_combo",'+stmp);
          end;
      end;
    if filename='' then filename:='option.lay.auf';
    str.SaveToFile(GetCurrentPathFull+filename);
  finally
    str.Free;
  end;
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
var has_dbf,has_buf:boolean;
    function change_datasetType:boolean;
    begin
      result:=false;
      if has_dbf then begin
        FDataSetType:=dstDBF;
        FPaperDB.Free;
        FImageDB.Free;
        FNotesDB.Free;
        FPaperDB:=TDbf.Create(Self);
        FImageDB:=TDbf.Create(Self);
        FNotesDB:=TDbf.Create(Self);
      end else if has_buf then begin
        FDataSetType:=dstBUF;
        FPaperDB.Free;
        FImageDB.Free;
        FNotesDB.Free;
        FPaperDB:=TBufDataset.Create(Self);
        FImageDB:=TBufDataset.Create(Self);
        FNotesDB:=TBufDataset.Create(Self);
      end else exit;
      result:=true;
    end;

begin
  if FOnOpen <> nil then FOnOpen(Self);

  Self.SetPaths(WinCPToUTF8(filename));

  has_dbf:=FileExists(GetCurrentPathFull+'paper.dbf');
  has_buf:=FileExists(GetCurrentPathFull+'paper.buf');

  if (FDataSetType=dstDBF) and (not has_dbf)
  or (FDataSetType=dstBUF) and (not has_buf)
  then begin
    if not change_datasetType then begin
      ShowMsgOK('打开工程','找不到合适的文件格式，无法打开工程。');
      exit
    end;
  end;

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
  SaveDbf('paper',Self.FPaperDB,RunPerformance.Backup_SaveXml);
  SaveDbf('image',Self.FImageDB,RunPerformance.Backup_SaveXml);
  SaveDbf('note',Self.FNotesDB,RunPerformance.Backup_SaveXml);

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
            if scoFileName in ASimChkOption then with (FPaperDB) do
              begin
                if not LocatePID(FPaperDB,id1) then continue;
                lst1.Add(FieldByName(_Col_Paper_FileName_).AsString);
                if not LocatePID(FPaperDB,id2) then continue;
                lst2.Add(FieldByName(_Col_Paper_FileName_).AsString);
              end;
            if scoFileHash in ASimChkOption then with (FPaperDB) do
              begin
                if not LocatePID(FPaperDB,id1) then continue;
                lst1.Add(FieldByName(_Col_Paper_FileHash_).AsString);
                if not LocatePID(FPaperDB,id2) then continue;
                lst2.Add(FieldByName(_Col_Paper_FileHash_).AsString);
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
      if LocatePID(FPaperDB,PID) then result:=FieldByName(AFieldName).AsString else result:='';
    end;
end;

procedure TRTFP.GetPaperKlass(PID:RTFP_ID;str:TStrings);
var tmpDbf:TDataset;
begin
  tmpDbf:=FieldList.FindItemByName(_Attrs_Class_).Dbf;
  with tmpDbf do
    begin
      if not Active then Open;
      if not LocatePID(tmpDbf,PID) then exit;
      str.Text:=FieldByName(_Col_class_DefaultCl_).AsString;
    end;
end;

procedure TRTFP.ReNewCreateTime(PID:RTFP_ID);
begin
  EditFieldAsDateTime(_Col_notes_CreateTime_,_Attrs_Notes_,PID,Now,[],false);
end;

procedure TRTFP.ReNewModifyTime(PID:RTFP_ID);
begin
  EditFieldAsDateTime(_Col_notes_ModifyTime_,_Attrs_Notes_,PID,Now,[],false);
end;

procedure TRTFP.ReNewCheckTime(PID:RTFP_ID);
begin
  EditFieldAsDateTime(_Col_notes_CheckTime_,_Attrs_Notes_,PID,Now,[],false);
end;

procedure TRTFP.ReNewModifyTimeWithoutChange(PID:RTFP_ID);
begin
  BeginUpdate;
  EditFieldAsDateTime(_Col_notes_ModifyTime_,_Attrs_Notes_,PID,Now,[],false);
  EndUpdate;
end;

procedure TRTFP.ReNewCheckTimeWithoutChange(PID:RTFP_ID);
begin
  BeginUpdate;
  EditFieldAsDateTime(_Col_notes_CheckTime_,_Attrs_Notes_,PID,Now,[],false);
  EndUpdate;
end;


{
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
}
//这部分原本用来干啥的？

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

function TRTFP.GetCurrentPathFull:string;
begin
  result:=FFilePath+FRootFolder+'\';
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

class function TRTFP.DeleteDir(filename:string;force_delete:boolean=false):boolean;
var filelist:TStringList;
    stmp:string;
begin
  result:=false;
  filelist:=TStringList.Create;
  try
    FindAllFiles(filelist,filename,'',true,faAnyFile);
    for stmp in filelist do FileDelete(stmp);
  finally
    filelist.Free;
  end;
  result:=RemoveDir(filename);
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

initialization

  rtfp_reg:=TRegExpr.Create;

finalization
  rtfp_reg.Free;

end.

