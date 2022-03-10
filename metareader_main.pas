unit metareader_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Windows,
  rtfp_pdfium, rtfp_pdfobj, LazUTF8;

type

  { TForm_MetaReader }

  TForm_MetaReader = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    Procedure CheckPdf(filename:string);
  public

  end;

var
  Form_MetaReader: TForm_MetaReader;

implementation
uses {RTFP_definition, }rtfp_constants;

{$R *.lfm}

function PDFCheck(filename:string):boolean;//存在严重的内存泄漏问题
var tmpPdf:pointer;
    tmpPage:pointer;
    stmp:string;
    PdfMeta:TPdfMeta;

    function GetMeta(tag:pchar):string;
    var pc:pwidechar;
        wchar:array[0..255]of widechar;
        len:uint64;
        ustr:unicodeString;
    begin
      pc:=@wchar[0];
      len:=248;
      len:=FPDF_GetMetaText(tmpPdf,tag,pc,len);
      ustr:=StrPas(pc);
      result:=UTF16ToUTF8(ustr);
    end;

begin
  result:=false;
  PdfMeta:=TPdfMeta.Create;
  FPDF_InitLibrary;

  tmpPdf:=FPDF_LoadDocument(pchar(UTF8toWinCP(filename)),'');

  if tmpPdf <> nil then with PdfMeta do begin
    tmpPage:=FPDF_LoadPage(tmpPdf,0);
    if tmpPage <> nil then with FileData do begin
      PageCount:=FPDF_GetPageCount(tmpPdf);
      PageHeight:=FPDF_GetPageHeight(tmpPage);
      PageWidth:=FPDF_GetPageWidth(tmpPage);
      //
      FPDF_ClosePage(tmpPage);
    end;
    for stmp in DocInfo.list do begin
      pFields['DocInfo:'+stmp]^:=GetMeta(pchar(stmp));
    end;
    for stmp in Dublin.list do begin
      pFields['DCMI:'+stmp]^:=GetMeta(pchar('dc:'+stmp));
    end;
    {
    for stmp in Ext.list do begin
      pFields['Ext:'+stmp]^:=GetMeta(pchar('prism:'+stmp));
    end;
    }
    pFields['Ext:doi']^:=GetMeta(pchar('prism:doi'));
    if pFields['Ext:doi']^='' then pFields['Ext:doi']^:=GetMeta(pchar('doi'));
    pFields['Ext:versionIdentifier']^:=GetMeta(pchar('prism:versionIdentifier'));
    pFields['Ext:lpage']^:=GetMeta(pchar('lpage'));
    pFields['Ext:fpage']^:=GetMeta(pchar('fpage'));

    //jav:journal_article_version

    further.Add('none');

    //FPDF_CloseDocument(tmpPdf);//为啥就是内存错误呢
  end;

  PdfMeta.SaveToFile('MetaData.swap');

  FPDF_DestroyLibrary;
  PdfMeta.Free;

  result:=true;
end;


function PDFView(filename:string;page:uint64;dc:HDC):boolean;//存在严重的内存泄漏问题
var tmpPdf:pointer;
    tmpPage:pointer;
    stmp:string;


begin
  result:=false;
  FPDF_InitLibrary;

  tmpPdf:=FPDF_LoadDocument(pchar(UTF8toWinCP(filename)),'');

  if tmpPdf <> nil then begin
    tmpPage:=FPDF_LoadPage(tmpPdf,page);
    if tmpPage <> nil then begin
      FPDF_RenderPage(dc,tmpPage,0,0,
                      trunc(FPDF_GetPageWidth(tmpPage)),
                      trunc(FPDF_GetPageHeight(tmpPage)),
                      0,0);
      FPDF_ClosePage(tmpPage);
    end;

    //FPDF_CloseDocument(tmpPdf);//为啥就是内存错误呢
  end;

  FPDF_DestroyLibrary;

  result:=true;
end;


{ TForm_MetaReader }

procedure TForm_MetaReader.FormCreate(Sender: TObject);
var success,retry:boolean;
begin
  Hide;
  if ParamCount < 2 then halt;

  success:=false;
  retry:=true;
  If FileExists('MetaData.swap') then repeat
    success:=DeleteFile('MetaData.swap');
    if not success then begin
      case MessageDlg('错误','MetaData.swap被占用，是否重试？',mtConfirmation,[mbRetry,mbCancel],0) of
        //rnmbRetry:;
        rnmbCancel:retry:=false;
      end;
    end;
  until success or (not retry);

  case lowercase(ParamStr(1)) of
    'meta':CheckPdf(ParamStr(2));
    'view':if ParamCount>=4 then PDFView(ParamStr(2),StrToInt(ParamStr(3)),HDC(StrToInt(ParamStr(4))));//??????要这样搞吗
  end;


  If FileExists('MetaData.wait') then DeleteFile('MetaData.wait');
  //Close;
  Halt;

end;

Procedure TForm_MetaReader.CheckPdf(filename:string);
begin
  PDFCheck(filename);
end;

end.

