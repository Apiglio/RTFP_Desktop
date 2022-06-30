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
    ComboBox_DefaultCl: TComboBox;
    Label_DefaultCl: TLabel;
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
    procedure FormCreate(Sender: TObject);
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
uses RTFP_main, RTFP_definition, rtfp_class;

{$R *.lfm}

{ TForm_CiteTrans }

procedure TForm_CiteTrans.FormDeactivate(Sender: TObject);
begin
  //Self.Hide;
end;

procedure TForm_CiteTrans.Button_ExportCiteClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
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
  if ProjectInvalid then exit;
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
  if ProjectInvalid then exit;
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
  Memo_Cite.Clear;
end;

procedure TForm_CiteTrans.Button_ImportPapersClick(Sender: TObject);
var tmpKL:TKlass;
begin
  if ProjectInvalid then exit;
  if TabControl_CiteStyle.TabIndex<0 then exit;
  tmpKL:=TKlass(ComboBox_DefaultCl.Items.Objects[ComboBox_DefaultCl.ItemIndex]);
  case TabControl_CiteStyle.Tabs[TabControl_CiteStyle.TabIndex] of
    'E-Study':CurrentRTFP.ImportPapersFromEStudy(Memo_Cite.Lines,tmpKL);
    'RefWorks':CurrentRTFP.ImportPapersFromRefWork(Memo_Cite.Lines,tmpKL);
    'EndNote':CurrentRTFP.ImportPapersFromEndNote(Memo_Cite.Lines,tmpKL);
    'NoteExpress':CurrentRTFP.ImportPapersFromNoteExpress(Memo_Cite.Lines,tmpKL);
    'NoteFirst':CurrentRTFP.ImportPapersFromNoteFirst(Memo_Cite.Lines,tmpKL);
    'RIS':CurrentRTFP.ImportPapersFromRIS(Memo_Cite.Lines,tmpKL);
    else exit;
  end;
  FormDesktop.Validate(CurrentRTFP);
  Memo_Cite.Clear;
end;

procedure TForm_CiteTrans.Button_ImportRefsClick(Sender: TObject);
begin
  if ProjectInvalid then exit;
  if TabControl_Reference_Style.TabIndex<0 then exit;
  case TabControl_Reference_Style.Tabs[TabControl_Reference_Style.TabIndex] of
    'GB/T 7714':CurrentRTFP.SetGBT7714(FormDesktop.Selected_PID,Memo_Reference.Lines.CommaText);
    'CAJ-CD':CurrentRTFP.SetCAJCD(FormDesktop.Selected_PID,Memo_Reference.Lines.CommaText);
    'MLA':CurrentRTFP.SetMLA(FormDesktop.Selected_PID,Memo_Reference.Lines.CommaText);
    'APA':CurrentRTFP.SetAPA(FormDesktop.Selected_PID,Memo_Reference.Lines.CommaText);
    '查新':CurrentRTFP.SetChaXin(FormDesktop.Selected_PID,Memo_Reference.Lines.CommaText);
  end;
  FormDesktop.Validate(CurrentRTFP);
  Memo_Reference.Clear;
end;

procedure TForm_CiteTrans.FormCreate(Sender: TObject);
begin
  if Self.Height>Screen.Height then Self.Height:=trunc(Screen.Height*0.8);
  if Self.Width>Screen.Width then Self.Height:=trunc(Screen.Width*0.8);
end;

procedure TForm_CiteTrans.FormDropFiles(Sender: TObject;
  const FileNames: array of String);
var bom_temp,bom:string;
begin
  Memo_Cite.Lines.LoadFromFile(FileNames[0]);
  //检验BOM码  EF BB BF
  bom_temp:=Memo_Cite.Lines[0];
  bom:=bom_temp;
  delete(bom,4,length(bom));
  if bom=#$EF#$BB#$BF then begin
    delete(bom_temp,1,3);
    Memo_Cite.Lines[0]:=bom_temp;
  end;
end;

procedure TForm_CiteTrans.FormHide(Sender: TObject);
begin
  FormDesktop.Panel_DBGridMain.Parent:=FormDesktop.TabSheet_Project_DataGrid;
  FormDesktop.Panel_DBGridMain.Align:=alClient;
end;

procedure TForm_CiteTrans.FormShow(Sender: TObject);
var tmpKL:TKlass;
begin
  FormDesktop.Panel_DBGridMain.Parent:=Self.Panel_DBGrid_Temporary;
  FormDesktop.Panel_DBGridMain.Align:=alClient;

  ComboBox_DefaultCl.Clear;
  ComboBox_DefaultCl.AddItem('无默认分类',nil);
  for tmpKL in CurrentRTFP.KlassList do
    if tmpKL.FilterEnabled then
      ComboBox_DefaultCl.AddItem(tmpKL.Name,tmpKL);
  ComboBox_DefaultCl.ItemIndex:=0;

end;

procedure TForm_CiteTrans.PaintBox_ArrowsPaint(Sender: TObject);
var button_center,col_1,col_2,col_3,col_4,row_1,row_2,row_3,row_4,half:integer;
begin
  with PaintBox_Arrows.Canvas.Pen do
    begin
      Color:=clGray;
      Style:=psSolid;
      Mode:=pmCopy;
      Width:=1;
    end;

  col_1:=Button_ExportCite.Left - PaintBox_Arrows.Left;
  col_2:=Button_ExportCite.Left + Button_ExportCite.Width - PaintBox_Arrows.Left;
  col_3:=Button_ImportCite.Left - PaintBox_Arrows.Left;
  col_4:=Button_ImportCite.Left + Button_ImportCite.Width - PaintBox_Arrows.Left;
  row_1:=Button_ExportCite.Top+Button_ExportCite.Height div 2 - PaintBox_Arrows.Top;
  row_2:=Button_ImportCite.Top+Button_ImportCite.Height div 2 - PaintBox_Arrows.Top + 8;
  row_3:=Button_ImportRefs.Top+Button_ImportRefs.Height div 2 - PaintBox_Arrows.Top - 8;
  row_4:=Button_ExportRefs.Top+Button_ExportRefs.Height div 2 - PaintBox_Arrows.Top;
  half:=Button_ExportCite.Height div 2;
  button_center:=Button_ImportPapers.Left + Button_ImportPapers.Width div 2 - PaintBox_Arrows.Left;

  PaintBox_Arrows.Canvas.Line(0,           row_1,    col_1,      row_1);
  PaintBox_Arrows.Canvas.Line(col_2,       row_1,    col_2+30,   row_1);
  PaintBox_Arrows.Canvas.Arc( col_2+30-8,  row_1-16, col_2+30+8, row_1,0,-90*16);
  PaintBox_Arrows.Canvas.Line(col_2+30+8,  row_1-8,  col_2+30+8, 0);
  PaintBox_Arrows.Canvas.Line(col_2+30,    8,        col_2+30+8, 0);
  PaintBox_Arrows.Canvas.Line(col_2+30+16, 8,        col_2+30+8, 0);

  PaintBox_Arrows.Canvas.Line(0,           row_4,    col_1,      row_4);
  PaintBox_Arrows.Canvas.Line(col_2,       row_4,    col_2+30,   row_4);
  PaintBox_Arrows.Canvas.Arc( col_2+30-8,  row_4,    col_2+30+8, row_4+14,0,90*16);
  PaintBox_Arrows.Canvas.Line(col_2+30+8,  row_4+6,  col_2+30+8, row_4+14);
  PaintBox_Arrows.Canvas.Line(col_2+30,    row_4+6,  col_2+30+8, row_4+14);
  PaintBox_Arrows.Canvas.Line(col_2+30+16, row_4+6,  col_2+30+8, row_4+14);

  PaintBox_Arrows.Canvas.Line(0,           row_2,    col_3,      row_2);
  PaintBox_Arrows.Canvas.Line(col_4,       row_2,    col_4+30,   row_2);
  PaintBox_Arrows.Canvas.Arc( col_4+30-8,  row_2-16, col_4+30+8, row_2,0,-90*16);
  PaintBox_Arrows.Canvas.Line(col_4+30+8,  row_2-8,  col_4+30+8, 0);
  PaintBox_Arrows.Canvas.Line(0,           row_2,    8,          row_2-8);
  PaintBox_Arrows.Canvas.Line(0,           row_2,    8,          row_2+8);
  PaintBox_Arrows.Canvas.Line(col_4+30,    1,        col_4+30+16,1);

  PaintBox_Arrows.Canvas.Line(0,           row_3,    col_3,      row_3);
  PaintBox_Arrows.Canvas.Line(col_4,       row_3,    col_4+30,   row_3);
  PaintBox_Arrows.Canvas.Arc( col_4+30-8,  row_3,    col_4+30+8, row_3+16,0,90*16);
  PaintBox_Arrows.Canvas.Line(col_4+30+8,  row_3+6,  col_4+30+8, row_4+12);
  PaintBox_Arrows.Canvas.Line(0,           row_3,    8,          row_3-8);
  PaintBox_Arrows.Canvas.Line(0,           row_3,    8,          row_3+8);
  PaintBox_Arrows.Canvas.Line(col_4+30,    row_4+12, col_4+30+16,row_4+12);

  PaintBox_Arrows.Canvas.Line(button_center-8,1,button_center+8,1);
  PaintBox_Arrows.Canvas.Line(button_center,1,button_center,16);
  PaintBox_Arrows.Canvas.Line(button_center-8,8,button_center,16);
  PaintBox_Arrows.Canvas.Line(button_center+8,8,button_center,16);

end;

end.

