unit form_classmanager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Menus, StdCtrls;

type

  { TClassManagerForm }

  TClassManagerForm = class(TForm)
    Button_ClsMgr_SelectAll: TButton;
    Button_ClsMgr_UnSelect: TButton;
    Button_ClsMgr_XorSelect: TButton;
    MenuItem_ClsMgr_Include: TMenuItem;
    MenuItem_ClsMgr_Exclude: TMenuItem;
    Panel_ListView_Temporary: TPanel;
    Panel_DBGrid_Temporary: TPanel;
    PopupMenu_ClassManager: TPopupMenu;
    Splitter_ClsMgrV: TSplitter;
    procedure Button_ClsMgr_SelectAllClick(Sender: TObject);
    procedure Button_ClsMgr_UnSelectClick(Sender: TObject);
    procedure Button_ClsMgr_XorSelectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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
uses RTFP_main, RTFP_definition, RTFP_constants, rtfp_type, rtfp_class, rtfp_dialog,
  DBGrids, db, ListCheck;

{$R *.lfm}

{ TClassManagerForm }

procedure TClassManagerForm.FormShow(Sender: TObject);
begin
  FormDesktop.Panel_DBGridMain.Parent:=Self.Panel_DBGrid_Temporary;
  FormDesktop.Panel_DBGridMain.Align:=alClient;
  FormDesktop.DBGrid_Main.PopupMenu:=nil;
  FormDesktop.DBGrid_Main.Options:=FormDesktop.DBGrid_Main.Options + [dgMultiselect];
  //FormDesktop.DBGrid_Main.SelectedIndex:=FormDesktop.DBGrid_Main.DataSource.DataSet.RecNo;
  FormDesktop.DBGrid_Main.SelectedRows.CurrentRowSelected:=true;
  FormDesktop.AListView_Klass.Parent:=Self.Panel_ListView_Temporary;
  FormDesktop.AListView_Klass.Align:=alClient;
  FormDesktop.AListView_Klass.PopupMenu:=Self.PopupMenu_ClassManager;
end;

procedure TClassManagerForm.MenuItem_ClsMgr_ExcludeClick(Sender: TObject);
var tmpKL:TKlass;
    index:integer;
    arr:array of RTFP_ID;
    max:integer;
    PID:RTFP_ID;
begin
  if ProjectInvalid then exit;
  tmpKL:=TKlass(FormDesktop.AListView_Klass.Selected.Data);
  if tmpKL=nil then begin
    ShowMsgOK('排除分组','无效的分类，无法执行操作。');
    exit;
  end;
  FormDesktop.DBGrid_Main.Visible:=false;
  max:=FormDesktop.DBGrid_Main.SelectedRows.Count;
  SetLength(arr,max);
  CurrentRTFP.BeginUpdate;
  with CurrentRTFP do
    begin
      if not PaperDS.Active then PaperDS.Open;
      for index:=0 to max-1 do
        begin
          PaperDS.GotoBookmark(FormDesktop.DBGrid_Main.SelectedRows.Items[index]);
          PID:=PaperDS.FieldByName(_Col_PID_).AsString;
          arr[index]:=PID;
        end;
      for index:=0 to max-1 do KlassExclude(tmpKL.KlassNameWithDelimiter('.'),arr[index]);

    end;
  CurrentRTFP.EndUpdate;
  FormDesktop.DBGrid_Main.Visible:=true;
  CurrentRTFP.RebuildMainGrid;//FormDesktop.MainGridValidate(CurrentRTFP);//CurrentRTFP.DataChange;
  SetLength(arr,0);
end;

procedure TClassManagerForm.MenuItem_ClsMgr_IncludeClick(Sender: TObject);
var tmpKL:TKlass;
    index:integer;
    arr:array of RTFP_ID;
    max:integer;
    PID:RTFP_ID;
begin
  if ProjectInvalid then exit;
  tmpKL:=TKlass(FormDesktop.AListView_Klass.Selected.Data);
  if tmpKL=nil then begin
    ShowMsgOK('纳入分组','无效的分类，无法执行操作。');
    exit;
  end;
  FormDesktop.DBGrid_Main.Visible:=false;
  max:=FormDesktop.DBGrid_Main.SelectedRows.Count;
  SetLength(arr,max);
  CurrentRTFP.BeginUpdate;
  with CurrentRTFP do
    begin
      if not PaperDS.Active then PaperDS.Open;
      for index:=0 to max-1 do
        begin
          PaperDS.GotoBookmark(FormDesktop.DBGrid_Main.SelectedRows.Items[index]);
          PID:=PaperDS.FieldByName(_Col_PID_).AsString;
          arr[index]:=PID;
        end;
      for index:=0 to max-1 do KlassInclude(tmpKL.KlassNameWithDelimiter('.'),arr[index]);

    end;
  CurrentRTFP.EndUpdate;
  FormDesktop.DBGrid_Main.Visible:=true;
  CurrentRTFP.RebuildMainGrid;//FormDesktop.MainGridValidate(CurrentRTFP);//CurrentRTFP.DataChange;
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

procedure TClassManagerForm.Button_ClsMgr_SelectAllClick(Sender: TObject);
var bm:TBookMark;
begin
  if FormDesktop.DBGrid_Main.DataSource.DataSet=nil then exit;
  with FormDesktop.DBGrid_Main do
    begin
      bm:=DataSource.DataSet.Bookmark;
      DataSource.DataSet.DisableControls;
      DataSource.DataSet.First;
      while not DataSource.DataSet.EOF do
        begin
          SelectedRows.CurrentRowSelected:=true;
          DataSource.DataSet.Next;
        end;
      DataSource.DataSet.EnableControls;
      DataSource.DataSet.GotoBookmark(bm);
    end;
end;

procedure TClassManagerForm.Button_ClsMgr_UnSelectClick(Sender: TObject);
var bm:TBookMark;
begin
  if FormDesktop.DBGrid_Main.DataSource.DataSet=nil then exit;
  with FormDesktop.DBGrid_Main do
    begin
      bm:=DataSource.DataSet.Bookmark;
      DataSource.DataSet.DisableControls;
      DataSource.DataSet.First;
      while not DataSource.DataSet.EOF do
        begin
          SelectedRows.CurrentRowSelected:=false;
          DataSource.DataSet.Next;
        end;
      DataSource.DataSet.EnableControls;
      DataSource.DataSet.GotoBookmark(bm);
    end;
end;

procedure TClassManagerForm.Button_ClsMgr_XorSelectClick(Sender: TObject);
var bm:TBookMark;
begin
  if FormDesktop.DBGrid_Main.DataSource.DataSet=nil then exit;
  with FormDesktop.DBGrid_Main do
    begin
      bm:=DataSource.DataSet.Bookmark;
      DataSource.DataSet.DisableControls;
      DataSource.DataSet.First;
      while not DataSource.DataSet.EOF do
        begin
          SelectedRows.CurrentRowSelected:=not SelectedRows.CurrentRowSelected;
          DataSource.DataSet.Next;
        end;
      DataSource.DataSet.EnableControls;
      DataSource.DataSet.GotoBookmark(bm);
    end;
end;

procedure TClassManagerForm.FormCreate(Sender: TObject);
begin
  if Self.Height>Screen.Height then Self.Height:=trunc(Screen.Height*0.8);
  if Self.Width>Screen.Width then Self.Height:=trunc(Screen.Width*0.8);
end;

end.

