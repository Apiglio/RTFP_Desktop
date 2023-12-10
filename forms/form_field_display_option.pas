unit form_field_display_option;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ColorBox,
  StdCtrls, ExtCtrls, Grids, Menus, rtfp_field, db, Regexpr, Types;

type

  { TFormFieldDisplayOption }

  TFormFieldDisplayOption = class(TForm)
    Button_OK: TButton;
    ColorBox_Popup: TColorBox;
    MenuItem_VC_Custom_Color: TMenuItem;
    MenuItem_VC_div01: TMenuItem;
    MenuItem_VC_Ins: TMenuItem;
    MenuItem_VC_Add: TMenuItem;
    MenuItem_VC_Del: TMenuItem;
    PopupMenu_ValuesColors: TPopupMenu;
    ScrollBox_ValuesColors: TScrollBox;
    StringGrid_ValuesColors: TStringGrid;
    Memo_Tip: TMemo;
    RadioGroup_ColorStyle: TRadioGroup;
    procedure Button_OKClick(Sender: TObject);
    procedure CheckBox_UseDisplayOptionChange(Sender: TObject);
    procedure ColorBox_PopupSelect(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuItem_VC_AddClick(Sender: TObject);
    procedure MenuItem_VC_Custom_ColorClick(Sender: TObject);
    procedure MenuItem_VC_DelClick(Sender: TObject);
    procedure MenuItem_VC_InsClick(Sender: TObject);
    procedure StringGrid_ValuesColorsColRowDeleted(Sender: TObject;
      IsColumn: Boolean; sIndex, tIndex: Integer);
    procedure StringGrid_ValuesColorsColRowInserted(Sender: TObject;
      IsColumn: Boolean; sIndex, tIndex: Integer);
    procedure StringGrid_ValuesColorsDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure StringGrid_ValuesColorsMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure StringGrid_ValuesColorsMouseWheelDown(Sender: TObject;
      Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure StringGrid_ValuesColorsMouseWheelUp(Sender: TObject;
      Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure StringGrid_ValuesColorsResize(Sender: TObject);
    procedure RadioGroup_ColorStyleSelectionChanged(Sender: TObject);
    procedure StringGrid_ValuesColorsSelectCell(Sender: TObject; aCol,
      aRow: Integer; var CanSelect: Boolean);
  private
    CurrentField:TAttrsField;
    StoredDisplayOption:TFieldDisplayOption;
  public
    function Call(AAttrsField:TAttrsField):Integer;
  end;

var
  FormFieldDisplayOption: TFormFieldDisplayOption;

implementation
uses rtfp_dialog, rtfp_misc;

{$R *.lfm}

{ TFormFieldDisplayOption }

function FindColorBox(CB:TColorBox;color:TColor):integer;
var pi:integer;
begin
  for pi:=0 to CB.Items.Count-1 do begin
    result:=pi;
    {$ifdef cpu64}
    if qword(CB.Items.Objects[pi])=qword(color) then exit;
    {$else}
      {$error 'TColorBox color only work on cpu64'}
    {$endif}
  end;
  result:=-1;
end;

function TFormFieldDisplayOption.Call(AAttrsField:TAttrsField):Integer;
var pi,len,idx:integer;
begin
  if AAttrsField=nil then begin ShowMsgOK('字段显示设置','默认字段暂不支持单元格设色。');exit;end;//这句真的能达到触发条件吗
  CurrentField:=AAttrsField;
  Self.Caption:='字段显示设置'+' - '+AAttrsField.FieldName+'('+AAttrsField.AttrsGroup.Name+')';

  StoredDisplayOption.Assign(AAttrsField.FFieldDisplayOption);
  len:=StoredDisplayOption.Count;
  StringGrid_ValuesColors.RowCount:=len+1;
  for pi:=1 to len do begin
    StringGrid_ValuesColors.Cells[1,pi]:=StoredDisplayOption.Values[pi-1];
    idx:=FindColorBox(ColorBox_Popup,StoredDisplayOption.Colors[pi-1]);
    if idx<0 then StringGrid_ValuesColors.Cells[2,pi]:=''
    else StringGrid_ValuesColors.Cells[2,pi]:=ColorBox_Popup.Items[idx];
  end;
  case StoredDisplayOption.Mode of
    fdmSuccessive:RadioGroup_ColorStyle.ItemIndex:=1;
    fdmIdentical:RadioGroup_ColorStyle.ItemIndex:=2;
    fdmRegexpr:RadioGroup_ColorStyle.ItemIndex:=3;
    fdmDisabled:RadioGroup_ColorStyle.ItemIndex:=0;
    else RadioGroup_ColorStyle.ItemIndex:=0;
  end;
  StringGrid_ValuesColorsResize(StringGrid_ValuesColors);
  RadioGroup_ColorStyleSelectionChanged(RadioGroup_ColorStyle);
  result:=ShowModal;
end;

procedure TFormFieldDisplayOption.RadioGroup_ColorStyleSelectionChanged(
  Sender: TObject);
var RG:TRadioGroup;
begin
  RG:=Sender as TRadioGroup;
  Memo_Tip.Clear;
  case RG.Items[RG.ItemIndex] of
    '连续色带':
      begin
        Memo_Tip.Lines.Add('对数值型字段有效，选择两个数值边界及对应的颜色，两值中间的数值去渐变色带上的相应颜色。');
        StringGrid_ValuesColors.Enabled:=true;
      end;
    '离散值列表':
      begin
        Memo_Tip.Lines.Add('对字符型字段有效，依次判断字段值确定单元格颜色。');
        StringGrid_ValuesColors.Enabled:=true;
      end;
    '正则表达式':
      begin
        Memo_Tip.Lines.Add('对字符型字段有效，依次判断正则表达式确定单元格颜色。');
        StringGrid_ValuesColors.Enabled:=true;
      end;
    '无':
      begin
        Memo_Tip.Lines.Add('不进行单元格着色。');
        StringGrid_ValuesColors.Enabled:=false;
      end
    else ;
  end;
end;

procedure TFormFieldDisplayOption.StringGrid_ValuesColorsSelectCell(
  Sender: TObject; aCol, aRow: Integer; var CanSelect: Boolean);
var cell_rect:TRect;
    SG:TStringGrid;
    vc_color:TColor;
begin
  //这里ColorBox为什么总是没办法初始化就在正确的位置上？？？
  if aRow=0 then begin
    ColorBox_Popup.Visible:=false;
    exit;
  end;
  SG:=Sender as TStringGrid;
  ColorBox_Popup.Parent:=SG;
  ColorBox_Popup.Visible:=true;
  cell_rect:=SG.CellRect(2,aRow);
  ColorBox_Popup.Width:=cell_rect.Width-1;
  ColorBox_Popup.Height:=SG.DefaultRowHeight;//cell_rect.Height-2;
  ColorBox_Popup.Top:=cell_rect.Top;// + SG.Top;
  ColorBox_Popup.Left:=cell_rect.Left;// + SG.Left;
  vc_color:=StoredDisplayOption.Colors[aRow-1];
  ColorBox_Popup.ItemIndex:=FindColorBox(ColorBox_Popup,vc_color);
  Application.ProcessMessages;

end;

procedure TFormFieldDisplayOption.Button_OKClick(Sender: TObject);
var SG:TStringGrid;
    pi:integer;
begin
  with StoredDisplayOption do begin
    case RadioGroup_ColorStyle.Items[RadioGroup_ColorStyle.ItemIndex] of
      '连续色带':
        begin
          Mode:=fdmSuccessive;
        end;
      '离散值列表':
        begin
          Mode:=fdmIdentical;
        end;
      '正则表达式':
        begin
          Mode:=fdmRegexpr;
        end;
      '无':
        begin
          Mode:=fdmDisabled;
        end;
    end;
    SG:=StringGrid_ValuesColors;
    for pi:=1 to SG.RowCount-1 do begin
      StoredDisplayOption.Values[pi-1]:=SG.Cells[1,pi];
    end;
    CurrentField.FFieldDisplayOption.Assign(StoredDisplayOption);

  end;
  CurrentField:=nil;
  ModalResult:=mrOK;
end;

procedure TFormFieldDisplayOption.CheckBox_UseDisplayOptionChange(
  Sender: TObject);
begin
  if (Sender as TCheckBox).Checked then
    begin
      if StoredDisplayOption.Mode = fdmIdentical then
        RadioGroup_ColorStyle.ItemIndex:=1
      else
        RadioGroup_ColorStyle.ItemIndex:=0;
    end
  else
    begin
      RadioGroup_ColorStyle.ItemIndex:=-1;
      Memo_Tip.Lines.Add('');
      ColorBox_Popup.Enabled:=true;
    end;
  RadioGroup_ColorStyleSelectionChanged(RadioGroup_ColorStyle);
end;

procedure TFormFieldDisplayOption.ColorBox_PopupSelect(Sender: TObject);
var SG:TStringGrid;
    CB:TColorBox;
    tmpColor:TColor;
begin
  SG:=StringGrid_ValuesColors;
  CB:=Sender as TColorBox;
  tmpColor:=CB.Selected;
  StoredDisplayOption.Colors[SG.Row-1]:=tmpColor;
  SG.Cells[2,SG.Row]:=CB.Items[CB.ItemIndex];
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

  StringGrid_ValuesColors.ColCount:=3;
  StringGrid_ValuesColors.Cells[1,0]:='数值';
  StringGrid_ValuesColors.Cells[2,0]:='颜色';

  CB_List:=TList.Create;
  CB_List.Add(ColorBox_Popup);

  for tmpCB in CB_List do begin
    TColorBox(tmpCB).Clear;
    for V:=100 downto 0 do
      begin
        if not (V in [99,97,92,87,75,50]) then continue;
        for H:=0 to 23 do
          begin
            n1:=IntToStr(H);
            while length(n1)<2 do n1:='0'+n1;
            n2:=IntToStr(V);
            while length(n2)<2 do n2:='0'+n2;
            //color_dw:=(HSVToColor((H*20)/1,sqrt_n(pow_n(100)-pow_n(V)),V/1));
            //color_dw:=(HSVToColor((H*20)/1,100/exp(sqr(V-50)/1000),V/1));
            color_dw:=(HSVToColor((H*15)/1,100*sqrt(sin(V*V/1000/PI)),V/1));
            {$ifdef cpu64}
            TColorBox(tmpCB).AddItem('H'+n1+'V'+n2,TObject(qword(color_dw)));
            {$else}
              {$error 'TColorBox color only work on cpu64'}
            {$endif}
          end;
      end;
    TColorBox(tmpCB).AddItem('SBLACK',TObject($00000000));
    TColorBox(tmpCB).AddItem('S00V12',TObject($00202020));
    TColorBox(tmpCB).AddItem('S00V25',TObject($00404040));
    TColorBox(tmpCB).AddItem('S00V37',TObject($00606060));
    TColorBox(tmpCB).AddItem('S00V50',TObject($00808080));
    TColorBox(tmpCB).AddItem('S00V63',TObject($00A0A0A0));
    TColorBox(tmpCB).AddItem('S00V75',TObject($00C0C0C0));
    TColorBox(tmpCB).AddItem('S00V88',TObject($00E0E0E0));
    TColorBox(tmpCB).AddItem('SWHITE',TObject($00FFFFFF));
  end;
  CB_List.Free;

  StoredDisplayOption:=TFieldDisplayOption.Create;

end;

procedure TFormFieldDisplayOption.FormDestroy(Sender: TObject);
begin
  StoredDisplayOption.Free;
end;

procedure TFormFieldDisplayOption.MenuItem_VC_AddClick(Sender: TObject);
var arow:integer;
begin
  arow:=StringGrid_ValuesColors.RowCount;
  StringGrid_ValuesColors.RowCount:=arow+1;
  StoredDisplayOption.InsertValue(arow-1,'');
  StoredDisplayOption.InsertColor(arow-1,$ff000000);
end;

procedure TFormFieldDisplayOption.MenuItem_VC_Custom_ColorClick(Sender: TObject
  );
begin
  //自定义颜色暂时不实现
end;

procedure TFormFieldDisplayOption.MenuItem_VC_DelClick(Sender: TObject);
var arow:integer;
begin
  arow:=StringGrid_ValuesColors.Row;
  if arow<=0 then exit;
  StringGrid_ValuesColors.DeleteRow(StringGrid_ValuesColors.Row);
  StoredDisplayOption.DeleteValue(arow-1);
  StoredDisplayOption.DeleteColor(arow-1);
end;

procedure TFormFieldDisplayOption.MenuItem_VC_InsClick(Sender: TObject);
var arow:integer;
begin
  arow:=StringGrid_ValuesColors.Row;
  if arow<=0 then exit;
  StringGrid_ValuesColors.InsertRowWithValues(arow,[]);
  StoredDisplayOption.InsertValue(arow-1,'');
  StoredDisplayOption.InsertColor(arow-1,$ff000000);
end;

procedure TFormFieldDisplayOption.StringGrid_ValuesColorsColRowDeleted(
  Sender: TObject; IsColumn: Boolean; sIndex, tIndex: Integer);
begin
  with Sender as TStringGrid do begin
    Height:=RowCount*DefaultRowHeight;
  end;
end;

procedure TFormFieldDisplayOption.StringGrid_ValuesColorsColRowInserted(
  Sender: TObject; IsColumn: Boolean; sIndex, tIndex: Integer);
begin
  with Sender as TStringGrid do begin
    Height:=RowCount*DefaultRowHeight;
  end;
end;

procedure TFormFieldDisplayOption.StringGrid_ValuesColorsDrawCell(Sender: TObject; aCol,
  aRow: Integer; aRect: TRect; aState: TGridDrawState);
var SG:TStringGrid;
begin
  if aCol*aRow=0 then exit;
  if aCol=1 then exit;
  SG:=Sender as TStringGrid;
  SG.Canvas.Brush.Color:=StoredDisplayOption.Colors[aRow-1];
  SG.Canvas.FillRect(aRect);
  SG.DefaultDrawCell(aCol,aRow,aRect,aState);
end;

procedure TFormFieldDisplayOption.StringGrid_ValuesColorsMouseUp(
  Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var SG:TStringGrid;
begin
  SG:=Sender as TStringGrid;
  SG.Row:=Y div SG.DefaultRowHeight;
  SG.Col:=1;
end;

procedure TFormFieldDisplayOption.StringGrid_ValuesColorsMouseWheelDown(
  Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  with ScrollBox_ValuesColors.VertScrollBar do
    Position:=Position + Page div 2;
end;

procedure TFormFieldDisplayOption.StringGrid_ValuesColorsMouseWheelUp(
  Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  with ScrollBox_ValuesColors.VertScrollBar do
    Position:=Position - Page div 2;
end;

procedure TFormFieldDisplayOption.StringGrid_ValuesColorsResize(Sender: TObject);
var w:integer;
    SG:TStringGrid;
    cs:boolean;
begin
  SG:=Sender as TStringGrid;
  w:=(SG.Width - 40) div 3;
  StringGrid_ValuesColors.ColWidths[0]:=40;
  StringGrid_ValuesColors.ColWidths[1]:=2*w;
  StringGrid_ValuesColors.ColWidths[2]:=w;
  cs:=true;
  StringGrid_ValuesColors.DefaultRowHeight:=ColorBox_Popup.Height-1;
  StringGrid_ValuesColorsSelectCell(SG,SG.Col,SG.Row,cs);
end;

end.

