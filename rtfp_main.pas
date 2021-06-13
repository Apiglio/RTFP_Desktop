unit RTFP_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, dbf, sqldb, mssqlconn, FileUtil, Forms,
  Controls, Graphics, Dialogs, ComCtrls, Menus, ExtCtrls, DBGrids, ValEdit,
  StdCtrls, DbCtrls, LazUTF8, LvlGraphCtrl,
  Clipbrd, LCLType,

  AufScript_Frame, ACL_ListView, TreeListView, lNetComponents,

  RTFP_definition, rtfp_constants, simpleipc, Types;

const
  C_VERSION_NUMBER  = '0.1.1-alpha.14';//如果增加了CheckAttrs的机制，请改成0.1.2
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
    ACL_ListView_Klass: TACL_ListView;
    ACL_ListView_Attrs: TACL_ListView;
    Button_FormatEditPost: TButton;
    Button_FormatEditRecover: TButton;
    Button_FormatEditLock: TButton;
    Button_MainFilter: TButton;
    Button_temp: TButton;
    Button_Project_NodeView_Fresh: TButton;
    Button_FmtCmt_Post: TButton;
    Button_FmtCmt_Recover: TButton;
    Button_NodeViewPost: TButton;
    Button_NodeViewRecover: TButton;
    Image_IsMemo: TImage;
    ComboBox_AttrName: TComboBox;
    ComboBox_FieldName: TComboBox;
    DataSource_Main: TDataSource;
    DBGrid_Main: TDBGrid;
    Edit_DBGridMain_Filter: TEdit;
    Frame_AufScript1: TFrame_AufScript;
    Image_PDF_View: TImage;
    Label_FmtCmtPID: TLabel;
    Label_MainFilter: TLabel;
    LvlGraphControl: TLvlGraphControl;
    MainMenu: TMainMenu;
    Memo_FmtCmt: TMemo;
    MenuItem_AdvOpen_PDF: TMenuItem;
    MenuItem_AdvOpen_CAJ: TMenuItem;
    MenuItem_AdvOpen_Dir: TMenuItem;
    MenuItem_AdvOpen_Link: TMenuItem;
    MenuItem_AdvOpen: TMenuItem;
    MenuItem_ClassTool: TMenuItem;
    MenuItem_Klass: TMenuItem;
    MenuItem_BasicReferences: TMenuItem;
    MenuItem_DelePaper: TMenuItem;
    MenuItem_pop_div03: TMenuItem;
    MenuItem_Tree_Into: TMenuItem;
    MenuItem_Tree_Back: TMenuItem;
    MenuItem_pop_div02: TMenuItem;
    MenuItem_Tree: TMenuItem;
    MenuItem_main_div02: TMenuItem;
    MenuItem_main_div03: TMenuItem;
    MenuItem_main_div01: TMenuItem;
    MenuItem_Mark_IsRead_Yes: TMenuItem;
    MenuItem_Mark_IsRead_No: TMenuItem;
    MenuItem_Mark: TMenuItem;
    MenuItem_pop_div01: TMenuItem;
    MenuItem_OpenDefault: TMenuItem;
    MenuItem_project_recent: TMenuItem;
    MenuItem_ImportFromOther: TMenuItem;
    MenuItem_ExportToOther: TMenuItem;
    MenuItem_CiteTool: TMenuItem;
    MenuItem_main_div05: TMenuItem;
    MenuItem_project_close: TMenuItem;
    MenuItem_project_check: TMenuItem;
    MenuItem_main_div04: TMenuItem;
    MenuItem_project_saveas: TMenuItem;
    MenuItem_project_save: TMenuItem;
    MenuItem_option_help: TMenuItem;
    MenuItem_option_about: TMenuItem;
    MenuItem_option_setting: TMenuItem;
    MenuItem_project_unzip: TMenuItem;
    MenuItem_project_zip: TMenuItem;
    MenuItem_project_new: TMenuItem;
    MenuItem_edit_newNote: TMenuItem;
    MenuItem_edit_newClass: TMenuItem;
    MenuItem_edit_newPaper: TMenuItem;
    MenuItem_option: TMenuItem;
    MenuItem_project: TMenuItem;
    MenuItem_edit: TMenuItem;
    MenuItem_project_open: TMenuItem;
    OpenDialog_Project: TOpenDialog;
    PageControl_Filter: TPageControl;
    PageControl_Node: TPageControl;
    PageControl_Project: TPageControl;
    Panel_DBGridMain: TPanel;
    ScrollBox_Node_FormatEdit: TScrollBox;
    PopupMenu_MainDBGrid: TPopupMenu;
    SaveDialog_project: TSaveDialog;
    Splitter_LeftH: TSplitter;
    Splitter_PropertiesV: TSplitter;
    Splitter_RightH: TSplitter;
    Splitter_MainV: TSplitter;
    StaticText_AttrNameCombo: TStaticText;
    StaticText_FieldNameCombo: TStaticText;
    StatusBar: TStatusBar;
    TabSheet_Node_FormatEdit: TTabSheet;
    TabSheet_Filter_Klass: TTabSheet;
    TabSheet_Filter_Field: TTabSheet;
    TabSheet_Project_NodeView: TTabSheet;
    TabSheet_FmtCmt: TTabSheet;
    TabSheet_Project_Properties: TTabSheet;
    TabSheet_Node_PDF: TTabSheet;
    TabSheet_Node_View: TTabSheet;
    TabSheet_Project_AufScript: TTabSheet;
    TabSheet_Project_DataGrid: TTabSheet;
    PropertiesValueListEditor: TValueListEditor;
    ValueListEditor_NodeView: TValueListEditor;
    procedure ACL_ListView_AttrsNodeChecked(Sender: TObject; Item: TACL_TreeNode
      );
    procedure ACL_ListView_KlassNodeChecked(Sender: TObject; Item: TACL_TreeNode
      );
    procedure Button_FmtCmt_PostClick(Sender: TObject);
    procedure Button_FmtCmt_RecoverClick(Sender: TObject);
    procedure Button_MainFilterClick(Sender: TObject);
    procedure Button_NodeViewAddAttrClick(Sender: TObject);
    procedure Button_NodeViewPostClick(Sender: TObject);
    procedure Button_NodeViewRecoverClick(Sender: TObject);
    procedure Button_Project_NodeView_FreshClick(Sender: TObject);
    procedure Button_tempClick(Sender: TObject);
    procedure CheckListBox_MainAttrFilterClickCheck(Sender: TObject);
    procedure ComboBox_AttrNameChange(Sender: TObject);
    procedure ComboBox_FieldNameChange(Sender: TObject);
    procedure DataSource_MainUpdateData(Sender: TObject);
    procedure DBGrid_MainCellClick(Column: TColumn);
    procedure DBGrid_MainKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBGrid_MainMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure Edit_DBGridMain_FilterChange(Sender: TObject);
    procedure Edit_DBGridMain_FilterKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure FormResize(Sender: TObject);
    procedure Memo_FmtCmtChange(Sender: TObject);
    procedure MenuItem_AdvOpen_CAJClick(Sender: TObject);
    procedure MenuItem_AdvOpen_DirClick(Sender: TObject);
    procedure MenuItem_AdvOpen_LinkClick(Sender: TObject);
    procedure MenuItem_AdvOpen_PDFClick(Sender: TObject);
    procedure MenuItem_BasicReferencesClick(Sender: TObject);
    procedure MenuItem_CiteToolClick(Sender: TObject);
    procedure MenuItem_ClassToolClick(Sender: TObject);
    procedure MenuItem_DelePaperClick(Sender: TObject);
    procedure MenuItem_KlassClick(Sender: TObject);
    procedure MenuItem_Mark_IsRead_NoClick(Sender: TObject);
    procedure MenuItem_Mark_IsRead_YesClick(Sender: TObject);
    procedure MenuItem_OpenAsCajClick(Sender: TObject);
    procedure MenuItem_OpenAsPdfClick(Sender: TObject);
    procedure MenuItem_OpenDefaultClick(Sender: TObject);
    procedure MenuItem_OpenDirClick(Sender: TObject);
    procedure MenuItem_OpenLinkClick(Sender: TObject);
    procedure MenuItem_option_aboutClick(Sender: TObject);
    procedure MenuItem_project_closeClick(Sender: TObject);
    procedure MenuItem_project_newClick(Sender: TObject);
    procedure MenuItem_project_openClick(Sender: TObject);
    procedure MenuItem_project_saveasClick(Sender: TObject);
    procedure MenuItem_project_saveClick(Sender: TObject);
    procedure PageControl_NodeChange(Sender: TObject);
    procedure TabSheet_Project_AufScriptResize(Sender: TObject);
    procedure PropertiesValueListEditorEditingDone(Sender: TObject);

  private
    FWaitForm:TForm;

  private
    FLayoutMode:integer;
  protected
    procedure SetLayoutMode(AModeIndex:integer);
  public
    property LayoutMode:integer read FLayoutMode write SetLayoutMode;

  //private
  public
    function Selected_PID:RTFP_ID;//根据DBGrid_Main的选择返回PID
    function Selected_FileName:string;//根据DBGrid_Main的选择返回文件名

  public
    //RTFP类事件，Sender参数为TRTFP类
    procedure EventLink(Sender:TRTFP);//链接所有事件

    procedure Validate(Sender:TObject);//更新显示
    procedure ClassListValidate(Sender:TObject);//分类更新时的操作
    procedure FieldListValidate(Sender:TObject);//分类更新时的操作
    procedure MainGridValidate(Sender:TObject);

    procedure FirstEdit(Sender:TObject);//工程第一次编辑
    procedure Clear(Sender:TObject);//清空


    procedure ProjectOpenDone(Sender:TObject);//工程打开或新建
    procedure ProjectCloseDone(Sender:TObject);//工程关闭
    procedure ProjectSaveDone(Sender:TObject);//工程保存

    procedure DBGridColumnAdjusting(Sender:TObject);

    //以下与下半部分的NodeView有关
    procedure ViewPdfValidate;
    //预览pdf
    procedure NodeViewValidate;
    //根据当前DBGrid_Main的选择状态更新NodeView显示
    procedure NodeViewDataPost;
    //将NodeView的数据提交到工程中

  end;

var
  FormDesktop: TFormDesktop;
  CurrentRTFP:TRTFP;
  LocalPath:string;

implementation
uses form_new_project, form_cite_trans, form_classmanager, form_import,
     rtfp_field, rtfp_class;

{$R *.lfm}

{ TFormDesktop }

procedure TFormDesktop.EventLink(Sender:TRTFP);//链接所有事件
begin
  //Sender.onNewDone:=@ProjectOpenDone;
  Sender.onOpenDone:=@ProjectOpenDone;
  Sender.onFirstEdit:=@FirstEdit;
  Sender.onSaveDone:=@ProjectSaveDone;
  Sender.onCloseDone:=@ProjectCloseDone;
  Sender.onChange:=@Validate;
  Sender.onClassChange:=@ClassListValidate;
  Sender.onFieldChange:=@FieldListValidate;
  //Sender.OnTableValidateDone:=@DBGridColumnAdjusting;
end;

procedure TFormDesktop.Validate(Sender:TObject);
var changed_str:string;
begin
  if (Sender as TRTFP).IsChanged then changed_str:=' *'
  else changed_str:='';
  //标题
  if (Sender as TRTFP).Title <> '' then
    Self.Caption:=C_SOFTWARE_NAME+' - '+(Sender as TRTFP).Title + changed_str
  else
    Self.Caption:=C_SOFTWARE_NAME;
  //工程信息 标签页
  CurrentRTFP.ProjectPropertiesValidate(Self.PropertiesValueListEditor);
  //文献节点 标签页
  MainGridValidate(nil);

end;

procedure TFormDesktop.ClassListValidate(Sender:TObject);
begin
  CurrentRTFP.KlassListValidate(ACL_ListView_Klass);
end;

procedure TFormDesktop.FieldListValidate(Sender:TObject);
begin
  CurrentRTFP.FieldListValidate(ACL_ListView_Attrs);
end;

procedure TFormDesktop.MainGridValidate(Sender:TObject);
begin
  Self.DBGrid_Main.Visible:=false;
  FWaitForm.Show;
  CurrentRTFP.TableValidate;
  FWaitForm.Hide;
  Self.DBGrid_Main.Visible:=true;
end;

procedure TFormDesktop.FirstEdit(Sender:TObject);
begin
  Self.Caption:=C_SOFTWARE_NAME+' - '+(Sender as TRTFP).Title + ' *';
  Self.MenuItem_project_save.Enabled:=true;
end;

procedure TFormDesktop.Clear(Sender:TObject);
begin
  Self.Caption:=C_SOFTWARE_NAME;
  Self.PropertiesValueListEditor.Clear;
  ACL_ListView_Attrs.Clear;
  ACL_ListView_Klass.Clear;
  ComboBox_AttrName.Clear;
  ComboBox_FieldName.Clear;
end;

procedure TFormDesktop.ProjectOpenDone(Sender:TObject);
begin

  //文献节点选项卡
  Self.DataSource_Main.DataSet:=CurrentRTFP.PaperDS;

  //分类节点选项卡
  ClassListValidate(nil);

  //FmtCmt选项卡
  Self.ComboBox_AttrName.Clear;
  Self.Button_FmtCmt_Post.Enabled:=false;
  CurrentRTFP.AttrNameValidate(ComboBox_AttrName.Items);

  Self.Validate(Sender);
  CurrentRTFP.FormatEditBuild(Self.ScrollBox_Node_FormatEdit,'test');


  Self.MenuItem_project_new.Enabled:=false;
  Self.MenuItem_project_open.Enabled:=false;
  Self.MenuItem_project_save.Enabled:=false;
  Self.MenuItem_project_saveas.Enabled:=true;
  Self.MenuItem_project_close.Enabled:=true;
  Self.MenuItem_project_zip.Enabled:=true;
  Self.MenuItem_project_unzip.Enabled:=false;
  Self.MenuItem_project_check.Enabled:=true;

end;

procedure TFormDesktop.ProjectCloseDone(Sender:TObject);
begin
  Self.Clear(Sender);
  CurrentRTFP.FormatEditClear(Self.ScrollBox_Node_FormatEdit);

  //文献节点选项卡
  Self.DataSource_Main.DataSet:=nil;

  //分类节点选项卡
  ACL_ListView_Klass.Clear;

  //FmtCmt选项卡
  Self.ComboBox_AttrName.Clear;
  Self.ComboBox_FieldName.Clear;

  Self.MenuItem_project_new.Enabled:=true;
  Self.MenuItem_project_open.Enabled:=true;
  Self.MenuItem_project_save.Enabled:=false;
  Self.MenuItem_project_saveas.Enabled:=false;
  Self.MenuItem_project_close.Enabled:=false;
  Self.MenuItem_project_zip.Enabled:=false;
  Self.MenuItem_project_unzip.Enabled:=true;
  Self.MenuItem_project_check.Enabled:=false;

end;

procedure TFormDesktop.ProjectSaveDone(Sender:TObject);
begin
  Self.Validate(Sender);
  Self.MenuItem_project_save.Enabled:=false;
end;

procedure TFormDesktop.DBGridColumnAdjusting(Sender:TObject);
var index:integer;
begin
  with DBGrid_Main do
  for index:=0 to Columns.Count-1 do
    begin
      Columns[index].Width:=TRTFP.FieldOptWidth(Columns[index].Field.FieldDef);
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

function TFormDesktop.Selected_FileName:string;
begin
  result:='';
  if DBGrid_Main.DataSource.DataSet=nil then exit;
  if not DBGrid_Main.DataSource.DataSet.Active then exit;
  result:=DBGrid_Main.DataSource.DataSet.Fields.FieldByName(_Col_Paper_FileName_).AsString;
end;

procedure TFormDesktop.ViewPdfValidate;
begin
  //
end;

procedure TFormDesktop.NodeViewValidate;
var PID:RTFP_ID;
    attrNa,fieldNa:string;
begin
  PID:=Selected_PID;
  if PID='000000' then exit;
  StatusBar.Panels[0].Text:=PID;

  //节点字段
  //ValueListEditor_NodeView.Clear;
  CurrentRTFP.NodeViewValidate(PID,ValueListEditor_NodeView);

  //FmtCmt
  if (ComboBox_AttrName.ItemIndex>=0) and (ComboBox_FieldName.ItemIndex>=0) then begin
    attrNa:=ComboBox_AttrName.Items[ComboBox_AttrName.ItemIndex];
    fieldNa:=ComboBox_FieldName.Items[ComboBox_FieldName.ItemIndex];
    if Button_FmtCmt_Post.Enabled then
      begin
        //这表明FmtCmt没有保存
        case MessageDlg('FmtCmt未保存','更新FmtCmt会覆盖当前的修改，是否先保存此修改？',mtInformation,[mbYes,mbNo],0) of
          rnmbYes:CurrentRTFP.FmtCmtDataPost(Label_FmtCmtPID.Caption,attrNa,fieldNa,Memo_FmtCmt);
          rnmbNo:;
        end;
      end;
    CurrentRTFP.FmtCmtValidate(PID,attrNa,fieldNa,Memo_FmtCmt);
    Label_FmtCmtPID.Caption:=PID;
    Button_FmtCmt_Post.Enabled:=false;
  end;
end;

procedure TFormDesktop.NodeViewDataPost;
begin
  CurrentRTFP.NodeViewDataPost(Selected_PID,ValueListEditor_NodeView);
end;

////////////////////////////////////////////////////////////////////////////////
//菜单事件

procedure TFormDesktop.MenuItem_project_closeClick(Sender: TObject);
begin
  CurrentRTFP.Close;
end;

procedure TFormDesktop.MenuItem_project_newClick(Sender: TObject);
begin
  Form_NewProject.Call;
end;

procedure TFormDesktop.MenuItem_project_openClick(Sender: TObject);
begin

  if assigned(CurrentRTFP) then
  begin
    if CurrentRTFP.IsOpen then CurrentRTFP.Close;
    CurrentRTFP.Free;
  end;

  CurrentRTFP:=TRTFP.Create(FormDesktop);

  Self.EventLink(CurrentRTFP);

  if Self.OpenDialog_Project.Execute then
    CurrentRTFP.Open(UTF8ToWinCP(Self.OpenDialog_Project.FileName));
end;

procedure TFormDesktop.MenuItem_project_saveasClick(Sender: TObject);
begin
  if Self.SaveDialog_Project.Execute then
    CurrentRTFP.SaveAs(Self.SaveDialog_Project.FileName);
end;

procedure TFormDesktop.MenuItem_project_saveClick(Sender: TObject);
begin
  CurrentRTFP.Save;
end;



//菜单事件
////////////////////////////////////////////////////////////////////////////////



procedure TFormDesktop.FormResize(Sender: TObject);
begin
  //Self.Frame_AufScript1.FrameResize(nil);
end;

procedure TFormDesktop.Memo_FmtCmtChange(Sender: TObject);
begin
  Button_FmtCmt_Post.Enabled:=(Sender as TMemo).Modified;
end;

procedure TFormDesktop.MenuItem_AdvOpen_CAJClick(Sender: TObject);
begin
  if not assigned(CurrentRTFP) then exit;
  if not CurrentRTFP.IsOpen then exit;
  CurrentRTFP.OpenPaperAsCaj(Selected_PID);
end;

procedure TFormDesktop.MenuItem_AdvOpen_DirClick(Sender: TObject);
begin
  if not assigned(CurrentRTFP) then exit;
  if not CurrentRTFP.IsOpen then exit;
  CurrentRTFP.OpenPaperDir(Selected_PID);
end;

procedure TFormDesktop.MenuItem_AdvOpen_LinkClick(Sender: TObject);
begin
  if not assigned(CurrentRTFP) then exit;
  if not CurrentRTFP.IsOpen then exit;
  CurrentRTFP.OpenPaperLink(Selected_PID);
end;

procedure TFormDesktop.MenuItem_AdvOpen_PDFClick(Sender: TObject);
begin
  if not assigned(CurrentRTFP) then exit;
  if not CurrentRTFP.IsOpen then exit;
  CurrentRTFP.OpenPaperAsPdf(Selected_PID);
end;

procedure TFormDesktop.MenuItem_BasicReferencesClick(Sender: TObject);
begin
  Form_CiteTrans.Show;
end;

procedure TFormDesktop.MenuItem_CiteToolClick(Sender: TObject);
begin
  Form_CiteTrans.show;
end;

procedure TFormDesktop.MenuItem_ClassToolClick(Sender: TObject);
begin
  ClassManagerForm.show;
end;

procedure TFormDesktop.MenuItem_DelePaperClick(Sender: TObject);
begin
  case MessageDlg('删除确认','是否删除此文献节点？',mtInformation,[mbYes,mbNo],0) of
    rnmbYes:CurrentRTFP.DeletePaper(Selected_PID);
    rnmbNo:;
  end;
end;

procedure TFormDesktop.MenuItem_KlassClick(Sender: TObject);
begin
  ClassManagerForm.Show;
end;

procedure TFormDesktop.MenuItem_Mark_IsRead_NoClick(Sender: TObject);
begin
  CurrentRTFP.EditFieldAsBoolean(_Col_class_Is_Read_,_Attrs_Class_,Selected_PID,false,[]);
end;

procedure TFormDesktop.MenuItem_Mark_IsRead_YesClick(Sender: TObject);
begin
  CurrentRTFP.EditFieldAsBoolean(_Col_class_Is_Read_,_Attrs_Class_,Selected_PID,true,[]);
end;

procedure TFormDesktop.MenuItem_OpenAsCajClick(Sender: TObject);
begin
  if not assigned(CurrentRTFP) then exit;
  if not CurrentRTFP.IsOpen then exit;
  CurrentRTFP.OpenPaperAsCaj(Selected_PID);
end;

procedure TFormDesktop.MenuItem_OpenAsPdfClick(Sender: TObject);
begin
  if not assigned(CurrentRTFP) then exit;
  if not CurrentRTFP.IsOpen then exit;
  CurrentRTFP.OpenPaperAsPdf(Selected_PID);
end;

procedure TFormDesktop.MenuItem_OpenDefaultClick(Sender: TObject);
begin
  if not assigned(CurrentRTFP) then exit;
  if not CurrentRTFP.IsOpen then exit;
  CurrentRTFP.OpenPaper(Selected_PID,'');
end;

procedure TFormDesktop.MenuItem_OpenDirClick(Sender: TObject);
begin
  if not assigned(CurrentRTFP) then exit;
  if not CurrentRTFP.IsOpen then exit;
  CurrentRTFP.OpenPaperDir(Selected_PID);
end;

procedure TFormDesktop.MenuItem_OpenLinkClick(Sender: TObject);
begin
  if not assigned(CurrentRTFP) then exit;
  if not CurrentRTFP.IsOpen then exit;
  CurrentRTFP.OpenPaperLink(Selected_PID);
end;

procedure TFormDesktop.MenuItem_option_aboutClick(Sender: TObject);
begin
  MessageDlg('关于',C_SOFTWARE_NAME + #13#10
           + '版本： ' + C_VERSION_NUMBER + #13#10
           + '作者： ' + C_SOFTWARE_AUTHOR + #13#10
           + #13#10 + ' - Reading Technique For Paperwork.'
           + #13#10 + ' - Reference Tool by Free Pascal.'
           + #13#10 + ' - Read The F Paper.', mtCustom,[mbOK],0);
end;

procedure TFormDesktop.PageControl_NodeChange(Sender: TObject);
begin

end;

procedure TFormDesktop.TabSheet_Project_AufScriptResize(Sender: TObject);
begin
  Self.Frame_AufScript1.FrameResize(nil);
end;

procedure TFormDesktop.PropertiesValueListEditorEditingDone(Sender: TObject);
begin
  if not assigned(CurrentRTFP) then  exit;
  if not CurrentRTFP.IsOpen then exit;

  //CurrentRTFP.Title:=Utf8ToWinCP(Self.PropertiesValueListEditor.Values['工程标题']);
  //CurrentRTFP.User:=Utf8ToWinCP(Self.PropertiesValueListEditor.Values['创建用户']);
  CurrentRTFP.ProjectPropertiesDataPost(Self.PropertiesValueListEditor);
end;

procedure TFormDesktop.FormCreate(Sender: TObject);
begin
  Self.Frame_AufScript1.AufGenerator;
  AufScriptFuncDefineRTFP(Self.Frame_AufScript1.Auf);
  Self.Frame_AufScript1.HighLighterReNew;

  LocalPath:=ExtractFilePath(ParamStr(0));

  FWaitForm:=TForm.Create(Self);
  with FWaitForm do begin
    Height:=120;
    Width:=280;
    Position:=poOwnerFormCenter;
    Caption:='请稍等';
    Hide;
  end;

  if ParamCount<>0 then
    begin
      {
      if assigned(CurrentRTFP) then
      begin
        if CurrentRTFP.IsOpen then CurrentRTFP.Close;
        CurrentRTFP.Free;
      end;
      }
      CurrentRTFP:=TRTFP.Create(FormDesktop);
      Self.EventLink(CurrentRTFP);
      CurrentRTFP.Open(UTF8ToWinCP(ParamStr(1)));
    end;

  //CurrentRTFP:=TRTFP.Create(Self);
end;

procedure TFormDesktop.FormDropFiles(Sender: TObject;
  const FileNames: array of String);
var len:integer;
begin
  len:=Length(FileNames);
  if (len=1) and (TRTFP.IsProjectFile(FileNames[0])) then
    begin
      if assigned(CurrentRTFP) then
        begin
          if CurrentRTFP.IsOpen then exit
          else CurrentRTFP.Free;
        end;
      CurrentRTFP:=TRTFP.Create(FormDesktop);
      Self.EventLink(CurrentRTFP);
      CurrentRTFP.Open(UTF8ToWinCP(FileNames[0]));
    end
  else
    begin
      Form_ImportFiles.Call(FileNames);
    end;

end;

procedure TFormDesktop.CheckListBox_MainAttrFilterClickCheck(Sender: TObject);
//var attrNo:byte;
begin
  if not assigned(CurrentRTFP) then exit;
  if CurrentRTFP.IsOpen then begin
    MainGridValidate(nil);
  end;
end;

procedure TFormDesktop.ComboBox_AttrNameChange(Sender: TObject);
var str:string;
begin
  ComboBox_FieldName.Clear;
  with ComboBox_AttrName do begin
    if ItemIndex<0 then exit;
    str:=Items[ItemIndex];
  end;
  CurrentRTFP.FieldNameValidate(str,ComboBox_FieldName.Items);
end;

procedure TFormDesktop.ComboBox_FieldNameChange(Sender: TObject);
var attrName,fieldName:string;
    ty:TFieldType;
begin
  attrName:=ComboBox_AttrName.Items[ComboBox_AttrName.ItemIndex];
  fieldName:=ComboBox_FieldName.Items[ComboBox_FieldName.ItemIndex];
  ty:=CurrentRTFP.GetFieldType(attrName,fieldName);
  if ty=ftMemo then begin
    Image_IsMemo.Picture.LoadFromFile(LocalPath+'Icon\checked_true.png');
    Image_IsMemo.Hint:='该字段可支持FmtCmt';
    Memo_FmtCmt.Enabled:=true;
    Button_FmtCmt_Post.Enabled:=false;
  end else begin
    Image_IsMemo.Picture.LoadFromFile(LocalPath+'Icon\checked_false.png');
    Image_IsMemo.Hint:='该字段不支持FmtCmt';
    Memo_FmtCmt.Clear;
    Memo_FmtCmt.Enabled:=false;
    Button_FmtCmt_Post.Enabled:=false;
  end;
  Application.ProcessMessages;
  NodeViewValidate;
end;

procedure TFormDesktop.DataSource_MainUpdateData(Sender: TObject);
begin
  DBGridColumnAdjusting(CurrentRTFP);
end;

procedure TFormDesktop.Button_NodeViewPostClick(Sender: TObject);
begin
  if not assigned(CurrentRTFP) then exit;
  if not CurrentRTFP.IsOpen then exit;
  NodeViewDataPost;
end;

procedure TFormDesktop.Button_NodeViewAddAttrClick(Sender: TObject);
begin
  ///////
end;

procedure TFormDesktop.ACL_ListView_AttrsNodeChecked(Sender: TObject;
  Item: TACL_TreeNode);
var tmpAF:TAttrsField;
begin
  tmpAF:=TAttrsField(Item.Data);
  if tmpAF<>nil then
    begin
      tmpAF.Shown:=Item.Checked;
      MainGridValidate(nil);
    end;
end;

procedure TFormDesktop.ACL_ListView_KlassNodeChecked(Sender: TObject;
  Item: TACL_TreeNode);
var tmpKL:TKlass;
begin
  tmpKL:=TKlass(Item.Data);
  if tmpKL<>nil then begin
    tmpKL.FilterEnabled:=Item.Checked;
    MainGridValidate(nil);
  end;
end;

procedure TFormDesktop.Button_FmtCmt_PostClick(Sender: TObject);
var PID:RTFP_ID;
    attrNa,fieldNa:string;
begin
  if not assigned(CurrentRTFP) then exit;
  if not CurrentRTFP.IsOpen then exit;
  if Image_IsMemo.Hint='该字段不支持FmtCmt' then exit;
  //PID:=Selected_PID;
  PID:=Label_FmtCmtPID.Caption;
  if PID='000000' then exit;
  if (ComboBox_AttrName.ItemIndex>=0) and (ComboBox_FieldName.ItemIndex>=0) then begin
    attrNa:=ComboBox_AttrName.Items[ComboBox_AttrName.ItemIndex];
    fieldNa:=ComboBox_FieldName.Items[ComboBox_FieldName.ItemIndex];
    CurrentRTFP.FmtCmtDataPost(PID,attrNa,fieldNa,Memo_FmtCmt);
  end;
  (Sender as TButton).Enabled:=false;
end;

procedure TFormDesktop.Button_FmtCmt_RecoverClick(Sender: TObject);
var PID:RTFP_ID;
    attrNa,fieldNa:string;
begin
  if not assigned(CurrentRTFP) then exit;
  if not CurrentRTFP.IsOpen then exit;
  if Image_IsMemo.Hint='该字段不支持FmtCmt' then exit;
  //PID:=Selected_PID;
  PID:=Label_FmtCmtPID.Caption;
  if PID='000000' then exit;
  if (ComboBox_AttrName.ItemIndex>=0) and (ComboBox_FieldName.ItemIndex>=0) then begin
    attrNa:=ComboBox_AttrName.Items[ComboBox_AttrName.ItemIndex];
    fieldNa:=ComboBox_FieldName.Items[ComboBox_FieldName.ItemIndex];
    CurrentRTFP.FmtCmtValidate(PID,attrNa,fieldNa,Memo_FmtCmt);
  end;
end;

procedure TFormDesktop.Button_MainFilterClick(Sender: TObject);
begin
  //温和的筛选方式
  if not assigned(CurrentRTFP) then exit;
  if not CurrentRTFP.IsOpen then exit;
  MainGridValidate(nil);
  CurrentRTFP.TableFilter(Edit_DBGridMain_Filter.Caption);
end;

procedure TFormDesktop.Button_NodeViewRecoverClick(Sender: TObject);
begin
  if not assigned(CurrentRTFP) then exit;
  if not CurrentRTFP.IsOpen then exit;
  NodeViewValidate;
end;

procedure TFormDesktop.Button_Project_NodeView_FreshClick(Sender: TObject);
begin
  //LvlGraphControl.Clear;
  //LvlGraphControl.Graph.GetEdge('AA','BB',true);
  //LvlGraphControl.Graph.GetEdge('AA','CC',true);
  //LvlGraphControl.Graph.GetEdge('AA','DD',true);
end;

procedure TFormDesktop.Button_tempClick(Sender: TObject);
begin
  LayoutMode:=(LayoutMode+1) mod 3;
end;



procedure TFormDesktop.DBGrid_MainCellClick(Column: TColumn);
begin
  NodeViewValidate;
end;

procedure TFormDesktop.DBGrid_MainKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  NodeViewValidate;
end;

procedure TFormDesktop.DBGrid_MainMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
  //NodeViewValidate;
end;

procedure TFormDesktop.Edit_DBGridMain_FilterChange(Sender: TObject);
begin
  //有点激进的筛选方式
  //MainGridValidate(nil);
  //CurrentRTFP.TableFilter((Sender as TEdit).Caption);
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
  FWaitForm.Free;
end;


procedure TFormDesktop.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if assigned(CurrentRTFP) then begin
    if CurrentRTFP.IsOpen then
      if not CurrentRTFP.Close then CanClose:=false;
  end;
end;


end.

