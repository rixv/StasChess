unit UCI;

interface

  uses Sysutils, Classes, Windows;


const
 MAXBUFF = 4096;

function PeekInput: integer;
function ReadInput(nbytes:integer): string;
procedure SetupInput;
procedure WriteString(s: string);


var  stih,stoh: cardinal;

implementation


procedure WriteData(pbuff:pointer; n:integer);
var nw: cardinal;
begin
  WriteFile(stoh,pbuff^,n,nw,nil);
end;

procedure WriteString(s: string);
begin
  s := s + #10;
  WriteData(pchar(s),length(s));
end;

function ReadInput(nbytes:integer): string;
var
 n: cardinal;
 data: array[0..MAXBUFF-1] of char;
begin
  ReadFile(stih,data,nbytes,n,nil);
  data[n] := #0;
  result := data;
  result := trim(result);
end;

procedure SetupInput;
var Mode: Cardinal;
begin
  stih := GetStdHandle(STD_INPUT_HANDLE);
  stoh := GetStdHandle(STD_OUTPUT_HANDLE);
  IsConsole := GetConsoleMode(stih,mode);
  if IsConsole then
  begin
     mode := mode and not (ENABLE_WINDOW_INPUT or ENABLE_MOUSE_INPUT);
     SetConsoleMode(stih,mode);
     FlushConsoleInputBuffer(stih);
  end;
end;

function PeekInput: integer;
var
 n,nr,nl: cardinal;
 i: integer;
 data: array[0..MAXBUFF-1] of char;
begin
  result := 0;
  if IsConsole then begin
     GetNumberOfConsoleInputEvents(stih, n);
     if n > 1 then result := 256;
     exit;
  end;
  PeekNamedPipe(stih,@data,MAXBUFF,@nr,@n,@nl);
  if nr = 0 then exit;
  for i := 0 to nr-1 do
  if (data[i] = #10) or (data[i] = #13) then begin
     result := i+1;
     break;
  end;
  if nr > MAXBUFF then result := MAXBUFF;
end;



end.
