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

var Nodes, HashNodes: LongInt;



function MinMax(Board: TBoard; Depth, Alpha, Beta: Integer; var Pv: TPVMoves; CMove: Boolean): TMove;
var PMoves: TMoves; i, Val, BestVal: Integer; CheckBoard: TBoard;
  Hash: LongWord;  rDepth, BestMoveIndex: Byte; SMoves: String;
begin

  BestMoveIndex := 1;
  BestVal := -1111;



    If Depth > 0 then
    begin
    If CMove then
    begin

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
          rDepth := Depth - 1;
          Val := MinMax(CheckBoard, rDepth, Alpha, Beta, Pv, not CMove).Eval;

       //   HashTable[Hash].Val := Val - Alpha;

          if Val > Alpha then
          begin
            Alpha := Val;
            BestMoveIndex := i;
          end;
          BestVal := Alpha;
          if Beta <= Alpha then Break;
       end;
     end;
    end
    else
    begin
      PMoves := PossibleMovesBlack(Board);
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
          rDepth := Depth - 1;

          Val := MinMax(CheckBoard, rDepth, Alpha, Beta, Pv, not CMove).Eval;


     //     HashTable[Hash].Val := Beta - Val;

          if Val < Beta then
          begin
            Beta := Val;
            BestMoveindex := i;
          end;
          BestVal := Beta;
          if Beta <= Alpha then Break;
        end;
      end;
    end;

   if PMoves.Count > 0 then
   begin
     Result := PMoves.Move[BestMoveIndex];
     Pv.Depth := Depth;
     Pv.Moves[Depth] := MoveToEasyMove(Result);
   end;
  end else

  begin
    BestVal := Estimator(Board, CMove);
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
  IsBlack: Boolean;
  MainDepth: Word;
  Pv:String;
  iPv: TPVMoves;
begin

  ClearHash;
  Nodes := 0;
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
     WriteString('option name Elo type spin default 1100 min 1000 max 1100');
     WriteString('uciok');


   end;

   if (s[1] = 'g') and (s[2] = 'o') then
   begin

     NOdes := 0;
//     ClearHash;


//     if GetEndSpiel(Board) then MainDepth := 5 else MainDepth := 6;

     i := 6;
    /// for i := 1 to 6 do
     begin
       BestMove := MinMax(Board, i, -65530, 65530, iPv, Board.EngineColor);

       WriteString('info depth '+IntToStr(i)+' score cp '+ IntToStr(-BestMove.Eval)) ;
       sleep(20);
     end;


     pv := '';

     for j := iPv.Depth downto 1 do
     pv := pv + ConvertMoveToStr(EasyMoveToMove(iPv.Moves[j])) + ' ';

     WriteString('bestmove ' + ConvertMoveTOStr(BestMove));
     SL.Add(ConvertMoveTOStr(BestMove));

     WriteString('info depth ' + IntToStr(i-1) +' nodes '+IntToStr(Nodes)+' score cp '
     + IntToStr(-BestMove.Eval)+ ' time 0 nodes ' + IntToStr(Nodes) +
     ' pv ' + pv + ' str '+ IntToStr(Nodes));
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
