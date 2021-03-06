unit ChessTypes;

interface

const
  WHITEPAWN = 1;
  BLACKPAWN = -1;
  WHITEKNIGHT = 2;
  WHITEBISHOP = 3;
  WHITEROOK = 4;
  WHITEQUEEN = 5;
  WHITEKING = 6;
  BLACKKNIGHT = -2;
  BLACKBISHOP = -3;
  BLACKROOK = -4;
  BLACKQUEEN = -5;
  BLACKKING = -6;





type TEasyMove = record
  FromX: Byte;
  FromY: Byte;
  ToX: Byte;
  ToY: Byte;
  Transform: Char;
end;

type TPVMoves = record
   Moves: array[1..10] of TEasyMove;
   Depth: Byte;
end;

type TMove = record
  FromX: Byte;
  FromY: Byte;
  ToX: Byte;
  ToY: Byte;
  Transform: Char;
  Eval: Integer;
  Sort: Integer;
end;

type TBoard = record
   Cells: array[1..8, 1..8] of Integer;
   H1RookMoveW: Boolean;
   A1RookMoveW: Boolean;
   KingMoveW: Boolean;
   H1RookMoveB: Boolean;
   A1RookMoveB: Boolean;
   KingMoveB: Boolean;
   EngineColor: Boolean;
   LastMove: TMove;
end;



type TMoves = record
  Move: array[1..90] of TMove;
  Count: Integer;
end;

function EasyMoveToMove(A: TEasyMove): TMove;
function MoveToEasyMove(A: TMove): TEasyMove;


implementation

function EasyMoveToMove(A: TEasyMove): TMove;
begin
  Result.FromX := A.FromX;
  Result.FromY := A.FromY;
  Result.ToX := A.ToX;
  Result.ToY := A.ToY;
  Result.Transform := A.Transform;
end;

function MoveToEasyMove(A: TMove): TEasyMove;
begin
  Result.FromX := A.FromX;
  Result.FromY := A.FromY;
  Result.ToX := A.ToX;
  Result.ToY := A.ToY;
  Result.Transform := A.Transform;
end;



end.

