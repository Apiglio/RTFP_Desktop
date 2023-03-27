//与引注格式有关的转换代码
//文献类型需要一个树结构了，尽可能兼容不同引文格式


function TRTFP.InitBasic(PID:RTFP_ID):TFields;
var AG:TAttrsGroup;
begin
  result:=nil;
  AG:=FindAttrs(_Attrs_Basic_);
  if AG=nil then AG:=AddAttrs(_Attrs_Basic_);
  //CheckBasicFields;
  with AG.Dbf do begin
    if not Active then Open;
    if not LocatePID(AG.Dbf,PID) then
      begin
        assert(false,'不应该找不到才对');
        Append;
        FieldByName(_Col_PID_).AsString:=PID;
        Post;
      end;
    Edit;
    result:=Fields;
  end;
end;

procedure TRTFP.PostBasic;
var AG:TAttrsGroup;
begin
  AG:=FindAttrs(_Attrs_Basic_);
  AG.Dbf.Post;
  AG.Modified:=true;
end;

procedure TRTFP.EditBasic;
var AG:TAttrsGroup;
begin
  AG:=FindAttrs(_Attrs_Basic_);
  AG.Dbf.Edit;
end;

procedure TRTFP.ReEditBasic;
var AG:TAttrsGroup;
begin
  AG:=FindAttrs(_Attrs_Basic_);
  AG.Dbf.Post;
  AG.Dbf.Edit;
end;

function TRTFP.PID_Cite_format(APID:RTFP_ID):string;
var project_id:string;
begin
  project_id:=Tag['引注标识码'];
  if project_id='' then project_id:=Tag['工程标题'];
  if project_id='' then result:=APID else result:=project_id+'_'+APID;
end;

function decodeEStudyRefType(str:string):string;
begin
  case str of
    '1':result:='期刊论文';
    '2':result:='学位论文';
    '3':result:='会议论文';
    '4':result:='报纸';
    '5':result:='专著';
    '6':result:='年鉴';
    '60':result:='专利';
    '61':result:='其他文献';
    '62':result:='标准规范';
    else result:='未知';
  end;
end;

function encodeEStudyRefType(str:string):string;
begin
  case str of
    '期刊论文':result:='1';
    '学位论文':result:='2';
    '会议论文':result:='3';
    '报纸':result:='4';
    '专著':result:='5';
    '年鉴':result:='6';
    '专利':result:='60';
    '其他文献':result:='61';
    '标准规范':result:='62';
    else result:='0';
  end;
end;

function decodeEndNoteRefType(str:string):string;
begin
  case str of
    'Journal Article':result:='期刊论文';
    'Thesis':result:='学位论文';
    'Conference Proceedings':result:='会议论文';
    'Newspaper Article':result:='报纸';
    'Book':result:='专著';
    //'Legal Rule or Regulation':result:='年鉴';
    'Patent':result:='专利';
    'Other Article':result:='其他文献';
    'Legal Rule or Regulation':result:='标准规范';
    else result:='未知';
  end;
end;

function encodeEndNoteRefType(str:string):string;
begin
  case str of
    '期刊论文':result:='Journal Article';
    '学位论文':result:='Thesis';
    '会议论文':result:='Conference Proceedings';
    '报纸':result:='Newspaper Article';
    '专著':result:='Book';
    '年鉴':result:='Legal Rule or Regulation';
    '专利':result:='Patent';
    '其他文献':result:='Other Article';
    '标准规范':result:='Legal Rule or Regulation';
    else result:='Unknown';
  end;
end;

function decodeRISRefType(str:string):string;
begin
  case uppercase(str) of
    //'ABST'result:='';     //Abstract
    //'ADVS'result:='';     //Audiovisual material
    //'AGGR'result:='';     //Aggregated Database
    //'ANCIENT'result:='';  //Ancient Text
    //'ART'result:='';      //Art Work
    //'BILL'result:='';     //Bill
    //'BLOG'result:='';     //Blog
    //'BOOK'result:='专著'; //Whole book
    //'CASE'result:='';     //Case
    //'CHAP'result:='专著';     //Book chapter
    //'CHART'result:='';    //Chart
    //'CLSWK'result:='';    //Classical Work
    //'COMP'result:='';     //Computer program
    //'CONF'result:='';     //Conference proceeding
    //'CPAPER'result:='会议论文';   //Conference paper
    //'CTLG'result:='';     //Catalog
    //'DATA'result:='';     //Data file
    //'DBASE'result:='';    //Online Database
    //'DICT'result:='';     //Dictionary
    //'EBOOK'result:='专著';    //Electronic Book
    //'ECHAP'result:='';    //Electronic Book Section
    //'EDBOOK'result:='';   //Edited Book
    //'EJOUR'result:='期刊论文';    //Electronic Article
    //'WEB'result:='';      //Web Page
    //'ENCYC'result:='';    //Encyclopedia
    //'EQUA'result:='';     //Equation
    //'FIGURE'result:='';   //Figure
    //'GEN'result:='';      //Generic
    //'GOVDOC'result:='';   //Government Document
    //'GRANT'result:='';    //Grant
    //'HEAR'result:='';     //Hearing
    //'ICOMM'result:='';    //Internet Communication
    //'INPR'result:='';     //In Press
    //'JFULL'result:='期刊论文';  //Journal (full)
    //'JOUR'result:='期刊论文';   //Journal
    //'LEGAL'result:='标准规范';  //Legal Rule or Regulation
    //'MANSCPT'result:='';  //Manuscript
    //'MAP'result:='舆图';      //Map
    //'MGZN'result:='';     //Magazine article
    //'MPCT'result:='';     //Motion picture
    //'MULTI'result:='';    //Online Multimedia
    //'MUSIC'result:='';    //Music score
    //'NEWS'result:='报纸';     //Newspaper
    //'PAMP'result:='';     //Pamphlet
    //'PAT'result:='专利';      //Patent
    //'PCOMM'result:='';    //Personal communication
    //'RPRT'result:='';     //Report
    //'SER'result:='';      //Serial publication
    //'SLIDE'result:='';    //Slide
    //'SOUND'result:='';    //Sound recording
    //'STAND'result:='标准规范';    //Standard
    //'STAT'result:='';     //Statute
    //'THES'result:='学位论文';     //Thesis/Dissertation
    //'UNBILL'result:='';   //Unenacted Bill
    //'UNPB'result:='';     //Unpublished work
    //'VIDEO'result:='';    //Video recording
    '...............................':;
    else result:=str;
  end;
end;

function encodeRISRefType(str:string):string;
begin
  result:=str;
end;

procedure TRTFP.LoadFromEStudy(PID:RTFP_ID;str:TStrings);
var stmp,header,attr:string;
    poss:integer;
    tmpDate:TDate;
    error_str,sum_temp:string;
    is_last_summary:boolean;
begin
  error_str:=#13#10;
  is_last_summary:=false;
  with InitBasic(PID) do begin
    for stmp in str do begin
      if stmp='' then continue;
      poss:=pos(': ',stmp);
      if poss<=0 then begin
        header:='';
        attr:=stmp;
      end else begin
        header:=stmp;
        attr:=stmp;
        delete(header,poss,length(stmp));
        delete(attr,1,poss+1);
        //if attr='' then continue;
        //这里的本意是为了避免空值覆盖有意义的内容，但是现在考虑到有可能出现摘要开头换行的问题暂时禁用
      end;
      try
        case header of
          'DataType':
            begin
              is_last_summary:=false;
              FieldByName(_Col_basic_RefType_).AsString:=decodeEStudyRefType(attr);
            end;
          'Author-作者','Author-发明人','Source-起草单位':
            begin
              is_last_summary:=false;
              while attr[length(attr)]=';' do
                begin
                  delete(attr,length(attr),1);
                  if attr='' then break;
                end;
              FieldByName(_Col_basic_Author_).AsString:=attr;
            end;
          'Title-题名','Title-正标题','Title-书名','Title-专利名称','Title-中文标准名称':
            begin
              is_last_summary:=false;
              FieldByName(_Col_basic_Title_).AsString:=attr;
            end;
          'Source-刊名','Source-学位授予单位','Source-报纸中文名','Author-发布单位名称','Source-文献来源':
            begin
              is_last_summary:=false;
              FieldByName(_Col_basic_Source_).AsString:=attr;
            end;
          'Year-年','Year-年鉴年份':
            begin
              is_last_summary:=false;
              FieldByName(_Col_basic_Year_).AsString:=attr;
            end;
          'PubTime-出版时间','PubTime-发表时间':
            begin
              is_last_summary:=false;
              {zan}poss:=pos(' ',attr);
              if poss>0 then delete(attr,poss,length(attr));
              try
                TryStrToDate(attr,tmpDate,'YYYYMMDD','-');
              except
              end;
              FieldByName(_Col_basic_PubTime_).AsDateTime:=tmpDate;
            end;
          'Period-期':
            begin
              is_last_summary:=false;
              attr:=StringReplace(attr,'S','-',[rfReplaceAll,rfIgnoreCase]);
              FieldByName(_Col_basic_Issue_).AsString:=attr;
            end;
          'Roll-卷':
            begin
              is_last_summary:=false;
              FieldByName(_Col_basic_Volume_).AsString:=attr;
            end;
          'Keyword-关键词':
            begin
              is_last_summary:=false;
              FieldByName(_Col_basic_Keyword_).AsString:=attr;
            end;
          'Summary-摘要','Summary-快照':
            begin
              is_last_summary:=true;
              FieldByName(_Col_basic_Summary_).AsString:=attr;
            end;
          'PageCount-页数':
            begin
              is_last_summary:=false;
              FieldByName(_Col_basic_PageCount_).AsString:=attr;
            end;
          'Page-页码':
            begin
              is_last_summary:=false;
              FieldByName(_Col_basic_Page_).AsString:=attr;
            end;
          //'SrcDatabase-来源库':FieldByName(_Col_basic_来源库_).AsString:=attr;
          'Organ-机构','Organ-大学','Organ-出版社','文献来源'{专利},'Organ-出版者'{年鉴}:
            begin
              is_last_summary:=false;
              FieldByName(_Col_basic_Organ_).AsString:=attr;
            end;
          'Link-链接':
            begin
              is_last_summary:=false;
              FieldByName(_Col_basic_Link_).AsString:=StringReplace(attr,'&amp;','&',[rfReplaceAll]);
            end;
          'Degree-学位':
            begin
              is_last_summary:=false;
              FieldByName(_Col_basic_Degree_).AsString:=attr;
            end;
          'Teacher-导师','Teacher-申请人':
            begin
              is_last_summary:=false;
              FieldByName(_Col_basic_Teacher_).AsString:=attr;
            end;
          'City-会议地点','City-地址':
            begin
              is_last_summary:=false;
              FieldByName(_Col_basic_City_).AsString:=attr;
            end;
          'Meeting-会议名称':
            begin
              is_last_summary:=false;
              FieldByName(_Col_basic_Meeting_).AsString:=attr;
            end;
          'Notes-标准号':
            begin
              is_last_summary:=false;
              FieldByName(_Col_basic_ISBN_ISSN_).AsString:=attr;
            end
          else if is_last_summary then
            begin
              sum_temp:=FieldByName(_Col_basic_Summary_).AsString;
              FieldByName(_Col_basic_Summary_).AsString:=sum_temp+#13#10+stmp;
            end;
        end;
      except
        error_str:=error_str+'    '+header+#13#10;
      end;
      ReEditBasic;
    end;
  end;
  if error_str<>#13#10 then ShowMsgOKAll('导入错误','以下字段导入时发生错误：'+error_str);
  //这里最好加一个本次不再提示
  PostBasic;
  FieldAndRecordChange;//DataChange;
end;
procedure TRTFP.LoadFromRefWork(PID:RTFP_ID;str:TStrings);
begin
  ShowMsgOK('警告','暂不支持导入RefWork');
end;
procedure TRTFP.LoadFromEndNote(PID:RTFP_ID;str:TStrings);
var stmp,attr:string;
    has_author:boolean;
    reftype:string;
begin
  has_author:=false;
  reftype:='';
  with InitBasic(PID) do begin
    for stmp in str do begin
      if length(stmp)<3 then continue;
      if (stmp[1]<>'%') or (stmp[3]<>' ') then continue;
      attr:=stmp;
      delete(attr,1,3);
      case stmp[2] of
        '0':
          begin
            reftype:=decodeEndNoteRefType(attr);
            FieldByName(_Col_basic_RefType_).AsString:=reftype;
          end;
        'A':
          begin
            attr:=StringReplace(attr,' %A ',';',[rfReplaceAll]);
            if has_author then attr:=FieldByName(_Col_basic_Author_).AsString+';'+attr;
            FieldByName(_Col_basic_Author_).AsString:=attr;
            has_author:=true;
          end;
        '+':FieldByName(_Col_basic_Organ_).AsString:=attr;
        'T':FieldByName(_Col_basic_Title_).AsString:=attr;
        'J','I':FieldByName(_Col_basic_Source_).AsString:=attr;
        'D':
          try
            FieldByName(_Col_basic_Year_).AsString:=attr;
          except
          end;
        'V':case reftype of
              '标准规范':FieldByName(_Col_basic_ISBN_ISSN_).AsString:=attr;
              else
                try
                  FieldByName(_Col_basic_Issue_).AsString:=attr;
                except
                end;
            end;
        'N':
          try
            FieldByName(_Col_basic_Volume_).AsString:=attr;
          except
          end;
        'K':FieldByName(_Col_basic_Keyword_).AsString:=attr;
        'X':FieldByName(_Col_basic_Summary_).AsString:=attr;
        'P':FieldByName(_Col_basic_Page_).AsString:=attr;
        '@':FieldByName(_Col_basic_ISBN_ISSN_).AsString:=attr;
        'L':FieldByName(_Col_basic_CN_).AsString:=attr;
        //'W':FieldByName(_Col_basic_DataProv_).AsString:=attr;
        'Y':FieldByName(_Col_basic_Teacher_).AsString:=attr;
        '9':FieldByName(_Col_basic_Degree_).AsString:=attr;//也指专利类型
        'C':FieldByName(_Col_basic_City_).AsString:=attr;
        'B':FieldByName(_Col_basic_Meeting_).AsString:=attr;
        '?':FieldByName(_Col_basic_Sponsor_).AsString:=attr;
        '8':FieldByName(_Col_basic_PubTime_).AsString:=attr;//专利的发表时间

      end;
      ReEditBasic;
    end;
  end;
  PostBasic;
  FieldAndRecordChange;//DataChange;
end;
procedure TRTFP.LoadFromNoteExpress(PID:RTFP_ID;str:TStrings);
begin
  ShowMsgOK('警告','暂不支持导入NoteExpress');
end;
procedure TRTFP.LoadFromNoteFirst(PID:RTFP_ID;str:TStrings);
begin
  ShowMsgOK('警告','暂不支持导入NoteFirst');
end;
procedure TRTFP.LoadFromRIS(PID:RTFP_ID;str:TStrings);
var stmp,attr:string;
    has_author,has_keyword:boolean;
    tmpDate:TDate;
    page_sp,page_ep:string;
begin
  has_author:=false;
  has_keyword:=false;
  page_sp:='';
  page_ep:='';
  with InitBasic(PID) do begin
    for stmp in str do begin
      if length(stmp)<6 then continue;
      if (stmp[3]<>' ') or (stmp[4]<>' ') or (stmp[5]<>'-') or (stmp[6]<>' ') then continue;
      //有见到只有一个空格的RIS格式，暂不因为特例进行修改了。
      attr:=stmp;
      delete(attr,1,6);
      case uppercase(stmp[1]+stmp[2]) of
        'TY':FieldByName(_Col_basic_RefType_).AsString:=decodeRISRefType(attr);
        'AU','A1','A2','A3','A4','A5','A6','A7','A8':
          begin
            if has_author then attr:=FieldByName(_Col_basic_Author_).AsString+';'+attr;
            FieldByName(_Col_basic_Author_).AsString:=attr;
            has_author:=true;
          end;
        'DA':
          begin
            try
              TryStrToDate(attr,tmpDate,'YYYYMMDD','/');
            except
              //还有这种格式： JUL 29
            end;
            FieldByName(_Col_basic_PubTime_).AsDateTime:=tmpDate;
          end;
        'KW':
          begin
            if has_keyword then attr:=FieldByName(_Col_basic_Keyword_).AsString+';'+attr;
            FieldByName(_Col_basic_Keyword_).AsString:=attr;
            has_keyword:=true;
          end;
        'ER':{do nothing};
        'T1','TI':FieldByName(_Col_basic_Title_).AsString:=attr;
        'JO','JF','T2':FieldByName(_Col_basic_Source_).AsString:=attr;
        'PY':
          try
            FieldByName(_Col_basic_Year_).AsString:=attr;
          except
          end;
        'VL':
          try
            FieldByName(_Col_basic_Volume_).AsString:=attr;
          except
          end;
        'IS':
          try
            FieldByName(_Col_basic_Issue_).AsString:=attr;
          except
          end;
        'AB':FieldByName(_Col_basic_Summary_).AsString:=attr;
        'SN':FieldByName(_Col_basic_ISBN_ISSN_).AsString:=attr;
        'DO':FieldByName(_Col_basic_doi_).AsString:=attr;
        'UR':FieldByName(_Col_basic_Link_).AsString:=attr;
        'DB':FieldByName(_Col_basic_DataProv_).AsString:=attr;
        'DP':FieldByName(_Col_basic_DataProv_).AsString:=attr;
        'SP':page_sp:=attr;
        'EP':page_ep:=attr;
        //'AU':FieldByName(Author Address).AsString:=attr;
        //'AN':FieldByName(Accession Number).AsString:=attr;
        //'AV':FieldByName(Location in Archives).AsString:=attr;
        //'SP':FieldByName(Start Page).AsString:=attr;
        //'EP':FieldByName(End Page).AsString:=attr;
        //'LA':FieldByName(_Col_basic_Language).AsString:=attr;

      end;
      ReEditBasic;
    end;
    if (page_sp<>'') and (page_ep<>'') then begin
      FieldByName(_Col_basic_Page_).AsString:=page_sp+'-'+page_ep;
      ReEditBasic;
    end;
  end;
  PostBasic;
  FieldAndRecordChange;//DataChange;
end;

procedure TRTFP.SaveToEStudy(PID:RTFP_ID;str:TStrings);
begin
  ShowMsgOK('警告','暂不支持导出EStudy');
end;
procedure TRTFP.SaveToRefWork(PID:RTFP_ID;str:TStrings);
begin
  ShowMsgOK('警告','暂不支持导出RefWork');
end;
procedure TRTFP.SaveToEndNote(PID:RTFP_ID;str:TStrings);
var stmp,reftype:string;
    ntmp:integer;
begin
  str.Clear;
  with InitBasic(PID) do begin
    stmp:=FieldByName(_Col_basic_RefType_).AsString;
    if stmp<>'' then str.Add('%0 '+encodeEndNoteRefType(stmp));
    reftype:=stmp;
    stmp:=FieldByName(_Col_basic_Author_).AsString;
    if stmp<>'' then str.Add('%A '+StringReplace(stmp,';',' %A ',[rfReplaceAll]));
    stmp:=FieldByName(_Col_basic_Organ_).AsString;
    if stmp<>'' then str.Add('%+ '+stmp);
    stmp:=FieldByName(_Col_basic_Title_).AsString;
    if stmp<>'' then str.Add('%T '+stmp);

    stmp:=FieldByName(_Col_basic_Source_).AsString;
    if reftype = '学位论文' then begin
      if stmp<>'' then str.Add('%I '+stmp);
    end else begin
      if stmp<>'' then str.Add('%J '+stmp);
    end;

    ntmp:=FieldByName(_Col_basic_Year_).AsInteger;
    if ntmp<>0 then str.Add('%D '+IntToStr(ntmp));
    ntmp:=FieldByName(_Col_basic_Issue_).AsInteger;
    if ntmp<>0 then str.Add('%V '+IntToStr(ntmp));
    ntmp:=FieldByName(_Col_basic_Volume_).AsInteger;
    if ntmp<>0 then str.Add('%N '+IntToStr(ntmp));
    stmp:=FieldByName(_Col_basic_Keyword_).AsString;
    if stmp<>'' then str.Add('%K '+stmp);
    stmp:=FieldByName(_Col_basic_Summary_).AsString;
    if stmp<>'' then str.Add('%X '+stmp);
    stmp:=FieldByName(_Col_basic_Page_).AsString;
    if stmp<>'' then str.Add('%P '+stmp);
    stmp:=FieldByName(_Col_basic_ISBN_ISSN_).AsString;
    if stmp<>'' then str.Add('%@ '+stmp);
    stmp:=FieldByName(_Col_basic_CN_).AsString;
    if stmp<>'' then str.Add('%L '+stmp);
    stmp:=FieldByName(_Col_basic_DataProv_).AsString;
    if stmp<>'' then str.Add('%W '+stmp);
    stmp:=FieldByName(_Col_basic_Teacher_).AsString;
    if stmp<>'' then str.Add('%Y '+stmp);
    stmp:=FieldByName(_Col_basic_Degree_).AsString;
    if stmp<>'' then str.Add('%9 '+stmp);
    stmp:=FieldByName(_Col_basic_City_).AsString;
    if stmp<>'' then str.Add('%C '+stmp);
    stmp:=FieldByName(_Col_basic_Meeting_).AsString;
    if stmp<>'' then str.Add('%B '+stmp);
    stmp:=FieldByName(_Col_basic_Sponsor_).AsString;
    if stmp<>'' then str.Add('%? '+stmp);

  end;
  PostBasic;
end;
procedure TRTFP.SaveToNoteExpress(PID:RTFP_ID;str:TStrings);
begin
  ShowMsgOK('警告','暂不支持导出NoteExpress');
end;
procedure TRTFP.SaveToNoteFirst(PID:RTFP_ID;str:TStrings);
begin
  ShowMsgOK('警告','暂不支持导出NoteFirst');
end;
procedure TRTFP.SaveToRIS(PID:RTFP_ID;str:TStrings);
begin
  ShowMsgOK('警告','暂不支持导出RIS');
end;

procedure TRTFP.SetGBT7714(PID:RTFP_ID;str:string);
begin
  ShowMsgOK('警告','暂不支持导入GB/T 7714');
end;
procedure TRTFP.SetCAJCD(PID:RTFP_ID;str:string);
begin
  ShowMsgOK('警告','暂不支持导入CAJ/CD');
end;
procedure TRTFP.SetMLA(PID:RTFP_ID;str:string);
begin
  ShowMsgOK('警告','暂不支持导入MLA');
end;
procedure TRTFP.SetAPA(PID:RTFP_ID;str:string);
begin
  ShowMsgOK('警告','暂不支持导入APA');
end;
procedure TRTFP.SetChaXin(PID:RTFP_ID;str:string);
begin
  ShowMsgOK('警告','暂不支持导入查新');
end;

function TRTFP.GetGBT7714(PID:RTFP_ID):string;
var stmp:string;
    tmpDateTime:TDateTime;
begin
  //ShowMsgOK('警告','unimplemented');
  result:='';
  with InitBasic(PID) do
    begin
      case FieldByName(_Col_basic_RefType_).AsString of
        '期刊论文':
          begin
            result:='['+PID_Cite_format(PID)+']';
            result:=result+StringReplace(FieldByName(_Col_basic_Author_).AsString,';',',',[rfReplaceAll]);
            result:=result+'.';
            result:=result+FieldByName(_Col_basic_Title_).AsString;
            result:=result+'[J].';
            result:=result+FieldByName(_Col_basic_Source_).AsString;
            result:=result+',';
            result:=result+FieldByName(_Col_basic_Year_).AsString;
            result:=result+',';
            result:=result+FieldByName(_Col_basic_Volume_).AsString;
            result:=result+'(';
            result:=result+StringReplace(FieldByName(_Col_basic_Issue_).AsString,'-','S',[rfReplaceAll]);
            result:=result+'):';
            result:=result+FieldByName(_Col_basic_Page_).AsString;
            result:=result+'.';
          end;
        '学位论文':
          begin
            result:='['+PID_Cite_format(PID)+']';
            result:=result+FieldByName(_Col_basic_Author_).AsString;
            result:=result+'.';
            result:=result+FieldByName(_Col_basic_Title_).AsString;
            result:=result+'[D].';
            result:=result+FieldByName(_Col_basic_Source_).AsString;
            result:=result+',';
            result:=result+FieldByName(_Col_basic_Year_).AsString;
            result:=result+'.';
          end;
        '会议论文':
          begin
            result:='['+PID_Cite_format(PID)+']';
            result:=result+StringReplace(FieldByName(_Col_basic_Author_).AsString,';',',',[rfReplaceAll]);
            result:=result+'. ';
            result:=result+FieldByName(_Col_basic_Title_).AsString;
            result:=result+'[A]. ';
            result:=result+FieldByName(_Col_basic_Sponsor_).AsString;
            result:=result+'.';
            result:=result+FieldByName(_Col_basic_Source_).AsString;
            result:=result+'[C]';
            result:=result+FieldByName(_Col_basic_Sponsor_).AsString;
            result:=result+':';
            result:=result+FieldByName(_Col_basic_Meeting_).AsString;
            result:=result+',';
            result:=result+FieldByName(_Col_basic_Year_).AsString;
            result:=result+':';
            result:=result+FieldByName(_Col_basic_PageCount_).AsString;
            result:=result+'.';
          end;
        '报纸':
          begin
            result:='['+PID_Cite_format(PID)+']';
            result:=result+StringReplace(FieldByName(_Col_basic_Author_).AsString,';',',',[rfReplaceAll]);
            result:=result+'. ';
            result:=result+FieldByName(_Col_basic_Title_).AsString;
            result:=result+'[N]. ';
            result:=result+FieldByName(_Col_basic_Source_).AsString;
            result:=result+',';
            result:=result+FieldByName(_Col_basic_PubTime_).AsString;
            result:=result+'(';
            result:=result+FieldByName(_Col_basic_PageCount_).AsString;
            result:=result+').';
          end;
        '专著':
          begin
            result:='['+PID_Cite_format(PID)+']';
            result:=result+StringReplace(FieldByName(_Col_basic_Author_).AsString,';',',',[rfReplaceAll]);
            result:=result+'.';
            result:=result+FieldByName(_Col_basic_Title_).AsString;
            result:=result+'[M].';
            //result:=result+FieldByName(_Col_basic_出版社城市_).AsString;
            //result:=result+':';
            result:=result+FieldByName(_Col_basic_Organ_).AsString;
            result:=result+',';

            stmp:=FieldByName(_Col_basic_Year_).AsString;
            if stmp='' then
              begin
                tmpDateTime:=FieldByName(_Col_basic_PubTime_).AsDateTime;
                if tmpDateTime<>0 then
                  begin
                    DateTimeToString(stmp,'yyyy',tmpDateTime,[]);
                    result:=result+stmp;
                  end;
              end
            else result:=result+stmp;

            stmp:=FieldByName(_Col_basic_Page_).AsString;
            if stmp<>'' then
              begin
                result:=result+':';
                result:=result+stmp;
              end;

            result:=result+'.';
          end;
        '年鉴':
          begin
            result:='暂不支持此类型';
          end;
        '专利':
          begin
            result:='['+PID_Cite_format(PID)+']';
            result:=result+StringReplace(FieldByName(_Col_basic_Author_).AsString,';',',',[rfReplaceAll]);
            result:=result+'. ';
            result:=result+FieldByName(_Col_basic_Title_).AsString;

            stmp:=FieldByName(_Col_basic_ISBN_ISSN_).AsString;
            if stmp<>'' then result:=result+': '+stmp;
            result:=result+'[P].';
            stmp:=FieldByName(_Col_basic_PubTime_).AsString;
            if stmp<>'' then result:=' '+result+stmp+'.';
          end;
        '其它文献':
          begin
            result:='暂不支持此类型';
          end;
        '标准规范':
          begin
            result:='['+PID_Cite_format(PID)+']';
            result:=result+StringReplace(FieldByName(_Col_basic_Author_).AsString,';',',',[rfReplaceAll]);
            result:=result+'. ';
            result:=result+FieldByName(_Col_basic_Title_).AsString;
            result:=result+': ';
            result:=result+FieldByName(_Col_basic_ISBN_ISSN_).AsString;
            result:=result+'[S].';
            //result:=result+FieldByName(_Col_basic_City_).AsString;
            //result:=result+':';
            //result:=result+FieldByName(_Col_basic_Organ_).AsString;
            //result:=result+',';
            tmpDateTime:=FieldByName(_Col_basic_PubTime_).AsDateTime;
            if tmpDateTime<>0 then
              begin
                DateTimeToString(stmp,'yyyy:mm',tmpDateTime,[]);
                if length(stmp)=7 then result:=result+stmp+'.';
              end;
          end;
        else result:='暂不支持此类型';
      end;
    end;
end;
function TRTFP.GetCAJCD(PID:RTFP_ID):string;
begin
  ShowMsgOK('警告','暂不支持导出CAJ/CD');
end;
function TRTFP.GetMLA(PID:RTFP_ID):string;
begin
  ShowMsgOK('警告','暂不支持导出MLA');
end;
function TRTFP.GetAPA(PID:RTFP_ID):string;
var stmp:string;
    tmpDateTime:TDateTime;
begin
  //ShowMsgOK('警告','unimplemented');
  result:='';
  with InitBasic(PID) do
    begin
      case FieldByName(_Col_basic_RefType_).AsString of
        '期刊论文':
          begin
            result:=StringReplace(FieldByName(_Col_basic_Author_).AsString,';',',',[rfReplaceAll]);
            result:=result+'.(';
            result:=result+FieldByName(_Col_basic_Year_).AsString;
            result:=result+').';
            result:=result+FieldByName(_Col_basic_Title_).AsString;
            result:=result+'.';
            result:=result+FieldByName(_Col_basic_Source_).AsString;
            result:=result+',';
            result:=result+FieldByName(_Col_basic_Volume_).AsString;
            result:=result+'(';
            result:=result+StringReplace(FieldByName(_Col_basic_Issue_).AsString,'-','S',[rfReplaceAll]);
            result:=result+'):';
            result:=result+FieldByName(_Col_basic_Page_).AsString;
            result:=result+'.';
          end;
        '学位论文':
          begin
            result:=FieldByName(_Col_basic_Author_).AsString;
            result:=result+'.(';
            result:=result+FieldByName(_Col_basic_Year_).AsString;
            result:=result+').';
            result:=result+FieldByName(_Col_basic_Title_).AsString;
            result:=result+'[';
            case FieldByName(_Col_basic_Degree_).AsString of
              '硕士':result:=result+'Master';
              '博士':result:=result+'Doctoral';
              else result:=result+'Unknown';
            end;
            result:=result+' dissertation,';
            result:=result+FieldByName(_Col_basic_Source_).AsString;
            result:=result+'].';
          end;
        '会议论文':
          begin
            result:=FieldByName(_Col_basic_Author_).AsString;
            result:=result+'.(';
            result:=result+FieldByName(_Col_basic_Year_).AsString;
            result:=result+').[Conference].';
            result:=result+FieldByName(_Col_basic_Meeting_).AsString;
            result:=result+',';
            result:=result+FieldByName(_Col_basic_City_).AsString;
            result:=result+'.';
          end;
        '报纸':
          begin
            result:=StringReplace(FieldByName(_Col_basic_Author_).AsString,';',',',[rfReplaceAll]);
            result:=result+'.';
            stmp:='';
            tmpDateTime:=FieldByName(_Col_basic_PubTime_).AsDateTime;
            if tmpDateTime<>0 then DateTimeToString(stmp,'yyyy,mm,dd',tmpDateTime,[]);
            if stmp='' then stmp:=FieldByName(_Col_basic_Year_).AsString;
            result:=result+'('+stmp+').';
            result:=result+FieldByName(_Col_basic_Title_).AsString;
            result:=result+'.';
            result:=result+FieldByName(_Col_basic_Source_).AsString;
            result:=result+'.';
          end;
        '专著':
          begin
            result:=StringReplace(FieldByName(_Col_basic_Author_).AsString,';',',',[rfReplaceAll]);
            result:=result+'.';
            stmp:=FieldByName(_Col_basic_Year_).AsString;
            if stmp='' then
              begin
                tmpDateTime:=FieldByName(_Col_basic_PubTime_).AsDateTime;
                if tmpDateTime<>0 then
                  begin
                    DateTimeToString(stmp,'yyyy',tmpDateTime,[]);
                    result:=result+'('+stmp+').';
                  end;
              end
            else result:=result+'('+stmp+').';
            result:=result+FieldByName(_Col_basic_Title_).AsString;
            result:=result+'.';
            //result:=result+FieldByName(_Col_basic_出版社城市_).AsString;
            //result:=result+':';
            result:=result+FieldByName(_Col_basic_Organ_).AsString;
            result:=result+'.';
          end;
        else result:='暂不支持此类型';
      end;
    end;
end;
function TRTFP.GetChaXin(PID:RTFP_ID):string;
begin
  ShowMsgOK('警告','暂不支持导出查新');
end;
function TRTFP.GetRef_InOrder(PID:RTFP_ID):string;
begin
  result:='^['+PID_Cite_format(PID)+']';
end;
function TRTFP.GetRef_AurYear(PID:RTFP_ID):string;
var stmp,clip:string;
    str:TStringList;
    poss:integer;
    function IsAscii(str:string):boolean;
    var index:integer;
    begin
      for index:=1 to length(str) do if str[index] in [#128..#255] then begin result:=false;exit end;
      result:=true;
    end;

begin
  result:='(';
  with InitBasic(PID) do
    begin
      stmp:=FieldByName(_Col_basic_Author_).AsString;
      str:=TStringList.Create;
      try
        poss:=pos(';',stmp);
        while poss>0 do
          begin
            clip:=stmp;
            delete(clip,poss,length(clip));
            str.Add(clip);
            delete(stmp,1,poss);
            poss:=pos(';',stmp);
          end;
        str.Add(stmp);
        result:=result+str[0];
        if str.Count>1 then begin
          if IsAscii(str[0]) then result:=result+' et al.'
          else result:=result+' 等';
        end;
      finally
        str.Free;
      end;
      result:=result+', '+FieldByName(_Col_basic_Year_).AsString;
    end;
  result:=result+')';
end;

procedure TRTFP.ImportPapersFromEStudy(str:TStrings;DefaultCl:TKlass);
var stmp:TStringList;
    PID,line,header:string;
    poss:integer;
begin
  CurrentRTFP.BeginUpdate;
  stmp:=TStringList.Create;
  ConfirmState.Enable;
  try
    for line in str do
      begin
        header:=line;
        poss:=pos(': ',header);
        if poss>0 then delete(header,poss,length(header));
        stmp.Add(line);
        case header of
          'Link-链接','Link','链接':
            begin
              PID:=AddPaper('',apmReference);
              if DefaultCl<>nil then KlassInclude(DefaultCl.Name,PID);
              LoadFromEStudy(PID,stmp);
              stmp.Clear;
            end;
        end;
      end;
  finally
    stmp.Free;
    CurrentRTFP.EndUpdate;
    CurrentRTFP.FieldAndRecordChange;
    ConfirmState.Disable;
  end;
end;
procedure TRTFP.ImportPapersFromRefWork(str:TStrings;DefaultCl:TKlass);
begin
  ShowMsgOK('警告','暂不支持批量导入RefWork');
end;
procedure TRTFP.ImportPapersFromEndNote(str:TStrings;DefaultCl:TKlass);
begin
  ShowMsgOK('警告','暂不支持批量导入EndNote');
end;
procedure TRTFP.ImportPapersFromNoteExpress(str:TStrings;DefaultCl:TKlass);
begin
  ShowMsgOK('警告','暂不支持批量导入NoteExpress');
end;
procedure TRTFP.ImportPapersFromNoteFirst(str:TStrings;DefaultCl:TKlass);
begin
  ShowMsgOK('警告','暂不支持批量导入NoteFirst');
end;
procedure TRTFP.ImportPapersFromRIS(str:TStrings;DefaultCl:TKlass);
var stmp:TStringList;
    PID,line,header:string;
begin
  CurrentRTFP.BeginUpdate;
  stmp:=TStringList.Create;
  try
    for line in str do
      begin
        header:=line;
        delete(header,3,length(header));
        stmp.Add(line);
        case uppercase(header) of
          'ER':
            begin
              PID:=AddPaper('',apmReference);
              if DefaultCl<>nil then KlassInclude(DefaultCl.Name,PID);
              LoadFromRIS(PID,stmp);
              stmp.Clear;
            end;
        end;
      end;
  finally
    stmp.Free;
    CurrentRTFP.EndUpdate;
    CurrentRTFP.FieldAndRecordChange;
  end;
end;                   
