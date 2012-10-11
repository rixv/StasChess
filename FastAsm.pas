unit FastAsm;

interface
  uses ChessTypes;

function Piece(Brd: TBoard): TMoves;

implementation



function Piece(Brd:TBoard): TMoves;
var PBrd, PMoves: Pointer;
begin

  PBrd := Addr(Brd);
  PMoves := Addr(Result);

  asm
    mov ecx, 64;

@loop:

    mov eax, ecx;
    sub eax, 1;
    imul eax, 4;
    mov ebx, [PBrd];
    add ebx, eax;


    cmp [ebx], 1;

    je @check;
@lret:

    loop @loop;
    jmp @End;


@check:






  jmp @lret;


@End: nop;
  end;


end;



end.
