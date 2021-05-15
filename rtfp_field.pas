// 计划要做单独字段管理
//
//
//
//
//

unit rtfp_field;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db;

type

  TComponentType=(ctUnknown=0,ctEdit=1,ctMemo=2,ctCheck=3,
                  ctCombo=4,ctCheckList=5,ctImage=6,ctNotes=7,
                  ctPaper=8,ctFormat=9,ctButton=10);

  TRTFP_FieldItem = class(TCollectionItem)
  private
    FDisplayName,FFieldName:string;
    FDataType:TFieldType;
    FComponentType:TComponentType;
    FAttrNo:byte;
  public
    constructor Create(ACollection: TCollection);
  end;

  TRTFP_FieldList = class(TCollection)
  private
    FOwner:TComponent;
  private
    function GetItems(Index: integer): TRTFP_FieldItem;
    procedure SetItems(Index: integer; AValue: TRTFP_FieldItem);
  public
    constructor Create(AOwner:TComponent);
  public
    function Add: TRTFP_FieldItem;
    function AddEx(AFieldName:string): TRTFP_FieldItem;
    procedure Clear;
    property Items[Index: integer]: TRTFP_FieldItem read GetItems write SetItems; default;
  end;


implementation


{ TRTFP_FieldItem }

constructor TRTFP_FieldItem.Create(ACollection: TCollection);
begin
  if Assigned(ACollection) and (ACollection is TRTFP_FieldList) then
    inherited Create(ACollection)
  else raise Exception.Create('TRTFP_FieldItem.Create: unassigned or wrong ListType');
end;


{ TRTFP_FieldList }

function TRTFP_FieldList.GetItems(Index: integer): TRTFP_FieldItem;
begin
  Result := TRTFP_FieldItem(inherited Items[Index]);
end;

procedure TRTFP_FieldList.SetItems(Index: integer; AValue: TRTFP_FieldItem);
begin
  Items[Index].Assign(AValue);
end;

constructor TRTFP_FieldList.Create(AOwner:TComponent);
begin
  inherited Create(TRTFP_FieldItem);
end;

function TRTFP_FieldList.Add: TRTFP_FieldItem;
begin
  Result := inherited Add as TRTFP_FieldItem;
end;

function TRTFP_FieldList.AddEx(AFieldName:string): TRTFP_FieldItem;
begin
  Result := inherited Add as TRTFP_FieldItem;
  result.FFieldName:=AFieldName;
end;

procedure TRTFP_FieldList.Clear;
begin
  inherited Clear;
end;



end.

