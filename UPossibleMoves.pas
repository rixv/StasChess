unit UPossibleMoves;

interface

  uses SysUtils, ChessTypes, Dialogs, UIni, FastAsm;

  function QueenMoveCount(Board: TBoard; i, j: ShortInt): Byte;
  function RookMoveCount(Board: TBoard; i, j: ShortInt): Byte;
  function BishopMoveCount(Board: TBoard; i, j: ShortInt): Byte;
  function KnightMoveCount(Board: TBoard; i, j: ShortInt): Byte;
  function PieceMoveCount(Board: TBoard; i, j: Byte): Byte;

  function MoveCountWhite(Board: TBoard): Word;
  function MoveCountBlack(Board: TBoard): Word;

  function PossibleMovesWhite(Board: TBoard): TMoves;
  function DoMove(Board: TBoard; Move: TMove): TBoard;
  function PossibleMovesBlack(Board: TBoard): TMoves;
  function ApplyMoves(Board: TBoard; SMoves: String): TBoard;
  function ThreatTo(BoardA: TBoard; x, y: Integer; Color: Boolean): Boolean;
  function ThreatToKing(Board: TBoard; Color: Boolean): Boolean;
  procedure qSort(var Ar:TMoves; low, high: Integer);
implementation


function ThreatToKing(Board: TBoard; Color: Boolean): Boolean;
var I, j, King: Integer;
begin
  Result := False;
  if Color then King := 6 else King := -6;
  for i := 1 to 8 do
  for j := 1 to 8 do
  begin
    if Board.Cells[i, j] = King then
    begin
      Result := ThreatTo(Board, i, j, Color);
      break;
    end;
  end;

end;

function ThreatTo(BoardA: TBoard; x, y: Integer; Color: Boolean): Boolean;
var i, j, a, b, t, n, m: Integer; Board: TBoard;
begin

  Result := False;

  i := x;
  j := y;

  if not Color then
  begin
    for a := 1 to 8 do
    for b := 1 to 8 do
    begin
      Board.Cells[a, b] := - BoardA.Cells[a, 9 - b];
    end;

     j := 9 - y;
  end else Board := BoardA;


    a := i + 1;
    b := j + 1;
    if (a in [1..8]) and (b in [1..8]) and (Board.Cells[a, b] = -1) then
    begin
      Result := True;
      exit;
    end;

    a := i - 1;
    b := j + 1;
    if (a in [1..8]) and (b in [1..8]) and (Board.Cells[a, b] = -1) then
    begin
      Result := True;
      exit;
    end;


    for n := -1 to 1 do
    for m := -1 to 1 do
    if (n <> 0) or (m <> 0) then
    begin
      a := n + i;
      b := m + j;

      if (a in [1..8]) and (b in [1..8]) then
        t := board.cells[a, b]
      else t := 1;

      while (t <= 0) do
      begin
        if (t < 0) then
        begin
          if (t = -5) and ((n <> 0) or (m <> 0)) then
          begin
            Result := True;
            exit;
          end;
          if (t = -4) and (abs(n + m) = 1) then
          begin
            Result := True;
            exit;
          end;
          if (t = -3) and (n <> 0) and (m <> 0) then
          begin
            Result := True;
            exit;
          end;
          a := -1;
        end;

        a := a + n;
        b := b + m;

        if (a in [1..8]) and (b in [1..8]) then
          t := board.cells[a, b]
        else
          t := 1;
      end;

    end;



   if i <= 6 then
   begin
      if (j <= 7) then
      begin
      if (Board.Cells[i + 2, j + 1] = -2) then
        begin
          Result := True;
          exit;
        end;
      end;

       if (j >= 2) then
       begin
         if Board.Cells[i + 2, j - 1] = -2 then
         begin
           Result := True;
           exit;
         end;
       end;

   end;

   if i >= 3 then
   begin
          if (j <= 7) then
          begin
            if Board.Cells[i - 2, j + 1] = -2 then
            begin
                Result := True;
                exit;
            end;
          end;

          if (j >= 2) then
          begin
            if (Board.Cells[i - 2, j - 1] = -2) then
            begin
                Result := True;
                exit;
            end;
          end;
   end;


   if i <= 7 then
   begin
          if (j <= 6) then
          begin
            if Board.Cells[i + 1, j + 2] = -2 then
            begin
                Result := True;
                exit;
            end;
          end;

          if (j >= 3) then
          begin
            if Board.Cells[i + 1, j - 2] = -2 then
            begin
                Result := True;
                exit;
            end;
          end;
    end;


    if i >= 2 then
    begin
          if (j <= 6) then
          begin
            if Board.Cells[i - 1, j + 2] = -2 then
            begin
                Result := True;
                exit;
            end;
          end;
          if (j >= 3) then
          begin
            if Board.Cells[i - 1, j - 2] = -2 then
            begin
                Result := True;
                exit;
            end;
          end;
    end;

end;

function Castling(Board: TBoard; Move: TMove): Boolean;
begin
//
end;


function DoMove(Board: TBoard; Move: TMove): TBoard;
var SMoves: String; j:integer;
begin
  Result := Board;
  Result.Cells[Move.FromX, Move.FromY] := 0;
  if (Move.Transform <> #0) then
  begin
    case Move.Transform of
    'q': Result.Cells[Move.ToX, Move.ToY] := 5 * Board.Cells[Move.FromX, Move.FromY];
    'r': Result.Cells[Move.ToX, Move.ToY] := 4 * Board.Cells[Move.FromX, Move.FromY];
    'b': Result.Cells[Move.ToX, Move.ToY] := 3 * Board.Cells[Move.FromX, Move.FromY];
    'n': Result.Cells[Move.ToX, Move.ToY] := 2 * Board.Cells[Move.FromX, Move.FromY];
    end;
  end else
  begin

    if (Board.Cells[Move.FromX, Move.FromY] = 4) and (Move.FromX = 1) then
      Result.A1RookMoveW := True;
    if (Board.Cells[Move.FromX, Move.FromY] = 4) and (Move.FromX = 8) then
      Result.H1RookMoveW := True;
    if (Board.Cells[Move.FromX, Move.FromY] = -4) and (Move.FromX = 1) then
      Result.A1RookMoveB := True;
    if (Board.Cells[Move.FromX, Move.FromY] = -4) and (Move.FromX = 8) then
      Result.H1RookMoveB := True;

    if (Board.Cells[Move.FromX, Move.FromY] = 6) then
      Result.KingMoveW := True;
    if (Board.Cells[Move.FromX, Move.FromY] = -6) then
      Result.KingMoveB := True;



    if  (Move.FromX <> Move.ToX) and (Board.Cells[Move.ToX, Move.ToY] = 0) and
        (abs(Board.Cells[Move.fromx, Move.fromy]) = 1) and (abs(Board.Cells[Move.ToX, Move.FromY]) = 1) then
    begin
      Result.Cells[Move.ToX, Move.FromY] := 0;
    end;

    ///
    Result.Cells[Move.ToX, Move.ToY] := Board.Cells[Move.FromX, Move.FromY];
    ///

    if (Move.ToX = 7) and (Move.ToY = 1) and (Move.FromX = 5) and (Move.FromY = 1) and (Board.Cells[Move.FromX, Move.FromY] = 6) then
    begin
      Result.Cells[8, 1] := 0;
      Result.Cells[6, 1] := Board.Cells[8, 1];
      Result.KingMoveW := true;
    end;
    if (Move.ToX = 3) and (Move.ToY = 1) and (Move.FromX = 5) and (Move.FromY = 1) and (Board.Cells[Move.FromX, Move.FromY] = 6) then
    begin
      Result.Cells[1, 1] := 0;
      Result.Cells[4, 1] := Board.Cells[1, 1];
      Result.KingMoveW := true;
    end;

    if (Move.ToX = 7) and (Move.ToY = 8) and (Move.FromX = 5) and (Move.FromY = 8) and (Board.Cells[Move.FromX, Move.FromY] = -6) then
    begin
      Result.Cells[8, 8] := 0;
      Result.Cells[6, 8] := Board.Cells[8, 8];
      Result.KingMoveB := true;
    end;
    if (Move.ToX = 3) and (Move.ToY = 8) and (Move.FromX = 5) and (Move.FromY = 8) and (Board.Cells[Move.FromX, Move.FromY] = -6) then
    begin
      Result.Cells[1, 8] := 0;
      Result.Cells[4, 8] := Board.Cells[1, 8];
      Result.KingMoveB := true;
    end;
  end;

  Result.LastMove := Move;
end;


function AddMove(var Moves: TMoves; i, j, a, b, iSort: Integer; S: Char): TMoves;
begin
  Inc(Moves.Count);
  with Moves.Move[Moves.Count] do
  begin
    Transform := S;
    FromX := i;
    FromY := j;
    ToX := a;
    ToY := b;
    Sort := iSort;
  end;
  Result := Moves;
end;



function BishopMoves(var Moves: TMoves; Board: TBoard; i, j: ShortInt): TMoves;
var a, b, t, x, y: ShortInt;
begin

  for x := -1 to 1 do
  for y := -1 to 1 do
    if (x <> 0) and (y <> 0) then
    begin
      a := i + x;
      b := j + y;

      if (a in [1..8]) and (b in [1..8]) then
        t := board.cells[a, b]
      else t := 1;

      while (t <= 0) do
      begin
        if t < 0 then
        begin

          Moves := AddMove(Moves, i, j, a, b, abs(t) * 100 - 3, #0);
          a := -1;
        end
        else
          Moves := AddMove(Moves, i, j, a, b, 5, #0);

        a := a + x;
        b := b + y;

        if (a in [1..8]) and (b in [1..8]) then
          t := board.cells[a, b]
        else
          t := 1;
       end;
     end;

     Result := Moves;

end;



function RookMoves(var Moves: TMoves; Board: TBoard; i, j: ShortInt): TMoves;
var a, b, t, x, y: ShortInt;
begin

  for x := -1 to 1 do
  for y := -1 to 1 do
    if abs(x + y) = 1 then
    begin
      a := i + x;
      b := j + y;

      if (a in [1..8]) and (b in [1..8]) then
        t := board.cells[a, b]
      else t := 1;

      while (t <= 0) do
      begin
        if t < 0 then
        begin
          Moves := AddMove(Moves, i, j, a, b, abs(t) * 100 - 4, #0);
          a := -1;
        end
        else
          Moves := AddMove(Moves, i, j, a, b, 8, #0);

        a := a + x;
        b := b + y;

        if (a in [1..8]) and (b in [1..8]) then
          t := board.cells[a, b]
        else
          t := 1;
       end;
     end;

     Result := Moves;

end;


function QueenMoves(var Moves: TMoves; Board: TBoard; i, j: ShortInt): TMoves;
var a, b, t, x, y: ShortInt;
begin

  for x := -1 to 1 do
  for y := -1 to 1 do
    if (x <> 0) or (y <> 0) then
    begin
      a := i + x;
      b := j + y;

      if (a in [1..8]) and (b in [1..8]) then
        t := board.cells[a, b]
      else t := 1;

      while (t <= 0) do
      begin
        if t < 0 then
        begin
          Moves := AddMove(Moves, i, j, a, b, abs(t) * 100 - 5, #0);
          a := -1;
        end
        else
          Moves := AddMove(Moves, i, j, a, b, 10, #0);

        a := a + x;
        b := b + y;

        if (a in [1..8]) and (b in [1..8]) then
          t := board.cells[a, b]
        else
          t := 1;
       end;
     end;

     Result := Moves;

end;



function KnightMoves(var Moves: TMoves; Board: TBoard; i, j: ShortInt): TMoves;
var a, b: ShortInt;
begin
    for a := -2 to 2 do
    for b := -2 to 2 do
      begin
        if (abs(a) <> abs(b)) and (a <> 0) and (b <> 0) then
        if ((a + i) in [1..8]) and ((b + j) in [1..8]) then
        if Board.Cells[i + a, j + b] <= 0 then
        if Board.Cells[i + a, j + b] < 0 then
          Moves := AddMove(Moves, i, j, i + a, j + b, abs(Board.Cells[i + a, j + b]) * 100 - 2, #0)
        else
          Moves := AddMove(Moves, i, j, i + a, j + b, 6, #0);
      end;
  Result := Moves;
end;


function PieceMoves(var Moves: TMoves; Board: TBoard; i, j: Byte): TMoves;
begin
  if Board.Cells[i, j + 1] = 0 then
  begin
    if j = 7 then
    begin
      Moves := AddMove(Moves, i, j, i, j + 1, 10000, 'q');
      Moves := AddMove(Moves, i, j, i, j + 1, 9000, 'r');
      Moves := AddMove(Moves, i, j, i, j + 1, 7000, 'b');
      Moves := AddMove(Moves, i, j, i, j + 1, 8000, 'n');
    end
    else
    begin
      Moves := AddMove(Moves, i, j, i, j + 1, 1, #0);
      if (j = 2) and (Board.Cells[i, j + 2] = 0) then
        Moves := AddMove(Moves, i, j, i, j + 2, 0, #0);
    end;
  end;

  if i < 8 then
  if (Board.Cells[i + 1, j + 1] < 0) then
  if j = 7 then
  begin
    Moves := AddMove(Moves, i, j, i + 1, j + 1, 10001, 'q');
    Moves := AddMove(Moves, i, j, i + 1, j + 1, 9001, 'r');
    Moves := AddMove(Moves, i, j, i + 1, j + 1, 7001, 'b');
    Moves := AddMove(Moves, i, j, i + 1, j + 1, 8001, 'n');
  end
  else
    Moves := AddMove(Moves, i, j, i + 1, j + 1, abs(Board.Cells[i + 1, j + 1])*100, #0);

  if i > 1 then
  if (Board.Cells[i - 1, j + 1] < 0)  then
  if j = 7 then
  begin
    Moves := AddMove(Moves, i, j, i - 1, j + 1, 10001, 'q');
    Moves := AddMove(Moves, i, j, i - 1, j + 1, 9001, 'r');
    Moves := AddMove(Moves, i, j, i - 1, j + 1, 7001, 'b');
    Moves := AddMove(Moves, i, j, i - 1, j + 1, 8001, 'n');
  end
  else
    Moves := AddMove(Moves, i, j, i - 1, j + 1, abs(Board.Cells[i - 1, j + 1])*100, #0);


  if (j = 5) and (Board.LastMove.ToY = 5) and (Board.LastMove.FromY = 7) then
  begin
    if Board.Cells[Board.LastMove.ToX, Board.LastMove.ToY] = -1 then
    begin
      if Board.LastMove.ToX = i - 1 then
        Moves := AddMove(Moves, i, j, i - 1, j + 1, 101, #0);
      if Board.LastMove.ToX = i + 1 then
        Moves := AddMove(Moves, i, j, i + 1, j + 1, 101, #0);
    end;
  end;


  Result := Moves;
end;


function KingMoves(var Moves: TMoves; Board: TBoard; i, j: Byte): TMoves;
var a, b, x, y, t: ShortInt;
begin

  if not Board.KingMoveW and not Board.H1RookMoveW then
  begin
    if (Board.Cells[7,1] = 0) and (Board.Cells[6,1] = 0) then
    if not ThreatTo(Board, 5, 1, True) then
    if not ThreatTo(Board, 7, 1, True) then
    if not ThreatTo(Board, 6, 1, True) then
    if (i = 5) and (j = 1) then
    begin
      Moves := AddMove(Moves, i, j, i + 2, j, 6, #0);
    end;
  end;

  if not Board.KingMoveW and not Board.A1RookMoveW then
  begin
    if (Board.Cells[2,1] = 0) and (Board.Cells[3,1] = 0) and (Board.Cells[4,1] = 0) then
    if not ThreatTo(Board, 5, 1, True) then
    if not ThreatTo(Board, 3, 1, True) then
    if not ThreatTo(Board, 4, 1, True) then
    if not ThreatTo(Board, 2, 1, True) then
    if (i = 5) and (j = 1) then
    begin
      Moves := AddMove(Moves, i, j, i - 2, j, 6, #0);
    end;
  end;

  for x := -1 to 1 do
  for y := -1 to 1 do
    if (x <> 0) or (y <> 0) then
    begin
      a := i + x;
      b := j + y;

      if (a in [1..8]) and (b in [1..8]) then
        t := board.cells[a, b]
      else t := 1;

      if t < 0 then
        Moves := AddMove(Moves, i, j, A, b, abs(t) * 100 - 6, #0);
      if t = 0 then
        Moves := AddMove(Moves, i, j, a, B, 0, #0);

    end;

  Result := Moves;
end;


function PossibleMovesWhite(Board: TBoard): TMoves;
var I, J, a, b, t: Integer;
    Smoves: String;
begin
  Result.Count := 0;

  for i := 1 to 8 do
  for j := 1 to 8 do
  begin

    if Board.Cells[i, j] > 0 then
    begin

      case Board.Cells[i, j] of
      1: Result := PieceMoves(Result, Board, i, j);
      2: Result := KnightMoves(Result, Board, i, j);
      3: Result := BishopMoves(Result, Board, i, j);
      4: Result := RookMoves(Result, Board, i, j);
      5: Result := QueenMoves(Result, Board, i, j);
      6: Result := KingMoves(Result, Board, i, j);
      end;

    end;
  end;

  if Result.Count > 1 then
    qSort(Result, 1, Result.Count);

end;










function PossibleMovesBlack(Board: TBoard): TMoves;
var i, j: Integer; InvBoard: TBoard; Tmp: Boolean;
begin
  for i := 1 to 8 do
  for j := 1 to 8 do
  begin
    InvBoard.Cells[i, j] := - Board.Cells[i, 9 - j];
  end;

  InvBoard.H1RookMoveW := Board.H1RookMoveB;
  InvBoard.A1RookMoveW := Board.A1RookMoveB;
  InvBoard.KingMoveW := Board.KingMoveB;
  InvBoard.H1RookMoveB := Board.H1RookMoveW;
  InvBoard.A1RookMoveB := Board.A1RookMoveW;
  InvBoard.KingMoveB := Board.KingMoveW;

  InvBoard.LastMove.ToY := (9 - Board.LastMove.ToY);
  InvBoard.LastMove.FromY := (9 - Board.LastMove.FromY);
  InvBoard.LastMove.ToX := Board.LastMove.ToX;
  InvBoard.LastMove.FromX := Board.LastMove.FromX;



  Result := PossibleMovesWhite(InvBoard);



  for i := 1 to Result.Count do
  begin
    Result.Move[i].ToY := 9 - Result.Move[i].ToY;
    Result.Move[i].FromY := 9 - Result.Move[i].FromY;
  end;

end;


function ApplyMoves(Board: TBoard; SMoves: String): TBoard;
var Buf: String;  I: Integer;
begin
  Result := Board;
  if SMoves = '' then exit;
  Buf := '';
  for i := 1 to Length(SMoves) do
  begin
    if SMoves[i] = ' ' then
    begin
      Board := DoMove(Board, ConvertStrToMove(Buf));
      Buf := '';
    end
    else
      Buf := Buf + SMoves[i];
  end;

    if Board.Cells[ConvertStrToMove(Buf).FromX, ConvertStrToMove(Buf).FromY] > 0 then
    Board.EngineColor := False else Board.EngineColor := True;

    Result := DoMove(Board, ConvertStrToMove(Buf));
end;

procedure qSort(var Ar:TMoves; low, high: Integer);
var i,j:integer;
    m: Integer; Wsp: TMove;
begin
  i:= low;
  j:= high;
  M:= -Ar.Move[(i+j) div 2].Sort;
  repeat
    while(-Ar.Move[i].Sort < m) do i := i + 1;
    while(-Ar.Move[j].Sort > m) do j := j - 1;
    if(i <= j) then
    begin
      wsp := ar.Move[i];
      ar.Move[i] := ar.Move[j];
      ar.Move[j] := wsp;
      i:= i + 1;
      j:= j - 1;
    end;
  until (i > j);
  if (low < j) then qSort(ar, low, j);
  if (i < high) then qSort(ar, i, high);
end;




function MoveCountWhite(Board: TBoard): Word;
var I, J, a, b, t: Integer;
begin
  Result := 0;

  for i := 1 to 8 do
  for j := 1 to 8 do
  begin

    if Board.Cells[i, j] > 0 then
    begin

      case Board.Cells[i, j] of
      1: Result := Result + PieceMoveCount(Board, i, j);
      2: Result := Result + KnightMoveCount(Board, i, j);
      3: Result := Result + BishopMoveCount(Board, i, j);
      4: Result := Result + RookMoveCount(Board, i, j);
      5: Result := Result + QueenMoveCount(Board, i, j);
      end;

    end;
  end;

end;

function MoveCountBlack(Board: TBoard): Word;
var i, j: Integer; InvBoard: TBoard; Tmp: Boolean;
begin
  for i := 1 to 8 do
  for j := 1 to 8 do
  begin
    InvBoard.Cells[i, j] := - Board.Cells[i, 9 - j];
  end;

  InvBoard.H1RookMoveW := Board.H1RookMoveB;
  InvBoard.A1RookMoveW := Board.A1RookMoveB;
  InvBoard.KingMoveW := Board.KingMoveB;
  InvBoard.H1RookMoveB := Board.H1RookMoveW;
  InvBoard.A1RookMoveB := Board.A1RookMoveW;
  InvBoard.KingMoveB := Board.KingMoveW;

  InvBoard.LastMove.ToY := (9 - Board.LastMove.ToY);
  InvBoard.LastMove.FromY := (9 - Board.LastMove.FromY);
  InvBoard.LastMove.ToX := Board.LastMove.ToX;
  InvBoard.LastMove.FromX := Board.LastMove.FromX;



  Result := MoveCountWhite(InvBoard);

end;




function BishopMoveCount(Board: TBoard; i, j: ShortInt): Byte;
var a, b, t, x, y: ShortInt;
begin
  Result := 0;

  for x := -1 to 1 do
  for y := -1 to 1 do
    if (x <> 0) and (y <> 0) then
    begin
      a := i + x;
      b := j + y;

      if (a in [1..8]) and (b in [1..8]) then
        t := board.cells[a, b]
      else t := 1;

      while (t <= 0) do
      begin
        if t < 0 then
        begin
          inc(Result);
          a := -1;
        end
        else
          inc(Result);

        a := a + x;
        b := b + y;

        if (a in [1..8]) and (b in [1..8]) then
          t := board.cells[a, b]
        else
          t := 1;
       end;
     end;


end;



function PieceMoveCount(Board: TBoard; i, j: Byte): Byte;
begin
  Result := 0;
  if Board.Cells[i, j + 1] = 0 then
  begin
      Inc(Result);
      if (j = 2) and (Board.Cells[i, j + 2] = 0) then Inc(Result);
  end;

  if i < 8 then
  if (Board.Cells[i + 1, j + 1] < 0) then
      Inc(Result);

  if i > 1 then
  if (Board.Cells[i - 1, j + 1] < 0)  then
      Inc(Result);
end;


function KnightMoveCount(Board: TBoard; i, j: ShortInt): Byte;
var a, b: ShortInt;
begin
  Result := 0;
    for a := -2 to 2 do
    for b := -2 to 2 do
      begin
        if (abs(a) <> abs(b)) and (a <> 0) and (b <> 0) then
        if ((a + i) in [1..8]) and ((b + j) in [1..8]) then
        if Board.Cells[i + a, j + b] <= 0 then
          Inc(Result);
      end;
end;



function QueenMoveCount(Board: TBoard; i, j: ShortInt): Byte;
var a, b, t, x, y: ShortInt;
begin
  Result := 0;

  for x := -1 to 1 do
  for y := -1 to 1 do
    if (x <> 0) or (y <> 0) then
    begin
      a := i + x;
      b := j + y;

      if (a in [1..8]) and (b in [1..8]) then
        t := board.cells[a, b]
      else t := 1;

      while (t <= 0) do
      begin
        if t < 0 then
        begin
          Inc(Result);
          a := -1;
        end
        else
          Inc(Result);

        a := a + x;
        b := b + y;

        if (a in [1..8]) and (b in [1..8]) then
          t := board.cells[a, b]
        else
          t := 1;
       end;
     end;

end;




function RookMoveCount(Board: TBoard; i, j: ShortInt): Byte;
var a, b, t, x, y: ShortInt;
begin

  Result := 0;

  for x := -1 to 1 do
  for y := -1 to 1 do
    if abs(x + y) = 1 then
    begin
      a := i + x;
      b := j + y;

      if (a in [1..8]) and (b in [1..8]) then
        t := board.cells[a, b]
      else t := 1;

      while (t <= 0) do
      begin
        if t < 0 then
        begin
          Inc(Result);
          a := -1;
        end
        else
          Inc(Result);

        a := a + x;
        b := b + y;

        if (a in [1..8]) and (b in [1..8]) then
          t := board.cells[a, b]
        else
          t := 1;
       end;
     end;


end;




end.