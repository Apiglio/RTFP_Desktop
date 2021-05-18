unit form_import;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Buttons,
  ComCtrls, ExtCtrls, StdCtrls, CheckLst;

const
  AnimationStepLen = 50;

type

  { TForm_ImportFiles }

  TForm_ImportFiles = class(TForm)
    Button_ImportFileNamesCheck: TButton;
    Button_BackToPrev: TButton;
    CheckBox_AddPaperMethod: TCheckBox;
    CheckListBox_ImportFileNames: TCheckListBox;
    Image_FileFullBackup: TImage;
    Image_FileReference: TImage;
    Image_TestFiles: TImage;
    Image_RefFormat: TImage;
    Image_AddNote: TImage;
    Image_AddImage: TImage;
    PageControl_ImportFiles: TPageControl;
    Panel_L: TPanel;
    Panel_Buttons: TPanel;
    Panel_FilesFullBackup: TPanel;
    Panel_FilesReference: TPanel;
    Panel_R: TPanel;
    Panel_TestFiles: TPanel;
    Panel_RefFormat: TPanel;
    Panel_AddNote: TPanel;
    Panel_AddImage: TPanel;
    ProgressBar_ImportFiles: TProgressBar;
    SplitterImportFilesV: TSplitter;
    StaticText_ImportFileNames: TStaticText;
    StaticText_1: TStaticText;
    StaticText_2: TStaticText;
    StaticText_3: TStaticText;
    StaticText_4: TStaticText;
    StaticText_5: TStaticText;
    StaticText_6: TStaticText;
    TabSheet_ImportRefs: TTabSheet;
    TabSheet_TestFiles: TTabSheet;
    TabSheet_AddImage: TTabSheet;
    TabSheet_AddNote: TTabSheet;
    TabSheet_AddPaper: TTabSheet;
    procedure Button_BackToPrevClick(Sender: TObject);
    procedure Button_ImportFileNamesCheckClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure Image_MouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image_MouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Panel_FilesFullBackupMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel_FilesFullBackupMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    {
    procedure Timer_AnimationStartTimer(Sender: TObject);
    procedure Timer_AnimationStopTimer(Sender: TObject);
    procedure Timer_AnimationTimer(Sender: TObject);
    }
  private
    FFilenames:TStringList;
    FAnimationRightOrt:boolean;
    FPhase:integer;
  public
    procedure Call(AFileNames: array of String);
    procedure Clear;
    procedure Phase1;
    procedure Phase2;


  end;

var
  Form_ImportFiles: TForm_ImportFiles;

implementation
uses RTFP_main, RTFP_definition;

{$R *.lfm}

{ TForm_ImportFiles }

procedure TForm_ImportFiles.Call(AFileNames: array of String);
var len,pi:integer;
begin
  FFileNames.Clear;
  len:=Length(AFileNames);
  for pi:=0 to len-1 do
    begin
      FFilenames.Add(AFileNames[pi]);
    end;
  SplitterImportFilesV.Left:=Width-6;
  Button_ImportFileNamesCheck.Enabled:=true;
  Button_ImportFileNamesCheck.Caption:='确认导入';
  ProgressBar_ImportFiles.Position:=0;
  Self.Show;
end;

procedure TForm_ImportFiles.Clear;
begin
  CheckListBox_ImportFileNames.Clear;
end;

procedure TForm_ImportFiles.Phase1;
var newPos:integer;
begin
  PageControl_ImportFiles.BeginUpdateBounds;
  repeat
    newPos:=SplitterImportFilesV.Left + AnimationStepLen;
    if newPos > Width-6 then begin
      newPos:=Width-6;
      break
    end;
    SplitterImportFilesV.Left:=newPos;
    Application.ProcessMessages;
    //sleep(5);
  until newPos >= Width-6;
  SplitterImportFilesV.Left:=Width-6;
  PageControl_ImportFiles.EndUpdateBounds;
  FPhase:=1;
  Application.ProcessMessages;
end;

procedure TForm_ImportFiles.Phase2;
var newPos:integer;
begin
  PageControl_ImportFiles.BeginUpdateBounds;
  repeat
    newPos:=SplitterImportFilesV.Left - AnimationStepLen;
    if newPos < 0 then begin
      newPos:=0;
      break
    end;
    SplitterImportFilesV.Left:=newPos;
    Application.ProcessMessages;
    //sleep(5);
  until newPos <= 0;
  SplitterImportFilesV.Left:=0;
  PageControl_ImportFiles.EndUpdateBounds;
  FPhase:=2;
  Application.ProcessMessages;
end;

procedure TForm_ImportFiles.FormDeactivate(Sender: TObject);
begin
  Self.Hide;
end;

procedure TForm_ImportFiles.FormCreate(Sender: TObject);
begin
  FFileNames:=TStringList.Create;
end;

procedure TForm_ImportFiles.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  FFileNames.Free;
end;

procedure TForm_ImportFiles.Button_BackToPrevClick(Sender: TObject);
begin
  CheckListBox_ImportFileNames.Clear;
  Phase1;
end;

procedure TForm_ImportFiles.Button_ImportFileNamesCheckClick(Sender: TObject);
var pi:integer;
    all_success:boolean;
begin
  ProgressBar_ImportFiles.Max:=FFileNames.Count;
  all_success:=true;
  for pi:=0 to FFileNames.Count-1 do
    begin
      if CurrentRTFP.FindPaper(FFileNames[pi]) = '000000' then
        begin
          if CheckBox_AddPaperMethod.Checked then
            CurrentRTFP.AddPaper(FFileNames[pi],apmFullBackup)
          else
            CurrentRTFP.AddPaper(FFileNames[pi],apmReference);
          CheckListBox_ImportFileNames.Checked[pi]:=true;
          ProgressBar_ImportFiles.Position:=pi+1;
          Application.ProcessMessages;
        end
      else
        begin
          all_success:=false;
          //ShowMessage(FileNames[pi]+'已在库内。');
        end;
    end;
  if all_success then begin
    Clear;
    Self.Hide;
  end else begin
    Button_ImportFileNamesCheck.Caption:='手动退出';
    Button_ImportFileNamesCheck.Enabled:=false;
  end;

end;

procedure TForm_ImportFiles.Image_MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var Panel:TPanel;
begin
  Panel:=(Sender as TImage).Parent as TPanel;
  Panel.OnMouseDown(Panel,Button,Shift,X,Y);
end;

procedure TForm_ImportFiles.Image_MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var Panel:TPanel;
begin
  Panel:=(Sender as TImage).Parent as TPanel;
  Panel.OnMouseUp(Panel,Button,Shift,X,Y);
end;

procedure TForm_ImportFiles.Panel_FilesFullBackupMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  (Sender as TPanel).BevelOuter:=bvLowered;
end;

procedure TForm_ImportFiles.Panel_FilesFullBackupMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var stmp:string;
    pi:integer;
begin
  (Sender as TPanel).BevelOuter:=bvNone;
  case (Sender as TPanel).Hint of
    '备份文件节点':
      begin
        CheckBox_AddPaperMethod.Checked:=true;
        PageControl_ImportFiles.PageIndex:=TabSheet_AddPaper.PageIndex;
        pi:=0;
        for stmp in FFileNames do begin
          CheckListBox_ImportFileNames.AddItem(stmp,nil);
          CheckListBox_ImportFileNames.Checked[pi]:=false;
          inc(pi);
        end;

      end;
    '链接文件节点':
      begin
        CheckBox_AddPaperMethod.Checked:=false;
        PageControl_ImportFiles.PageIndex:=TabSheet_AddPaper.PageIndex;
        pi:=0;
        for stmp in FFileNames do begin
          CheckListBox_ImportFileNames.AddItem(stmp,nil);
          CheckListBox_ImportFileNames.Checked[pi]:=false;
          inc(pi);
        end;

      end;
    '识别文件':PageControl_ImportFiles.PageIndex:=TabSheet_TestFiles.PageIndex;
    '导入引用格式':PageControl_ImportFiles.PageIndex:=TabSheet_ImportRefs.PageIndex;
    '创建笔记节点':PageControl_ImportFiles.PageIndex:=TabSheet_AddNote.PageIndex;
    '创建位图节点':PageControl_ImportFiles.PageIndex:=TabSheet_AddImage.PageIndex;
    else ;
  end;
  Phase2;
end;

{
procedure TForm_ImportFiles.Timer_AnimationStartTimer(Sender: TObject);
begin
  //Self.BeginFormUpdate;
end;

procedure TForm_ImportFiles.Timer_AnimationStopTimer(Sender: TObject);
begin
  //Self.EndFormUpdate;
end;

procedure TForm_ImportFiles.Timer_AnimationTimer(Sender: TObject);
var newPos:integer;
begin
  if FAnimationRightOrt then
    newPos:=SplitterImportFilesV.Left + AnimationStepLen
  else
    newPos:=SplitterImportFilesV.Left - AnimationStepLen;
  if newPos < 0 then begin
    newPos:=0;
    (Sender as TTimer).Enabled:=false;
  end;
  if newPos > Width - 6 then begin
    newPos:=Width - 6;
    (Sender as TTimer).Enabled:=false;
  end;
  SplitterImportFilesV.Left:=newPos;
end;
}

end.

