unit UHash;

interface

  uses ChessTypes, Dialogs, SysUtils;

const HASHSIZE = 5000000;

type THashRecord=record
  RealHash: Int64;
  Val: Integer;
  Depth: Byte;
  FigCount: Byte;
end;

function GetHash(var Board: TBoard): Int64;
procedure ClearHash;
function HashFullness: Cardinal;

function GetFigCount(var Board: TBoard): Byte;

function Collizions: Cardinal;

var HashTable: array[0..HASHSIZE] of THashRecord;

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
    HashTable[i].FigCount := 0;
  end;
end;

function Rol32(Value, Shift: LongWord): LongWord;
asm
  mov ecx, edx
  rol eax, cl
end;



function GetFigCount(var Board: TBoard): Byte;
var i, j: Integer;
  Val: CArdinal;
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
  Val: Word64; Shift: Byte;
begin

  Val := 9008;

{  Val := Val xor Board.LastMove.ToX;
  Val := Val xor Board.LastMove.ToY;
  Val := Val xor Board.LastMove.FromX;
  Val := Val xor Board.LastMove.FromY;
193745}

  if Board.H1RookMoveW then Val := Int64(Val) xor 123;
  if Board.A1RookMoveW then Val := Int64(Val) xor 234;
  if Board.KingMoveW then Val := Int64(Val) xor 345;
  if Board.H1RookMoveB then Val := Int64(Val) xor 456;
  if Board.A1RookMoveB then Val := Int64(Val) xor 567;
  if Board.KingMoveB then Val := Int64(Val) xor 678;


   for i := 1 to 8 do
   for j := 1 to 8 do
    begin
      Val := Val xor Int64((Board.Cells[i, j]) + 7) + i*j;
      shift := 15;
      Val := val shl shift or Val shr -shift;
   end;


   Result := abs(Val);
end;


end.

