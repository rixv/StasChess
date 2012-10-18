unit UHash;

interface

  uses ChessTypes, Dialogs, SysUtils;

const HASHSIZE = 10000;

type THashRecord=record
  Val: Integer;
end;

function GetHash(Board: TBoard): Cardinal;
procedure ClearHash;

var HashTable: array[0..HASHSIZE] of THashRecord;

implementation

procedure ClearHash;
var i: Cardinal;
begin
  for i := 0 to HASHSIZE do
    HashTable[i].Val := 0;
end;

function Rol32(Value, Shift: LongWord): LongWord;
asm
  mov ecx, edx
  rol eax, cl
end;


function GetHash(Board: TBoard): LongWord;
var i, j: Integer;
  Val: LongWord;
begin

  Val := 1;

  Val := Val xor Board.LastMove.ToX;
  Val := Val xor Board.LastMove.ToY;
  Val := Val xor Board.LastMove.FromX;
  Val := Val xor Board.LastMove.FromY;

  if Board.H1RookMoveW then Val := (Val) xor 1;
  if Board.A1RookMoveW then Val := (Val) xor 1;
  if Board.KingMoveW then Val := (Val) xor 1;
  if Board.H1RookMoveB then Val := (Val) xor 1;
  if Board.A1RookMoveB then Val := (Val) xor 1;
  if Board.KingMoveB then Val := (Val) xor 1;


  for i := 1 to 8 do
    for j := 1 to 8 do
    begin
      Val := Val xor (LongWord((Board.Cells[i, j]) + 6));
      Val := Rol32(Val, i + j);
      Val := Val xor (LongWord((Board.Cells[i, j]) + 6 + j + i));
      Val := Rol32(Val, LongWord((Board.Cells[i, j]) + 6));
   end;


    if Val > HASHSIZE then Val := Val mod HASHSIZE;

  Result := Val;
end;


end.

