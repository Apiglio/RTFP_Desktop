unit form_new_project;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  CheckLst, RTFP_definition, LazUTF8;

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
    SelectDirectoryDialog_NewProject: TSelectDirectoryDialog;
    procedure Button_BrowseClick(Sender: TObject);
    procedure Button_CreateClick(Sender: TObject);
    procedure Edit_ProjectNameChange(Sender: TObject);
    procedure Edit_ProjectPathChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
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

  public
    procedure Call;

  end;

var
  Form_NewProject: TForm_NewProject;

implementation
uses RTFP_main;

{$R *.lfm}

function TForm_NewProject.GetFileFullName:string;
var str:string;
    len:integer;
begin
  result:=Utf8ToWinCP(Self.Edit_ProjectPath.Caption)+'\'+Utf8ToWinCP(Self.Edit_ProjectName.Caption);
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
  result:=result+'\';
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

  CurrentRTFP:=TRTFP.Create(FormDesktop);
  CurrentRTFP.onNewDone:=@FormDesktop.Validate;
  CurrentRTFP.New(Self.FileFullName,Self.FileName,'Apiglio');

  Self.Hide;

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

procedure TForm_NewProject.FormDeactivate(Sender: TObject);
begin
  Self.Hide;
end;

procedure TForm_NewProject.Renew;
begin

  //Self.Caption:=Self.FileName;

  with CheckListBox_CanBuild do begin
    if TRTFP.CanBuildName(Self.FileName) then Checked[0]:=true else Checked[0]:=false;
    if TRTFP.CanBuildPath(Self.FilePath+Self.FileName) then Checked[1]:=true else Checked[1]:=false;
    if TRTFP.CanBuildFile(Self.FileFullName) then Checked[2]:=true else Checked[2]:=false;
    if TRTFP.CanBuildDisc(Self.FilePath[1]) then Checked[3]:=true else Checked[3]:=false;

    if Checked[0] and Checked[1] and Checked[2] and Checked[3] then
       Self.Button_Create.Enabled:=true
    else Self.Button_Create.Enabled:=false;

  end;

end;

procedure TForm_NewProject.Call;
begin
  Self.Show;

end;

end.

