unit RTFP_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, dbf, sqldb, mssqlconn, FileUtil, Forms,
  Controls, Graphics, Dialogs, ComCtrls, Menus, ExtCtrls, DBGrids, ValEdit,
  StdCtrls, DbCtrls, LazUTF8, LvlGraphCtrl,
  Clipbrd, LCLType, Buttons,

  AufScript_Frame, ACL_ListView, TreeListView, lNetComponents,

  RTFP_definition, rtfp_constants, rtfp_dialog, simpleipc, Types;

const
  C_VERSION_NUMBER  = '0.1.2-alpha.2';
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
    AListView_Klass: TACL_ListView;
    AListView_Attrs: TACL_ListView;
    Button_FieldType: TButton;
    Button_AddAttrs: TButton;
    Button_AddField: TButton;
    Button_AddKlass: TButton;
    Combo_FieldType: TComboBox;
    ComboBox_FormatEdit: TComboBox;
    Button_FormatEditPost: TButton;
    Button_FormatEditRecover: TButton;
    Button_MainFilter: TButton;
    Button_temp: TButton;
    Button_Project_NodeView_Fresh: TButton;
    Button_FmtCmt_Post: TButton;
    Button_FmtCmt_Recover: TButton;
    Combo_AddAttrs: TComboBox;
    Edit_AddField: TEdit;
    Edit_AddKlass: TEdit;
    Image_IsMemo: TImage;
    ComboBox_AttrName: TComboBox;
    ComboBox_FieldName: TComboBox;
    DataSource_Main: TDataSource;
    DBGrid_Main: TDBGrid;
    Edit_DBGridMain_Filter: TEdit;
    Frame_AufScript1: TFrame_AufScript;
    Image_PDF_View: TImage;
    Label_FieldType: TLabel;
    Label_AddAttrs: TLabel;
    Label_AddField: TLabel;
    Label_AddKlass: TLabel;
    Label_FmtCmtPID: TLabel;
    Label_MainFilter: TLabel;
    LvlGraphControl: TLvlGraphControl;
    MainMenu: TMainMenu;
    Memo_FmtCmt: TMemo;
    MenuItem_FieldMgr_Del: TMenuItem;
    MenuItem_FieldMgr_Ren: TMenuItem;
    MenuItem_FieldMgr_Edit: TMenuItem;
    MenuItem_option_div01: TMenuItem;
    MenuItem_Attr_EditField: TMenuItem;
    MenuItem_Attr_DelField: TMenuItem;
    MenuItem_Attr_AddAttrs: TMenuItem;
    MenuItem_Attr_DelAttrs: TMenuItem;
    MenuItem_Attr_AddField: TMenuItem;
    MenuItem_Attr_div02: TMenuItem;
    MenuItem_Attr_div01: TMenuItem;
    MenuItem_ClassMgr_UnCheckAll: TMenuItem;
    MenuItem_ClassMgr_CheckAll: TMenuItem;
    MenuItem_ClassMgr_div01: TMenuItem;
    MenuItem_ClassMgr_CDir: TMenuItem;
    MenuItem_ClassMgr_Del: TMenuItem;
    MenuItem_ClassMgr_Ren: TMenuItem;
    MenuItem_Klass_check: TMenuItem;
    MenuItem_Attr_DelKlass: TMenuItem;
    MenuItem_Attr_AddKlass: TMenuItem;
    MenuItem_AttributeMenu: TMenuItem;
    MenuItem_option_appearance: TMenuItem;
    MenuItem_AdvOpen_PDF: TMenuItem;
    MenuItem_AdvOpen_CAJ: TMenuItem;
    MenuItem_AdvOpen_Dir: TMenuItem;
    MenuItem_AdvOpen_Link: TMenuItem;
    MenuItem_AdvOpen: TMenuItem;
    MenuItem_ClassTool: TMenuItem;
    MenuItem_Klass: TMenuItem;
    MenuItem_BasicReferences: TMenuItem;
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
    PopupMenu_FieldManager: TPopupMenu;
    PopupMenu_ClassManager: TPopupMenu;
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
    TabSheet_Project_AufScript: TTabSheet;
    TabSheet_Project_DataGrid: TTabSheet;
    PropertiesValueListEditor: TValueListEditor;
    procedure AListView_AttrsNodeChecked(Sender: TObject; Item: TACL_TreeNode);
    procedure AListView_KlassNodeChecked(Sender: TObject; Item: TACL_TreeNode);
    procedure Button_AddAttrsClick(Sender: TObject);
    procedure Button_AddFieldClick(Sender: TObject);
    procedure Button_AddKlassClick(Sender: TObject);
    procedure Button_FmtCmt_PostClick(Sender: TObject);
    procedure Button_FmtCmt_RecoverClick(Sender: TObject);
    procedure Button_FormatEditPostClick(Sender: TObject);
    procedure Button_FormatEditRecoverClick(Sender: TObject);
    procedure Button_MainFilterClick(Sender: TObject);

    procedure Button_NodeViewRecoverClick(Sender: TObject);
    procedure Button_Project_NodeView_FreshClick(Sender: TObject);
    procedure Button_tempClick(Sender: TObject);
    procedure CheckListBox_MainAttrFilterClickCheck(Sender: TObject);
    procedure ComboBox_AttrNameChange(Sender: TObject);
    procedure ComboBox_FieldNameChange(Sender: TObject);
    procedure ComboBox_FormatEditChange(Sender: TObject);
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
    procedure MenuItem_ClassMgr_CDirClick(Sender: TObject);
    procedure MenuItem_ClassMgr_CheckAllClick(Sender: TObject);
    procedure MenuItem_ClassMgr_DelClick(Sender: TObject);
    procedure MenuItem_ClassMgr_RenClick(Sender: TObject);
    procedure MenuItem_ClassMgr_UnCheckAllClick(Sender: TObject);
    procedure MenuItem_ClassToolClick(Sender: TObject);
    procedure MenuItem_DeletePaperClick(Sender: TObject);
    procedure MenuItem_FieldMgr_DelClick(Sender: TObject);
    procedure MenuItem_FieldMgr_EditClick(Sender: TObject);
    procedure MenuItem_FieldMgr_RenClick(Sender: TObject);
    procedure MenuItem_KlassClick(Sender: TObject);
    procedure MenuItem_Attr_AddKlassClick(Sender: TObject);
    procedure MenuItem_Attr_DelKlassClick(Sender: TObject);
    procedure MenuItem_Mark_IsRead_NoClick(Sender: TObject);
    procedure MenuItem_Mark_IsRead_YesClick(Sender: TObject);
    procedure MenuItem_OpenAsCajClick(Sender: TObject);
    procedure MenuItem_OpenAsPdfClick(Sender: TObject);
    procedure MenuItem_OpenDefaultClick(Sender: TObject);
    procedure MenuItem_OpenDirClick(Sender: TObject);
    procedure MenuItem_OpenLinkClick(Sender: TObject);
    procedure MenuItem_option_aboutClick(Sender: TObject);
    procedure MenuItem_option_appearanceClick(Sender: TObject);
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
    FWaitLabel:TLabel;

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
    procedure FormatListValidate(Sender:TObject);

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


  end;

  function ProjectInvalid:boolean;

var
  FormDesktop: TFormDesktop;
  CurrentRTFP:TRTFP;
  LocalPath:string;

implementation
uses form_new_project, form_cite_trans, form_classmanager, form_import,
     form_appearance, rtfp_field, rtfp_class;

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

procedure TFormDesktop.EventLink(Sender:TRTFP);//链接所有事件
begin
  //Sender.onNewDone:=@ProjectOpenDone;
  Sender.onOpenDone:=@ProjectOpenDone;
  Sender.onFirstEdit:=@FirstEdit;
  Sender.onSaveDone:=@ProjectSaveDone;
  Sender.onCloseDone:=@ProjectCloseDone;
  Sender.onChange:=@Validate;
  Sender.onDataChange:=@MainGridValidate;
  Sender.onClassChange:=@ClassListValidate;
  Sender.onFieldChange:=@FieldListValidate;
  //Sender.OnTableValidateDone:=@DBGridColumnAdjusting;
  Sender.onFormatListChange:=@FormatListValidate;
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
  //MainGridValidate(CurrentRTFP);//这个移到DataChange去了

end;

procedure TFormDesktop.ClassListValidate(Sender:TObject);
begin
  (Sender as TRTFP).KlassListValidate(AListView_Klass);
end;

procedure TFormDesktop.FieldListValidate(Sender:TObject);
var tmpAG:TAttrsGroup;
    stored_AG:string;
begin
  (Sender as TRTFP).FieldListValidate(AListView_Attrs);
  stored_AG:='';
  if Combo_AddAttrs.ItemIndex>=0 then stored_AG:=Combo_AddAttrs.Items[Combo_AddAttrs.ItemIndex];
  Combo_AddAttrs.Clear;
  for tmpAG in CurrentRTFP.FieldList do Combo_AddAttrs.AddItem(tmpAG.Name,tmpAG);
  Combo_AddAttrs.SelText:=stored_AG;
end;

procedure TFormDesktop.MainGridValidate(Sender:TObject);
begin
  Self.DBGrid_Main.Visible:=false;
  FWaitForm.Show;
  (Sender as TRTFP).TableValidate;
  FWaitForm.Hide;
  Self.DBGrid_Main.Visible:=true;
end;

procedure TFormDesktop.FormatListValidate(Sender:TObject);
var stmp,stored:string;
    marked,acc:integer;
begin
  stored:=ComboBox_FormatEdit.SelText;
  if stored='' then stored:='default.fmt';
  ComboBox_FormatEdit.Clear;
  acc:=0;
  marked:=-1;
  for stmp in (Sender as TRTFP).FormatList do
    begin
      ComboBox_FormatEdit.AddItem(stmp,nil);
      if stmp=stored then marked:=acc;
      inc(acc);
    end;
  if marked>=0 then ComboBox_FormatEdit.ItemIndex:=marked;
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
  AListView_Attrs.Clear;
  AListView_Klass.Clear;
  ComboBox_AttrName.Clear;
  ComboBox_FieldName.Clear;
  Combo_AddAttrs.Clear;
  ComboBox_FormatEdit.Clear;
end;

procedure TFormDesktop.ProjectOpenDone(Sender:TObject);
begin

  //文献节点选项卡
  Self.DataSource_Main.DataSet:=CurrentRTFP.PaperDS;

  //分类节点选项卡
  ClassListValidate(CurrentRTFP);

  //FmtCmt选项卡
  Self.ComboBox_AttrName.Clear;
  Self.Button_FmtCmt_Post.Enabled:=false;
  CurrentRTFP.AttrNameValidate(ComboBox_AttrName.Items);

  Self.Validate(Sender);
  Self.MainGridValidate(Sender);
  CurrentRTFP.FormatEditBuild(Self.ScrollBox_Node_FormatEdit,'default.fmt');


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
  AListView_Klass.Clear;

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
  StatusBar.Panels[1].Text:=ExtractFileName(Selected_FileName);
  CurrentRTFP.UpdatePIDExpr(PID,Self.Frame_AufScript1.Auf.Script);

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

  //FormatEdit
  CurrentRTFP.FormatEditValidate(PID);
  //类似于FmtCmt的保存询问机制需要覆盖所有的节点编辑选项卡


end;

////////////////////////////////////////////////////////////////////////////////
//菜单事件

procedure TFormDesktop.MenuItem_project_closeClick(Sender: TObject);
begin
  CurrentRTFP.Close;
end;

procedure TFormDesktop.MenuItem_project_newClick(Sender: TObject);
begin
  Form_NewProject.ShowModal;//Form_NewProject.Show;
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

procedure TFormDesktop.MenuItem_BasicReferencesClick(Sender: TObject);
begin
  Form_CiteTrans.ShowModal;//Form_CiteTrans.Show;
end;

procedure TFormDesktop.MenuItem_CiteToolClick(Sender: TObject);
begin
  Form_CiteTrans.ShowModal;//Form_CiteTrans.Show;
end;

procedure TFormDesktop.MenuItem_ClassMgr_CDirClick(Sender: TObject);
var klassname,newname:string;
    tmpNode:TACL_TreeNode;
    tmpLV:TACL_ListView;
begin
  if ProjectInvalid then exit;
  tmpLV:=AListView_Klass;
  tmpNode:=TACL_TreeNode(tmpLV.Selected.Data);
  if tmpNode<>nil then
  klassname:=TKlass(tmpNode.Data).FullPath;
  newname:=InputBox('分类移动','分类组：',klassname);
  //if (newname<>'') and (newname<>klassname) then CurrentRTFP.ChangeKlassDir(klassname);
end;

procedure TFormDesktop.MenuItem_ClassMgr_DelClick(Sender: TObject);
var klassname:string;
    tmpNode:TACL_TreeNode;
    tmpLV:TACL_ListView;
begin
  if ProjectInvalid then exit;
  tmpLV:=AListView_Klass;
  tmpNode:=TACL_TreeNode(tmpLV.Selected.Data);
  if tmpNode<>nil then
  klassname:=tmpNode.Name;
  case MessageDlg('删除分类','是否删除“'+klassname+'”分类？',mtInformation,[mbYes,mbNo],0) of
    rnmbYes:;
    rnmbNo:;
  end;
  CurrentRTFP.DeleteKlass(klassname);
end;

procedure TFormDesktop.MenuItem_ClassMgr_RenClick(Sender: TObject);
var klassname,newname:string;
    tmpNode:TACL_TreeNode;
    tmpLV:TACL_ListView;
begin
  if ProjectInvalid then exit;
  tmpLV:=AListView_Klass;
  tmpNode:=TACL_TreeNode(tmpLV.Selected.Data);
  if tmpNode<>nil then
  klassname:=tmpNode.Name;
  newname:=InputBox('分类重命名','新名称：',klassname);
  //if (newname<>'') and (newname<>klassname) then CurrentRTFP.RenameKlass(klassname);
end;

procedure TFormDesktop.MenuItem_ClassMgr_CheckAllClick(Sender: TObject);
var tmpNode:TACL_TreeNode;
begin
  if ProjectInvalid then exit;
  tmpNode:=TACL_TreeNode(AListView_Klass.Selected.Data);
  CurrentRTFP.BeginUpdate;
  tmpNode.CheckAll;
  CurrentRTFP.EndUpdate;
  AListView_Klass.RePaint;
  MainGridValidate(CurrentRTFP);
end;

procedure TFormDesktop.MenuItem_ClassMgr_UnCheckAllClick(Sender: TObject);
var tmpNode:TACL_TreeNode;
begin
  if ProjectInvalid then exit;
  tmpNode:=TACL_TreeNode(AListView_Klass.Selected.Data);
  CurrentRTFP.BeginUpdate;
  tmpNode.UnCheckAll;
  CurrentRTFP.EndUpdate;
  AListView_Klass.RePaint;
  MainGridValidate(CurrentRTFP);
end;

procedure TFormDesktop.MenuItem_ClassToolClick(Sender: TObject);
begin
  ClassManagerForm.ShowModal;//ClassManagerForm.show;
end;

procedure TFormDesktop.MenuItem_DeletePaperClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  case MessageDlg('删除确认','是否删除此文献节点？',mtInformation,[mbYes,mbNo],0) of
    rnmbYes:CurrentRTFP.DeletePaper(Selected_PID);
    rnmbNo:;
  end;
end;

procedure TFormDesktop.MenuItem_FieldMgr_DelClick(Sender: TObject);
var tmpA:Pointer;
    tmpNode:TACL_TreeNode;
    target_name,group_name:string;
begin
  if ProjectInvalid then exit;
  tmpNode:=TACL_TreeNode(AListView_Attrs.Selected.Data);
  if tmpNode=nil then exit;
  if tmpNode.Data is TAttrsGroup then
    begin
      target_name:=(tmpNode.Data as TAttrsGroup).Name;
      case MessageDlg('删除属性组','是否删除属性组“'+target_name+'”？',mtInformation,[mbYes,mbNo],0) of
        rnmbYes:CurrentRTFP.DeleteAttrs(target_name);
        rnmbNo:;
      end;
    end
  else if tmpNode.Data is TAttrsField then
    begin
      target_name:=(tmpNode.Data as TAttrsField).FieldName;
      group_name:=(tmpNode.Data as TAttrsField).AttrsGroup.Name;
      case MessageDlg('删除字段列','是否删除属性组“'+group_name+'”中的字段列“'+target_name+'”？',mtInformation,[mbYes,mbNo],0) of
        rnmbYes:CurrentRTFP.DeleteField(target_name,group_name);
        rnmbNo:;
      end;
    end
  else assert(false,'ACL_TreeNode中有unexpected的类型对象');
end;

procedure TFormDesktop.MenuItem_FieldMgr_EditClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
end;

procedure TFormDesktop.MenuItem_FieldMgr_RenClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
end;

procedure TFormDesktop.MenuItem_KlassClick(Sender: TObject);
begin
  ClassManagerForm.Show;
end;

procedure TFormDesktop.MenuItem_Attr_AddKlassClick(Sender: TObject);
var klassname,pathname:string;
begin
  if ProjectInvalid then exit;
  klassname:=InputBox('新建分类','分类名称：','');
  if klassname<>'' then
    begin
      pathname:=ExtractFilePath(klassname);
      klassname:=ExtractFileName(klassname);
      CurrentRTFP.AddKlass(klassname,pathname);
    end;
end;

procedure TFormDesktop.MenuItem_Attr_DelKlassClick(Sender: TObject);
var klassname:string;
    str:TStringList;
    tmpKL:TKlass;
begin
  if ProjectInvalid then exit;
  str:=TStringList.Create;
  try
    for tmpKL in CurrentRTFP.KlassList do str.Add(tmpKL.Name);
    klassname:=ShowMsgList('删除分类','选择需要删除的分类：',str);
    if klassname<>'' then CurrentRTFP.DeleteKlass(klassname);
  finally
    str.Free;
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
  MessageDlg('关于',C_SOFTWARE_NAME + #13#10
           + '版本： ' + C_VERSION_NUMBER + #13#10
           + '作者： ' + C_SOFTWARE_AUTHOR + #13#10
           + #13#10 + ' - Reading Technique For Paperwork.'
           + #13#10 + ' - Reference Tool by Free Pascal.'
           + #13#10 + ' - Read The F Paper.', mtCustom,[mbOK],0);
end;

procedure TFormDesktop.MenuItem_option_appearanceClick(Sender: TObject);
begin
  AppearanceForm.Show;
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
  if ProjectInvalid then exit;

  //CurrentRTFP.Title:=Utf8ToWinCP(Self.PropertiesValueListEditor.Values['工程标题']);
  //CurrentRTFP.User:=Utf8ToWinCP(Self.PropertiesValueListEditor.Values['创建用户']);
  CurrentRTFP.ProjectPropertiesDataPost(Self.PropertiesValueListEditor);
end;

procedure TFormDesktop.FormCreate(Sender: TObject);
begin
  Self.Frame_AufScript1.AufGenerator;
  AufScriptFuncDefineRTFP(Self.Frame_AufScript1.Auf);
  Self.Frame_AufScript1.HighLighterReNew;
  CurrentRTFP.UpdatePIDExpr('000000',Self.Frame_AufScript1.Auf.Script);

  LocalPath:=ExtractFilePath(ParamStr(0));

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
    Caption:='主表正在重建中';//为啥不管用？？？？？
    Parent:=FWaitForm;
  end;
  if ParamCount<>0 then
    begin
      CurrentRTFP:=TRTFP.Create(FormDesktop);
      Self.EventLink(CurrentRTFP);
      CurrentRTFP.Open(UTF8ToWinCP(ParamStr(1)));
    end;
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
      if not ProjectInvalid then Form_ImportFiles.Call(FileNames);
    end;

end;

procedure TFormDesktop.CheckListBox_MainAttrFilterClickCheck(Sender: TObject);
begin
  if ProjectInvalid then exit;
  MainGridValidate(CurrentRTFP);
end;

procedure TFormDesktop.ComboBox_AttrNameChange(Sender: TObject);
var str:string;
begin
  if ProjectInvalid then exit;
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
  if ProjectInvalid then exit;
  if ComboBox_AttrName.ItemIndex<0 then exit;
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

procedure TFormDesktop.ComboBox_FormatEditChange(Sender: TObject);
var combo:TComboBox;
    filename:string;
begin
  if ProjectInvalid then exit;
  combo:=Sender as TComboBox;
  if combo.ItemIndex>=0 then filename:=combo.Items[combo.ItemIndex]
  else filename:='';
  CurrentRTFP.FormatEditClear(nil);
  CurrentRTFP.FormatEditBuild(Self.ScrollBox_Node_FormatEdit,filename);
  CurrentRTFP.FormatEditValidate(Selected_PID);
end;

procedure TFormDesktop.DataSource_MainUpdateData(Sender: TObject);
begin
  DBGridColumnAdjusting(CurrentRTFP);
end;



procedure TFormDesktop.AListView_AttrsNodeChecked(Sender: TObject;
  Item: TACL_TreeNode);
var tmpA:TObject;
begin
  tmpA:=Item.Data;
  if tmpA=nil then exit;
  if tmpA is TAttrsField then
    begin
      (tmpA as TAttrsField).Shown:=Item.Checked;
      CurrentRTFP.DataChange;//MainGridValidate(CurrentRTFP);
    end
  else if tmpA is TAttrsGroup then
    begin
      //
    end
  else ;
end;

procedure TFormDesktop.AListView_KlassNodeChecked(Sender: TObject;
  Item: TACL_TreeNode);
var tmpKL:TKlass;
begin
  tmpKL:=TKlass(Item.Data);
  if tmpKL<>nil then begin
    tmpKL.FilterEnabled:=Item.Checked;
    CurrentRTFP.DataChange;//MainGridValidate(CurrentRTFP);
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
      ShowMessage('属性组“'+GroupName+'”已存在。');
      exit;
    end;
  if Sender=nil then begin
    CurrentRTFP.AddAttrs(GroupName);
    //Button_AddFieldClick中使用nil作为参数调用则不需要再询问
  end else begin
    case MessageDlg('创建属性组','是否创建名为“'+GroupName+'”的属性组？',mtInformation,[mbYes,mbNo],0) of
      rnmbYes:CurrentRTFP.AddAttrs(GroupName);
      rnmbNo:;
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
  case str of
    'Memo':ChosenFieldType:=ftMemo;
    //'String':ChosenFieldType:=ftString;
    'Boolean':ChosenFieldType:=ftBoolean;
    'SmallInt':ChosenFieldType:=ftSmallint;
    'LargeInt':ChosenFieldType:=ftLargeint;
    'Float':ChosenFieldType:=ftFloat;
    //'Date':ChosenFieldType:=ftDate;
    'DateTime':ChosenFieldType:=ftDateTime;
    //'Blob':ChosenFieldType:=ftBlob;
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
      ShowMessage('属性组名称不能超过20个字节！');
      exit;
    end;
  if length(FieldName)>12 then
    begin
      ShowMessage('字段列名称不能超过12个字节！');
      exit;
    end;
  if CurrentRTFP.FindField(FieldName,GroupName)<>nil then
    begin
      ShowMessage('字段列“'+GroupName+'.'+FieldName+'”已存在');
      exit;
    end;
  if Combo_AddAttrs.ItemIndex<0 then begin
    case MessageDlg('创建字段列('+fieldclassname+')','创建字段列“'+FieldName+'”之前先创建，需要先创建属性组“'+GroupName+'”，是否创建？',mtInformation,[mbYes,mbNo],0) of
      rnmbYes:
        begin
          Button_AddAttrsClick(nil);//此处使用nil不需要再询问一次
          confirmed:=true;//之后也不用再询问
        end;
      rnmbNo:exit;
    end;
  end;
  if confirmed then begin
    CurrentRTFP.AddField(FieldName,GroupName,ChosenFieldType);
  end else begin
    case MessageDlg('创建字段列('+fieldclassname+')','是否在属性组“'+GroupName+'”中创建名为“'+FieldName+'”的字段列？',mtInformation,[mbYes,mbNo],0) of
      rnmbYes:CurrentRTFP.AddField(FieldName,GroupName,ChosenFieldType);
      rnmbNo:;
    end;
  end;
  CurrentRTFP.FieldChange;
end;

procedure TFormDesktop.Button_AddKlassClick(Sender: TObject);
var klasspath,klassname:string;
begin
  if ProjectInvalid then exit;
  if Edit_AddKlass.Caption='' then exit;
  klassname:=ExtractFileName(Edit_AddKlass.Caption);
  klasspath:=ExtractFilePath(Edit_AddKlass.Caption);
  if length(klassname)>40 then begin
    ShowMessage('分类名称长度不能大于40个字节');
    exit;
  end;
  if length(klasspath)>60 then begin
    ShowMessage('分类路径长度不能大于60个字节');
    exit;
  end;
  if CurrentRTFP.FindKlass(klassname)<>nil then
    begin
      ShowMessage('分类“'+klassname+'”已存在。');
      exit;
    end;
  case MessageDlg('创建分类','是否创建名为“'+Edit_AddKlass.Caption+'”的分类？',mtInformation,[mbYes,mbNo],0) of
    rnmbYes:
      begin
        CurrentRTFP.AddKlass(klassname,klasspath);
      end;
    rnmbNo:;
  end;
end;

procedure TFormDesktop.Button_FmtCmt_PostClick(Sender: TObject);
var PID:RTFP_ID;
    attrNa,fieldNa:string;
begin
  if ProjectInvalid then exit;
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
  if ProjectInvalid then exit;
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

procedure TFormDesktop.Button_MainFilterClick(Sender: TObject);
begin
  //温和的筛选方式
  if ProjectInvalid then exit;
  MainGridValidate(CurrentRTFP);
  CurrentRTFP.TableFilter(Edit_DBGridMain_Filter.Caption);
end;

procedure TFormDesktop.Button_NodeViewRecoverClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
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
  //MainGridValidate(CurrentRTFP);
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
  if ProjectInvalid then exit;
  if not CurrentRTFP.Close then CanClose:=false;

end;


end.

