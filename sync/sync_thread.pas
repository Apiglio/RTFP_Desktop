unit sync_thread;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils;

type

  TLines_Thread_Proc = procedure(line:string;index:integer);
  TLines_Thread_Proc_Tips = procedure;
  TLines_Thread = class(TThread)
  private
    FProcStep:TLines_Thread_Proc;
    FProcStart:TLines_Thread_Proc_Tips;
    FProcTerminate:TLines_Thread_Proc_Tips;
    PLines:TStrings;
    FIndex:integer;
  protected
    procedure Execute;override;
    procedure SynchOnStep;
    procedure SynchOnStart;
    procedure SynchOnTerminate;
  public
    constructor Create(ALines:TStrings);
    property ProcStep:TLines_Thread_Proc read FProcStep write FProcStep;
    property ProcStart:TLines_Thread_Proc_Tips read FProcStart write FProcStart;
    property ProcTerminate:TLines_Thread_Proc_Tips read FProcTerminate write FProcTerminate;
  end;


implementation
uses RTFP_definition;

{ TLines_Thread }

procedure TLines_Thread.Execute;
begin
  Synchronize(@SynchOnStart);
  while (FIndex<PLines.Count) and (not Terminated) do begin
    Synchronize(@SynchOnStep);
    inc(FIndex);
  end;
  Synchronize(@SynchOnTerminate);
end;
procedure TLines_Thread.SynchOnStep;
begin
  if FProcStep<>nil then FProcStep(PLines[FIndex],FIndex);
end;
procedure TLines_Thread.SynchOnStart;
begin
  if FProcStart<>nil then FProcStart();
end;
procedure TLines_Thread.SynchOnTerminate;
begin
  if FProcTerminate<>nil then FProcTerminate();
end;
constructor TLines_Thread.Create(ALines:TStrings);
begin
  inherited Create(true);
  //CreateSuspended=true 必须在启动前设置三个事件
  FreeOnTerminate := True;
  PLines:=ALines;
  FIndex:=0;
end;


end.

