unit Eval;

interface

  uses ChessTypes, UPossibleMoves;

function Estimator(var BoardN: TBoard): Integer;


implementation


function Estimator(var BoardN: TBoard): Integer;
var i, j: Integer; Fig: Integer; k: Integer;
  BCnt: Word;
begin
  // ���������� �����
  Result := MoveCountWhite(BoardN)*3;
  BCnt := MoveCountBlack(BoardN)*3;
  Result := Result - Bcnt;


  for i := 1 to 8 do
  for j := 1 to 8 do
  begin
    Fig := BoardN.Cells[i, j];

    if (Fig = 1) or (Fig = -1) then
    begin
      if (Fig = 1) then
      for k := j + 1 to 6 do
      begin
        if BoardN.Cells[i, k] = 1 then Result := Result - 20;
      end;

      if (Fig = -1) then
      for k := j - 1 downto 3 do
      begin
        if BoardN.Cells[i, k] = -1 then Result := Result + 20;
      end;

      if (Fig = 1) then
        case j of
          3: Result := Result + 3;
          4: Result := Result + 20;
          5: Result := Result + 30;
          6: Result := Result + 70;
          7: Result := Result + 150;
        end;
      if (Fig = -1) then
        case j of
          6: Result := Result - 7;
          5: Result := Result - 20;
          4: Result := Result - 30;
          3: Result := Result - 70;
          2: Result := Result - 150;
        end;

    end;

    if (Fig = -2) then
      if (i in [3..6]) and (j in [3..6]) then
      begin
        Result := Result - 30;
      end;

    if (Fig = 2) then
      if (i in [3..6]) and (j in [3..6]) then
      begin
        Result := Result + 30;
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

end;



end.
