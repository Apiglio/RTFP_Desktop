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
    CheckBox_FormatEditOpt_AllowBasicFormatEdit: TCheckBox;
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
    TabSheet_Format: TTabSheet;
    TabSheet_Summary: TTabSheet;
    TabSheet_Sync: TTabSheet;
    TrackBar_SyncInterval: TTrackBar;
    procedure Button_SyncPathClick(Sender: TObject);
    procedure Edit_SyncPathChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Memo_RegExprChange(Sender: TObject);
    procedure CheckBox_SyncEnabledChange(Sender: TObject);
    procedure RadioGroup_BackupModeClick(Sender: TObject);
    procedure TrackBar_SyncIntervalChange(Sender: TObject);
  private

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
  FormDesktop.SyncTimer.Enabled:=(Sender as TCheckBox).Checked;
end;

procedure TFormOptions.Edit_SyncPathChange(Sender: TObject);
begin
  FormDesktop.SyncTimer.SyncPath:=(Sender as TEdit).Caption;
end;

procedure TFormOptions.FormActivate(Sender: TObject);
var tmpPos:double;
    posint:integer;
begin
  with FormDesktop.SyncTimer do
    begin
      CheckBox_SyncEnabled.Checked:=Enabled;
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
end;

procedure TFormOptions.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin

end;

procedure TFormOptions.FormCreate(Sender: TObject);
begin

end;

procedure TFormOptions.FormHide(Sender: TObject);
begin
  FormDesktop.SyncTimer.Enabled:=true;
end;

procedure TFormOptions.FormShow(Sender: TObject);
begin
  FormDesktop.SyncTimer.Enabled:=false;
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
      end
    else
      begin
        FormDesktop.SyncTimer.SyncPath:='E:\chrome_download';
        FormDesktop.SyncTimer.BackupMode:=apmFullBackup;
        FormDesktop.SyncTimer.Interval:=1195;
        FormDesktop.SyncTimer.Rule:='\.pdf|\.caj|\.docx*|\.xlsx*|\.sep|\.od[ts]';
        FormDesktop.SyncTimer.Enabled:=false;
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
  finally
    Reg.Free;
  end;
end;

end.

