unit form_cite_trans;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  DBGrids, ExtCtrls, ComCtrls;

type

  { TForm_CiteTrans }

  TForm_CiteTrans = class(TForm)
    Button_MemoModifer: TButton;
    Button_ImportCite: TButton;
    CheckBox_WordWrap: TCheckBox;
    ListBox_CiteStyle: TListBox;
    Memo_Cite: TMemo;
    Panel_DBGrid_Temporary: TPanel;
    procedure Button_ImportCiteClick(Sender: TObject);
    procedure Button_MemoModiferClick(Sender: TObject);
    procedure CheckBox_WordWrapChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure FormHide(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FCloseAfterEdit:boolean;
    FImportToNewPapers:boolean;
  public
    procedure Call(PID_Changeable:boolean;Multi_Import:boolean);
    procedure ImportCiteInfo_Mono;
    procedure ImportCiteInfo_Multi;
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

procedure TForm_CiteTrans.ImportCiteInfo_Mono;
begin
  if ProjectInvalid then exit;
  if ListBox_CiteStyle.ItemIndex<0 then exit;
  case ListBox_CiteStyle.Items[ListBox_CiteStyle.ItemIndex] of
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

procedure TForm_CiteTrans.ImportCiteInfo_Multi;
var tmpKL:TKlass;
begin
  if ProjectInvalid then exit;
  if ListBox_CiteStyle.ItemIndex<0 then exit;
  tmpKL:=nil;
  case ListBox_CiteStyle.Items[ListBox_CiteStyle.ItemIndex] of
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

procedure TForm_CiteTrans.Button_ImportCiteClick(Sender: TObject);
var memo_wordwrap:boolean;
begin
  memo_wordwrap:=Memo_Cite.WordWrap;
  Memo_Cite.WordWrap:=false;
  if FImportToNewPapers then ImportCiteInfo_Multi
  else ImportCiteInfo_Mono;
  Memo_Cite.WordWrap:=memo_wordwrap;
  if FCloseAfterEdit then ModalResult:=mrOK;
end;

function RemoveRepeatedSpace(str:string):string;
var index:integer;
    behind_space,now_space:boolean;
begin
  index:=0;
  result:='';
  behind_space:=false;
  for index:=1 to length(str) do
  begin
    now_space:=str[index]=' ';
    if now_space and behind_space then {is repeated space}
    else result:=result+str[index];
    behind_space:=now_space;
  end;
end;

procedure TForm_CiteTrans.Button_MemoModiferClick(Sender: TObject);
var line:integer;
    stmp:string;
    memo_wordwrap,behind_empty_line,now_empty_line:boolean;
begin
  memo_wordwrap:=Memo_Cite.WordWrap;
  Memo_Cite.WordWrap:=false;
  with Memo_Cite do
  begin
    for line:=0 to Lines.Count-1 do
    begin
      stmp:=Lines[line];
      stmp:=TrimLeft(stmp);//清除行首空格
      stmp:=RemoveRepeatedSpace(stmp);//删除重复空格
      Lines[line]:=stmp;
    end;
    line:=0;
    behind_empty_line:=false;
    while line<Lines.Count do
    begin
      now_empty_line:=Lines[line]='';
      if now_empty_line and behind_empty_line then Lines.Delete(line);//删除重复空行
      behind_empty_line:=now_empty_line;
      inc(line);
    end;
  end;
  Memo_Cite.WordWrap:=memo_wordwrap;
end;

procedure TForm_CiteTrans.CheckBox_WordWrapChange(Sender: TObject);
begin
  Memo_Cite.WordWrap:=CheckBox_WordWrap.Checked;
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

procedure TForm_CiteTrans.FormResize(Sender: TObject);
begin
  if FImportToNewPapers then Panel_DBGrid_Temporary.Width:=0
  else Panel_DBGrid_Temporary.Width:=Width div 2;
end;

procedure TForm_CiteTrans.FormShow(Sender: TObject);
begin
  FormDesktop.Panel_DBGridMain.Parent:=Self.Panel_DBGrid_Temporary;
  FormDesktop.Panel_DBGridMain.Align:=alClient;
end;


procedure TForm_CiteTrans.Call(PID_Changeable:boolean;Multi_Import:boolean);
begin
  Panel_DBGrid_Temporary.Enabled:=PID_Changeable;
  FCloseAfterEdit:=not PID_Changeable;
  FImportToNewPapers:=Multi_Import;
  if Multi_Import then begin
    Button_ImportCite.Caption:='批量创建文献';
    Panel_DBGrid_Temporary.Width:=0;
  end else begin
    Button_ImportCite.Caption:='修改题录信息';
    Panel_DBGrid_Temporary.Width:=Width div 2;
  end;
  CheckBox_WordWrap.Checked:=Memo_Cite.WordWrap;
  ShowModal;
end;

end.

