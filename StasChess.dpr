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
  UHash in 'UHash.pas',
  Eval in 'Eval.pas';

var Nodes, HashNodes, AlphaBeta, OffCuts: LongInt;


procedure Relax;
begin
  WriteString('info nodes '+IntToStr(Nodes)+
  ' hashfull ' + IntToStr(HashFullness) +
  ' string ' + 'hash: ' + IntToStr(HashNodes));

end;


function MinMax(Board: TBoard; Depth, Alpha, Beta: Integer; var Pv: TPVMoves; CMove, OnlyCaptures: Boolean): TMove;
var PMoves: TMoves; i, Val, BestVal, CapVal: Integer; CheckBoard: TBoard;
  Hash: Int64;  rDepth, BestMoveIndex: Byte; HashIndex: Cardinal;
begin

  BestMoveIndex := 1;
  BestVal := -8000;


    if (Nodes <> 0) and ((Nodes mod 400000) = 0) then
      Relax;

    If Depth > 0 then
    begin
    If CMove then
    begin

      PMoves := PossibleMovesWhite(Board);

      if PMoves.Count > 1 then
      begin
        for I := 1 to PMoves.Count do
        begin
          if (PMoves.Move[i].Sort < 30) then
          begin
             if (Killers[Depth, 1].FromX = PMoves.Move[i].FromX) and
                (Killers[Depth, 1].FromY = PMoves.Move[i].FromY) and
                (Killers[Depth, 1].ToY = PMoves.Move[i].ToY) and
                (Killers[Depth, 1].ToX = PMoves.Move[i].ToX)
              then
                PMoves.Move[i].Sort := 30
              else
                if (Killers[Depth, 2].FromX = PMoves.Move[i].FromX) and
                  (Killers[Depth, 2].FromY = PMoves.Move[i].FromY) and
                  (Killers[Depth, 2].ToY = PMoves.Move[i].ToY) and
                  (Killers[Depth, 2].ToX = PMoves.Move[i].ToX)
                then
                  PMoves.Move[i].Sort := 29;
           end;
        end;
        qSort(PMoves, 1, PMoves.Count);
      end;

      if PMoves.Count = 0 then
      begin
        if ThreatToKing(Board, True) then Val := -9000 - Depth else Val := 0;
        BestVal := Val;
      end
      else
      begin

        for I := 1 to PMoves.Count do
        begin
          if OnlyCaptures and (PMoves.Move[i].Sort < 30) then Continue;

          CheckBoard := DoMove(Board, PMoves.Move[i]);
         // Hash := GetHash(CheckBoard);
        //  HashIndex := abs(Hash) mod HashSize;


          if (Depth = 1) and ThreatToKing(CheckBoard, False) then
            rDepth := Depth
          else  rDepth := Depth - 1;




         if false and (HashTable[HashIndex].RealHash = Hash) and
         (HashTable[HashIndex].Depth >= rDepth)  then
         begin
           Val := HashTable[HashIndex].Val;
           Inc(HashNodes);
         end
         else
         begin
           if (rDepth = 0) and (PMoves.Move[i].Sort > 30) then
           begin
             if not OnlyCaptures then
             begin
                CapVal := Estimator(Board);
                inc(Nodes);
                if CapVal > Alpha then
                  Val := MinMax(CheckBoard, 1, CapVal, Beta, Pv, not CMove, True).Eval
                else
                  Val := MinMax(CheckBoard, 1, Alpha, Beta, Pv, not CMove, True).Eval;
                OnlyCaptures := True;
             end else
                Val := MinMax(CheckBoard, 1, Alpha, Beta, Pv, not CMove, True).Eval;
           end else
           Val := MinMax(CheckBoard, rDepth, Alpha, Beta, Pv, not CMove, OnlyCaptures).Eval;
         end;

          if Val > Alpha then
          begin
            if rDepth > 1 then
            begin
           //   HashTable[HashIndex].Val := Val;
           //   HashTable[HashIndex].Depth := rDepth;
           //   HashTable[HashIndex].RealHash := Hash;
            end;

            Alpha := Val;
            BestMoveIndex := i;
            inc(AlphaBeta);
            if PMoves.Move[i].Sort < 30 then
            begin
              Killers[Depth, 2] := Killers[Depth, 1];
              Killers[Depth, 1] := PMoves.Move[i];
            end;
          end;
          BestVal := Alpha;
          if Beta <= Alpha then begin Inc(OffCuts); Break; end;
       end;
     end;
    end
    else
    begin
      PMoves := PossibleMovesBlack(Board);

      if PMoves.Count > 1 then
      begin
        for I := 1 to PMoves.Count do
        begin
          if (PMoves.Move[i].Sort < 30) then
          begin
             if (Killers[Depth, 1].FromX = PMoves.Move[i].FromX) and
                (Killers[Depth, 1].FromY = PMoves.Move[i].FromY) and
                (Killers[Depth, 1].ToY = PMoves.Move[i].ToY) and
                (Killers[Depth, 1].ToX = PMoves.Move[i].ToX)
              then
                PMoves.Move[i].Sort := 30
              else
                if (Killers[Depth, 2].FromX = PMoves.Move[i].FromX) and
                  (Killers[Depth, 2].FromY = PMoves.Move[i].FromY) and
                  (Killers[Depth, 2].ToY = PMoves.Move[i].ToY) and
                  (Killers[Depth, 2].ToX = PMoves.Move[i].ToX)
                then
                  PMoves.Move[i].Sort := 29;
           end;
        end;
        qSort(PMoves, 1, PMoves.Count);
      end;



      if PMoves.Count = 0 then
      begin
        if ThreatToKing(Board, False) then Val := 9000 + Depth else Val := 0;
        BestVal := Val;
      end
      else
      begin
        for I := 1 to PMoves.Count do
        begin
          if OnlyCaptures and (PMoves.Move[i].Sort < 30) then Continue;

          CheckBoard := DoMove(Board, PMoves.Move[i]);
        //  Hash := GetHash(CheckBoard);
        //  HashIndex := abs(Hash) mod HashSize;

          if (Depth = 1) and ThreatToKing(CheckBoard, True) then
            rDepth := Depth
          else
            rDepth := Depth - 1;

        if false and (HashTable[HashIndex].RealHash = Hash) and
         (HashTable[HashIndex].Depth >= rDepth)  then
         begin
           Val := HashTable[HashIndex].Val;
           Inc(HashNodes);
         end
         else
         begin
           if (rDepth = 0) and (PMoves.Move[i].Sort > 30) then
           begin
             if not OnlyCaptures then
             begin
               CapVal := Estimator(Board);
                inc(Nodes);
             if CapVal < Beta then
               Val := MinMax(CheckBoard, 1, Alpha, CapVal, Pv, not CMove, True).Eval
             else
               Val := MinMax(CheckBoard, 1, Alpha, Beta, Pv, not CMove, True).Eval;
             end else
                Val := MinMax(CheckBoard, 1, Alpha, Beta, Pv, not CMove, True).Eval;
           end else
             Val := MinMax(CheckBoard, rDepth, Alpha, Beta, Pv, not CMove, OnlyCaptures).Eval;
         end;

          if Val < Beta then
          begin
            if rDepth > 1 then
            begin
         //     HashTable[HashIndex].Val := Val;
        //      HashTable[HashIndex].Depth := rDepth;
         //     HashTable[HashIndex].RealHash := Hash;
            end;

            Beta := Val;
            BestMoveIndex := i;
            inc(AlphaBeta);
            if PMoves.Move[i].Sort < 30 then
            begin
              Killers[Depth, 2] := Killers[Depth, 1];
              Killers[Depth, 1] := PMoves.Move[i];
            end;
          end;

          BestVal := Beta;
          if Beta <= Alpha then begin Inc(OffCuts); Break; end;
        end;
      end;
    end;

   if (PMoves.Count > 0) then
   begin
     Result := PMoves.Move[BestMoveIndex];
     Pv.Depth := Depth;
     Pv.Moves[Depth] := MoveToEasyMove(Result);
   end;

  if ((BestVal = -8000) and OnlyCaptures) then
  begin
    BestVal := Estimator(Board);
    inc(Nodes);
  end;

  end else
  begin
    BestVal := Estimator(Board);
    inc(Nodes);
    Pv.Depth := 0;
  end;

  Result.Eval := BestVal;
end;


var
  i, j, nc: LongWord;

  Board: TBoard;
  BestMove: TMove;
  n, NullCount: Integer;
  s, SMoves: String;
  SL: TStringList;
  Pv:String;
  iPv: TPVMoves;
begin
  ClearHash;
  Nodes := 0;
  randomize;
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
     WriteString('option name Elo type spin default 1100 min 1000 max 1100');
     WriteString('uciok');


   end;

   if (s[1] = 'g') and (s[2] = 'o') then
   begin

  //   if GetEndSpiel(Board) then i := 8 else i := 7;

     if Nodes > 100000 then i := 6 else i := 7;
     if (Nodes < 10000) and (Nodes > 100) then i := 8;


     NOdes := 0;
     HashNodes := 0;
     AlphaBeta := 0;
     OffCuts := 0;



//    i := 7;


//     for i := 1 to 6 do
     begin
       BestMove := MinMax(Board, i, -65530, 65530, iPv, Board.EngineColor, False);

       WriteString('info depth '+IntToStr(i)+' score cp '+ IntToStr(-BestMove.Eval)) ;
       sleep(20);
     end;


     pv := '';

     for j := iPv.Depth downto 1 do
     pv := pv + ConvertMoveToStr(EasyMoveToMove(iPv.Moves[j])) + ' ';

     WriteString('bestmove ' + ConvertMoveTOStr(BestMove));
     SL.Add(ConvertMoveTOStr(BestMove));

     WriteString('info depth ' + IntToStr(i-1) +' nodes '+IntToStr(Nodes)+' score cp '
     + IntToStr(-BestMove.Eval)+ ' time 0 nodes ' + IntToStr(Nodes)
   + ' pv ' + pv
   + ' hashfull ' + IntToStr(HashFullness)
   + ' string '
   +  'hash: ' + IntToStr(HashNodes)
   +  ' AlphaBeta: ' + IntToStr(AlphaBeta)
   +  ' OffCuts: ' + IntToStr(OffCuts)
   +  ' Eval: ' + IntToStr(Estimator(Board))
   );
   end;


  //   WriteString('info depth '+ IntToStr(i) +' score cp '+ IntToStr(-BestMove.Eval) + ' nodes ' + IntToStr(Nodes));



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
