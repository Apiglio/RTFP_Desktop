unit sync_thread;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils;

type

  TRTFP_Thread = class(TThread)
  private
    FRTFP_Project:TObject;
    procedure ProjectOperation;
  protected
    procedure Execute;override;
  public
    constructor Create(ARTFP_Project:TObject;CreateSuspended:Boolean);
  end;

  TRTFP_ThreadPool = class
  private
    FList:TList;
  public
    constructor Create;
    destructor Destroy;
  end;

implementation
uses RTFP_definition;

{ TRTFP_Thread }

procedure TRTFP_Thread.ProjectOperation;
begin
  //FRTFP_Project...;
end;
procedure TRTFP_Thread.Execute;
begin
  //...
  Synchronize(@ProjectOperation);
end;
constructor TRTFP_Thread.Create(ARTFP_Project:TObject;CreateSuspended:Boolean);
begin
  inherited Create(CreateSuspended);
  FRTFP_Project:=ARTFP_Project;
  FreeOnTerminate := True;
end;

{ TRTFP_ThreadPool }

constructor TRTFP_ThreadPool.Create;
begin
  inherited Create;
end;

destructor TRTFP_ThreadPool.Destroy;
begin
  inherited Destroy;
end;


end.

