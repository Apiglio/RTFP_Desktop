unit form_options;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ExtCtrls, Registry, LazUTF8;

type

  { TFormOptions }

  TFormOptions = class(TForm)
    Button_SyncPath: TButton;
    CheckBox_Fields_img: TCheckBox;
    CheckBox_AutoSave: TCheckBox;
    CheckBox_Backup_xml: TCheckBox;
    CheckBox_FormatEditOpt_AllowBasicFormatEdit: TCheckBox;
    CheckBox_FormatEditOpt_ForceSave: TCheckBox;
    CheckBox_FormatEditOpt_F9_To_Save: TCheckBox;
    Edit_SyncPath: TEdit;
    GroupBox_FormatEdit: TGroupBox;
    GroupBox_SyncPath: TGroupBox;
    GroupBox_SyncFilter: TGroupBox;
    GroupBox_SyncInterval: TGroupBox;
    Label_SyncInterval: TLabel;
    Memo_RegExpr: TMemo;
    PageControl_Option: TPageControl;
    CheckBox_SyncEnabled: TCheckBox;
    RadioGroup_BackupMode: TRadioGroup;
    ScrollBox_Sync: TScrollBox;
    SelectDirectoryDialog: TSelectDirectoryDialog;
    TabSheet_Backup: TTabSheet;
    TabSheet_Format: TTabSheet;
    TabSheet_Summary: TTabSheet;
    TabSheet_Sync: TTabSheet;
    TrackBar_SyncInterval: TTrackBar;
    procedure Button_SyncPathClick(Sender: TObject);
    procedure CheckBox_Backup_xmlChange(Sender: TObject);
    procedure CheckBox_Fields_imgChange(Sender: TObject);
    procedure CheckBox_FormatEditOpt_ForceSaveChange(Sender: TObject);
    procedure Edit_SyncPathChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Memo_RegExprChange(Sender: TObject);
    procedure CheckBox_SyncEnabledChange(Sender: TObject);
    procedure RadioGroup_BackupModeClick(Sender: TObject);
    procedure TrackBar_SyncIntervalChange(Sender: TObject);
  private
    TimerEnabled:boolean;//在OnShow和OnHide之间存储FormDesktop.SyncTimer.Enabled
  public
    procedure LoadOptionFromReg;
    procedure SaveOptionToReg;
  end;

var
  FormOptions: TFormOptions;

implementation
uses RTFP_main, rtfp_type;

{$R *.lfm}

{ TFormOptions }

procedure TFormOptions.TrackBar_SyncIntervalChange(Sender: TObject);
var pos:double;
begin
  pos:=(Sender as TTrackBar).Position;
  pos:=exp(ln(1.42547322)*pos)/10;
  Label_SyncInterval.Caption:=FloatToStrF(pos,ffFixed,1,2)+'秒';
  FormDesktop.SyncTimer.Interval:=trunc(pos*1000);
end;

procedure TFormOptions.CheckBox_SyncEnabledChange(Sender: TObject);
begin
  TimerEnabled:=(Sender as TCheckBox).Checked;
end;

procedure TFormOptions.Edit_SyncPathChange(Sender: TObject);
var stmp:string;
begin
  stmp:=(Sender as TEdit).Caption;
  if FormDesktop.SyncTimer.SyncPath<>stmp then
    FormDesktop.SyncTimer.SyncPath:=stmp;
end;

procedure TFormOptions.FormActivate(Sender: TObject);
var tmpPos:double;
    posint:integer;
begin
  CheckBox_SyncEnabled.Checked:=TimerEnabled;
  with FormDesktop.SyncTimer do
    begin
      Edit_SyncPath.Caption:=SyncPath;
      case BackupMode of
        apmCutBackup:RadioGroup_BackupMode.ItemIndex:=0;
        apmFullBackup:RadioGroup_BackupMode.ItemIndex:=1;
        apmAddress:RadioGroup_BackupMode.ItemIndex:=2;
      end;
      Memo_RegExpr.Text:=Rule;
      tmpPos:=ln(interval/100)/ln(1.42547322)+1;
      posint:=trunc(tmpPos);
      if posint<0 then posint:=0;
      if posint>20 then posint:=20;
      TrackBar_SyncInterval.Position:=posint;
    end;
  CheckBox_Backup_xml.Checked:=FormDesktop.OptionMap.Backup_SaveXml;
  CheckBox_Fields_img.Checked:=FormDesktop.OptionMap.Fields_ImgFile;
  CheckBox_FormatEditOpt_ForceSave.Checked:=FormDesktop.OptionMap.ForceSaveField;
end;

procedure TFormOptions.FormHide(Sender: TObject);
begin
  if TimerEnabled then FormDesktop.SyncTimer.Enabled:=true;
end;

procedure TFormOptions.FormShow(Sender: TObject);
begin
  TimerEnabled:=FormDesktop.SyncTimer.Enabled;
  if TimerEnabled then FormDesktop.SyncTimer.Enabled:=false;
end;

procedure TFormOptions.Memo_RegExprChange(Sender: TObject);
var str:string;
begin
  str:=(Sender as TMemo).Text;
  FormDesktop.SyncTimer.Rule:=str;
  if FormDesktop.SyncTimer.CheckRegExpr then Memo_RegExpr.Color:=clDefault
  else Memo_RegExpr.Color:=$00DDDDFF;
end;

procedure TFormOptions.Button_SyncPathClick(Sender: TObject);
begin
  with SelectDirectoryDialog do if Execute then
    begin
      Edit_SyncPath.Caption:=FileName;
    end;
end;

procedure TFormOptions.CheckBox_Backup_xmlChange(Sender: TObject);
var status:boolean;
begin
  status:=(Sender as TCheckBox).Checked;
  FormDesktop.OptionMap.Backup_SaveXml:=status;
  if not ProjectInvalid then CurrentRTFP.RunPerformance.Backup_SaveXml:=status;
end;

procedure TFormOptions.CheckBox_Fields_imgChange(Sender: TObject);
var status:boolean;
begin
  status:=(Sender as TCheckBox).Checked;
  FormDesktop.OptionMap.Fields_ImgFile:=status;
  if not ProjectInvalid then CurrentRTFP.RunPerformance.Fields_ImgFile:=status;
end;

procedure TFormOptions.CheckBox_FormatEditOpt_ForceSaveChange(Sender: TObject);
var status:boolean;
begin
  status:=(Sender as TCheckBox).Checked;
  FormDesktop.OptionMap.ForceSaveField:=status;
  if not ProjectInvalid then CurrentRTFP.RunPerformance.ForceSaveField:=status;
end;

procedure TFormOptions.RadioGroup_BackupModeClick(Sender: TObject);
begin
  case (Sender as TRadioGroup).ItemIndex of
    0:FormDesktop.SyncTimer.BackupMode:=apmCutBackup;
    1:FormDesktop.SyncTimer.BackupMode:=apmFullBackup;
    2:FormDesktop.SyncTimer.BackupMode:=apmAddress;
  end;
end;

procedure TFormOptions.LoadOptionFromReg;
var Reg:TRegistry;
begin
  FormDesktop.SyncTimer.Enabled:=false;
  Reg:=TRegistry.Create;
  try
    Reg.RootKey:=HKEY_CURRENT_USER;
    if Reg.OpenKey('Software\ApiglioToolBox\RTFP_Desktop\SyncTimer',false) then
      begin
        FormDesktop.SyncTimer.SyncPath:=WinCPtoUTF8(Reg.ReadString('SyncPath'));
        FormDesktop.SyncTimer.BackupMode:=TAddPaperMethod(Reg.ReadInteger('BackupMode'));
        FormDesktop.SyncTimer.Interval:=Reg.ReadInteger('Interval');
        FormDesktop.SyncTimer.Rule:=WinCPtoUTF8(Reg.ReadString('Rule'));
        FormDesktop.SyncTimer.Enabled:=Reg.ReadBool('Enabled');
        Reg.CloseKey;
      end
    else
      begin
        FormDesktop.SyncTimer.SyncPath:='E:\chrome_download';
        FormDesktop.SyncTimer.BackupMode:=apmFullBackup;
        FormDesktop.SyncTimer.Interval:=1195;
        FormDesktop.SyncTimer.Rule:='\.pdf|\.caj|\.docx*|\.xlsx*|\.sep|\.od[ts]';
        FormDesktop.SyncTimer.Enabled:=false;
      end;
    if Reg.OpenKey('Software\ApiglioToolBox\RTFP_Desktop\BackupOption',false) then
      begin
        FormDesktop.OptionMap.Backup_SaveXml:=Reg.ReadBool('SaveXml');
        Reg.CloseKey;
      end
    else
      begin
        FormDesktop.OptionMap.Backup_SaveXml:=false;
      end;
    if Reg.OpenKey('Software\ApiglioToolBox\RTFP_Desktop\FieldsOption',false) then
      begin
        FormDesktop.OptionMap.Fields_ImgFile:=Reg.ReadBool('ImgFile');
        if Reg.ValueExists('ForceEdit') then
          FormDesktop.OptionMap.ForceSaveField:=Reg.ReadBool('ForceEdit')
        else
          FormDesktop.OptionMap.ForceSaveField:=false;
        Reg.CloseKey;
      end
    else
      begin
        FormDesktop.OptionMap.Fields_ImgFile:=false;
      end;

  finally
    Reg.Free;
  end;
end;

procedure TFormOptions.SaveOptionToReg;
var Reg:TRegistry;
begin
  Reg:=TRegistry.Create;
  try
    Reg.RootKey:=HKEY_CURRENT_USER;
    Reg.OpenKey('Software\ApiglioToolBox\RTFP_Desktop\SyncTimer',true);
    Reg.WriteString('SyncPath',UTF8ToWinCP(FormDesktop.SyncTimer.SyncPath));
    Reg.WriteInteger('BackupMode',ord(FormDesktop.SyncTimer.BackupMode));
    Reg.WriteInteger('Interval',FormDesktop.SyncTimer.Interval);
    Reg.WriteString('Rule',UTF8ToWinCP(FormDesktop.SyncTimer.Rule));
    Reg.WriteBool('Enabled',FormDesktop.SyncTimer.Enabled);
    Reg.CloseKey;

    Reg.OpenKey('Software\ApiglioToolBox\RTFP_Desktop\BackupOption',true);
    Reg.WriteBool('SaveXml',FormDesktop.OptionMap.Backup_SaveXml);
    Reg.CloseKey;

    Reg.OpenKey('Software\ApiglioToolBox\RTFP_Desktop\FieldsOption',true);
    Reg.WriteBool('ImgFile',FormDesktop.OptionMap.Fields_ImgFile);
    Reg.WriteBool('ForceEdit',FormDesktop.OptionMap.ForceSaveField);
    Reg.CloseKey;

  finally
    Reg.Free;
  end;
end;

end.

