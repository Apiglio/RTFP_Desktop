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

  TFmtEditState = (fesUnknown=0, fesReadOnly=1, fesSaved=2, fesModified=3, fesNodata=4, fesNoField=5);
  //Unknown为意外情况，ReadOnly为只读模式，Saved为可编辑且未修改
  //Modifify为可编辑且未保存，Nodata为可编辑但无数据，NoField为没有字段

  TFmtImage = class(TScrollBox)
  private
    FPopupMenu:TPopupMenu;
    FImage:TImage;
  private
    procedure BandSolo(band:byte);
  protected
    procedure PastePicture(Sender:TObject);
    procedure CopyPicture(Sender:TObject);
    procedure OpenPicture(Sender:TObject);
    procedure CompressPicture(Sender:TObject);

    procedure BandSolo_R(Sender:TObject);
    procedure BandSolo_G(Sender:TObject);
    procedure BandSolo_B(Sender:TObject);

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
    FState:TFmtEditState;
  public
    constructor Create(CmpClass:TClass);
    destructor Destroy;

  protected
    procedure SetEditable(inp:boolean);

  public
    property TitleLabel:TLabel read FLabel;
    property Component:Pointer read FComponent;
    property ComponentClass:TClass read FClass;

    property DisplayName:string read FDisplayName write FDisplayName;
    property AttrsName:string read FAttrsName write FAttrsName;
    property FieldName:string read FFieldName write FFieldName;

    property Editable:boolean read FEditable write SetEditable;

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

    procedure FmtPanelPaint(Sender:TObject);
    procedure FmtPanelComponentChange(Sender:TObject);
    procedure FmtPanelKeyUp(Sender:TObject;var Key:Word;Shift:TShiftState);


    procedure SetState(value:TFmtEditState);

  public
    procedure RestoreState;//Setter函数中包含了FState:=fesSaved，如果是还原字段数值则需要用这个方法
    property State:TFmtEditState read FState write SetState;
    property ComponentType:TClass read FClass;

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

procedure TFmtImage.BandSolo(band:byte);
var pi,pj:integer;
    ptr:pdword;
    tmpBitMap:TBitmap;
    r:TRect;
begin
  if band>3 then exit;
  tmpBitMap:=TBitmap.Create;
  try
    tmpBitMap.PixelFormat:=pf32bit;
    r.Top:=0;
    r.Left:=0;
    r.Width:=FImage.Picture.Bitmap.Width;
    r.Height:=FImage.Picture.Bitmap.Height;

    tmpBitMap.SetSize(r.Width,r.Height);
    tmpBitMap.Canvas.CopyRect(r,FImage.Picture.Bitmap.Canvas,r);
    for pi:=0 to r.Height-1 do
      begin
        for pj:=0 to r.Width-1 do
          begin
            ptr:=tmpBitMap.ScanLine[pi];
            ptr:=ptr+pj;
            ptr^:=ptr^ shr (band*8);
            ptr^:=ptr^ and $000000ff;
            ptr^:=ptr^ * $10101;
          end;
      end;
    //FImage.Picture.Bitmap:=tmpBitMap;
    FImage.Picture.Bitmap.Canvas.CopyRect(r,tmpBitMap.Canvas,r);//通道化没有立刻更改显示????怎么回事????
  finally
    tmpBitMap.Free;
  end;
end;

procedure TFmtImage.PastePicture(Sender:TObject);
begin
  if Clipboard.HasFormat(PredefinedClipboardFormat(pcfDelphiBitmap)) then
    FImage.Picture.Bitmap.LoadFromClipboardFormat(PredefinedClipboardFormat(pcfDelphiBitmap));
  if Clipboard.HasFormat(PredefinedClipboardFormat(pcfBitmap)) then
    FImage.Picture.Bitmap.LoadFromClipboardFormat(PredefinedClipboardFormat(pcfBitmap));
  TFormatEditPanel(Parent).FmtPanelComponentChange(Self);
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
    Repaint;
  finally
    tmpBitmap.Free;
  end;
end;
procedure TFmtImage.BandSolo_R(Sender:TObject);
begin
  BandSolo(2);
end;
procedure TFmtImage.BandSolo_G(Sender:TObject);
begin
  BandSolo(1);
end;
procedure TFmtImage.BandSolo_B(Sender:TObject);
begin
  BandSolo(0);
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
  FPopupMenu.Items[6].Caption:='通道灰度图';
  FPopupMenu.Items[6].OnClick:=nil;

  FPopupMenu.Items[6].Add(TMenuItem.Create(Self));
  FPopupMenu.Items[6].Add(TMenuItem.Create(Self));
  FPopupMenu.Items[6].Add(TMenuItem.Create(Self));

  FPopupMenu.Items[6].Items[0].Caption:='红通道';
  FPopupMenu.Items[6].Items[0].OnClick:=@BandSolo_R;
  FPopupMenu.Items[6].Items[1].Caption:='绿通道';
  FPopupMenu.Items[6].Items[1].OnClick:=@BandSolo_G;
  FPopupMenu.Items[6].Items[2].Caption:='蓝通道';
  FPopupMenu.Items[6].Items[2].OnClick:=@BandSolo_B;

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
    'TEdit':
      begin
        FComponent:=TEdit.Create(Self);
        TEdit(FComponent).OnChange:=@FmtPanelComponentChange;
      end;
    'TMemo':
      begin
        FComponent:=TMemo.Create(Self);
        TMemo(FComponent).ScrollBars:=ssAutoVertical;
        TMemo(FComponent).OnChange:=@FmtPanelComponentChange;
      end;
    'TComboBox':
      begin
        FComponent:=TComboBox.Create(Self);
        TComboBox(FComponent).OnChange:=@FmtPanelComponentChange;
      end;
    'TCheckBox':
      begin
        FComponent:=TCheckBox.Create(Self);
        TCheckBox(FComponent).OnChange:=@FmtPanelComponentChange;
      end;
    'TFmtImage':
      begin
        FComponent:=TFmtImage.Create(Self);
        //image的modified在右键菜单设置中
      end;
    'TListBox':
      begin
        FComponent:=TListBox.Create(Self);
        //TListBox(FComponent).onOnChange:=@FmtPanelComponentChange;//这个目前似乎还没准备好
      end;
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
  if TObject(FComponent) is TWinControl then begin
    TWinControl(FComponent).Parent:=Self;
  end else begin
    TFmtImage(FComponent).Parent:=Self;
  end;

  Self.OnPaint:=@FmtPanelPaint;
  Self.OnKeyUp:=@FmtPanelKeyUp;
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
    'TListBox':TListBox(FComponent).Free;
    else raise Exception.Create('FormatEditPanel Type Error');
  end;
  inherited Destroy;
end;

procedure TFormatEditPanel.SetEditable(inp:boolean);
begin
  case FClass.ClassName of
    'TEdit':TEdit(FComponent).ReadOnly:=not inp;
    'TMemo':TMemo(FComponent).ReadOnly:=not inp;
    'TComboBox':TComboBox(FComponent).ReadOnly:=not inp;
    'TCheckBox':TCheckBox(FComponent).Enabled:=inp;
    'TFmtImage':TFmtImage(FComponent).Enabled:=inp;
    'TListBox':TListBox(FComponent).Enabled:=inp;
    else raise Exception.Create('FormatEditPanel Type Error');
  end;
  if inp then begin
    case FState of
      fesUnknown:FState:=fesSaved;
      else;
    end;
    //Paint;
  end else begin
    case FState of
      fesUnknown:FState:=fesReadOnly;
      else;
    end;
    //Paint;
  end;
  FEditable:=inp;
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
    'TListBox':result:=TListBox(FComponent).Items;
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
  FState:=fesSaved;
end;
procedure TFormatEditPanel.SetLInt(value:int64);
begin
  case FClass.ClassName of
    'TEdit':TEdit(FComponent).Caption:=IntToStr(value);
  end;
  FState:=fesSaved;
end;
procedure TFormatEditPanel.SetFloat(value:double);
begin
  case FClass.ClassName of
    'TEdit':TEdit(FComponent).Caption:=FloatToStr(value);
  end;
  FState:=fesSaved;
end;
procedure TFormatEditPanel.SetString(value:string);
begin
  case FClass.ClassName of
    'TEdit':TEdit(FComponent).Caption:=value;
  end;
  FState:=fesSaved;
end;

procedure TFormatEditPanel.RestoreState;
begin
  if Self.FEditable then Self.FState:=fesSaved
  else Self.FState:=fesReadOnly;
  Self.Paint;
end;


procedure TFormatEditPanel.FmtPanelPaint(Sender:TObject);
var state_color:TColor;
begin
  //加入色条表示数据状态 //aBGR
  case FState of
    fesUnknown:state_color:=$7FFF7FFF;//Purple
    fesReadOnly:state_color:=$7F7F7FFF;//Red
    fesSaved:state_color:=$7F7FFF7F;//Green
    fesModified:state_color:=$7F7FFFFF;//Yellow
    fesNodata:state_color:=$7F7F7F7F;//Grey
    fesNoField:state_color:=$7FFF7FFF;//Purple
  end;
  Canvas.Brush.Color:=state_color;
  Canvas.Pen.Color:=state_color;
  Canvas.Brush.Style:=bsSolid;
  Canvas.Rectangle(0,26,Canvas.Width,28);

end;
procedure TFormatEditPanel.FmtPanelComponentChange(Sender:TObject);
begin
  Self.FState:=fesModified;
  Self.Paint;
end;
procedure TFormatEditPanel.FmtPanelKeyUp(Sender:TObject;var Key:Word;Shift:TShiftState);
begin
  //消息部分有问题，TEdit之类的会吞消息，TFmtImage又抢不过DBGrid_Main
  {
  if (Shift=[ssCtrl]) and (Key=83) then
    begin
      ShowMsgOK('Save','Save');
    end;
  }
end;
procedure TFormatEditPanel.SetState(value:TFmtEditState);
begin
  FState:=value;
  Paint;
end;

end.

