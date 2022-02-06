unit form_repeated_checker;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, CheckLst, Menus, ExtCtrls;

type

  { TFormRepeatedChecker }

  TFormRepeatedChecker = class(TForm)
    Button_ApplyCombination: TButton;
    Button_ApplyAll: TButton;
    Button_SelectAll: TButton;
    Button_FindRepeated: TButton;
    Button_UnSelectAll: TButton;
    Button_RecommandSelection: TButton;
    CheckGroup_ColMode: TCheckGroup;
    ListBox_RepeatedPIDPair: TListBox;
    ListView_AttrsCompare: TListView;
    MenuItem_KeepMain: TMenuItem;
    MenuItem_KeepVice: TMenuItem;
    MenuItem_LinearComb: TMenuItem;
    MenuItem_DeleteAll: TMenuItem;
    PopupMenu_CombinationMode: TPopupMenu;
    ProgressBar_Chk: TProgressBar;
    RadioGroup_SelMode: TRadioGroup;
    RadioGroup_FitMode: TRadioGroup;
    Splitter_Opt: TSplitter;
    procedure Button_ApplyCombinationClick(Sender: TObject);
    procedure Button_ApplyAllClick(Sender: TObject);
    procedure Button_FindRepeatedClick(Sender: TObject);
    procedure Button_RecommandSelectionClick(Sender: TObject);
    procedure Button_SelectAllClick(Sender: TObject);
    procedure Button_UnSelectAllClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
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
uses RTFP_main, RTFP_definition, rtfp_field, rtfp_constants,
     dbf_common, rtfp_dialog;

{$R *.lfm}




{ TFormRepeatedChecker }

procedure TFormRepeatedChecker.Button_FindRepeatedClick(Sender: TObject);
var vOption:TSimChkOptions;
    tmpProc:TNotifyEvent;
    cnt_total:integer;
begin

  ListView_AttrsCompare.Clear;
  vOption:=[];
  case RadioGroup_FitMode.ItemIndex of
    0:vOption:=vOption+[scoEqual];
    1:vOption:=vOption+[scoContain];
    2:vOption:=vOption+[scoHalffit];
    3:vOption:=vOption+[scoHalffitUnsigned];
  end;
  case RadioGroup_SelMode.ItemIndex of
    0:vOption:=vOption+[scoDS];
    1:vOption:=vOption+[scoDB];
  end;
  if CheckGroup_ColMode.Checked[0] then vOption:=vOption+[scoFileName];
  if CheckGroup_ColMode.Checked[1] then vOption:=vOption+[scoFileHash];
  if CheckGroup_ColMode.Checked[2] then vOption:=vOption+[scoTitle];
  if CheckGroup_ColMode.Checked[3] then vOption:=vOption+[scoWeblnk];
  if CheckGroup_ColMode.Checked[4] then vOption:=vOption+[scoDOI];

  if scoDB in vOption then cnt_total:=CurrentRTFP.CountPaper
  else cnt_total:=CurrentRTFP.PaperDS.RecordCount;
  if cnt_total>400 then begin
    if ShowMsgYesNoAll('查重','需要查重的节点过多，可能耗时较旧，是否继续？')<>'Yes' then exit;
  end;

  FormDesktop.ShowWaitForm:=false;
  AllState.Enable;
  tmpProc:=CurrentRTFP.onChange;
  CurrentRTFP.onChange:=nil;
  Enabled:=false;

  ListBox_RepeatedPIDPair.Clear;
  ListBox_RepeatedPIDPair.Items.BeginUpdate;
  CurrentRTFP.GetSimilarPIDList(ListBox_RepeatedPIDPair.Items,vOption,ProgressBar_Chk);
  ListBox_RepeatedPIDPair.Items.EndUpdate;

  Enabled:=true;
  CurrentRTFP.onChange:=tmpProc;
  FormDesktop.ShowWaitForm:=true;
  AllState.Disable;

end;

procedure TFormRepeatedChecker.Button_ApplyCombinationClick(Sender: TObject);
var vFieldSelectOptions:TFieldSelectOptions;
    ListViewIndex:integer;
    tmpAF:TAttrsField;
    tmpFS:PFieldSelectOption;
    id1,id2:RTFP_ID;
begin
  vFieldSelectOptions:=TFieldSelectOptions.Create;
  with vFieldSelectOptions do
    try
      id1:=ListView_AttrsCompare.Items[0].SubItems[0];
      id2:=ListView_AttrsCompare.Items[0].SubItems[1];
      for ListViewIndex:=0 to ListView_AttrsCompare.Items.Count-1 do
        begin
          tmpAF:=TAttrsField(ListView_AttrsCompare.Items[ListViewIndex].Data);
          if tmpAF=nil then continue;
          getmem(tmpFS,sizeof(TFieldSelectOption));
          tmpFS^.field:=tmpAF;
          case ListView_AttrsCompare.Items[ListViewIndex].SubItems[2] of
            '主要属性':tmpFS^.select_mode:=fsmMain;
            '次要属性':tmpFS^.select_mode:=fsmVice;
            '文本追加':tmpFS^.select_mode:=fsmBoth;
            '都不保留':tmpFS^.select_mode:=fsmNone;
          end;
          Add(tmpFS);
        end;
      CurrentRTFP.MergePaper(id1,id2,vFieldSelectOptions);
    finally
      while Count>0 do
        begin
          freemem(Items[0],sizeof(TFieldSelectOption));
          Delete(0);
        end;
      Free;
    end;

end;

procedure TFormRepeatedChecker.Button_ApplyAllClick(Sender: TObject);
var index:integer;
    tmpProc:TNotifyEvent;
begin
  if ShowMsgYesNoAll('批量合并','请再三确认是否合并左栏所有重复项。')<>'Yes' then exit;

  FormDesktop.ShowWaitForm:=false;
  AllState.Enable;
  tmpProc:=CurrentRTFP.onChange;
  CurrentRTFP.onChange:=nil;
  Enabled:=false;

  index:=0;
  while index<ListBox_RepeatedPIDPair.Items.Count do
    begin
      ListBox_RepeatedPIDPair.ItemIndex:=index;
      Button_ApplyCombinationClick(Button_ApplyCombination);
      inc(index);
    end;

  Enabled:=true;
  CurrentRTFP.onChange:=tmpProc;
  FormDesktop.ShowWaitForm:=true;
  AllState.Disable;
  CurrentRTFP.RecordChange;

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

procedure TFormRepeatedChecker.FormCreate(Sender: TObject);
begin
  if Self.Height>Screen.Height then Self.Height:=trunc(Screen.Height*0.8);
  if Self.Width>Screen.Width then Self.Height:=trunc(Screen.Width*0.8);
end;

procedure TFormRepeatedChecker.FormShow(Sender: TObject);
begin
  ListView_AttrsCompare.Clear;
end;

procedure TFormRepeatedChecker.ListBox_RepeatedPIDPairSelectionChange(
  Sender: TObject; User: boolean);
var SelPair,id1,id2,v1,v2,bo:string;
    b1,b2:boolean;
    index:integer;
    tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
begin
  index:=ListBox_RepeatedPIDPair.ItemIndex;
  if index<0 then exit;
  SelPair:=ListBox_RepeatedPIDPair.Items[index];
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
        if v1<>v2 then ListView_AttrsCompare.Items[index].SubItems.Add('x')
        else ListView_AttrsCompare.Items[index].SubItems.Add(' ');
      end;
  ListView_AttrsCompare.Column[0].Width:=160;
  ListView_AttrsCompare.Column[1].Width:=450;
  ListView_AttrsCompare.Column[2].Width:=450;
  ListView_AttrsCompare.Column[3].Width:=120;
  ListView_AttrsCompare.Column[3].Width:=60;
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

