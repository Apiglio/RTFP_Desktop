unit form_formatedit_option;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TFormFormatEditOption }

  TFormFormatEditOption = class(TForm)
    Button_OK: TButton;
    CheckBox_CustomLayout: TCheckBox;
    ComboBox_Type: TComboBox;
    ComboBox_L: TComboBox;
    ComboBox_R: TComboBox;
    ComboBox_Attrs: TComboBox;
    ComboBox_Field: TComboBox;
    ComboBox_RW: TComboBox;
    Edit_Top: TEdit;
    Edit_Bottom: TEdit;
    Edit_DisplayName: TEdit;
    GroupBox_Position: TGroupBox;
    Label_Type: TLabel;
    Label_Top: TLabel;
    Label_Bottom: TLabel;
    Label_L: TLabel;
    Label_R: TLabel;
    Label_DisplayName: TLabel;
    Label_Attrs: TLabel;
    Label_Field: TLabel;
    Label_RW: TLabel;
    procedure CheckBox_CustomLayoutClick(Sender: TObject);
    procedure ComboBox_AttrsSelect(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    ProjectObj:TObject;
    dt,db:integer;
    dl,dr:integer;

  protected
    function GetSyntax:string;
    function GetDisplayName:string;
    function GetAttrsName:string;
    function GetFieldName:string;
    function GetCpmType:string;
    function GetRW_Mode:string;


  private
    procedure DefaultPosition;

  public
    function Call(Sender:TObject;t,b,l,r:integer):Integer;
    property Syntax:string read GetSyntax;
    property DisplayName:string read GetDisplayName;
    property AttrsName:string read GetAttrsName;
    property FieldName:string read GetFieldName;
    property CpmType:string read GetCpmType;
    property RW_Mode:string read GetRW_Mode;


  end;

var
  FormFormatEditOption: TFormFormatEditOption;

implementation
uses RTFP_main, RTFP_definition, rtfp_field;

{$R *.lfm}

procedure TFormFormatEditOption.FormCreate(Sender: TObject);
begin
  ComboBox_L.AddItem('L',nil);
  ComboBox_L.AddItem('LM',nil);
  ComboBox_L.AddItem('ML',nil);
  ComboBox_L.AddItem('M',nil);
  ComboBox_L.AddItem('MR',nil);
  ComboBox_L.AddItem('RM',nil);
  ComboBox_L.AddItem('R',nil);

  ComboBox_R.AddItem('L',nil);
  ComboBox_R.AddItem('LM',nil);
  ComboBox_R.AddItem('ML',nil);
  ComboBox_R.AddItem('M',nil);
  ComboBox_R.AddItem('MR',nil);
  ComboBox_R.AddItem('RM',nil);
  ComboBox_R.AddItem('R',nil);

  ComboBox_RW.AddItem('读写',nil);
  ComboBox_RW.AddItem('只读',nil);

  ComboBox_Type.AddItem('单行文本 Edit',nil);
  ComboBox_Type.AddItem('多行文本 Memo',nil);
  ComboBox_Type.AddItem('是非选项 Check',nil);
  //ComboBox_Type.AddItem('多项选项 Combo',nil);
  ComboBox_Type.AddItem('图像字段 Image',nil);


end;

function TFormFormatEditOption.GetSyntax:string;
begin
  result:='';
  if ComboBox_Type.ItemIndex<0 then exit;
  if ComboBox_Attrs.ItemIndex<0 then exit;
  if ComboBox_Field.ItemIndex<0 then exit;

  result:=ComboBox_Type.SelText;
  delete(result,1,pos(' ',result));

  result:=result+' "'+TAttrsGroup(ComboBox_Attrs.Items.Objects[ComboBox_Attrs.ItemIndex]).Name+'"';
  result:=result+',"'+TAttrsField(ComboBox_Field.Items.Objects[ComboBox_Field.ItemIndex]).FieldName+'"';
  result:=result+',"'+Edit_DisplayName.Caption+'"';

  result:=result+','+Edit_Top.Caption;
  result:=result+','+Edit_Bottom.Caption;
  result:=result+',"'+ComboBox_L.Items[ComboBox_L.ItemIndex]+'"';
  result:=result+',"'+ComboBox_R.Items[ComboBox_R.ItemIndex]+'"';

  case ComboBox_RW.SelText of
    //'读写':result:=result+',"editable"';
    '只读':result:=result+',"uneditable"';
    else result:=result+',"editable"';
  end;

end;

function TFormFormatEditOption.GetDisplayName:string;
begin
  result:=Edit_DisplayName.Caption;
end;
function TFormFormatEditOption.GetAttrsName:string;
begin
  if ComboBox_Attrs.ItemIndex<0 then result:=''
  else result:=ComboBox_Attrs.Items[ComboBox_Attrs.ItemIndex];
end;
function TFormFormatEditOption.GetFieldName:string;
begin
  if ComboBox_Field.ItemIndex<0 then result:=''
  else result:=ComboBox_Field.Items[ComboBox_Field.ItemIndex];
end;
function TFormFormatEditOption.GetCpmType:string;
var stmp:string;
begin
  if ComboBox_Type.ItemIndex<0 then
    begin
      result:='';
      exit;
    end;
  stmp:=ComboBox_Type.Items[ComboBox_Type.ItemIndex];
  delete(stmp,1,pos(' ',stmp));
  case stmp of
    'Edit':result:='Et';
    'Memo':result:='Me';
    'Check':result:='Ck';
    'Combo':result:='Cb';
    'Image':result:='Im';
    else result:='Un';
  end;
end;
function TFormFormatEditOption.GetRW_Mode:string;
begin
  if ComboBox_RW.ItemIndex<0 then result:='editable'
  else case ComboBox_RW.Items[ComboBox_RW.ItemIndex] of
    '只读':result:='uneditable';
    else result:='editable';
  end;
end;

procedure TFormFormatEditOption.DefaultPosition;
{
  function SyntaxToIndex(syn:string):integer;
  begin
    case lowercase(syn) of
      'l':result:=0;
      'lm':result:=1;
      'ml':result:=2;
      'm':result:=3;
      'mr':result:=4;
      'rm':result:=5;
      'r':result:=6;
    end;
  end;
}
begin
  Edit_Top.Caption:=IntToStr(dt);
  Edit_Bottom.Caption:=IntToStr(db);
  ComboBox_L.ItemIndex:=(dl);
  ComboBox_R.ItemIndex:=(dr);
end;

procedure TFormFormatEditOption.CheckBox_CustomLayoutClick(Sender: TObject);
begin
  if (Sender as TCheckBox).Checked then begin
    Edit_Top.Enabled:=true;
    Edit_Bottom.Enabled:=true;
    ComboBox_L.Enabled:=true;
    ComboBox_R.Enabled:=true;
  end else begin
    DefaultPosition;
    Edit_Top.Enabled:=false;
    Edit_Bottom.Enabled:=false;
    ComboBox_L.Enabled:=false;
    ComboBox_R.Enabled:=false;
  end;
end;

procedure TFormFormatEditOption.ComboBox_AttrsSelect(Sender: TObject);
var tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
begin
  if ComboBox_Attrs.ItemIndex<0 then exit;
  tmpAG:=TAttrsGroup(ComboBox_Attrs.Items.Objects[ComboBox_Attrs.ItemIndex]);
  ComboBox_Field.Clear;
  for tmpAF in tmpAG.FieldList do ComboBox_Field.AddItem(tmpAF.FieldName,tmpAF);
end;


function TFormFormatEditOption.Call(Sender:TObject;t,b,l,r:integer):Integer;
var tmpAG:TAttrsGroup;
begin
  ProjectObj:=Sender;
  dt:=t;
  db:=b;
  dl:=l;
  dr:=r;
  CheckBox_CustomLayout.Checked:=false;
  Edit_Top.Enabled:=false;
  Edit_Bottom.Enabled:=false;
  ComboBox_L.Enabled:=false;
  ComboBox_R.Enabled:=false;
  DefaultPosition;
  ComboBox_RW.ItemIndex:=0;
  ComboBox_Attrs.Clear;
  ComboBox_Field.Clear;
  with ProjectObj as TRTFP do
    for tmpAG in FieldList do ComboBox_Attrs.AddItem(tmpAG.Name,tmpAG);

  result:=ShowModal;
end;

end.

