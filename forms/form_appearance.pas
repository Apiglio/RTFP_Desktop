unit form_appearance;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ColorBox,
  ComCtrls, ButtonPanel, ExtCtrls, StdCtrls,
  Clipbrd, LCLIntf, LCLType;

type

  { TAppearanceForm }

  TAppearanceForm = class(TForm)
    ColorBox: TColorBox;
    Label_Appearance_alpha: TLabel;
    Label_Appearance_color: TLabel;
    ScrollBox_Appearance: TScrollBox;
    TrackBar: TTrackBar;
    procedure ColorBoxChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure TrackBarChange(Sender: TObject);
  private

  public

  end;

var
  AppearanceForm: TAppearanceForm;

implementation
uses RTFP_main;

{$R *.lfm}

{ TAppearanceForm }

procedure TAppearanceForm.TrackBarChange(Sender: TObject);
begin
  FormDesktop.AlphaBlend:=true;
  FormDesktop.AlphaBlendValue:=(Sender as TTrackBar).Position;
end;

procedure TAppearanceForm.FormDeactivate(Sender: TObject);
begin
  //Self.Hide;
end;

procedure TAppearanceForm.ColorBoxChange(Sender: TObject);
var selc:TColor;
begin
  selc:=(Sender as TColorBox).Selected;
  FormDesktop.Color:=selc;
  FormDesktop.TabSheet_Node_PDF.Color:=selc;
  FormDesktop.PageControl_Node.Color:=selc;

  //FormDesktop.TabSheet_Filter_Field.Color:=(Sender as TColorBox).Selected;
  //FormDesktop.TabSheet_Filter_Klass.Color:=(Sender as TColorBox).Selected;

end;

procedure TAppearanceForm.FormCreate(Sender: TObject);
begin
  if Self.Height>Screen.Height then Self.Height:=trunc(Screen.Height*0.8);
  if Self.Width>Screen.Width then Self.Height:=trunc(Screen.Width*0.8);
end;

end.

