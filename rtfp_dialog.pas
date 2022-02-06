unit rtfp_dialog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math, Dialogs,
  // LCL
  LResources, LCLIntf, LCLType, LCLProc,
  Forms, Controls, Themes, GraphType, Graphics, Buttons, ButtonPanel, StdCtrls,
  ExtCtrls, ClipBrd, Menus, LCLTaskDialog,
  ListFilterEdit;

type
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
    destructor Destroy;
  end;


var
  AllState,ConfirmState:TAllState;


function ShowMsgCombo(const ACaption,APrompt:string;const AList:TStrings;
  AllowInput:Boolean;Out ASelected:Integer):string;
function ShowMsgCombo(const ACaption,APrompt:string;const AList:TStrings):string;
function ShowMsgList(const ACaption,APrompt:string;const AList:TStrings;
  Out ASelected:Integer):string;
function ShowMsgList(const ACaption,APrompt:string;const AList:TStrings):string;
function ShowMsgEdit(const ACaption,APrompt,DefaultStr:string):String;
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

function ShowMsgYesNoCancel(const ACaption,APrompt:string):String;
begin
  case MessageDlg(ACaption,APrompt,mtCustom,[mbYes,mbNo,mbCancel],0) of
    mrYes:result:='Yes';
    mrNo:result:='No';
    mrCancel:result:='Cancel';
    else result:='Error';
  end;
end;
{
var
  W,Sep,Margin: Integer;
  Frm: TForm;
  LPrompt: TLabel;
  BP: TButtonPanel;
begin
  Margin:=24;
  Sep:=8;
  Result:='';
  Frm:=TForm.Create(Application);
  try

    //W:=Max(frm.Canvas.TextWidth(APrompt),frm.Canvas.TextWidth(ACaption));
    //W:=Max(W,360);
    W:=360;

    with frm do begin
      BorderStyle:=bsDialog;
      Caption:=ACaption;
      ClientWidth:=W+2*Margin;
      Position:=poScreenCenter;
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
      ShowButtons:=[pbOK,pbCancel,pbClose];
      ShowGlyphs:=[];
      CloseButton.Caption:='&是';
      OKButton.Caption:='&否';
      CancelButton.Caption:='&取消';
    end;

    Frm.ClientHeight:=LPrompt.Height+BP.Height+3*Sep+Margin;

    case Frm.ShowModal of
      mrClose:Result:='Yes';
      mrOK:Result:='No';
      mrCancel:Result:='Cancel';
    end;

  finally
    FreeAndNil(Frm);
  end;
end;
}

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
{
var
  W,Sep,Margin: Integer;
  Frm: TForm;
  LPrompt: TLabel;
  BP: TButtonPanel;
  function con(condition:boolean;if_true,if_false:string):string;
  begin
    if condition then result:=if_true
    else result:=if_false;
  end;
begin
  Margin:=24;
  Sep:=8;
  Result:='';
  Frm:=TForm.Create(Application);
  try

    //W:=Max(frm.Canvas.TextWidth(APrompt),frm.Canvas.TextWidth(ACaption));
    //W:=Max(W,360);
    W:=360;

    with frm do begin
      BorderStyle:=bsDialog;
      Caption:=ACaption;
      ClientWidth:=W+2*Margin;
      Position:=poScreenCenter;
      KeyPreview:=true;
    end;

    LPrompt:=TLabel.Create(frm);
    with LPrompt do begin
      Parent:=frm;
      Caption:=APrompt;
      //SetBounds(Margin,Margin,Frm.ClientWidth-2*Margin,frm.Canvas.TextHeight(APrompt));
      WordWrap:=True;
      AutoSize:=True;
      Anchors:=[akTop,akLeft,akRight];
      AnchorSideTop.Control:=frm;
      AnchorSideTop.Side:=asrTop;
      AnchorSideLeft.Control:=frm;
      AnchorSideLeft.Side:=asrLeft;
      AnchorSideRight.Control:=frm;
      AnchorSideRight.Side:=asrRight;
      BorderSpacing.Top:=Margin;
      BorderSpacing.Left:=Margin;
      BorderSpacing.Right:=Margin;
      Height:=frm.Canvas.TextFitInfo(APrompt,W);
    end;

    BP:=TButtonPanel.Create(Frm);
    with BP do begin
      Parent:=Frm;
      ShowButtons:=[pbOK,pbCancel];
      if UseAllState then ShowButtons:=ShowButtons+[pbClose];
      ShowGlyphs:=[];
      CloseButton.Caption:='&全部';
      if AllState.FEnabled then
        begin
          CloseButton.Enabled:=true;
          case AllState.FDefaultButton of
            'Yes':CloseButton.Caption:='&全部(是)';
            'No':CloseButton.Caption:='&全部(否)';
          end;
        end
      else CloseButton.Enabled:=false;
      OKButton.Caption:='&是';
      CancelButton.Caption:='&否';
    end;

    Frm.ClientHeight:=LPrompt.Height+BP.Height+3*Sep+2*Margin;

    case Frm.ShowModal of
      mrClose:
        begin
          AllState.ApplyAll;
          result:=con(AllState.FDefaultButton='Yes','Yes','No');
        end;
      mrOK:
        begin
          AllState.SetButton('Yes');
          Result:='Yes';
        end;
      mrCancel:
        begin
          AllState.SetButton('No');
          Result:='No';
        end;
    end;

  finally
    FreeAndNil(Frm);
  end;
end;
}




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
{
var
  W,Sep,Margin: Integer;
  Frm: TForm;
  LPrompt: TLabel;
  BP: TButtonPanel;
begin
  Margin:=24;
  Sep:=8;
  Result:='';
  Frm:=TForm.Create(Application);
  try

    //W:=Max(frm.Canvas.TextWidth(APrompt),frm.Canvas.TextWidth(ACaption));
    //W:=Max(W,360);
    W:=360;

    with frm do begin
      BorderStyle:=bsDialog;
      Caption:=ACaption;
      ClientWidth:=W+2*Margin;
      Position:=poScreenCenter;
      KeyPreview:=true;
    end;

    LPrompt:=TLabel.Create(frm);
    with LPrompt do begin
      Parent:=frm;
      Caption:=APrompt;
      //SetBounds(Margin,Margin,Frm.ClientWidth-2*Margin,frm.Canvas.TextHeight(APrompt));
      WordWrap:=True;
      AutoSize:=False;
      Anchors:=[akTop,akLeft,akRight];
      AnchorSideTop.Control:=frm;
      AnchorSideTop.Side:=asrTop;
      AnchorSideLeft.Control:=frm;
      AnchorSideLeft.Side:=asrLeft;
      AnchorSideRight.Control:=frm;
      AnchorSideRight.Side:=asrRight;
      BorderSpacing.Top:=Margin;
      BorderSpacing.Left:=Margin;
      BorderSpacing.Right:=Margin;
      Height:=frm.Canvas.TextFitInfo(APrompt,W);
    end;

    BP:=TButtonPanel.Create(Frm);
    with BP do begin
      Parent:=Frm;
      ShowButtons:=[pbOK,pbClose];
      if UseCancel then ShowButtons:=ShowButtons+[pbCancel];
      ShowGlyphs:=[];
      CloseButton.Caption:='&重试';
      OKButton.Caption:='&忽略';
      CancelButton.Caption:='&取消';
    end;

    Frm.ClientHeight:=LPrompt.Height+BP.Height+3*Sep+2*Margin;

    case Frm.ShowModal of
      mrClose:Result:='Retry';
      mrOK:Result:='Ignore';
      mrCancel:Result:='Cancel';
    end;

  finally
    FreeAndNil(Frm);
  end;
end;
}

function ShowMsgOK(const ACaption,APrompt:string):String;
begin
  MessageDlg(ACaption,APrompt,mtCustom,[mbOK],0);
  result:='OK';
end;

{
var
  W,Sep,Margin:Integer;
  FH,NH,NW:integer;
  Frm: TForm;
  LPrompt: TLabel;
  BP: TButtonPanel;
  function charcount(ch:char;str:string):integer;
  var p:integer;
  begin
    result:=0;
    for p:=1 to length(str) do if str[p]=ch then inc(result);
  end;

begin
  Margin:=24;
  Sep:=8;
  Result:='';
  Frm:=TForm.Create(Application);
  try

    //W:=Max(frm.Canvas.TextWidth(APrompt),frm.Canvas.TextWidth(ACaption));
    //W:=Max(W,360);
    W:=360;

    with frm do begin
      BorderStyle:=bsDialog;
      Caption:=ACaption;
      ClientWidth:=W+2*Margin;
      Position:=poScreenCenter;
      KeyPreview:=true;
    end;

    LPrompt:=TLabel.Create(frm);
    with LPrompt do begin
      Parent:=frm;
      AutoSize:=true;
      Caption:=APrompt;
      SetBounds(Margin,Margin,Frm.ClientWidth-2*Margin,charcount(#10,APrompt)*frm.Canvas.TextHeight('WjqlpygfI'));
      WordWrap:=false;
    end;


    BP:=TButtonPanel.Create(Frm);
    with BP do begin
      Parent:=Frm;
      ShowButtons:=[pbOK];
      ShowGlyphs:=[];
      OKButton.Caption:='&确认';
    end;

    Frm.ClientHeight:=LPrompt.Height+BP.Height+3*Sep+Margin;
    //Frm.ClientWidth:=Max(W,LPrompt.Width)+2*Sep;
    Frm.ShowModal;

  finally
    FreeAndNil(Frm);
  end;
end;
}

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

initialization
  AllState:=TAllState.Create;
  ConfirmState:=TAllState.Create;


finalization
  AllState.Free;
  ConfirmState.Free;



end.

