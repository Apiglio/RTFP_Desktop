unit rtfp_dataset;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db;

type

  TRTFP_Dataset = class(TDataSet)
  private
    FRTFP_Project: TObject;
  public
    //too difficult
  public
    constructor Create(AOwner: TComponent; ARTFPProject:TObject);
    destructor Destroy; override;
  end;

implementation
uses RTFP_definition;

{ TRTFP_Dataset }

constructor TRTFP_Dataset.Create(AOwner: TComponent; ARTFPProject:TObject);
begin
  inherited Create(AOwner);
  FRTFP_Project:=ARTFPProject;
end;

destructor TRTFP_Dataset.Destroy;
begin
  inherited Destroy;
end;

end.

