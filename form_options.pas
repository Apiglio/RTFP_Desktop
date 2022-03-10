unit form_options;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ExtCtrls;

type

  { TFormOptions }

  TFormOptions = class(TForm)
    Button_SyncPath: TButton;
    Edit_SyncPath: TEdit;
    GroupBox_SyncPath: TGroupBox;
    GroupBox_SyncFilter: TGroupBox;
    GroupBox_SyncInterval: TGroupBox;
    Label_SyncInterval: TLabel;
    Memo_RegExpr: TMemo;
    PageControl1: TPageControl;
    CheckBox_SyncEnabled: TCheckBox;
    RadioGroup_BackupMode: TRadioGroup;
    ScrollBox_Sync: TScrollBox;
    SelectDirectoryDialog: TSelectDirectoryDialog;
    TabSheet_Summary: TTabSheet;
    TabSheet_Sync: TTabSheet;
    TrackBar_SyncInterval: TTrackBar;
    procedure Button_SyncPathClick(Sender: TObject);
    procedure Edit_SyncPathChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Memo_RegExprChange(Sender: TObject);
    procedure CheckBox_SyncEnabledChange(Sender: TObject);
    procedure RadioGroup_BackupModeClick(Sender: TObject);
    procedure TrackBar_SyncIntervalChange(Sender: TObject);
  private

  public

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
      tmpPos:=ln(interval/100)/ln(1.42547322);
      if tmpPos<0 then tmpPos:=0;
      if tmpPos>20 then tmpPos:=20;
      TrackBar_SyncInterval.Position:=trunc(tmpPos);
    end;
end;

procedure TFormOptions.FormCreate(Sender: TObject);
begin

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

end.

