//
//  这个单元存放一些杂项的小类
//
//


unit rtfp_misc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, rtfp_constants;

type
  MsgDlgAllOption = class
    FHasFirstChoice:boolean;
    FChoice:byte;
  public
    procedure Enable;
    procedure Choose(AKey:byte);
    procedure Disable;
    function Confirmed:boolean;
    property ChoiceButton:byte read FChoice;
  end;
  //此类计划用于在MessageDlg选项中追加一个All选项，根据第一个选项替代后续的选择

  //case MessageDlg() of
  //  rnmbXX:;
  //end;
  //
  //if FAllOpts.Confirmed then button:=FAllOpts.ChoiceButton
  //else button:=MessageDlg();
  //case button of
  //  rnmbXX:;
  //end;


implementation

procedure MsgDlgAllOption.Enable;
begin

end;
procedure MsgDlgAllOption.Choose(AKey:byte);
begin

end;
procedure MsgDlgAllOption.Disable;
begin

end;
function MsgDlgAllOption.Confirmed:boolean;
begin

end;

end.

