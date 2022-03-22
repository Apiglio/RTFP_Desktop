unit form_project_profile;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, TANavigation, SpinEx, Forms,
  Controls, Graphics, Dialogs, ComCtrls, StdCtrls;

type

  { TFormProjectProfile }

  TFormProjectProfile = class(TForm)
    Button_Redraw: TToggleBox;
    Chart1BarSeries1: TBarSeries;
    Chart_YearStat: TChart;
    Chart_YearStatBarSeries: TBarSeries;
    Label_Year1: TLabel;
    Label_Year2: TLabel;
    PageControl1: TPageControl;
    SpinEditEx_Year1: TSpinEditEx;
    SpinEditEx_Year2: TSpinEditEx;
    TabSheet_AnnualReport: TTabSheet;
    procedure Button_RedrawClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpinEditEx_Year1Change(Sender: TObject);
    procedure SpinEditEx_Year2Change(Sender: TObject);
  private

  public
    annual_report:record
      year_from,year_to:integer;
    end;
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
    yrs,ymax,ymin,cnt,index:int64;
    StrHash:TStrHash;
begin
  Chart_YearStatBarSeries.Clear;
  PIDs:=TStringList.Create;
  StrHash:=TStrHash.Create;
  try
    CurrentRTFP.GetPIDList(PIDs);
    ymin:=$7fffffffffffffff;
    ymax:=$8000000000000000;
    for PID in PIDs do
      begin
        yrs:=CurrentRTFP.ReadFieldAsInteger(_Col_basic_Year_,_Attrs_Basic_,PID,[]);
        if yrs>0 then
          begin
            StrHash.NamedItemAddCount(IntToStr(yrs));
            if yrs>ymax then ymax:=yrs;
            if yrs<ymin then ymin:=yrs;
          end;
      end;

    if CurrentRTFP.IsChanged or (SpinEditEx_Year1.Value<=0) or (SpinEditEx_Year2.Value<=0) then
      begin
        SpinEditEx_Year1.Caption:=FloatToStrF(ymin,ffFixed,0,0);
        SpinEditEx_Year2.Caption:=FloatToStrF(ymax,ffFixed,0,0);
      end
    else
      begin
        ymin:=round(SpinEditEx_Year1.Value);
        ymax:=round(SpinEditEx_Year2.Value);
      end;

    index:=0;
    while index<StrHash.Count do
      begin
        yrs:=StrToInt(TStrHashItem(StrHash.Items[index]).Name);
        cnt:=TStrHashItem(StrHash.Items[index]).Count;
        if (cnt>0) and (yrs>=ymin) and (yrs<=ymax) then Chart_YearStatBarSeries.AddXY(yrs,cnt);
        inc(index);
      end;
    Chart_YearStat.ZoomFull(false);
  finally
    PIDs.Free;
    StrHash.Free;
  end;
end;

procedure TFormProjectProfile.Button_RedrawClick(Sender: TObject);
begin
  with Sender as TToggleBox do
    begin
      FormShow(Self);
      Checked:=false;
    end;
end;

procedure TFormProjectProfile.SpinEditEx_Year1Change(Sender: TObject);
begin
  //FormShow(Self);
end;

procedure TFormProjectProfile.SpinEditEx_Year2Change(Sender: TObject);
begin
  //FormShow(Self);
end;

end.

