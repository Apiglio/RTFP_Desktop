unit sync_timer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, RegExpr, rtfp_type, rtfp_class;

type
  TRTFP_SyncTimer = class(TComponent)
    private
      FTimer:TTimer;
      FEnabled:boolean;
      FInterval:integer;
      FSyncPath:string;
      FBackupMode:TAddPaperMethod;
      FRule:string;
      FFileListOld,FFileList,FFileListNew:TStringList;
      FRegExpr:TRegExpr;
    public
      procedure UpdateFileList;
      //每次更新FileList之前将上一次的结果存入Old，然后根据二者计算出新增New

      function CheckRegExpr:boolean;

    protected
      procedure SyncOnTimer(Sender:TObject);

      procedure SetInterval(value:integer);
      function GetInterval:integer;
      procedure SetEnabled(value:boolean);
      function GetEnabled:boolean;
      procedure SetRule(expr:string);
      procedure SetPath(path:string);

    public
      property SyncPath:string read FSyncPath write FSyncPath;
      property BackupMode:TAddPaperMethod read FBackupMode write FBackupMode;
      property Rule:string read FRule write SetRule;
      property Interval:integer read GetInterval write SetInterval;
      property Enabled:boolean read GetEnabled write SetEnabled;

    public
      constructor Create(AOwner:TComponent);
      destructor Destroy;override;
  end;


implementation
uses Forms, rtfp_dialog, rtfp_main, form_cite_trans;

function apm_str(apm:TAddPaperMethod):string;
begin
  case apm of
    apmFullBackup:result:='复制备份';
    apmCutBackup:result:='移动入库';
    apmAddress:result:='文件链接';
  end;
end;

procedure TRTFP_SyncTimer.UpdateFileList;
var Info:TSearchRec;
    pi,oup:integer;
    btmp:boolean;
Begin

  FFileListOld.Clear;
  FFileListOld.Assign(FFileList);
  FFileList.Clear;
  FFileListNew.Clear;

  If FindFirst(FSyncPath+'\*',faAnyFile,Info)=0 then
  Repeat
    With Info do
    if (Name<>'.') and (Name<>'..') and (Attr and faDirectory = 0) then
      begin
        try
          btmp:=FRegExpr.Exec(Name);
          except btmp:=false;
        end;
        if btmp then FFileList.Add(Name);
      end;
  Until FindNext(Info)<>0;
  FindClose(Info);

  //New = List - Old
  pi:=0;
  while pi<FFileList.Count do
    begin
      if not FFileListOld.Find(FFileList[pi],oup) then
        FFileListNew.Add(FFileList[pi]);
      inc(pi);
    end;
end;

function TRTFP_SyncTimer.CheckRegExpr:boolean;
begin
  result:=false;
  try
    if FRegExpr.Expression<>'' then if FRegExpr.Exec('-9~Ma中') then;
    except exit;
  end;
  result:=true;
end;

procedure TRTFP_SyncTimer.SyncOnTimer(Sender:TObject);
var filename,fullname,PID:string;
begin
  if ProjectInvalid then exit;
  FTimer.Enabled:=false;
  UpdateFileList;
  for filename in FFileListNew do
    begin
      fullname:=FSyncPath+'\'+filename;
      case ShowMsgYesNoAll('新建文件节点','是否为以下文件新建文献节点？'+#13#10+fullname+'（'+apm_str(FBackupMode)+'）') of
        'No':continue;
        else begin
          with CurrentRTFP do begin
            BeginUpdate;//这里不禁用会触发修改分组时的UpdateCurrentRec，应该重新考虑各个Change事件的时机
            PID:=AddPaper(fullname,FBackupMode);
            if PID='000000' then begin
              ShowMsgOK('SyncTimer','文件导入失败。');
              continue;
            end;
            KlassIncludeFromCombo(PID,true);
            EndUpdate;//这里不禁用会触发修改分组时的UpdateCurrentRec，应该重新考虑各个Change事件的时机
            RecordChange;
          end;
          with FormDesktop do begin
            Select_PID(PID);
            NodeViewValidate;
          end;
          Form_CiteTrans.ShowModal;
        end;
      end;
    end;
  FTimer.Enabled:=true;
end;
procedure TRTFP_SyncTimer.SetInterval(value:integer);
begin
  FTimer.Interval:=value;
  FInterval:=value;
end;
function TRTFP_SyncTimer.GetInterval:integer;
begin
  result:=FInterval;
end;
procedure TRTFP_SyncTimer.SetEnabled(value:boolean);
begin
  if not FTimer.Enabled and value then
    begin
      FFileList.Clear;
      UpdateFileList;
    end;
  FTimer.Enabled:=value;
  FEnabled:=value;
end;
function TRTFP_SyncTimer.GetEnabled:boolean;
begin
  result:=FEnabled;
end;
procedure TRTFP_SyncTimer.SetRule(expr:string);
begin
  FRule:=expr;
  FRegExpr.Expression:=expr;
  UpdateFileList;//规则修改后需要重新读取Old
end;

procedure TRTFP_SyncTimer.SetPath(path:string);
begin
  FSyncPath:=path;
  UpdateFileList;//规则路径后需要重新读取Old
end;

constructor TRTFP_SyncTimer.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);
  FTimer:=TTimer.Create(Self);
  with FTimer do
    begin
      Enabled:=false;
      Interval:=5000;
      OnTimer:=@SyncOnTimer;
    end;
  FEnabled:=false;
  FInterval:=5000;
  FRule:='\.pdf|\.caj';
  FSyncPath:='F:\chrome_downloaded';
  FBackupMode:=apmCutBackup;

  FFileList:=TStringList.Create;
  FFileList.Sorted:=true;
  FFileListOld:=TStringList.Create;
  FFileListOld.Sorted:=true;
  FFileListNew:=TStringList.Create;
  FFileListNew.Sorted:=true;
  FRegExpr:=TRegExpr.Create;
end;

destructor TRTFP_SyncTimer.Destroy;
begin
  FTimer.Free;
  FFileList.Free;
  FFileListOld.Free;
  FFileListNew.Free;
  FRegExpr.Free;
  inherited Destroy;
end;


end.

