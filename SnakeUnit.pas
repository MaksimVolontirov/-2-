unit SnakeUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.StdCtrls;

type
  TSnakeForm = class(TForm)
    GamePanel: TPanel;
    GameTimer: TTimer;
    GameField: TImage;
    GameBackground: TImage;
    StatusLabel: TLabel;
    ScoreLabel: TLabel;
    PauseLabel: TLabel;
    MenuPanel: TPanel;
    MenuImage: TImage;
    PlayLabel: TLabel;
    ExitLabel: TLabel;
    SelectShape: TShape;
    SnakeLabel: TLabel;
    SaveScorePanel: TPanel;
    NameLabel: TLabel;
    SvScLabel: TLabel;
    NameEdit: TEdit;
    SaveButton: TButton;
    CancelButton: TButton;
    LeadersPanel: TPanel;
    LeadersImage: TImage;
    LeaderboardLabel: TLabel;
    LeadersLabel: TLabel;
    BackLabel: TLabel;
    LeaderBoard: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure GameTimerTimer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure PlayLabelClick(Sender: TObject);
    procedure ExitLabelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure NameEditChange(Sender: TObject);
    procedure NameEditKeyPress(Sender: TObject; var Key: Char);
    procedure SaveButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure LeaderBoardClick(Sender: TObject);
    procedure BackLabelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SnakeForm: TSnakeForm;

implementation
uses
    MainMenuUnit, HideUnit, ListUnit;
{$R *.dfm}
type
    TDirection = (DStop, DRight, DLeft, DUp, DDown);
var
    PrevDir, Direction: TDirection;
    Apple: TPoint;
    Snake: Array[1..256] of TPoint;
    SnakeLength, Size, Score: Integer;
    GameOver, IsPause, IsMenu: Boolean;
    Leaders: TList;
procedure ShowLeaders();
var
    Ptr:Pt;
begin
    with SnakeForm do
    begin
        LeadersPanel.Enabled := True;
        LeadersPanel.Top := 0;
        LeadersPanel.Left := 0;
        LeadersPanel.Width := ClientWidth;
        LeadersPanel.Height := ClientHeight;
        LeadersImage.Top := 0;
        LeadersImage.Left := 0;
        LeadersImage.Width := ClientWidth;
        LeadersImage.Height := ClientHeight;
        LeadersPanel.Show;
        if(Settings.Language = English)then
        begin
            BackLabel.Caption := 'Back - ESC';
            LeaderboardLabel.Caption := 'Leaderboard';
        end
        else
        begin
            BackLabel.Caption := 'Назад - ESC';
            LeaderboardLabel.Caption := 'Список лидеров';
        end;
        LeaderboardLabel.Font.Size := 40 * ClientWidth div 1280;
        LeaderboardLabel.Top := ClientHeight div 5;
        LeaderboardLabel.Left := (ClientWidth - LeaderboardLabel.Width) div 2;
        LeadersLabel.Font.Size := 20 * ClientWidth div 1280;
        LeadersLabel.Caption := '';
        Ptr := Leaders.Head;
        While(Ptr <> Nil)do
        begin
            LeadersLabel.Caption := LeadersLabel.Caption + Ptr.Name + '    ' + IntToStr(Ptr.Data) + #13#10;
            Ptr := Ptr.Next;
        end;
        LeadersLabel.Left := (ClientWidth - LeadersLabel.Width) div 2;
        LeadersLabel.Top := LeaderboardLabel.Top + LeaderboardLabel.Height + 10;
        BackLabel.Font.Size := 40 * ClientWidth div 1280;
        BackLabel.Left := (ClientWidth - BackLabel.Width) div 2;
        BackLabel.Top := ClientHeight * 7 div 8;
    end;
end;
procedure LoadLeaders();
const
    PATH = 'LeadersSnake.txt';
var
    InputFile: TextFile;
    Name: String[20];
    Score: Integer;
    Str: String;
    IsCorrect: Boolean;
begin
    IsCorrect := True;
    try
        AssignFile(InputFile, PATH);
        Reset(InputFile);
    except
        IsCorrect := False;
        if(Settings.Language = English)then
            Application.MessageBox('Couldn''t load leaders from file', 'Error', MB_ICONERROR)
        else
            Application.MessageBox('Не удалось загрузить лидеров из файла', 'Ошибка', MB_ICONERROR);
    end;
    if(IsCorrect)then
    begin
        Leaders.Clear;
        while(not Eof(InputFile))do
        begin
            Read(InputFile, Str);
            if(Str <> '')then
            begin
                try
                    Name := Copy(Str, 1, pos(' ', Str));
                    Score := StrToInt(Copy(Str, Pos(' ', Str), Length(Str) - Pos(' ', Str) + 1));
                finally
                    Leaders.Push_back(Name, Score);
                end;
            end;
            Readln(InputFile);
        end;
        Leaders.Sort;
        CloseFile(InputFile);
    end;
end;
procedure SaveScore();
begin
    with SnakeForm do
    begin
        SaveScorePanel.Width := ClientWidth div 6;
        SaveScorePanel.Height := ClientHeight div 2;
        SaveScorePanel.Top := (ClientHEight - SaveScorePanel.Height) div 2;
        SaveScorePanel.Left := (ClientWidth - SaveScorePanel.Width) div 2;
        SaveScorePanel.Show;
        SaveScorePanel.Enabled := True;
        NameLabel.Font.Size := 20 * ClientWidth div 1280;
        SaveButton.Font.Size := 14 * ClientWidth div 1280;
        CancelButton.Font.Size := 14 * ClientWidth div 1280;
        NameEdit.Font.Size := 14 * ClientWidth div 1280;
        SvScLabel.Font.Size := 20 * ClientWidth div 1280;
        if(Settings.Language = English)then
        begin
            SaveButton.Caption := 'Save';
            CancelButton.Caption := 'Cancel';
            NameLabel.Caption := 'Name:';
            SvScLabel.Caption := 'Score: ' + IntToStr(Score);
        end
        else
        begin
            NameLabel.Caption := 'Имя:';
            SaveButton.Caption := 'Сохранить';
            CancelButton.Caption := 'Отмена';
            SvScLabel.Caption := 'Счёт: ' + IntToStr(Score);
        end;
        SvScLabel.Left := (SaveScorePanel.Width - SvScLabel.Width) div 2;
        SvScLabel.Top := 5;
        NameLabel.Left := (SaveScorePanel.Width - NameLabel.Width) div 2;
        NameLabel.Top := SaveScorePanel.Height div 9;
        SaveButton.Left := (SaveScorePanel.Width - SaveButton.Width) div 2;
        SaveButton.Top := SaveScorePanel.Height div 2;
        CancelButton.Left := (SaveScorePanel.Width - CancelButton.Width) div 2;
        CancelButton.Top := SaveScorePanel.Height * 3 div 4;
        NameEdit.Left := (SaveScorePanel.Width - NameEdit.Width) div 2;
        NameEdit.Top := SaveScorePanel.Height div 3;
    end;
end;
procedure DrawField();
begin
    with SnakeForm.GameField.Canvas do
    begin
        Brush.Color := $228B22;
        Pen.Color := $228B22;
        Rectangle(0,0, SnakeForm.GameField.Width, SnakeForm.GameField.Height);
        Brush.Color := $00CC00;
        Pen.Color := $00CC00;
        for var I:= 1 to 16 do
            for var J:= 0 to 7 do
                Rectangle((2 * J + I mod 2 + 1) * Size, I * Size,(2 * J + I mod 2 + 2) * Size, (I + 1) * Size);
        Brush.Color := $00EE00;
        Pen.Color := $00EE00;
        for var I := 1 to 16 do
            for var J := 0 to 7 do
                Rectangle((2 * J + (I - 1) mod 2 + 1) * Size, I * Size,(2 * J + (I - 1) mod 2 + 2) * Size, (I + 1) * Size);
    end;
end;
procedure DrawSnake();
begin
    with SnakeForm.GameField.Canvas do
    begin
        Brush.Color := $CC0000;
        Pen.Color := $CC0000;
        for var I := 1 to SnakeLength - 1 do
            Rectangle(Snake[I].X * Size, Snake[I].Y * Size, (Snake[I].X + 1) * Size, (Snake[I].Y + 1) * Size);
        Brush.Color := $990000;
        Pen.Color := $990000;
        Rectangle(Snake[SnakeLength].X * Size, Snake[SnakeLength].Y * Size, (Snake[SnakeLength].X + 1) * Size, (Snake[SnakeLength].Y + 1) * Size);
    end;
end;
procedure DrawApple();
begin
    With SnakeForm.GameField.Canvas do
    begin
        Brush.Color := $0000FF;
        Pen.Color := $0000FF;
        Rectangle(Apple.X * Size, Apple.Y * Size, (Apple.X + 1) * Size, (Apple.Y + 1) * Size);
    end;
end;
procedure DrawFrame();
begin
    DrawField;
    DrawApple;
    DrawSnake;
end;
procedure CreateApple();
var
    IsOk: Boolean;
begin
    Randomize;
    repeat
        Apple.X := Random(16) + 1;
        Apple.Y := Random(16) + 1;
        IsOk := True;
        for var I := 1 to SnakeLength do
            if(Snake[I] = Apple)then
                IsOk := False;
    until IsOk;
end;
procedure Restart();
begin
    SnakeForm.GameTimer.Enabled := True;
    SnakeLength := 4;
    for var I := 1 to SnakeLength do
    begin
        Snake[I].X := I;
        Snake[I].Y := 7;
    end;
    Size := SnakeForm.GameField.Width div 18;
    Direction := DStop;
    CreateApple;
    Score := 0;
    with SnakeForm do
    begin
        if(Settings.Language = English)then
        begin
            StatusLabel.Caption := 'Press down, up, or right to choose direction' + #13#10 + 'and start';
            ScoreLabel.Caption := 'Score: ' + IntToStr(Score);
        end
        else
        begin
            StatusLabel.Caption := 'Нажмите вниз, вверх или вправо, чтобы выбрать' + #13#10 + 'направление и начать игру';
            ScoreLabel.Caption := 'Счёт: ' + IntToStr(Score);
        end;
        StatusLabel.Left := (ClientWidth - StatusLabel.Width) div 2;
        StatusLabel.Top := (ClientHeight - StatusLabel.Height) div 2;
        StatusLabel.Show;
        ScoreLabel.Left := (ClientWidth - ScoreLabel.Width) div 2;
    end;
    DrawFrame;
    GameOver := False;
end;
procedure StartGame();
begin
    IsMenu := False;
    IsPause := False;
    with SnakeForm do
    begin
        SaveScorePanel.Hide;
        GamePanel.Show;
        MenuPanel.Hide;
        GamePanel.Top := 0;
        GamePanel.Left := 0;
        GamePanel.Width := ClientWidth;
        GamePanel.Height := ClientHeight;
        GameBackground.Top := 0;
        GameBackground.Left := 0;
        GameBackground.Width := ClientWidth;
        GameBackground.Height := ClientHeight;
        GameField.Height := ClientHeight;
        GameField.Width := GameField.Height;
        GameField.Top := 0;
        GameField.Left := (ClientWidth - GameField.Width) div 2;
        StatusLabel.Font.Size := 40 * ClientWidth div 1280;
        ScoreLabel.Font.Size := 20 * ClientWidth div 1280;
        PauseLabel.Font.Size := 20 * ClientWidth div 1280;
        if(Settings.Language = English)then
            PauseLabel.Caption := 'Pause - space'
        else
            PauseLabel.Caption := 'Пауза - пробел';
        PauseLabel.Top := ClientHeight - PauseLabel.Height - 2;
        PauseLabel.Left := (ClientWidth - PauseLabel.Width) div 2;
        ScoreLabel.Top := 2;
        Restart;
        GameTimer.Enabled := True;
        GameTimer.Interval := 125;
    end;
end;
procedure ShowMenu();
begin
    IsMenu := True;
    with SnakeForm do
    begin
        LeadersPanel.Enabled := False;
        LeadersPanel.Hide;
        SaveScorePanel.Hide;
        MenuPanel.Show;
        GamePanel.Hide;
        MenuPanel.Top := 0;
        MenuPanel.Left := 0;
        MenuPanel.Width := ClientWidth;
        MenuPanel.Height := ClientHeight;
        MenuImage.Top := 0;
        MenuImage.Left := 0;
        MenuImage.Width := ClientWidth;
        MenuImage.Height := ClientHeight;
        SnakeLabel.Font.Size := 100 * ClientWidth div 1920;
        SnakeLabel.Top := ClientHeight div 5;
        SnakeLabel.Left := (ClientWidth - SnakeLabel.Width) div 2;
        PlayLabel.Font.Size := 60 * ClientWidth div 1920;
        LeaderBoard.Font.Size := 60 * ClientWidth div 1920;
        ExitLabel.Font.Size := 60 * ClientWidth div 1920;
        if(Settings.Language = English)then
        begin
            PlayLabel.Caption := 'Play';
            LeaderBoard.Caption := 'Leaders';
            ExitLabel.Caption := 'Exit';
        end
        else
        begin
            PlayLabel.Caption := 'Играть';
            LeaderBoard.Caption := 'Лидеры';
            ExitLabel.Caption := 'Выход';
        end;
        PlayLabel.Top := ClientHeight * 2 div 5;
        PlayLabel.Left := (ClientWidth - PlayLabel.Width) div 2;
        LeaderBoard.Top := ClientHeight * 3 div 5;
        LeaderBoard.Left := (ClientWidth - LeaderBoard.Width) div 2;
        ExitLabel.Top := ClientHeight * 4 div 5;
        ExitLabel.Left := (ClientWidth - ExitLabel.Width) div 2;
        SelectShape.Width := LeaderBoard.Width + 8;
        SelectShape.Height := LeaderBoard.Height + 8;
        SelectShape.Top := PlayLabel.Top - 4;
        SelectShape.Left := (ClientWidth - SelectShape.Width) div 2;
    end;
end;
function EatApple(): Boolean;
begin
    Result := False;
    if(Apple = Snake[SnakeLength])then
    begin
        CreateApple;
        Inc(Score);
        if(Settings.Language = English)then
            SnakeForm.ScoreLabel.Caption := 'Score: ' + IntToStr(Score)
        else
            SnakeForm.ScoreLabel.Caption := 'Счёт: ' + IntToStr(Score);
        Result := True;
    end;
end;
procedure MoveSnake();
begin
    if(Direction <> DStop)then
        for var I := 1 to SnakeLength - 1 do
            Snake[I] := Snake[I + 1];
    case Direction of
        DUp: Snake[SnakeLength].Y := Snake[SnakeLength].Y - 1;
        DDown: Snake[SnakeLength].Y := Snake[SnakeLength].Y + 1;
        DLeft: Snake[SnakeLength].X := Snake[SnakeLength].X - 1;
        DRight: Snake[SnakeLength].X := Snake[SnakeLength].X + 1;
    end;
end;
procedure MoveHead();
begin
    Inc(SnakeLength);
    Snake[SnakeLength] := Snake[SnakeLength - 1];
    case Direction of
        DUp: Snake[SnakeLength].Y := Snake[SnakeLength - 1].Y - 1;
        DDown: Snake[SnakeLength].Y := Snake[SnakeLength - 1].Y + 1;
        DLeft: Snake[SnakeLength].X := Snake[SnakeLength - 1].X - 1;
        DRight: Snake[SnakeLength].X := Snake[SnakeLength - 1].X + 1;
    end;
end;
procedure MoveHeadBack();
begin
    Dec(SnakeLength);
    Snake[SnakeLength + 1] := Snake[SnakeLength];
end;
procedure CheckDeath();
var
    I, J: Integer;
begin
    if(Snake[SnakeLength].X < 1) or (Snake[SnakeLength].X > 16) or (Snake[SnakeLength].Y < 1) or (Snake[SnakeLength].Y > 16)then
    begin
        MoveHeadBack;
        Direction := DStop;
        GameOver := True;
    end;
    I := 1;
    While(I < SnakeLength - 3) do
    begin
        if(Snake[SnakeLength] = Snake[I])then
        begin
            SnakeLength := SnakeLength - I;
            for J := 1 to SnakeLength do
                Snake[J] := Snake[J + I];
            Direction := DStop;
            GameOver := True;
        end;
        Inc(I);
    end;
    if(GameOver)then
    begin
        SnakeForm.GameTimer.Enabled := False;
        if(Settings.Language = English)then
            SnakeForm.StatusLabel.Caption := 'Game over' + #13#10 + 'Your score: ' + IntToStr(Score) + #13#10 + 'Press space to start again' + #13#10 + 'Press ESC to exit'
        else
            SnakeForm.StatusLabel.Caption := 'Игра окончена' + #13#10 + 'Ваш счёт: ' + IntTOStr(Score) + #13#10 + 'Нажмите пробел, чтобы начать сначала' + #13#10 + 'Нажмите ESC, чтобы выйти';
        SnakeForm.StatusLabel.Left := (SnakeForm.ClientWidth - SnakeForm.StatusLabel.Width) div 2;
        SnakeForm.StatusLabel.Top := (SnakeForm.ClientHeight - SnakeForm.StatusLabel.Height) div 2;
        SnakeForm.StatusLabel.Show;
        if(Leaders.Calc_size < 10)then
            SaveScore
        else
        begin
            if(Leaders.Tail.Data < Score)then
            begin
                Leaders.Delete;
                SaveScore;
            end;
        end;
    end;
end;
procedure TSnakeForm.GameTimerTimer(Sender: TObject);
begin
    if(EatApple)then
        MoveHead
    else
        MoveSnake;
    PrevDir := Direction;
    CheckDeath;
    DrawFrame;
end;

procedure TSnakeForm.LeaderBoardClick(Sender: TObject);
begin
    ShowLeaders;
end;

procedure TSnakeForm.NameEditChange(Sender: TObject);
begin
    if(Length(NameEdit.Text) > 0)then
        SaveButton.Enabled := True
    else
        SaveButton.Enabled := False;
end;

procedure TSnakeForm.NameEditKeyPress(Sender: TObject; var Key: Char);
begin
    if not(Key in ['0'..'9', 'A'..'Z','a'..'z',#08,'_'])then
        Key := #0;
    if(Length(NameEdit.Text) > 19) and (Key <> #08)then
        Key := #0;
end;

procedure TSnakeForm.PlayLabelClick(Sender: TObject);
begin
     StartGame;
end;

procedure TSnakeForm.SaveButtonClick(Sender: TObject);
const
    PATH = 'LeadersSnake.txt';
var
    OutputFile: TextFile;
    IsCorrect: Boolean;
    Ptr: Pt;
begin
    IsCorrect := True;
    try
        AssignFile(OutputFile, PATH);
        Rewrite(OutputFile);
    except
        IsCorrect := False;
        if(Settings.Language = English)then
            Application.MessageBox('Couldn''t save score', 'Error', MB_ICONERROR)
        else
            Application.MessageBox('Не удалось сохранить рекорд', 'Ошибка', MB_ICONERROR);
    end;
    if(IsCorrect)then
    begin
        Leaders.Push_back(SnakeForm.NameEdit.Text, Score);
        Leaders.Sort;
        Ptr := Leaders.Head;
        while(Ptr <> Nil)do
        begin
            Writeln(OutputFile, Ptr.Name, ' ', IntToStr(Ptr.Data));
            Ptr := Ptr.Next;
        end;
        CloseFile(OutputFile);
    end;
    SaveScorePanel.Hide;
    SaveScorePanel.Enabled := False;
end;

procedure TSnakeForm.BackLabelClick(Sender: TObject);
begin
    ShowMenu;
end;

procedure TSnakeForm.CancelButtonClick(Sender: TObject);
begin
    SaveScorePanel.Hide;
    SaveScorePanel.Enabled := False;
end;

procedure TSnakeForm.ExitLabelClick(Sender: TObject);
begin
    SnakeForm.Close;
end;

procedure TSnakeForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    MainMenuForm.Show();
    GameTimer.Enabled := False;
    MainMenuForm.Top := SnakeForm.Top;
    MainMenuForm.Left := SnakeForm.Left;
    GameTimer.Enabled := False;
end;

procedure TSnakeForm.FormShow(Sender: TObject);
begin
    SnakeForm.ClientHeight := MainMenuForm.ClientHeight;
    SnakeForm.ClientWidth := MainMenuForm.ClientWidth;
    SnakeForm.Top := MainMenuForm.Top;
    SnakeForm.Left := MainMenuForm.Left;
    LoadLeaders;
    ShowMenu;
end;

procedure TSnakeForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
    WND: HWND;
    lpCaption, lpText: PChar;
    Tip: Integer;
begin
    if(Not IsMenu)then
    begin
        WND := Handle;
        if(Settings.Language = English)then
        begin
            lpCaption := 'Exit';
            lpText := 'Are you sure you want to close Snake?';
        end
        else
        begin
            lpCaption := 'Выход';
            lpText := 'Вы уверены, что хотите закрыть Snake?';
        end;
        Tip := MB_YESNO + MB_ICONINFORMATION + MB_DEFBUTTON2;
        case MessageBox(WND, lpText, lpCaption, Tip) of
            IDYES : CanClose := True;
            IDNO : CanClose := False;
        end
    end
    else
    begin
        CanClose := True;
    end;
end;

procedure TSnakeForm.FormCreate(Sender: TObject);
begin
    Leaders := TList.Init;
end;

procedure TSnakeForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if(Not IsMenu)then
    begin
        if(Not (GameOver or IsPause))then
        begin
            if(Key = VK_LEFT) and (PrevDir <> DRight) and (Direction <> DStop) then
            begin
                Direction := DLeft;
            end;
            if(Key = VK_RIGHT) and (PrevDir <> DLeft) then
            begin
                StatusLabel.Hide;
                Direction := DRight;
            end;
            if(Key = VK_UP) and (PrevDir <> DDown) then
            begin
                StatusLabel.Hide;
                Direction := DUp;
            end;
            if(Key = VK_Down) and (PrevDir <> DUp) then
            begin
                StatusLabel.Hide;
                Direction := DDown;
            end;
        end;
        if(Key = VK_Space)then
            if(GameOver and  not SaveScorePanel.Enabled)then
            begin
                Restart;
            end else
            begin
                if(Direction <> DStop)then
                begin
                    IsPause := Not IsPause;
                    if(IsPause)then
                    begin
                        if(Settings.Language = English)then
                            StatusLabel.Caption := 'Pause' + #13#10 + 'Press space to continue' + #13#10 + 'Press ESC to exit'
                        else
                            StatusLabel.Caption := 'Пауза' + #13#10 + 'Нажмите пробел, чтобы продолжить' + #13#10 + 'Нажмите ESC, чтобы выйти';
                        StatusLabel.Left := (ClientWidth - StatusLabel.Width) div 2;
                        StatusLabel.Top := (ClientHeight - StatusLabel.Height) div 2;
                        StatusLabel.Show;
                        GameTimer.Enabled := False;
                    end
                    else
                    begin
                        GameTimer.Enabled := True;
                        StatusLabel.Hide;
                    end;
                end;
            end;
        if(Key = VK_ESCAPE)then
            if(IsPause) or (GameOver) or (Direction = DStop)then
                ShowMenu;
    end;
    if(IsMenu)then
    begin
        if(Key = VK_DOWN)then
        begin
            if(SelectShape.Top + 4 < SnakeForm.ClientHeight * 4 div 5)then
                SelectShape.Top := SelectShape.Top + SnakeForm.ClientHeight div 5;
        end;
        if(Key = VK_UP)then
        begin
            if(SelectShape.Top + 4 > SnakeForm.ClientHeight * 2 div 5)then
                SelectShape.Top := SelectShape.Top - SnakeForm.ClientHeight div 5;
        end;
        if(Key = VK_RETURN)then
        begin
            if not (LeadersPanel.Enabled)then
            begin
                if(SelectShape.Top + 4 = SnakeForm.ClientHeight * 2 div 5)then
                    StartGame;
                if(SelectShape.Top + 4 = SnakeForm.ClientHeight * 3 div 5)then
                    ShowLeaders;
                if(SelectShape.Top + 4 = SnakeForm.ClientHeight * 4 div 5)then
                    SnakeForm.Close;
            end;
        end;
        if(LeadersPanel.Enabled) and (Key = VK_ESCAPE)then
            ShowMenu;
    end;
end;

end.
