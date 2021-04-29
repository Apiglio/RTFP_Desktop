unit RTFP_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, dbf, memds, FileUtil, Forms, Controls, Graphics,
  Dialogs, ComCtrls, Menus, ExtCtrls, DBGrids, Grids, ValEdit, CheckLst,
  StdCtrls, LazUTF8,

  Apiglio_Useful, AufScript_Frame,

  RTFP_definition;

const
  C_VERSION_NUMBER  = '0.1.0-alpha.3';
  C_SOFTWARE_NAME   = 'RTFP Desktop';
  C_SOFTWARE_AUTHOR = 'Apiglio';


type

  { TFormDesktop }

  TFormDesktop = class(TForm)
    CheckListBox_MainAttrFilter: TCheckListBox;
    ComboBox_Attrs_View: TComboBox;
    DataSource_Attrs: TDataSource;
    DataSource_Main: TDataSource;
    DBGrid_Attrs: TDBGrid;
    DBGrid_Main: TDBGrid;
    Frame_AufScript1: TFrame_AufScript;
    Label_Attrs_View: TLabel;
    MainMenu: TMainMenu;
    MemDataset_Main: TMemDataset;
    MenuItem1: TMenuItem;
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
    Panel_Release: TPanel;
    SaveDialog_project: TSaveDialog;
    Splitter_RightH: TSplitter;
    Splitter_MainV: TSplitter;
    StatusBar: TStatusBar;
    TabSheet_Project_Properties: TTabSheet;
    TabSheet_Node_PDF: TTabSheet;
    TabSheet_Project_Class: TTabSheet;
    TabSheet_Project_Attrs: TTabSheet;
    TabSheet_Node_Edit: TTabSheet;
    TabSheet_Node_View: TTabSheet;
    TabSheet_Project_AufScript: TTabSheet;
    TabSheet_Project_DataGrid: TTabSheet;
    PropertiesValueListEditor: TValueListEditor;
    procedure CheckListBox_MainAttrFilterClickCheck(Sender: TObject);
    procedure ComboBox_Attrs_ViewChange(Sender: TObject);
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

  public
    //RTFP类事件，Sender参数为TRTFP类
    procedure EventLink(Sender:TRTFP);//链接所有事件

    procedure Validate(Sender:TObject);//更新显示
    procedure FirstEdit(Sender:TObject);//工程第一次编辑
    procedure Clear(Sender:TObject);//清空

    procedure ProjectOpenDone(Sender:TObject);//工程打开或新建
    procedure ProjectCloseDone(Sender:TObject);//工程关闭
    procedure ProjectSaveDone(Sender:TObject);//工程保存




  end;

var
  FormDesktop: TFormDesktop;
  CurrentRTFP:TRTFP;

implementation
uses form_new_project, form_cite_trans;

{$R *.lfm}

{ TFormDesktop }

procedure TFormDesktop.EventLink(Sender:TRTFP);//链接所有事件
begin
  Sender.onNewDone:=@ProjectOpenDone;
  Sender.onOpenDone:=@ProjectOpenDone;
  Sender.onFirstEdit:=@FirstEdit;
  Sender.onSaveDone:=@ProjectSaveDone;
  Sender.onCloseDone:=@ProjectCloseDone;
end;

procedure TFormDesktop.Validate(Sender:TObject);
var changed_str:string;
    attr_i,pi:integer;
    stmp,old_choice:string;
begin

  if (Sender as TRTFP).IsChanged then changed_str:=' *'
  else changed_str:='';

  if (Sender as TRTFP).Title <> '' then
    Self.Caption:=C_SOFTWARE_NAME+' - '+(Sender as TRTFP).Title + changed_str
  else
    Self.Caption:=C_SOFTWARE_NAME;

  Self.PropertiesValueListEditor.Values['工程标题']:=(Sender as TRTFP).Title;
  Self.PropertiesValueListEditor.Values['创建用户']:=(Sender as TRTFP).User;

  Self.PropertiesValueListEditor.Values['创建日期']:=(Sender as TRTFP).Tag['创建日期'];
  Self.PropertiesValueListEditor.Values['修改日期']:=(Sender as TRTFP).Tag['修改日期'];

  Self.PropertiesValueListEditor.Values['属性组00']:=(Sender as TRTFP).Tag['属性组00'];
  Self.PropertiesValueListEditor.Values['属性组01']:=(Sender as TRTFP).Tag['属性组01'];
  Self.PropertiesValueListEditor.Values['属性组02']:=(Sender as TRTFP).Tag['属性组02'];

  pi:=Self.ComboBox_Attrs_View.ItemIndex;
  if pi>=0 then old_choice:=Self.ComboBox_Attrs_View.Items[pi] else old_choice:='';
  with Self.ComboBox_Attrs_View do begin
    Clear;
    attr_i:=0;
    repeat
      stmp:=CurrentRTFP.AttrsName[attr_i];
      if stmp<>'' then ComboBox_Attrs_View.AddItem(stmp,CurrentRTFP.AttrsDB[attr_i])
      else break;
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
  len:=Length(FileNames);
  {
  //Self.Panel_Release.Caption:=IntToStr(len);
  if len=1 then Self.Panel_Release.Caption:=FileNames[0]
  else Self.Panel_Release.Caption:='多个文件';
  }
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
  //修改属性组的显隐状态时
  //(Sender as TCheckListBox).Checked[0];
  {tmp}
  if not assigned(CurrentRTFP) then exit;
  if CurrentRTFP.IsOpen then Self.DataSource_Main.DataSet:=CurrentRTFP.PaperDB;

end;

procedure TFormDesktop.ComboBox_Attrs_ViewChange(Sender: TObject);
var pi:integer;
begin
  pi:=(Sender as TComboBox).ItemIndex;
  if pi>=0 then DataSource_Attrs.DataSet:=((Sender as TComboBox).Items.Objects[pi] as TDbf);
end;

procedure TFormDesktop.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if assigned(CurrentRTFP) then begin
    if CurrentRTFP.IsOpen then
      if not CurrentRTFP.Close then CanClose:=false;
  end;
end;


end.

