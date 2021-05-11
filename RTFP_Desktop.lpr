program RTFP_Desktop;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, {pack_powerpdf, }RTFP_main,{ dbflaz, memdslaz,}
  form_new_project, form_cite_trans, form_import, lazcontrols;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TFormDesktop, FormDesktop);
  Application.CreateForm(TForm_NewProject, Form_NewProject);
  Application.CreateForm(TForm_CiteTrans, Form_CiteTrans);
  Application.CreateForm(TForm_ImportFiles, Form_ImportFiles);
  Application.Run;
end.

