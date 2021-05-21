unit RTFP_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, dbf, sqldb, mssqlconn, FileUtil, Forms,
  Controls, Graphics, Dialogs, ComCtrls, Menus, ExtCtrls, DBGrids, ValEdit,
  CheckLst, StdCtrls, DbCtrls, LazUTF8, LvlGraphCtrl,
  Clipbrd, LCLType,

  AufScript_Frame, ACL_ListView, TreeListView,

  RTFP_definition, simpleipc, Types;

const
  C_VERSION_NUMBER  = '0.1.1-alpha.6';
  C_SOFTWARE_NAME   = 'RTFP Desktop';
  C_SOFTWARE_AUTHOR = 'Apiglio';


type

  { TFormDesktop }

  TFormDesktop = class(TForm)
    ACL_ListView_Klass: TACL_ListView;
    ACL_ListView_Attrs: TACL_ListView;
    Button_temp: TButton;
    Button_Project_NodeView_Fresh: TButton;
    Button_FmtCmt_Post: TButton;
    Button_FmtCmt_Recover: TButton;
    Button_NodeViewAddAttr: TButton;
    Button_NodeViewPost: TButton;
    Button_NodeViewRecover: TButton;
    CheckListBox_MainAttrFilter: TCheckListBox;
    ComboBox_AttrName: TComboBox;
    ComboBox_FieldName: TComboBox;
    DataSource_Attrs: TDataSource;
    DataSource_Main: TDataSource;
    DBGrid_Main: TDBGrid;
    Edit_DBGridMain_Filter: TEdit;
    Frame_AufScript1: TFrame_AufScript;
    Image_PDF_View: TImage;
    Label_MainFilter: TLabel;
    LvlGraphControl: TLvlGraphControl;
    MainMenu: TMainMenu;
    Memo_FmtCmt: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem_OpenAsPdf: TMenuItem;
    MenuItem_OpenAsCaj: TMenuItem;
    MenuItem_project_recent: TMenuItem;
    MenuItem_ImportFromOther: TMenuItem;
    MenuItem_ExportToOther: TMenuItem;
    MenuItem_CiteTool: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem_project_close: TMenuItem;
    MenuItem_project_check: TMenuItem;
    MenuItem3: TMenuItem;
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
    PopupMenu_MainDBGrid: TPopupMenu;
    SaveDialog_project: TSaveDialog;
    Splitter_LeftH: TSplitter;
    Splitter_PropertiesV: TSplitter;
    Splitter_RightH: TSplitter;
    Splitter_MainV: TSplitter;
    StaticText_AttrNameCombo: TStaticText;
    StaticText_FieldNameCombo: TStaticText;
    StatusBar: TStatusBar;
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
    procedure Button_FmtCmt_PostClick(Sender: TObject);
    procedure Button_FmtCmt_RecoverClick(Sender: TObject);
    procedure Button_NodeViewAddAttrClick(Sender: TObject);
    procedure Button_NodeViewPostClick(Sender: TObject);
    procedure Button_NodeViewRecoverClick(Sender: TObject);
    procedure Button_Project_NodeView_FreshClick(Sender: TObject);
    procedure Button_tempClick(Sender: TObject);
    procedure CheckListBox_MainAttrFilterClickCheck(Sender: TObject);
    procedure ComboBox_AttrNameChange(Sender: TObject);
    procedure ComboBox_Attrs_ViewChange(Sender: TObject);
    procedure ComboBox_FieldNameChange(Sender: TObject);
    procedure DBGrid_MainCellClick(Column: TColumn);
    procedure DBGrid_MainKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBGrid_MainMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure Edit_DBGridMain_FilterChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure FormResize(Sender: TObject);
    procedure MenuItem_CiteToolClick(Sender: TObject);
    procedure MenuItem_OpenAsCajClick(Sender: TObject);
    procedure MenuItem_OpenAsPdfClick(Sender: TObject);
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
    FLayoutMode:integer;
  protected
    procedure SetLayoutMode(AModeIndex:integer);
  public
    property LayoutMode:integer read FLayoutMode write SetLayoutMode;

  private
    function Selected_PID:RTFP_ID;//根据DBGrid_Main的选择返回PID

  public
    //RTFP类事件，Sender参数为TRTFP类
    procedure EventLink(Sender:TRTFP);//链接所有事件

    procedure Validate(Sender:TObject);//更新显示
    procedure ClassListValidate(Sender:TObject);//分类更新时的操作
    procedure FirstEdit(Sender:TObject);//工程第一次编辑
    procedure Clear(Sender:TObject);//清空

    procedure StopGridConnect;//断开展示连接
    procedure ResetGridConnect;//重新连接数据展示

    procedure ProjectOpenDone(Sender:TObject);//工程打开或新建
    procedure ProjectCloseDone(Sender:TObject);//工程关闭
    procedure ProjectSaveDone(Sender:TObject);//工程保存

    //以下与下半部分的NodeView有关
    procedure ViewPdfValidate;
    //预览pdf
    procedure NodeViewValidate;
    //根据当前DBGrid_Main的选择状态更新NodeView显示
    procedure NodeViewDataPost;
    //将NodeView的数据提交到工程中

  protected
    function GetMainAttrFilterSet:TablesUse;
  public
    property MainAttrFilterSet:TablesUse read GetMainAttrFilterSet;


  end;

var
  FormDesktop: TFormDesktop;
  CurrentRTFP:TRTFP;

implementation
uses form_new_project, form_cite_trans, form_import,
     rtfp_field;

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

end;

procedure TFormDesktop.Validate(Sender:TObject);
var changed_str:string;
    attr_i,pi:integer;
    stmp,old_choice:string;
    AG:TAttrsGroup;
    //此处刷新CheckBoxMainFilter的勾选就会重置，需解决

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

  CurrentRTFP.TableValidate(Self.MainAttrFilterSet);

  CheckListBox_MainAttrFilter.Items.Clear;
  {
  attr_i:=0;
  repeat
    stmp:=CurrentRTFP.AttrName[attr_i];
    if stmp<>'' then begin
      Self.CheckListBox_MainAttrFilter.Items.Add(stmp);
    end else break;
    inc(attr_i);
  until attr_i>99;
  }
  for AG in CurrentRTFP.each_attrs do
    begin
      CheckListBox_MainAttrFilter.Items.Add(AG.Name);
    end;

end;

procedure TFormDesktop.ClassListValidate(Sender:TObject);
var stmp:string;
begin
  ACL_ListView_Klass.Clear;
  for stmp in CurrentRTFP.each_class do
    begin
      ACL_ListView_Klass.AddItem(stmp,nil);
    end;
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
  //Self.MemDataset_Main.Clear;
  Self.CheckListBox_MainAttrFilter.Clear;
  Self.CheckListBox_MainAttrFilter.ItemIndex:=-1;
end;

procedure TFormDesktop.StopGridConnect;
begin
  //Self.ProjectCloseDone(CurrentRTFP);
end;

procedure TFormDesktop.ResetGridConnect;
begin
  //Self.ProjectOpenDone(CurrentRTFP);
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
  if not DBGrid_Main.DataSource.DataSet.Active then exit;
  result:=DBGrid_Main.DataSource.DataSet.Fields.FieldByName(_Col_PID_).AsString;
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
  ValueListEditor_NodeView.Clear;
  if PID='000000' then exit;
  StatusBar.Panels[0].Text:=PID;
  CurrentRTFP.NodeViewValidate(PID,ValueListEditor_NodeView);

  if (ComboBox_AttrName.ItemIndex>=0) and (ComboBox_FieldName.ItemIndex>=0) then begin
    attrNa:=ComboBox_AttrName.Items[ComboBox_AttrName.ItemIndex];
    fieldNa:=ComboBox_FieldName.Items[ComboBox_FieldName.ItemIndex];
    CurrentRTFP.FmtCmtValidate(PID,attrNa,fieldNa,Memo_FmtCmt);
  end;
end;

procedure TFormDesktop.NodeViewDataPost;
var PID:RTFP_ID;
begin
  PID:=ValueListEditor_NodeView.Values['PID'];
  CurrentRTFP.NodeViewDataPost(PID,ValueListEditor_NodeView);
end;



function TFormDesktop.GetMainAttrFilterSet:TablesUse;
var pi,max:byte;
begin
  result:=[];
  if CheckListBox_MainAttrFilter.Count<=0 then exit;
  max:=CheckListBox_MainAttrFilter.Count-1;
  if max>99 then max:=99;
  for pi:=0 to max do
    if Self.CheckListBox_MainAttrFilter.Checked[pi] then result:=result+[pi];

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

procedure TFormDesktop.MenuItem_CiteToolClick(Sender: TObject);
begin
  Form_CiteTrans.show;
end;

procedure TFormDesktop.MenuItem_OpenAsCajClick(Sender: TObject);
begin
  if not assigned(CurrentRTFP) then exit;
  if not CurrentRTFP.IsOpen then exit;
  CurrentRTFP.OpenPaperAsCaj(Self.DataSource_Main.DataSet.FieldByName(_Col_PID_).AsString);
end;

procedure TFormDesktop.MenuItem_OpenAsPdfClick(Sender: TObject);
begin
  if not assigned(CurrentRTFP) then exit;
  if not CurrentRTFP.IsOpen then exit;
  CurrentRTFP.OpenPaperAsPdf(Self.DataSource_Main.DataSet.FieldByName(_Col_PID_).AsString);
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

procedure TFormDesktop.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  //
end;

procedure TFormDesktop.CheckListBox_MainAttrFilterClickCheck(Sender: TObject);
//var attrNo:byte;
begin
  if not assigned(CurrentRTFP) then exit;
  if CurrentRTFP.IsOpen then begin
    CurrentRTFP.TableValidate(Self.MainAttrFilterSet);
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
  ty:=CurrentRTFP.AttrFieldDataTypeS[attrName,fieldName];
  Self.Button_FmtCmt_Post.Enabled:=(ty=ftMemo);
end;

procedure TFormDesktop.Button_NodeViewPostClick(Sender: TObject);
begin
  StopGridConnect;
  NodeViewDataPost;
end;

procedure TFormDesktop.Button_NodeViewAddAttrClick(Sender: TObject);
begin
  ///////
end;

procedure TFormDesktop.Button_FmtCmt_PostClick(Sender: TObject);
var PID:RTFP_ID;
    attrNa,fieldNa:string;
begin
  PID:=Selected_PID;
  if PID='000000' then exit;
  if (ComboBox_AttrName.ItemIndex>=0) and (ComboBox_FieldName.ItemIndex>=0) then begin
    attrNa:=ComboBox_AttrName.Items[ComboBox_AttrName.ItemIndex];
    fieldNa:=ComboBox_FieldName.Items[ComboBox_FieldName.ItemIndex];
    CurrentRTFP.FmtCmtDataPost(PID,attrNa,fieldNa,Memo_FmtCmt);
  end;
end;

procedure TFormDesktop.Button_FmtCmt_RecoverClick(Sender: TObject);
var PID:RTFP_ID;
    attrNa,fieldNa:string;
begin
  PID:=Selected_PID;
  if PID='000000' then exit;
  if (ComboBox_AttrName.ItemIndex>=0) and (ComboBox_FieldName.ItemIndex>=0) then begin
    attrNa:=ComboBox_AttrName.Items[ComboBox_AttrName.ItemIndex];
    fieldNa:=ComboBox_FieldName.Items[ComboBox_FieldName.ItemIndex];
    CurrentRTFP.FmtCmtValidate(PID,attrNa,fieldNa,Memo_FmtCmt);
  end;
end;

procedure TFormDesktop.Button_NodeViewRecoverClick(Sender: TObject);
begin
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

procedure TFormDesktop.ComboBox_Attrs_ViewChange(Sender: TObject);
var pi:integer;
begin
  pi:=(Sender as TComboBox).ItemIndex;
  if pi>=0 then DataSource_Attrs.DataSet:=((Sender as TComboBox).Items.Objects[pi] as TDbf);
  //在关闭工程以后 ，这里有一个错误
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
  CurrentRTFP.TableFilter((Sender as TEdit).Caption);
end;


procedure TFormDesktop.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if assigned(CurrentRTFP) then begin
    if CurrentRTFP.IsOpen then
      if not CurrentRTFP.Close then CanClose:=false;
  end;
end;


end.

