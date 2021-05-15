unit rtfp_class;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dbf;

type
  TRTFP_ClassItem = class(TCollectionItem)
  private
    FName:string;
    FDbf:TDbf;
  public
    property Name:string read FName;
    property Dbf:Tdbf read FDbf;
  public
    constructor Create(ACollection:TCollection);override;
  end;

  TRTFP_ClassList = class(TCollection)
  private
    FOwner:TComponent;
  private
    function GetItems(Index: integer): TRTFP_ClassItem;
    procedure SetItems(Index: integer; AValue: TRTFP_ClassItem);
  public
    constructor Create(AOwner:TComponent);
  public
    function Add: TRTFP_ClassItem;
    function AddEx(AName:string): TRTFP_ClassItem;
    procedure Clear;
    property Items[Index: integer]: TRTFP_ClassItem read GetItems write SetItems; default;
  end;


implementation


{ TRTFP_ClassItem }

constructor TRTFP_ClassItem.Create(ACollection: TCollection);
begin
  if Assigned(ACollection) and (ACollection is TRTFP_ClassList) then
    inherited Create(ACollection)
  else raise Exception.Create('TRTFP_ClassItem.Create: unassigned or wrong ListType');
end;

{ TRTFP_ClassList }

function TRTFP_ClassList.GetItems(Index: integer): TRTFP_ClassItem;
begin
  Result := TRTFP_ClassItem(inherited Items[Index]);
end;

procedure TRTFP_ClassList.SetItems(Index: integer; AValue: TRTFP_ClassItem);
begin
  Items[Index].Assign(AValue);
end;

constructor TRTFP_ClassList.Create(AOwner:TComponent);
begin
  inherited Create(TRTFP_ClassItem);
end;

function TRTFP_ClassList.Add: TRTFP_ClassItem;
begin
  Result := inherited Add as TRTFP_ClassItem;
end;

function TRTFP_ClassList.AddEx(AName:string): TRTFP_ClassItem;
begin
  Result := inherited Add as TRTFP_ClassItem;
  result.FName:=AName;
  result.FDbf:=TDbf.Create(Self.FOwner);
end;

procedure TRTFP_ClassList.Clear;
begin
  inherited Clear;
end;



end.

