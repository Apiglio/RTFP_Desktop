unit form_import;

{$mode objfpc}{$H+}

interface

uses
  {$ifdef UNIX}
  cthreads,
  {$endif}
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Buttons,
  ComCtrls, ExtCtrls, StdCtrls, rtfp_dialog, sync_thread;

const
  AnimationStepLen = 50;

type

  { TForm_ImportFiles }

  TForm_ImportFiles = class(TForm)
    Button_ToMainForm: TButton;
    Button_ImportFileNamesCheck: TButton;
    Button_BackToPrev: TButton;
    CheckBox_DefaultCl: TCheckBox;
    CheckListBox_ImportFileNames: TListView;
    ComboBox_DefaultCl: TComboBox;
    Image_FileFullBackup: TImage;
    Image_FileReference: TImage;
    Image_TestFile: TImage;
    Image_UpdateFile: TImage;
    Image_AddNote: TImage;
    Image_AddImage: TImage;
    PageControl_ImportFiles: TPageControl;
    Panel_L: TPanel;
    Panel_Buttons: TPanel;
    Panel_FilesFullBackup: TPanel;
    Panel_FilesReference: TPanel;
    Panel_R: TPanel;
    Panel_TestFile: TPanel;
    Panel_UpdateFile: TPanel;
    Panel_AddNote: TPanel;
    Panel_AddImage: TPanel;
    ProgressBar_ImportFiles: TProgressBar;
    RadioGroup_AddPaperMethod: TRadioGroup;
    SplitterImportFilesV: TSplitter;
    StaticText_ImportFileNames: TStaticText;
    StaticText_1: TStaticText;
    StaticText_2: TStaticText;
    StaticText_3: TStaticText;
    StaticText_4: TStaticText;
    StaticText_5: TStaticText;
    StaticText_6: TStaticText;
    TabSheet_TestFiles: TTabSheet;
    TabSheet_AddImage: TTabSheet;
    TabSheet_AddNote: TTabSheet;
    TabSheet_AddPaper: TTabSheet;
    procedure Button_BackToPrevClick(Sender: TObject);
    procedure Button_ImportFileNamesCheckClick(Sender: TObject);
    procedure Button_ToMainFormClick(Sender: TObject);
    procedure CheckBox_DefaultClChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Image_MouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Image_MouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Panel_FilesFullBackupMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel_FilesFullBackupMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    FFilenames:TStringList;
    FPhase:integer;
    FImportThread:TLines_Thread;

    Panel_Down:boolean;//六个按键的状态，重复按过快可能报错，加入这个变量限制快速按键操作

  public
    function Call(AFileNames: array of String):Integer;
    procedure Clear;
    procedure Phase1;
    procedure Phase2;

  public
    IsBackup:boolean;//为真时导入文件采用复制方式，为假则删除源文件
    ImportAny:boolean;
    ImportAll:boolean;

  end;

var
  Form_ImportFiles: TForm_ImportFiles;

implementation
uses RTFP_main, RTFP_definition, rtfp_type, rtfp_class;

{$R *.lfm}

{ TForm_ImportFiles }

function TForm_ImportFiles.Call(AFileNames: array of String):Integer;
var len,pi:integer;
    tmpKl:TKlass;
begin
  FFileNames.Clear;
  len:=Length(AFileNames);
  for pi:=0 to len-1 do FFilenames.Add(AFileNames[pi]);
  SplitterImportFilesV.Left:=Width-6;
  Button_ImportFileNamesCheck.Enabled:=true;
  if IsBackup then RadioGroup_AddPaperMethod.ItemIndex:=0
  else RadioGroup_AddPaperMethod.ItemIndex:=1;
  Button_BackToPrev.Enabled:=true;
  ProgressBar_ImportFiles.Position:=0;
  Button_ImportFileNamesCheck.Caption:='开始导入';

  ComboBox_DefaultCl.Clear;
  for tmpKL in CurrentRTFP.KlassList do
    if tmpKL.FilterEnabled then
      ComboBox_DefaultCl.AddItem(tmpKL.Name,tmpKL);
  CheckBox_DefaultCl.Checked:=false;
  ComboBox_DefaultCl.Enabled:=false;
  ComboBox_DefaultCl.ItemIndex:=-1;
  ComboBox_DefaultCl.Text:='';
  result:=ShowModal;
end;

procedure TForm_ImportFiles.Clear;
begin
  CheckListBox_ImportFileNames.Clear;
end;

procedure TForm_ImportFiles.Phase1;
var newPos:integer;
begin
  Button_ImportFileNamesCheck.Caption:='开始导入';
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
  CheckListBox_ImportFileNames.BeginUpdate;
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
  CheckListBox_ImportFileNames.EndUpdate;
  FPhase:=2;
  Application.ProcessMessages;
  Self.OnResize(Self);
end;

procedure TForm_ImportFiles.FormDeactivate(Sender: TObject);
begin
  //Self.Hide;
end;

procedure TForm_ImportFiles.FormDestroy(Sender: TObject);
begin
  FFileNames.Free;
end;

procedure TForm_ImportFiles.FormHide(Sender: TObject);
begin
  Clear;
end;

procedure TForm_ImportFiles.FormResize(Sender: TObject);
begin
  with CheckListBox_ImportFileNames do begin
    Columns[1].Width:=100;
    Columns[0].Width:=TabSheet_AddPaper.Width-10-100;
  end;
end;

procedure TForm_ImportFiles.FormCreate(Sender: TObject);
begin
  FFileNames:=TStringList.Create;
  if Self.Height>Screen.Height then Self.Height:=trunc(Screen.Height*0.8);
  if Self.Width>Screen.Width then Self.Height:=trunc(Screen.Width*0.8);
end;

procedure TForm_ImportFiles.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  //
end;

procedure TForm_ImportFiles.Button_BackToPrevClick(Sender: TObject);
begin
  CheckListBox_ImportFileNames.Clear;
  Phase1;
end;

procedure ImportItemStep(Filename:string;Index:integer);
var newPID:string;
    tmpIdx:integer;
    tmpKL:TKlass;
    tmpAddPaperMethod:TAddPaperMethod;
begin
  with Form_ImportFiles do begin
    CheckListBox_ImportFileNames.ItemIndex:=Index;
    if CurrentRTFP.FindPaper(Filename) = '000000' then
      begin
        case RadioGroup_AddPaperMethod.ItemIndex of
          0:tmpAddPaperMethod:=apmFullBackup;
          1:tmpAddPaperMethod:=apmCutBackup;
          2:tmpAddPaperMethod:=apmAddress;
        end;
        newPID:=CurrentRTFP.AddPaper(FileName,tmpAddPaperMethod);
        if newPID<>'000000' then begin
          ImportAny:=true;
          CheckListBox_ImportFileNames.Items[Index].SubItems[0]:='导入成功';
          tmpIdx:=ComboBox_DefaultCl.ItemIndex;
          if tmpIdx>=0 then tmpKL:=TKlass(ComboBox_DefaultCl.Items.Objects[tmpIdx]) else tmpKL:=nil;
          if tmpKL<>nil then CurrentRTFP.KlassInclude(tmpKL,newPID);
        end else begin
          ImportAll:=false;
          CheckListBox_ImportFileNames.Items[Index].SubItems[0]:='导入失败';
        end;
        ProgressBar_ImportFiles.Position:=Index+1;
      end
    else
      begin
        ImportAll:=false;
        CheckListBox_ImportFileNames.Items[Index].SubItems[0]:='已在库内';
      end;
  end;
end;

procedure ImportItemStart;
begin
  with Form_ImportFiles do begin
    ProgressBar_ImportFiles.Max:=FFileNames.Count;
    ImportAll:=true;
    ImportAny:=false;
    AllState.Enable;
    CurrentRTFP.BeginUpdate;
  end;
end;

procedure ImportItemTerminate;
begin
  with Form_ImportFiles do begin
    CurrentRTFP.EndUpdate;
    AllState.Disable;
    if ImportAll then begin
      Button_ToMainForm.Click;
    end else begin
      MessageDlg('警告','部分文件导入失败！',mtWarning,[mbOK],0);
      Button_ImportFileNamesCheck.Caption:='手动退出';
      Button_ImportFileNamesCheck.Enabled:=false;
      Button_BackToPrev.Enabled:=false;
    end;
    if ImportAny then CurrentRTFP.RecordChange;
  end;
end;

procedure TForm_ImportFiles.Button_ImportFileNamesCheckClick(Sender: TObject);
var pi:integer;
    all_success:boolean;
    newPID:RTFP_ID;
    tmpProc:TNotifyEvent;
    index:integer;
    tmpKL:TKlass;
    tmpAddPaperMethod:TAddPaperMethod;
begin
  FImportThread:=TLines_Thread.Create(FFilenames);
  FImportThread.ProcStart:=@ImportItemStart;
  FImportThread.ProcStep:=@ImportItemStep;
  FImportThread.ProcTerminate:=@ImportItemTerminate;
  FImportThread.Start;
end;

procedure TForm_ImportFiles.Button_ToMainFormClick(Sender: TObject);
begin
  //操作在ModalResult里头，不用自己写退出
  if Assigned(FImportThread) then FImportThread.Terminate;
end;

procedure TForm_ImportFiles.CheckBox_DefaultClChange(Sender: TObject);
begin
  if (Sender as TCheckBox).Checked then ComboBox_DefaultCl.Enabled:=true
  else ComboBox_DefaultCl.Enabled:=false;
end;



procedure TForm_ImportFiles.Image_MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var Panel:TPanel;
begin
  if Panel_Down then exit;
  Panel_Down:=true;
  Panel:=(Sender as TImage).Parent as TPanel;
  Panel.OnMouseDown(Panel,Button,Shift,X,Y);
end;

procedure TForm_ImportFiles.Image_MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var Panel:TPanel;
begin
  if not Panel_Down then exit;
  Panel_Down:=false;
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
        PageControl_ImportFiles.PageIndex:=TabSheet_AddPaper.PageIndex;
        CheckListBox_ImportFileNames.Clear;
        pi:=0;
        for stmp in FFileNames do begin
          CheckListBox_ImportFileNames.AddItem(stmp,nil);
          CheckListBox_ImportFileNames.Items[pi].SubItems.Add('待导入');
          inc(pi);
        end;
      end;
    '识别文件':PageControl_ImportFiles.PageIndex:=TabSheet_TestFiles.PageIndex;
    '创建笔记节点':PageControl_ImportFiles.PageIndex:=TabSheet_AddNote.PageIndex;
    '创建位图节点':PageControl_ImportFiles.PageIndex:=TabSheet_AddImage.PageIndex;
    else exit;
  end;
  Phase2;
end;


end.

