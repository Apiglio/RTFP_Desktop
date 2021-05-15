unit rtfp_files;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Apiglio_Useful;

type
  TRTFP_FileItem = class(TCollectionItem)
  private
    FFileName:string;
    FFileSize:int64;
  public
    property Name:string read FFileName;
  public
    constructor Create(ACollection:TCollection);override;
  end;

  TRTFP_FileList = class(TCollection)
  private
    FOwner:TComponent;
    FBaseDir:string;
  private
    function GetItems(Index: integer): TRTFP_FileItem;
    procedure SetItems(Index: integer; AValue: TRTFP_FileItem);
  public
    constructor Create(AOwner:TComponent;ABaseDir:string);
    procedure RunDir(APath:string='\');//APath这个参数用于递归，必须斜杠结尾，设置基地址请使用BaseDir
  public
    function Add: TRTFP_FileItem;
    function AddEx(AFileName:string;ASize:int64): TRTFP_FileItem;
    procedure Clear;
    property Items[Index: integer]: TRTFP_FileItem read GetItems write SetItems; default;
    property BaseDir:string read FBaseDir write FBaseDir;//这个基地址用来确定初始的搜索目录
  end;


implementation


{ TRTFP_FileItem }

constructor TRTFP_FileItem.Create(ACollection: TCollection);
begin
  if Assigned(ACollection) and (ACollection is TRTFP_FileList) then
    inherited Create(ACollection)
  else raise Exception.Create('TRTFP_FileItem.Create: unassigned or wrong ListType');
end;

{ TRTFP_FileList }

function TRTFP_FileList.GetItems(Index: integer): TRTFP_FileItem;
begin
  Result := TRTFP_FileItem(inherited Items[Index]);
end;

procedure TRTFP_FileList.SetItems(Index: integer; AValue: TRTFP_FileItem);
begin
  Items[Index].Assign(AValue);
end;

constructor TRTFP_FileList.Create(AOwner:TComponent;ABaseDir:string);
begin
  inherited Create(TRTFP_FileItem);
  Self.FBaseDir:=ABaseDir;
end;

procedure TRTFP_FileList.RunDir(APath:string='\');
Var Info:TSearchRec;
    pi:Longint;
Begin
  Self.Clear;
  pi:=0;
  If FindFirst(Self.BaseDir+APath+'*',faAnyFile and faDirectory,Info)=0 then
    Repeat
      Inc(pi);
      With Info do
        begin
          if (Name<>'.') and (Name<>'..') then BEGIN
            If (Attr and faDirectory) = faDirectory then RunDir(APath+Name+'\')
            else AddEx(APath+Name,Size);//递归好像不会增产增加元素
          END;
        end;
    Until FindNext(info)<>0;
  FindClose(Info);
End;

function TRTFP_FileList.Add: TRTFP_FileItem;
begin
  Result := inherited Add as TRTFP_FileItem;
end;

function TRTFP_FileList.AddEx(AFileName:string;ASize:int64): TRTFP_FileItem;
begin
  Result := inherited Add as TRTFP_FileItem;
  Result.FFileName:=AFileName;
  Result.FFileSize:=ASize;
end;

procedure TRTFP_FileList.Clear;
begin
  inherited Clear;
end;

end.

