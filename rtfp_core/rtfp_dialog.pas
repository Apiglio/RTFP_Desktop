unit rtfp_dialog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, Dialogs,
  // LCL
  LResources, LCLIntf, LCLType, LCLProc,
  Forms, Controls, Themes, GraphType, Graphics, Buttons, ButtonPanel, StdCtrls,
  ExtCtrls, ClipBrd, Menus, LCLTaskDialog,
  ListFilterEdit, CheckLst;

type

  RTFP_ModalResult=(
    rtmr_None=0,
    rtmr_OK=1,
    rtmr_Cancel=2,
    rtmr_Abort=3,
    rtmr_Retry=4,
    rtmr_Ignore=5,
    rtmr_Yes=6,
    rtmr_No=7,
    rtmr_All=8,
    rtmr_NoToAll=9,
    rtmr_YesToAll=10
  );

  TRTFP_Button=(
    rtmb_OK=1,
    rtmb_Cancel=2,
    rtmb_Abort=3,
    rtmb_Retry=4,
    rtmb_Ignore=5,
    rtmb_Yes=6,
    rtmb_No=7,
    rtmb_All=8,
    rtmb_NoToAll=9,
    rtmb_YesToAll=10
  );
  TRTFP_Button_Set=set of TRTFP_Button;

  TScrollImage = class(TScrollBox)
  private
    FImage:TImage;
    FDrag:boolean;
    FFirstPoint:Classes.TPoint;
    FTargetPoint:Classes.TPoint;
    FFirstPosition:Classes.TPoint;
  private
    procedure ScrollPaint(Sender:TObject);unimplemented;
    procedure ApplyMovement(X,Y:Integer);
  public
    procedure ScrollMouseDown(Sender:TObject;Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
    procedure ScrollMouseMove(Sender:TObject;Shift:TShiftState;X,Y:Integer);
    procedure ScrollMouseUp(Sender:TObject;Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
  public
    constructor Create(AOwner:TComponent;ABitmap:TBitmap);
    destructor Destroy;override;
  end;

  TAllState = class
  private
    FEnabled:boolean;//为真时触发All选项
    FConfirmed:boolean;//为真时表明做过一次选择
    FDefaultButton:string;//最后一次人工选择的结果
  public
    //property Enabled:boolean read FEnabled;
    property DefaultButton:string read FDefaultButton{ write FDefaultButton};
  public
    procedure Enable;//开始记录和选项，此时All显示，但是是灰的
    procedure SetButton(button:string);//指定一个选项作为之后的选项
    procedure ApplyAll;//开始应用指定的选项，此时不会弹窗
    procedure Disable;//结束记录，一切恢复正常，也不会有All选项
  public
    constructor Create;
    destructor Destroy;override;
  end;


var
  AllState,ConfirmState:TAllState;


function ShowMsgButtons(const ACaption,APrompt:string;AButtons:TRTFP_Button_Set):String;
function ShowMsgCombo(const ACaption,APrompt:string;const AList:TStrings;
  AllowInput:Boolean;Out ASelected:Integer):string;
function ShowMsgCombo(const ACaption,APrompt:string;const AList:TStrings):string;
function ShowMsgList(const ACaption,APrompt:string;const AList:TStrings;
  Out ASelected:Integer):string;
function ShowMsgList(const ACaption,APrompt:string;const AList:TStrings):string;
function ShowMsgCheckList(ACaption,APrompt:string;AList:TStrings;out SelList:TStrings;AllSelected:boolean=false):String;//AList会根据选择改变
function ShowMsgEdit(const ACaption,APrompt,DefaultStr:string):String;

function ShowMsgImage(const ACaption:string;const ABitmap:TBitmap;ShowPixelInfo:boolean=false):string;

function ShowMsgYesNoCancel(const ACaption,APrompt:string):String;//返回首字母大写的键名
function ShowMsgYesNoAll(const ACaption,APrompt:string;UseAllState:boolean=false):String;//返回首字母大写的键名，可以使用AllState操作All键
function ShowMsgRetryIgnore(const ACaption,APrompt:string;UseCancel:boolean=false):String;//返回首字母大写的键名
function ShowMsgOK(const ACaption,APrompt:string):String;
function ShowMsgOKAll(const ACaption,APrompt:string):String;


//继续制作以下几类全部替代之前的MessageDlg和InputBox：
//ShowMsgYesNoCancel:boolean;
//ShowMsgYesNoAll:boolean;
//ShowMsgRetryIgnore:boolean;
//ShowMsgOK;


implementation
uses RTFP_main;

procedure TAllState.Enable;
begin
  FEnabled:=true;
  FConfirmed:=false;
  FDefaultButton:='';
end;
procedure TAllState.SetButton(button:string);
begin
  FDefaultButton:=button;
end;
procedure TAllState.ApplyAll;
begin
  FConfirmed:=true;
end;
procedure TAllState.Disable;
begin
  FEnabled:=false;
  FConfirmed:=false;
end;
constructor TAllState.Create;
begin
  inherited Create;
  FEnabled:=false;
  FDefaultButton:='';
end;
destructor TAllState.Destroy;
begin
  inherited Destroy;
end;

//控件布局有些麻烦，先不写了。写完就可以把ShowMsgOK之类中的MessageDlg都替换了。
function ShowMsgButtons(const ACaption,APrompt:string;AButtons:TRTFP_Button_Set):String;
var
  W,I,Sep,Margin: Integer;
  Frm: TForm;
  LPrompt: TLabel;
  BP: TButtonPanel;
begin
  Margin:=24;
  Sep:=8;
  Result:='';
  Frm:=TForm.Create(FormDesktop);
  try
    W:=Max(frm.Canvas.TextWidth(APrompt),frm.Canvas.TextWidth(ACaption));
    W:=Max(W,360);
    W:=Min(W,540);

    with frm do begin
      BorderStyle:=bsDialog;
      Caption:=ACaption;
      ClientWidth:=W+2*Margin;
      Position:=poOwnerFormCenter;
      KeyPreview:=true;
    end;

    LPrompt:=TLabel.Create(frm);
    with LPrompt do begin
      Parent:=frm;
      Caption:=APrompt;
      SetBounds(Margin,Margin,Frm.ClientWidth-2*Margin,frm.Canvas.TextHeight(APrompt));
      WordWrap:=True;
      AutoSize:=False;
    end;

    BP:=TButtonPanel.Create(Frm);
    with BP do begin
      Parent:=Frm;
      ShowButtons:=[pbOK,pbCancel];
      ShowGlyphs:=[];
      OKButton.Caption:='&确认';
      CancelButton.Caption:='&取消';
    end;

    if (Frm.ShowModal=mrOk) then begin
      Result:='OK';
    end;

  finally
    FreeAndNil(Frm);
  end;
end;

function ShowMsgCombo(const ACaption,APrompt:string;const AList:TStrings;AllowInput:Boolean;Out ASelected:Integer):String;
const
  CBStyles : array[Boolean] of TComboBoxStyle = (csDropDownList,csDropDown);
var
  W,I,Sep,Margin: Integer;
  Frm: TForm;
  CBSelect : TComboBox;
  LPrompt: TLabel;
  BP: TButtonPanel;
begin
  Margin:=24;
  Sep:=8;
  Result:='';
  ASelected:=-1;
  Frm:=TForm.Create(FormDesktop);
  try

    W:=Max(frm.Canvas.TextWidth(APrompt),frm.Canvas.TextWidth(ACaption));
    W:=Max(W,360);
    W:=Min(W,540);
    for I:=0 to AList.Count-1 do W:=Max(W,frm.Canvas.TextWidth(AList[i]+'WWW'));//WWW占位符

    with frm do begin
      BorderStyle:=bsDialog;
      Caption:=ACaption;
      ClientWidth:=W+2*Margin;
      Position:=poOwnerFormCenter;
      KeyPreview:=true;
    end;

    LPrompt:=TLabel.Create(frm);
    with LPrompt do begin
      Parent:=frm;
      Caption:=APrompt;
      SetBounds(Margin,Margin,Frm.ClientWidth-2*Margin,frm.Canvas.TextHeight(APrompt));
      WordWrap:=True;
      AutoSize:=False;
    end;

    CBSelect:=TComboBox.Create(Frm);
    with CBSelect do begin
      Parent:=Frm;
      Style:=CBStyles[AllowInput];
      Items.Assign(AList);
      ItemIndex:=-1;
      Left:=Margin;
      Top:=LPrompt.Top + LPrompt.Height + Sep;
      Width:=Frm.ClientWidth-2*Margin;
    end;

    BP:=TButtonPanel.Create(Frm);
    with BP do begin
      Parent:=Frm;
      ShowButtons:=[pbOK,pbCancel];
      ShowGlyphs:=[];
      OKButton.Caption:='&确认';
      CancelButton.Caption:='&取消';
    end;

    Frm.ClientHeight:=LPrompt.Height+CBSelect.Height+BP.Height+2*Sep+Margin;

    if (Frm.ShowModal=mrOk) then begin
      Result:=CBSelect.Text;
      ASelected:=CBSelect.ItemIndex;
    end;

  finally
    FreeAndNil(Frm);
  end;
end;

function ShowMsgCombo(const ACaption,APrompt:string;const AList:TStrings):string;
var codee:integer;
begin
  result:=ShowMsgCombo(ACaption,APrompt,AList,false,codee);
end;


function ShowMsgList(const ACaption,APrompt:string;const AList:TStrings;Out ASelected:Integer):String;
var
  W,I,Sep,Margin: Integer;
  Frm: TForm;
  CBSelect : TListBox;
  CBSelectFilter : TListFilterEdit;
  LPrompt: TLabel;
  BP: TButtonPanel;
begin
  Margin:=24;
  Sep:=8;
  Result:='';
  ASelected:=-1;
  Frm:=TForm.Create(FormDesktop);
  try

    W:=Max(frm.Canvas.TextWidth(APrompt),frm.Canvas.TextWidth(ACaption));
    W:=Max(W,360);
    W:=Min(W,540);
    for I:=0 to AList.Count-1 do W:=Max(W,frm.Canvas.TextWidth(AList[i]+'WWW'));//WWW占位符

    with frm do begin
      BorderStyle:=bsDialog;
      Caption:=ACaption;
      ClientWidth:=W+2*Margin;
      Position:=poOwnerFormCenter;
      KeyPreview:=true;
    end;

    LPrompt:=TLabel.Create(frm);
    with LPrompt do begin
      Parent:=frm;
      Caption:=APrompt;
      SetBounds(Margin,Margin,Frm.ClientWidth-2*Margin,frm.Canvas.TextHeight(APrompt));
      WordWrap:=True;
      AutoSize:=False;
    end;

    CBSelect:=TListBox.Create(Frm);
    with CBSelect do begin
      Parent:=Frm;
      Items.Assign(AList);
      ItemIndex:=-1;
      Left:=Margin;
      Top:=LPrompt.Top + LPrompt.Height + Sep;
      Width:=Frm.ClientWidth-2*Margin;
      Height:=120;
    end;

    CBSelectFilter:=TListFilterEdit.Create(Frm);
    with CBSelectFilter do begin
      Parent:=Frm;
      FilteredListbox:=CBSelect;
      Left:=Margin;
      Top:=LPrompt.Top + LPrompt.Height + Sep + CBSelect.Height + Sep;
      Width:=Frm.ClientWidth-2*Margin;
    end;

    BP:=TButtonPanel.Create(Frm);
    with BP do begin
      Parent:=Frm;
      ShowButtons:=[pbOK,pbCancel];
      ShowGlyphs:=[];
      OKButton.Caption:='&确认';
      CancelButton.Caption:='&取消';
    end;

    Frm.ClientHeight:=LPrompt.Height+CBSelect.Height+CBSelectFilter.Height+BP.Height+3*Sep+Margin;

    if (Frm.ShowModal=mrOk) then begin
      ASelected:=CBSelect.ItemIndex;
      if ASelected>=0 then Result:=CBSelect.Items[ASelected];
    end;

  finally
    FreeAndNil(Frm);
  end;
end;

function ShowMsgList(const ACaption,APrompt:string;const AList:TStrings):String;
var codee:integer;
begin
  result:=ShowMsgList(ACaption,APrompt,AList,codee);
end;


function ShowMsgCheckList(ACaption,APrompt:string;AList:TStrings;out SelList:TStrings;AllSelected:boolean=false):String;
var
  W,I,Sep,Margin:Integer;
  Frm:TForm;
  CBSelect:TCheckListBox;
  LPrompt:TLabel;
  BP:TButtonPanel;
begin
  Margin:=24;
  Sep:=8;
  Result:='';
  Frm:=TForm.Create(FormDesktop);
  try

    W:=Max(frm.Canvas.TextWidth(APrompt),frm.Canvas.TextWidth(ACaption));
    W:=Max(W,360);
    W:=Min(W,540);
    for I:=0 to AList.Count-1 do W:=Max(W,frm.Canvas.TextWidth(AList[i]+'WWW'));//WWW占位符

    with frm do begin
      BorderStyle:=bsDialog;
      Caption:=ACaption;
      ClientWidth:=W+2*Margin;
      Position:=poOwnerFormCenter;
      KeyPreview:=true;
    end;

    LPrompt:=TLabel.Create(frm);
    with LPrompt do begin
      Parent:=frm;
      Caption:=APrompt;
      SetBounds(Margin,Margin,Frm.ClientWidth-2*Margin,frm.Canvas.TextHeight(APrompt));
      WordWrap:=True;
      AutoSize:=False;
    end;

    CBSelect:=TCheckListBox.Create(Frm);
    with CBSelect do begin
      Parent:=Frm;
      Items.Assign(AList);
      Left:=Margin;
      Top:=LPrompt.Top + LPrompt.Height + Sep;
      Width:=Frm.ClientWidth-2*Margin;
      Height:=120;
      if AllSelected then SelectAll;
    end;

    BP:=TButtonPanel.Create(Frm);
    with BP do begin
      Parent:=Frm;
      ShowButtons:=[pbOK,pbCancel];
      ShowGlyphs:=[];
      OKButton.Caption:='&确认';
      CancelButton.Caption:='&取消';
    end;

    Frm.ClientHeight:=LPrompt.Height+CBSelect.Height+BP.Height+3*Sep+Margin;

    if (Frm.ShowModal=mrOk) then begin
      for I:=0 to CBSelect.Count-1 do if CBSelect.Checked[I] then SelList.Add(CBSelect.Items[I]);
    end;

  finally
    FreeAndNil(Frm);
  end;
end;


function ShowMsgEdit(const ACaption,APrompt,DefaultStr:string):String;
var
  W,Sep,Margin: Integer;
  Frm: TForm;
  CBEdit : TEdit;
  LPrompt: TLabel;
  BP: TButtonPanel;
begin
  Margin:=24;
  Sep:=8;
  Result:='';
  Frm:=TForm.Create(FormDesktop);
  try

    W:=Max(frm.Canvas.TextWidth(APrompt),frm.Canvas.TextWidth(ACaption));
    W:=Min(W,540);
    W:=Max(W,360);

    with frm do begin
      BorderStyle:=bsDialog;
      Caption:=ACaption;
      ClientWidth:=W+2*Margin;
      Position:=poOwnerFormCenter;
      KeyPreview:=true;
    end;

    LPrompt:=TLabel.Create(frm);
    with LPrompt do begin
      Parent:=frm;
      Caption:=APrompt;
      SetBounds(Margin,Margin,Frm.ClientWidth-2*Margin,frm.Canvas.TextHeight(APrompt));
      WordWrap:=True;
      AutoSize:=False;
    end;

    CBEdit:=TEdit.Create(Frm);
    with CBEdit do begin
      Parent:=Frm;
      Left:=Margin;
      Top:=LPrompt.Top + LPrompt.Height + Sep;
      Width:=Frm.ClientWidth-2*Margin;
      Caption:=DefaultStr;
    end;

    BP:=TButtonPanel.Create(Frm);
    with BP do begin
      Parent:=Frm;
      ShowButtons:=[pbOK,pbCancel];
      ShowGlyphs:=[];
      OKButton.Caption:='&确认';
      CancelButton.Caption:='&取消';
    end;

    Frm.ClientHeight:=LPrompt.Height+CBEdit.Height+BP.Height+3*Sep+Margin;

    if (Frm.ShowModal=mrOk) then begin
      Result:=CBEdit.Caption;
    end;

  finally
    FreeAndNil(Frm);
  end;
end;

function ShowMsgImage(const ACaption:string;const ABitmap:TBitmap;ShowPixelInfo:boolean=false):string;
var
  W,H,Sep,Margin,ScrollWidth:Integer;
  Frm:TForm;
  Scroll:TScrollBox;
  Image:TImage;
begin
  if ABitmap.Width*ABitmap.Height=0 then exit;
  Margin:=24;
  Sep:=8;
  ScrollWidth:=5;//避免触发ScrollBar
  Result:='';
  Frm:=TForm.Create(FormDesktop);
  try
    //确保最大窗体不会超过屏幕
    if (Screen.Width/Screen.Height)>=(ABitmap.Width/ABitmap.Height) then begin
      H:=Min(ABitmap.Height,Screen.Height-180);
      W:=ABitmap.Width*H div ABitmap.Height;
    end else begin
      W:=Min(ABitmap.Width,Screen.Width-180);
      H:=ABitmap.Height*W div ABitmap.Width;
    end;

    with frm do begin
      BorderStyle:=bsSizeable;
      if ShowPixelInfo then
        Caption:=ACaption+' ('+IntToStr(ABitmap.Width)+'x'+IntToStr(ABitmap.Height)+')'
      else
        Caption:=ACaption;
      ClientWidth:=W+2*Margin+ScrollWidth;
      ClientHeight:=H+2*Margin+ScrollWidth;
      Position:=poScreenCenter;
      KeyPreview:=true;
    end;

    //Scroll:=TScrollBox.Create(Frm);
    Scroll:=TScrollImage.Create(Frm,ABitmap);
    with Scroll do begin
      Parent:=Frm;
      Anchors:=[akTop,akLeft,akRight,akBottom];
      with BorderSpacing do begin
        Top:=Margin;
        Left:=Margin;
        Right:=Margin;
        Bottom:=Margin;
      end;
      AnchorSideTop.Control:=Frm;
      AnchorSideTop.Side:=asrTop;
      AnchorSideLeft.Control:=Frm;
      AnchorSideLeft.Side:=asrLeft;
      AnchorSideRight.Control:=Frm;
      AnchorSideRight.Side:=asrRight;
      AnchorSideBottom.Control:=Frm;
      AnchorSideBottom.Side:=asrBottom;
    end;
    {
    Image:=TImage.Create(Scroll);
    with Image do begin
      Parent:=Scroll;
      Align:=alClient;
      Proportional:=true;
      Picture.Bitmap:=ABitmap;
      OnMouseDown:=nil;
      OnMouseUp:=nil;
    end;
    }
    Frm.ShowModal;
    result:='';


  finally
    FreeAndNil(Frm);
  end;
end;

function ShowMsgYesNoCancel(const ACaption,APrompt:string):String;
begin
  case MessageDlg(ACaption,APrompt,mtCustom,[mbYes,mbNo,mbCancel],0) of
    mrYes:result:='Yes';
    mrNo:result:='No';
    mrCancel:result:='Cancel';
    else result:='Error';
  end;
end;

function ShowMsgYesNoAll(const ACaption,APrompt:string;UseAllState:boolean=false):String;
var buttons:TMsgDlgButtons;
    msg_line:string;
begin
  buttons:=[mbYes,mbNo];
  if UseAllState and AllState.FEnabled then
    begin
      if AllState.FConfirmed then
        begin
          result:=AllState.DefaultButton;
          exit;
        end
      else
        begin
          if AllState.DefaultButton<>'' then buttons:=buttons+[mbAll];
          case AllState.DefaultButton of
            'Yes':msg_line:=APrompt+#13#10+'(全部：是)';
            'No':msg_line:=APrompt+#13#10+'(全部：否)';
            else msg_line:=APrompt;
          end;
        end;
      case MessageDlg(ACaption,msg_line,mtCustom,buttons,0) of
        mrYes:
          begin
            result:='Yes';
            AllState.SetButton('Yes');
          end;
        mrNo:
          begin
            result:='No';
            AllState.SetButton('No');
          end;
        mrAll:
          begin
            result:=AllState.DefaultButton;
            AllState.ApplyAll;
          end;
      end;
    end
  else
    case MessageDlg(ACaption,APrompt,mtCustom,buttons,0) of
      mrYes:result:='Yes';
      mrNo:result:='No';
    end;
end;

function ShowMsgRetryIgnore(const ACaption,APrompt:string;UseCancel:boolean=false):String;
var buttons:TMsgDlgButtons;
begin
  buttons:=[mbRetry,mbIgnore];
  if UseCancel then buttons:=buttons+[mbCancel];
  case MessageDlg(ACaption,APrompt,mtCustom,buttons,0) of
    mrCancel:result:='Cancel';
    mrRetry:result:='Retry';
    mrIgnore:result:='Ignore';
    else result:='Error';
  end;
end;

function ShowMsgOK(const ACaption,APrompt:string):String;
begin
  MessageDlg(ACaption,APrompt,mtCustom,[mbOK],0);
  result:='OK';
end;

function ShowMsgOKAll(const ACaption,APrompt:string):String;
begin
  if not ConfirmState.FEnabled then
    ShowMsgOK(ACaption,APrompt)
  else begin
    if not ConfirmState.FConfirmed then begin
      case MessageDlg(ACaption,APrompt,mtCustom,[mbOK,mbAll],0) of
        mrOK:ConfirmState.SetButton('OK');
        mrAll:ConfirmState.ApplyAll;
      end;
    end;
  end;
  result:='OK';
end;

{ ScrollImage }

procedure TScrollImage.ScrollPaint(Sender:TObject);
begin
  if not FDrag then exit;
  FImage.Repaint;
  with FImage.Canvas do begin
    Pen.Width:=2;
    Pen.Color:=clRed;
    Line(FFirstPoint.X,FFirstPoint.Y,FTargetPoint.X,FTargetPoint.Y);
  end;
end;

procedure TScrollImage.ApplyMovement(X,Y:Integer);
var tmp_x,tmp_y:integer;
begin
  tmp_x:=FFirstPosition.X+FFirstPoint.X-X;
  tmp_y:=FFirstPosition.Y+FFirstPoint.Y-Y;
  HorzScrollBar.Position:=tmp_x;
  VertScrollBar.Position:=tmp_y;
end;

procedure TScrollImage.ScrollMouseDown(Sender:TObject;Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
begin
  FDrag:=true;
  FFirstPoint.X:=X;
  FFirstPoint.Y:=Y;
  FFirstPosition.X:=HorzScrollBar.Position;
  FFirstPosition.Y:=VertScrollBar.Position;
end;

procedure TScrollImage.ScrollMouseMove(Sender:TObject;Shift:TShiftState;X,Y:Integer);
begin
  if not FDrag then exit;
  FTargetPoint.X:=X;
  FTargetPoint.Y:=Y;
  ApplyMovement(X,Y);
end;

procedure TScrollImage.ScrollMouseUp(Sender:TObject;Button:TMouseButton;Shift:TShiftState;X,Y:Integer);
var tmp_x,tmp_y:integer;
begin
  FDrag:=false;
  ApplyMovement(X,Y);
end;

constructor TScrollImage.Create(AOwner:TComponent;ABitmap:TBitmap);
begin
  inherited Create(AOwner);
  FImage:=TImage.Create(Self);
  FImage.Parent:=Self;
  FImage.Picture.Bitmap:=ABitmap;
  FImage.Width:=ABitmap.Width;
  FImage.Height:=ABitmap.Height;
  FImage.OnMouseDown:=@ScrollMouseDown;
  FImage.OnMouseUp:=@ScrollMouseUp;
  FImage.OnMouseMove:=@ScrollMouseMove;
  //FImage.OnPaint:=@ScrollPaint;
  FDrag:=false;
end;

destructor TScrollImage.Destroy;
begin
  inherited Destroy;
end;

initialization
  AllState:=TAllState.Create;
  ConfirmState:=TAllState.Create;


finalization
  AllState.Free;
  ConfirmState.Free;



end.

