unit ListUnit;

interface
type
  Pt = ^Node;
  Node = Record
      Name: String[20];
      Data: Integer;
      Next: pt;
  End;
  TList = Class
        Head: Pt;
        Tail: Pt;
        constructor Init();
        procedure Push_back(Str: String; Num: Integer);
        function Calc_size(): Integer;
        procedure Sort();
        procedure Clear();
        procedure Delete();
  End;
implementation
constructor TList.Init();
begin
    Head := Nil;
    Tail := Head;
end;
procedure TList.Push_back(Str: String; Num: Integer);
var
    Tmp: pt;
begin
    New(Tmp);
    Tmp.Data := Num;
    Tmp.Name := Str;
    Tmp.Next := Nil;
    If(Head = Nil)then
    begin
        Head := Tmp;
    end else
    begin
        Tail.Next := Tmp;
    end;
    Tail := Tmp;
end;
function TList.Calc_size(): Integer;
var
    Size: Integer;
    Ptr: Pt;
begin
    Ptr := Head;
    Size := 0;
    while(Ptr <> Nil)do
    begin
        Inc(Size);
        Ptr := Ptr.Next;
    end;
    Result := Size;
end;
procedure TList.Sort();
var
    IsNotChanged: Boolean;
    Ptr: Pt;
    Tmp: String[20];
begin
    if(Head <> nil) then
    repeat
        IsNotChanged := True;
        Ptr := Head;
        while(Ptr.Next <> nil) do
        begin
            if(Ptr.Data < Ptr.Next.Data)then
            begin
                Ptr.Data := Ptr.Data + Ptr.Next.Data;
                Ptr.Next.Data := Ptr.Data - Ptr.Next.Data;
                Ptr.Data := Ptr.Data - Ptr.Next.Data;
                Tmp := Ptr.Name;
                Ptr.Name := Ptr.Next.Name;
                Ptr.Next.Name := Tmp;
                IsNotChanged := False;
            end;
            Ptr := Ptr.Next;
        end;
    until IsNotChanged;
end;
procedure TList.Clear();
var
    Ptr: Pt;
begin
    While(Head <> Nil)do
    begin
        Ptr := Head;
        if(Head = Tail)then
        begin
            Dispose(Head);
            Head := Nil;
            Tail := Head;
        end else
        begin
            While(Ptr.next <> Tail)do
            begin
                Ptr := Ptr.Next;
            end;
            Dispose(Tail);
            Tail := Ptr;
            Ptr.Next := Nil;
        end;
    end;
end;
procedure TList.Delete();
var
    Ptr: Pt;
begin
    Ptr := Head;
    While(Ptr.Next <> Tail)do
        Ptr := Ptr.Next;
    Tail := Ptr;
    Dispose(Ptr.Next);
    Ptr.Next := Nil;
end;
end.
