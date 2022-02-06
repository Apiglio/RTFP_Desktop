unit rtfp_format_component;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, StdCtrls, ExtCtrls, Graphics, Menus, Forms,
  graphtype, intfgraphics, lazcanvas,
  Clipbrd, LCLIntf, LCLType;

type

  TFColor = record b,g,r:Byte;end;
  PFColor = ^TFColor;
  TLine = array[0..0] of TFColor;
  PLine = ^TLine;



  TFmtImage = class(TScrollBox)
  private
    FPopupMenu:TPopupMenu;
    FImage:TImage;
  protected
    procedure FmtMouseUp(Sender:TObject;Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
    procedure PastePicture(Sender:TObject);
    procedure CopyPicture(Sender:TObject);
    procedure OpenPicture(Sender:TObject);
    procedure CompressPicture(Sender:TObject);

  public
    constructor Create(AOwner:TComponent);override;
    destructor Destroy; override;
    property Image:TImage read FImage;
  end;


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
    function GetBitMap:TBitMap;
    //function GetImage:TImage;

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
    property AsBitMap:TBitMap read GetBitMap;
    //property AsImage:TImage read GetImage;

  end;


implementation
uses rtfp_dialog;


//版权声明：本文为CSDN博主「OK_boom」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
//原文链接：https://blog.csdn.net/rocklee/article/details/23772391
procedure StretchDrawBitmapToBitmap(SourceBitmap, DestBitmap: TBitmap; DestWidth, DestHeight: integer);
var DestIntfImage, SourceIntfImage: TLazIntfImage;
    DestCanvas: TLazCanvas;
begin
  // Prepare the destination
  DestBitmap.Height:=DestHeight;
  DestBitmap.Width:=DestWidth;
  DestIntfImage := TLazIntfImage.Create(0, 0);
  DestIntfImage.LoadFromBitmap(DestBitmap.Handle, 0);
  DestCanvas := TLazCanvas.Create(DestIntfImage);
  //Prepare the source
  SourceIntfImage := TLazIntfImage.Create(0, 0);
  SourceIntfImage.LoadFromBitmap(SourceBitmap.Handle, 0);
  // Execute the stretch draw via TFPSharpInterpolation
  DestCanvas.Interpolation := TFPSharpInterpolation.Create;
  DestCanvas.StretchDraw(0, 0, DestWidth, DestHeight, SourceIntfImage);
  // Reload the image into the TBitmap
  DestBitmap.LoadFromIntfImage(DestIntfImage);
  SourceIntfImage.Free;
  DestCanvas.Interpolation.Free;
  DestCanvas.Free;
  DestIntfImage.Free;
end;


//版权声明：本文为CSDN博主「OK_boom」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
//原文链接：https://blog.csdn.net/rocklee/article/details/23772391
procedure SmoothResize(Src,Dst: TBitmap;newWidth,newHeight:integer);
var x,y,xP,yP,yP2,xP2:Integer;
    Read,Read2:PLine;
    t,z,iz,z2,iz2:Integer;
    pc:PFColor;
begin
  if src.Width=1 then Exit;
  Dst.Width:=newWidth;
  Dst.Height:=newHeight;
  {
  if (Dst.Width = src.Width) and (Dst.Height = src.Height) then begin
    CopyMemory(Dst.Bits,Bits,Size);
    Exit;
  end;
  }
  xP2:=((src.Width-1) shl 16) div Dst.Width;
  yP2:=((src.Height-1) shl 16) div Dst.Height;
  yP:=0;
  for y:=0 to Dst.Height-1 do begin
    xP:=0;
    Read:=src.ScanLine[yP shr 16];
    if yP shr 16 < src.Height - 1 then Read2:=src.ScanLine[yP shr 16+1]
    else Read2:=src.ScanLine[yP shr 16];
    pc:=Dst.ScanLine[y];
    z2:=yP and $FFFF;
    iz2:=$10000-z2;
    for x:=0 to Dst.Width-1 do begin
      t:=xP shr 16;
      z:=xP and $FFFF;
      iz:=$10000-z;
      pc^.b:=(((Read^[t].b*iz+Read^[t+1].b*z) shr 16)*iz2+((Read2^[t].b*iz+Read2^[t+1].b*z) shr 16)*z2) shr 16;
      pc^.r:=(((Read^[t].r*iz+Read^[t+1].r*z) shr 16)*iz2+((Read2^[t].r*iz+Read2^[t+1].r*z) shr 16)*z2) shr 16;
      pc^.g:=(((Read^[t].g*iz+Read^[t+1].g*z) shr 16)*iz2+((Read2^[t].g*iz+Read2^[t+1].g*z) shr 16)*z2) shr 16;
      Inc(pc);
      Inc(xP,xP2);
    end;
    Inc(yP, yP2);
  end;
end;




procedure TFmtImage.FmtMouseUp(Sender:TObject;Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
begin
  //if (Button=mbRight) and (Shift=[]) then
  //  begin
      //FPopupMenu.PopUp;
      MessageBox(0,'AA','AAA',mb_OK);
  //  end;
end;

procedure TFmtImage.PastePicture(Sender:TObject);
begin
  if Clipboard.HasFormat(PredefinedClipboardFormat(pcfDelphiBitmap)) then
    FImage.Picture.Bitmap.LoadFromClipboardFormat(PredefinedClipboardFormat(pcfDelphiBitmap));
  if Clipboard.HasFormat(PredefinedClipboardFormat(pcfBitmap)) then
    FImage.Picture.Bitmap.LoadFromClipboardFormat(PredefinedClipboardFormat(pcfBitmap));
end;
procedure TFmtImage.CopyPicture(Sender:TObject);
begin
  FImage.Picture.Bitmap.SaveToClipboardFormat(PredefinedClipboardFormat(pcfBitmap));
end;
procedure TFmtImage.OpenPicture(Sender:TObject);
begin
  ShowMsgImage('图片详情',FImage.Picture.Bitmap,true);
end;
procedure TFmtImage.CompressPicture(Sender:TObject);
var ow,oh,nw,nh:integer;
    nwh:string;
    tmpBitmap:TBitMap;
begin
  ow:=FImage.Picture.Bitmap.Width;
  oh:=FImage.Picture.Bitmap.Height;
  nwh:=ShowMsgEdit('压缩图片','压缩后像素宽度：',IntToStr(ow));
  try
    nw:=StrToInt(nwh);
    nh:=oh*nw div ow;
    if nh*nw=0 then raise Exception.Create('');
    if (nh>4000) or (nw>4000) then raise Exception.Create('');
  except
    ShowMsgOK('错误','新尺寸过大或无效，未能压缩图片属性。');
    exit;
  end;
  tmpBitmap:=TBitmap.Create;
  try
    //SmoothResize(FImage.Picture.Bitmap,tmpBitmap,nw,nh);
    StretchDrawBitmapToBitmap(FImage.Picture.Bitmap,tmpBitmap,nw,nh);
    FImage.Picture.Bitmap:=tmpBitmap;
  finally
    tmpBitmap.Free;
  end;
end;
constructor TFmtImage.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);
  FImage:=TImage.Create(Self);
  with FImage do
    begin
      Parent:=Self;
      Align:=alClient;
      Proportional:=true;
    end;
  Self.AutoScroll:=true;
  Self.VertScrollBar.Visible:=true;

  FPopupMenu:=TPopupMenu.Create(Self);
  FPopupMenu.Parent:=Self;
  FPopupMenu.Items.Add(TMenuItem.Create(Self));
  FPopupMenu.Items.Add(TMenuItem.Create(Self));
  FPopupMenu.Items.Add(TMenuItem.Create(Self));
  FPopupMenu.Items.Add(TMenuItem.Create(Self));
  FPopupMenu.Items.Add(TMenuItem.Create(Self));
  FPopupMenu.Items.Add(TMenuItem.Create(Self));
  FPopupMenu.Items[0].Caption:='打开';
  FPopupMenu.Items[0].OnClick:=@OpenPicture;
  FPopupMenu.Items[1].Caption:='-';
  FPopupMenu.Items[1].OnClick:=nil;
  FPopupMenu.Items[2].Caption:='复制';
  FPopupMenu.Items[2].OnClick:=@CopyPicture;
  FPopupMenu.Items[3].Caption:='粘贴';
  FPopupMenu.Items[3].OnClick:=@PastePicture;
  FPopupMenu.Items[4].Caption:='-';
  FPopupMenu.Items[4].OnClick:=nil;
  FPopupMenu.Items[5].Caption:='压缩图片';
  FPopupMenu.Items[5].OnClick:=@CompressPicture;
  //FImage.OnMouseUp:=@FmtMouseUp;
  FImage.OnDblClick:=@OpenPicture;
  PopupMenu:=FPopupMenu;
end;
destructor TFmtImage.Destroy;
begin
  //FImage.Free;
  inherited Destroy;
end;

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
    'TMemo':begin FComponent:=TMemo.Create(Self);TMemo(FComponent).ScrollBars:=ssAutoVertical;end;
    'TComboBox':FComponent:=TComboBox.Create(Self);
    'TCheckBox':FComponent:=TCheckBox.Create(Self);
    'TFmtImage':FComponent:=TFmtImage.Create(Self);
    else raise Exception.Create('FormatEditPanel Type Error');
  end;
  with TControl(FComponent) do begin
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
  if TObject(FComponent) is TWinControl then
    TWinControl(FComponent).Parent:=Self
  else begin
    TFmtImage(FComponent).Parent:=Self;
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
    'TFmtImage':TFmtImage(FComponent).Free;
    else raise Exception.Create('FormatEditPanel Type Error');
  end;
  inherited Destroy;
end;

function TFormatEditPanel.GetBool:boolean;
begin
  case FClass.ClassName of
    'TCheckBox':result:=TCheckBox(FComponent).Checked;
    else result:=false;
  end;
end;
function TFormatEditPanel.GetLInt:int64;
begin
  try
    case FClass.ClassName of
      'TEdit':result:=StrToInt(TEdit(FComponent).Caption);
      else result:=0;
    end;
  except
    result:=0;
  end;
end;
function TFormatEditPanel.GetFloat:double;
begin
  try
    case FClass.ClassName of
      'TEdit':result:=StrToFloat(TEdit(FComponent).Caption);
      else result:=0;
    end;
  except
    result:=0;
  end;
end;
function TFormatEditPanel.GetString:string;
begin
  case FClass.ClassName of
    'TEdit':result:=TEdit(FComponent).Caption;
    else result:='';
  end;
end;

function TFormatEditPanel.GetLines:TStrings;
begin
  case FClass.ClassName of
    'TMemo':result:=TMemo(FComponent).Lines;
    else result:=nil;
  end;
end;

function TFormatEditPanel.GetBitMap:TBitMap;
begin
  case FClass.ClassName of
    'TFmtImage':result:=TFmtImage(FComponent).Image.Picture.Bitmap;
    else result:=nil;
  end;
end;
{
function TFormatEditPanel.GetImage:TImage;
begin
  case FClass.ClassName of
    'TFmtImage':result:=TFmtImage(FComponent);
    else result:=nil;
  end;
end;
}

procedure TFormatEditPanel.SetBool(value:boolean);
begin
  case FClass.ClassName of
    'TCheckBox':TCheckBox(FComponent).Checked:=value;
  end;
end;
procedure TFormatEditPanel.SetLInt(value:int64);
begin
  case FClass.ClassName of
    'TEdit':TEdit(FComponent).Caption:=IntToStr(value);
  end;
end;
procedure TFormatEditPanel.SetFloat(value:double);
begin
  case FClass.ClassName of
    'TEdit':TEdit(FComponent).Caption:=FloatToStr(value);
  end;
end;
procedure TFormatEditPanel.SetString(value:string);
begin
  case FClass.ClassName of
    'TEdit':TEdit(FComponent).Caption:=value;
  end;
end;


end.

