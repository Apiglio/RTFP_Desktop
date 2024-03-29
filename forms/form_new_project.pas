unit form_new_project;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  CheckLst, ExtCtrls, RTFP_definition, LazUTF8;

type

  { TForm_NewProject }

  TForm_NewProject = class(TForm)
    Button_Create: TButton;
    Button_Browse: TButton;
    CheckListBox_CanBuild: TCheckListBox;
    Edit_ProjectName: TEdit;
    Edit_ProjectPath: TEdit;
    Label_ProjectName: TLabel;
    Label_ProjectPath: TLabel;
    Label_ProjectCanBuild: TLabel;
    RadioGroup_dbFormat: TRadioGroup;
    SelectDirectoryDialog_NewProject: TSelectDirectoryDialog;
    procedure Button_BrowseClick(Sender: TObject);
    procedure Button_CreateClick(Sender: TObject);
    procedure Edit_ProjectNameChange(Sender: TObject);
    procedure Edit_ProjectPathChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);

  private
    procedure Renew;

  protected
    function GetFileFullName:string;
    function GetFileName:string;
    function GetFilePath:string;

  public
    property FilePath:string read GetFilePath;
    property FileName:string read GetFileName;
    property FileFullName:string read GetFileFullName;

  end;

var
  Form_NewProject: TForm_NewProject;

implementation
uses RTFP_main, rtfp_type, rtfp_constants;

{$R *.lfm}

function TForm_NewProject.GetFileFullName:string;
var str:string;
    len:integer;
begin
  result:=Utf8ToWinCP(Self.Edit_ProjectPath.Caption)+'/'+Utf8ToWinCP(Self.Edit_ProjectName.Caption);
  len:=length(result);
  if len>=5 then begin
    str:=copy(result,len-4,5);
    if lowercase(str)<>'.rtfp' then result:=result+'.rtfp';
  end;
end;

function TForm_NewProject.GetFileName:string;
var str:string;
    pos,len:integer;
begin
  result:=Utf8ToWinCP(Self.Edit_ProjectName.Caption);
  len:=length(result);
  if len>=5 then begin
    pos:=length(result)-4;
    str:=copy(result,pos,5);
    if lowercase(str)='.rtfp' then delete(result,pos,5);
  end;
end;

function TForm_NewProject.GetFilePath:string;
begin
  result:=Utf8ToWinCP(Self.Edit_ProjectPath.Caption);
  ExpandFileName(result);
  result:=result+'/';
end;

procedure TForm_NewProject.Button_BrowseClick(Sender: TObject);
begin
  if Self.SelectDirectoryDialog_NewProject.Execute then
    begin
      Self.Edit_ProjectPath.Caption:=Self.SelectDirectoryDialog_NewProject.FileName;
    end;
end;

procedure TForm_NewProject.Button_CreateClick(Sender: TObject);
begin

  if assigned(CurrentRTFP) then
  begin
    if CurrentRTFP.IsOpen then CurrentRTFP.Close;
    CurrentRTFP.Free;
  end;

  case RadioGroup_dbFormat.ItemIndex of
    1:CurrentRTFP:=TRTFP.Create(FormDesktop,dstBUF);
    else CurrentRTFP:=TRTFP.Create(FormDesktop,dstDBF);
  end;

  CurrentRTFP.SetAuf(FormDesktop.Frame_AufScript1.Auf);
  FormDesktop.EventLink(CurrentRTFP);
  CurrentRTFP.New((Self.FileFullName),(Self.FileName),'Apiglio');

  //Self.Hide;
  //ModalResult法

end;

procedure TForm_NewProject.Edit_ProjectNameChange(Sender: TObject);
begin
  Self.Renew;
end;

procedure TForm_NewProject.Edit_ProjectPathChange(Sender: TObject);
begin
  Self.Renew;
end;

procedure TForm_NewProject.FormActivate(Sender: TObject);
begin
  Self.Renew;
end;

procedure TForm_NewProject.FormCreate(Sender: TObject);
var init_path:string;
    len:integer;
begin
  if ProjectInvalid then
    init_path:=ExtractFilePath(ParamStr(0))+'DefaultDB'+_fsplit_
  else
    init_path:=CurrentRTFP.CurrentPathFull;
  Edit_ProjectPath.Caption:=init_path;
  len:=length(init_path);
  if len>1 then delete(init_path,len,1);
  SelectDirectoryDialog_NewProject.InitialDir:=init_path;
end;

procedure TForm_NewProject.FormDeactivate(Sender: TObject);
begin
  //Self.Hide;
end;

procedure TForm_NewProject.Renew;
begin

  //Self.Caption:=Self.FileName;

  with CheckListBox_CanBuild do begin
    if TRTFP.CanBuildName(Self.FileName) then Checked[0]:=true else Checked[0]:=false;
    if TRTFP.CanBuildPath(Self.FilePath+'.'+Self.FileName) then Checked[1]:=true else Checked[1]:=false;
    if TRTFP.CanBuildFile(Self.FileFullName) then Checked[2]:=true else Checked[2]:=false;
    if TRTFP.CanBuildPLen(Self.FilePath+Self.FileName) then Checked[3]:=true else Checked[3]:=false;
    if TRTFP.CanBuildDisc(Self.FilePath[1]) then Checked[4]:=true else Checked[4]:=false;

    if Checked[0] and Checked[1] and Checked[2] and Checked[3] and Checked[4] then
       Self.Button_Create.Enabled:=true
    else Self.Button_Create.Enabled:=false;

  end;

end;

end.

