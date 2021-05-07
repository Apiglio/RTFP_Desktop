//翻译的pdfium的C源码，注释请翻原代码

unit rtfp_pdfium;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Windows;


const

  { fpdfview.h }

  // PDF object types
  FPDF_OBJECT_UNKNOWN=0;
  FPDF_OBJECT_BOOLEAN=1;
  FPDF_OBJECT_NUMBER=2;
  FPDF_OBJECT_STRING=3;
  FPDF_OBJECT_NAME=4;
  FPDF_OBJECT_ARRAY=5;
  FPDF_OBJECT_DICTIONARY=6;
  FPDF_OBJECT_STREAM=7;
  FPDF_OBJECT_NULLOBJ=8;
  FPDF_OBJECT_REFERENCE=9;



  { fpdf_doc.h }

  PDFACTION_UNSUPPORTED=0;
  PDFACTION_GOTO=1;
  PDFACTION_REMOTEGOTO=2;
  PDFACTION_URI=3;
  PDFACTION_LAUNCH=4;


type


  PDF_PV = pointer;//void*
  PDF_PVC = pointer;//void const*



  { fpdfview.h }

  //PDFtypes
  FPDF_ACTION=PDF_PV;
  FPDF_ANNOTATION=PDF_PV;
  FPDF_ATTACHMENT=PDF_PV;
  FPDF_BITMAP=PDF_PV;
  FPDF_BOOKMARK=PDF_PV;
  FPDF_CLIPPATH=PDF_PV;
  FPDF_DEST=PDF_PV;
  FPDF_DOCUMENT=PDF_PV;
  FPDF_FONT=PDF_PV;
  FPDF_LINK=PDF_PV;
  FPDF_PAGE=PDF_PV;
  FPDF_PAGELINK=PDF_PV;
  FPDF_PAGEOBJECT=PDF_PV;
  FPDF_PAGERANGE=PDF_PV;
  FPDF_RECORDER=PDF_PV;
  FPDF_SCHHANDLE=PDF_PV;
  FPDF_STRUCTELEMENT=PDF_PV;
  FPDF_STRUCTTREE=PDF_PV;
  FPDF_TEXTPAGE=PDF_PV;
  FPDF_PATHSEGMENT=PDF_PVC;

  {$ifdef PDF_ENABLE_XFA}
  FPDF_STRINGHANDLE=PDF_PV;
  FPDF_WIDGET=PDF_PV;
  {$endif}

  // Basic data types
  FPDF_BOOL=int32;
  FPDF_ERROR=int32;
  FPDF_DWORD=uint64;
  FS_FLOAT=single;

  {$ifdef PDF_ENABLE_XFA}
  FPDF_LPVOID=PDF_PV;
  FPDF_LPCVOID=PDF_PVC;
  FPDF_LPCSTR=PDF_PVC;
  FPDF_RESULT=int32;
  {$endif}

  // Duplex types
  FPDF_DUPLEXTYPE = (DuplexUndefined=0,Simplex,DuplexFlipShortEdge,DuplexFlipLongEdge);

  // String types
  FPDF_WCHAR=byte;//unsigned short
  FPDF_LPCBYTE=pbyte;//unsigned char const* (应该是 var byte)

  FPDF_BYTESTRING=pchar;

  FPDF_WIDESTRING=pbyte;

  {$ifdef PDF_ENABLE_XFA}
  // Structure for a byte string.
  // Note, a byte string commonly means a UTF-16LE formated string.
  FPDF_BSTR = record
    str:pchar;// String buffer.
    len:int32;// Length of the string, in bytes.
  end;
  {$endif}

  FPDF_STRING=pchar;

  _FS_MATRIX_ = record
    a,b,c,d,e,f:single;
  end;
  FS_MATRIX=_FS_MATRIX_;
  _FS_RECTF_ = record
    bottom,left,right,top:single;
  end;
  FS_LPRECTF=^_FS_RECTF_;
  FS_RECTF=_FS_RECTF_;
  FS_LPCRECTF=^FS_RECTF;// Const Pointer to FS_RECTF structure.
  FPDF_ANNOTATION_SUBTYPE=int32;// Annotation subtype.
  FPDF_OBJECT_TYPE=int32;// Dictionary value types.

  {$ifdef FPDFSDK_EXPORTS}
    {$ifdef _WIN32}
      {$defineFPDF_EXPORT__declspec(dllexport)}
      {$defineFPDF_CALLCONV__stdcall}
    {$else}
      {$defineFPDF_EXPORT__attribute__((visibility("default")))}
      {$defineFPDF_CALLCONV}
    {$endif}
  {$else}
    {$ifdef _WIN32}
      {$defineFPDF_EXPORT__declspec(dllimport)}
      {$defineFPDF_CALLCONV__stdcall}
    {$else}
      {$defineFPDF_EXPORT}
      {$defineFPDF_CALLCONV}
    {$endif}
  {$endif}



  //自定义文件访问结构
  FPDF_FILEACCESS=record
    m_FileLen:uint64;//文件字节数
    m_GetBlock:function(param:PDF_PV;position:uint64;pBuf:pchar;size:uint64):int32;
    m_Param:PDF_PV;
  end;
  PFPDF_FILEACCESS=^FPDF_FILEACCESS;
  FPDF_LIBRARY_CONFIG = record
    m_pIsolate:PDF_PV;
    m_pUserFontPaths:array of pchar;//sizeof = 8
    m_v8EmbedderSlot:uint32;
    version:int32;
  end;
  PFPDF_LIBRARY_CONFIG=^FPDF_LIBRARY_CONFIG;

  { fpdf_doc.h }
  _FS_QUADPOINTSF = record
    x1,y1,x2,y2,x3,y3,x4,y4:FS_FLOAT;
  end;
  FS_QUADPOINTSF=_FS_QUADPOINTSF;



  { dataavail.h }

  FPDF_AVAIL=int32;
  size_t=uint32;

  PFX_FILEAVAIL=^FX_FILEAVAIL;
  FX_FILEAVAIL = record
    version:int32;// Version number of the interface. Must be 1.
    IsDataAvail:function(pThis:PFX_FILEAVAIL;offset,size:size_t):FPDF_BOOL;
  end;


  PFX_DOWNLOADHINTS=^FX_DOWNLOADHINTS;
  FX_DOWNLOADHINTS = record
    version:int32;// Version number of the interface. Must be 1.
    AddSegment:procedure(pThis:PFX_DOWNLOADHINTS;offset,size:size_t);
  end;

  { fpdfview.h }

  function FPDFBitmap_Create(width,height,alpha:int32):FPDF_BITMAP;stdcall;external 'pdfium.dll';
  function FPDFBitmap_CreateEx(width,height,format:int32;first_scan:pointer;stride:int32):FPDF_BITMAP;stdcall;external 'pdfium.dll';
  procedure FPDFBitmap_Destroy(bitmap:FPDF_BITMAP);stdcall;external 'pdfium.dll';
  procedure FPDFBitmap_FillRect(bitmap:FPDF_BITMAP;left,top,width,height:int32;color:FPDF_DWORD);stdcall;external 'pdfium.dll';
  function FPDFBitmap_GetBuffer(bitmap:FPDF_BITMAP):pointer;stdcall;external 'pdfium.dll';
  function FPDFBitmap_GetFormat(bitmap:FPDF_BITMAP):int32;stdcall;external 'pdfium.dll';
  function FPDFBitmap_GetHeight(bitmap:FPDF_BITMAP):int32;stdcall;external 'pdfium.dll';
  function FPDFBitmap_GetStride(bitmap:FPDF_BITMAP):int32;stdcall;external 'pdfium.dll';
  function FPDFBitmap_GetWidth(bitmap:FPDF_BITMAP):int32;stdcall;external 'pdfium.dll';

  procedure FPDF_CloseDocument(var doc:FPDF_DOCUMENT);stdcall;external 'pdfium.dll';
  procedure FPDF_ClosePage(page:FPDF_PAGE);stdcall;external 'pdfium.dll';
  function FPDF_CountNamedDests(document:FPDF_DOCUMENT):FPDF_DWORD;stdcall;external 'pdfium.dll';
  procedure FPDF_DestroyLibrary;stdcall;external 'pdfium.dll';
  procedure FPDF_DeviceToPage(page:FPDF_PAGE;start_x,start_y,size_x,size_y,rotate,device_x,device_y:int32;var page_x,page_y:double);stdcall;external 'pdfium.dll';
  function FPDF_GetDocPermissions(document:FPDF_DOCUMENT):uint64;stdcall;external 'pdfium.dll';
  function FPDF_GetFileVersion(doc:FPDF_DOCUMENT;var fileVersion:int32):FPDF_BOOL;stdcall;external 'pdfium.dll';
  function FPDF_GetLastError:uint64;stdcall;external 'pdfium.dll';
  function FPDF_GetNamedDest(document:FPDF_DOCUMENT;index:int32;buffer:pointer;var buflen:int64):FPDF_DEST;stdcall;external 'pdfium.dll';
  function FPDF_GetNamedDestByName(document:FPDF_DOCUMENT;name:FPDF_BYTESTRING):FPDF_DEST;stdcall;external 'pdfium.dll';
  function FPDF_GetPageCount(document:FPDF_DOCUMENT):int32;stdcall;external 'pdfium.dll';
  function FPDF_GetPageHeight(page:FPDF_PAGE):double;stdcall;external 'pdfium.dll';
  function FPDF_GetPageSizeByIndex(document:FPDF_DOCUMENT;page_index:int32;var width,height:double):int32;stdcall;external 'pdfium.dll';
  function FPDF_GetPageWidth(page:FPDF_PAGE):double;stdcall;external 'pdfium.dll';
  function FPDF_GetSecurityHandlerRevision(document:FPDF_DOCUMENT):int32;stdcall;external 'pdfium.dll';
  procedure FPDF_InitLibrary;stdcall;external 'pdfium.dll';
  procedure FPDF_InitLibraryWithConfig(const config:PFPDF_LIBRARY_CONFIG);stdcall;external 'pdfium.dll';
  function FPDF_LoadCustomDocument(pFileAccess:PFPDF_FILEACCESS;password:FPDF_BYTESTRING):FPDF_DOCUMENT;stdcall;external 'pdfium.dll';
  function FPDF_LoadDocument(file_path:pchar;password:pchar):FPDF_DOCUMENT;stdcall;external 'pdfium.dll';
  function FPDF_LoadMemDocument(data_buf:pbyte;size:int32;password:pchar):FPDF_DOCUMENT;stdcall;external 'pdfium.dll';
  function FPDF_LoadPage(document:FPDF_DOCUMENT;page_index:int32):FPDF_PAGE;stdcall;external 'pdfium.dll';
  procedure FPDF_PageToDevice(page:FPDF_PAGE;start_x,start_y,size_x,size_y,rotate:int32;page_x,page_y:double;var device_x,device_y:int32);stdcall;external 'pdfium.dll';
  procedure FPDF_RenderPage(dc:HDC;page:FPDF_PAGE;start_x,start_y,size_x,size_y,rotate,flags:int32);stdcall;external 'pdfium.dll';
  procedure FPDF_RenderPageBitmap(bitmap:FPDF_BITMAP;page:FPDF_PAGE;start_x,start_y,size_x,size_y,rotate,flags:int32);stdcall;external 'pdfium.dll';
  procedure FPDF_RenderPageBitmapWithMatrix(bitmap:FPDF_BITMAP;page:FPDF_PAGE;var matrix:FS_MATRIX;var clipping:FS_RECTF;flags:int32);stdcall;external 'pdfium.dll';
  function FPDF_SetPrintMode(mode:int32):FPDF_BOOL;stdcall;external 'pdfium.dll';
  function FPDF_SetPrintPostscriptLevel(postscript_level:int32):FPDF_BOOL;stdcall;external 'pdfium.dll';
  procedure FPDF_SetSandBoxPolicy(policy:FPDF_DWORD;enable:FPDF_BOOL);stdcall;external 'pdfium.dll';

  function FPDF_VIEWERREF_GetDuplex(document:FPDF_DOCUMENT):FPDF_DUPLEXTYPE;stdcall;external 'pdfium.dll';
  function FPDF_VIEWERREF_GetName(document:FPDF_DOCUMENT;key:FPDF_BYTESTRING;buffer:pchar;length:uint64):uint64;stdcall;external 'pdfium.dll';
  function FPDF_VIEWERREF_GetNumCopies(document:FPDF_DOCUMENT):int32;stdcall;external 'pdfium.dll';
  function FPDF_VIEWERREF_GetPrintPageRange(document:FPDF_DOCUMENT):FPDF_PAGERANGE;stdcall;external 'pdfium.dll';
  function FPDF_VIEWERREF_GetPrintScaling(document:FPDF_DOCUMENT):FPDF_BOOL;stdcall;external 'pdfium.dll';



  { fpdf_doc.h }
  function FPDFBookmark_GetFirstChild(document:FPDF_DOCUMENT;bookmark:FPDF_BOOKMARK):FPDF_BOOKMARK;stdcall;external 'pdfium.dll';
  function FPDFBookmark_GetNextSibling(document:FPDF_DOCUMENT;bookmark:FPDF_BOOKMARK):FPDF_BOOKMARK;stdcall;external 'pdfium.dll';
  function FPDFBookmark_GetTitle(bookmark:FPDF_BOOKMARK;buffer:PDF_PV;buflen:uint64):uint64;stdcall;external 'pdfium.dll';
  function FPDFBookmark_Find(document:FPDF_DOCUMENT;title:FPDF_WIDESTRING):FPDF_BOOKMARK;stdcall;external 'pdfium.dll';
  function FPDFBookmark_GetDest(document:FPDF_DOCUMENT;bookmark:FPDF_BOOKMARK):FPDF_DEST;stdcall;external 'pdfium.dll';
  function FPDFBookmark_GetAction(bookmark:FPDF_BOOKMARK):FPDF_ACTION;stdcall;external 'pdfium.dll';
  function FPDFAction_GetType(action:FPDF_ACTION):uint64;stdcall;external 'pdfium.dll';
  function FPDFAction_GetDest(document:FPDF_DOCUMENT;action:FPDF_ACTION):FPDF_DEST;stdcall;external 'pdfium.dll';
  function FPDFAction_GetFilePath(action:FPDF_ACTION;buffer:PDF_PV;buflen:uint64):uint64;stdcall;external 'pdfium.dll';
  function FPDFAction_GetURIPath(document:FPDF_DOCUMENT;action:FPDF_ACTION;buffer:PDF_PV;buflen:uint64):uint64;stdcall;external 'pdfium.dll';
  function FPDFDest_GetPageIndex(document:FPDF_DOCUMENT;dest:FPDF_DEST):uint64;stdcall;external 'pdfium.dll';
  function FPDFDest_GetLocationInPage(dest:FPDF_DEST;var hasXCoord,hasYCoord,hasZoom:FPDF_BOOL;var x,y,zoom:FS_FLOAT):FPDF_BOOL;stdcall;external 'pdfium.dll';
  function FPDFLink_GetLinkAtPoint(page:FPDF_PAGE;x,y:double):FPDF_LINK;stdcall;external 'pdfium.dll';
  function FPDFLink_GetLinkZOrderAtPoint(page:FPDF_PAGE;x,y:double):int32;stdcall;external 'pdfium.dll';
  function FPDFLink_GetDest(document:FPDF_DOCUMENT;link:FPDF_LINK):FPDF_DEST;stdcall;external 'pdfium.dll';
  function FPDFLink_GetAction(link:FPDF_LINK):FPDF_ACTION;stdcall;external 'pdfium.dll';
  function FPDFLink_Enumerate(page:FPDF_PAGE;var startPos:int32;var linkAnnot:FPDF_LINK):FPDF_BOOL;stdcall;external 'pdfium.dll';
  function FPDFLink_GetAnnotRect(linkAnnot:FPDF_LINK;var rect:FS_RECTF):FPDF_BOOL;stdcall;external 'pdfium.dll';
  function FPDFLink_CountQuadPoints(linkAnnot:FPDF_LINK):int32;stdcall;external 'pdfium.dll';
  function FPDFLink_GetQuadPoints(linkAnnot:FPDF_LINK;quadIndex:int32;var quadPoints:FS_QUADPOINTSF):FPDF_BOOL;stdcall;external 'pdfium.dll';
  function FPDF_GetMetaText(document:FPDF_DOCUMENT;tag:FPDF_BYTESTRING;buffer:pwidechar;var buflen:uint64):uint64;stdcall;external 'pdfium.dll';
  function FPDF_GetPageLabel(document:FPDF_DOCUMENT;page_index:int32;buffer:PDF_PV;buflen:uint64):uint64;stdcall;external 'pdfium.dll';

  //not finished


  { dataavail.h }

  function FPDFAvail_Create(var file_avail:FX_FILEAVAIL;var afile:FPDF_FILEACCESS):FPDF_AVAIL;stdcall;external 'pdfium.dll';
  procedure FPDFAvail_Destroy(avail:FPDF_AVAIL);stdcall;external 'pdfium.dll';
  function FPDFAvail_IsDocAvail(avail:FPDF_AVAIL;var hints:FX_DOWNLOADHINTS):int32;stdcall;external 'pdfium.dll';
  function FPDFAvail_GetDocument(avail:FPDF_AVAIL;password:FPDF_BYTESTRING):FPDF_DOCUMENT;stdcall;external 'pdfium.dll';
  function FPDFAvail_GetFirstPageNum(doc:FPDF_DOCUMENT):int32;stdcall;external 'pdfium.dll';
  function FPDFAvail_IsPageAvail(avail:FPDF_AVAIL;page_index:int32;var hints:FX_DOWNLOADHINTS):int32;stdcall;external 'pdfium.dll';
  function FPDFAvail_IsFormAvail(avail:FPDF_AVAIL;var hints:FX_DOWNLOADHINTS):int32;stdcall;external 'pdfium.dll';
  function FPDFAvail_IsLinearized(avail:FPDF_AVAIL):int32;stdcall;external 'pdfium.dll';



implementation


initialization

//FPDF_InitLibrary;

end.

