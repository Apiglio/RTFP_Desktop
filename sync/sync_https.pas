unit sync_https;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fphttpclient, sslsockets, SAX_HTML, DOM_HTML, DOM;

function ReadWebsiteMeta(url:string;out title,author,keywords,description:string):boolean;unimplemented;

implementation

function ReadWebsiteMeta(url:string;out title,author,keywords,description:string):boolean;
var html_stream:TMemoryStream;
    html_object:THTMLDocument;
    html_head,html_meta,html_attr:TDOMNode;
    head_count,head_index:integer;
procedure AppendIfNotEmpty(segment:string; var target:string; split:string=',');
begin
  if segment='' then exit;
  if target<>'' then target:=target+split;
  target:=target+segment;
end;

begin
  result:=false;
  title:='';
  author:='';
  keywords:='';
  description:='';
  html_object:=nil;
  html_stream:=TMemoryStream.Create;
  with TFPHTTPClient.Create(nil) do try
    AllowRedirect:=true;
    AddHeader('User-Agent','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36');
    Get(url,html_stream);
    html_stream.Position:=0;
    //https://www.fuzhou.gov.cn/zfxxgkzl/szfbmjxsqxxgk/szfbmxxgk/fzsrmzfbgt/zfxxgkml/xzfggzhgfxwj_2570/202404/t20240423_4813255.htm
    //这个网址不能解析
    //网页解析需要考虑charset
    ReadHTMLFile(html_object,html_stream);
  finally
    Free;
    html_stream.Free;
  end;
  if html_object<>nil then begin
    //title:=html_object.Title;
    html_head:=html_object.FirstChild.FirstChild;
    head_count:=html_head.ChildNodes.Count;
    head_index:=0;
    while head_index<head_count do begin
      html_meta:=html_head.ChildNodes[head_index];
      case html_meta.NodeName of
        'meta':begin
          html_attr:=html_meta.Attributes.GetNamedItem('name');
          if html_attr<>nil then case lowercase(html_attr.TextContent) of
            'description':AppendIfNotEmpty(html_meta.Attributes.GetNamedItem('content').TextContent,description,#13#10);
            'author':AppendIfNotEmpty(html_meta.Attributes.GetNamedItem('content').TextContent,author,',');
            'keywords':AppendIfNotEmpty(html_meta.Attributes.GetNamedItem('content').TextContent,keywords,',');
            'og:title':AppendIfNotEmpty(html_meta.Attributes.GetNamedItem('og:title').TextContent,title,' ');
          end;
        end;
        'title':AppendIfNotEmpty(html_meta.TextContent,title,' ');
      end;
      inc(head_index);
    end;
    html_object.Free;
  end;
  result:=true;
end;

end.

