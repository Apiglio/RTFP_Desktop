//用于压缩储存和格式转换的文件定义
//使用zip压缩格式

procedure TRTFP.ZTFP_Importer(fullfilename:string);
begin

end;

procedure TRTFP.ZTFP_Exporter(fullfilename:string);
var zf:TZipper;
    stmp:string;
begin
  zf:=TZipper.Create;
  try
    zf.FileName:=fullfilename;
    //文件备份在zip中，直接用PID名称保存，使用Zipper单元

    //工程属性
    zf.Entries.AddFileEntry(Self.FFileFullName,'project_file');
    zf.Entries.AddFileEntry(Self.CurrentPathFull+'user.dat','user_name');
    for stmp in FFormatList do
      zf.Entries.AddFileEntry(Self.CurrentPathFull+'format\'+stmp,'format\'+stmp);
    zf.Entries.AddFileEntry(Self.CurrentPathFull+'option.lay.auf','option_lay');

    //属性组与字段

    //类型（不保存“分类”属性组中的数据，检查分类映射完整性后直接一系列属性表统计，包括“是否已读”字段）

    //文献节点

    //-图片节点

    //-注记节点

    //样式
  finally
    zf.Free;
  end;

end;
