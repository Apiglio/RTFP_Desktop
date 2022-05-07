//����ע��ʽ�йص�ת������


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
        assert(false,'��Ӧ���Ҳ����Ŷ�');
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

function decodeEStudyRefType(str:string):string;
begin
  case str of
    '1':result:='�ڿ�����';
    '2':result:='ѧλ����';
    '3':result:='��������';
    '4':result:='��ֽ';
    '5':result:='ר��';
    '6':result:='���';
    '60':result:='ר��';
    '61':result:='��������';
    '62':result:='��׼�淶';
    else result:='δ֪';
  end;
end;

function encodeEStudyRefType(str:string):string;
begin
  case str of
    '�ڿ�����':result:='1';
    'ѧλ����':result:='2';
    '��������':result:='3';
    '��ֽ':result:='4';
    'ר��':result:='5';
    '���':result:='6';
    'ר��':result:='60';
    '��������':result:='61';
    '��׼�淶':result:='62';
    else result:='0';
  end;
end;

function decodeEndNoteRefType(str:string):string;
begin
  case str of
    'Journal Article':result:='�ڿ�����';
    'Thesis':result:='ѧλ����';
    'Conference Proceedings':result:='��������';
    'Newspaper Article':result:='��ֽ';
    'Book':result:='ר��';
    //'Legal Rule or Regulation':result:='���';
    'Patent':result:='ר��';
    'Other Article':result:='��������';
    'Legal Rule or Regulation':result:='��׼�淶';
    else result:='δ֪';
  end;
end;

function encodeEndNoteRefType(str:string):string;
begin
  case str of
    '�ڿ�����':result:='Journal Article';
    'ѧλ����':result:='Thesis';
    '��������':result:='Conference Proceedings';
    '��ֽ':result:='Newspaper Article';
    'ר��':result:='Book';
    '���':result:='Legal Rule or Regulation';
    'ר��':result:='Patent';
    '��������':result:='Other Article';
    '��׼�淶':result:='Legal Rule or Regulation';
    else result:='Unknown';
  end;
end;

function decodeRISRefType(str:string):string;
begin
  result:=str;
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
      //�������Ʊ����ж϶���ժҪ��ʽ�Ƿ����㹻����Ӧ�ԣ�
      if (stmp[1]=#9) and is_last_summary then begin
        sum_temp:=FieldByName(_Col_basic_Summary_).AsString;
        FieldByName(_Col_basic_Summary_).AsString:=sum_temp+#13#10+stmp;
      end;
      poss:=pos(': ',stmp);
      if poss<=0 then continue;
      header:=stmp;
      attr:=stmp;
      delete(header,poss,length(stmp));
      delete(attr,1,poss+1);
      if attr='' then continue;

      try
        case header of
          'DataType':FieldByName(_Col_basic_RefType_).AsString:=decodeEStudyRefType(attr);
          'Author-����','Author-������','Source-��ݵ�λ':
            begin
              while attr[length(attr)]=';' do
                begin
                  delete(attr,length(attr),1);
                  if attr='' then break;
                end;
              FieldByName(_Col_basic_Author_).AsString:=attr;
            end;
          'Title-����','Title-������','Title-����','Title-ר������','Title-���ı�׼����':FieldByName(_Col_basic_Title_).AsString:=attr;
          'Source-����','Source-ѧλ���赥λ','Source-��ֽ������','Author-������λ����','Source-������Դ':
            FieldByName(_Col_basic_Source_).AsString:=attr;
          'Year-��','Year-������':FieldByName(_Col_basic_Year_).AsString:=attr;
          'PubTime-����ʱ��','PubTime-����ʱ��':
            begin
              {zan}poss:=pos(' ',attr);
              if poss>0 then delete(attr,poss,length(attr));
              try
                TryStrToDate(attr,tmpDate,'YYYYMMDD','-');
              except
              end;
              FieldByName(_Col_basic_PubTime_).AsDateTime:=tmpDate;
            end;
          'Period-��':begin
            attr:=StringReplace(attr,'S','-',[rfReplaceAll,rfIgnoreCase]);
            FieldByName(_Col_basic_Issue_).AsString:=attr;
          end;
          'Roll-��':FieldByName(_Col_basic_Volume_).AsString:=attr;
          'Keyword-�ؼ���':FieldByName(_Col_basic_Keyword_).AsString:=attr;
          'Summary-ժҪ','Summary-����':FieldByName(_Col_basic_Summary_).AsString:=attr;
          'PageCount-ҳ��':FieldByName(_Col_basic_PageCount_).AsString:=attr;
          'Page-ҳ��':FieldByName(_Col_basic_Page_).AsString:=attr;
          //'SrcDatabase-��Դ��':FieldByName(_Col_basic_��Դ��_).AsString:=attr;
          'Organ-����','Organ-��ѧ','Organ-������','������Դ'{ר��},'Organ-������'{���}:
            FieldByName(_Col_basic_Organ_).AsString:=attr;
          'Link-����':FieldByName(_Col_basic_Link_).AsString:=StringReplace(attr,'&amp;','&',[rfReplaceAll]);
          'Degree-ѧλ':FieldByName(_Col_basic_Degree_).AsString:=attr;
          'Teacher-��ʦ','Teacher-������':FieldByName(_Col_basic_Teacher_).AsString:=attr;
          'City-����ص�','City-��ַ':FieldByName(_Col_basic_City_).AsString:=attr;
          'Meeting-��������':FieldByName(_Col_basic_Meeting_).AsString:=attr;
          'Notes-��׼��':FieldByName(_Col_basic_ISBN_ISSN_).AsString:=attr;

        end;
      except
        error_str:=error_str+'    '+header+#13#10;
      end;
      case header of
        'Summary-ժҪ','Summary-����':is_last_summary:=true;
        else is_last_summary:=false;
      end;
      ReEditBasic;
      //PostBasic;
      //EditBasic;
    end;
  end;
  if error_str<>#13#10 then ShowMsgOKAll('�������','�����ֶε���ʱ��������'+error_str);//������ü�һ�����β�����ʾ
  PostBasic;
  FieldAndRecordChange;//DataChange;
end;
procedure TRTFP.LoadFromRefWork(PID:RTFP_ID;str:TStrings);
begin
  ShowMsgOK('����','�ݲ�֧�ֵ���RefWork');
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
        'D':FieldByName(_Col_basic_Year_).AsString:=attr;
        'V':case reftype of
              '��׼�淶':FieldByName(_Col_basic_ISBN_ISSN_).AsString:=attr;
              else FieldByName(_Col_basic_Issue_).AsString:=attr;
            end;
        'N':FieldByName(_Col_basic_Volume_).AsString:=attr;
        'K':FieldByName(_Col_basic_Keyword_).AsString:=attr;
        'X':FieldByName(_Col_basic_Summary_).AsString:=attr;
        'P':FieldByName(_Col_basic_Page_).AsString:=attr;
        '@':FieldByName(_Col_basic_ISBN_ISSN_).AsString:=attr;
        'L':FieldByName(_Col_basic_CN_).AsString:=attr;
        //'W':FieldByName(_Col_basic_DataProv_).AsString:=attr;
        'Y':FieldByName(_Col_basic_Teacher_).AsString:=attr;
        '9':FieldByName(_Col_basic_Degree_).AsString:=attr;//Ҳָר������
        'C':FieldByName(_Col_basic_City_).AsString:=attr;
        'B':FieldByName(_Col_basic_Meeting_).AsString:=attr;
        '?':FieldByName(_Col_basic_Sponsor_).AsString:=attr;
        '8':FieldByName(_Col_basic_PubTime_).AsString:=attr;//ר���ķ���ʱ��

      end;
      ReEditBasic;
    end;
  end;
  PostBasic;
  FieldAndRecordChange;//DataChange;
end;
procedure TRTFP.LoadFromNoteExpress(PID:RTFP_ID;str:TStrings);
begin
  ShowMsgOK('����','�ݲ�֧�ֵ���NoteExpress');
end;
procedure TRTFP.LoadFromNoteFirst(PID:RTFP_ID;str:TStrings);
begin
  ShowMsgOK('����','�ݲ�֧�ֵ���NoteFirst');
end;
procedure TRTFP.LoadFromRIS(PID:RTFP_ID;str:TStrings);
var stmp,attr:string;
    has_author,has_keyword:boolean;
    tmpDate:TDate;
begin
  has_author:=false;
  has_keyword:=false;
  with InitBasic(PID) do begin
    for stmp in str do begin
      if length(stmp)<6 then continue;
      if (stmp[3]<>' ') or (stmp[4]<>' ') or (stmp[5]<>'-') or (stmp[6]<>' ') then continue;
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
        'JO','JF':FieldByName(_Col_basic_Source_).AsString:=attr;
        'PY':FieldByName(_Col_basic_Year_).AsString:=attr;
        'VL':FieldByName(_Col_basic_Volume_).AsString:=attr;
        'AB':FieldByName(_Col_basic_Summary_).AsString:=attr;
        'SN':FieldByName(_Col_basic_ISBN_ISSN_).AsString:=attr;
        'DO':FieldByName(_Col_basic_doi_).AsString:=attr;
        'UR':FieldByName(_Col_basic_Link_).AsString:=attr;
        'DB':FieldByName(_Col_basic_DataProv_).AsString:=attr;
        'DP':FieldByName(_Col_basic_DataProv_).AsString:=attr;
        //'AU':FieldByName(Author Address).AsString:=attr;
        //'AN':FieldByName(Accession Number).AsString:=attr;
        //'AV':FieldByName(Location in Archives).AsString:=attr;
        //'SP':FieldByName(Start Page).AsString:=attr;
        //'EP':FieldByName(End Page).AsString:=attr;
        //'LA':FieldByName(_Col_basic_Language).AsString:=attr;

      end;
      ReEditBasic;
    end;
  end;
  PostBasic;
  FieldAndRecordChange;//DataChange;
end;

procedure TRTFP.SaveToEStudy(PID:RTFP_ID;str:TStrings);
begin
  ShowMsgOK('����','�ݲ�֧�ֵ���EStudy');
end;
procedure TRTFP.SaveToRefWork(PID:RTFP_ID;str:TStrings);
begin
  ShowMsgOK('����','�ݲ�֧�ֵ���RefWork');
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
    if reftype = 'ѧλ����' then begin
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
  ShowMsgOK('����','�ݲ�֧�ֵ���NoteExpress');
end;
procedure TRTFP.SaveToNoteFirst(PID:RTFP_ID;str:TStrings);
begin
  ShowMsgOK('����','�ݲ�֧�ֵ���NoteFirst');
end;
procedure TRTFP.SaveToRIS(PID:RTFP_ID;str:TStrings);
begin
  ShowMsgOK('����','�ݲ�֧�ֵ���RIS');
end;

procedure TRTFP.SetGBT7714(PID:RTFP_ID;str:string);
begin
  ShowMsgOK('����','�ݲ�֧�ֵ���GB/T 7714');
end;
procedure TRTFP.SetCAJCD(PID:RTFP_ID;str:string);
begin
  ShowMsgOK('����','�ݲ�֧�ֵ���CAJ/CD');
end;
procedure TRTFP.SetMLA(PID:RTFP_ID;str:string);
begin
  ShowMsgOK('����','�ݲ�֧�ֵ���MLA');
end;
procedure TRTFP.SetAPA(PID:RTFP_ID;str:string);
begin
  ShowMsgOK('����','�ݲ�֧�ֵ���APA');
end;
procedure TRTFP.SetChaXin(PID:RTFP_ID;str:string);
begin
  ShowMsgOK('����','�ݲ�֧�ֵ������');
end;

function TRTFP.GetGBT7714(PID:RTFP_ID):string;
var stmp:string;
    tmpDateTime:TDateTime;
begin
  //ShowMsgOK('����','unimplemented');
  result:='';
  with InitBasic(PID) do
    begin
      case FieldByName(_Col_basic_RefType_).AsString of
        '�ڿ�����':
          begin
            result:='[PID='+PID+']';
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
            result:=result+FieldByName(_Col_basic_Issue_).AsString;
            result:=result+'):';
            result:=result+FieldByName(_Col_basic_Page_).AsString;
            result:=result+'.';
          end;
        'ѧλ����':
          begin
            result:='[PID='+PID+']';
            result:=result+FieldByName(_Col_basic_Author_).AsString;
            result:=result+'.';
            result:=result+FieldByName(_Col_basic_Title_).AsString;
            result:=result+'[D].';
            result:=result+FieldByName(_Col_basic_Source_).AsString;
            result:=result+',';
            result:=result+FieldByName(_Col_basic_Year_).AsString;
            result:=result+'.';
          end;
        '��������':
          begin
            result:='[PID='+PID+']';
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
        '��ֽ':
          begin
            result:='[PID='+PID+']';
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
        'ר��':
          begin
            result:='[PID='+PID+']';
            result:=result+StringReplace(FieldByName(_Col_basic_Author_).AsString,';',',',[rfReplaceAll]);
            result:=result+'.';
            result:=result+FieldByName(_Col_basic_Title_).AsString;
            result:=result+'[M].';
            //result:=result+FieldByName(_Col_basic_���������_).AsString;
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
        '���':
          begin
            result:='�ݲ�֧�ִ�����';
          end;
        'ר��':
          begin
            result:='[PID='+PID+']';
            result:=result+StringReplace(FieldByName(_Col_basic_Author_).AsString,';',',',[rfReplaceAll]);
            result:=result+'. ';
            result:=result+FieldByName(_Col_basic_Title_).AsString;

            stmp:=FieldByName(_Col_basic_ISBN_ISSN_).AsString;
            if stmp<>'' then result:=result+': '+stmp;
            result:=result+'[P].';
            stmp:=FieldByName(_Col_basic_PubTime_).AsString;
            if stmp<>'' then result:=' '+result+stmp+'.';
          end;
        '��������':
          begin
            result:='�ݲ�֧�ִ�����';
          end;
        '��׼�淶':
          begin
            result:='[PID='+PID+']';
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
        else result:='�ݲ�֧�ִ�����';
      end;
    end;
end;
function TRTFP.GetCAJCD(PID:RTFP_ID):string;
begin
  ShowMsgOK('����','�ݲ�֧�ֵ���CAJ/CD');
end;
function TRTFP.GetMLA(PID:RTFP_ID):string;
begin
  ShowMsgOK('����','�ݲ�֧�ֵ���MLA');
end;
function TRTFP.GetAPA(PID:RTFP_ID):string;
begin
  ShowMsgOK('����','�ݲ�֧�ֵ���APA');
end;
function TRTFP.GetChaXin(PID:RTFP_ID):string;
begin
  ShowMsgOK('����','�ݲ�֧�ֵ�������');
end;
function TRTFP.GetRef_InOrder(PID:RTFP_ID):string;
begin
  result:='^[PID='+PID+']';
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
          else result:=result+' ��';
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
          'Link-����','Link','����':
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
  ShowMsgOK('����','�ݲ�֧����������RefWork');
end;
procedure TRTFP.ImportPapersFromEndNote(str:TStrings;DefaultCl:TKlass);
begin
  ShowMsgOK('����','�ݲ�֧����������EndNote');
end;
procedure TRTFP.ImportPapersFromNoteExpress(str:TStrings;DefaultCl:TKlass);
begin
  ShowMsgOK('����','�ݲ�֧����������NoteExpress');
end;
procedure TRTFP.ImportPapersFromNoteFirst(str:TStrings;DefaultCl:TKlass);
begin
  ShowMsgOK('����','�ݲ�֧����������NoteFirst');
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