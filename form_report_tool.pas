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
    procedure ListBox_ListSelectionChange(Sender: TObject; User: boolean);
  private

  public

  end;

var
  FormReportTool: TFormReportTool;

implementation
uses rtfp_main, rtfp_dialog, rtfp_field, rtfp_class, rtfp_constants,
     RTFP_definition, db, dbf;

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
    stmp,gname,fname:string;
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
              {rec}gname:={rec}gname+#9+ReadFieldAsString(fn,gn,stmp,[]);
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
procedure ExportFile_KlassInfo(str:TStrings);
var tmpKL:TKlass;
    PID:RTFP_ID;
    vTitle,filename:string;
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
               Add('包含文件：'+IntToStr(RecordCount)+'个');
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
begin
  with str do begin
    with CurrentRTFP do begin
      for tmpAG in FieldList do begin
        Add('属性组名称：'+tmpAG.Name);
        Add('字段列数量：'+IntToStr(tmpAG.FieldList.Count)+'个');
        with tmpAG.Dbf do
          begin
            if not Active then Open;
            Add('属性组记录：'+IntToStr(RecordCount)+'条');
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

end.

