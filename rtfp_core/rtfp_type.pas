unit rtfp_type;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, dbf, dbf_common, dbf_fields;

type
  RTFP_ID=string;//六位64进制数
  TPIDNotifyEvent = procedure(Sender:TObject;PID:RTFP_ID) of object;

  TFieldTypeSet = set of TFieldType;
  TAttrExtendUnit = (aeFailIfNoPID,aeFailIfNoField,aeFailIfTypeDismatch,
                     aeCreateIfNoField,aeForceEditIfTypeDismatch);
  TAttrExtend = set of TAttrExtendUnit;
  TablesUse = set of byte;
  TAddPaperMethod = (apmFullBackup=1,apmCutBackup=2,apmAddress=3,apmWebsite=4,apmReference=5);
  //几种文档入库方式: 复制备份/本地链接/网址链接/数据入库

  TSimChkOption = (scoFileName,scoTitle,scoFileHash,scoWeblnk,scoDOI,
                   scoMetaTitle,scoMetaSubject,scoMetaCreator,scoMetaProduce,
                   scoEqual,scoContain,scoHalffit,scoHalffitUnsigned,  //匹配模式：完全相等、包含和半长度匹配(典型/无符号)
                   scoDB,scoDS);                                       //匹配总体：PaperDB、PaperDS

  TSimChkOptions = set of TSimChkOption;
  TRTFP_DataSetType = (dstDBF,dstBUF);

  TMGSC_CR_Option = (mgsc_cc_unknown=0, mgsc_cc_title=1, mgsc_cc_path=2,
                     mgsc_cc_link=3, mgsc_cc_gb7714=4, mgsc_cc_apa=5,
                     mgsc_cc_mla=6, mgsc_cc_order=7, mgsc_cc_auyear=8);//数字不允许修改，只能增加，用于注册表

  TPicStretch = (psch_stretch=0, psch_clip=1, psch_middle=2);//0-拉伸, 1-裁切, 2-缩放居中. 数字不允许修改，只能增加，用于注册表
  TPicsExportOption = record
    cell_width:integer;
    cell_height:integer;
    head_height:integer;
    pic_stretch:TPicStretch;
  end;

implementation

end.

