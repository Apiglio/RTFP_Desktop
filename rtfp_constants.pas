unit rtfp_constants;

{$mode objfpc}{$H+}

interface

const
  {Real Number of MessageBox}
  rnmbOK     = 1;
  rnmbCancel = 2;
  rnmbAbort  = 3;
  rnmbRetry  = 4;
  rnmbIgnore = 5;
  rnmbYes    = 6;
  rnmbNo     = 7;


  RTFP_ID_ORDER_Pre_0_1_1_alpha_18 = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+-';
  RTFP_ID_ORDER = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz{}';
  RTFP_ID_CHARSET_Pre_0_1_1_alpha_18 = ['0'..'9','A'..'Z','a'..'z','+','-'];
  RTFP_ID_CHARSET = ['0'..'9','A'..'Z','a'..'z','{','}'];
  DefaultOpenExe = ''; //cmd.exe /c
  Comma_Symbol = '<_cma>';

  _Attrs_Basic_ = '文献基础信息';
  _Attrs_Class_ = '分类';
  _Attrs_Notes_ = '注解';
  _Attrs_Metas_ = '元数据';
  _Attrs_Relat_ = '关系';

  _Col_OID_ = 'OID';
  _Col_PID_ = 'PID';
  _Col_IID_ = 'IID';
  _Col_NID_ = 'NID';

  _Col_Paper_Is_Backup_ = '是否备份';
  _Col_Paper_Folder_ = '目录';
  _Col_Paper_FileName_ = '文件名';
  _Col_Paper_FileSize_ = '文件大小';
  _Col_Paper_FileHash_ = '文件哈希';

  _Col_Image_FileSize_ = '文件大小';
  _Col_Image_FileHash_ = '文件哈希';
  _Col_Image_Folder_ = '目录';
  _Col_Image_FileName_ = '文件名';
  _Col_Image_Width_ = '宽度';
  _Col_Image_Height_ = '高度';
  _Col_Note_Folder_ = '目录';
  _Col_Note_FileName_ = '文件名';
  _Col_basic_RefType_ = '类型';
  _Col_basic_Title_ = '标题';
  _Col_basic_Author_ = '作者';
  _Col_basic_Corresp_ = '通讯作者';
  _Col_basic_Source_ = '来源';
  _Col_basic_PubTime_ = '发表时间';
  _Col_basic_Keyword_ = '关键词';
  _Col_basic_Summary_ = '摘要';
  _Col_basic_Organ_ = '单位';
  _Col_basic_Year_ = '年份';
  _Col_basic_Volume_ = '卷';
  _Col_basic_Issue_ = '期';
  _Col_basic_PageCount_ = '页数';
  _Col_basic_Page_ = '页码';
  _Col_basic_Fund_ = '基金';
  _Col_basic_Link_ = '链接';
  _Col_basic_doi_ = 'DOI';
  _Col_basic_CLC_ = '中图号';
  _Col_basic_ISBN_ISSN_ = 'ISBN';
  _Col_basic_Note_ = '注释';
  _Col_basic_DataProv_ = 'DataProv.';
  _Col_basic_Has_Ext_ = 'Has_Ext';
  _Col_metas_Title_ = 'Title';
  _Col_metas_Authors_ = 'Authors';
  _Col_metas_Subject_ = 'Subject';
  _Col_metas_KeyWord_ = 'KeyWord';
  _Col_metas_Creator_ = 'Creator';
  _Col_metas_Produce_ = 'Produce';
  _Col_metas_CreDate_ = 'CreDate';
  _Col_metas_ModDate_ = 'ModDate';
  _Col_metas_Trapped_ = 'Trapped';
  _Col_class_Is_Read_ = '是否已读';
  _Col_class_DefaultCl_ = '默认分类';
  _Col_notes_Usage_ = '用途';
  _Col_notes_Rank_ = '评分';
  _Col_notes_Comment_ = '笔记';
  _Col_notes_User_ = '入库用户';
  _Col_notes_CreateTime_ = '入库时间';
  _Col_notes_ModifyTime_ = '最近修改';
  _Col_notes_CheckTime_ = '最近查询';
  _Col_notes_FurtherCmt_ = 'FurtherCmt';
  _Col_notes_Format_ = 'Format';
  _Col_relat_Parent_ = '父节点';
  _Col_relat_Children_ = '子节点';
  _Col_relat_Cited_ = '引证文献';
  _Col_relat_References_ = '参考文献';

implementation

end.

