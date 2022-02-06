unit form_report_tool;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TFormReportTool }

  TFormReportTool = class(TForm)
    Button_Report: TButton;
    Button_ImportStyle: TButton;
    Button_ExportStyle: TButton;
    Label_Choosing: TLabel;
    ListBox_List: TListBox;
    Memo_tip: TMemo;
    SaveDialog_report: TSaveDialog;
    procedure Button_ReportClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListBox_ListDblClick(Sender: TObject);
    procedure ListBox_ListSelectionChange(Sender: TObject; User: boolean);
  private

  public

  end;

var
  FormReportTool: TFormReportTool;

implementation
uses rtfp_main, rtfp_dialog, rtfp_field, rtfp_class, rtfp_constants,
     RTFP_definition, rtfp_misc, db, dbf;

{$R *.lfm}

{ TFormReportTool }

procedure TFormReportTool.ListBox_ListSelectionChange(Sender: TObject;
  User: boolean);
begin
  if ListBox_List.ItemIndex<0 then exit;
  Memo_tip.Clear;
  case ListBox_List.Items[ListBox_List.ItemIndex] of
    '工程基础信息':Memo_tip.Lines.Add('导出当前工程的基本信息，包括：工程标题等基本信息，文献记录、字段和分类的统计信息。');
    '导出字段数据':Memo_tip.Lines.Add('导出所有文献选定的字段数据，在对话框中选择需要导出的字段。字段数据之间用制表符分隔。');
    '导出当前主表':Memo_tip.Lines.Add('导出文献节点标签页中显示的表格数据，字段数据之间用制表符分隔。');
    '字段数据统计':Memo_tip.Lines.Add('统计具体某个字段中的数据出现次数，半角分号区分为不同的统计项。主要用于关键词、作者和作者单位字段的统计，也可以用于其他类似格式的字段。');
    '分类统计':Memo_tip.Lines.Add('导出不同分类组所包含文献的数量统计及其文献明细。');
    '属性统计':Memo_tip.Lines.Add('导出各个属性组的记录使用情况及其字段的类型。');
  end;
end;

procedure ExportFile_ProjectInfo(str:TStrings);
var acc:integer;
    tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
    tmpKL:TKlass;
begin
  with str do begin
    with CurrentRTFP do begin;
      Add('工程标题　　　：'+Title);
      Add('创建用户　　　：'+User);
      Add('创建日期　　　：'+Tag['创建日期']);
      Add('修改日期　　　：'+Tag['修改日期']);
      Add('最后保存版本　：'+Version);
      Add(' ');
      Add('总文献数量　　：'+IntToStr(CountPaper));
      Add('备份文献数量　：'+IntToStr(CountBackupPaper));
      Add('关联文献数量　：'+IntToStr(CountExternPaper));
      Add('链接文献数量　：'+IntToStr(CountWeblnkPaper));
      Add(' ');
      Add('属性组数量　　：'+IntToStr(FieldList.Count));
      for tmpAG in FieldList do
        begin
          acc:=0;
          for tmpAF in tmpAG.FieldList do
            if (tmpAF.FieldName=_Col_PID_) or (tmpAF.FieldName=_Col_OID_) then else inc(acc);
          Add(#9+tmpAG.Name+#9+'('+IntToStr(acc)+'个字段)');
        end;
      Add('分类组数量　　：'+IntToStr(KlassList.Count));
      for tmpKL in KlassList do Add(#9+tmpKL.Name);
    end;
  end;
end;
procedure ExportFile_FieldsGrid(str:TStrings);
type TAttrsFieldName=packed record
       gn,fn:string[64];
     end;
var tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
    vList,vOut,PIDs:TStrings;
    stmp,gname,fname,CRLF_deleter:string;
    selected:TList;
    len,poss:integer;
    tmpRec:Pointer;
begin
  with str do begin
    with CurrentRTFP do begin
      vList:=TStringList.Create;
      vOut:=TStringList.Create;
      PIDs:=TStringList.Create;
      selected:=TList.Create;
      try
        for tmpAG in FieldList do begin
          for tmpAF in tmpAG.FieldList do begin
            vList.Add(tmpAG.Name+'|'+tmpAF.FieldName);
          end;
        end;
        ShowMsgCheckList('导出字段','选择导出的字段：',vList,vOut,false);
        for stmp in vOut do
          begin
            len:=length(stmp);
            if len<=0 then continue;
            poss:=pos('|',stmp);
            gname:=stmp;
            fname:=stmp;
            System.delete(gname,poss,len);
            System.delete(fname,1,poss);
            tmpRec:=getmem(sizeof(TAttrsFieldName));
            with TAttrsFieldName(tmpRec^) do
              begin
                gn:=gname;
                fn:=fname;
              end;
            selected.Add(tmpRec);
          end;
        GetPIDList(PIDs);
        for {PID}stmp in PIDs do
          begin
            {rec}gname:='['+{PID}stmp+']';
            for tmpRec in selected do with TAttrsFieldName(tmpRec^) do
              begin
                CRLF_deleter:=ReadFieldAsString(fn,gn,stmp,[]);
                CRLF_deleter:=StringReplace(CRLF_deleter,#13,'',[rfReplaceAll]);
                CRLF_deleter:=StringReplace(CRLF_deleter,#10,'|',[rfReplaceAll]);
                {rec}gname:={rec}gname+#9+CRLF_deleter;
              end;
            Add({rec}gname);
          end;
        for tmpRec in selected do freemem(tmpRec,sizeof(TAttrsFieldName));
      finally
        vList.Free;
        vOut.Free;
        PIDs.Free;
        selected.Free;
      end;
    end;
  end;
end;
procedure ExportFile_CurrentGrid(str:TStrings);
var bm:TBookMark;
    tmpF:TField;
    stmp:string;
begin
  with str do begin
    with CurrentRTFP do begin
      with PaperDS do begin
        FormDesktop.DataSource_Main.DataSet:=nil;
        bm:=Bookmark;
        BeginUpdate;
        First;
        while not EOF do
          begin
            stmp:='';
            for tmpF in Fields do
              begin
                stmp:=stmp+tmpF.AsString+#9;
              end;
            Add(stmp);
            Next;
          end;
        GotoBookmark(bm);
        EndUpdate;
        FormDesktop.DataSource_Main.DataSet:=PaperDS;
      end;
    end;
  end;

end;

function FuncListSortCompare(Item1,Item2:Pointer):Integer;
begin
  result:=TStrHashItem(Item2).Count-TStrHashItem(Item1).Count;
end;

procedure ExportFile_FieldStat(str:TStrings);
var tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
    vList,PIDs:TStrings;
    stmp,GroupData,StatData,StatDataClip:string;
    stat_attrs,stat_field,group_attrs,group_field:string;
    len,poss:integer;
    StatStrList:TStringList;
    groupped:boolean;

    function NamedHash(key_name:string):TStrHash;
    var key_index:integer;
        tmpHash:TStrHash;
    begin
      if not StatStrList.Find(key_name,key_index) then
        begin
          tmpHash:=TStrHash.Create;
          key_index:=StatStrList.AddObject(key_name,tmpHash);
        end;
      result:=StatStrList.Objects[key_index] as TStrHash;
    end;
    procedure ClearStrList;
    begin
      with StatStrList do
        while Count>0 do
          begin
            (Objects[0] as TStrHash).Free;
            Delete(0);
          end;
    end;

begin
  with str do begin
    with CurrentRTFP do begin
      vList:=TStringList.Create;
      PIDs:=TStringList.Create;
      StatStrList:=TStringList.Create;
      StatStrList.Sorted:=true;
      try
        for tmpAG in FieldList do begin
          for tmpAF in tmpAG.FieldList do begin
            vList.Add(tmpAG.Name+'|'+tmpAF.FieldName);
          end;
        end;
        stat_attrs:=ShowMsgList('导出字段','选择统计的字段：',vList);
        poss:=pos('|',stat_attrs);
        if (stat_attrs='')or(poss<=0) then begin ShowMsgOK('导出报表','导出已取消。');exit;end
        else begin
          stat_field:=stat_attrs;
          len:=length(stat_attrs);
          System.delete(stat_attrs,poss,len);
          System.delete(stat_field,1,poss);
          case ShowMsgYesNoAll('导出字段统计','是否设置分组字段？') of
            'Yes':
              begin
                group_attrs:=ShowMsgList('导出字段','选择分组字段：',vList);
                if group_attrs<>'' then begin
                  poss:=pos('|',group_attrs);
                  group_field:=group_attrs;
                  len:=length(group_attrs);
                  System.delete(group_attrs,poss,len);
                  System.delete(group_field,1,poss);
                end;
              end;
          end;
          if group_attrs='' then group_field:='';
        end;
        groupped:=group_attrs<>'';
        GroupData:='';//groupped为假时一直是这个值
        GetPIDList(PIDs);
        for {PID}stmp in PIDs do
          begin
            if Groupped then GroupData:=ReadFieldAsString(group_field,group_attrs,{PID}stmp,[]);
            StatData:=ReadFieldAsString(stat_field,stat_attrs,{PID}stmp,[]);
            repeat
              poss:=pos(';',StatData);
              len:=length(StatData);
              if poss>0 then begin
                StatDataClip:=copy(StatData,1,poss-1);
                NamedHash(GroupData).NamedItemAddCount(StatDataClip);
                System.delete(StatData,1,poss);
              end;
            until poss<=0;
            NamedHash(GroupData).NamedItemAddCount(StatData);
          end;
        if groupped then
          begin
            for stmp in StatStrList do
              begin
                Add('分组："'+stmp+'"');
                poss:=0;
                StatStrList.Find(stmp,len);
                with StatStrList.Objects[len] as TStrHash do
                  while poss<Count do
                    begin
                      Sort(@FuncListSortCompare);
                      with TStrHashItem(Items[poss]) do str.Add(#9+'"'+Name+'"'+#9+IntToStr(Count));
                      inc(poss);
                    end;
              end;
          end
        else
          begin
            poss:=0;
            with StatStrList.Objects[0] as TStrHash do
              while poss<Count do
                begin
                  Sort(@FuncListSortCompare);
                  with TStrHashItem(Items[poss]) do str.Add('"'+Name+'"'+#9+IntToStr(Count));
                  inc(poss);
                end;
          end;
        Add('');
      finally
        vList.Free;
        PIDs.Free;
        StatStrList.Free;
      end;
    end;
  end;
end;



procedure ExportFile_KlassInfo(str:TStrings);
var tmpKL:TKlass;
    PID:RTFP_ID;
    vTitle,filename:string;
    acc:integer;
begin
  with str do begin
    with CurrentRTFP do begin
      for tmpKL in KlassList do
        begin
           Add('分类名称：'+tmpKL.Name);
           Add('分类路径：'+tmpKL.FullPath);
           with tmpKL.Dbf do
             begin
               if not Active then Open;
               First;
               acc:=0;
               while not EOF do
                 begin
                   inc(acc);
                   Next;
                 end;
               Add('包含文件：'+IntToStr(acc)+'个');
               First;
               while not EOF do
                 begin
                   PID:=FieldByName(_Col_PID_).AsString;
                   vTitle:=ReadFieldAsString(_Col_basic_Title_,_Attrs_Basic_,PID,[]);
                   //filename:=ReadFieldAsString(_Col_Paper_FileName_,'',PID,[]);
                   Add(#9+'['+PID+']'+vTitle);
                   Next;
                 end;
             end;
           Add(' ');
        end;
    end;
  end;
end;
procedure ExportFile_FieldInfo(str:TStrings);
var tmpAG:TAttrsGroup;
    tmpAF:TAttrsField;
    acc:integer;
begin
  with str do begin
    with CurrentRTFP do begin
      for tmpAG in FieldList do begin
        Add('属性组名称：'+tmpAG.Name);
        Add('字段列数量：'+IntToStr(tmpAG.FieldList.Count)+'个');
        with tmpAG.Dbf do
          begin
            if not Active then Open;
            First;
            acc:=0;
            while not EOF do
              begin
                inc(acc);
                Next;
              end;
            Add('属性组记录：'+IntToStr(acc)+'条');
          end;
        for tmpAF in tmpAG.FieldList do begin
          Add(#9+'字段“'+tmpAF.FieldName+'”('+tmpAF.FieldDef.FieldClass.ClassName+')');
        end;
        Add(' ');
      end;
    end;
  end;
end;



procedure TFormReportTool.Button_ReportClick(Sender: TObject);
var filepath,filename:string;
    str:TStringList;
begin
  if not assigned(CurrentRTFP) then exit;
  if not CurrentRTFP.IsOpen then exit;
  if CurrentRTFP.IsChanged then
    begin
      if ShowMsgYesNoAll('导出报表','导出报表之前需要保存工程，是否保存？')<>'Yes' then exit;
      CurrentRTFP.Save;
    end;
  if ListBox_List.ItemIndex<0 then
    begin
      ShowMsgOK('警告','请选择一种报表再导出。');
      exit;
    end;
  filepath:=CurrentRTFP.CurrentPathFull+'export\';
  ForceDirectories(filepath);
  with SaveDialog_report do begin
    InitialDir:=filepath;
    Title:='导出报表';
    FileName:='';
  end;
  if SaveDialog_report.Execute then filename:=SaveDialog_report.FileName else exit;
  str:=TStringList.Create;
  try
    case ListBox_List.Items[ListBox_List.ItemIndex] of
      '工程基础信息':ExportFile_ProjectInfo(str);
      '导出字段数据':ExportFile_FieldsGrid(str);
      '导出当前主表':ExportFile_CurrentGrid(str);
      '字段数据统计':ExportFile_FieldStat(str);
      '分类统计':ExportFile_KlassInfo(str);
      '属性统计':ExportFile_FieldInfo(str);
    end;
    if str.Count>0 then str.SaveToFile(filename);
  finally
    str.Free;
  end;
  TRTFP.OpenFile(filename);
  ModalResult:=mrOK;
end;

procedure TFormReportTool.FormCreate(Sender: TObject);
begin
  if Self.Height>Screen.Height then Self.Height:=trunc(Screen.Height*0.8);
  if Self.Width>Screen.Width then Self.Height:=trunc(Screen.Width*0.8);
end;

procedure TFormReportTool.ListBox_ListDblClick(Sender: TObject);
begin
  Button_Report.onClick(Button_Report);
end;

end.

