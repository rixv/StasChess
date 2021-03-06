unit UHash;

interface

  uses ChessTypes, Dialogs, SysUtils;

const HASHSIZE = 30;

type THashRecord=record
  RealHash: Int64;
  Val: Integer;
  Depth: Byte;
end;

function GetHash(var Board: TBoard): Int64;
procedure ClearHash;
function HashFullness: Cardinal;

function GetFigCount(var Board: TBoard): Byte;

function Collizions: Cardinal;

var HashTable: array[0..HASHSIZE] of THashRecord;

  Killers: array[1..10, 1..2] of TMove;

implementation

function Collizions: Cardinal;
var i, j: Cardinal;
begin
  Result := 0;

  for i:=0 to HASHSIZE do
  for j := 0 to HASHSIZE do
  if (i <> j) and (HashTable[i].RealHash <> 0) and (HashTable[j].RealHash <> 0)
   and (HashTable[i].RealHash = HashTable[j].RealHash) then
    inc(Result);

end;


function HashFullness: Cardinal;
var I: Integer;
begin
  Result := 0;
  for i := 0 to HASHSIZE do
  begin
   if HashTable[i].RealHash <> 0 then
      inc(Result);
  end;

  Result := trunc((Result/HASHSIZE)*1000);
end;


procedure ClearHash;
var i: Cardinal;
begin
  for i := 0 to HASHSIZE do
  begin
    HashTable[i].Val := 0;
    HashTable[i].RealHash := 0;
    HashTable[i].Depth := 0;
  end;
end;

function GetFigCount(var Board: TBoard): Byte;
var i, j: Integer;
begin

  Result := 0;

  for i := 1 to 8 do
    for j := 1 to 8 do
    begin
      If Board.Cells[i, j] <> 0 then Inc(Result);
    end;

end;


function GetHash(var Board: TBoard): Int64;
var i, j: Integer;
  Val: Int64; Shift: Byte;
begin

  Val := 9008;

  if Board.H1RookMoveW then Val := LongInt(Val) xor 1;
  if Board.A1RookMoveW then Val := LongInt(Val) xor 2;
  if Board.KingMoveW then Val := LongInt(Val) xor 4;
  if Board.H1RookMoveB then Val := LongInt(Val) xor 8;
  if Board.A1RookMoveB then Val := LongInt(Val) xor 16;
  if Board.KingMoveB then Val := LongInt(Val) xor 32;

   for i := 1 to 8 do
   for j := 1 to 8 do
   begin
      Val := Val xor (Board.Cells[i, j]+6 + i*13 + j*13*8);
      Shift := Board.Cells[i, j] + 7;
      Val := (Val shl Shift) or (Val shr (64-Shift));
   end;

   Result := Val;

end;


end.

