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
    Edit_FieldDisplayName: TEdit;
    Edit_FieldSize: TEdit;
    ComboBox_FieldType: TComboBox;
    Label_FieldComboItem: TLabel;
    Label_FieldName: TLabel;
    Label_FieldType: TLabel;
    Label_FieldSize: TLabel;
    Label_FieldDisplayName: TLabel;
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
    function Call(AAttrsField:TAttrsField):Integer;
    procedure DataUpdate;
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
  if value=ftUnknown then ComboBox_FieldType.Text:='属性组';
  //这里如果ComboBox_FieldType列表内容顺序变化全部要重新修改
end;

procedure TForm_FieldChange.ComboBox_FieldTypeChange(Sender: TObject);
var target_type:TFieldType;
    cvf:pConvertFunc;
    res:string;
begin
  target_type:=ComboBoxToFieldType;
  case target_type of
    ftString,ftFloat:Edit_FieldSize.Enabled:=true;
    else Edit_FieldSize.Enabled:=false;
  end;
  Memo_TypeChangeTip.Clear;
  res:=FieldTypeChangeMode(CurrentField.FieldDef.DataType,target_type,cvf);
  Memo_TypeChangeTip.Lines.Add(res);
  if res='不支持保留数值的转换。' then Button_ChangeField.Enabled:=false
  else Button_ChangeField.Enabled:=true;
end;

procedure TForm_FieldChange.Button_ChangeFieldClick(Sender: TObject);
var new_name:string;
    new_type:TFieldType;
    new_size:integer;
    current_fe:string;
begin
  if CurrentField is TAttrsField then begin
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
        ftString:
          begin
            if new_size<1 then new_size:=1;
            CurrentRTFP.ReTypeField(CurrentField.FieldName,CurrentField.AttrsGroup.Name,new_type,new_size);
          end
        else CurrentRTFP.ReTypeField(CurrentField.FieldName,CurrentField.AttrsGroup.Name,new_type);
      end;
    end else begin
      if (CurrentField.FieldDef.Size<>new_size) and (new_type=ftString) then
        CurrentRTFP.ReTypeField(CurrentField.FieldName,CurrentField.AttrsGroup.Name,new_type,new_size);
    end;
    //再改名
    CurrentField.FFieldDisplayOption.DispName:=Edit_FieldDisplayName.Caption;
    if CurrentField.FieldDef.Name<>new_name then CurrentRTFP.RenameField(CurrentField.FieldName,new_name,CurrentField.AttrsGroup.Name);
    ModalResult:=mrOK;
    CurrentRTFP.FieldAndRecordChange;
    //最后改combo选项
    CurrentField.ComboItem.Assign(Memo_ComboItem.Lines);
    current_fe:=FormDesktop.ComboBox_FormatEdit.Text;
    CurrentRTFP.FormatEditChange(current_fe,current_fe);
  end else begin
    new_name:=Edit_FieldName.Caption;
    TAttrsGroup(CurrentField).DisplayName:=Edit_FieldDisplayName.Caption;
    CurrentRTFP.RenameAttrs(TAttrsGroup(CurrentField).Name,new_name);
    CurrentRTFP.FieldAndRecordChange;
    ModalResult:=mrOK;
  end;
end;

function TForm_FieldChange.Call(AAttrsField:TAttrsField):Integer;
begin
  if AAttrsField=nil then begin
    ShowMsgOK('字段属性','默认字段无法查看和修改属性。');
    exit;
  end;
  CurrentField:=AAttrsField;
  if CurrentField is TAttrsField then
    Self.Caption:='字段属性'+' - '+AAttrsField.FieldName+'('+AAttrsField.AttrsGroup.Name+')'
  else
    Self.Caption:='属性组设置'+' - '+AAttrsField.FieldName;
  DataUpdate;
  result:=ShowModal;
end;

procedure TForm_FieldChange.DataUpdate;
begin
  if CurrentField is TAttrsField then begin
    Label_FieldName.Caption:='字段名称：';
    Edit_FieldName.Caption:=CurrentField.FieldName;
    Edit_FieldDisplayName.Caption:=CurrentField.FieldDisplayOption.DispName;
    Edit_FieldSize.Enabled:=true;
    Edit_FieldSize.Caption:=IntToStr(CurrentField.FieldDef.Size);
    FieldTypeToComboBox(CurrentField.FieldDef.DataType);
    ComboBox_FieldType.Enabled:=true;
    case CurrentField.FieldDef.DataType of
      ftString:Edit_FieldSize.Enabled:=true;
      else Edit_FieldSize.Enabled:=false;
    end;
    Memo_TypeChangeTip.Clear;
    Memo_ComboItem.Enabled:=true;
    Memo_ComboItem.Lines.Assign(CurrentField.ComboItem);
  end else begin
    Label_FieldName.Caption:='属性组：';
    Edit_FieldName.Caption:=TAttrsGroup(CurrentField).Name;
    Edit_FieldDisplayName.Caption:=TAttrsGroup(CurrentField).DisplayName;
    Edit_FieldSize.Enabled:=false;
    FieldTypeToComboBox(ftUnknown);
    ComboBox_FieldType.Enabled:=false;
    Edit_FieldSize.Caption:='';
    Edit_FieldSize.Enabled:=false;
    Memo_TypeChangeTip.Clear;
    Memo_TypeChangeTip.Lines.Add('属性组仅能修改名称');
    Memo_ComboItem.Clear;
    Memo_ComboItem.Enabled:=false;
  end;
  Application.ProcessMessages;
end;

end.

