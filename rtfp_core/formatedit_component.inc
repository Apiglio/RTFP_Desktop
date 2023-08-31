
procedure TRTFP.FormatEditScrollBoxResize(Sender:TObject);
var HexaWidth,TriWidth,FullWidth:integer;
begin
  with FFormatEditComponentList do begin
    if Count<5 then exit;
    if TObject(Items[0]).ClassType<>TSplitter then exit;
    if TObject(Items[1]).ClassType<>TSplitter then exit;
    if TObject(Items[2]).ClassType<>TSplitter then exit;
    if TObject(Items[3]).ClassType<>TSplitter then exit;
    if TObject(Items[4]).ClassType<>TSplitter then exit;
    FullWidth:=(Sender as TScrollBox).Width;
    HexaWidth:=(FullWidth - 7*6) div 6;
    TriWidth:=(FullWidth - 7*6) div 3;
    TSplitter(Items[0]).Left:=HexaWidth + 6;
    TSplitter(Items[1]).Left:=TriWidth + 12;
    TSplitter(Items[2]).Left:=(FullWidth - 6) div 2;
    TSplitter(Items[3]).Left:=FullWidth - TriWidth - 12;
    TSplitter(Items[4]).Left:=FullWidth - HexaWidth - 6;

  end;
end;

procedure TRTFP.FormatEditBuild(AScrollBox:TScrollBox;AFormatFile:string);
var str:TStringList;
begin
  str:=TStringList.Create;
  try
    try
      str.LoadFromFile(Self.FFilePath+Self.FRootFolder+'/format/'+AFormatFile);
      Self.FormatEditBuild(AScrollBox,str);
    except
      assert(false,'Format文件未找到。');
    end;
  finally
    str.Free;
  end;
end;

procedure TRTFP.FormatEditBuild(AScrollBox:TScrollBox;AFormat:TStrings);
var SplitterObj:TSplitter;
    FormatPanel:TFormatEditPanel;
    index:integer;
    stmp,is_editable,str_editable:string;
    tmp:integer;
    AG:TAttrsGroup;
    AF:TAttrsField;
begin
  assert(FFormatEditComponentList.Count=0,'FormatEditBuild之前需要FormatEditClear！');
  with FFormatEditComponentList do begin
    for index:=0 to 4 do begin
      SplitterObj:=TSplitter.Create(AScrollBox);
      with SplitterObj do
        begin
          Parent:=AScrollBox;
          Align:=alNone;
          ResizeAnchor:=akLeft;
          Width:=6;
          Top:=0;
          Height:=6;
          Enabled:=false;
        end;
      Add(SplitterObj);
    end;
    //在这里写format-script
    for stmp in AFormat do begin
      //CmpType AttrsName FieldName DisplayName Top Height Left_Col Right_Col
      Auf.ReadArgs(stmp);
      if Auf.ArgsCount<8 then continue;
      case lowercase(Auf.nargs[0].arg) of
        'memo':FormatPanel:=TFormatEditPanel.Create(TMemo);
        'edit':FormatPanel:=TFormatEditPanel.Create(TEdit);
        'combo':FormatPanel:=TFormatEditPanel.Create(TComboBox);
        'check':FormatPanel:=TFormatEditPanel.Create(TCheckBox);
        'image':FormatPanel:=TFormatEditPanel.Create(TFmtImage);
        'list':FormatPanel:=TFormatEditPanel.Create(TListBox);
        else continue;
      end;

      is_editable:='';
      if Auf.ArgsCount>8 then Auf.TryArgToString(8,is_editable);
      if lowercase(is_editable)='editable' then begin
        FormatPanel.Editable:=true;
        str_editable:='';
      end else begin
        FormatPanel.Editable:=false;
        str_editable:='(只读)';
      end;

      Add(FormatPanel);
      FormatPanel.AttrsName:=Auf.nargs[1].arg;
      FormatPanel.FieldName:=Auf.nargs[2].arg;
      FormatPanel.DisplayName:=Auf.nargs[3].arg;
      FormatPanel.RelatedPath:=Tag['字段关联路径'];
      FormatPanel.RelatedExt:=Tag['字段关联后缀'];
      FormatPanel.TitleLabel.Caption:=Auf.nargs[3].arg+str_editable+': ';

      if FormatPanel.ComponentType=TComboBox then begin
        AG:=FFieldList.FindItemByName(FormatPanel.AttrsName);
        if AG<>nil then begin
          AF:=AG.FieldList.FindItemByName(FormatPanel.FieldName);
          if AF<>nil then begin
            if AF.ComboItem.Count>0 then begin
              for index:=0 to AF.ComboItem.Count-1 do TComboBox(FormatPanel.Component).Items.Add(AF.ComboItem[index]);
            end else begin
              TComboBox(FormatPanel.Component).Items.Add('');
            end;
          end;
        end;
      end;

      with FormatPanel do begin
        Parent:=AScrollBox;
        BeginUpdateBounds;
        Anchors:=[akTop,akLeft,akRight];

        //TControl(Component).Enabled:=Editable;

        case lowercase(Auf.nargs[6].arg) of
          '0','l':begin
                AnchorSideLeft.Control:=AScrollBox;
                AnchorSideLeft.Side:=asrLeft;
                BorderSpacing.Left:=6;
              end;
          'lm':begin
                AnchorSideLeft.Control:=TSplitter(Items[0]);
                AnchorSideLeft.Side:=asrRight;
              end;
          '1','ml':begin
                AnchorSideLeft.Control:=TSplitter(Items[1]);
                AnchorSideLeft.Side:=asrRight;
              end;
          '2','m':begin
                AnchorSideLeft.Control:=TSplitter(Items[2]);
                AnchorSideLeft.Side:=asrRight;
              end;
          '3','mr':begin
                AnchorSideLeft.Control:=TSplitter(Items[3]);
                AnchorSideLeft.Side:=asrRight;
              end;
          'rm':begin
                AnchorSideLeft.Control:=TSplitter(Items[4]);
                AnchorSideLeft.Side:=asrRight;
              end;
          else ;
        end;
        case lowercase(Auf.nargs[7].arg) of
          '4','r':begin
                AnchorSideRight.Control:=AScrollBox;
                AnchorSideRight.Side:=asrRight;
                BorderSpacing.Right:=6;
              end;
          'rm':begin
                AnchorSideRight.Control:=TSplitter(Items[4]);
                AnchorSideRight.Side:=asrLeft;
              end;
          '3','mr':begin
                AnchorSideRight.Control:=TSplitter(Items[3]);
                AnchorSideRight.Side:=asrLeft;
              end;
          '2','m':begin
                AnchorSideRight.Control:=TSplitter(Items[2]);
                AnchorSideRight.Side:=asrLeft;
              end;
          '1','ml':begin
                AnchorSideRight.Control:=TSplitter(Items[1]);
                AnchorSideRight.Side:=asrLeft;
              end;
          'lm':begin
                AnchorSideRight.Control:=TSplitter(Items[0]);
                AnchorSideRight.Side:=asrLeft;
              end;
          else ;
        end;

        AnchorSideTop.Control:=AScrollBox;
        AnchorSideTop.Side:=asrTop;
        BorderSpacing.Top:=Usf.to_i(Auf.nargs[4].arg);
        EndUpdateBounds;
        tmp:=Usf.to_i(Auf.nargs[5].arg);
        Height:=tmp;
      end;
    end;
  end;

  AScrollBox.OnResize:=@FormatEditScrollBoxResize;
  AScrollBox.OnResize(AScrollBox);
end;

procedure TRTFP.FormatEditClear(AScrollBox:TScrollBox);
begin
  with FFormatEditComponentList do
    while Count<>0 do
      begin
        if TObject(Items[0]).ClassType=TSplitter then TSplitter(Items[0]).Free
        else TFormatEditPanel(Items[0]).Free;
        Delete(0);
      end;
end;

procedure TRTFP.FormatEditValidate(PID:string);
var Item:Pointer;
begin
  for Item in FFormatEditComponentList do begin
    if TObject(Item).ClassType=TSplitter then continue;
    with TFormatEditPanel(Item) do begin
      try
        case ComponentClass.ClassName of
          'TEdit':AsString:=ReadFieldAsString(FieldName,AttrsName,PID,[aeFailIfNoPID,aeFailIfNoField]);
          'TMemo':ReadFieldAsMemo(FieldName,AttrsName,PID,AsMemo,[aeFailIfNoPID,aeFailIfNoField]);
          'TCheckBox':AsBoolean:=ReadFieldAsBoolean(FieldName,AttrsName,PID,[aeFailIfNoPID,aeFailIfNoField]);
          'TComboBox':AsString:=ReadFieldAsString(FieldName,AttrsName,PID,[aeFailIfNoPID,aeFailIfNoField]);
          'TFmtImage':
            begin
              case GetFieldType(AttrsName,FieldName) of
                ftMemo,ftString:AsString:=ReadFieldAsString(FieldName,AttrsName,PID,[aeFailIfNoPID,aeFailIfNoField]);
                ftBlob:ReadFieldAsBitmap(FieldName,AttrsName,PID,AsBitmap,[aeFailIfNoPID,aeFailIfNoField]);
                else raise AttrsTypeDismatchErr.Create('对TFmtImage无效的字段类型。');
              end;
            end;
          'TListBox':ReadFieldAsMemo(FieldName,AttrsName,PID,AsMemo,[aeFailIfNoPID,aeFailIfNoField]);
        end;
        RestoreState;
      except
        on E:AttrsNoFieldErr do case ComponentClass.ClassName of
          'TEdit','TComboBox':begin
            AsString:='';
            State:=fesNoField;
          end;
          'TCheckBox':begin
            AsBoolean:=false;
            State:=fesNoField;
          end;
          'TMemo','TListBox':begin
            AsMemo.Clear;
            State:=fesNoField;
          end;
          'TFmtImage':begin
            AsBitmap.Clear;
            State:=fesNoField;
          end;
        end;
        on E:AttrsNoPIDErr do case ComponentClass.ClassName of
          'TEdit','TComboBox':begin
            AsString:='';
            State:=fesNodata;
          end;
          'TCheckBox':begin
            AsBoolean:=false;
            State:=fesNodata;
          end;
          'TMemo','TListBox':begin
            AsMemo.Clear;
            State:=fesNodata;
          end;
          'TFmtImage':begin
            AsBitmap.Clear;
            State:=fesNodata;
          end;
        end;
        on E:AttrsTypeDismatchErr do case ComponentClass.ClassName of
          'TFmtImage':begin
            AsBitmap.Clear;
            State:=fesNodata;
          end;
        end;
      end;
    end;
  end;
end;

procedure TRTFP.FormatEditDataPost(PID:string);
var Item:Pointer;
begin
  BeginUpdate;
  for Item in FFormatEditComponentList do begin
    if TObject(Item).ClassType=TSplitter then continue;
    with TFormatEditPanel(Item) do begin
      if (State=fesModified) or (RunPerformance.ForceSaveField and (State=fesSaved)) then
        try
          case ComponentClass.ClassName of
            'TEdit':EditFieldAsString(FieldName,AttrsName,PID,AsString,[aeForceEditIfTypeDismatch]);
            'TMemo':EditFieldAsMemo(FieldName,AttrsName,PID,AsMemo,[]);
            'TCheckBox':EditFieldAsBoolean(FieldName,AttrsName,PID,AsBoolean,[]);
            'TComboBox':EditFieldAsString(FieldName,AttrsName,PID,AsString,[aeForceEditIfTypeDismatch]);
            'TFmtImage':
              begin
                case GetFieldType(AttrsName,FieldName) of
                  ftMemo,ftString:AsBitmap.SaveToFile(RelatedPath+ReadFieldAsString(FieldName,AttrsName,PID,[aeFailIfNoPID,aeFailIfNoField])+RelatedExt);
                  ftBlob:EditFieldAsBitmap(FieldName,AttrsName,PID,AsBitmap,[]);
                  else raise AttrsTypeDismatchErr.Create('对TFmtImage无效的字段类型。');
                end;
              end;
            'TListBox':EditFieldAsMemo(FieldName,AttrsName,PID,AsMemo,[]);
          end;
        except
          ShowMsgOK('FormatEdit','字段'+AttrsName+'.'+FieldName+'保存失败。');
        end;
      RestoreState;
    end;
  end;
  EndUpdate;
  DataChange(PID);
end;
