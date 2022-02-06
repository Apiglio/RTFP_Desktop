unit form_repeated_checker;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, CheckLst, Menus;

type

  { TFormRepeatedChecker }

  TFormRepeatedChecker = class(TForm)
    Button_ApplyCombination: TButton;
    Button_ChkOption: TButton;
    Button_SelectAll: TButton;
    Button_FindRepeated: TButton;
    Button_UnSelectAll: TButton;
    Button_RecommandSelection: TButton;
    ListBox_RepeatedPIDPair: TListBox;
    ListView_AttrsCompare: TListView;
    MenuItem_KeepMain: TMenuItem;
    MenuItem_KeepVice: TMenuItem;
    MenuItem_LinearComb: TMenuItem;
    MenuItem_DeleteAll: TMenuItem;
    PopupMenu_CombinationMode: TPopupMenu;
    ProgressBar1: TProgressBar;
    ProgressBar_Chk: TProgressBar;
    procedure Button_FindRepeatedClick(Sender: TObject);
    procedure Button_RecommandSelectionClick(Sender: TObject);
    procedure Button_SelectAllClick(Sender: TObject);
    procedure Button_UnSelectAllClick(Sender: TObject);
    procedure ListBox_RepeatedPIDPairSelectionChange(Sender: TObject;
      User: boolean);
    procedure MenuItem_DeleteAllClick(Sender: TObject);
    procedure MenuItem_KeepMainClick(Sender: TObject);
    procedure MenuItem_KeepViceClick(Sender: TObject);
    procedure MenuItem_LinearCombClick(Sender: TObject);
  private

  public

  end;


var
  FormRepeatedChecker: TFormRepeatedChecker;

implementation
uses RTFP_main, RTFP_definition, rtfp_field, rtfp_constants, dbf_common;

{$R *.lfm}




{ TFormRepeatedChecker }

procedure TFormRepeatedChecker.Button_FindRepeatedClick(Sender: TObject);
begin
  ListBox_RepeatedPIDPair.Clear;
  ListBox_RepeatedPIDPair.Items.BeginUpdate;
  CurrentRTFP.GetSimilarPIDList(ListBox_RepeatedPIDPair.Items,[scoTitle,scoFileName,scoHalffit,scoDS],ProgressBar_Chk);
  ListBox_RepeatedPIDPair.Items.EndUpdate;
end;

procedure TFormRepeatedChecker.Button_RecommandSelectionClick(Sender: TObject);
var index:integer;
    tmpAF:TAttrsField;
    tmpAG:TAttrsGroup;
    id1,id2:RTFP_ID;
    bo1,bo2:boolean;
begin
  for index:=0 to ListView_AttrsCompare.Items.Count-1 do
    begin
      tmpAF:=TAttrsField(ListView_AttrsCompare.Items[index].Data);
      if tmpAF = nil then
        begin
          if ListView_AttrsCompare.Items[index].Caption<>_Col_PID_ then continue;
          id1:=ListView_AttrsCompare.Items[index].SubItems[0];
          id2:=ListView_AttrsCompare.Items[index].SubItems[1];
          continue;
        end;
      tmpAG:=tmpAF.AttrsGroup;
      with tmpAG.Dbf do
        begin
          if not Active then Open;
          IndexName:='id';
          bo1:=SearchKey(id1,stEqual);
          bo2:=SearchKey(id2,stEqual);
          if bo1 then begin
            if bo2 then begin
              if (ListView_AttrsCompare.Items[index].SubItems[0]='')
              and (ListView_AttrsCompare.Items[index].SubItems[1]<>'') then
                ListView_AttrsCompare.Items[index].SubItems[2]:='次要属性'
              else
                ListView_AttrsCompare.Items[index].SubItems[2]:='主要属性';
            end else begin
              ListView_AttrsCompare.Items[index].SubItems[2]:='主要属性';
            end;
          end else begin
            if bo2 then begin
              ListView_AttrsCompare.Items[index].SubItems[2]:='次要属性';
            end else begin
              ListView_AttrsCompare.Items[index].SubItems[2]:='都不保留';
            end;
          end;
        end;
    end;
end;

procedure TFormRepeatedChecker.Button_SelectAllClick(Sender: TObject);
var index:integer;
begin
  ListView_AttrsCompare.BeginUpdate;
  for index:=0 to ListView_AttrsCompare.Items.Count-1 do
    begin
      if ListView_AttrsCompare.Items[index].Data=nil then continue;
      ListView_AttrsCompare.Items[index].SubItems[2]:='主要属性';
    end;
  ListView_AttrsCompare.EndUpdate;
end;

procedure TFormRepeatedChecker.Button_UnSelectAllClick(Sender: TObject);
var index:integer;
begin
  ListView_AttrsCompare.BeginUpdate;
  for index:=0 to ListView_AttrsCompare.Items.Count-1 do
    begin
      if ListView_AttrsCompare.Items[index].Data=nil then continue;
      ListView_AttrsCompare.Items[index].SubItems[2]:='次要属性';
    end;
  ListView_AttrsCompare.EndUpdate;
end;

procedure TFormRepeatedChecker.ListBox_RepeatedPIDPairSelectionChange(
  Sender: TObject; User: boolean);
var SelPair,id1,id2,v1,v2,bo:string;
    b1,b2:boolean;
    index:integer;
    tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
begin
  SelPair:=ListBox_RepeatedPIDPair.Items[ListBox_RepeatedPIDPair.ItemIndex];
  id1:=SelPair;
  id2:=SelPair;
  delete(id1,1,7);
  delete(id2,7,7);
  ListView_AttrsCompare.Clear;
  ListView_AttrsCompare.BeginUpdate;
  ListView_AttrsCompare.AddItem(_Col_PID_,nil);
  ListView_AttrsCompare.Items[0].SubItems.Add(id1);
  ListView_AttrsCompare.Items[0].SubItems.Add(id2);

  ListView_AttrsCompare.AddItem(_Col_Paper_FileName_,nil);
  ListView_AttrsCompare.Items[1].SubItems.Add(CurrentRTFP.GetPaperAttrs(_Col_Paper_FileName_,id1));
  ListView_AttrsCompare.Items[1].SubItems.Add(CurrentRTFP.GetPaperAttrs(_Col_Paper_FileName_,id2));

  ListView_AttrsCompare.AddItem(_Col_Paper_Folder_,nil);
  ListView_AttrsCompare.Items[2].SubItems.Add(CurrentRTFP.GetPaperAttrs(_Col_Paper_Folder_,id1));
  ListView_AttrsCompare.Items[2].SubItems.Add(CurrentRTFP.GetPaperAttrs(_Col_Paper_Folder_,id2));



  //ListView_AttrsCompare.Items[0].SubItems.Add('');
  for tmpAG in CurrentRTFP.FieldList do
    for tmpAF in tmpAG.FieldList do
      begin
        if (tmpAF.FieldName=_Col_PID_) or (tmpAF.FieldName=_Col_OID_) then continue;
        ListView_AttrsCompare.AddItem(tmpAG.Name+'.'+tmpAF.FieldName,tmpAF);
        index:=ListView_AttrsCompare.Items.Count-1;
        tmpAG.Dbf.IndexName:='id';
        b1:=tmpAG.Dbf.SearchKey(id1,stEqual);
        b2:=tmpAG.Dbf.SearchKey(id2,stEqual);
        if b1 then v1:=CurrentRTFP.ReadFieldAsString(tmpAF.FieldName,tmpAG.Name,id1,[aeFailIfNoPID]) else v1:='<未初始化>';
        if b2 then v2:=CurrentRTFP.ReadFieldAsString(tmpAF.FieldName,tmpAG.Name,id2,[aeFailIfNoPID]) else v2:='<未初始化>';

        ListView_AttrsCompare.Items[index].SubItems.Add(v1);
        ListView_AttrsCompare.Items[index].SubItems.Add(v2);
        if b1 then begin
          if b2 then
            begin
              if (v1='') and (v2<>'') then bo:='次要属性' else bo:='主要属性';
            end
          else
            bo:='主要属性';
        end else begin
          if b2 then bo:='次要属性' else bo:='都不保留';
        end;
        ListView_AttrsCompare.Items[index].SubItems.Add(bo);
      end;
  ListView_AttrsCompare.Column[0].Width:=160;
  ListView_AttrsCompare.Column[1].Width:=450;
  ListView_AttrsCompare.Column[2].Width:=450;
  ListView_AttrsCompare.Column[3].Width:=120;
  ListView_AttrsCompare.EndUpdate;
end;

procedure TFormRepeatedChecker.MenuItem_DeleteAllClick(Sender: TObject);
var index:integer;
begin
  index:=ListView_AttrsCompare.ItemIndex;
  if index<0 then exit;
  ListView_AttrsCompare.Items[index].SubItems[2]:='都不保留';

end;

procedure TFormRepeatedChecker.MenuItem_KeepMainClick(Sender: TObject);
var index:integer;
begin
  index:=ListView_AttrsCompare.ItemIndex;
  if index<0 then exit;
  ListView_AttrsCompare.Items[index].SubItems[2]:='主要属性';

end;

procedure TFormRepeatedChecker.MenuItem_KeepViceClick(Sender: TObject);
var index:integer;
begin
  index:=ListView_AttrsCompare.ItemIndex;
  if index<0 then exit;
  ListView_AttrsCompare.Items[index].SubItems[2]:='次要属性';

end;

procedure TFormRepeatedChecker.MenuItem_LinearCombClick(Sender: TObject);
var index:integer;
begin
  index:=ListView_AttrsCompare.ItemIndex;
  if index<0 then exit;
  ListView_AttrsCompare.Items[index].SubItems[2]:='文本追加';

end;

end.
