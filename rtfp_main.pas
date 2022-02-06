unit RTFP_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, dbf, memds, FileUtil, Forms, Controls, Graphics,
  Dialogs, ComCtrls, Menus, ExtCtrls, DBGrids, Grids, ValEdit, CheckLst,
  StdCtrls, LazUTF8,

  AufScript_Frame,

  RTFP_definition, Types;

const
  C_VERSION_NUMBER  = '0.1.0-alpha.6';
  C_SOFTWARE_NAME   = 'RTFP Desktop';
  C_SOFTWARE_AUTHOR = 'Apiglio';


type

  { TFormDesktop }

  TFormDesktop = class(TForm)
    Button_NodeViewAddAttr: TButton;
    Button_NodeViewPost: TButton;
    Button_NodeViewRecover: TButton;
    CheckListBox_MainAttrFilter: TCheckListBox;
    ComboBox_Attrs_View: TComboBox;
    DataSource_Attrs: TDataSource;
    DataSource_Main: TDataSource;
    DBGrid_Attrs: TDBGrid;
    DBGrid_Main: TDBGrid;
    Frame_AufScript1: TFrame_AufScript;
    Image_PDF_View: TImage;
    Label_Attrs_View: TLabel;
    MainMenu: TMainMenu;
    MemDataset_Main: TMemDataset;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem_project_recent: TMenuItem;
    MenuItem_ImportFromOther: TMenuItem;
    MenuItem_ExportToOther: TMenuItem;
    MenuItem_CIteTool: TMenuItem;
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
    PageControl_Node: TPageControl;
    PageControl_Project: TPageControl;
    Panel_DBGridMain: TPanel;
    Panel_Release: TPanel;
    SaveDialog_project: TSaveDialog;
    Splitter_RightH: TSplitter;
    Splitter_MainV: TSplitter;
    StatusBar: TStatusBar;
    TabSheet_Project_Properties: TTabSheet;
    TabSheet_Node_PDF: TTabSheet;
    TabSheet_Project_Class: TTabSheet;
    TabSheet_Project_Attrs: TTabSheet;
    TabSheet_Node_View: TTabSheet;
    TabSheet_Project_AufScript: TTabSheet;
    TabSheet_Project_DataGrid: TTabSheet;
    PropertiesValueListEditor: TValueListEditor;
    ValueListEditor_NodeView: TValueListEditor;
    procedure Button_NodeViewAddAttrClick(Sender: TObject);
    procedure Button_NodeViewPostClick(Sender: TObject);
    procedure Button_NodeViewRecoverClick(Sender: TObject);
    procedure CheckListBox_MainAttrFilterClickCheck(Sender: TObject);
    procedure ComboBox_Attrs_ViewChange(Sender: TObject);
    procedure DBGrid_MainCellClick(Column: TColumn);
    procedure DBGrid_MainKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBGrid_MainMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure FormResize(Sender: TObject);
    procedure MenuItem_CIteToolClick(Sender: TObject);
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
    function Selected_PID:RTFP_ID;//根据DBGrid_Main的选择返回PID

  public
    //RTFP类事件，Sender参数为TRTFP类
    procedure EventLink(Sender:TRTFP);//链接所有事件

    procedure Validate(Sender:TObject);//更新显示
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
uses form_new_project, form_cite_trans, form_import;

{$R *.lfm}

{ TFormDesktop }

procedure TFormDesktop.EventLink(Sender:TRTFP);//链接所有事件
begin
  Sender.onNewDone:=@ProjectOpenDone;
  Sender.onOpenDone:=@ProjectOpenDone;
  Sender.onFirstEdit:=@FirstEdit;
  Sender.onSaveDone:=@ProjectSaveDone;
  Sender.onCloseDone:=@ProjectCloseDone;
  Sender.onChange:=@Validate;
end;

procedure TFormDesktop.Validate(Sender:TObject);
var changed_str:string;
    attr_i,pi:integer;
    stmp,old_choice:string;

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
  {
  Self.PropertiesValueListEditor.Values['工程标题']:=(Sender as TRTFP).Title;
  Self.PropertiesValueListEditor.Values['创建用户']:=(Sender as TRTFP).User;

  Self.PropertiesValueListEditor.Values['创建日期']:=(Sender as TRTFP).Tag['创建日期'];
  Self.PropertiesValueListEditor.Values['修改日期']:=(Sender as TRTFP).Tag['修改日期'];

  Self.PropertiesValueListEditor.Values['属性组00']:=(Sender as TRTFP).Tag['属性组00'];
  Self.PropertiesValueListEditor.Values['属性组01']:=(Sender as TRTFP).Tag['属性组01'];
  Self.PropertiesValueListEditor.Values['属性组02']:=(Sender as TRTFP).Tag['属性组02'];
  }

  //文献节点 & 文献属性组 标签页
  //{}Self.DataSource_Main.DataSet:=CurrentRTFP.PaperDB;

  CurrentRTFP.TableValidate(Self.MemDataset_Main,Self.MainAttrFilterSet);
  //Self.DBGrid_Main.Columns[0].DisplayName:='c0';
  //Self.DBGrid_Main.Columns[1].DisplayName:='c1';
  //Self.DBGrid_Main.Columns[2].DisplayName:='c2';
  //没用？？

  {}Self.DataSource_Main.DataSet:=Self.MemDataset_Main;
  {}Self.CheckListBox_MainAttrFilter.Items.Clear;

  pi:=Self.ComboBox_Attrs_View.ItemIndex;
  if pi>=0 then old_choice:=Self.ComboBox_Attrs_View.Items[pi] else old_choice:='';
  with Self.ComboBox_Attrs_View do begin
    Clear;
    attr_i:=0;
    repeat
      stmp:=CurrentRTFP.AttrsName[attr_i];
      if stmp<>'' then begin
        ComboBox_Attrs_View.AddItem(stmp,CurrentRTFP.AttrsDB[attr_i]);
        {}Self.CheckListBox_MainAttrFilter.Items.Add(stmp);
      end else break;
      inc(attr_i);
    until attr_i>99;
  end;
  attr_i:=0;
  pi:=-1;
  for stmp in Self.ComboBox_Attrs_View.Items do
    begin
      if stmp=old_choice then pi:=attr_i;
      inc(attr_i);
    end;
  Self.ComboBox_Attrs_View.ItemIndex:=pi;
  Self.ComboBox_Attrs_View.OnChange(Self.ComboBox_Attrs_View);

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
  Self.MemDataset_Main.Clear;
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

function TFormDesktop.Selected_PID:RTFP_ID;
begin
  result:='000000';
  if not DBGrid_Main.DataSource.DataSet.Active then exit;
  result:=DBGrid_Main.DataSource.DataSet.Fields.FieldByName('PID').AsString;
end;

procedure TFormDesktop.ViewPdfValidate;
begin
  //
end;

procedure TFormDesktop.NodeViewValidate;
var PID:RTFP_ID;
begin
  PID:=Selected_PID;
  ValueListEditor_NodeView.Clear;
  if PID='000000' then exit;
  CurrentRTFP.NodeViewValidate(PID,ValueListEditor_NodeView);
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
    CurrentRTFP.Open(Self.OpenDialog_Project.FileName);
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

procedure TFormDesktop.MenuItem_CIteToolClick(Sender: TObject);
begin
  Form_CiteTrans.show;
end;

procedure TFormDesktop.MenuItem_option_aboutClick(Sender: TObject);
begin
  MessageDlg('关于',C_SOFTWARE_NAME + #13#10 + '版本： ' + C_VERSION_NUMBER + #13#10 + '作者： ' + C_SOFTWARE_AUTHOR,mtCustom,[mbOK],0);
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
  if assigned(CurrentRTFP) then
    begin
      if CurrentRTFP.IsOpen then
        begin
          CurrentRTFP.Title:=Utf8ToWinCP(Self.PropertiesValueListEditor.Values['工程标题']);
          CurrentRTFP.User:=Utf8ToWinCP(Self.PropertiesValueListEditor.Values['创建用户']);
        end;
    end;
end;

procedure TFormDesktop.FormCreate(Sender: TObject);
begin
  Self.Frame_AufScript1.AufGenerator;
  AufScriptFuncDefineRTFP(Self.Frame_AufScript1.Auf);
  Self.Frame_AufScript1.HighLighterReNew;

  //CurrentRTFP:=TRTFP.Create(Self);
end;

procedure TFormDesktop.FormDropFiles(Sender: TObject;
  const FileNames: array of String);
var len,pi:integer;
begin
  if not assigned(CurrentRTFP) then exit;
  if not CurrentRTFP.IsOpen then exit;
  len:=Length(FileNames);

  Form_ImportFiles.Show;

  for pi:=0 to len-1 do
    begin
      if CurrentRTFP.FindPaper(FileNames[pi]) = '000000' then
        CurrentRTFP.AddPaper(FileNames[pi])
      else
        ShowMessage(FileNames[pi]+'已在库内。');
    end;
end;

procedure TFormDesktop.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  //
end;

procedure TFormDesktop.CheckListBox_MainAttrFilterClickCheck(Sender: TObject);
begin
  if not assigned(CurrentRTFP) then exit;
  if CurrentRTFP.IsOpen then
  CurrentRTFP.TableValidate(Self.MemDataset_Main,Self.MainAttrFilterSet);
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

procedure TFormDesktop.Button_NodeViewRecoverClick(Sender: TObject);
begin
  NodeViewValidate;
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
  //ShowMessage(IntToStr((Self.DBGrid_Main).DataSource.DataSet.RecNo));
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
  NodeViewValidate;
end;

procedure TFormDesktop.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if assigned(CurrentRTFP) then begin
    if CurrentRTFP.IsOpen then
      if not CurrentRTFP.Close then CanClose:=false;
  end;
end;


end.

