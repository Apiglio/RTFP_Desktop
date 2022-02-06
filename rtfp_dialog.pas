unit rtfp_dialog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, math,
  // LCL
  LResources, LCLIntf, LCLType, LCLProc,
  Forms, Controls, Themes, GraphType, Graphics, Buttons, ButtonPanel, StdCtrls,
  ExtCtrls, ClipBrd, Menus, LCLTaskDialog,
  ListFilterEdit;

function ShowMsgCombo(const ACaption,APrompt:string;const AList:TStrings;
  AllowInput:Boolean;Out ASelected:Integer):string;
function ShowMsgCombo(const ACaption,APrompt:string;const AList:TStrings):string;
function ShowMsgList(const ACaption,APrompt:string;const AList:TStrings;
  Out ASelected:Integer):string;
function ShowMsgList(const ACaption,APrompt:string;const AList:TStrings):string;

//继续制作以下几类全部替代之前的MessageDlg和InputBox：
//ShowMsgEdit:string;
//ShowMsgYesNo:boolean;
//ShowMsgRetry:boolean;
//ShowMsgOK;


implementation


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
  Frm:=TForm.Create(Application);
  try

    W:=Max(frm.Canvas.TextWidth(APrompt),frm.Canvas.TextWidth(ACaption));
    W:=Max(W,360);
    for I:=0 to AList.Count-1 do W:=Max(W,frm.Canvas.TextWidth(AList[i]+'WWW'));//WWW占位符

    with frm do begin
      BorderStyle:=bsDialog;
      Caption:=ACaption;
      ClientWidth:=W+2*Margin;
      Position:=poScreenCenter;
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
  Frm:=TForm.Create(Application);
  try

    W:=Max(frm.Canvas.TextWidth(APrompt),frm.Canvas.TextWidth(ACaption));
    W:=Max(W,360);
    for I:=0 to AList.Count-1 do W:=Max(W,frm.Canvas.TextWidth(AList[i]+'WWW'));//WWW占位符

    with frm do begin
      BorderStyle:=bsDialog;
      Caption:=ACaption;
      ClientWidth:=W+2*Margin;
      Position:=poScreenCenter;
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
  ShowMsgList(ACaption,APrompt,AList,codee);
end;


end.

