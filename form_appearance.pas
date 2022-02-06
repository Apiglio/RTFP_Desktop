unit form_appearance;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ColorBox,
  ComCtrls;

type

  { TAppearanceForm }

  TAppearanceForm = class(TForm)
    ColorBox: TColorBox;
    TrackBar: TTrackBar;
    procedure ColorBoxChange(Sender: TObject);
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
  Self.Hide;
end;

procedure TAppearanceForm.ColorBoxChange(Sender: TObject);
begin
  FormDesktop.Color:=(Sender as TColorBox).Selected;

  //FormDesktop.TabSheet_Filter_Field.Color:=(Sender as TColorBox).Selected;
  //FormDesktop.TabSheet_Filter_Klass.Color:=(Sender as TColorBox).Selected;

end;

end.

