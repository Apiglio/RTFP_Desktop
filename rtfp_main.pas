unit RTFP_main;

{$mode objfpc}{$H+}



interface

uses
  Classes, SysUtils, db, dbf, memds, FileUtil,
  Forms, Controls, Graphics, Dialogs, ComCtrls, Menus, ExtCtrls, DBGrids, Grids,
  ValEdit, StdCtrls, DbCtrls, LazUTF8, SynEdit, Clipbrd, LCLType, Buttons,
  Regexpr, SynHighlighterAuf,

  Apiglio_Useful, AufScript_Frame, ListCheck,

  RTFP_definition, rtfp_constants, rtfp_type, sync_timer, source_dialog, Types;

const
  C_VERSION_NUMBER  = '0.4.2-alpha.2';
  C_SOFTWARE_NAME   = 'RTFP Desktop';
  C_SOFTWARE_AUTHOR = 'Apiglio';


type

  { TWaitForm }
  TWaitForm = class(TForm)
  private
    FEnabled:boolean;
  public
    property Enabled:boolean read FEnabled write FEnabled;
  end;


  { TFormDesktop }

  TFormDesktop = class(TForm)
    AListView_Attrs: TListCheck;
    AListView_Klass: TListCheck;
    Button_ClearKlassFilter: TButton;
    Button_MainSorter: TButton;
    Button_FormatEditPostAndNext: TButton;
    Button_FormatEditLoad: TButton;
    Button_FormatEditPostAndPrev: TButton;
    Button_FormatEditSave: TButton;
    Button_help: TButton;
    Button_FormatEdit_Ren: TButton;
    Button_FormatEdit_Del: TButton;
    Button_FormatEdit_Add: TButton;
    Button_FieldType: TButton;
    Button_AddAttrs: TButton;
    Button_AddField: TButton;
    Button_AddKlass: TButton;
    CheckBox_MainSorterAuto: TCheckBox;
    Edit_DBGridMain_Sorter: TEdit;
    Label_MainSorter: TLabel;
    Memo_Log: TMemo;
    MenuItem_Edit_NewPaper_Files: TMenuItem;
    MenuItem_ClassMgr_Danger_DeletePapers: TMenuItem;
    MenuItem_ClassMgr_div02: TMenuItem;
    MenuItem_ClassMgr_Danger: TMenuItem;
    MenuItem_Edit_NewPaper_Void: TMenuItem;
    MenuItem_Edit_NewPaper_WebLnk: TMenuItem;
    MenuItem_Edit_NewPaper_Refs: TMenuItem;
    MenuItem_Edit_NewPaper: TMenuItem;
    MenuItem_DBGC_Export_set: TMenuItem;
    MenuItem_DBGC_Export_array: TMenuItem;
    MenuItem_DBGC_Export_lines: TMenuItem;
    MenuItem_DBGC_Export: TMenuItem;
    MenuItem_ClassMgr_AddSub: TMenuItem;
    MenuItem_DBGC_CR: TMenuItem;
    MenuItem_DBGE_json: TMenuItem;
    MenuItem_FieldMgr_Copy: TMenuItem;
    MenuItem_PastePaper: TMenuItem;
    MenuItem_CopyPaper: TMenuItem;
    MenuItem_DBGE_python_dict: TMenuItem;
    MenuItem_DBGE_ruby_hash: TMenuItem;
    MenuItem_DBGE_tsv: TMenuItem;
    MenuItem_DBGE_csv: TMenuItem;
    MenuItem_DBGC_FieldOpt: TMenuItem;
    MenuItem_Edit_FieldComboBuild: TMenuItem;
    MenuItem_Edit_NewField: TMenuItem;
    MenuItem_DBGC_Calc: TMenuItem;
    PopupMenu_MainDBGrid_Export: TPopupMenu;
    RadioButton_KlassAND: TRadioButton;
    CheckBox_KlassNot: TCheckBox;
    RadioButton_KlassOR: TRadioButton;
    CheckBox_MainFilterAuto: TCheckBox;
    Combo_FieldType: TComboBox;
    ComboBox_FormatEdit: TComboBox;
    Button_FormatEditPost: TButton;
    Button_FormatEditRecover: TButton;
    Button_MainFilter: TButton;
    Button_temp: TButton;
    Combo_AddAttrs: TComboBox;
    Edit_AddField: TEdit;
    Edit_AddKlass: TEdit;
    DataSource_Main: TDataSource;
    DBGrid_Main: TDBGrid;
    Edit_DBGridMain_Filter: TEdit;
    Frame_AufScript1: TFrame_AufScript;
    Image_PDF_View: TImage;
    Label_FieldType: TLabel;
    Label_AddAttrs: TLabel;
    Label_AddField: TLabel;
    Label_AddKlass: TLabel;
    Label_MainFilter: TLabel;
    ListBox_FormatEditMgr: TListBox;
    MainMenu: TMainMenu;
    MenuItem_field_div01: TMenuItem;
    MenuItem_field_RebuildBlob: TMenuItem;
    MenuItem_FieldMgr_div01: TMenuItem;
    MenuItem_EditSource: TMenuItem;
    MenuItem_EditKlass: TMenuItem;
    MenuItem_EditReferences: TMenuItem;
    MenuItem_Edit: TMenuItem;
    MenuItem_NewPaper: TMenuItem;
    MenuItem_Edit_div01: TMenuItem;
    MenuItem_Node: TMenuItem;
    MenuItem_CB_RefNum_InOrder: TMenuItem;
    MenuItem_CB_RefNum_AurYear: TMenuItem;
    MenuItem_CB_RefNumFormat: TMenuItem;
    MenuItem_DBGC_div03: TMenuItem;
    MenuItem_DBGC_DisplayOpt: TMenuItem;
    MenuItem_FieldMgr_DisplayOption: TMenuItem;
    MenuItem_project_profile: TMenuItem;
    MenuItem_klass_SourceClass: TMenuItem;
    MenuItem_DBGC_div02: TMenuItem;
    MenuItem_DBGC_Seek: TMenuItem;
    MenuItem_RepeatedChecker: TMenuItem;
    MenuItem_ExportTool: TMenuItem;
    MenuItem_Tool_div01: TMenuItem;
    MenuItem_Tool_ProjectDir: TMenuItem;
    MenuItem_DBGC_Title: TMenuItem;
    MenuItem_DBGC_div01: TMenuItem;
    MenuItem_DBGC_AS: TMenuItem;
    MenuItem_DBGC_DS: TMenuItem;
    MenuItem_CB_Cite_MLA: TMenuItem;
    MenuItem_CB_Cite_APA: TMenuItem;
    MenuItem_CB_Cite_GB7714: TMenuItem;
    MenuItem_CB_CiteFormat: TMenuItem;
    MenuItem_CB_Ref_RIS: TMenuItem;
    MenuItem_CB_Ref_EStudy: TMenuItem;
    MenuItem_CB_Ref_EndNote: TMenuItem;
    MenuItem_CB_RefFormat: TMenuItem;
    MenuItem_CB_Title: TMenuItem;
    MenuItem_CB_Filenamefull: TMenuItem;
    MenuItem_CB_PID: TMenuItem;
    MenuItem_ClipBoards: TMenuItem;
    MenuItem_FieldMgr_Del: TMenuItem;
    MenuItem_FieldMgr_Edit: TMenuItem;
    MenuItem_option_div01: TMenuItem;
    MenuItem_klass_div01: TMenuItem;
    MenuItem_ClassMgr_UnCheckAll: TMenuItem;
    MenuItem_ClassMgr_CheckAll: TMenuItem;
    MenuItem_ClassMgr_div01: TMenuItem;
    MenuItem_ClassMgr_CDir: TMenuItem;
    MenuItem_ClassMgr_Del: TMenuItem;
    MenuItem_ClassMgr_Ren: TMenuItem;
    MenuItem_klass_check: TMenuItem;
    MenuItem_klass_DelKlass: TMenuItem;
    MenuItem_klass_AddKlass: TMenuItem;
    MenuItem_KlassMenu: TMenuItem;
    MenuItem_option_appearance: TMenuItem;
    MenuItem_AdvOpen_PDF: TMenuItem;
    MenuItem_AdvOpen_CAJ: TMenuItem;
    MenuItem_AdvOpen_Dir: TMenuItem;
    MenuItem_AdvOpen_Link: TMenuItem;
    MenuItem_AdvOpen: TMenuItem;
    MenuItem_ClassTool: TMenuItem;
    MenuItem_DeletePaper: TMenuItem;
    MenuItem_pop_div03: TMenuItem;
    MenuItem_Tree_Into: TMenuItem;
    MenuItem_Tree_Back: TMenuItem;
    MenuItem_pop_div02: TMenuItem;
    MenuItem_Tree: TMenuItem;
    MenuItem_project_div02: TMenuItem;
    MenuItem_project_div03: TMenuItem;
    MenuItem_project_div01: TMenuItem;
    MenuItem_Mark_IsRead_Yes: TMenuItem;
    MenuItem_Mark_IsRead_No: TMenuItem;
    MenuItem_Mark: TMenuItem;
    MenuItem_pop_div01: TMenuItem;
    MenuItem_OpenDefault: TMenuItem;
    MenuItem_project_recent: TMenuItem;
    MenuItem_ImportFromOther: TMenuItem;
    MenuItem_ExportToOther: TMenuItem;
    MenuItem_CiteTool: TMenuItem;
    MenuItem_project_close: TMenuItem;
    MenuItem_project_check: TMenuItem;
    MenuItem_project_div04: TMenuItem;
    MenuItem_project_saveas: TMenuItem;
    MenuItem_project_save: TMenuItem;
    MenuItem_option_help: TMenuItem;
    MenuItem_option_about: TMenuItem;
    MenuItem_option_setting: TMenuItem;
    MenuItem_project_unzip: TMenuItem;
    MenuItem_project_zip: TMenuItem;
    MenuItem_project_new: TMenuItem;
    MenuItem_option: TMenuItem;
    MenuItem_project: TMenuItem;
    MenuItem_Tool: TMenuItem;
    MenuItem_project_open: TMenuItem;
    OpenDialog_Project: TOpenDialog;
    PageControl_Filter: TPageControl;
    PageControl_Node: TPageControl;
    PageControl_Project: TPageControl;
    Panel_DBGridMain: TPanel;
    PopupMenu_MainDBGrid_Column: TPopupMenu;
    PopupMenu_FieldManager: TPopupMenu;
    PopupMenu_ClassManager: TPopupMenu;
    ScrollBox_Node_FormatEdit: TScrollBox;
    PopupMenu_MainDBGrid: TPopupMenu;
    SaveDialog_project: TSaveDialog;
    Splitter_LeftH: TSplitter;
    Splitter_PropertiesV: TSplitter;
    Splitter_RightH: TSplitter;
    Splitter_MainV: TSplitter;
    StatusBar: TStatusBar;
    StringGrid_FormatEditLayout: TStringGrid;
    SynEdit_FEMgr: TSynEdit;
    TabSheet_Log: TTabSheet;
    TabSheet_Project_FormatEditMgr: TTabSheet;
    TabSheet_Node_FormatEdit: TTabSheet;
    TabSheet_Filter_Klass: TTabSheet;
    TabSheet_Filter_Field: TTabSheet;
    TabSheet_Project_Properties: TTabSheet;
    TabSheet_Node_PDF: TTabSheet;
    TabSheet_Project_AufScript: TTabSheet;
    TabSheet_Project_DataGrid: TTabSheet;
    PropertiesValueListEditor: TValueListEditor;
    procedure AListView_AttrsItemChecked(Sender: TObject; Item: TListCheckNode);
    procedure AListView_KlassDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure AListView_KlassDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure AListView_KlassItemChecked(Sender: TObject; Item: TListCheckNode);
    procedure Button_AddAttrsClick(Sender: TObject);
    procedure Button_AddFieldClick(Sender: TObject);
    procedure Button_AddKlassClick(Sender: TObject);
    procedure Button_ClearKlassFilterClick(Sender: TObject);
    procedure Button_FieldTypeClick(Sender: TObject);
    procedure Button_FormatEditLoadClick(Sender: TObject);
    procedure Button_FormatEditPostAndNextClick(Sender: TObject);
    procedure Button_FormatEditPostAndPrevClick(Sender: TObject);
    procedure Button_FormatEditPostClick(Sender: TObject);
    procedure Button_FormatEditRecoverClick(Sender: TObject);
    procedure Button_FormatEditSaveClick(Sender: TObject);
    procedure Button_FormatEdit_AddClick(Sender: TObject);
    procedure Button_FormatEdit_DelClick(Sender: TObject);
    procedure Button_FormatEdit_RenClick(Sender: TObject);
    procedure Button_helpClick(Sender: TObject);
    procedure Button_MainFilterClick(Sender: TObject);
    procedure Button_MainSorterClick(Sender: TObject);

    procedure Button_NodeViewRecoverClick(Sender: TObject);
    procedure CheckBox_KlassNotClick(Sender: TObject);
    procedure CheckBox_MainSorterAutoClick(Sender: TObject);
    procedure Edit_DBGridMain_SorterChange(Sender: TObject);
    procedure Edit_DBGridMain_SorterKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure MenuItem_ClassMgr_AddSubClick(Sender: TObject);
    procedure MenuItem_ClassMgr_Danger_DeletePapersClick(Sender: TObject);
    procedure MenuItem_CopyPaperClick(Sender: TObject);
    procedure MenuItem_DBGC_ASClick(Sender: TObject);
    procedure MenuItem_DBGC_CalcClick(Sender: TObject);
    procedure MenuItem_DBGC_CRClick(Sender: TObject);
    procedure MenuItem_DBGC_DSClick(Sender: TObject);
    procedure MenuItem_DBGC_Export_arrayClick(Sender: TObject);
    procedure MenuItem_DBGC_Export_linesClick(Sender: TObject);
    procedure MenuItem_DBGC_Export_setClick(Sender: TObject);
    procedure MenuItem_DBGC_FieldOptClick(Sender: TObject);
    procedure MenuItem_DBGE_csvClick(Sender: TObject);
    procedure MenuItem_DBGE_jsonClick(Sender: TObject);
    procedure MenuItem_DBGE_python_dictClick(Sender: TObject);
    procedure MenuItem_DBGE_ruby_hashClick(Sender: TObject);
    procedure MenuItem_DBGE_tsvClick(Sender: TObject);
    procedure MenuItem_Edit_NewPaper_FilesClick(Sender: TObject);
    procedure MenuItem_Edit_NewPaper_RefsClick(Sender: TObject);
    procedure MenuItem_Edit_NewPaper_VoidClick(Sender: TObject);
    procedure MenuItem_Edit_NewPaper_WebLnkClick(Sender: TObject);
    procedure MenuItem_FieldMgr_CopyClick(Sender: TObject);
    procedure MenuItem_PastePaperClick(Sender: TObject);
    procedure MenuItem_project_unzipClick(Sender: TObject);
    procedure MenuItem_project_zipClick(Sender: TObject);
    procedure PageControl_FilterResize(Sender: TObject);
    procedure RadioButton_KlassANDClick(Sender: TObject);
    procedure RadioButton_KlassORClick(Sender: TObject);
    procedure CheckBox_MainFilterAutoClick(Sender: TObject);
    procedure ComboBox_FormatEditChange(Sender: TObject);
    procedure DataSource_MainUpdateData(Sender: TObject);
    procedure DBGrid_MainCellClick(Column: TColumn);
    procedure DBGrid_MainColumnSized(Sender: TObject);
    procedure DBGrid_MainDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure DBGrid_MainDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure DBGrid_MainDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure DBGrid_MainKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBGrid_MainMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DBGrid_MainMouseEnter(Sender: TObject);
    procedure DBGrid_MainMouseLeave(Sender: TObject);
    procedure DBGrid_MainMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DBGrid_MainMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure Edit_DBGridMain_FilterChange(Sender: TObject);
    procedure Edit_DBGridMain_FilterKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure MenuItem_AdvOpen_CAJClick(Sender: TObject);
    procedure MenuItem_AdvOpen_DirClick(Sender: TObject);
    procedure MenuItem_AdvOpen_LinkClick(Sender: TObject);
    procedure MenuItem_AdvOpen_PDFClick(Sender: TObject);
    procedure MenuItem_Attr_AddAttrsClick(Sender: TObject);
    procedure MenuItem_EditReferencesClick(Sender: TObject);
    procedure MenuItem_CB_Cite_APAClick(Sender: TObject);
    procedure MenuItem_CB_Cite_GB7714Click(Sender: TObject);
    procedure MenuItem_CB_Cite_MLAClick(Sender: TObject);
    procedure MenuItem_CB_FilenamefullClick(Sender: TObject);
    procedure MenuItem_CB_PIDClick(Sender: TObject);
    procedure MenuItem_CB_RefNum_AurYearClick(Sender: TObject);
    procedure MenuItem_CB_RefNum_InOrderClick(Sender: TObject);
    procedure MenuItem_CB_Ref_EndNoteClick(Sender: TObject);
    procedure MenuItem_CB_Ref_EStudyClick(Sender: TObject);
    procedure MenuItem_CB_Ref_RISClick(Sender: TObject);
    procedure MenuItem_CB_TitleClick(Sender: TObject);
    procedure MenuItem_CiteToolClick(Sender: TObject);
    procedure MenuItem_ClassMgr_CDirClick(Sender: TObject);
    procedure MenuItem_ClassMgr_CheckAllClick(Sender: TObject);
    procedure MenuItem_ClassMgr_DelClick(Sender: TObject);
    procedure MenuItem_ClassMgr_RenClick(Sender: TObject);
    procedure MenuItem_ClassMgr_UnCheckAllClick(Sender: TObject);
    procedure MenuItem_ClassToolClick(Sender: TObject);
    procedure MenuItem_DBGC_DisplayOptClick(Sender: TObject);
    procedure MenuItem_DBGC_SeekClick(Sender: TObject);
    procedure MenuItem_DBGC_TitleClick(Sender: TObject);
    procedure MenuItem_DeletePaperClick(Sender: TObject);
    procedure MenuItem_EditSourceClick(Sender: TObject);
    procedure MenuItem_ExportToolClick(Sender: TObject);
    procedure MenuItem_FieldMgr_DelClick(Sender: TObject);
    procedure MenuItem_FieldMgr_EditClick(Sender: TObject);
    procedure MenuItem_FieldMgr_DisplayOptionClick(Sender: TObject);
    procedure MenuItem_EditKlassClick(Sender: TObject);
    procedure MenuItem_field_RebuildBlobClick(Sender: TObject);
    procedure MenuItem_klass_AddKlassClick(Sender: TObject);
    procedure MenuItem_klass_checkClick(Sender: TObject);
    procedure MenuItem_klass_DelKlassClick(Sender: TObject);
    procedure MenuItem_klass_SourceClassClick(Sender: TObject);
    procedure MenuItem_Mark_IsRead_NoClick(Sender: TObject);
    procedure MenuItem_Mark_IsRead_YesClick(Sender: TObject);
    procedure MenuItem_NewPaperClick(Sender: TObject);
    procedure MenuItem_OpenAsCajClick(Sender: TObject);
    procedure MenuItem_OpenAsPdfClick(Sender: TObject);
    procedure MenuItem_OpenDefaultClick(Sender: TObject);
    procedure MenuItem_OpenDirClick(Sender: TObject);
    procedure MenuItem_OpenLinkClick(Sender: TObject);
    procedure MenuItem_option_aboutClick(Sender: TObject);
    procedure MenuItem_option_appearanceClick(Sender: TObject);
    procedure MenuItem_option_settingClick(Sender: TObject);
    procedure MenuItem_project_closeClick(Sender: TObject);
    procedure MenuItem_project_newClick(Sender: TObject);
    procedure MenuItem_project_openClick(Sender: TObject);
    procedure MenuItem_project_profileClick(Sender: TObject);
    procedure MenuItem_project_saveasClick(Sender: TObject);
    procedure MenuItem_project_saveClick(Sender: TObject);
    procedure MenuItem_RepeatedCheckerClick(Sender: TObject);
    procedure MenuItem_Tool_ProjectDirClick(Sender: TObject);
    procedure PageControl_NodeChange(Sender: TObject);
    procedure StringGrid_FormatEditLayoutMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SynEdit_FEMgrClick(Sender: TObject);
    procedure TabSheet_Project_AufScriptResize(Sender: TObject);
    procedure PropertiesValueListEditorEditingDone(Sender: TObject);

  private
    FWaitForm:TForm;
    FWaitLabel:TLabel;
    FShowWaitForm:boolean;
    FMainForm_ShiftState:TShiftState;
    FFormatEdit_Highlighter:TSynAufSyn;

    LastDBGridPos:TPoint;

    //记录不同控件之间的鼠标起落情况
    UIState:record
      DragButton:TMouseButton;
      DragShift:TShiftState;
    end;

  public
    SyncTimer:TRTFP_SyncTimer;
    property ShowWaitForm:boolean read FShowWaitForm write FShowWaitForm;

  private
    FLayoutMode:integer;
  protected
    procedure SetLayoutMode(AModeIndex:integer);
  public
    property LayoutMode:integer read FLayoutMode write SetLayoutMode;
  public
    OptionMap:record
      Backup_SaveXml:boolean;
      Fields_ImgFile:boolean;
      ForceSaveField:boolean;
      Shortcut_CtrlR:TMGSC_CR_Option;
      CopyMainGridWithDispName:boolean;  //在主表的信息复制中使用显示名
      CopyMainGridWithHeadLine:boolean;  //在主表的信息复制中增加表头行
      ExportImagePicStretch:TPicStretch; //导出图片报表的裁切选项
      ExportImageFontSize:integer;       //导出图片报表的字体大小
      ExportImageCellWidth:integer;      //导出图片报表的单元格宽
      ExportImageCellHeight:integer;     //导出图片报表的单元格高
      DisplayKlassListRecCount:boolean;  //在分类列表中显示节点数量
    end;//这些设置需要同步到RTFP对象中，打开工程时需要赋值，同时在软件打开时从注册表中读取，关闭是保存到注册表
    RunOption:record
      Filter_AutoRun:boolean;
    end;//这些设置不需要同步到RTFP对象中，也不记录到注册表中

  //private
  public
    function Selected_PID:RTFP_ID;//根据DBGrid_Main的选择返回PID
    function Select_PID(PID:RTFP_ID):Boolean;
    function Selected_FileName:string;//根据DBGrid_Main的选择返回文件名
    function Selected_Title:string;//根据DBGrid_Main的选择返回标题
    function Selected_Link:string;//根据DBGrid_Main的选择返回链接
    procedure ShowStatusHelper(str:string);

  public
    //RTFP类事件，Sender参数为TRTFP类
    procedure EventLink(AProject:TRTFP);//链接所有事件
    procedure OptionLink(AProject:TRTFP);//链接所有选项
    procedure MenuItemOpenProject(Sender:TObject);
    procedure LoadRecentProject;
    procedure SaveRecentProject;

    procedure Validate(AProject:TRTFP);//更新显示
    procedure ClassListValidate(AProject:TRTFP);//分类更新时的操作
    procedure FieldListValidate(AProject:TRTFP);//分类更新时的操作
    procedure MainGridRebuilding(Sender:TObject);
    procedure MainGridRebuildDone(Sender:TObject);
    procedure MainGridUpdateRec(AProject:TRTFP;PID:RTFP_ID);
    procedure FormatListValidate(AProject:TRTFP;rename:string='default.fmt');
    procedure FormatEditValidate(AProject:TRTFP;fe_new,fe_old:string);
    procedure ProjectTagChange(AProject:TRTFP;akey,avalue:string);

    procedure FirstEdit(AProject:TRTFP);//工程第一次编辑
    procedure Clear(AProject:TRTFP);//清空
    procedure Log(AProject:TRTFP;msg:string);//日志


    procedure ProjectOpenDone(AProject:TRTFP);//工程打开或新建
    procedure ProjectClose(AProject:TRTFP);//工程关闭之前
    procedure ProjectCloseDone(AProject:TRTFP);//工程关闭
    procedure ProjectSaveDone(AProject:TRTFP);//工程保存

    procedure DBGridColumnAdjusting(Sender:TObject);
    procedure DBGridColumnAllocating(Sender:TObject);

    //以下与下半部分的NodeView有关
    procedure ViewPdfValidate;
    //预览pdf
    procedure NodeViewValidate;
    //根据当前DBGrid_Main的选择状态更新NodeView显示

  public
    //能使用快捷键的命令
    function Action_NewPaper:boolean;
    function Action_NewPaper_WebLnk:boolean;
    function Action_ImportPapers:boolean;

  public
    procedure debugline(str:string);


  end;

  function ProjectInvalid:boolean;

var
  FormDesktop: TFormDesktop;
  CurrentRTFP:TRTFP;
  LocalPath:string;

implementation
uses form_new_project, form_cite_trans, form_classmanager, form_import,
     form_appearance, rtfp_field, rtfp_class, form_options, form_report_tool,
     form_repeated_checker, form_project_profile, form_field_display_option,
     form_formatedit_option, rtfp_dialog, form_field_change, form_calc_field,
     fpjson;

{$R *.lfm}

function ProjectInvalid:boolean;
begin
  if not assigned(CurrentRTFP) then result:=true
  else begin
    if not CurrentRTFP.IsOpen then result:=true
    else result:=false;
  end;
end;

{ TFormDesktop }

procedure TFormDesktop.debugline(str:string);
begin
  Frame_AufScript1.Auf.Script.writeln(str);
end;

procedure TFormDesktop.EventLink(AProject:TRTFP);//链接所有事件
begin
  with AProject do begin
    onOpenDone:=@ProjectOpenDone;
    onFirstEdit:=@FirstEdit;
    onSaveDone:=@ProjectSaveDone;
    onCloseDone:=@ProjectCloseDone;
    onClose:=@ProjectClose;
    onChange:=@Validate;
    onTagChange:=@ProjectTagChange;
    OnMainGridRebuilding:=@MainGridRebuilding;
    OnMainGridRebuildDone:=@MainGridRebuildDone;
    onClassIncludeChange:=@Self.ClassListValidate;
    onClassChange:=@Self.ClassListValidate;
    onFieldChange:=@Self.FieldListValidate;
    onFormatListChange:=@Self.FormatListValidate;
    onFormatEditChange:=@Self.FormatEditValidate;
    OnLogLine:=@Log;
    LogEnabled:=true;
  end;
end;

procedure TFormDesktop.OptionLink(AProject:TRTFP);
begin
  with AProject do begin
    with RunPerformance do begin
      Backup_SaveXml:=OptionMap.Backup_SaveXml;
      Fields_ImgFile:=OptionMap.Fields_ImgFile;
      Filter_AutoRun:=CheckBox_MainFilterAuto.Checked;
      Filter_Command:=Edit_DBGridMain_Filter.Caption;
      CopyMainGridWithDispName:=OptionMap.CopyMainGridWithDispName;
      CopyMainGridWithHeadLine:=OptionMap.CopyMainGridWithHeadLine;
      ExportImagePicStretch:=OptionMap.ExportImagePicStretch;
      ExportImageFontSize:=OptionMap.ExportImageFontSize;
      ExportImageCellWidth:=OptionMap.ExportImageCellWidth;
      ExportImageCellHeight:=OptionMap.ExportImageCellHeight;
      DisplayKlassListRecCount:=OptionMap.DisplayKlassListRecCount;
    end;
    ClassChange(true);
  end;
end;

procedure TFormDesktop.MenuItemOpenProject(Sender:TObject);
var filename:string;
begin
  filename:=(Sender as TMenuItem).Caption;
  if not ProjectInvalid then
    begin
      if not CurrentRTFP.Close then exit;
    end;
  if not assigned(CurrentRTFP) then
    begin
      CurrentRTFP:=TRTFP.Create(FormDesktop);
      CurrentRTFP.SetAuf(Frame_AufScript1.Auf);
      Self.EventLink(CurrentRTFP);
    end;
  if FileExists(filename) then begin
    CurrentRTFP.Open(UTF8ToWinCP(filename));
    OptionLink(CurrentRTFP);
  end else ShowMsgOK('未找到工程','工程文件未找到！');
end;

procedure TFormDesktop.LoadRecentProject;
var filename:string;
    str:TStringList;
    stmp:string;
    tmp:TMenuItem;
begin
  filename:=LocalPath+'recent_project.dat';
  with MenuItem_project_recent do while Count>0 do
    begin
      tmp:=Items[0];
      Delete(0);
      tmp.Free;
    end;
  str:=TStringList.Create;
  try
    if FileExists(filename) then str.LoadFromFile(filename);
    for stmp in str do
      begin
        if MenuItem_project_recent.Count>10 then break;
        tmp:=TMenuItem.Create(Self);
        tmp.Caption:=stmp;
        tmp.OnClick:=@Self.MenuItemOpenProject;
        MenuItem_project_recent.Add(tmp);
      end;
  finally
    str.Free;
    if MenuItem_project_recent.Count=0 then
      begin
        tmp:=TMenuItem.Create(Self);
        tmp.Caption:='<空>';
        tmp.Enabled:=false;
        MenuItem_project_recent.Add(tmp);
      end;
  end;
end;
procedure TFormDesktop.SaveRecentProject;
var filename,stmp:string;
    str,old:TStringList;
    index:integer;
begin
  if ProjectInvalid then exit;
  filename:=CurrentRTFP.CurrentFileFull;
  str:=TStringList.Create;
  old:=TStringList.Create;
  try
    old.LoadFromFile(LocalPath+'recent_project.dat');
    str.Add(filename);
    for stmp in old do begin
      if (stmp<>filename) and FileExists(stmp) then str.Add(stmp);
    end;
    str.SaveToFile(LocalPath+'recent_project.dat');
  finally
    str.Free;
    old.Free;
  end;
end;

procedure TFormDesktop.Validate(AProject:TRTFP);
var changed_str:string;
begin
  if ProjectInvalid then begin
    Self.Caption:=C_SOFTWARE_NAME;
    exit;
  end;
  if AProject.IsChanged then changed_str:=' *'
  else changed_str:='';
  //标题
  if AProject.Title <> '' then
    Self.Caption:=C_SOFTWARE_NAME+' - '+AProject.Title + changed_str
  else
    Self.Caption:=C_SOFTWARE_NAME+' - '+'<无标题>' + changed_str;
  //工程信息 标签页
  AProject.ProjectPropertiesValidate(Self.PropertiesValueListEditor);
  //文献节点 标签页
  //MainGridValidate(CurrentRTFP);//这个移到DataChange去了

end;

procedure TFormDesktop.ClassListValidate(AProject:TRTFP);
begin
  AProject.KlassListValidate(AListView_Klass);
end;

procedure TFormDesktop.FieldListValidate(AProject:TRTFP);
var tmpAG:TAttrsGroup;
    stored_AG:string;
begin
  AProject.FieldListValidate(AListView_Attrs);
  stored_AG:='';
  if Combo_AddAttrs.ItemIndex>=0 then stored_AG:=Combo_AddAttrs.Items[Combo_AddAttrs.ItemIndex];
  Combo_AddAttrs.Clear;
  for tmpAG in CurrentRTFP.FieldList do Combo_AddAttrs.AddItem(tmpAG.Name,tmpAG);
  Combo_AddAttrs.SelText:=stored_AG;
end;

procedure TFormDesktop.MainGridRebuilding(Sender:TObject);
begin
  Self.DBGrid_Main.Visible:=false;
  if FShowWaitForm then FWaitForm.Show;
end;
procedure TFormDesktop.MainGridRebuildDone(Sender:TObject);
var len,idx:integer;
    tmpAF:TAttrsField;
begin
  len:=Self.DBGrid_Main.Columns.Count;
  for idx:=0 to len-1 do begin
    tmpAF:=TAttrsField(CurrentRTFP.PaperDSFieldDefs[idx]);
    if tmpAF=nil then continue;
    if tmpAF.FFieldDisplayOption.DispName<>'' then
      Self.DBGrid_Main.Columns[idx].Title.Caption:=tmpAF.FFieldDisplayOption.DispName;
  end;
  if FShowWaitForm then FWaitForm.Hide;
  Self.DBGrid_Main.Visible:=true;
  TabSheet_Project_DataGrid.Caption:='文献节点 ('+IntToStr(CurrentRTFP.CountMainGrid)+')';
end;

procedure TFormDesktop.MainGridUpdateRec(AProject:TRTFP;PID:RTFP_ID);
begin
  AProject.UpdateCurrentRec(PID);
end;

procedure TFormDesktop.FormatListValidate(AProject:TRTFP;rename:string='default.fmt');
var stmp,stored:string;
    marked,acc,index:integer;
begin
  //NodeTab
  stored:=ComboBox_FormatEdit.SelText;
  //if stored='' then stored:='default.fmt';
  if stored='' then stored:=rename;
  ComboBox_FormatEdit.Clear;
  acc:=0;
  marked:=-1;
  for stmp in AProject.FormatList do
    begin
      ComboBox_FormatEdit.AddItem(stmp,nil);
      if stmp=stored then marked:=acc;
      inc(acc);
    end;
  if marked>=0 then ComboBox_FormatEdit.ItemIndex:=marked;

  //ProjectTab
  index:=ListBox_FormatEditMgr.ItemIndex;
  ListBox_FormatEditMgr.Clear;
  for stmp in AProject.FormatList do ListBox_FormatEditMgr.Items.Add(stmp);
  if ListBox_FormatEditMgr.Count>index then ListBox_FormatEditMgr.ItemIndex:=index;

end;

procedure TFormDesktop.FormatEditValidate(AProject:TRTFP;fe_new,fe_old:string);
var stored:integer;
    current_fe:string;
begin
  if ComboBox_FormatEdit.Items.Count>0 then begin
    {zan}stored:=ComboBox_FormatEdit.ItemIndex;
    if {zan}stored<0 then current_fe:=''
    else current_fe:=ComboBox_FormatEdit.Items[{zan}stored];
  end else current_fe:='';
  if (fe_old<>current_fe) and (fe_new<>'') then exit;
  if fe_new='' then begin //删除FormatEdit
    stored:=ComboBox_FormatEdit.Items.IndexOf('default.fmt');
    if ComboBox_FormatEdit.Items.Count<1 then begin
      ComboBox_FormatEdit.ItemIndex:=-1;
    end else if stored<0 then begin
      ComboBox_FormatEdit.ItemIndex:=0;
    end else begin
      ComboBox_FormatEdit.ItemIndex:=stored;
    end;
  end else if fe_new=fe_old then begin //修改FormatEdit
    //
  end else begin //重命名FormatEdit
    stored:=ComboBox_FormatEdit.Items.IndexOf(fe_new);
    ComboBox_FormatEdit.ItemIndex:=stored;
  end;
  CurrentRTFP.FormatEditClear(nil);
  if fe_new<>'' then CurrentRTFP.FormatEditBuild(Self.ScrollBox_Node_FormatEdit,fe_new)
  else CurrentRTFP.FormatEditBuild(Self.ScrollBox_Node_FormatEdit,'default.fmt');
  CurrentRTFP.FormatEditValidate(Selected_PID);
end;

procedure TFormDesktop.ProjectTagChange(AProject:TRTFP;akey,avalue:string);
var combo:TComboBox;
    filename:string;
begin
  case akey of
    '字段关联路径':with AProject do
      begin
        combo:=ComboBox_FormatEdit;
        if combo.ItemIndex>=0 then filename:=combo.Items[combo.ItemIndex]
        else filename:='';
        FormatEditClear(Self.ScrollBox_Node_FormatEdit);
        FormatEditBuild(Self.ScrollBox_Node_FormatEdit,filename);
      end;
  end;
end;

procedure TFormDesktop.FirstEdit(AProject:TRTFP);
begin
  Self.Caption:=C_SOFTWARE_NAME+' - '+AProject.Title + ' *';
  Self.MenuItem_project_save.Enabled:=true;
  Application.ProcessMessages;
end;

procedure TFormDesktop.Clear(AProject:TRTFP);
begin
  Self.Caption:=C_SOFTWARE_NAME;
  Self.PropertiesValueListEditor.Clear;
  AListView_Attrs.Root.Clear;
  AListView_Klass.Root.Clear;
  Combo_AddAttrs.Clear;
  ComboBox_FormatEdit.Clear;
end;

procedure TFormDesktop.Log(AProject:TRTFP;msg:string);
begin
  Memo_Log.Lines.Add(msg);
end;

procedure TFormDesktop.ProjectOpenDone(AProject:TRTFP);
var fmt_file:string;
    oidx:integer;
begin

  Self.Frame_AufScript1.OpenDialog.InitialDir:=AProject.CurrentPathFull+'script';
  Self.Frame_AufScript1.SaveDialog.InitialDir:=AProject.CurrentPathFull+'script';

  //文献节点选项卡
  Self.DataSource_Main.DataSet:=AProject.PaperDS;

  //分类节点选项卡
  ClassListValidate(AProject);
  Self.Validate(AProject);
  AProject.RebuildMainGrid;
  fmt_file:=AProject.Tag['编辑属性布局'];
  if AProject.FormatList.Find(fmt_file,oidx) then begin
    ComboBox_FormatEdit.ItemIndex:=oidx;
  end else begin
    fmt_file:='default.fmt';
  end;

  Self.MenuItem_project_new.Enabled:=false;
  Self.MenuItem_project_open.Enabled:=false;
  Self.MenuItem_project_save.Enabled:=false;
  Self.MenuItem_project_saveas.Enabled:=true;
  Self.MenuItem_project_close.Enabled:=true;
  Self.MenuItem_project_zip.Enabled:=true;
  Self.MenuItem_project_unzip.Enabled:=false;
  Self.MenuItem_project_check.Enabled:=true;
  Self.MenuItem_Tool_ProjectDir.Enabled:=true;

  Application.ProcessMessages;

  //这个不是这里应该做的事，应该整合到format_component里头
  //目前在application.processmessage之后避免属性组选项未加载完成而导致combo选项未加载。
  AProject.FormatEditClear(nil);
  AProject.FormatEditBuild(Self.ScrollBox_Node_FormatEdit,fmt_file);
  AProject.FormatEditValidate(Selected_PID);

end;

procedure TFormDesktop.ProjectClose(AProject:TRTFP);
begin
  SaveRecentProject;
end;


procedure TFormDesktop.ProjectCloseDone(AProject:TRTFP);
begin
  Self.Clear(AProject);
  CurrentRTFP.FormatEditClear(Self.ScrollBox_Node_FormatEdit);

  //文献节点选项卡
  Self.DataSource_Main.DataSet:=nil;

  //分类节点选项卡
  AListView_Klass.Root.Clear;
  AListView_Attrs.Root.Clear;
  AListView_Klass.Refresh;
  AListView_Attrs.Refresh;

  Self.MenuItem_project_new.Enabled:=true;
  Self.MenuItem_project_open.Enabled:=true;
  Self.MenuItem_project_save.Enabled:=false;
  Self.MenuItem_project_saveas.Enabled:=false;
  Self.MenuItem_project_close.Enabled:=false;
  Self.MenuItem_project_zip.Enabled:=false;
  Self.MenuItem_project_unzip.Enabled:=true;
  Self.MenuItem_project_check.Enabled:=false;
  Self.MenuItem_Tool_ProjectDir.Enabled:=false;

  SaveRecentProject;
  LoadRecentProject;

end;

procedure TFormDesktop.ProjectSaveDone(AProject:TRTFP);
begin
  Self.Validate(AProject);
  Self.MenuItem_project_save.Enabled:=false;
end;

procedure TFormDesktop.DBGridColumnAdjusting(Sender:TObject);
var index:integer;
    AF:TAttrsField;
    procedure DoDefault;
    begin
      with DBGrid_Main do Columns[index].Width:=TRTFP.FieldOptWidth(Columns[index].Field.FieldDef);
    end;
    procedure DoCustom(value:integer);
    begin
      with DBGrid_Main do Columns[index].Width:=value;
    end;

begin
  if ProjectInvalid then exit;
  with DBGrid_Main do
  for index:=0 to Columns.Count-1 do
    begin
      AF:=TAttrsField(CurrentRTFP.PaperDSFieldDefs[index]);
      if AF=nil then DoDefault
      else if AF.FieldDisplayOption.DispWidth<0 then DoDefault
      else DoCustom(AF.FieldDisplayOption.DispWidth);
    end;
end;

procedure TFormDesktop.DBGridColumnAllocating(Sender:TObject);
var index:integer;
    AF:TAttrsField;
begin
  if ProjectInvalid then exit;
  with DBGrid_Main do
  for index:=0 to Columns.Count-1 do
    begin
      AF:=TAttrsField(CurrentRTFP.PaperDSFieldDefs[index]);
      if AF=nil then continue;
      if Columns[index].Width<2 then AF.FFieldDisplayOption.DispWidth:=2
      else AF.FFieldDisplayOption.DispWidth:=Columns[index].Width;
    end;
end;

procedure TFormDesktop.SetLayoutMode(AModeIndex:integer);
begin
  if AModeIndex = FLayoutMode then exit;
  case AModeIndex of
    0:Splitter_RightH.Top:=0;
    1:Splitter_RightH.Top:=StatusBar.Top div 2;
    2:Splitter_RightH.Top:=StatusBar.Top-6;
  end;
  FLayoutMode:=AModeIndex;
end;

function TFormDesktop.Selected_PID:RTFP_ID;
begin
  result:='000000';
  if DBGrid_Main.DataSource.DataSet=nil then exit;
  if not DBGrid_Main.DataSource.DataSet.Active then exit;
  result:=DBGrid_Main.DataSource.DataSet.Fields.FieldByName(_Col_PID_).AsString;
end;

function TFormDesktop.Select_PID(PID:RTFP_ID):boolean;
begin
  result:=false;
  if DBGrid_Main.DataSource.DataSet=nil then exit;
  if not DBGrid_Main.DataSource.DataSet.Active then exit;
  with TMemDataset(DBGrid_Main.DataSource.DataSet) do
    if Locate(_Col_PID_,PID,[]) then result:=true;
end;

function TFormDesktop.Selected_FileName:string;
begin
  result:='';
  if DBGrid_Main.DataSource.DataSet=nil then exit;
  if not DBGrid_Main.DataSource.DataSet.Active then exit;
  result:=DBGrid_Main.DataSource.DataSet.Fields.FieldByName(_Col_Paper_FileName_).AsString;
end;
function TFormDesktop.Selected_Title:string;
begin
  result:='';
  if DBGrid_Main.DataSource.DataSet=nil then exit;
  if not DBGrid_Main.DataSource.DataSet.Active then exit;
  result:=CurrentRTFP.ReadFieldAsString(_Col_basic_Title_,_Attrs_Basic_,Selected_PID,[]);
end;
function TFormDesktop.Selected_Link:string;
begin
  result:='';
  if DBGrid_Main.DataSource.DataSet=nil then exit;
  if not DBGrid_Main.DataSource.DataSet.Active then exit;
  result:=CurrentRTFP.ReadFieldAsString(_Col_basic_Link_,_Attrs_Basic_,Selected_PID,[]);
end;

procedure TFormDesktop.ShowStatusHelper(str: string);
begin
  StatusBar.Panels[2].Text:=ExtractFileName(str);
end;

procedure TFormDesktop.ViewPdfValidate;
begin
  //
end;

procedure TFormDesktop.NodeViewValidate;
var PID:RTFP_ID;
begin
  PID:=Selected_PID;
  if PID='000000' then exit;
  StatusBar.Panels[0].Text:=PID;
  StatusBar.Panels[1].Text:=ExtractFileName(Selected_FileName);
  CurrentRTFP.UpdatePIDExpr(PID,Self.Frame_AufScript1.Auf.Script);


  //FormatEdit
  CurrentRTFP.FormatEditValidate(PID);
  //类似于FmtCmt的保存询问机制需要覆盖所有的节点编辑选项卡


end;

////////////////////////////////////////////////////////////////////////////////
//快捷键命令

function TFormDesktop.Action_NewPaper:boolean;
var _pid:RTFP_ID;
    _success:boolean;
begin
  result:=false;
  if ProjectInvalid then exit;
  CurrentRTFP.BeginUpdate;//这里不禁用会触发修改分组时的UpdateCurrentRec，应该重新考虑各个Change事件的时机
  _pid:=CurrentRTFP.AddPaper('',apmReference);
  _success:=CurrentRTFP.KlassIncludeFromCombo(_pid,true);
  if not _success then CurrentRTFP.DeletePaper(_pid);
  CurrentRTFP.EndUpdate;//这里不禁用会触发修改分组时的UpdateCurrentRec，应该重新考虑各个Change事件的时机
  if not _success then exit;
  CurrentRTFP.RecordChange;
  Select_PID(_pid);
  NodeViewValidate;
  result:=true;
end;

function TFormDesktop.Action_NewPaper_WebLnk:boolean;
var _pid:RTFP_ID;
    link:string;
begin
  result:=false;
  if ProjectInvalid then exit;
  link:=ShowMsgEdit('新增链接节点','链接：','');
  if link='' then exit;
  CurrentRTFP.BeginUpdate;//这里不禁用会触发修改分组时的UpdateCurrentRec，应该重新考虑各个Change事件的时机
  _pid:=CurrentRTFP.AddPaper(link,apmWebsite);
  CurrentRTFP.KlassIncludeFromCombo(_pid,true);
  CurrentRTFP.EndUpdate;//这里不禁用会触发修改分组时的UpdateCurrentRec，应该重新考虑各个Change事件的时机
  CurrentRTFP.RecordChange;
  Select_PID(_pid);
  NodeViewValidate;
  result:=true;
end;

function TFormDesktop.Action_ImportPapers:boolean;
var filenames:array of string;
    index,len:integer;
begin
  result:=false;
  if ProjectInvalid then exit;
  Form_ImportFiles.IsBackup:=not (ssShift in FMainForm_ShiftState);
  OpenDialog_Project.Title:='导入文献';
  OpenDialog_Project.Filter:='PDF文件(*.pdf)|*.pdf|CAJ文件(*.caj)|*.caj|EPUB文件(*.epub)|*.epub|所有文件|*.*';
  OpenDialog_Project.DefaultExt:='*.pdf';
  OpenDialog_Project.Options:=[ofEnableSizing, ofAllowMultiSelect];
  if OpenDialog_Project.Execute then begin
    index:=0;
    len:=OpenDialog_Project.Files.Count;
    SetLength(filenames,len);
    try
      while index<len do begin
        filenames[index]:=OpenDialog_Project.Files[index];
        inc(index);
      end;
      Form_ImportFiles.Call(filenames);
    finally
      SetLength(filenames,0);
    end;
    SetFocus;
  end;
  result:=true;
end;

////////////////////////////////////////////////////////////////////////////////
//菜单事件

procedure TFormDesktop.MenuItem_project_closeClick(Sender: TObject);
begin
  CurrentRTFP.Close;
end;

procedure TFormDesktop.MenuItem_project_newClick(Sender: TObject);
begin
  Form_NewProject.ShowModal;
  SetFocus;
end;

procedure TFormDesktop.MenuItem_project_openClick(Sender: TObject);
begin

  if assigned(CurrentRTFP) then
  begin
    if CurrentRTFP.IsOpen then CurrentRTFP.Close;
    CurrentRTFP.Free;
  end;
  CurrentRTFP:=TRTFP.Create(FormDesktop);
  CurrentRTFP.SetAuf(Frame_AufScript1.Auf);
  Self.EventLink(CurrentRTFP);

  OpenDialog_Project.Title:='打开工程';
  OpenDialog_Project.Filter:='RTFP工程文件(*.rtfp)|*.rtfp|所有文件|*.*';
  OpenDialog_Project.DefaultExt:='*.rtfp';
  OpenDialog_Project.Options:=[ofEnableSizing];
  if Self.OpenDialog_Project.Execute then begin
    CurrentRTFP.Open(UTF8ToWinCP(Self.OpenDialog_Project.FileName));
    OptionLink(CurrentRTFP);
  end;

end;

procedure TFormDesktop.MenuItem_project_profileClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  FormProjectProfile.ShowModal;
  SetFocus;
end;

procedure TFormDesktop.MenuItem_project_saveasClick(Sender: TObject);
begin
  SaveDialog_project.Filter:='RTFP工程文件(*.rtfp)|*.rtfp|所有文件|*.*';
  SaveDialog_project.DefaultExt:='*.rtfp';
  SaveDialog_Project.Title:='另存为';
  if Self.SaveDialog_Project.Execute then
    CurrentRTFP.SaveAs(Self.SaveDialog_Project.FileName);
end;

procedure TFormDesktop.MenuItem_project_saveClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  CurrentRTFP.Save;
end;

procedure TFormDesktop.MenuItem_RepeatedCheckerClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  FormRepeatedChecker.ShowModal;
  SetFocus;
end;

procedure TFormDesktop.MenuItem_EditReferencesClick(Sender: TObject);
begin
  Form_CiteTrans.Call(false,false);
  SetFocus;
end;

procedure TFormDesktop.MenuItem_Tool_ProjectDirClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  TRTFP.OpenDir({UTF8ToWinCP}(CurrentRTFP.CurrentFileFull));
end;



//菜单事件
////////////////////////////////////////////////////////////////////////////////



procedure TFormDesktop.FormResize(Sender: TObject);
begin
  //Self.Frame_AufScript1.FrameResize(nil);
end;

procedure TFormDesktop.MenuItem_AdvOpen_CAJClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  CurrentRTFP.OpenPaperAsCaj(Selected_PID);
end;

procedure TFormDesktop.MenuItem_AdvOpen_DirClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  CurrentRTFP.OpenPaperDir(Selected_PID);
end;

procedure TFormDesktop.MenuItem_AdvOpen_LinkClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  CurrentRTFP.OpenPaperLink(Selected_PID);
end;

procedure TFormDesktop.MenuItem_AdvOpen_PDFClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  CurrentRTFP.OpenPaperAsPdf(Selected_PID);
end;

procedure TFormDesktop.MenuItem_Attr_AddAttrsClick(Sender: TObject);
begin

end;

procedure TFormDesktop.MenuItem_CB_Cite_APAClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  ClipBoard.AsText:=CurrentRTFP.GetAPA(Selected_PID);
end;

procedure TFormDesktop.MenuItem_CB_Cite_GB7714Click(Sender: TObject);
begin
  if ProjectInvalid then exit;
  ClipBoard.AsText:=CurrentRTFP.GetGBT7714(Selected_PID);
end;

procedure TFormDesktop.MenuItem_CB_Cite_MLAClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  ClipBoard.AsText:=CurrentRTFP.GetMLA(Selected_PID);
end;

procedure TFormDesktop.MenuItem_CB_FilenamefullClick(Sender: TObject);
var folder,filename:string;
begin
  if ProjectInvalid then exit;
  folder:=CurrentRTFP.PaperDS.FieldByName(_Col_Paper_Folder_).AsString;
  filename:=CurrentRTFP.PaperDS.FieldByName(_Col_Paper_FileName_).AsString;
  case folder of
    'extern','weblnk','':ClipBoard.AsText:=filename;
    else ClipBoard.AsText:=CurrentRTFP.CurrentPathFull+'paper'+_fsplit_+folder+_fsplit_+filename;
  end;
end;

procedure TFormDesktop.MenuItem_CB_PIDClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  ClipBoard.AsText:=Selected_PID;
end;

procedure TFormDesktop.MenuItem_CB_RefNum_AurYearClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  ClipBoard.AsText:=CurrentRTFP.GetRef_AurYear(Selected_PID);
end;

procedure TFormDesktop.MenuItem_CB_RefNum_InOrderClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  ClipBoard.AsText:=CurrentRTFP.GetRef_InOrder(Selected_PID);
end;

procedure TFormDesktop.MenuItem_CB_Ref_EndNoteClick(Sender: TObject);
var str:TStringList;
    stmp,res:string;
begin
  if ProjectInvalid then exit;
  str:=TStringList.Create;
  try
    CurrentRTFP.SaveToEndNote(Selected_PID,str);
    res:=#13#10;
    for stmp in str do res:=res+stmp+#13#10;
    Clipboard.AsText:=res;
  finally
    str.Free;
  end;
end;

procedure TFormDesktop.MenuItem_CB_Ref_EStudyClick(Sender: TObject);
var str:TStringList;
    stmp,res:string;
begin
  if ProjectInvalid then exit;
  str:=TStringList.Create;
  try
    CurrentRTFP.SaveToEStudy(Selected_PID,str);
    res:=#13#10;
    for stmp in str do res:=res+stmp+#13#10;
    Clipboard.AsText:=res;
  finally
    str.Free;
  end;
end;

procedure TFormDesktop.MenuItem_CB_Ref_RISClick(Sender: TObject);
var str:TStringList;
    stmp,res:string;
begin
  if ProjectInvalid then exit;
  str:=TStringList.Create;
  try
    CurrentRTFP.SaveToRIS(Selected_PID,str);
    res:=#13#10;
    for stmp in str do res:=res+stmp+#13#10;
    Clipboard.AsText:=res;
  finally
    str.Free;
  end;
end;

procedure TFormDesktop.MenuItem_CB_TitleClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  ClipBoard.AsText:=CurrentRTFP.ReadFieldAsString(_Col_basic_Title_,_Attrs_Basic_,Selected_PID,[]);
end;

procedure TFormDesktop.MenuItem_CiteToolClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  Form_CiteTrans.Call(true,false);
  SetFocus;
end;

procedure TFormDesktop.MenuItem_ClassMgr_CDirClick(Sender: TObject);
var tmpNode:TListCheckNode;
begin
  if ProjectInvalid then exit;
  tmpNode:=TListCheckNode(AListView_Klass.Selected);
  if tmpNode<>nil then
  ShowMsgOK('分类重命名','暂不支持分类移动。');
  //klassname:=TKlass(tmpNode.Data).FullPath;
  //newname:=InputBox('分类移动','分类组：',klassname);
  //if (newname<>'') and (newname<>klassname) then CurrentRTFP.ChangeKlassDir(klassname);
end;

procedure TFormDesktop.MenuItem_ClassMgr_DelClick(Sender: TObject);
var tmpNode:TListCheckNode;
    tmpKL:TKlass;
    filter:boolean;
begin
  if ProjectInvalid then exit;
  tmpNode:=AListView_Klass.Selected;
  if tmpNode=nil then exit;
  if tmpNode.Name='.' then begin
    case ShowMsgOK('删除分类','“.”分类即上一层的可展开分类，请直接删除上一层分类。') of
      'Yes':;
      else exit;
    end;
  end;
  tmpKL:=TKlass(tmpNode.Data);
  if tmpKL=nil then exit;
  if tmpKL.KlassList.Count<>0 then begin
    case ShowMsgYesNoAll('删除分类','删除'+tmpKL.Name+'将同时删除其下的所有分类，是否确认删除？') of
      'Yes':;
      else exit;
    end;
  end;
  filter:=tmpKL.FilterEnabled;
  case ShowMsgYesNoAll('删除分类','是否删除“'+tmpKL.Name+'”分类？') of
    'Yes':CurrentRTFP.DeleteKlass(tmpKL);
    else exit;
  end;
  if filter then CurrentRTFP.RebuildMainGrid;
end;

procedure TFormDesktop.MenuItem_ClassMgr_RenClick(Sender: TObject);
var tmpNode:TListCheckNode;
begin
  if ProjectInvalid then exit;
  tmpNode:=AListView_Klass.Selected;
  if tmpNode=nil then exit;
  ShowMsgOK('分类重命名','暂不支持分类重命名。');
  //klassname:=TKlass(tmpNode.Data).Name;
  //newname:=InputBox('分类重命名','新名称：',klassname);
  //if (newname<>'') and (newname<>klassname) then CurrentRTFP.RenameKlass(klassname);
end;

procedure TFormDesktop.MenuItem_ClassMgr_CheckAllClick(Sender: TObject);
var tmpNode:TListCheckNode;
    tmpKL:TKlass;
begin
  if ProjectInvalid then exit;
  tmpNode:=AListView_Klass.Selected;
  if tmpNode=nil then exit;
  CurrentRTFP.BeginUpdate;
  tmpNode.CheckAllSubordinates;
  for tmpKL in TKlass(tmpNode.Data).KlassList do tmpKL.FilterEnabled:=true;
  CurrentRTFP.EndUpdate;
  AListView_Klass.Refresh;
  CurrentRTFP.RebuildMainGrid;
end;

procedure TFormDesktop.MenuItem_ClassMgr_UnCheckAllClick(Sender: TObject);
var tmpNode:TListCheckNode;
    tmpKL:TKlass;
begin
  if ProjectInvalid then exit;
  tmpNode:=AListView_Klass.Selected;
  if tmpNode=nil then exit;
  CurrentRTFP.BeginUpdate;
  tmpNode.UnCheckAllSubordinates;
  for tmpKL in TKlass(tmpNode.Data).KlassList do tmpKL.FilterEnabled:=false;
  CurrentRTFP.EndUpdate;
  AListView_Klass.Refresh;
  CurrentRTFP.RebuildMainGrid;
end;

procedure TFormDesktop.MenuItem_ClassToolClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  ClassManagerForm.ShowModal;//ClassManagerForm.show;
  SetFocus;
end;

procedure TFormDesktop.MenuItem_DBGC_DisplayOptClick(Sender:TObject);
begin
  if ProjectInvalid then exit;
  FormFieldDisplayOption.Call(TAttrsField(CurrentRTFP.PaperDSFieldDefs[LastDBGridPos.x-1]));
  SetFocus;
end;

procedure TFormDesktop.MenuItem_DBGC_SeekClick(Sender: TObject);
var searchstr:string;
    bm:TBookMark;
    reg:TRegexpr;
begin
  if ProjectInvalid then exit;
  reg:=TRegexpr.Create;
  try
  searchstr:=ShowMsgEdit('跳转到符合条件的字段值','正则表达式（匹配空值请输入“^$”或“\A\Z”）：','');
  if searchstr='' then exit
  else reg.Expression:=searchstr;
  with DBGrid_Main.DataSource.DataSet do
    begin
      bm:=Bookmark;
      while not EOF do
        begin
          if reg.Exec(Fields[LastDBGridPos.x-1].AsString) then exit;
          Next;
        end;
      if EOF then begin
        searchstr:=ShowMsgOK('未找到','未找到符合条件的字段值。');
        GotoBookmark(bm);
      end;
    end;
  finally
    reg.Free;
  end;
end;

procedure TFormDesktop.MenuItem_DBGC_TitleClick(Sender: TObject);
begin
  Clipboard.AsText:=(Sender as TMenuItem).Caption;
end;

procedure TFormDesktop.MenuItem_DeletePaperClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  case ShowMsgYesNoAll('删除确认','是否删除此文献节点？') of
    'Yes':CurrentRTFP.DeletePaper(Selected_PID);
    else exit;
  end;
  //CurrentRTFP.RecordChange;
end;

procedure TFormDesktop.MenuItem_EditSourceClick(Sender: TObject);
begin
  Form_FileSource.Call;
  SetFocus;
end;

procedure TFormDesktop.MenuItem_ExportToolClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  FormReportTool.ShowModal;
  SetFocus;
end;

procedure TFormDesktop.MenuItem_FieldMgr_DelClick(Sender: TObject);
var tmpNode:TListCheckNode;
    target_name,group_name:string;
begin
  if ProjectInvalid then exit;
  tmpNode:=AListView_Attrs.Selected;
  if tmpNode=nil then exit;
  if tmpNode.Data is TAttrsGroup then
    begin
      target_name:=(tmpNode.Data as TAttrsGroup).Name;
      case ShowMsgYesNoAll('删除属性组','是否删除属性组“'+target_name+'”？') of
        'Yes':CurrentRTFP.DeleteAttrs(target_name);
        else exit;
      end;
    end
  else if tmpNode.Data is TAttrsField then
    begin
      target_name:=(tmpNode.Data as TAttrsField).FieldName;
      group_name:=(tmpNode.Data as TAttrsField).AttrsGroup.Name;
      case ShowMsgYesNoAll('删除字段列','是否删除属性组“'+group_name+'”中的字段列“'+target_name+'”？') of
        'Yes':CurrentRTFP.DeleteField(target_name,group_name);
        else exit;
      end;
    end
  else assert(false,'TListCheckNode中有unexpected的类型对象');
end;

procedure TFormDesktop.MenuItem_FieldMgr_EditClick(Sender: TObject);
var tmpNode:TListCheckNode;
begin
  if ProjectInvalid then exit;
  tmpNode:=AListView_Attrs.Selected;
  if tmpNode=nil then exit;
  if tmpNode.Data is TAttrsGroup then begin
    if Form_FieldChange.Call(TAttrsField(tmpNode.Data))=mrOK then
      CurrentRTFP.RebuildMainGrid;
    SetFocus;
  end else if tmpNode.Data is TAttrsField then begin
    if Form_FieldChange.Call(TAttrsField(tmpNode.Data))=mrOK then
      CurrentRTFP.RebuildMainGrid;
    SetFocus;
  end else assert(false,'TListCheckNode中有unexpected的类型对象');

end;

procedure TFormDesktop.MenuItem_FieldMgr_DisplayOptionClick(Sender: TObject);
var tmpNode:TListCheckNode;
begin
  if ProjectInvalid then exit;
  tmpNode:=AListView_Attrs.Selected;
  if tmpNode=nil then exit;
  if tmpNode.Data is TAttrsGroup then
    exit
  else if tmpNode.Data is TAttrsField then
    begin
      if FormFieldDisplayOption.Call(TAttrsField(tmpNode.Data))=mrOK then;
        //DBGrid_MainDrawColumnCell(DBGrid_Main,)
      SetFocus;
    end
  else assert(false,'TListCheckNode中有unexpected的类型对象');
end;

procedure TFormDesktop.MenuItem_EditKlassClick(Sender: TObject);
begin
  ClassManagerForm.ShowModal;
  SetFocus;
end;

procedure TFormDesktop.MenuItem_field_RebuildBlobClick(Sender: TObject);
var AG:TAttrsGroup;
    AF:TAttrsField;
    is_img_file:boolean;
    PID:RTFP_ID;
    tmp_mem:TMemoryStream;
    tmp_bmp:TPicture;
    img_file_name,img_file_path:string;
    tmpField:TField;
begin
  if ProjectInvalid then exit;
  //更改数据的警告
  exit;
  //将所有图像字段改为当前设置的形式。
  //真离谱，生成的bmp格式有问题，用TPicture又有错误
  {
  tmp_mem:=TMemoryStream.Create;
  tmp_bmp:=TPicture.Create;
  try
    for AG in CurrentRTFP.FieldList do begin
      AG.Dbf.First;
      while not AG.Dbf.EOF do begin
        PID:=AG.Dbf.FieldByName(_Col_PID_).AsString;
        for AF in AG.FieldList do begin
          if AF.FieldDef.DataType<>ftBlob then continue;
          tmpField:=AG.Dbf.FieldByName(AF.FieldName);
          is_img_file:=false;
          if TBlobField(tmpField).Size=4 then begin
            TBlobField(tmpField).SaveToStream(tmp_mem);
            if pdword(tmp_mem.Memory)^=0 then is_img_file:=true;
          end;
          if CurrentRTFP.RunPerformance.Fields_ImgFile=is_img_file then continue;
          img_file_path:=CurrentRTFP.GetImgFilePath(AF.FieldName,AG.Name);
          img_file_name:=img_file_path+_fsplit_+CurrentRTFP.GetImgFileName(PID);
          if is_img_file then begin
            tmp_bmp.Bitmap.LoadFromFile(img_file_name);
            tmp_bmp.Bitmap.SaveToStream(tmp_mem);
            AG.Dbf.Edit;
            TBlobField(tmpField).LoadFromStream(tmp_mem);
            AG.Dbf.Post;
            TRTFP.FileDelete(img_file_name);
            //文件夹要不要删？
          end else begin
            TBlobField(tmpField).SaveToStream(tmp_mem);
            tmp_bmp.Bitmap.LoadFromStream(tmp_mem);
            ForceDirectories(img_file_path);
            tmp_bmp.Bitmap.SaveToFile(img_file_name);
            tmp_mem.Clear;
            tmp_mem.Position:=0;
            tmp_mem.WriteDWord(0);
            tmp_mem.Position:=0;
            AG.Dbf.Edit;
            TBlobField(tmpField).LoadFromStream(tmp_mem);
            AG.Dbf.Post;
          end;
        end;
        AG.Dbf.Next;
      end;
    end;
  finally
    tmp_mem.Free;
    tmp_bmp.Free;
  end;
  }
  CurrentRTFP.FieldAndRecordChange;
end;

procedure TFormDesktop.MenuItem_klass_AddKlassClick(Sender: TObject);
var klassname:string;
begin
  if ProjectInvalid then exit;
  klassname:={InputBox}ShowMsgEdit('新建分类','分类名称：','');
  if klassname<>'' then
    begin
      klassname:=ExtractFileName(klassname);
      CurrentRTFP.AddKlass(klassname,nil);
    end;
end;

procedure TFormDesktop.MenuItem_klass_checkClick(Sender: TObject);
var PID:RTFP_ID;
    PIDList,ExcStr:TStringList;
    codee:integer;
    klassname:string;
    tmpKL:TKlass;
begin
  if ProjectInvalid then exit;
  //if ShowMsgYesNoAll('-------','-----，是否继续？')<>'Yes' then exit;
  PIDList:=TStringList.Create;
  ExcStr:=TStringList.Create;
  ExcStr.Sorted:=true;
  try
    CurrentRTFP.GetPIDList(PIDList);
    CurrentRTFP.BeginUpdate;
    for PID in PIDList do
      CurrentRTFP.EditFieldAsString(_Col_class_DefaultCl_,_Attrs_Class_,PID,'',[aeForceEditIfTypeDismatch]);
    for tmpKL in CurrentRTFP.KlassList do
      begin
        with tmpKL.Dbf do
          begin
            klassname:=tmpKL.KlassNameWithDelimiter('.');
            if not Active then Open;
            First;
            while not EOF do
              begin
                PID:=FieldByName(_Col_PID_).AsString;
                ExcStr.Clear;
                CurrentRTFP.ReadFieldAsMemo(_Col_class_DefaultCl_,_Attrs_Class_,PID,ExcStr,[]);
                if not ExcStr.Find(klassname,codee) then begin
                  ExcStr.Add(klassname);
                  CurrentRTFP.EditFieldAsMemo(_Col_class_DefaultCl_,_Attrs_Class_,PID,ExcStr,[]);
                end;
                Next;
              end;
          end;
        //
      end;
  finally
    PIDList.Free;
    ExcStr.Free;
    CurrentRTFP.EndUpdate;
    CurrentRTFP.ClassChange;
    CurrentRTFP.RecordChange;
    ShowMsgOK('更新分类字段','分类字段已根据分类索引重置');
  end;
end;

procedure TFormDesktop.MenuItem_klass_DelKlassClick(Sender: TObject);
var klassname:string;
    str:TStringList;
    tmpKL:TKlass;
begin
  if ProjectInvalid then exit;
  str:=TStringList.Create;
  try
    for tmpKL in CurrentRTFP.KlassList do str.Add(tmpKL.KlassNameWithDelimiter('.'));
    klassname:=ShowMsgList('删除分类','选择需要删除的分类：',str);
    if klassname<>'' then CurrentRTFP.DeleteKlass(klassname,'.');
  finally
    str.Free;
  end;
end;

procedure SourceClassMaking(APID:string);
var source,klassname:string;
    tmpKL:TKlass;
begin
  source:=CurrentRTFP.ReadFieldAsString(_Col_basic_Source_,_Attrs_Basic_,APID,[]);
  if source<>'' then begin
    klassname:=source;
    tmpKL:=CurrentRTFP.AddKlass('来源库.'+klassname,'.');
    CurrentRTFP.KlassInclude(tmpKL,APID);
  end;
end;

procedure TFormDesktop.MenuItem_klass_SourceClassClick(Sender: TObject);
var PIDList:TStringList;
begin
  //太慢了，要点其他操作缓解一下，或者做进度条和耗时提示
  if ProjectInvalid then exit;
  //if ShowMsgYesNoAll('重建来源分类','重建来源分类会删除已有的全部“来源库”文件夹下的分类，是否继续？')<>'Yes' then exit;
  PIDList:=TStringList.Create;
  CurrentRTFP.BeginUpdate;
  try
    CurrentRTFP.GetPIDList(PIDList);
    ShowMsgProgressBar('请稍后','正在创建来源分类……',PIDList,@SourceClassMaking);
  finally
    PIDList.Free;
    CurrentRTFP.EndUpdate;
    CurrentRTFP.ClassChange;
    ShowMsgOK('重建来源分类','来源库已重建完成！');
  end;
end;

procedure TFormDesktop.MenuItem_Mark_IsRead_NoClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  CurrentRTFP.EditFieldAsBoolean(_Col_class_Is_Read_,_Attrs_Class_,Selected_PID,false,[]);
end;

procedure TFormDesktop.MenuItem_Mark_IsRead_YesClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  CurrentRTFP.EditFieldAsBoolean(_Col_class_Is_Read_,_Attrs_Class_,Selected_PID,true,[]);
end;

procedure TFormDesktop.MenuItem_NewPaperClick(Sender: TObject);
begin
  Action_NewPaper;
end;

procedure TFormDesktop.MenuItem_OpenAsCajClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  CurrentRTFP.OpenPaperAsCaj(Selected_PID);
end;

procedure TFormDesktop.MenuItem_OpenAsPdfClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  CurrentRTFP.OpenPaperAsPdf(Selected_PID);
end;

procedure TFormDesktop.MenuItem_OpenDefaultClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  CurrentRTFP.OpenPaper(Selected_PID,'');
end;

procedure TFormDesktop.MenuItem_OpenDirClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  CurrentRTFP.OpenPaperDir(Selected_PID);
end;

procedure TFormDesktop.MenuItem_OpenLinkClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  CurrentRTFP.OpenPaperLink(Selected_PID);
end;

procedure TFormDesktop.MenuItem_option_aboutClick(Sender: TObject);
begin
  ShowMsgOK('关于',C_SOFTWARE_NAME+#13#10+
            '版本： ' + C_VERSION_NUMBER+#13#10+
            '作者： ' + C_SOFTWARE_AUTHOR+#13#10+
            ' '+#13#10+
            ' - Reading Technique For Paperwork.'+#13#10+
            ' - Reference Tool by Free Pascal.'+#13#10+
            ' - Read The F Paper.');
end;

procedure TFormDesktop.MenuItem_option_appearanceClick(Sender: TObject);
begin
  AppearanceForm.ShowModal;
  SetFocus;
end;

procedure TFormDesktop.MenuItem_option_settingClick(Sender: TObject);
begin
  FormOptions.ShowModal;
  SetFocus;
end;

procedure TFormDesktop.PageControl_NodeChange(Sender: TObject);
begin

end;

procedure TFormDesktop.StringGrid_FormatEditLayoutMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var tmpSG:TStringGrid;
    pi,pj:integer;
begin
  if ProjectInvalid then exit;
  if (Button = mbRight) and (Shift = []) then else exit;
  tmpSG:=Sender as TStringGrid;
  FormFormatEditOption.Call(
    CurrentRTFP,
    (tmpSG.Selection.Top-1)*70,
    (tmpSG.Selection.Bottom)*70,
    (tmpSG.Selection.Left-1),
    tmpSG.Selection.Right);
  SetFocus;
  //ShowMsgOK('',FormFormatEditOption.Syntax);//直接得到的这个代码暂时用不了
  SynEdit_FEMgr.Lines.Add(FormFormatEditOption.Syntax);

  for pj:=tmpSG.Selection.Top to tmpSG.Selection.Bottom do
    for pi:=tmpSG.Selection.Left to tmpSG.Selection.Right do
      tmpSG.Cells[pi,pj]:='x';

end;

procedure TFormDesktop.SynEdit_FEMgrClick(Sender: TObject);
var tmpSyn:TSynEdit;
    ltext:string;
    sel_row,tt,bb,ll,rr:integer;
begin
  tmpSyn:=Sender as TSynEdit;
  sel_row:=tmpSyn.CaretY;
  //点击以后的高亮不太好弄
  ltext:=tmpSyn.LineText;
  //ShowMessage(IntToStr(sel_row));
  Auf.ReadArgs(ltext);
  //edit 文献基础信息,关键词,关键词,140,70,0,2,editable
  try

    tt:=StrToInt(Auf.nargs[4].arg) div 70 + 1;
    bb:=StrToInt(Auf.nargs[5].arg) div 70 + tt - 2;
    case lowercase(Auf.nargs[6].arg) of
      '0','l':ll:=1;
      'lm':ll:=2;
      '1','ml':ll:=3;
      '2','m':ll:=4;
      '3','mr':ll:=5;
      'rm':ll:=6;
      //'4','r':ll:=7;
    end;
    case lowercase(Auf.nargs[7].arg) of
      //'0','l':rr:=0;
      'lm':rr:=1;
      '1','ml':rr:=2;
      '2','m':rr:=3;
      '3','mr':rr:=4;
      'rm':rr:=5;
      '4','r':rr:=6;
    end;
    with StringGrid_FormatEditLayout.Selection do
      begin
        Inflate(ll,tt,rr,bb);
        //Top:=tt;
        //Left:=ll;
        //Right:=rr;
        //Bottom:=bb;//坐标有误
        //为啥选区不能更新？？
      end;
    StringGrid_FormatEditLayout.Update;

  except

  end;

  //StringGrid_FormatEditLayout.Selection.Top;
end;

procedure TFormDesktop.TabSheet_Project_AufScriptResize(Sender: TObject);
begin
  Self.Frame_AufScript1.FrameResize(nil);
end;

procedure TFormDesktop.PropertiesValueListEditorEditingDone(Sender: TObject);
begin
  if ProjectInvalid then exit;

  //CurrentRTFP.Title:=Utf8ToWinCP(Self.PropertiesValueListEditor.Values['工程标题']);
  //CurrentRTFP.User:=Utf8ToWinCP(Self.PropertiesValueListEditor.Values['创建用户']);
  CurrentRTFP.ProjectPropertiesDataPost(Self.PropertiesValueListEditor);
end;

procedure TFormDesktop.FormCreate(Sender: TObject);
var pi:integer;
begin
  Self.Frame_AufScript1.AufGenerator;
  AufScriptFuncDefineRTFP(Self.Frame_AufScript1.Auf);
  Self.Frame_AufScript1.HighLighterReNew;
  CurrentRTFP.UpdatePIDExpr('000000',Self.Frame_AufScript1.Auf.Script);
  Self.Frame_AufScript1.OnHelper:=@ShowStatusHelper;

  LocalPath:=ExtractFilePath(ParamStr(0));
  if Self.Height>Screen.Height then Self.Height:=trunc(Screen.Height*0.8);
  if Self.Width>Screen.Width then Self.Height:=trunc(Screen.Width*0.8);

  StringGrid_FormatEditLayout.Cells[1,0]:='L-LM';
  StringGrid_FormatEditLayout.Cells[2,0]:='LM-ML';
  StringGrid_FormatEditLayout.Cells[3,0]:='ML-M';
  StringGrid_FormatEditLayout.Cells[4,0]:='M-MR';
  StringGrid_FormatEditLayout.Cells[5,0]:='MR-RM';
  StringGrid_FormatEditLayout.Cells[6,0]:='RM-R';

  for pi:=1 to 99 do StringGrid_FormatEditLayout.Cells[0,pi]:=IntToStr(pi);
  StringGrid_FormatEditLayout.ColWidths[0]:=36;

  PageControl_Filter.ActivePage:=TabSheet_Filter_Field;
  PageControl_Project.ActivePage:=TabSheet_Project_DataGrid;
  PageControl_Node.ActivePage:=TabSheet_Node_FormatEdit;

  FShowWaitForm:=true;
  FWaitForm:=TForm.Create(Self);
  with FWaitForm do begin
    Height:=120;
    Width:=280;
    Position:=poOwnerFormCenter;
    Caption:='请稍等';
    Hide;
  end;
  FWaitLabel:=TLabel.Create(FWaitForm);
  with FWaitLabel do begin
    //Align:=alClient;
    //AutoSize:=true;
    Top:=0;
    Left:=0;
    Caption:='主表正在重建中';//为啥不管用？？？？？有见到它创建，但是就闪了一下，怎么回事
    Parent:=FWaitForm;
  end;

  SyncTimer:=TRTFP_SyncTimer.Create(Self);
  FormOptions.LoadOptionFromReg;

  LoadRecentProject;

  if ParamCount<>0 then
    begin
      CurrentRTFP:=TRTFP.Create(FormDesktop);
      CurrentRTFP.SetAuf(Frame_AufScript1.Auf);
      Self.EventLink(CurrentRTFP);
      CurrentRTFP.Open(UTF8ToWinCP(ParamStr(1)));
    end;

  FMainForm_ShiftState:=[];

  FFormatEdit_Highlighter:=TSynAufSyn.Create(Self);
  with FFormatEdit_Highlighter do
    begin
      InternalFunc:=InternalFunc+'memo,';
      InternalFunc:=InternalFunc+'edit,';
      InternalFunc:=InternalFunc+'combo,';
      InternalFunc:=InternalFunc+'check,';
      InternalFunc:=InternalFunc+'image,';
      InternalFunc:=InternalFunc+'list,';
    end;
  SynEdit_FEMgr.Highlighter:=FFormatEdit_Highlighter;
end;

procedure TFormDesktop.FormDropFiles(Sender: TObject;
  const FileNames: array of String);
var len,pi:integer;
    filelist:TStringList;
    filenames_in_dir:array of String;
begin
  len:=Length(FileNames);
  if (len=1) then
  begin
    if DirectoryExists(FileNames[0]) then
    begin
      filelist:=TStringList.Create;
      try
        FindAllFiles(filelist,FileNames[0],'',true,faAnyFile or faDirectory);
        SetLength(filenames_in_dir,filelist.Count);
        for pi:=0 to filelist.Count-1 do begin
          filenames_in_dir[pi]:=filelist[pi];
        end;
        if not ProjectInvalid then
        begin
          Form_ImportFiles.IsBackup:=not (ssShift in FMainForm_ShiftState);
          Form_ImportFiles.Call(filenames_in_dir);
        end;
      finally
        filelist.Free;
        SetLength(filenames_in_dir,0);
      end;
      SetFocus;
      exit;
    end;
    if TRTFP.IsProjectFile(FileNames[0]) then
    begin
      if assigned(CurrentRTFP) then
      begin
        if CurrentRTFP.IsOpen then exit
        else CurrentRTFP.Free;
      end;
      CurrentRTFP:=TRTFP.Create(FormDesktop);
      CurrentRTFP.SetAuf(Frame_AufScript1.Auf);
      Self.EventLink(CurrentRTFP);
      Application.ProcessMessages;

      CurrentRTFP.Open(UTF8ToWinCP(FileNames[0]));
      OptionLink(CurrentRTFP);
      SetFocus;
      exit;
    end;
  end;
  if not ProjectInvalid then
  begin
    Form_ImportFiles.IsBackup:=not (ssShift in FMainForm_ShiftState);
    Form_ImportFiles.Call(FileNames);
  end;
  SetFocus;
end;

procedure TFormDesktop.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  FMainForm_ShiftState+=Shift;
  //ShowMsgOK('A','B'); ????????
end;

procedure TFormDesktop.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  FMainForm_ShiftState-=Shift;
  //ShowMsgOK('A','B');
  //为什么没有反应？？？
  if ssCtrl in Shift then
    begin
      case Key of
        78,110:Action_NewPaper;//N
      end;
    end;
end;

{
procedure TFormDesktop.CheckListBox_MainAttrFilterClickCheck(Sender: TObject);
begin
  if ProjectInvalid then exit;
  CurrentRTFP.RebuildMainGrid;//MainGridValidate(CurrentRTFP);
end;
}

procedure TFormDesktop.ComboBox_FormatEditChange(Sender: TObject);
var combo:TComboBox;
    filename:string;
begin
  if ProjectInvalid then exit;
  combo:=Sender as TComboBox;
  if combo.ItemIndex>=0 then filename:=combo.Items[combo.ItemIndex]
  else filename:='';
  CurrentRTFP.Tag['编辑属性布局']:=filename;
  CurrentRTFP.FormatEditClear(nil);
  CurrentRTFP.FormatEditBuild(Self.ScrollBox_Node_FormatEdit,filename);
  CurrentRTFP.FormatEditValidate(Selected_PID);
end;

procedure TFormDesktop.DataSource_MainUpdateData(Sender: TObject);
begin
  DBGridColumnAdjusting(CurrentRTFP);
end;


{
procedure TFormDesktop.AListView_AttrsNodeChecked(Sender: TObject;
  Item: TACL_TreeNode);
var tmpA:TObject;
begin
  tmpA:=Item.Data;
  if tmpA=nil then exit;
  if tmpA is TAttrsField then
    begin
      (tmpA as TAttrsField).Shown:=Item.Checked;
      CurrentRTFP.RebuildMainGrid;//MainGridValidate(CurrentRTFP);//CurrentRTFP.DataChange;
    end
  else if tmpA is TAttrsGroup then
    begin
      (tmpA as TAttrsGroup).GroupShown:=Item.Checked;
    end
  else ;
end;
}

procedure TFormDesktop.AListView_AttrsItemChecked(Sender: TObject;
  Item: TListCheckNode);
var tmpA:TObject;
begin
  tmpA:=Item.Data;
  if tmpA=nil then exit;
  if tmpA is TAttrsField then
    begin
      (tmpA as TAttrsField).Shown:=Item.Checked;
      CurrentRTFP.RebuildMainGrid;
    end
  else if tmpA is TAttrsGroup then
    begin
      (tmpA as TAttrsGroup).GroupShown:=Item.Unfold;
    end
  else ;
end;

procedure TFormDesktop.AListView_KlassDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var tmpNode:TListCheckNode;
    tmpKL:TKlass;
begin
  tmpNode:=(Sender as TListCheck).PickItem(X,Y);
  if tmpNode=nil then exit;
  tmpKL:=TKlass(tmpNode.Data);
  if tmpKL=nil then exit;
  if ssShift in UIState.DragShift then
    CurrentRTFP.KlassExclude(tmpKL,Selected_PID)
  else
    CurrentRTFP.KlassInclude(tmpKL,Selected_PID);
end;

procedure TFormDesktop.AListView_KlassDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var tmpNode:TListCheckNode;
begin
  tmpNode:=(Sender as TListCheck).PickItem(X,Y);
  Accept:=tmpNode<>nil;
  if Accept then (Sender as TListCheck).Selected:=tmpNode;
  (Sender as TListCheck).Refresh;
end;

procedure TFormDesktop.AListView_KlassItemChecked(Sender: TObject;
  Item: TListCheckNode);
var tmpKL:TKlass;
begin
  tmpKL:=TKlass(Item.Data);
  if tmpKL<>nil then begin
    //可展开分类的设置
    if Item.Name='.' then begin
      tmpKL.FilterEnabled:=Item.Checked;
    end else begin
      if tmpKL.KlassList.Count=0 then begin
        tmpKL.FilterEnabled:=Item.Checked;
        //tmpKL.SubKlassShown:=false;
      end else begin
        tmpKL.SubKlassShown:=Item.Unfold;
        //tmpKL.FilterEnabled:=false;
        exit;//折叠展开时不刷新主表
      end;
    end;
    CurrentRTFP.RebuildMainGrid;
  end;
end;

procedure TFormDesktop.Button_AddAttrsClick(Sender: TObject);
var GroupName:string;
begin
  if ProjectInvalid then exit;
  if Combo_AddAttrs.ItemIndex>=0 then exit;
  GroupName:=Combo_AddAttrs.Text;
  if GroupName='' then exit;
  if CurrentRTFP.FindAttrs(GroupName)<>nil then
    begin
      ShowMsgOK('警告','属性组“'+GroupName+'”已存在。');
      exit;
    end;
  if Sender=nil then begin
    CurrentRTFP.AddAttrs(GroupName);
    //Button_AddFieldClick中使用nil作为参数调用则不需要再询问
  end else begin
    case ShowMsgYesNoAll('创建属性组','是否创建名为“'+GroupName+'”的属性组？') of
      'Yes':if CurrentRTFP.AddAttrs(GroupName)=nil then ShowMsgOK('警告','属性组创建失败');
      else exit;
    end;
  end;
  CurrentRTFP.FieldChange;
end;

procedure TFormDesktop.Button_AddFieldClick(Sender: TObject);
var GroupName,FieldName:string;
    confirmed:boolean;
    ChosenFieldType:TFieldType;
    poss:integer;
    fieldclassname,str:string;
begin
  if ProjectInvalid then exit;

  str:=Combo_FieldType.Text;
  fieldclassname:=str;
  poss:=pos(' ',str);
  delete(str,1,poss);
  delete(fieldclassname,poss,length(fieldclassname));
  {size}poss:=0;
  case str of
    'Memo':ChosenFieldType:=ftMemo;
    'String[16]':begin ChosenFieldType:=ftString;{size}poss:=16;end;
    'String[72]':begin ChosenFieldType:=ftString;{size}poss:=72;end;
    'String[240]':begin ChosenFieldType:=ftString;{size}poss:=240;end;
    'Boolean':ChosenFieldType:=ftBoolean;
    'SmallInt':ChosenFieldType:=ftSmallint;
    'LargeInt':ChosenFieldType:=ftLargeint;
    'Float':ChosenFieldType:=ftFloat;
    //'Date':ChosenFieldType:=ftDate;
    'DateTime':ChosenFieldType:=ftDateTime;
    'Blob':ChosenFieldType:=ftBlob;
    else begin
      assert(false,'Combo_FieldType中有unexpected类型');
      exit;
    end;
  end;

  confirmed:=false;
  GroupName:=Combo_AddAttrs.Text;
  FieldName:=Edit_AddField.Caption;
  if GroupName='' then exit;
  if FieldName='' then exit;
  if length(GroupName)>20 then
    begin
      ShowMsgOK('警告','属性组名称不能超过20个字节！');
      exit;
    end;
  if length(FieldName)>12 then
    begin
      ShowMsgOK('警告','字段列名称不能超过12个字节！');
      exit;
    end;
  if CurrentRTFP.FindField(FieldName,GroupName)<>nil then
    begin
      ShowMsgOK('警告','字段列“'+GroupName+'.'+FieldName+'”已存在');
      exit;
    end;
  if Combo_AddAttrs.ItemIndex<0 then begin
    case ShowMsgYesNoAll('创建字段列('+fieldclassname+')','创建字段列“'+FieldName+'”之前先创建，需要先创建属性组“'+GroupName+'”，是否创建？') of
      'Yes':
        begin
          Button_AddAttrsClick(nil);//此处使用nil不需要再询问一次
          confirmed:=true;//之后也不用再询问
        end;
      else exit;
    end;
  end;
  if confirmed then begin
    if CurrentRTFP.AddField(FieldName,GroupName,ChosenFieldType,{size}poss)=nil then ShowMsgOK('警告','字段列创建失败');
  end else begin
    case ShowMsgYesNoAll('创建字段列('+fieldclassname+')','是否在属性组“'+GroupName+'”中创建名为“'+FieldName+'”的字段列？') of
      'Yes':if CurrentRTFP.AddField(FieldName,GroupName,ChosenFieldType,{size}poss)=nil then ShowMsgOK('警告','字段列创建失败');
      else exit;
    end;
  end;
  CurrentRTFP.FieldChange;
end;

procedure TFormDesktop.Button_AddKlassClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  if Edit_AddKlass.Caption='' then exit;
  case ShowMsgYesNoAll('创建分类','是否创建名为“'+Edit_AddKlass.Caption+'”的分类？') of
    'Yes':if CurrentRTFP.AddKlass(Edit_AddKlass.Caption,'.')=nil then ShowMsgOK('警告','分组创建失败');
    else exit;
  end;
end;

procedure TFormDesktop.Button_ClearKlassFilterClick(Sender: TObject);
var tmpKL:TKlass;
begin
  if ProjectInvalid then exit;
  for tmpKL in CurrentRTFP.KlassList do tmpKL.AllUnChecked:=true;
  CurrentRTFP.ClassChange;
  CurrentRTFP.RebuildMainGrid;
end;

procedure TFormDesktop.Button_FieldTypeClick(Sender: TObject);
begin
  //这里可以增加额外的字段类型设置
  ShowMsgOK('字段类型说明',
    '段落　　'+#9+'(Memo)         '+#9+'无限制长度的文本内容'+#13#10+
    '短字符串'+#9+'(String[16])   '+#9+'最大长度16的文本内容'+#13#10+
    '中字符串'+#9+'(String[72])   '+#9+'最大长度16的文本内容'+#13#10+
    '长字符串'+#9+'(String[240])  '+#9+'最大长度16的文本内容'+#13#10+
    '布尔　　'+#9+'(Boolean)      '+#9+'只有是与否的两个选项'+#13#10+
    '短整型　'+#9+'(SmallInt)     '+#9+'范围为-32768到32767'+#13#10+
    '长整型　'+#9+'(LargeInt)     '+#9+'18位十进制位的整数'+#13#10+
    '浮点型　'+#9+'(Float)        '+#9+'带小数点的数据'+#13#10+
    '时间　　'+#9+'(DateTime)     '+#9+'记录日期与时刻'+#13#10+
    '图像　　'+#9+'(Blob)         '+#9+'记录图像数据'
  );
end;

procedure TFormDesktop.Button_FormatEditLoadClick(Sender: TObject);
var filename:string;
    pi,pj:integer;
begin
  if ProjectInvalid then exit;
  SynEdit_FEMgr.Clear;
  with ListBox_FormatEditMgr do
    filename:=Items[ItemIndex];
  //SynEdit_FEMgr.Lines.LoadFromFile(CurrentRTFP.CurrentPathFull+'format'+_fsplit_+filename);
  CurrentRTFP.LoadFromFormatEdit(filename,SynEdit_FEMgr.Lines);
  with StringGrid_FormatEditLayout do
    begin
      for pi:=1 to ColCount-1 do
        for pj:=1 to RowCount-1 do
          Cells[pi,pj]:='';
    end;
end;

procedure TFormDesktop.Button_FormatEditPostAndNextClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  with CurrentRTFP do begin
    FormatEditDataPost(Selected_PID);
    if not PaperDS.EOF then begin
      PaperDS.Next;
      NodeViewValidate;
    end;
  end;
end;

procedure TFormDesktop.Button_FormatEditPostAndPrevClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  with CurrentRTFP do begin
    FormatEditDataPost(Selected_PID);
    if not PaperDS.BOF then begin
      PaperDS.Prior;
      NodeViewValidate;
    end;
  end;
end;

procedure TFormDesktop.Button_FormatEditPostClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  CurrentRTFP.FormatEditDataPost(Selected_PID);
end;

procedure TFormDesktop.Button_FormatEditRecoverClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  CurrentRTFP.FormatEditValidate(Selected_PID);
end;

procedure TFormDesktop.Button_FormatEditSaveClick(Sender: TObject);
var filename:string;
begin
  if ProjectInvalid then exit;
  with ListBox_FormatEditMgr do
    filename:=Items[ItemIndex];
  case ShowMsgYesNoAll('替换格式','是否替换'+filename+'中的样式内容？') of
    'Yes':;
    else ;
  end;
  //SynEdit_FEMgr.Lines.SaveToFile(CurrentRTFP.CurrentPathFull+'format'+_fsplit_+filename);
  CurrentRTFP.SaveToFormatEdit(filename,SynEdit_FEMgr.Lines);
end;

procedure TFormDesktop.Button_FormatEdit_AddClick(Sender: TObject);
var format_name:string;
begin
  if ProjectInvalid then exit;
  format_name:=ShowMsgEdit('新建样式','样式名称：','');
  if not (lowercase(ExtractFileExt(format_name)) = '.fmt') then format_name:=format_name+'.fmt';
  if format_name<>'' then
    if not CurrentRTFP.AddFormatEditNull(format_name) then
      ShowMsgOK('新建样式','创建失败！'+#13#10+'样式已存在或名称有无效字符。');
end;

procedure TFormDesktop.Button_FormatEdit_DelClick(Sender: TObject);
var index:integer;
    format_name:string;
begin
  if ProjectInvalid then exit;
  index:=ListBox_FormatEditMgr.ItemIndex;
  if index<0 then ShowMsgOK('删除样式','请先选择一个样式文件！');
  format_name:=ListBox_FormatEditMgr.Items[index];
  case ShowMsgYesNoAll('删除样式','是否删除样式以下文件：'+#13#10+'  '+format_name) of
    'Yes':if not CurrentRTFP.DelFormatEdit(format_name) then
            ShowMsgOK('删除样式','删除失败！'+#13#10+'未找到样式或样式文件被占用。');
    else ;
  end;
end;

procedure TFormDesktop.Button_FormatEdit_RenClick(Sender: TObject);
var index:integer;
    format_name,newname:string;
begin
  if ProjectInvalid then exit;
  index:=ListBox_FormatEditMgr.ItemIndex;
  if index<0 then begin
    ShowMsgOK('重命名样式','请先选择一个样式文件！');
    exit
  end;
  format_name:=ListBox_FormatEditMgr.Items[index];
  newname:=ShowMsgEdit('重命名样式','将样式“'+format_name+'”重命名为：',format_name);
  if (newname<>'') and (newname<>format_name) then
    if not CurrentRTFP.RenFormatEdit(format_name,newname) then
      ShowMsgOK('重命名样式','重命名失败！'+#13#10+'未找到样式或样式文件被占用。');
end;

procedure TFormDesktop.Button_helpClick(Sender: TObject);
begin
  ShowMsgOK('样式管理','在右侧窗格中选择一定范围的单元格，单击鼠标右键在此范围内创建字段项。'
                      +'用于在“编辑属性(样式)”标签卡中查看文献节点的具体字段数据。');
end;

procedure TFormDesktop.Button_MainFilterClick(Sender: TObject);
begin
  //温和的筛选方式
  if ProjectInvalid then exit;
  CurrentRTFP.RebuildMainGrid;
  if FShowWaitForm then FWaitForm.Show;
  CurrentRTFP.RunPerformance.Filter_Command:=Edit_DBGridMain_Filter.Caption;
  CurrentRTFP.TableFilter;
  if FShowWaitForm then FWaitForm.Hide;
end;

procedure TFormDesktop.Button_MainSorterClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  if FShowWaitForm then FWaitForm.Show;
  CurrentRTFP.RunPerformance.Sorter_Command:=Edit_DBGridMain_Sorter.Caption;
  CurrentRTFP.TableSorter;
  if FShowWaitForm then FWaitForm.Hide;
end;

procedure TFormDesktop.Button_NodeViewRecoverClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  NodeViewValidate;
end;

procedure TFormDesktop.CheckBox_KlassNotClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  CurrentRTFP.RunPerformance.Klass_Filter_NOT:=(Sender as TCheckBox).Checked;
  CurrentRTFP.RebuildMainGrid;
end;

procedure TFormDesktop.CheckBox_MainSorterAutoClick(Sender: TObject);
var not_checked:boolean;
begin
  not_checked:=not (Sender as TCheckBox).Checked;
  Self.Button_MainSorter.Enabled:=not_checked;
  Edit_DBGridMain_Sorter.Enabled:=not_checked;
  if ProjectInvalid then exit;
  CurrentRTFP.RunPerformance.Sorter_AutoRun:=(Sender as TCheckBox).Checked;
  if (Sender as TCheckBox).Checked then CurrentRTFP.TableSorter;
end;

procedure TFormDesktop.Edit_DBGridMain_SorterChange(Sender: TObject);
begin
  if ProjectInvalid then exit;
  CurrentRTFP.RunPerformance.Sorter_Command:=(Sender as TEdit).Caption;
  //if CurrentRTFP.RunPerformance.Sorter_AutoRun then CurrentRTFP.TableSorter;//你需要了
end;

procedure TFormDesktop.Edit_DBGridMain_SorterKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Shift = []) and (Key=13) then
    begin
      Button_MainSorterClick(nil);
    end;
end;

procedure TFormDesktop.MenuItem_ClassMgr_AddSubClick(Sender: TObject);
var tmpNode:TListCheckNode;
    tmpKL:TKlass;
    filter:boolean;
    klassname:string;
begin
  if ProjectInvalid then exit;
  tmpNode:=AListView_Klass.Selected;
  if tmpNode=nil then exit;
  tmpKL:=TKlass(tmpNode.Data);
  if tmpKL=nil then exit;
  {
  filter:=tmpKL.FilterEnabled;
  case ShowMsgYesNoAll('删除分类','是否删除“'+tmpKL.Name+'”分类？') of
    'Yes':CurrentRTFP.DeleteKlass(tmpKL.Name);
    else exit;
  end;
  if filter then CurrentRTFP.RebuildMainGrid;
  }
  klassname:={InputBox}ShowMsgEdit('新建分类','分类名称：','');
  if klassname<>'' then begin
    //pathname:=tmpKL.FullPath+''+ExtractFilePath(klassname);
    //klassname:=ExtractFileName(klassname);
    CurrentRTFP.AddKlass(klassname,tmpKL);
  end;
end;

procedure TFormDesktop.MenuItem_ClassMgr_Danger_DeletePapersClick(
  Sender: TObject);
var tmpNode:TListCheckNode;
    tmpKL:TKlass;
    PIDs:TStringList;
    PID:RTFP_ID;
begin
  if ProjectInvalid then exit;
  tmpNode:=AListView_Klass.Selected;
  if tmpNode=nil then exit;
  tmpKL:=TKlass(tmpNode.Data);
  if tmpKL=nil then exit;
  case ShowMsgOK('不可恢复警告','删除分类中的文献不可恢复，请再三确认分类中所有文献均需要删除。') of
    'OK':;
    else exit;
  end;
  PIDs:=TStringList.Create;
  AllState.Enable;
  try
    CurrentRTFP.GetPIDList_Klass(PIDs,tmpKL);
    CurrentRTFP.BeginUpdate;
    for PID in PIDs do CurrentRTFP.DeletePaper(PID);
    CurrentRTFP.EndUpdate;
  finally
    PIDs.Free;
    AllState.Disable;
  end;
  CurrentRTFP.ClassChange;
  CurrentRTFP.RecordChange;
end;

procedure TFormDesktop.MenuItem_CopyPaperClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  with CurrentRTFP.GetJSON_Paper(Selected_PID) do begin
    ClipBoard.AsText:=FormatJSON;
    Clear;
    Free;
  end;
end;

procedure TFormDesktop.MenuItem_DBGC_ASClick(Sender: TObject);
var sort_syntax,field_name:string;
begin
  if ProjectInvalid then exit;
  field_name:=DBGrid_Main.DataSource.DataSet.Fields[LastDBGridPos.x-1].FieldName;
  sort_syntax:=Edit_DBGridMain_Sorter.Caption;
  Edit_DBGridMain_Sorter.Caption:='+ "'+field_name+'" '+sort_syntax;
  Application.ProcessMessages;
  CurrentRTFP.TableSorter;
end;

procedure TFormDesktop.MenuItem_DBGC_CalcClick(Sender: TObject);
var tmpAF:TAttrsField;
begin
  if ProjectInvalid then exit;
  tmpAF:=TAttrsField(CurrentRTFP.PaperDSFieldDefs[LastDBGridPos.x-1]);
  if tmpAF=nil then begin ShowMsgOK('编辑字段值','该字段不支持编辑。');exit end;
  Form_CalcField.Call(tmpAF);
  SetFocus;
end;

procedure TFormDesktop.MenuItem_DBGC_CRClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  Edit_DBGridMain_Sorter.Caption:='"PID"';
  Application.ProcessMessages;
  CurrentRTFP.TableSorter;
end;

procedure TFormDesktop.MenuItem_DBGC_DSClick(Sender: TObject);
var sort_syntax,field_name:string;
begin
  if ProjectInvalid then exit;
  field_name:=DBGrid_Main.DataSource.DataSet.Fields[LastDBGridPos.x-1].FieldName;
  sort_syntax:=Edit_DBGridMain_Sorter.Caption;
  Edit_DBGridMain_Sorter.Caption:='- "'+field_name+'" '+sort_syntax;
  Application.ProcessMessages;
  CurrentRTFP.TableSorter;
end;

procedure TFormDesktop.MenuItem_DBGC_Export_arrayClick(Sender: TObject);
var FieldTitle:string;
begin
  FieldTitle:=PopupMenu_MainDBGrid_Column.Items[0].Caption;
  ClipBoard.AsText:=CurrentRTFP.ExportDSFieldToArray(FieldTitle);
end;

procedure TFormDesktop.MenuItem_DBGC_Export_linesClick(Sender: TObject);
var FieldTitle:string;
begin
  FieldTitle:=PopupMenu_MainDBGrid_Column.Items[0].Caption;
  ClipBoard.AsText:=CurrentRTFP.ExportDSFieldToLines(FieldTitle);
end;

procedure TFormDesktop.MenuItem_DBGC_Export_setClick(Sender: TObject);
var FieldTitle:string;
begin
  FieldTitle:=PopupMenu_MainDBGrid_Column.Items[0].Caption;
  ClipBoard.AsText:=CurrentRTFP.ExportDSFieldToLinesSet(FieldTitle);
end;

procedure TFormDesktop.MenuItem_DBGC_FieldOptClick(Sender: TObject);
var tmpAF:TAttrsField;
begin
  if ProjectInvalid then exit;
  tmpAF:=TAttrsField(CurrentRTFP.PaperDSFieldDefs[LastDBGridPos.x-1]);
  if Form_FieldChange.Call(tmpAF)=mrOK then CurrentRTFP.RebuildMainGrid;
  SetFocus;
end;

procedure TFormDesktop.MenuItem_DBGE_csvClick(Sender: TObject);
begin
  ClipBoard.AsText:=CurrentRTFP.ExportDSToCSVOrTSV(',');
end;

procedure TFormDesktop.MenuItem_DBGE_jsonClick(Sender: TObject);
begin
  ClipBoard.AsText:=CurrentRTFP.ExportDSToFormatJSON();
end;

procedure TFormDesktop.MenuItem_DBGE_python_dictClick(Sender: TObject);
begin
  ClipBoard.AsText:=CurrentRTFP.ExportDSToRubyOrPython(':');
end;

procedure TFormDesktop.MenuItem_DBGE_ruby_hashClick(Sender: TObject);
begin
  ClipBoard.AsText:=CurrentRTFP.ExportDSToRubyOrPython('=>');
end;

procedure TFormDesktop.MenuItem_DBGE_tsvClick(Sender: TObject);
begin
  ClipBoard.AsText:=CurrentRTFP.ExportDSToCSVOrTSV(#9);
end;

procedure TFormDesktop.MenuItem_Edit_NewPaper_FilesClick(Sender: TObject);
begin
  Action_ImportPapers;
end;

procedure TFormDesktop.MenuItem_Edit_NewPaper_RefsClick(Sender: TObject);
begin
  Form_CiteTrans.Call(false,true);//changeable选false是因为创建后关闭
end;

procedure TFormDesktop.MenuItem_Edit_NewPaper_VoidClick(Sender: TObject);
begin
  Action_NewPaper;
end;

procedure TFormDesktop.MenuItem_Edit_NewPaper_WebLnkClick(Sender: TObject);
begin
  Action_NewPaper_WebLnk;
end;

procedure TFormDesktop.MenuItem_FieldMgr_CopyClick(Sender: TObject);
var tmpNode:TListCheckNode;
    tmpJSON:TJSONData;
begin
  if ProjectInvalid then exit;
  tmpNode:=AListView_Attrs.Selected;
  if tmpNode=nil then exit;
  if tmpNode.Data is TAttrsGroup then
    begin
      tmpJSON:=CurrentRTFP.GetJSON_Attrs(tmpNode.Data as TAttrsGroup);
      Clipboard.AsText:=tmpJSON.FormatJSON;
      tmpJSON.Clear;
      tmpJSON.Free;
    end
  else if tmpNode.Data is TAttrsField then
    begin
      tmpJSON:=CurrentRTFP.GetJSON_Field(tmpNode.Data as TAttrsField);
      Clipboard.AsText:=tmpJSON.FormatJSON;
      tmpJSON.Clear;
      tmpJSON.Free;
    end
  else assert(false,'ACL_TreeNode中有unexpected的类型对象');
end;

procedure TFormDesktop.MenuItem_PastePaperClick(Sender: TObject);
var tmpJSON:TJSONData;
    APID:RTFP_ID;
begin
  if ProjectInvalid then exit;
  APID:=Selected_PID;
  case ShowMsgYesNoAll('覆盖节点属性','文献节点可能包含字段信息，是否覆盖原有属性？') of
    'No':exit;
  end;
  tmpJSON:=GetJSON(ClipBoard.AsText);
  try
    try
      CurrentRTFP.SetJSON_Paper(APID,tmpJSON);
    except
      ShowMsgOK('粘贴文献节点','节点属性数据出错，属性粘贴未完成，请手动检查粘贴结果。');
    end;
  finally
    tmpJSON.Free;
  end;
end;

procedure TFormDesktop.MenuItem_project_unzipClick(Sender: TObject);
begin
  if assigned(CurrentRTFP) then
  begin
    if CurrentRTFP.IsOpen then CurrentRTFP.Close;
    CurrentRTFP.Free;
  end;
  CurrentRTFP:=TRTFP.Create(FormDesktop);
  CurrentRTFP.SetAuf(Frame_AufScript1.Auf);
  Self.EventLink(CurrentRTFP);
  OpenDialog_Project.Filter:='RTFP压缩工程文件(*.ztfp)|*.ztfp|ZIP压缩文件(*.ztfp.zip)|*.ztfp.zip|所有文件|*.*';
  OpenDialog_Project.DefaultExt:='*.ztfp';
  OpenDialog_Project.Title:='解压导入';
  OpenDialog_Project.Options:=[ofEnableSizing];
  if Self.OpenDialog_Project.Execute then begin
    Form_NewProject.Caption:='选择工程解压位置';
    Form_NewProject.ShowModal;
    SetFocus;
    Form_NewProject.Caption:='新建工程';
    if not CurrentRTFP.IsOpen then exit;

    if FShowWaitForm then FWaitForm.Show;
    CurrentRTFP.ZTFP_Importer(Self.OpenDialog_Project.FileName);
    if FShowWaitForm then FWaitForm.Hide;
    OptionLink(CurrentRTFP);
  end;
end;

procedure TFormDesktop.MenuItem_project_zipClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  SaveDialog_project.Filter:='RTFP压缩工程文件(*.ztfp)|*.ztfp|ZIP压缩文件(*.ztfp.zip)|*.ztfp.zip|所有文件|*.*';
  SaveDialog_project.DefaultExt:='*.ztfp';
  SaveDialog_Project.Title:='压缩导出';
  if Self.SaveDialog_Project.Execute then begin
    if FShowWaitForm then FWaitForm.Show;
    CurrentRTFP.ZTFP_Exporter(Self.SaveDialog_Project.FileName);
    if FShowWaitForm then FWaitForm.Hide;
  end;
end;

procedure TFormDesktop.PageControl_FilterResize(Sender: TObject);
begin
  Button_AddKlass.Width:=Button_AddKlass.Height;
  Button_AddField.Width:=Button_AddField.Height;
  Button_AddAttrs.Width:=Button_AddAttrs.Height;
  Button_FieldType.Width:=Button_FieldType.Height;
end;

procedure TFormDesktop.RadioButton_KlassANDClick(Sender: TObject);
var is_and:boolean;
begin
  if ProjectInvalid then exit;
  is_and:=(Sender as TRadioButton).Checked;
  RadioButton_KlassOR.Checked:=not is_and;
  CurrentRTFP.RunPerformance.Klass_Filter_AND:=is_and;
  CurrentRTFP.RebuildMainGrid;
end;

procedure TFormDesktop.RadioButton_KlassORClick(Sender: TObject);
var is_and:boolean;
begin
  if ProjectInvalid then exit;
  is_and:=not (Sender as TRadioButton).Checked;
  RadioButton_KlassAND.Checked:=is_and;
  CurrentRTFP.RunPerformance.Klass_Filter_AND:=is_and;
  CurrentRTFP.RebuildMainGrid;
end;

procedure TFormDesktop.CheckBox_MainFilterAutoClick(Sender: TObject);
var not_checked:boolean;
begin
  not_checked:=not (Sender as TCheckBox).Checked;
  Button_MainFilter.Enabled:=not_checked;
  Edit_DBGridMain_Filter.Enabled:=not_checked;
  if ProjectInvalid then exit;
  CurrentRTFP.RunPerformance.Filter_AutoRun:=(Sender as TCheckBox).Checked;
  if (Sender as TCheckBox).Checked then CurrentRTFP.TableFilter;
end;



procedure TFormDesktop.DBGrid_MainCellClick(Column: TColumn);
begin
  NodeViewValidate;
end;

procedure TFormDesktop.DBGrid_MainColumnSized(Sender: TObject);
begin
  Self.DBGridColumnAllocating(Sender);
end;

procedure TFormDesktop.DBGrid_MainDragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
  //
end;

procedure TFormDesktop.DBGrid_MainDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept:=false;
end;

procedure TFormDesktop.DBGrid_MainDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var tmpFD:TFieldDef;
    tmpA:Pointer;
    tmpCL:TColor;
    tmpFontCL:TColor;
    vert_space:integer;
    tmpDBG:TDBGrid;
    trimRect:TRect;
    left_adjust:TTextStyle;

  function min(a,b:integer):integer;
  begin
    if a>b then result:=b else result:=a;
  end;

begin
  tmpFD:=Column.Field.FieldDef;
  tmpA:=CurrentRTFP.PaperDSFieldDefs.Items[DataCol];
  if tmpA=nil then exit;

  tmpCL:=$ff000000;
  if TObject(tmpA) is TAttrsField then
    tmpCL:=TAttrsField(tmpA).FieldDisplayOption.GetFieldColor(Column.Field);

  if (gdSelected in State) or (gdRowHighlight in State) then begin
    tmpCL:=clHighlight;
    tmpFontCL:=clHighlightText;
  end else begin
    if tmpCL and $ff000000 = $ff000000 then tmpCL:=clDefault;
    tmpFontCL:=clBlack;
  end;

  tmpDBG:=Sender as TDBGrid;
  tmpDBG.Canvas.Brush.Color:=tmpCL;
  tmpDBG.Canvas.Pen.Color:=tmpFontCL;
  tmpDBG.Canvas.FillRect(Rect);
  vert_space:=Rect.Height-tmpDBG.Canvas.GetTextHeight('W');
  left_adjust.Alignment:=taLeftJustify;

  trimRect:=Classes.Rect(Rect.Left,Rect.Top,Rect.Right-vert_space,Rect.Bottom);
  case tmpFD.DataType of
    ftMemo:
      begin
        tmpDBG.Canvas.TextRect(trimRect,trimRect.Left+vert_space div 2,trimRect.Top,Column.Field.AsString);
      end;
    ftFloat,ftInteger,ftLargeint,ftSmallint:
      begin
        tmpDBG.Canvas.TextRect(trimRect,trimRect.Left+vert_space div 2,trimRect.Top,Column.Field.AsString,left_adjust);
      end;
    //ftBlob:
    //  begin
    //    //啥没改，图片字段转成文件形式以后这么做的意义也不大了
    //  end;
    else
      begin
        (Sender as TDBGrid).DefaultDrawColumnCell(Rect,DataCol,Column,State);
        //至少用BLOB和blob可以区分有没有赋值
      end;
  end;

end;

procedure TFormDesktop.DBGrid_MainKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //主表会和FormatEdit的Panel抢事件
  if ssCtrl in Shift then
    begin
      case Key of
        76:CurrentRTFP.OpenPaperLink(Selected_PID);//L
        79:CurrentRTFP.OpenPaper(Selected_PID);//O
        68:CurrentRTFP.OpenPaperDir(Selected_PID);//D
        83:if not ProjectInvalid then CurrentRTFP.Save;//S
        82:begin
          case OptionMap.Shortcut_CtrlR of
            mgsc_cc_title:ClipBoard.AsText:=Self.Selected_Title;
            mgsc_cc_path:ClipBoard.AsText:=Self.Selected_FileName;
            mgsc_cc_link:ClipBoard.AsText:=Self.Selected_Link;
            mgsc_cc_gb7714:ClipBoard.AsText:=CurrentRTFP.GetGBT7714(Selected_PID);
            mgsc_cc_apa:ClipBoard.AsText:=CurrentRTFP.GetAPA(Selected_PID);
            mgsc_cc_mla:ClipBoard.AsText:=CurrentRTFP.GetMLA(Selected_PID);
            mgsc_cc_order:ClipBoard.AsText:=CurrentRTFP.GetRef_InOrder(Selected_PID);
            mgsc_cc_auyear:ClipBoard.AsText:=CurrentRTFP.GetRef_AurYear(Selected_PID);
            else ;
          end;
        end;//R
      end;
    end;
  //方向键时刷新主表
  case Key of
    37,38,39,40:NodeViewValidate;
  end;
end;

procedure TFormDesktop.DBGrid_MainMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ((ssShift in Shift) or (ssCtrl in Shift)) and (Button = mbLeft) then begin
    UIState.DragShift:=Shift;
    UIState.DragButton:=Button;
    Self.BeginDrag(True);
  end;
end;

procedure TFormDesktop.DBGrid_MainMouseEnter(Sender: TObject);
begin
  ShowStatusHelper('按Ctrl拖动至分类节点加入分类，按Shift拖动至分类节点排除出分类。');
end;

procedure TFormDesktop.DBGrid_MainMouseLeave(Sender: TObject);
begin
  ShowStatusHelper('');
end;

procedure TFormDesktop.DBGrid_MainMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var vCell:TGridCoord;
    vGrid:TDBGrid;
begin
  if (Shift=[]) and (Button=mbRight) then begin
    vGrid:=Sender as TDBGrid;
    if vGrid.DataSource.DataSet=nil then exit;
    with vGrid do begin
      vCell:=MouseCoord(X,Y);
      LastDBGridPos:=vCell;
      if vCell.y=0 then begin
        if vCell.x>0 then begin
          PopupMenu_MainDBGrid_Column.Items[0].Caption:=Columns[vCell.x-1].FieldName;
          PopupMenu_MainDBGrid_Column.PopUp;
        end else begin
          PopupMenu_MainDBGrid_Export.PopUp;
        end;
      end else begin
        PopupMenu_MainDBGrid.PopUp;
      end;

    end;
  end;
end;

procedure TFormDesktop.DBGrid_MainMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
const row_step=12;//这个之后加一个设置，滚轮一次位移多少行
var current_row,row_count:longint;
begin
  if DBGrid_Main.DataSource.DataSet=nil then exit;
  current_row:=DBGrid_Main.DataSource.DataSet.RecNo;
  row_count:=DBGrid_Main.DataSource.DataSet.RecordCount;
  if WheelDelta<0 then begin
    current_row:=current_row+row_step;
    if current_row>row_count then current_row:=row_count;
  end else begin
    current_row:=current_row-row_step;
    if current_row<0 then current_row:=0;
    //这里目前存在一个bug，高亮行不能归为0，对功能影响不大
  end;
  DBGrid_Main.DataSource.DataSet.RecNo:=current_row;
  Handled:=true;//禁用滚轮改变高亮行这个默认行为
end;

procedure TFormDesktop.Edit_DBGridMain_FilterChange(Sender: TObject);
begin
  //受限后的激进筛选方式
  if ProjectInvalid then exit;
  CurrentRTFP.RunPerformance.Filter_Command:=(Sender as TEdit).Caption;
  if CurrentRTFP.RunPerformance.Filter_AutoRun then CurrentRTFP.RebuildMainGrid;
end;

procedure TFormDesktop.Edit_DBGridMain_FilterKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Shift = []) and (Key=13) then
    begin
      Button_MainFilterClick(nil);
    end;
end;

procedure TFormDesktop.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  FormOptions.SaveOptionToReg;
  FormOptions.Free;
  FWaitForm.Free;
  FFormatEdit_Highlighter.Free;
  //SyncTimer.Free;
end;


procedure TFormDesktop.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if ProjectInvalid then exit;
  if not CurrentRTFP.Close then CanClose:=false;

end;


end.

