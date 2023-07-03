program RTFP_Desktop;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, RTFP_main, Apiglio_Useful, auf_ram_image, aufscript_frame,{ dbflaz, memdslaz,}
  form_new_project, form_cite_trans, form_import, lazcontrols,
  tachartlazaruspkg, form_classmanager, form_appearance, form_options,
  form_report_tool, form_repeated_checker, form_project_profile,
  form_field_display_option, form_formatedit_option, source_dialog, sync_timer,
  rtfp_type, rtfp_dataset_sorter, form_field_change, form_calc_field;

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
  Application.CreateForm(TFormFormatEditOption, FormFormatEditOption);
  Application.CreateForm(TForm_FileSource, Form_FileSource);
  Application.CreateForm(TForm_FieldChange, Form_FieldChange);
  Application.CreateForm(TForm_CalcField, Form_CalcField);
  Application.Run;
end.

