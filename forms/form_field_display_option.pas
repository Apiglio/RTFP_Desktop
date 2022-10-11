unit form_field_display_option;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ColorBox,
  StdCtrls, ExtCtrls, rtfp_field, db, Regexpr;

type

  { TFormFieldDisplayOption }

  TFormFieldDisplayOption = class(TForm)
    Button_OK: TButton;
    CheckBox_UseDisplayOption: TCheckBox;
    ColorBox_C1: TColorBox;
    ColorBox_C2: TColorBox;
    Edit_ConditionalSyntax: TEdit;
    Edit_V1: TEdit;
    Edit_V2: TEdit;
    Label_C1: TLabel;
    Label_C2: TLabel;
    Label_ConditionalSyntax: TLabel;
    Label_V1: TLabel;
    Label_V2: TLabel;
    Memo_Tip: TMemo;
    RadioGroup_ColorStyle: TRadioGroup;
    procedure Button_OKClick(Sender: TObject);
    procedure CheckBox_UseDisplayOptionChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RadioGroup_ColorStyleSelectionChanged(Sender: TObject);
  private
    CurrentField:TAttrsField;
  public
    function Call(AAttrsField:TAttrsField):Integer;
  end;

var
  FormFieldDisplayOption: TFormFieldDisplayOption;
  display_reg:TRegexpr;

implementation
uses rtfp_dialog, rtfp_misc;

{$R *.lfm}


function Successive_FDOP(v1,v2:double;c1,c2:TColor;expresion:string;Value:TField):TColor;
var fvalue:double;
begin
  if v1=v2 then begin result:=c1;exit;end;
  result:=clNone;
  case value.DataType of ftInteger,ftSmallint,ftLargeint,ftFloat:;else exit end;
  fvalue:=value.AsFloat;
  fvalue:=(fvalue-v1)/(v2-v1);
  result:=HSVLinearCombination(c1,c2,fvalue);
end;

function Binary_FDOP(v1,v2:double;c1,c2:TColor;expresion:string;Value:TField):TColor;
begin
  display_reg.Expression:=expresion;
  if display_reg.Exec(Value.AsString) then result:=c1 else result:=$ff000000;
end;

{ TFormFieldDisplayOption }

function TFormFieldDisplayOption.Call(AAttrsField:TAttrsField):Integer;
var index:integer;
begin
  if AAttrsField=nil then begin ShowMsgOK('字段显示设置','默认字段暂不支持单元格设色。');exit;end;//这句真的能达到触发条件吗
  CurrentField:=AAttrsField;
  Self.Caption:='字段显示设置'+' - '+AAttrsField.FieldName+'('+AAttrsField.AttrsGroup.Name+')';
  with AAttrsField.FieldDisplayOption do
    begin
      if colorize_process=nil then CheckBox_UseDisplayOption.Checked:=false
      else CheckBox_UseDisplayOption.Checked:=true;
      if CheckBox_UseDisplayOption.Checked then
        begin
          Edit_V1.Text:=FloatToStr(v1);
          Edit_V2.Text:=FloatToStr(v2);
          ColorBox_C1.ItemIndex:=-1;
          index:=0;
          while index<ColorBox_C1.Items.Count do
            begin
              if ColorBox_C1.Items.Objects[index]=TObject(qword(c1)) then
                ColorBox_C1.Selected:=ColorBox_C1.Colors[index];
                //ColorBox_C1.ItemIndex:=index;//两个ColorBox容量相同，否则遗漏或报错
              if ColorBox_C2.Items.Objects[index]=TObject(qword(c2)) then
                ColorBox_C2.Selected:=ColorBox_C2.Colors[index];
                //ColorBox_C2.ItemIndex:=index;//两个ColorBox容量相同，否则遗漏或报错
              inc(index);
            end;
          //ColorBox_C1.Color:=;

          Edit_ConditionalSyntax.Text:=expression;
        end;
    end;
  RadioGroup_ColorStyleSelectionChanged(RadioGroup_ColorStyle);
  result:=ShowModal;
end;

procedure TFormFieldDisplayOption.RadioGroup_ColorStyleSelectionChanged(
  Sender: TObject);
var RG:TRadioGroup;
begin
  RG:=Sender as TRadioGroup;
  Memo_Tip.Clear;
  if RG.ItemIndex<0 then
    begin
      Edit_V1.Enabled:=false;
      Edit_V2.Enabled:=false;
      Edit_ConditionalSyntax.Enabled:=false;
      ColorBox_C1.Enabled:=false;
      ColorBox_C2.Enabled:=false;
      exit;
    end
  else CheckBox_UseDisplayOption.Checked:=true;
  case RG.Items[RG.ItemIndex] of
    '连续色带':
      begin
        Memo_Tip.Lines.Add('对数值型字段有效，选择两个数值边界及对应的颜色，两值中间的数值去渐变色带上的相应颜色。');
        Edit_V1.Enabled:=true;
        Edit_V2.Enabled:=true;
        Edit_ConditionalSyntax.Enabled:=false;
        ColorBox_C1.Enabled:=true;
        ColorBox_C2.Enabled:=true;
      end;
    '二值显示':
      begin
        Memo_Tip.Lines.Add('对字符型字段有效，修改符合特定条件的单元格颜色。');
        Edit_V1.Enabled:=false;
        Edit_V2.Enabled:=false;
        Edit_ConditionalSyntax.Enabled:=true;
        ColorBox_C1.Enabled:=true;
        ColorBox_C2.Enabled:=false;
      end;
    '高区分度':
      begin
        Memo_Tip.Lines.Add('用于表现分组数据，目前暂不可使用。');
        Edit_V1.Enabled:=false;
        Edit_V2.Enabled:=false;
        Edit_ConditionalSyntax.Enabled:=false;
        ColorBox_C1.Enabled:=false;
        ColorBox_C2.Enabled:=false;
      end
    else ;
  end;
end;

procedure TFormFieldDisplayOption.Button_OKClick(Sender: TObject);
begin
  if not CheckBox_UseDisplayOption.Checked then begin
    ModalResult:=mrOK;
    exit;
  end;
  with CurrentField.FieldDisplayOption do begin
    case RadioGroup_ColorStyle.Items[RadioGroup_ColorStyle.ItemIndex] of
      '连续色带':
        begin
          colorize_process:=@Successive_FDOP;
        end;
      '二值显示':
        begin
          colorize_process:=@Binary_FDOP;
        end;
      '高区分度':
        begin
          ShowMsgOK('单元格着色','暂不支持“高区分度”颜色方案。');
          exit;
        end;
    end;
    c1:=ColorBox_C1.Selected;
    c2:=ColorBox_C2.Selected;
    if colorize_process=@Successive_FDOP then try
      v1:=StrToFloat(Edit_V1.Text);
      v2:=StrToFloat(Edit_V2.Text);
    except
      ShowMsgOK('单元格着色','“值1”或“值2”并非有效数值。');
      exit;
    end;
    expression:=Edit_ConditionalSyntax.Text;
  end;
  CurrentField:=nil;
  ModalResult:=mrOK;
end;

procedure TFormFieldDisplayOption.CheckBox_UseDisplayOptionChange(
  Sender: TObject);
begin
  if (Sender as TCheckBox).Checked then
    begin
      if CurrentField.FieldDisplayOption.colorize_process = @Binary_FDOP then
        RadioGroup_ColorStyle.ItemIndex:=1
      else
        RadioGroup_ColorStyle.ItemIndex:=0;
    end
  else
    begin
      RadioGroup_ColorStyle.ItemIndex:=-1;
      Memo_Tip.Lines.Add('');
      Edit_V1.Enabled:=false;
      Edit_V2.Enabled:=false;
      Edit_ConditionalSyntax.Enabled:=true;
      ColorBox_C1.Enabled:=true;
      ColorBox_C2.Enabled:=false;
    end;
  RadioGroup_ColorStyleSelectionChanged(RadioGroup_ColorStyle);
end;

procedure TFormFieldDisplayOption.FormCreate(Sender: TObject);
const pow_index=7;
var H:word;V:byte;
    n1,n2:string;
    color_dw:TColor;
    CB_List:TList;
    tmpCB:Pointer;
    function sqrt_n(base:ValReal):ValReal;begin result:=exp(ln(base)/pow_index);end;
    function pow_n(base:ValReal):ValReal;begin result:=exp(ln(base)*pow_index);end;

begin

  CB_List:=TList.Create;
  CB_List.Add(ColorBox_C1);
  CB_List.Add(ColorBox_C2);

  for tmpCB in CB_List do begin
    TColorBox(tmpCB).Clear;
    TColorBox(tmpCB).AddItem('H00VWHT',TObject($00FFFFFF));
    for V:=100 downto 0 do
      begin
        if not (V in [99,97,92,87,75,50]) then continue;
        for H:=0 to 17 do
          begin
            n1:=IntToStr(H*2);
            while length(n1)<2 do n1:='0'+n1;
            n2:=IntToStr(V);
            while length(n2)<2 do n2:='0'+n2;
            //color_dw:=(HSVToColor((H*20)/1,sqrt_n(pow_n(100)-pow_n(V)),V/1));
            //color_dw:=(HSVToColor((H*20)/1,100/exp(sqr(V-50)/1000),V/1));
            color_dw:=(HSVToColor((H*20)/1,100*sqrt(sin(V*V/1000/PI)),V/1));

            TColorBox(tmpCB).AddItem('H'+n1+'V'+n2,TObject(qword(color_dw)));
          end;
      end;
    TColorBox(tmpCB).AddItem('H00BLK',TObject($00000000));
  end;
  CB_List.Free;

end;

initialization
  display_reg:=TRegexpr.Create;


finalization
  display_reg.Free;

end.

