unit form_field_change;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  rtfp_field, db;

type

  { TForm_FieldChange }

  TForm_FieldChange = class(TForm)
    Button_information: TButton;
    Button_ChangeField: TButton;
    Edit_FieldName: TEdit;
    Edit_FieldSize: TEdit;
    ComboBox_FieldType: TComboBox;
    Label_FieldComboItem: TLabel;
    Label_FieldName: TLabel;
    Label_FieldType: TLabel;
    Label_FieldSize: TLabel;
    Memo_ComboItem: TMemo;
    Memo_TypeChangeTip: TMemo;
    ScrollBox_FieldOption: TScrollBox;
    procedure Button_ChangeFieldClick(Sender: TObject);
    procedure ComboBox_FieldTypeChange(Sender: TObject);
  private
    CurrentField:TAttrsField;
    function ComboBoxToFieldType:TFieldType;
    procedure FieldTypeToComboBox(value:TFieldType);
  public
    procedure Call(AAttrsField:TAttrsField);
    procedure Update;
  end;

var
  Form_FieldChange: TForm_FieldChange;

implementation
uses rtfp_dialog, rtfp_field_convert, RTFP_definition, RTFP_main;

{$R *.lfm}

{ TForm_FieldChange }

function TForm_FieldChange.ComboBoxToFieldType:TFieldType;
begin
  case ComboBox_FieldType.Items[ComboBox_FieldType.ItemIndex] of
    '段落 Memo':result:=ftMemo;
    '字符串 String':result:=ftString;
    '布尔 Boolean':result:=ftBoolean;
    '短整型 SmallInt':result:=ftSmallint;
    '长整型 LargeInt':result:=ftLargeint;
    '浮点型 Float':result:=ftFloat;
    '时间 DateTime':result:=ftDateTime;
    '日期 Date':result:=ftDate;
    '图像 Blob':result:=ftBlob;
    '系统自增 AutoInc':result:=ftAutoInc;
    else result:=ftUnknown;
  end;
end;

procedure TForm_FieldChange.FieldTypeToComboBox(value:TFieldType);
begin
  case value of
    ftMemo:ComboBox_FieldType.ItemIndex:=0;
    ftString:ComboBox_FieldType.ItemIndex:=1;
    ftBoolean:ComboBox_FieldType.ItemIndex:=2;
    ftSmallint:ComboBox_FieldType.ItemIndex:=3;
    ftLargeint:ComboBox_FieldType.ItemIndex:=4;
    ftFloat:ComboBox_FieldType.ItemIndex:=5;
    ftDateTime:ComboBox_FieldType.ItemIndex:=6;
    ftDate:ComboBox_FieldType.ItemIndex:=7;
    ftBlob:ComboBox_FieldType.ItemIndex:=8;
    ftAutoInc:ComboBox_FieldType.ItemIndex:=9;
    else ComboBox_FieldType.ItemIndex:=-1;
  end;
  //这里如果ComboBox_FieldType列表内容顺序变化全部要重新修改
end;

procedure TForm_FieldChange.ComboBox_FieldTypeChange(Sender: TObject);
var target_type:TFieldType;
    cvf:pConvertFunc;
begin
  target_type:=ComboBoxToFieldType;
  case target_type of
    ftString,ftFloat:Edit_FieldSize.Enabled:=true;
    else Edit_FieldSize.Enabled:=false;
  end;
  Memo_TypeChangeTip.Clear;
  Memo_TypeChangeTip.Lines.Add(FieldTypeChangeMode(CurrentField.FieldDef.DataType,target_type,cvf));
end;

procedure TForm_FieldChange.Button_ChangeFieldClick(Sender: TObject);
var new_name:string;
    new_type:TFieldType;
    new_size:integer;
begin
  new_name:=Edit_FieldName.Caption;
  new_type:=ComboBoxToFieldType;
  try
    new_size:=StrToInt(Edit_FieldSize.Caption);
  except
    new_size:=CurrentField.FieldDef.Size;
  end;
  //先改类型
  if CurrentField.FieldDef.DataType<>new_type then begin
    case new_type of
      ftString:CurrentRTFP.ReTypeField(CurrentField.FieldName,CurrentField.AttrsGroup.Name,new_type,new_size);
      else CurrentRTFP.ReTypeField(CurrentField.FieldName,CurrentField.AttrsGroup.Name,new_type);
    end;
  end else begin
    if (CurrentField.FieldDef.Size<>new_size) and (new_type=ftString) then
      CurrentRTFP.ReTypeField(CurrentField.FieldName,CurrentField.AttrsGroup.Name,new_type,new_size);
  end;
  //再改名
  if CurrentField.FieldDef.Name<>new_name then CurrentRTFP.RenameField(CurrentField.FieldName,new_name,CurrentField.AttrsGroup.Name);
  ModalResult:=mrOK;
  //最后改combo选项
  CurrentField.ComboItem.Assign(Memo_ComboItem.Lines);
end;

procedure TForm_FieldChange.Call(AAttrsField:TAttrsField);
begin
  if AAttrsField=nil then begin ShowMsgOK('字段属性','默认字段无法查看和修改属性。');exit;end;//这句真的能达到触发条件吗
  CurrentField:=AAttrsField;
  Self.Caption:='字段属性'+' - '+AAttrsField.FieldName+'('+AAttrsField.AttrsGroup.Name+')';
  Update;
  ShowModal;
end;

procedure TForm_FieldChange.Update;
begin
  Edit_FieldName.Caption:=CurrentField.FieldName;
  Edit_FieldSize.Caption:=IntToStr(CurrentField.FieldDef.Size);
  FieldTypeToComboBox(CurrentField.FieldDef.DataType);
  case CurrentField.FieldDef.DataType of
    ftString:Edit_FieldSize.Enabled:=true;
    else Edit_FieldSize.Enabled:=false;
  end;
  Memo_ComboItem.Lines.Assign(CurrentField.ComboItem);
end;

end.

