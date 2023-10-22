unit rtfp_pdfobj;

{$mode objfpc}{$H+}

interface

uses
  {$ifdef WINDOWS}
  rtfp_pdfium, Windows,
  {$endif}
  Classes, SysUtils, Dialogs, LazUTF8;

const
  META_COMMA_REPLACE='&_comma_';

type

  TPdfMeta=class
    DocInfo:record
      list:TStringList;
      Title,Author,Subject,Keywords,Creator,Producer,CreationDate,ModDate:string;
      Trapped:string;//name???
    end;
    Dublin:record
      list:TStringList;
      aTitle:string;
      aCreator:string;
      aDescription:string;
      aPublisher:string;
      aContributor:string;
      aDate:string;
      aType:string;
      aFormat:string;
      aIdentifier:string;
      aSource:string;
      aLanguage:string;
      aRelation:string;
      aCoverage:string;
      aRights:string;
    end;
    FileData:record
      PageCount:int32;
      PageHeight,PageWidth:double;
    end;
    Ext:record
      list:TStringList;
      DOI:string;
      lPage,fPage:string;
      versionIdentifier:string;
    end;
    further:TStringList;

  protected
    function GetStringPtrByName(index:string):pstring;
  public
    property pFields[index:string]:pstring read GetStringPtrByName;
  public
    function ToString:string;override;
    procedure LoadFromFile(filename:string);
    procedure SaveToFile(filename:string);
    procedure Clear;
  public
    constructor Create;
    destructor Destroy;override;

  end;

  TLastPdfData=TPdfMeta;


  TRTFP_PDF=class
    //FMem:TMemoryStream;
    FMem:TFileStream;
    FMeta:TPdfMeta;
    FFileName:string;
    FHash:string;
    FSize:uint64;
    {$ifdef WINDOWS}
    fdoc:FPDF_DOCUMENT;
    fpage:FPDF_PAGE;
    {$endif}

  private
    function CalcMeta:boolean;

  public
    property Hash:string read FHash;
    property Size:uint64 read FSize write FSize;
    property Meta:TPdfMeta read FMeta;

  public
    function FileEqual(buf:pbyte;buflen:uint64):boolean;
    procedure CopyTo(filename:string);
    procedure DeleteRealFile;//在loadpdf之后用于删除FFileName路径中的文件
    {$ifdef WINDOWS}
    procedure ShowPage(dc:HDC;page:uint64);
    {$endif}
  public
    constructor Create(AOwner:TComponent;FileName:string);
    destructor Destroy;override;
    class function CalcHash(AStream:TStream;out read_count:integer):string;
  end;


implementation
uses math;

class function TRTFP_PDF.CalcHash(AStream:TStream;out read_count:integer):string;
var index:byte;
    byt:byte;
    arr:array [0..238] of byte;
    skip_byte:byte;
begin
  read_count:=0;
  for index:=0 to 238 do arr[index]:=0;
  with AStream do
    begin
      //2MiB以内不跳过
      skip_byte:=Size div $200000;
      if skip_byte<1 then skip_byte:=1
      else skip_byte:=1+round(exp(ln(2)*math.ceil(ln(skip_byte)/ln(2))));

      if Size<$20000000 then begin
        //256MiB以内的按原本的方法跳转扫描
        index:=0;
        Position:=0;
        while Position<Size do begin
          byt:=ReadByte;
          inc(read_count);
          arr[index]:=arr[index]+byt;
          inc(index);
          if index>238 then index:=0;
          Seek(byt mod skip_byte,soFromCurrent);
        end;
      end else begin
        //256MiB以上的按开始的非零位作为初始值扫描
        index:=0;
        Position:=0;
        while Position<Size do begin
          byt:=ReadByte;
          inc(read_count);
          if byt<>0 then begin
            arr[index]:=byt;
            inc(index);
            if index>239 then break;
          end;
          Seek(1,soFromCurrent);
        end;
        for index:=0 to 238 do begin
          Seek(Size * index div 239, soFromBeginning);
          Seek(arr[index],soFromCurrent);
          if Position>=Size then break;
          byt:=ReadByte;
          inc(read_count);
          arr[index]:=arr[index]+byt;
        end;
      end;
    end;
  result:='';
  for index:=0 to 238 do
    begin
      arr[index]:=arr[index] and $3f;
      if (arr[index] and $30 = $30) then
        arr[index]:=arr[index] and $bf
      else
        arr[index]:=arr[index] or $40;
      result:=result+chr(arr[index]);
    end;
end;

constructor TRTFP_PDF.Create(AOwner:TComponent;FileName:string);
var rc:integer;
begin
  inherited Create;
  FHash:='';
  FSize:=0;
  {$ifdef WINDOWS}
  fdoc:=nil;
  fpage:=nil;
  {$endif}
  FMeta:=TLastPdfData.Create;
  FFileName:=FileName;
  if FileExists(FileName) then begin
    FMem:=TFileStream.Create(FFileName,fmOpenRead);
    FSize:=FMem.Size;
    FHash:=TRTFP_PDF.CalcHash(FMem,rc);
    CalcMeta;
  end;
end;

destructor TRTFP_PDF.Destroy;
begin
  FMem.Free;
  FMeta.Free;
  inherited Destroy;
end;

function TRTFP_PDF.CalcMeta:boolean;
var a:file of byte;
    localpath:string;
begin
  result:=false;
  {$ifdef WINDOWS}
  localpath:=ExtractFilePath(ParamStr(0));
  //{
  if not FileExists(localpath+'RTFP_MetaReader.exe') then begin
    MessageDlg('未找到RTFP_MetaReader.exe','元数据获取失败！',mtWarning,[mbIgnore],0);
    exit;
  end;
  //}//很奇怪，调试可以用，直接打开运行不行
  AssignFile(a,'MetaData.wait');
  rewrite(a);
  closeFile(a);
  WinExec(pchar({localpath+}'RTFP_MetaReader.exe meta "'+UTF8ToWinCP(FFilename)+'"'),SW_Hide);
  repeat
    //这里可以增加一个取消窗口
    //sleep(100);
  until not FileExists('MetaData.wait');
  FMeta.LoadFromFile('MetaData.swap');
  DeleteFile('MetaData.swap');
  result:=true;
  {$endif}
end;


function TRTFP_PDF.FileEqual(buf:pbyte;buflen:uint64):boolean;
var index:uint64;
begin
  result:=false;
  FMem.Position:=0;
  index:=0;
  if FSize <> buflen then exit;
  while index < FSize do begin
    if index+7 < FSize then begin
      if FMem.ReadQWord <> puint64(buf+index)^ then exit;
      inc(index,8);
    end else begin
      if FMem.ReadByte <> pbyte(buf+index)^ then exit;
      inc(index);
    end;
  end;
  result:=true;
end;

procedure TRTFP_PDF.CopyTo(filename:string);
var f:TFileStream;
begin
  try
    f:=TFileStream.Create(filename,fmOpenWrite);
    f.Position:=0;
    f.CopyFrom(FMem,FMem.Size);
  finally
    f.Free;
  end;
end;

procedure TRTFP_PDF.DeleteRealFile;
var f:file of byte;
begin
  assignfile(f,UTF8ToWinCP(FFilename));
  erase(f);
end;
{$ifdef WINDOWS}
procedure TRTFP_PDF.ShowPage(dc:HDC;page:uint64);
var a:file of byte;
begin
  AssignFile(a,'MetaData.wait');
  rewrite(a);
  closeFile(a);
  WinExec(pchar(GetCurrentDir+'\RTFP_MetaReader.exe view "'+UTF8ToWinCP(FFilename)+'" '+IntToStr(page)+' '+IntToStr(dc)),SW_Hide);
  repeat
    //这里可以增加一个取消窗口
    //sleep(100);
  until not FileExists('MetaData.wait');
end;
{$endif}

{ TPdfMeta }

function TPdfMeta.GetStringPtrByName(index:string):pstring;
begin
  result:=nil;
  case index of
    'DocInfo:Title':result:=@Self.DocInfo.Title;
    'DocInfo:Author':result:=@Self.DocInfo.Author;
    'DocInfo:Subject':result:=@Self.DocInfo.Subject;
    'DocInfo:Keywords':result:=@Self.DocInfo.Keywords;
    'DocInfo:Creator':result:=@Self.DocInfo.Creator;
    'DocInfo:Producer':result:=@Self.DocInfo.Producer;
    'DocInfo:CreationDate':result:=@Self.DocInfo.CreationDate;
    'DocInfo:ModDate':result:=@Self.DocInfo.ModDate;
    'DocInfo:Trapped':result:=@Self.DocInfo.Trapped;

    'DCMI:Title':result:=@Self.Dublin.aTitle;
    'DCMI:Creator':result:=@Self.Dublin.aCreator;
    'DCMI:Description':result:=@Self.Dublin.aDescription;
    'DCMI:Publisher':result:=@Self.Dublin.aPublisher;
    'DCMI:Contributor':result:=@Self.Dublin.aContributor;
    'DCMI:Date':result:=@Self.Dublin.aDate;
    'DCMI:Type':result:=@Self.Dublin.aType;
    'DCMI:Format':result:=@Self.Dublin.aFormat;
    'DCMI:Identifier':result:=@Self.Dublin.aIdentifier;
    'DCMI:Source':result:=@Self.Dublin.aSource;
    'DCMI:Language':result:=@Self.Dublin.aLanguage;
    'DCMI:Relation':result:=@Self.Dublin.aRelation;
    'DCMI:Coverage':result:=@Self.Dublin.aCoverage;
    'DCMI:Rights':result:=@Self.Dublin.aRights;

    //'FileData:PageCount':result:=@Self.FileData;
    //'FileData:PageHeight':result:=@Self.FileData;
    //'FileData:PageWidth':result:=@Self.FileData;

    'Ext:doi':result:=@Self.Ext.DOI;
    'Ext:versionIdentifier':result:=@Self.Ext.versionIdentifier;
    'Ext:fpage':result:=@Self.Ext.fPage;
    'Ext:lpage':result:=@Self.Ext.lPage;

    else assert(false,'无效的pdf元数据字段')
  end;
end;

procedure TPdfMeta.Clear;
begin
  with DocInfo do begin
    Title:='';
    Author:='';
    Subject:='';
    Keywords:='';
    Creator:='';
    Producer:='';
    CreationDate:='';
    ModDate:='';
    Trapped:='';
  end;
  with Dublin do begin
    aTitle:='';
    aCreator:='';
    aDescription:='';
    aPublisher:='';
    aContributor:='';
    aDate:='';
    aType:='';
    aFormat:='';
    aIdentifier:='';
    aSource:='';
    aLanguage:='';
    aRelation:='';
    aCoverage:='';
    aRights:='';
  end;
  with FileData do begin
    PageCount:=0;
    PageHeight:=0;
    PageWidth:=0;
  end;
  with Ext do begin
    DOI:='';
    lPage:='';
    fPage:='';
    versionIdentifier:='';
  end;
  further.Clear;
end;

function TPdfMeta.ToString:string;
var stmp:string;
begin
  result:='';
  result:=result+'DocInfo>'+#13#10;
  for stmp in DocInfo.list do
    begin
      result:=result+' '+stmp+':'+pFields['DocInfo:'+stmp]^+#13#10;
    end;
  result:=result+#13#10;
  result:=result+'DCMI>'+#13#10;
  for stmp in Dublin.list do
    begin
      result:=result+' '+stmp+':'+pFields['DCMI:'+stmp]^+#13#10;
    end;
  result:=result+#13#10;
  result:=result+'Ext>'+#13#10;
  for stmp in Ext.list do
    begin
      result:=result+' '+stmp+':'+pFields['Ext:'+stmp]^+#13#10;
    end;
  result:=result+#13#10;
  result:=result+'FileData>'+#13#10;
  with FileData do begin
    result:=result+' PageCount:'+IntToStr(PageCount)+#13#10;
    result:=result+' Width:'+FloatToStr(PageWidth)+#13#10;
    result:=result+' Height:'+FloatToStr(PageHeight)+#13#10;
  end;
  result:=result+#13#10;
  result:=result+'Further>'+#13#10;
  for stmp in further do
    begin
      result:=result+' '+stmp+#13#10;
    end;
end;

procedure TPdfMeta.LoadFromFile(filename:string);
var stmp:string;
    ss:TStringList;
    index:integer;
begin
  ss:=TStringList.Create;
  ss.LoadFromFile(filename);
  index:=0;

  for stmp in DocInfo.list do
    begin
      pFields['DocInfo:'+stmp]^:=ss[index];
      inc(index);
    end;
  for stmp in Dublin.list do
    begin
      pFields['DCMI:'+stmp]^:=ss[index];
      inc(index);
    end;
  for stmp in Ext.list do
    begin
      pFields['Ext:'+stmp]^:=ss[index];
      inc(index);
    end;
  with FileData do begin
    try PageCount:=StrToInt(ss[index]) except PageCount:=-1; end;
    inc(index);
    try PageWidth:=StrToFloat(ss[index]) except PageWidth:=-1; end;
    inc(index);
    try PageHeight:=StrToFloat(ss[index]) except PageHeight:=-1; end;
    inc(index);
  end;
  further.CommaText:=StringReplace(ss[index],META_COMMA_REPLACE,',',[rfReplaceAll]);
  //inc(index);
  ss.Free;
end;

procedure TPdfMeta.SaveToFile(filename:string);
var stmp:string;
    ss:TStringList;
begin
  ss:=TStringList.Create;
  for stmp in DocInfo.list do
    begin
      ss.add(pFields['DocInfo:'+stmp]^);
    end;
  for stmp in Dublin.list do
    begin
      ss.add(pFields['DCMI:'+stmp]^);
    end;
  for stmp in Ext.list do
    begin
      ss.add(pFields['Ext:'+stmp]^);
    end;
  with FileData do begin
    ss.add(IntToStr(PageCount));
    ss.add(FloatToStr(PageWidth));
    ss.add(FloatToStr(PageHeight));
  end;
  ss.add(StringReplace(further.CommaText,',',META_COMMA_REPLACE,[rfReplaceAll]));
  ss.SaveToFile(filename);
  ss.Free;
end;

constructor TPdfMeta.Create;
begin
  inherited Create;
  DocInfo.list:=TStringList.Create;
  Dublin.list:=TStringList.Create;
  Ext.list:=TStringList.Create;

  further:=TStringList.Create;

  DocInfo.list.Add('Title');
  DocInfo.list.Add('Author');
  DocInfo.list.Add('Subject');
  DocInfo.list.Add('Keywords');
  DocInfo.list.Add('Creator');
  DocInfo.list.Add('Producer');
  DocInfo.list.Add('CreationDate');
  DocInfo.list.Add('ModDate');
  //DocInfo.list.Add('Trapped');

  Dublin.list.add('Title');
  Dublin.list.add('Creator');
  Dublin.list.add('Description');
  Dublin.list.add('Publisher');
  Dublin.list.add('Contributor');
  Dublin.list.add('Date');
  Dublin.list.add('Type');
  Dublin.list.add('Format');
  Dublin.list.add('Identifier');
  Dublin.list.add('Source');
  Dublin.list.add('Language');
  Dublin.list.add('Relation');
  Dublin.list.add('Coverage');
  Dublin.list.add('Rights');

  Ext.list.Add('doi');
  Ext.list.Add('versionIdentifier');
  Ext.list.Add('lpage');
  Ext.list.Add('fpage');


end;

destructor TPdfMeta.Destroy;
begin
  further.Free;

  DocInfo.list.Free;
  Dublin.list.Free;
  Ext.list.Free;
  inherited Destroy;
end;






{
initialization
  FPDF_InitLibrary;

finalization
  FPDF_DestroyLibrary;
}
end.

