unit form_cite_trans;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ValEdit, DBGrids, ExtCtrls, ComCtrls;

type

  { TForm_CiteTrans }

  TForm_CiteTrans = class(TForm)
    Button_Import: TButton;
    Button_Export: TButton;
    Memo_Reference: TMemo;
    Memo_Cite: TMemo;
    Panel_DBGrid_Temporary: TPanel;
    TabControl_CiteStyle: TTabControl;
    TabControl_Reference_Style: TTabControl;
    ValueListEditor1: TValueListEditor;
    procedure FormDeactivate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  Form_CiteTrans: TForm_CiteTrans;

implementation
uses RTFP_main;

{$R *.lfm}

{ TForm_CiteTrans }

procedure TForm_CiteTrans.FormDeactivate(Sender: TObject);
begin
  Self.Hide;
end;

procedure TForm_CiteTrans.FormDropFiles(Sender: TObject;
  const FileNames: array of String);
begin
  Memo_Cite.Lines.LoadFromFile(FileNames[0]);
end;

procedure TForm_CiteTrans.FormHide(Sender: TObject);
begin
  FormDesktop.Panel_DBGridMain.Parent:=FormDesktop.TabSheet_Project_DataGrid;
  FormDesktop.Panel_DBGridMain.Align:=alClient;
end;

procedure TForm_CiteTrans.FormShow(Sender: TObject);
begin
  FormDesktop.Panel_DBGridMain.Parent:=Self.Panel_DBGrid_Temporary;
  FormDesktop.Panel_DBGridMain.Align:=alClient;
end;

end.

