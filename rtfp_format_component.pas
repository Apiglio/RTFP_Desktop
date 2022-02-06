//推荐取消泛型，改用指针

unit rtfp_format_component;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, StdCtrls, ExtCtrls, fgl;

type

  TFormatEditPanel = class(TPanel)
  private
    FComponent:Pointer;
    FLabel:TLabel;
    FClass:TClass;

    FDisplayName,FAttrsName,FFieldName:string;
    FEditable:boolean;
  public
    constructor Create(CmpClass:TClass);
    destructor Destroy;

  public
    property TitleLabel:TLabel read FLabel;
    property Component:Pointer read FComponent;
    property ComponentClass:TClass read FClass;

    property DisplayName:string read FDisplayName write FDisplayName;
    property AttrsName:string read FAttrsName write FAttrsName;
    property FieldName:string read FFieldName write FFieldName;

    property Editable:boolean read FEditable write FEditable;


  protected
    function GetBool:boolean;
    function GetLInt:int64;
    function GetFloat:double;
    function GetString:string;

    function GetLines:TStrings;

    procedure SetBool(value:boolean);
    procedure SetLInt(value:int64);
    procedure SetFloat(value:double);
    procedure SetString(value:string);

  public
    property AsBoolean:boolean read GetBool write SetBool;
    property AsLargeInt:int64 read GetLInt write SetLInt;
    property AsFloat:double read GetFloat write SetFloat;
    property AsString:string read GetString write SetString;
    property AsMemo:TStrings read GetLines;


  end;

  TFmtCmp = class
  public
    TitleLabel:TLabel;
    FEditable:boolean;
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
    property Editable:boolean read FEditable write FEditable;
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

  RTFP_ID_Exchange = string;


  //procedure FmtCmpGetLoadFromDB(PID:RTFP_ID_Exchange;Cmp:TFmtCmp);
  //procedure FmtCmpSetSaveToDB(PID:RTFP_ID_Exchange;Cmp:TFmtCmp);



implementation


constructor TFormatEditPanel.Create(CmpClass:TClass);
begin
  inherited Create(nil);
  Self.BevelWidth:=0;
  FClass:=CmpClass;
  FLabel:=TLabel.Create(Self);
  with FLabel do begin
    Parent:=Self;
    Height:=28;
    Anchors:=[akTop,akLeft];
    AnchorSideLeft.Control:=Self;
    AnchorSideLeft.Side:=asrLeft;
    BorderSpacing.Left:=0;
    AnchorSideTop.Control:=Self;
    AnchorSideTop.Side:=asrTop;
    BorderSpacing.Top:=0;
  end;
  case FClass.ClassName of
    'TEdit':FComponent:=TEdit.Create(Self);
    'TMemo':FComponent:=TMemo.Create(Self);
    'TComboBox':FComponent:=TComboBox.Create(Self);
    'TCheckBox':FComponent:=TCheckBox.Create(Self);
    else raise Exception.Create('FormatEditPanel Type Error');
  end;
  with TWinControl(FComponent) do begin
    Parent:=Self;
    Anchors:=[akTop,akLeft,akRight,akBottom];
    AnchorSideLeft.Control:=Self;
    AnchorSideLeft.Side:=asrLeft;
    BorderSpacing.Left:=0;

    AnchorSideTop.Control:=Self;
    AnchorSideTop.Side:=asrTop;
    BorderSpacing.Top:=TitleLabel.Height;

    AnchorSideRight.Control:=Self;
    AnchorSideRight.Side:=asrRight;
    BorderSpacing.Right:=0;

    AnchorSideBottom.Control:=Self;
    AnchorSideBottom.Side:=asrBottom;
    BorderSpacing.Bottom:=10;

  end;
  Self.Resize;
end;

destructor TFormatEditPanel.Destroy;
begin
  FLabel.Free;
  case FClass.ClassName of
    'TEdit':TEdit(FComponent).Free;
    'TMemo':TMemo(FComponent).Free;
    'TComboBox':TComboBox(FComponent).Free;
    'TCheckBox':TCheckBox(FComponent).Free;
    else raise Exception.Create('FormatEditPanel Type Error');
  end;
  inherited Destroy;
end;

function TFormatEditPanel.GetBool:boolean;
begin
  assert(FClass=TCheckBox,'非checkbox不能调用AsBoolean');
  result:=TCheckBox(FComponent).Checked;
end;
function TFormatEditPanel.GetLInt:int64;
begin
  assert(FClass=TEdit,'非edit不能调用AsLargeInt');
  try result:=StrToInt(TEdit(FComponent).Caption);
  except result:=0 end;
end;
function TFormatEditPanel.GetFloat:double;
begin
  assert(FClass=TEdit,'非edit不能调用AsFloat');
  try result:=StrToFloat(TEdit(FComponent).Caption);
  except result:=0 end;
end;
function TFormatEditPanel.GetString:string;
begin
  assert(FClass=TEdit,'非edit不能调用AsString');
  result:=TEdit(FComponent).Caption;
end;

function TFormatEditPanel.GetLines:TStrings;
begin
  assert(FClass=TMemo,'非memo不能调用AsLines');
  result:=TMemo(FComponent).Lines;
end;

procedure TFormatEditPanel.SetBool(value:boolean);
begin
  assert(FClass=TCheckBox,'非checkbox不能调用AsBoolean');
  TCheckBox(FComponent).Checked:=value;
end;
procedure TFormatEditPanel.SetLInt(value:int64);
begin
  assert(FClass=TEdit,'非edit不能调用AsLargeInt');
  TEdit(FComponent).Caption:=IntToStr(value);
end;
procedure TFormatEditPanel.SetFloat(value:double);
begin
  assert(FClass=TEdit,'非edit不能调用AsLargeInt');
  TEdit(FComponent).Caption:=FloatToStr(value);
end;
procedure TFormatEditPanel.SetString(value:string);
begin
  assert(FClass=TEdit,'非edit不能调用AsString');
  TEdit(FComponent).Caption:=value;
end;




constructor TFmtCmp.Create;
begin
  inherited Create;
  TitleLabel:=TLabel.Create(nil);
  FEditable:=true;
end;

destructor TFmtCmp.Destroy;
begin
  TitleLabel.Parent:=nil;
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
  TWinControl(FComponent).Parent:=nil;
  TComponent(FComponent).Free;
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

