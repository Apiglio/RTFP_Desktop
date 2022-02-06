program RTFP_Desktop;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lnetvisual, {pack_powerpdf, }RTFP_main,{ dbflaz, memdslaz,}
  form_new_project, form_cite_trans, form_import, lazcontrols,
  tachartlazaruspkg, form_classmanager, form_appearance, form_options,
  form_report_tool, form_repeated_checker, form_project_profile, form_field_display_option;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TFormDesktop, FormDesktop);
  Application.CreateForm(TForm_NewProject, Form_NewProject);
  Application.CreateForm(TForm_CiteTrans, Form_CiteTrans);
  Application.CreateForm(TForm_ImportFiles, Form_ImportFiles);
  Application.CreateForm(TClassManagerForm, ClassManagerForm);
  Application.CreateForm(TAppearanceForm, AppearanceForm);
  Application.CreateForm(TFormOptions, FormOptions);
  Application.CreateForm(TFormReportTool, FormReportTool);
  Application.CreateForm(TFormRepeatedChecker, FormRepeatedChecker);
  Application.CreateForm(TFormProjectProfile, FormProjectProfile);
  Application.CreateForm(TFormFieldDisplayOption, FormFieldDisplayOption);
  Application.Run;
end.

