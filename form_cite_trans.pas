unit form_cite_trans;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DBGrids, ExtCtrls, ComCtrls;

type

  { TForm_CiteTrans }

  TForm_CiteTrans = class(TForm)
    Button_ImportRefs: TButton;
    Button_ExportRefs: TButton;
    Button_ImportCite: TButton;
    Button_ExportCite: TButton;
    Memo_Reference: TMemo;
    Memo_Cite: TMemo;
    Panel_DBGrid_Temporary: TPanel;
    TabControl_CiteStyle: TTabControl;
    TabControl_Reference_Style: TTabControl;
    procedure Button_ExportCiteClick(Sender: TObject);
    procedure Button_ExportRefsClick(Sender: TObject);
    procedure Button_ImportCiteClick(Sender: TObject);
    procedure Button_ImportRefsClick(Sender: TObject);
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
uses RTFP_main, RTFP_definition;

{$R *.lfm}

{ TForm_CiteTrans }

procedure TForm_CiteTrans.FormDeactivate(Sender: TObject);
begin
  Self.Hide;
end;

procedure TForm_CiteTrans.Button_ExportCiteClick(Sender: TObject);
begin
  /////////
end;

procedure TForm_CiteTrans.Button_ExportRefsClick(Sender: TObject);
begin
  ////////////
end;

procedure TForm_CiteTrans.Button_ImportCiteClick(Sender: TObject);
begin
  CurrentRTFP.LoadFromEndNote(FormDesktop.Selected_PID,Memo_Cite.Lines);
  FormDesktop.Validate(CurrentRTFP);
end;

procedure TForm_CiteTrans.Button_ImportRefsClick(Sender: TObject);
begin
  ///////////
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

