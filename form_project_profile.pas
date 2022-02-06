unit form_project_profile;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, TANavigation, Forms, Controls,
  Graphics, Dialogs;

type

  { TFormProjectProfile }

  TFormProjectProfile = class(TForm)
    Chart1BarSeries1: TBarSeries;
    Chart_YearStat: TChart;
    Chart_YearStatBarSeries: TBarSeries;
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  FormProjectProfile: TFormProjectProfile;

implementation
uses RTFP_main, rtfp_constants, rtfp_misc, RTFP_definition;

{$R *.lfm}

{ TFormProjectProfile }

procedure TFormProjectProfile.FormShow(Sender: TObject);
var PIDs:TStringList;
    PID:string;
    yrs,cnt,index:int64;
    StrHash:TStrHash;
begin
  Chart_YearStatBarSeries.Clear;
  PIDs:=TStringList.Create;
  StrHash:=TStrHash.Create;
  try
    CurrentRTFP.GetPIDList(PIDs);
    for PID in PIDs do
      begin
        yrs:=CurrentRTFP.ReadFieldAsInteger(_Col_basic_Year_,_Attrs_Basic_,PID,[]);
        if yrs>0 then StrHash.NamedItemAddCount(IntToStr(yrs));
      end;
    index:=0;
    while index<StrHash.Count do
      begin
        yrs:=StrToInt(TStrHashItem(StrHash.Items[index]).Name);
        cnt:=TStrHashItem(StrHash.Items[index]).Count;
        if cnt>0 then Chart_YearStatBarSeries.AddXY(yrs,cnt);
        inc(index);
      end;

  finally
    PIDs.Free;
    StrHash.Free;
  end;
end;

end.

