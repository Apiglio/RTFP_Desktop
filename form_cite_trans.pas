unit form_cite_trans;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DBGrids, ExtCtrls, ComCtrls;

type

  { TForm_CiteTrans }

  TForm_CiteTrans = class(TForm)
    Button_ImportPapers: TButton;
    Button_ImportRefs: TButton;
    Button_ExportRefs: TButton;
    Button_ImportCite: TButton;
    Button_ExportCite: TButton;
    Memo_Reference: TMemo;
    Memo_Cite: TMemo;
    PaintBox_Arrows: TPaintBox;
    Panel_DBGrid_Temporary: TPanel;
    TabControl_CiteStyle: TTabControl;
    TabControl_Reference_Style: TTabControl;
    procedure Button_ExportCiteClick(Sender: TObject);
    procedure Button_ExportRefsClick(Sender: TObject);
    procedure Button_ImportCiteClick(Sender: TObject);
    procedure Button_ImportPapersClick(Sender: TObject);
    procedure Button_ImportRefsClick(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PaintBox_ArrowsPaint(Sender: TObject);
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
  if TabControl_CiteStyle.TabIndex<0 then exit;
  case TabControl_CiteStyle.Tabs[TabControl_CiteStyle.TabIndex] of
    'E-Study':CurrentRTFP.SaveToEStudy(FormDesktop.Selected_PID,Memo_Cite.Lines);
    'RefWorks':CurrentRTFP.SaveToRefWork(FormDesktop.Selected_PID,Memo_Cite.Lines);
    'EndNote':CurrentRTFP.SaveToEndNote(FormDesktop.Selected_PID,Memo_Cite.Lines);
    'NoteExpress':CurrentRTFP.SaveToNoteExpress(FormDesktop.Selected_PID,Memo_Cite.Lines);
    'NoteFirst':CurrentRTFP.SaveToNoteFirst(FormDesktop.Selected_PID,Memo_Cite.Lines);
    'RIS':CurrentRTFP.SaveToRIS(FormDesktop.Selected_PID,Memo_Cite.Lines);
    else exit;
  end;
  //FormDesktop.Validate(CurrentRTFP);
end;

procedure TForm_CiteTrans.Button_ExportRefsClick(Sender: TObject);
begin
  if TabControl_Reference_Style.TabIndex<0 then exit;
  case TabControl_Reference_Style.Tabs[TabControl_Reference_Style.TabIndex] of
    'GB/T 7714':Memo_Reference.Lines.CommaText:=CurrentRTFP.GetGBT7714(FormDesktop.Selected_PID);
    'CAJ-CD':Memo_Reference.Lines.CommaText:=CurrentRTFP.GetCAJCD(FormDesktop.Selected_PID);
    'MLA':Memo_Reference.Lines.CommaText:=CurrentRTFP.GetMLA(FormDesktop.Selected_PID);
    'APA':Memo_Reference.Lines.CommaText:=CurrentRTFP.GetAPA(FormDesktop.Selected_PID);
    '查新':Memo_Reference.Lines.CommaText:=CurrentRTFP.GetChaXin(FormDesktop.Selected_PID);
  end;
  //FormDesktop.Validate(CurrentRTFP);
end;

procedure TForm_CiteTrans.Button_ImportCiteClick(Sender: TObject);
begin
  if TabControl_CiteStyle.TabIndex<0 then exit;
  case TabControl_CiteStyle.Tabs[TabControl_CiteStyle.TabIndex] of
    'E-Study':CurrentRTFP.LoadFromEStudy(FormDesktop.Selected_PID,Memo_Cite.Lines);
    'RefWorks':CurrentRTFP.LoadFromRefWork(FormDesktop.Selected_PID,Memo_Cite.Lines);
    'EndNote':CurrentRTFP.LoadFromEndNote(FormDesktop.Selected_PID,Memo_Cite.Lines);
    'NoteExpress':CurrentRTFP.LoadFromNoteExpress(FormDesktop.Selected_PID,Memo_Cite.Lines);
    'NoteFirst':CurrentRTFP.LoadFromNoteFirst(FormDesktop.Selected_PID,Memo_Cite.Lines);
    'RIS':CurrentRTFP.LoadFromRIS(FormDesktop.Selected_PID,Memo_Cite.Lines);
    else exit;
  end;
  FormDesktop.Validate(CurrentRTFP);
end;

procedure TForm_CiteTrans.Button_ImportPapersClick(Sender: TObject);
begin
  if TabControl_CiteStyle.TabIndex<0 then exit;
  case TabControl_CiteStyle.Tabs[TabControl_CiteStyle.TabIndex] of
    'E-Study':CurrentRTFP.ImportPapersFromEStudy(Memo_Cite.Lines);
    'RefWorks':CurrentRTFP.ImportPapersFromRefWork(Memo_Cite.Lines);
    'EndNote':CurrentRTFP.ImportPapersFromEndNote(Memo_Cite.Lines);
    'NoteExpress':CurrentRTFP.ImportPapersFromNoteExpress(Memo_Cite.Lines);
    'NoteFirst':CurrentRTFP.ImportPapersFromNoteFirst(Memo_Cite.Lines);
    'RIS':CurrentRTFP.ImportPapersFromRIS(Memo_Cite.Lines);
    else exit;
  end;
  FormDesktop.Validate(CurrentRTFP);
end;

procedure TForm_CiteTrans.Button_ImportRefsClick(Sender: TObject);
begin
  if TabControl_Reference_Style.TabIndex<0 then exit;
  case TabControl_Reference_Style.Tabs[TabControl_Reference_Style.TabIndex] of
    'GB/T 7714':CurrentRTFP.SetGBT7714(FormDesktop.Selected_PID,Memo_Reference.Lines.CommaText);
    'CAJ-CD':CurrentRTFP.SetCAJCD(FormDesktop.Selected_PID,Memo_Reference.Lines.CommaText);
    'MLA':CurrentRTFP.SetMLA(FormDesktop.Selected_PID,Memo_Reference.Lines.CommaText);
    'APA':CurrentRTFP.SetAPA(FormDesktop.Selected_PID,Memo_Reference.Lines.CommaText);
    '查新':CurrentRTFP.SetChaXin(FormDesktop.Selected_PID,Memo_Reference.Lines.CommaText);
  end;
  FormDesktop.Validate(CurrentRTFP);
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

procedure TForm_CiteTrans.PaintBox_ArrowsPaint(Sender: TObject);
var button_center:integer;
begin
  with PaintBox_Arrows.Canvas.Pen do
    begin
      Color:=clBlack;
      Style:=psSolid;
      Mode:=pmCopy;
      Width:=1;
    end;
  PaintBox_Arrows.Canvas.Line(0,24,50,24);
  PaintBox_Arrows.Canvas.Line(170,24,200,24);
  PaintBox_Arrows.Canvas.Arc(192,8,208,24,0,-90*16);
  PaintBox_Arrows.Canvas.Line(208,16,208,0);
  PaintBox_Arrows.Canvas.Line(200,8,208,0);
  PaintBox_Arrows.Canvas.Line(216,8,208,0);

  PaintBox_Arrows.Canvas.Line(0,75,50,75);
  PaintBox_Arrows.Canvas.Line(170,75,200,75);
  PaintBox_Arrows.Canvas.Arc(192,75,208,91,0,90*16);
  PaintBox_Arrows.Canvas.Line(208,83,208,99);
  PaintBox_Arrows.Canvas.Line(200,91,208,99);
  PaintBox_Arrows.Canvas.Line(216,91,208,99);
  {
  with PaintBox_Arrows.Canvas.Pen do
    begin
      Color:=clBlack;
      Style:=psSolid;
      Mode:=pmCopy;
      Width:=1;
    end;
  }
  PaintBox_Arrows.Canvas.Line(0,36,220,36);
  PaintBox_Arrows.Canvas.Line(340,36,380,36);
  PaintBox_Arrows.Canvas.Arc(372,20,388,36,0,-90*16);
  PaintBox_Arrows.Canvas.Line(388,28,388,0);
  PaintBox_Arrows.Canvas.Line(0,36,8,28);
  PaintBox_Arrows.Canvas.Line(0,36,8,44);
  PaintBox_Arrows.Canvas.Line(380,1,396,1);

  PaintBox_Arrows.Canvas.Line(0,63,220,63);
  PaintBox_Arrows.Canvas.Line(340,63,380,63);
  PaintBox_Arrows.Canvas.Arc(372,63,388,79,0,90*16);
  PaintBox_Arrows.Canvas.Line(388,69,388,99);
  PaintBox_Arrows.Canvas.Line(0,63,8,55);
  PaintBox_Arrows.Canvas.Line(0,63,8,71);
  PaintBox_Arrows.Canvas.Line(380,98,396,98);
  {
  with PaintBox_Arrows.Canvas.Pen do
    begin
      Color:=clBlack;
      Style:=psSolid;
      Mode:=pmCopy;
      Width:=1;
    end;
  }
  button_center:=Button_ImportPapers.Left + Button_ImportPapers.Width div 2 - PaintBox_Arrows.Left;
  //ShowMessage(IntToStr(button_center));

  PaintBox_Arrows.Canvas.Line(button_center-8,1,button_center+8,1);
  PaintBox_Arrows.Canvas.Line(button_center,1,button_center,26);
  PaintBox_Arrows.Canvas.Line(button_center-8,18,button_center,26);
  PaintBox_Arrows.Canvas.Line(button_center+8,18,button_center,26);

end;

end.

