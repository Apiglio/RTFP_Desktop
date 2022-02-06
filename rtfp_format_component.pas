unit rtfp_format_component;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, StdCtrls, ExtCtrls, fgl;

type

  TFmtCmp = class
  public
    TitleLabel:TLabel;
  public
    function GetAttrsName:string;virtual;abstract;
    function GetFieldName:string;virtual;abstract;
    function GetDisplayName:string;virtual;abstract;
    procedure SetAttrsName(str:string);virtual;abstract;
    procedure SetFieldName(str:string);virtual;abstract;
    procedure SetDisplayName(str:string);virtual;abstract;
  public
    function GetComponent:Pointer;virtual;abstract;
  public
    constructor Create;virtual;
    destructor Destroy;virtual;
  end;

  generic TFmtComponent<T>=class(TFmtCmp)
  private
    FAttrsName,FFieldName,FDisplayName:string;
    FComponent:T;
  public
    constructor Create;override;
    destructor Destroy;override;
  public
    function GetAttrsName:string;override;
    function GetFieldName:string;override;
    function GetDisplayName:string;override;
    procedure SetAttrsName(str:string);override;
    procedure SetFieldName(str:string);override;
    procedure SetDisplayName(str:string);override;
  public
    function GetComponent:Pointer;override;
  public
    property AttrsName:string read GetAttrsName write SetAttrsName;
    property FieldName:string read GetFieldName write SetFieldName;
    property DisplayName:string read GetDisplayName write SetDisplayName;
    property Component:Pointer read GetComponent;
  end;

  TFmtEdit = specialize TFmtComponent<TEdit>;
  TFmtMemo = specialize TFmtComponent<TMemo>;
  TFmtCheckBox = specialize TFmtComponent<TCheckBox>;
  TFmtComboBox = specialize TFmtComponent<TComboBox>;
  TFmtSplitter = specialize TFmtComponent<TSplitter>;
  //TFmt = specialize TFmtComponent<T>;


implementation

constructor TFmtCmp.Create;
begin
  inherited Create;
  TitleLabel:=TLabel.Create(nil);
end;

destructor TFmtCmp.Destroy;
begin
  TitleLabel.Free;
  inherited Destroy;
end;

constructor TFmtComponent.Create;
begin
  assert(TObject(T) is TComponent,'错误的泛型类型，需要是TComponent！');
  inherited Create;
  FComponent:=T.Create(nil);
  if TWinControl(FComponent) is TMemo then TMemo(FComponent).ScrollBars:=ssAutoVertical;
end;

destructor TFmtComponent.Destroy;
begin
  TObject(FComponent).Free;
  inherited Destroy;
end;

function TFmtComponent.GetAttrsName:string;
begin
  result:=FAttrsName;
end;
function TFmtComponent.GetFieldName:string;
begin
  result:=FFieldName;
end;
function TFmtComponent.GetDisplayName:string;
begin
  result:=FDisplayName;
end;
function TFmtComponent.GetComponent:Pointer;
begin
  result:=FComponent;
end;
procedure TFmtComponent.SetAttrsName(str:string);
begin
  FAttrsName:=str;
end;
procedure TFmtComponent.SetFieldName(str:string);
begin
  FFieldName:=str;
end;
procedure TFmtComponent.SetDisplayName(str:string);
begin
  FDisplayName:=str;
end;


end.

