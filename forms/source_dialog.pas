unit source_dialog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls{, LazUTF8};

type

  { TForm_FileSource }

  TForm_FileSource = class(TForm)
    Button_OpenDialog: TButton;
    Button_Commit: TButton;
    Button_RenameBackup: TButton;
    Memo_Path: TMemo;
    OpenDialog: TOpenDialog;
    RadioGroup_mode: TRadioGroup;
    procedure Button_CommitClick(Sender: TObject);
    procedure Button_OpenDialogClick(Sender: TObject);
    procedure Button_RenameBackupClick(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
  private
    function DelOldBackup:boolean;//弹出选项 Yes:删除并返回true No:不删除并返回true Cancel:不删除并返回false
    function SetNewBackup(backup:string):boolean;
    procedure SetWeblink(weblink:string);
    procedure SetExternPath(path:string);
    procedure SetDefault;

    procedure UpdateMemo;
  public
    Current_PID:string;
    Origin_Mode:integer;
    OriPath:string;
    function Call:Integer;
  end;

var
  Form_FileSource: TForm_FileSource;

implementation
uses RTFP_definition, rtfp_dialog, RTFP_main, rtfp_constants, rtfp_type, rtfp_pdfobj;
{$R *.lfm}

{ TForm_FileSource }

function TForm_FileSource.DelOldBackup:boolean;
var pathn,filen,fulln:string;
begin
  pathn:=CurrentRTFP.ReadBasicString(_Col_Paper_Folder_,Current_PID);
  filen:=CurrentRTFP.ReadBasicString(_Col_Paper_FileName_,Current_PID);
  fulln:=pathn+_fsplit_+filen;
  result:=true;
  case ShowMsgYesNoCancel('删除旧备份','是否删除旧有备份文件：'+#13#10+'  '+fulln) of
    'Yes':TRTFP.FileDelete(CurrentRTFP.CurrentPathFull+'paper'+_fsplit_+fulln);
    'No':;
    else result:=false;
  end;
  CurrentRTFP.DataChange(Current_PID);
end;
function TForm_FileSource.SetNewBackup(backup:string):boolean;
var pathn,filen:string;
    tmpFS:TFileStream;
    rc:integer;
begin
  result:=false;
  pathn:=TRTFP.GetDateDir;
  filen:=ExtractFileName(backup);
  if not FileExists(backup) then exit;
  if not TRTFP.FileCopy(backup,CurrentRTFP.CurrentPathFull+'paper'+_fsplit_+pathn+_fsplit_+filen,true) then
    case ShowMsgYesNoAll('备份文件重名','备份文件重名，是否覆盖？') of
      'No':exit;
      else TRTFP.FileCopy(backup,CurrentRTFP.CurrentPathFull+'paper'+_fsplit_+pathn+_fsplit_+filen,false);
    end;
  //这里没有文件路径长度检验
  CurrentRTFP.EditBasicString(_Col_Paper_Folder_,Current_PID,pathn);
  CurrentRTFP.EditBasicString(_Col_Paper_FileName_,Current_PID,filen);
  CurrentRTFP.EditBasicBool(_Col_Paper_Is_Backup_,Current_PID,true);
  CurrentRTFP.EditBasicInteger(_Col_Paper_FileSize_,Current_PID,FileSize(backup));
  try
    tmpFS:=TFileStream.Create(backup,fmOpenRead);
    CurrentRTFP.EditBasicString(_Col_Paper_FileHash_,Current_PID,TRTFP_PDF.CalcHash(tmpFS,rc,CurrentRTFP.Tag['文件哈希方式']));
  finally
    tmpFS.Free;
  end;
  CurrentRTFP.DataChange(Current_PID);
  result:=true;
end;
procedure TForm_FileSource.SetWeblink(weblink:string);
begin
  CurrentRTFP.EditFieldAsString(_Col_basic_Link_,_Attrs_Basic_,Current_PID,weblink,[aeForceEditIfTypeDismatch]);
  CurrentRTFP.EditBasicString(_Col_Paper_Folder_,Current_PID,'weblnk');
  CurrentRTFP.EditBasicString(_Col_Paper_FileName_,Current_PID,'');
  CurrentRTFP.EditBasicBool(_Col_Paper_Is_Backup_,Current_PID,false);
  CurrentRTFP.DataChange(Current_PID);
end;
procedure TForm_FileSource.SetExternPath(path:string);
begin
  CurrentRTFP.EditBasicString(_Col_Paper_FileName_,Current_PID,path);
  CurrentRTFP.EditBasicString(_Col_Paper_Folder_,Current_PID,'extern');
  CurrentRTFP.EditBasicBool(_Col_Paper_Is_Backup_,Current_PID,false);
  CurrentRTFP.DataChange(Current_PID);
end;
procedure TForm_FileSource.SetDefault;
begin
  CurrentRTFP.EditBasicString(_Col_Paper_FileName_,Current_PID,'');
  CurrentRTFP.EditBasicString(_Col_Paper_Folder_,Current_PID,'');
  CurrentRTFP.EditBasicBool(_Col_Paper_Is_Backup_,Current_PID,false);
  CurrentRTFP.DataChange(Current_PID);
end;


procedure TForm_FileSource.UpdateMemo;
var pathn,filen:string;
begin
  Current_PID:=FormDesktop.Selected_PID;
  Memo_Path.Clear;
  OriPath:='';
  pathn:=CurrentRTFP.ReadBasicString(_Col_Paper_Folder_,Current_PID);
  filen:=CurrentRTFP.ReadBasicString(_Col_Paper_FileName_,Current_PID);
  Button_RenameBackup.Enabled:=false;
  case lowercase(pathn) of
    'extern':
      begin
        RadioGroup_mode.ItemIndex:=1;
        OriPath:=filen;
      end;
    'weblnk':
      begin
        RadioGroup_mode.ItemIndex:=2;
        OriPath:=CurrentRTFP.ReadFieldAsString(_Col_basic_Link_,_Attrs_Basic_,Current_PID,[]);
      end;
    else
      begin
        if filen='' then RadioGroup_mode.ItemIndex:=3
        else begin
          OriPath:=pathn+_fsplit_+filen;
          RadioGroup_mode.ItemIndex:=0;
          Button_RenameBackup.Enabled:=true;
        end;
      end;
  end;
  Origin_Mode:=RadioGroup_mode.ItemIndex;
  Memo_Path.Lines.Add(OriPath);
end;

function TForm_FileSource.Call:Integer;
begin
  UpdateMemo;
  result:=ShowModal;
end;

procedure TForm_FileSource.Button_OpenDialogClick(Sender: TObject);
begin
  if OpenDialog.Execute then
    begin
      Memo_Path.Clear;
      Memo_Path.lines.add(OpenDialog.FileName);
    end;
end;

procedure TForm_FileSource.Button_RenameBackupClick(Sender: TObject);
var pathn,filen,filenew:string;
begin
  with CurrentRTFP do
    begin
      filen:=ReadBasicString(_Col_Paper_FileName_,Current_PID);
      pathn:=CurrentPathFull+'paper'+_fsplit_+ReadBasicString(_Col_Paper_Folder_,Current_PID);
    end;
  filenew:=ShowMsgEdit('重命名备份','备份文件名修改为：',filen);
  if TRTFP.FileRename(pathn+_fsplit_+filen,pathn+_fsplit_+filenew) then
    CurrentRTFP.EditBasicString(_Col_Paper_FileName_,Current_PID,filenew)
  else ShowMsgOK('重命名失败','备份文件重命名失败。');
  pathn:=CurrentRTFP.ReadBasicString(_Col_Paper_Folder_,Current_PID);
  filen:=CurrentRTFP.ReadBasicString(_Col_Paper_FileName_,Current_PID);
  Memo_Path.Clear;
  Memo_Path.Lines.Add(pathn+_fsplit_+filen);
end;

procedure TForm_FileSource.Button_CommitClick(Sender: TObject);
var NewPath:string;
    len:integer;
begin
  NewPath:=Memo_Path.Text;
  len:=length(NewPath);
  while NewPath[len] in [#13,#10] do
    begin
      delete(NewPath,len,1);
      dec(len);
    end;
  case RadioGroup_mode.ItemIndex of
    0:begin
        if NewPath=OriPath then begin
          if Origin_Mode=1 then if not SetNewBackup(NewPath) then
            begin
              ShowMsgOK('备份失败','找不到备份目标文件');
              exit;
            end;
        end else begin
          if FileExists(NewPath) then begin
            if Origin_Mode=0 then if not DelOldBackup then exit;
            if not SetNewBackup(NewPath) then
              begin
                ShowMsgOK('备份失败','找不到备份目标文件');
                exit;
              end;
          end;
        end;
      end;
    1:begin
        if Origin_Mode=0 then if not DelOldBackup then exit;
        SetExternPath(NewPath);
      end;
    2:begin
        if Origin_Mode=0 then if not DelOldBackup then exit;
        SetWeblink(NewPath);
      end;
    3:begin
        if Origin_Mode=0 then if not DelOldBackup then exit;
        SetDefault;
      end;
  end;
  ModalResult:=mrOK;
end;

procedure TForm_FileSource.FormDropFiles(Sender: TObject;
  const FileNames: array of String);
begin
  if length(FileNames)>1 then ShowMsgOK('非单一源','仅支持单个文件源');//真的吗？以后可以考虑拓展这一条规则
  Memo_Path.Clear;
  Memo_Path.Lines.add(FileNames[0]);
end;

end.

