unit form_classmanager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Menus;

type

  { TClassManagerForm }

  TClassManagerForm = class(TForm)
    MenuItem_ClsMgr_Include: TMenuItem;
    MenuItem_ClsMgr_Exclude: TMenuItem;
    Panel_ListView_Temporary: TPanel;
    Panel_DBGrid_Temporary: TPanel;
    PopupMenu_ClassManager: TPopupMenu;
    procedure FormDeactivate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItem_ClsMgr_ExcludeClick(Sender: TObject);
    procedure MenuItem_ClsMgr_IncludeClick(Sender: TObject);
  private

  public

  end;

var
  ClassManagerForm: TClassManagerForm;

implementation
uses RTFP_main, RTFP_definition, RTFP_constants, DBGrids, db, ACL_ListView, rtfp_class;

{$R *.lfm}

{ TClassManagerForm }

procedure TClassManagerForm.FormShow(Sender: TObject);
begin
  FormDesktop.Panel_DBGridMain.Parent:=Self.Panel_DBGrid_Temporary;
  FormDesktop.Panel_DBGridMain.Align:=alClient;
  FormDesktop.DBGrid_Main.PopupMenu:=nil;
  FormDesktop.DBGrid_Main.Options:=FormDesktop.DBGrid_Main.Options + [dgMultiselect];
  FormDesktop.AListView_Klass.Parent:=Self.Panel_ListView_Temporary;
  FormDesktop.AListView_Klass.Align:=alClient;
  FormDesktop.AListView_Klass.PopupMenu:=Self.PopupMenu_ClassManager;
end;

procedure TClassManagerForm.MenuItem_ClsMgr_ExcludeClick(Sender: TObject);
var tmpKL:TKlass;
    index:integer;
    arr:array of TBookMark;
    max:integer;
    PID:RTFP_ID;
begin
  if ProjectInvalid then exit;
  tmpKL:=TKlass(TACL_TreeNode(FormDesktop.AListView_Klass.Selected.Data).Data);
  if tmpKL=nil then begin
    ShowMessage('无效的分类。');
    exit;
  end;
  max:=FormDesktop.DBGrid_Main.SelectedRows.Count;
  SetLength(arr,max);
  for index:=0 to max-1 do arr[index]:=FormDesktop.DBGrid_Main.SelectedRows.Items[index];
  CurrentRTFP.BeginUpdate;
  for index:=0 to max-1 do
    begin
      with CurrentRTFP do
        begin
          if not PaperDS.Active then PaperDS.Open;
          PaperDS.GotoBookmark(arr[index]);
          PID:=PaperDS.FieldByName(_Col_PID_).AsString;
          KlassExclude(tmpKL.Name,PID);
        end;
    end;
  CurrentRTFP.EndUpdate;
  CurrentRTFP.DataChange;
  SetLength(arr,0);
end;

procedure TClassManagerForm.MenuItem_ClsMgr_IncludeClick(Sender: TObject);
var tmpKL:TKlass;
    index:integer;
    arr:array of TBookMark;
    max:integer;
    PID:RTFP_ID;
begin
  if ProjectInvalid then exit;
  tmpKL:=TKlass(TACL_TreeNode(FormDesktop.AListView_Klass.Selected.Data).Data);
  if tmpKL=nil then begin
    ShowMessage('无效的分类。');
    exit;
  end;
  max:=FormDesktop.DBGrid_Main.SelectedRows.Count;
  SetLength(arr,max);
  for index:=0 to max-1 do arr[index]:=FormDesktop.DBGrid_Main.SelectedRows.Items[index];
  CurrentRTFP.BeginUpdate;
  for index:=0 to max-1 do
    begin
      with CurrentRTFP do
        begin
          if not PaperDS.Active then PaperDS.Open;
          PaperDS.GotoBookmark(arr[index]);
          PID:=PaperDS.FieldByName(_Col_PID_).AsString;
          KlassInclude(tmpKL.Name,PID);
        end;
    end;
  CurrentRTFP.EndUpdate;
  CurrentRTFP.DataChange;
  SetLength(arr,0);
end;

procedure TClassManagerForm.FormHide(Sender: TObject);
begin
  FormDesktop.Panel_DBGridMain.Parent:=FormDesktop.TabSheet_Project_DataGrid;
  FormDesktop.Panel_DBGridMain.Align:=alClient;
  FormDesktop.DBGrid_Main.PopupMenu:=FormDesktop.PopupMenu_MainDBGrid;
  FormDesktop.DBGrid_Main.Options:=FormDesktop.DBGrid_Main.Options - [dgMultiselect];
  FormDesktop.AListView_Klass.Parent:=FormDesktop.TabSheet_Filter_Klass;
  FormDesktop.AListView_Klass.Align:=alClient;
  FormDesktop.AListView_Klass.PopupMenu:=FormDesktop.PopupMenu_ClassManager;
end;

procedure TClassManagerForm.FormDeactivate(Sender: TObject);
begin
  //Self.Hide;
end;

end.

