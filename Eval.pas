unit Eval;

interface

  uses ChessTypes, UPossibleMoves;

function Estimator(BoardN: TBoard; CMove: Boolean): Integer;


implementation


function Estimator(BoardN: TBoard; CMove: Boolean): Integer;
var i, j: Integer; Sb, Sw: Boolean; Fig: Integer; k, l: Integer;
PMoves: TMoves; BCnt: Word;
begin

  Result := 0;
  Result := MoveCountWhite(BoardN)*4;
  BCnt := MoveCountBlack(BoardN)*4;
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
        if BoardN.Cells[i, k] = 1 then Result := Result - 20;
      end;

      if (BoardN.Cells[i, j] = -1) then
      for k := j - 1 downto 2 do
      begin
        if BoardN.Cells[i, k] = -1 then Result := Result + 20;
      end;

      if (BoardN.Cells[i, j] = 1) then
        Result := Result + trunc(j*j*j/3);

      if (BoardN.Cells[i, j] = -1) then
        Result := Result - trunc((9-j)*(9-j)*(9-j)/3);

    end;

    case Fig of

      1: Result := Result + 99;
     -1: Result := Result - 99;
      6: Result := Result + 50000;
     -6: Result := Result - 50000;
      2: Result := Result + 330;
     -2: Result := Result - 330;
      3: Result := Result + 331;
     -3: Result := Result - 331;
      4: Result := Result + 540;
     -4: Result := Result - 540;
      5: Result := Result + 940;
     -5: Result := Result - 940;
    end;


  end;

{
  Result := Result + BoardN.Cells[5, 4]*2;
  Result := Result + BoardN.Cells[4, 4]*2;

  Result := Result + BoardN.Cells[5, 5]*2;
  Result := Result + BoardN.Cells[4, 5]*2;;
}

 //result := result + random(4);

end;



end.
