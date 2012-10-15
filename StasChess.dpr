program StasChess;
{$APPTYPE CONSOLE}
uses
  SysUtils,
  Dialogs,
  StrUtils,
  Classes,
  ChessTypes in 'ChessTypes.pas',
  UPossibleMoves in 'UPossibleMoves.pas',
  UIni in 'UIni.pas',
  UCI in 'UCI.pas',
  FastAsm in 'FastAsm.pas',
  UHash in 'UHash.pas';

var Nodes, HashNodes: LongInt;

function Estimator(BoardN: TBoard; CMove: Boolean): Integer;
var i, j: Integer; Sb, Sw: Boolean; Fig: Integer; k, l: Integer;
PMoves: TMoves; BCnt: Word;
begin

  Result := 0;
  Result := MoveCountWhite(BoardN)*3;
  BCnt := MoveCountBlack(BoardN)*3;
  Result := Result - Bcnt;


  for i := 1 to 8 do
  for j := 1 to 8 do
  begin

    Fig := BoardN.Cells[i, j];
            {
    if Fig > 3 then
    begin
      Sw := ThreatTo(BoardN, i, j, True);
      if Sw then Result := Result - Fig*6;
    end;

    if Fig < -3 then
    begin
      Sb := ThreatTo(BoardN, i, j, False);
      if Sb then Result := Result - Fig*6;
    end;
           }


    if (Fig = 1) or (Fig = -1) then
    begin
    {  Sw := ThreatTo(BoardN, i, j, True);
      Sb := ThreatTo(BoardN, i, j, False);

      if Sb and (BoardN.Cells[i, j] > 0) then
        Result := Result + 10;

      if Sw and (BoardN.Cells[i, j] > 0) then
        Result := Result + 4 else Result := Result - 10;


      if Sb and (BoardN.Cells[i, j] < 0) then
        Result := Result - 4 else Result := Result + 10;

      if Sw and (BoardN.Cells[i, j] < 0) then
        Result := Result - 10; }

      if (BoardN.Cells[i, j] = 1) then
      for k := j + 1 to 7 do
      begin
        if BoardN.Cells[i, k] = 1 then Result := Result - 30;
      end;

      if (BoardN.Cells[i, j] = -1) then
      for k := j - 1 downto 2 do
      begin
        if BoardN.Cells[i, k] = -1 then Result := Result + 30;
      end;

      if (BoardN.Cells[i, j] = 1) then
        Result := Result + trunc(j*j*j/3);

      if (BoardN.Cells[i, j] = -1) then
        Result := Result - trunc((9-j)*(9-j)*(9-j)/3);

    end;

    case Fig of

      1: Result := Result + 95;
     -1: Result := Result - 95;
      6: Result := Result + 50000;
     -6: Result := Result - 50000;
      2: Result := Result + 340;
     -2: Result := Result - 340;
      3: Result := Result + 340;
     -3: Result := Result - 340;
      4: Result := Result + 540;
     -4: Result := Result - 540;
      5: Result := Result + 940;
     -5: Result := Result - 940;
    end;



 {   if BoardN.Cells[i, j] > 0 then
      Result := Result + BoardN.Cells[i, j]*j;

    if BoardN.Cells[i, j] < 0 then
      Result := Result + BoardN.Cells[i, j]*(9 - j);
  }

  end;

{
  Result := Result + BoardN.Cells[5, 4]*2;
  Result := Result + BoardN.Cells[4, 4]*2;

  Result := Result + BoardN.Cells[5, 5]*2;
  Result := Result + BoardN.Cells[4, 5]*2;;
}

 //result := result + random(4);
 inc(Nodes);

end;


function MinMax(Board: TBoard; Depth, iDepth, Alpha, Beta: Integer; CMove: Boolean): TMove;
var PMoves: TMoves; i, Val, BestVal: Integer; BestMove: TMove; CheckBoard: TBoard;
  Hash: LongWord;  rDepth, riDepth: Byte; SMoves: String;
begin

  BestMove.Sort := -99999;
  BestMove.FromX := 1;
  BestMove.FromY := 1;
  BestMove.ToX := 1;
  BestMove.ToY := 1;
  BestMove.Transform := #0;
  BestMove.Eval := 0;
  riDepth := iDepth;
  rDepth := Depth;



  If Depth > 0 then

    If CMove then
    begin
      BestVal := -9999;

      PMoves := PossibleMovesWhite(Board);

      if PMoves.Count = 0 then
      begin
        if ThreatToKing(Board, True) then Val := -9000 - Depth else Val := 0;
        BestVal := Val;
      end
      else
      begin
        for I := 1 to PMoves.Count do
        begin

          CheckBoard := DoMove(Board, PMoves.Move[i]);
          Hash := GetHash(CheckBoard);

//          if (Depth <> 1) and (i > PMoves.Count / 1.0) then  rDepth :=  1 else rDepth := 0;

          if (Depth = 1) and (iDepth > 0) and (PMoves.Move[i].Sort > 50)
            then riDepth := iDepth - 1 else rDepth := Depth - 1;

          Val := MinMax(CheckBoard, rDepth, riDepth, Alpha, Beta, not CMove).Eval;


          HashTable[Hash].Val := Val - Alpha;

          if Val > Alpha then
          begin

            Alpha := Val;
            BestVal := Val;
            BestMove := PMoves.Move[i];
          end;
          if Beta <= Alpha then Break;
       end;
     end;
    end
    else
    begin
      BestVal := 9999;
      PMoves := PossibleMovesBlack(Board);

      if PMoves.Count < 0 then ShowMessage(IntTOStr(PMoves.Count));

      if PMoves.Count = 0 then
      begin
        if ThreatToKing(Board, False) then Val := 9000 + Depth else Val := 0;
        BestVal := Val;
      end
      else
      begin
        for I := 1 to PMoves.Count do
        begin
          CheckBoard := DoMove(Board, PMoves.Move[i]);
          Hash := GetHash(CheckBoard);

  //        if (Depth <> 1) and (i > PMoves.Count / 1.0) then  rDepth :=  1 else rDepth := 0;

          if (Depth = 1) and (iDepth > 0) and (PMoves.Move[i].Sort > 50)
            then riDepth := iDepth - 1 else rDepth := Depth - 1;

            Val := MinMax(CheckBoard, rDepth, riDepth, Alpha, Beta, not CMove).Eval;

          HashTable[Hash].Val := Beta - Val;

          if Val < Beta then
          begin
            Beta := Val;
            BestVal := Val;
            BestMove := PMoves.Move[i];
          end;
          if Beta <= Alpha then Break;
        end;
      end;
    end;


  if Depth = 0 then
  begin
    BestVal := Estimator(Board, CMove);
  end;

  Result := BestMove;
  Result.Eval := BestVal;


end;


var
  i, j, nc: LongWord;

  Board: TBoard;
  BestMove: TMove;
  n, NullCount: Integer;
  s, SMoves: String;
  SL: TStringList;
  IsBlack: Boolean;
  MainDepth: Word;
begin

  ClearHash;
  Nodes := 0;
  HashNodes := 0;
  randomize;
  IsBlack := False;
  SL := TStringList.Create;
  SetupInput;
  WriteString('; ' + 'StasChess' + ' - Winboard/UCI chess engine');
  IniBoard(Board);
  Repeat
    n := PeekInput;
    if n = 0 then begin
      sleep(100);
      continue;
    end;
    s := ReadInput(n);

   if s = 'quit' then begin SL.SaveToFile('LOG.LOG'); exit; end;
   if s = 'isready' then begin
     WriteString('readyok');
   end;
   if s = 'uci' then begin
     WriteString('id name ' + 'StasChess');
     WriteString('id author Dovgiy Stanislav');
     WriteString('option name Hash type spin default 4 min 4 max 64');
     WriteString('option name Elo type spin default 2600 min 1000 max 2600');
     WriteString('uciok');


   end;

   if (s[1] = 'g') and (s[2] = 'o') then
   begin

     HashNodes := 0;
     ClearHash;


     if GetEndSpiel(Board) then MainDepth := 5 else MainDepth := 6;

     for i := 1 to MainDepth do
     begin
       BestMove := MinMax(Board, i, 3, -65530, 65530, Board.EngineColor);

       WriteString('info depth '+IntToStr(i)+' score cp '+ IntToStr(-BestMove.Eval)) ;
       sleep(20);
     end;

    { nc := 0;
     for i := 0 to HASHSIZE do
     if HashTable[i].Val <> 0 then
       inc(nc);
     ShowMessage(IntToStr(NC));
     }

     WriteString('bestmove ' + ConvertMoveTOStr(BestMove));
     SL.Add(ConvertMoveTOStr(BestMove));

     WriteString('info depth ' + IntToStr(i) +' nodes '+IntToStr(Nodes)+' score cp '
     + IntToStr(-BestMove.Eval)+ ' time 0 nodes ' + IntToStr(Nodes) + ' pv ' + ConvertMoveTOStr(BestMove)
     + ' str '+ IntToStr(Nodes));
   end;

     NOdes := 0;
     WriteString('info depth '+ IntToStr(i) +' score cp '+ IntToStr(-BestMove.Eval) + ' nodes ' + IntToStr(Nodes));



   if s = 'stop' then
   begin
     WriteString('bestmove ' + ConvertMoveTOStr(BestMove));
   end;

   if PosEx('position startpos', s) = 1 then
   begin
     IniBoard(Board);
     Board.EngineColor := True;
   end;


   if PosEx('position startpos moves', s) = 1 then
   begin
     IniBoard(Board);
     if Pos('moves', S) > 0 then
       SMoves := Copy(S, Pos('moves', S) + 6, Length(S));
     Board := ApplyMoves(Board, SMoves);
   end;


   if PosEx('position fen ', s) = 1 then
   begin     //ShowMessage(S);

     if Pos('moves', S) > 0 then
       SMoves := Copy(S, Pos('moves', S) + 6, Length(S));

     NullCount := 0;  NC := 1;

     S := Copy(s, 14, Length(S));

     ClearBoard(Board);
     for j := 8 downto 1 do
     for i := 1 to 8 do
     begin

       if S[NC] = '/' then INC(NC);

       if NullCount = 0 then
       begin
         NullCount := StrToIntDef(S[NC], 0);
         if NullCount <> 0 then Inc(NC);
       end;

       if NullCount = 0 then
       begin
         case S[NC] of
          'P': Board.Cells[i, j] := WHITEPAWN;
          'N': Board.Cells[i, j] := WHITEKNIGHT;
          'B': Board.Cells[i, j] := WHITEBISHOP;
          'R': Board.Cells[i, j] := WHITEROOK;
          'Q': Board.Cells[i, j] := WHITEQUEEN;
          'K': Board.Cells[i, j] := WHITEKING;
          'p': Board.Cells[i, j] := BLACKPAWN;
          'n': Board.Cells[i, j] := BLACKKNIGHT;
          'b': Board.Cells[i, j] := BLACKBISHOP;
          'r': Board.Cells[i, j] := BLACKROOK;
          'q': Board.Cells[i, j] := BLACKQUEEN;
          'k': Board.Cells[i, j] := BLACKKING;
         end;
         Inc(NC);
       end else begin dec(NullCount); Board.Cells[i, j] := 0; end;
     end;

     Board := ApplyMoves(Board, SMoves);

    // if ThreatTo(Board, 5, 8, True) then ShowMessage(';');
   end;

  { Smoves := '';
   for j := 8 downto 1 do
   for i := 1 to 8 do
   begin
     Smoves := SMoves + '[' + IntToStr(Board.Cells[i, j]) + ']';
     if i = 8 then Smoves := SMoves + #13;
   end;
   }
  // ShowMessage(SMoves);


   S := '';


  until false;


  readln;

end.
