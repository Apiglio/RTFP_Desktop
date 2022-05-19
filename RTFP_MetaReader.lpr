program RTFP_MetaReader;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lnetvisual, lazcontrols, tachartlazaruspkg,
  metareader_main, rtfp_pdfobj;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TForm_MetaReader, Form_MetaReader);
  Application.Run;
end.

