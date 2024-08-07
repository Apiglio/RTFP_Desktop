unit rtfp_cite;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, RegExpr;

type

  TCiteField = class
  public
    AttrsGroupName:string;
    AttrsFieldName:string;
  public
    constructor Create(AGroupName,AFieldName:string);
  end;

  TCiteImporter = class
  public
    FirstField:string;
    LastField:string;
    SeparatedDelimiter:string;
    SeparatedFields:TStringList;
    FirstOnlyFields:TStringList;
    OverwriteFields:TStringList;
    AppendFields:TStringList;
    KeyRegExpr:string;
    ValueRegExpr:string;
  public
    procedure ImportToProject(ACite:TStrings;AProject:TObject;PID:string);
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TCiteExporter = class
  public
    //
  public
    function ExportFromProject(AProject:TObject;PID:string):string;
  public
    constructor Create;
    destructor Destroy; override;
  end;

var
  CiteImport_RIS:TCiteImporter;
  CiteImport_EStudy:TCiteImporter;
  CiteImport_EndNote:TCiteImporter;
  CiteImport_RefWork:TCiteImporter;


implementation
uses RTFP_definition, rtfp_field, rtfp_type, rtfp_constants;

{ TCiteField }

constructor TCiteField.Create(AGroupName,AFieldName:string);
begin
  AttrsGroupName:=AGroupName;
  AttrsFieldName:=AFieldName;
end;

{ TCiteImporter }

procedure TCiteImporter.ImportToProject(ACite:TStrings;AProject:TObject;PID:string);
type
  TAppendMode = (amUnknown ,amFirstOnly, amOverwirte, amAppend, amSeparated);
var line,key,value,AGN,AFN,lastAGN,lastAFN,origin_content:string;
    project:TRTFP;
    reg:TRegExpr;
    repeated:TStringList;
    find_index,tmp_index:integer;
    append_mode:TAppendMode;
begin
  project:=AProject as TRTFP;
  reg:=TRegExpr.Create;
  repeated:=TStringList.Create;
  repeated.Sorted:=true;
  try
    lastAGN:='';
    lastAFN:='';
    append_mode:=amUnknown;
    for line in ACite do begin
      reg.Expression:=KeyRegExpr;
      if reg.Exec(line) then begin
        key:=reg.Match[1];
        reg.Expression:=ValueRegExpr;
        if reg.Exec(line) then begin
          value:=reg.Match[1];
        end else begin
          value:='';
        end;
      end else begin
        key:='';
        value:=line;
      end;
      value:=TrimLeft(value);
      if FirstOnlyFields.Find(key,find_index) then begin
        with TCiteField(FirstOnlyFields.Objects[find_index]) do begin
          AFN:=AttrsFieldName;
          AGN:=AttrsGroupName;
        end;
        if project.FindField(AFN,AGN)<>nil then begin
          if not repeated.Find(key,tmp_index) then begin
            project.EditFieldAsString(AFN,AGN,PID,value,[aeForceEditIfTypeDismatch, aeCreateIfNoField]);
            //如果首个有效字段没有读取过，就存入值
          end;
        end;
        append_mode:=amFirstOnly;
      end else if AppendFields.Find(key,find_index) then begin
        with TCiteField(AppendFields.Objects[find_index]) do begin
          AFN:=AttrsFieldName;
          AGN:=AttrsGroupName;
        end;
        if project.FindField(AFN,AGN)<>nil then begin
          if not repeated.Find(key,tmp_index) then begin
            project.EditFieldAsString(AFN,AGN,PID,'',[aeForceEditIfTypeDismatch, aeCreateIfNoField]);
            //如果追加型字段没有读取过，就初始化
          end;
          origin_content:=project.ReadFieldAsString(AFN,AGN,PID,[aeForceEditIfTypeDismatch]);
          project.EditFieldAsString(AFN,AGN,PID,origin_content+value,[aeForceEditIfTypeDismatch]);
        end;
        append_mode:=amAppend;
      end else if SeparatedFields.Find(key,find_index) then begin
        with TCiteField(SeparatedFields.Objects[find_index]) do begin
          AFN:=AttrsFieldName;
          AGN:=AttrsGroupName;
        end;
        if project.FindField(AFN,AGN)<>nil then begin
          if not repeated.Find(key,tmp_index) then begin
            project.EditFieldAsString(AFN,AGN,PID,'',[aeForceEditIfTypeDismatch, aeCreateIfNoField]);
            //如果分隔型字段没有读取过，就初始化
          end;
          origin_content:=project.ReadFieldAsString(AFN,AGN,PID,[aeForceEditIfTypeDismatch]);
          project.EditFieldAsString(AFN,AGN,PID,origin_content+value+SeparatedDelimiter,[aeForceEditIfTypeDismatch]);
        end;
        append_mode:=amSeparated;
      end else if OverwriteFields.Find(key,find_index) then begin
        with TCiteField(OverwriteFields.Objects[find_index]) do begin
          AFN:=AttrsFieldName;
          AGN:=AttrsGroupName;
        end;
        if project.FindField(AFN,AGN)<>nil then begin
          project.EditFieldAsString(AFN,AGN,PID,value,[aeForceEditIfTypeDismatch, aeCreateIfNoField]);
        end;
        append_mode:=amOverwirte;
      end else begin
        //key不符合任何一个设置
        if key='' then begin
          //如果是分隔型或追加型，按照先前的字段进行追加
          case append_mode of
            amAppend:begin
              origin_content:=project.ReadFieldAsString(lastAFN,lastAGN,PID,[aeForceEditIfTypeDismatch]);
              project.EditFieldAsString(lastAFN,lastAGN,PID,origin_content+value,[aeForceEditIfTypeDismatch]);
            end;
            amSeparated:begin
              origin_content:=project.ReadFieldAsString(lastAFN,lastAGN,PID,[aeForceEditIfTypeDismatch]);
              project.EditFieldAsString(lastAFN,lastAGN,PID,origin_content+value+SeparatedDelimiter,[aeForceEditIfTypeDismatch]);
            end;
          end;
        end else begin
          //意外的字段
        end;
      end;
      lastAGN:=AGN;
      lastAFN:=AFN;
      repeated.Add(key);
    end;
  finally
    reg.Free;
    repeated.Free;
  end;

end;

constructor TCiteImporter.Create;
begin
  inherited Create;
  SeparatedFields:=TStringList.Create;
  SeparatedFields.Sorted:=true;
  FirstOnlyFields:=TStringList.Create;
  FirstOnlyFields.Sorted:=true;
  OverwriteFields:=TStringList.Create;
  OverwriteFields.Sorted:=true;
  AppendFields:=TStringList.Create;
  AppendFields.Sorted:=true;

end;

destructor TCiteImporter.Destroy;
begin
  with SeparatedFields do begin
    while Count>0 do begin
      Objects[0].Free;
      Delete(0);
    end;
    Free;
  end;
  with FirstOnlyFields do begin
    while Count>0 do begin
      Objects[0].Free;
      Delete(0);
    end;
    Free;
  end;
  with OverwriteFields do begin
    while Count>0 do begin
      Objects[0].Free;
      Delete(0);
    end;
    Free;
  end;
  with AppendFields do begin
    while Count>0 do begin
      Objects[0].Free;
      Delete(0);
    end;
    Free;
  end;
  inherited Destroy;
end;

{ TCiteExporter }

function TCiteExporter.ExportFromProject(AProject:TObject;PID:string):string;unimplemented;
begin
  result:='';
end;

constructor TCiteExporter.Create;unimplemented;
begin
  inherited Create;
end;

destructor TCiteExporter.Destroy;unimplemented;
begin
  inherited Destroy;
end;


initialization
  CiteImport_RIS:=TCiteImporter.Create;
  with CiteImport_RIS do begin
    FirstField:='TY';
    LastField:='ER';
    SeparatedDelimiter:=';';
    SeparatedFields.AddObject('AU',TCiteField.Create(_Attrs_Basic_,_Col_basic_Author_));
    SeparatedFields.AddObject('A1',TCiteField.Create(_Attrs_Basic_,_Col_basic_Author_));
    SeparatedFields.AddObject('A2',TCiteField.Create(_Attrs_Basic_,_Col_basic_Author_));
    SeparatedFields.AddObject('A3',TCiteField.Create(_Attrs_Basic_,_Col_basic_Author_));
    SeparatedFields.AddObject('A4',TCiteField.Create(_Attrs_Basic_,_Col_basic_Author_));
    SeparatedFields.AddObject('A5',TCiteField.Create(_Attrs_Basic_,_Col_basic_Author_));
    SeparatedFields.AddObject('A6',TCiteField.Create(_Attrs_Basic_,_Col_basic_Author_));
    SeparatedFields.AddObject('A7',TCiteField.Create(_Attrs_Basic_,_Col_basic_Author_));
    SeparatedFields.AddObject('A8',TCiteField.Create(_Attrs_Basic_,_Col_basic_Author_));
    SeparatedFields.AddObject('KW',TCiteField.Create(_Attrs_Basic_,_Col_basic_Keyword_));
    FirstOnlyFields.AddObject('TY',TCiteField.Create(_Attrs_Basic_,_Col_basic_RefType_));
    FirstOnlyFields.AddObject('DA',TCiteField.Create(_Attrs_Basic_,_Col_basic_PubTime_));
    FirstOnlyFields.AddObject('TI',TCiteField.Create(_Attrs_Basic_,_Col_basic_Title_));
    FirstOnlyFields.AddObject('T1',TCiteField.Create(_Attrs_Basic_,_Col_basic_Title_));
    FirstOnlyFields.AddObject('JO',TCiteField.Create(_Attrs_Basic_,_Col_basic_Source_));
    FirstOnlyFields.AddObject('JF',TCiteField.Create(_Attrs_Basic_,_Col_basic_Source_));
    FirstOnlyFields.AddObject('T2',TCiteField.Create(_Attrs_Basic_,_Col_basic_Source_));
    FirstOnlyFields.AddObject('PY',TCiteField.Create(_Attrs_Basic_,_Col_basic_Year_));
    FirstOnlyFields.AddObject('VL',TCiteField.Create(_Attrs_Basic_,_Col_basic_Volume_));
    FirstOnlyFields.AddObject('IS',TCiteField.Create(_Attrs_Basic_,_Col_basic_Issue_));
    FirstOnlyFields.AddObject('SN',TCiteField.Create(_Attrs_Basic_,_Col_basic_doi_));
    FirstOnlyFields.AddObject('DO',TCiteField.Create(_Attrs_Basic_,_Col_basic_ISBN_ISSN_));
    FirstOnlyFields.AddObject('UR',TCiteField.Create(_Attrs_Basic_,_Col_basic_Link_));
    FirstOnlyFields.AddObject('DB',TCiteField.Create(_Attrs_Basic_,_Col_basic_DataProv_));
    FirstOnlyFields.AddObject('DP',TCiteField.Create(_Attrs_Basic_,_Col_basic_DataProv_));
    //OverwriteFields.AddObject('',TCiteField.Create('',''));
    AppendFields.AddObject('AB',TCiteField.Create(_Attrs_Basic_,_Col_basic_Summary_));
    //SP EP 这两个起止页码没办法
    KeyRegExpr:='^[\S\s]{6}';
    ValueRegExpr:='(?<=^[\S\s]{6})[^\n]*';
  end;

  CiteImport_EStudy:=TCiteImporter.Create;
  CiteImport_EndNote:=TCiteImporter.Create;
  CiteImport_RefWork:=TCiteImporter.Create;

finalization
  CiteImport_RIS.Free;
  CiteImport_EStudy.Free;
  CiteImport_EndNote.Free;
  CiteImport_RefWork.Free;

end.

