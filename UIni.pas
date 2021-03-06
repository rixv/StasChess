unit UIni;

interface

uses SysUtils, ChessTypes, Dialogs;

Procedure IniBoard(var Board: TBoard);
Function ConvertMoveToStr(Move: TMove): String;
procedure ClearBoard(var Board: TBoard);
function ConvertStrToMove(SMove: String): TMove;
implementation

function ConvertStrToMove(SMove: String): TMove;
begin

  case SMove[1] of
    'a': result.FromX := 1;
    'b': result.FromX := 2;
    'c': result.FromX := 3;
    'd': result.FromX := 4;
    'e': result.FromX := 5;
    'f': result.FromX := 6;
    'g': result.FromX := 7;
    'h': result.FromX := 8;
  end;

  result.FromY := StrToINt(SMove[2]);

  case SMove[3] of
    'a': result.ToX := 1;
    'b': result.ToX := 2;
    'c': result.ToX := 3;
    'd': result.ToX := 4;
    'e': result.ToX := 5;
    'f': result.ToX := 6;
    'g': result.ToX := 7;
    'h': result.ToX := 8;
  end;

  result.ToY := StrToINt(SMove[4]);

  if Length(SMove) > 4 then
  begin
    if SMove[5] in ['q', 'n', 'b', 'r'] then
    begin
      Result.Transform := SMove[5];
    end;
  end else Result.Transform := #0;

end;

Function ConvertMoveToStr(Move: TMove): String;
begin
  Result := '';
  case Move.FromX of
    1: Result := 'a';
    2: Result := 'b';
    3: Result := 'c';
    4: Result := 'd';
    5: Result := 'e';
    6: Result := 'f';
    7: Result := 'g';
    8: Result := 'h';
  end;

  Result := Result + IntToStr(Move.FromY);

  case Move.ToX of
    1: Result := Result + 'a';
    2: Result := Result + 'b';
    3: Result := Result + 'c';
    4: Result := Result + 'd';
    5: Result := Result + 'e';
    6: Result := Result + 'f';
    7: Result := Result + 'g';
    8: Result := Result + 'h';
  end;

  Result := Result + IntToStr(Move.ToY);

  if Move.Transform = 'q' then
    Result := Result + Move.Transform;
  if Move.Transform = 'r' then
    Result := Result + Move.Transform;
  if Move.Transform = 'b' then
    Result := Result + Move.Transform;
  if Move.Transform = 'n' then
    Result := Result + Move.Transform;


end;


procedure ClearBoard(var Board: TBoard);
var I, J: Integer;
begin

  Board.LastMove.FromX := 1;
  Board.LastMove.FromY := 1;
  Board.LastMove.ToX := 1;
  Board.LastMove.ToY := 1;

  Board.H1RookMoveW := False;
  Board.A1RookMoveW := False;
  Board.KingMoveW := False;
  Board.H1RookMoveB := False;
  Board.A1RookMoveB := False;
  Board.KingMoveB := False;
  Board.EngineColor := False;

  for i := 1 to 8 do
    for j := 1 to 8 do
      Board.Cells[i, j] := 0;
end;

Procedure IniBoard(var Board: TBoard);
begin

  ClearBoard(Board);
  Board.EngineColor := false;

  Board.Cells[1, 2] := 1;
  Board.Cells[2, 2] := 1;
  Board.Cells[3, 2] := 1;
  Board.Cells[4, 2] := 1;
  Board.Cells[5, 2] := 1;
  Board.Cells[6, 2] := 1;
  Board.Cells[7, 2] := 1;
  Board.Cells[8, 2] := 1;

  Board.Cells[5, 1] := 6;
  Board.Cells[5, 8] := -6;

  Board.Cells[4, 1] := 5;
  Board.Cells[4, 8] := -5;

  Board.Cells[3, 1] := 3;
  Board.Cells[3, 8] := -3;
  Board.Cells[6, 1] := 3;
  Board.Cells[6, 8] := -3;

  Board.Cells[2, 1] := 2;
  Board.Cells[2, 8] := -2;
  Board.Cells[7, 1] := 2;
  Board.Cells[7, 8] := -2;

  Board.Cells[1, 1] := 4;
  Board.Cells[1, 8] := -4;
  Board.Cells[8, 1] := 4;
  Board.Cells[8, 8] := -4;


  Board.Cells[1, 7] := -1;
  Board.Cells[2, 7] := -1;
  Board.Cells[3, 7] := -1;
  Board.Cells[4, 7] := -1;
  Board.Cells[5, 7] := -1;
  Board.Cells[6, 7] := -1;
  Board.Cells[7, 7] := -1;
  Board.Cells[8, 7] := -1;

end;

end.
