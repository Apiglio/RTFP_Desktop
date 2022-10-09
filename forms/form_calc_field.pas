unit form_calc_field;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, Forms, Controls, Graphics, Dialogs,
  Grids, ComCtrls, StdCtrls, ExtCtrls, Menus, rtfp_field;

type

  TRangeMode = (rm_maingrid=0, rm_all=1);
  TMatchMode = (mm_once=0, mm_all=1);

  { TForm_CalcField }

  TForm_CalcField = class(TForm)
    Button_FieldCalc_Confirm: TButton;
    Button_FieldJoin_Confirm: TButton;
    ComboBox_MatchField: TComboBox;
    ComboBox_ValueField: TComboBox;
    Label_MatchField: TLabel;
    Label_ValueField: TLabel;
    ListBox_Fields: TListBox;
    Memo_CalcSyntaxMid: TSynEdit;
    Memo_CalcSyntaxPost: TSynEdit;
    Memo_CalcSyntaxPre: TSynEdit;
    MenuItem_div01: TMenuItem;
    MenuItem_EditSel: TMenuItem;
    MenuItem_DelRow: TMenuItem;
    MenuItem_AddRow: TMenuItem;
    MenuItem_Clean: TMenuItem;
    PageControl1: TPageControl;
    PopupMenu_JoinField: TPopupMenu;
    RadioGroup_MatchMode: TRadioGroup;
    RadioGroup_EditRange: TRadioGroup;
    StringGrid_Join: TStringGrid;
    TabSheet_Formula: TTabSheet;
    TabSheet_Join: TTabSheet;
    procedure Button_FieldCalc_ConfirmClick(Sender: TObject);
    procedure Button_FieldJoin_ConfirmClick(Sender: TObject);
    procedure ComboBox_MatchFieldChange(Sender: TObject);
    procedure ComboBox_ValueFieldChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListBox_FieldsDblClick(Sender: TObject);
    procedure ListBox_FieldsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Memo_CalcSyntaxMidDragDrop(Sender, Source: TObject; X,
      Y: Integer);
    procedure Memo_CalcSyntaxMidDragOver(Sender, Source: TObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
    procedure MenuItem_AddRowClick(Sender: TObject);
    procedure MenuItem_CleanClick(Sender: TObject);
    procedure MenuItem_DelRowClick(Sender: TObject);
    procedure MenuItem_EditSelClick(Sender: TObject);
    procedure RadioGroup_EditRangeClick(Sender: TObject);
    procedure RadioGroup_MatchModeClick(Sender: TObject);
    procedure StringGrid_JoinKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure StringGrid_JoinResize(Sender: TObject);
    procedure TabSheet_JoinResize(Sender: TObject);
  private
    FTargetField:TAttrsField;
    FMatchField:TAttrsField;
    FRangeMode:TRangeMode;
    FMatchMode:TMatchMode;
  protected
    DragField:TAttrsField;
  public
    procedure Call(ATargetField:TAttrsField);
    procedure Update;
  end;

var
  Form_CalcField: TForm_CalcField;

implementation
uses RTFP_main, rtfp_dialog, db;

{$R *.lfm}

procedure TForm_CalcField.Button_FieldJoin_ConfirmClick(Sender: TObject);
var pid_list:TStringList;
    pid,match_str,target_str,match_field:string;
    sg_index,sg_count:integer;
    tmpValueF:double;
    tmpValueI:int64;
    tmpValueD:TDateTime;
begin
  pid_list:=TStringList.Create;
  CurrentRTFP.BeginUpdate;
    try
    case FRangeMode of
      rm_maingrid:CurrentRTFP.GetPIDList_DS(pid_list);
      rm_all:CurrentRTFP.GetPIDList(pid_list);
      else exit;
    end;
    sg_count:=StringGrid_Join.RowCount;
    for sg_index:=1 to sg_count-1 do begin
      match_str:=StringGrid_Join.Cells[1,sg_index];
      target_str:=StringGrid_Join.Cells[2,sg_index];
      if (match_str='') and (target_str='') then continue;
      for pid in pid_list do begin
        match_field:=CurrentRTFP.ReadFieldAsString(FMatchField.FieldName,FMatchField.AttrsGroup.Name,pid,[]);
        if match_field=match_str then begin
          case FTargetField.FieldDef.DataType of
            ftString,ftMemo:CurrentRTFP.EditFieldAsString(FTargetField.FieldName,FTargetField.AttrsGroup.Name,pid,target_str,[]);
            ftblob:CurrentRTFP.EditFieldFromImageFile(FTargetField.FieldName,FTargetField.AttrsGroup.Name,pid,target_str,[]);
            ftFloat:if TryStrToFloat(target_str,tmpValueF) then
                      CurrentRTFP.EditFieldAsDouble(FTargetField.FieldName,FTargetField.AttrsGroup.Name,pid,tmpValueF,[]);
            ftLargeint,ftInteger,ftSmallint:if TryStrToInt64(target_str,tmpValueI) then
                      CurrentRTFP.EditFieldAsInteger(FTargetField.FieldName,FTargetField.AttrsGroup.Name,pid,tmpValueI,[]);
            ftDate,ftDateTime,ftTime:if TryStrToDateTime(target_str,tmpValueD) then
                      CurrentRTFP.EditFieldAsDateTime(FTargetField.FieldName,FTargetField.AttrsGroup.Name,pid,tmpValueD,[]);
            else ;
          end;
          if FMatchMode=mm_once then break;//这个替换一次不太对，不是预期的那种依次独占赋值，替换不到后面的值
        end;
      end;
    end;
  finally
    CurrentRTFP.EndUpdate;
    pid_list.Free;
  end;
  CurrentRTFP.RecordChange;
  ModalResult:=mrOK;
end;

{
ifdef _apiglio_pid_,@2_lines_next
var char _apiglio_pid_ 6
ifdef _apiglio_res_,@2_lines_next
var char _apiglio_res_ 2048
ifdef _apiglio_tmp_,@2_lines_next
var char _apiglio_tmp_ 2048
pid.first @_apiglio_pid_
loo:
mov @_apiglio_res_,""
cat @_apiglio_res_,Content
attrs.rec.read @_apiglio_pid_,AttrName,FieldName,@_apiglio_tmp_
cat @_apiglio_res_,@_apiglio_tmp_
//...
attrs.rec.edit @_apiglio_pid_,AttrName,FieldName,@_apiglio_tmp_
pid.next_jump @_apiglio_pid_,:loo
unvar _apiglio_pid_
unvar _apiglio_res_
unvar _apiglio_tmp_
end
}

procedure TForm_CalcField.Button_FieldCalc_ConfirmClick(Sender: TObject);
var cmd:TStringList;
    stmp:string;
begin
  //这里因为界面没考虑好，那就暂时不实现主表计算了，计算字段一定会计算全部节点
  cmd:=TStringList.Create;
  CurrentRTFP.BeginUpdate;
  try
    for stmp in Memo_CalcSyntaxPre.Lines do cmd.Add(stmp);
    for stmp in Memo_CalcSyntaxMid.Lines do cmd.Add(stmp);
    for stmp in Memo_CalcSyntaxPost.Lines do cmd.Add(stmp);
    FormDesktop.Frame_AufScript1.Auf.Script.command(cmd);
  finally
    cmd.Free;
    CurrentRTFP.EndUpdate;
  end;
  CurrentRTFP.RecordChange;
end;

procedure TForm_CalcField.ComboBox_MatchFieldChange(Sender: TObject);
var index:integer;
begin
  index:=(Sender as TComboBox).ItemIndex;
  if index<0 then begin
    FMatchField:=nil;
    exit;
  end;
  FMatchField:=TAttrsField((Sender as TComboBox).Items.Objects[index]);
  Update;
end;

procedure TForm_CalcField.ComboBox_ValueFieldChange(Sender: TObject);
var index:integer;
begin
  index:=(Sender as TComboBox).ItemIndex;
  if index<0 then begin
    FMatchField:=nil;
    exit;
  end;
  FTargetField:=TAttrsField((Sender as TComboBox).Items.Objects[index]);
  Update;
end;

procedure TForm_CalcField.FormCreate(Sender: TObject);
begin
  Memo_CalcSyntaxPre.Highlighter:=FormDesktop.Frame_AufScript1.Auf.Script.SynAufSyn;
  Memo_CalcSyntaxMid.Highlighter:=FormDesktop.Frame_AufScript1.Auf.Script.SynAufSyn;
  Memo_CalcSyntaxPost.Highlighter:=FormDesktop.Frame_AufScript1.Auf.Script.SynAufSyn;
end;

procedure TForm_CalcField.ListBox_FieldsDblClick(Sender: TObject);
var index:integer;
begin
  index:=ListBox_Fields.ItemIndex;
  if index<0 then exit;
  DragField:=TAttrsField(ListBox_Fields.Items.Objects[index]);
  if DragField=nil then
    Memo_CalcSyntaxMid.SelText:=#13#10+'cat @_apiglio_res_,""'
  else
    Memo_CalcSyntaxMid.SelText:=#13#10+'attrs.rec.read @_apiglio_pid_,"'
      +DragField.AttrsGroup.Name+'","'+DragField.FieldName+'",@_apiglio_tmp_'
      +#13#10+'cat @_apiglio_res_,@_apiglio_tmp_';
end;

procedure TForm_CalcField.ListBox_FieldsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var index:integer;
begin
  index:=ListBox_Fields.ItemIndex;
  if index<0 then exit;
  DragField:=TAttrsField(ListBox_Fields.Items.Objects[index]);
  BeginDrag(true);
end;

procedure TForm_CalcField.Memo_CalcSyntaxMidDragDrop(Sender,
  Source: TObject; X, Y: Integer);
begin
  if DragField=nil then
    Memo_CalcSyntaxMid.SelText:=#13#10+'cat @_apiglio_res_,""'
  else
    Memo_CalcSyntaxMid.SelText:=#13#10+'attrs.rec.read @_apiglio_pid_,"'
      +DragField.AttrsGroup.Name+'","'+DragField.FieldName+'",@_apiglio_tmp_'
      +#13#10+'cat @_apiglio_res_,@_apiglio_tmp_';
end;

procedure TForm_CalcField.Memo_CalcSyntaxMidDragOver(Sender,
  Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept:=DragField<>FTargetField;
end;

procedure TForm_CalcField.MenuItem_AddRowClick(Sender: TObject);
var sel:TGridRect;
    sel_height:integer;
begin
  sel:=StringGrid_Join.Selection;
  sel_height:=sel.Height;
  if sel_height<1 then sel_height:=1;
  StringGrid_Join.RowCount:=StringGrid_Join.RowCount+sel_height;
end;

procedure TForm_CalcField.MenuItem_CleanClick(Sender: TObject);
var sel:TGridRect;
begin
  sel:=StringGrid_Join.Selection;
  StringGrid_Join.Clean(sel.Left,sel.Top,sel.Right,sel.Bottom,[]);
end;

procedure TForm_CalcField.MenuItem_DelRowClick(Sender: TObject);
var sel:TGridRect;
    bor,eor,idx:integer;
begin
  sel:=StringGrid_Join.Selection;
  bor:=sel.Top;
  eor:=sel.Bottom;
  for idx:=eor downto bor do StringGrid_Join.DeleteRow(idx);
end;

procedure TForm_CalcField.MenuItem_EditSelClick(Sender: TObject);
var sel:TGridRect;
    pi,pj:integer;
    stmp:string;
begin
  stmp:=ShowMsgEdit('批量编辑单元格','单元格值：','');
  sel:=StringGrid_Join.Selection;
  for pi:=sel.Top to sel.Bottom do
    for pj:=sel.Left to sel.Right do
      StringGrid_Join.Cells[pj,pi]:=stmp;
end;

procedure TForm_CalcField.RadioGroup_EditRangeClick(Sender: TObject);
begin
  with Sender as TRadioGroup do begin
    case ItemIndex of
      0:FRangeMode:=rm_maingrid;
      1:FRangeMode:=rm_all;
    end;
  end;
end;

procedure TForm_CalcField.RadioGroup_MatchModeClick(Sender: TObject);
begin
  with Sender as TRadioGroup do begin
    case ItemIndex of
      0:FMatchMode:=mm_once;
      1:FMatchMode:=mm_all;
    end;
  end;
end;

procedure TForm_CalcField.StringGrid_JoinKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var sel:TGridRect;
begin
  if (Shift=[]) and (Key=127) then begin
    sel:=StringGrid_Join.Selection;
    StringGrid_Join.Clean(sel.Left,sel.Top,sel.Right,sel.Bottom,[]);
  end;
end;

procedure TForm_CalcField.StringGrid_JoinResize(Sender: TObject);
var col_width:integer;
begin
  with Sender as TStringGrid do begin
    col_width:=(Width-ColWidths[0]-24) div 2;
    ColWidths[1]:=col_width;
    ColWidths[2]:=col_width;
  end;
end;

procedure TForm_CalcField.TabSheet_JoinResize(Sender: TObject);
var radio_width:integer;
begin
  radio_width:=(Width - StringGrid_Join.Width - 64) div 3;
  RadioGroup_EditRange.Width:=radio_width;
  RadioGroup_MatchMode.Width:=radio_width;
end;

procedure TForm_CalcField.Call(ATargetField:TAttrsField);
var tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
    stmp:string;
    index:integer;
begin
  FTargetField:=ATargetField;
  index:=-1;
  ComboBox_MatchField.Clear;
  ComboBox_ValueField.Clear;
  ListBox_Fields.Clear;
  ListBox_Fields.AddItem('添加字符串',nil);
  for tmpAG in CurrentRTFP.FieldList do begin
    for tmpAF in tmpAG.FieldList do begin
      //stmp:=tmpAG.Name+'.'+tmpAF.FieldName;
      stmp:=tmpAF.FieldName+' ('+tmpAG.Name+')';
      ComboBox_MatchField.AddItem(stmp,tmpAF);
      ComboBox_ValueField.AddItem(stmp,tmpAF);
      ListBox_Fields.AddItem(stmp,tmpAF);
      if tmpAF=FTargetField then index:=ComboBox_ValueField.Items.Count-1;
    end;
  end;
  ComboBox_ValueField.ItemIndex:=index;
  ComboBox_MatchField.ItemIndex:=-1;
  FMatchField:=nil;
  StringGrid_Join.Clean;
  StringGrid_Join.RowCount:=CurrentRTFP.CountPaper+1;
  StringGrid_Join.ColCount:=3;
  StringGrid_Join.ColWidths[0]:=30;
  StringGrid_Join.ColWidths[1]:=90;
  StringGrid_Join.ColWidths[2]:=90;
  Update;
  ShowModal;
end;

procedure TForm_CalcField.Update;
begin
  if FMatchField=nil then
    StringGrid_Join.Cells[1,0]:='匹配字段'
  else
    StringGrid_Join.Cells[1,0]:='匹配字段：'+FMatchField.AttrsGroup.Name+'.'+FMatchField.FieldName;
  if FTargetField=nil then
    StringGrid_Join.Cells[2,0]:='目标字段'
  else
    StringGrid_Join.Cells[2,0]:='目标字段：'+FTargetField.AttrsGroup.Name+'.'+FTargetField.FieldName;
  Memo_CalcSyntaxPost.Lines[0]:='attrs.rec.edit @_apiglio_pid_,'+FTargetField.AttrsGroup.Name+','+FTargetField.FieldName+',@_apiglio_res_';
  StringGrid_Join.OnResize(StringGrid_Join);
end;

end.

