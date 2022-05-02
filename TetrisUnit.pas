unit TetrisUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Imaging.pngimage, Vcl.ExtCtrls, HideUnit,
  Vcl.StdCtrls;

type
  TTetrisForm = class(TForm)
    BackGround: TImage;
    Gamefield: TImage;
    GameTimer: TTimer;
    RestartLabel: TLabel;
    NextLabel: TLabel;
    ScoreLabel: TLabel;
    GamePanel: TPanel;
    MenuPanel: TPanel;
    MenuBack: TImage;
    PlayLabel: TLabel;
    LeaderBoard: TLabel;
    ExitLabel: TLabel;
    ChooseShape: TShape;
    SaveScorePanel: TPanel;
    NameEdit: TEdit;
    NameLabel: TLabel;
    SaveButton: TButton;
    CancelButton: TButton;
    PauseLabel: TLabel;
    InfoPLabel: TLabel;
    SvScLabel: TLabel;
    LeadersPanel: TPanel;
    LeaderboardLabel: TLabel;
    LeadersLabel: TLabel;
    LeadersImage: TImage;
    BackLabel: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure GameTimerTimer(Sender: TObject);
    procedure Paint();
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PlayLabelClick(Sender: TObject);
    procedure ExitLabelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure NameEditKeyPress(Sender: TObject; var Key: Char);
    procedure NameEditChange(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure LeaderBoardClick(Sender: TObject);
    procedure InfoPLabelClick(Sender: TObject);
    procedure BackLabelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TetrisForm: TTetrisForm;

implementation
uses
    MainMenuUnit, ListUnit;
{$R *.dfm}
var
    Lines, FallTimer, Size, Rotation, Amount, Score, Str, Figure, NextFigure, FillAmount: Integer;
    AX,AY,BX,BY,CX,CY,DX,DY,NextAX,NextAY,NextBX,NextCX,NextBY,NextCY,NextDX,NextDY: Integer;
    CantFall, Restart, gameOver, FinishPaint: Boolean;
    Field: Array[0..24] of array[0..11] of Integer;
    ArrayOfFigures: Array of Array of Array of Array of Integer;
    Speed: Real;
    IsMenu: Boolean;
    Leaders: TList;

procedure TTetrisForm.CancelButtonClick(Sender: TObject);
begin
    SaveScorePanel.Hide;
end;

procedure TTetrisForm.ExitLabelClick(Sender: TObject);
begin
    TetrisForm.Close;
end;

procedure TTetrisForm.SaveButtonClick(Sender: TObject);
const
    PATH = 'LeadersTetris.txt';
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
        Leaders.Push_back(TetrisForm.NameEdit.Text, Score);
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
end;
procedure ShowLeaders();
var
    Ptr:Pt;
begin
    with TetrisForm do
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
procedure TTetrisForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    MainMenuForm.Show();
    GameTimer.Enabled := False;
    MainMenuForm.Top := TetrisForm.Top;
    MainMenuForm.Left := TetrisForm.Left;
end;
procedure TTetrisForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
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
            lpText := 'Are you sure you want to close Tetris?';
        end
        else
        begin
            lpCaption := 'Выход';
            lpText := 'Вы уверены, что хотите закрыть Tetris?';
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

procedure TTetrisForm.FormCreate(Sender: TObject);
begin
    Leaders := TList.Init();
end;

procedure PaintField();
begin
    with TetrisForm.Gamefield.Canvas do
        for var I := 4 to 23 do
            for var J := 1 to 10 do
            begin
                if(FinishPaint)then
                begin
                    case Field[I][J] of
                        0: Brush.Color := $000000;
                        1: Brush.Color := $0000AA;
                        2: Brush.Color := $008CFF;
                        3: Brush.Color := $00AAAA;
                        4: Brush.Color := $008000;
                        5: Brush.Color := $AAAA00;
                        6: Brush.Color := $AA0000;
                        7: Brush.Color := $AA00AA;
                    end;
                end else
                begin
                    case Field[I][J] of
                        0: Brush.Color := $000000;
                        1: Brush.Color := $0000FF;
                        2: Brush.Color := $00A5FF;
                        3: Brush.Color := $00FFFF;
                        4: Brush.Color := $00FF00;
                        5: Brush.Color := $FFFF00;
                        6: Brush.Color := $FF0000;
                        7: Brush.Color := $FF00FF;
                    end;
                end;
                Pen.Color := clGray;
                Rectangle((J + 1) * Size, (I - 3) * Size, (J + 1) * Size + Size, (I - 3) * Size + Size);
            end;
end;
procedure PaintFigure();
begin
    with TetrisForm.Gamefield.Canvas do
    begin
        Pen.Color := clGray;
        case figure of
            1: Brush.Color := $0000FF;
            2: Brush.Color := $00A5FF;
            3: Brush.Color := $00FFFF;
            4: Brush.Color := $00FF00;
            5: Brush.Color := $FFFF00;
            6: Brush.Color := $FF0000;
            7: Brush.Color := $FF00FF;
        end;
        if(AY > 4)then
            Rectangle((AX + 1) * Size, (AY - 4) * Size, (AX + 1) * Size + Size, (AY - 4) * Size + Size);
        if(BY > 4)then
            Rectangle((BX + 1) * Size, (BY - 4) * Size, (BX + 1) * Size + Size, (BY - 4) * Size + Size);
        if(CY > 4)then
            Rectangle((CX + 1) * Size, (CY - 4) * Size, (CX + 1) * Size + Size, (CY - 4) * Size + Size);
        if(DY > 4)then
            Rectangle((DX + 1) * Size, (DY - 4) * Size, (DX + 1) * Size + Size, (DY - 4) * Size + Size);
    end;
end;
procedure PaintNextFigure();
begin
    with TetrisForm.Gamefield.Canvas do
    begin
        Pen.Color := clDkGray;
        Brush.Color := clDkGray;
        Rectangle(Size * 13, Size * 2, Size * 18, Size * 8);
        Pen.Color := clGray;
        case NextFigure of
            1: Brush.Color := $0000FF;
            2: Brush.Color := $00A5FF;
            3: Brush.Color := $00FFFF;
            4: Brush.Color := $00FF00;
            5: Brush.Color := $FFFF00;
            6: Brush.Color := $FF0000;
            7: Brush.Color := $FF00FF;
        end;
        if(not GameOver)then
        begin
            Rectangle(NextAX, NextAY, NextAX + Size, NextAY + Size);
            Rectangle(NextBX, NextBY, NextBX + Size, NextBY + Size);
            Rectangle(NextCX, NextCY, NextCX + Size, NextCY + Size);
            Rectangle(NextDX, NextDY, NextDX + Size, NextDY + Size);
        end;
    end;
end;
procedure TTetrisForm.Paint();
begin
    with TetrisForm.Gamefield.Canvas do
    begin
        Brush.Color := clBlack;
        Pen.Color := clBlack;
        Rectangle(0,0,TetrisForm.Gamefield.Width, TetrisForm.Gamefield.Height);
        PaintField;
        PaintFigure;
        PaintNextFigure;
    end;
end;

procedure StartGame();
begin
    IsMenu := False;
    with TetrisForm do
    begin
        MenuPanel.Hide;
        GamePanel.Top := 0;
        GamePanel.Left := 0;
        GamePanel.Width := ClientWidth;
        GamePanel.Height := ClientHeight;
        GamePanel.Show;
        BackGround.Show;
        GameField.Show;
        Background.left := 0;
        BackGround.Top := 0;
        BackGround.Width := TetrisForm.ClientWidth;
        Background.Height := TetrisForm.ClientHeight;
        Gamefield.Height := BackGround.Height;
        Gamefield.Width := Gamefield.Height * 57 div 66;
        GameField.Top := 0;
        Gamefield.Left := (TetrisForm.Width - Gamefield.Width) div 2;
        Restart := True;
        gameOver := True;
        FinishPaint := False;
        Size := Gamefield.Height div 22;
        NextAX := Size * 15;
        NextAY := Size * 4;
        GameTimer.Enabled := False;
        TetrisForm.GameTimer.Interval := 5;
        Paint;
        if(Settings.Language = English)then
        begin
            NextLabel.Left := Size * 13 + Gamefield.Left;
            RestartLabel.Caption := 'Press SPACE to start';
            NextLabel.Caption := 'Next figure:';
            ScoreLabel.Caption := 'Score: ' + IntToStr(Score);
            InfoPLabel.Caption := 'Pause - space';
            PauseLAbel.Caption := 'Pause' + #13#10 + 'Press SPACE to continue' + #13#10 + 'Press ESC to exit';
        end
        else
        begin
            RestartLabel.Caption := 'Нажмите пробел, чтобы начать';
            NextLabel.Caption := 'Следующая фигура:';
            NextLabel.Left := Size * 12 + Gamefield.Left;
            ScoreLabel.Caption := 'Счёт: ' + IntToStr(Score);
            InfoPLabel.Caption := 'Пауза - пробел';
            PauseLAbel.Caption := 'Пауза' + #13#10 + 'Нажмите пробел, чтобы продолжить' + #13#10 + 'Нажмите ESC, чтобы выйти';
        end;
        NextLabel.Font.Size := 20 * TetrisForm.ClientWidth div 1920;
        ScoreLabel.Font.Size := 20 * TetrisForm.ClientWidth div 1920;
        InfoPLabel.Font.Size := 20 * TetrisForm.ClientWidth div 1920;
        PauseLabel.Font.Size := 30 * TetrisForm.ClientWidth div 1920;
        PauseLabel.Top := (ClientHeight - PauseLabel.Height) div 3;
        PauseLabel.Left := (ClientWidth - PauseLabel.Width) div 2;
        PauseLabel.Enabled := False;
        PauseLabel.Hide;
        NextLabel.Top := Size * 9 div 10;
        ScoreLabel.Top := Size * 11;
        ScoreLabel.Left := Gamefield.Left + Size * 13;
        InfoPLabel.Top := Size * 13;
        InfoPLabel.Left := Gamefield.Left + Size * 13;
        RestartLabel.Top := Size * 17 div 2;
        RestartLabel.Left := (TetrisForm.Width - RestartLabel.Width) div 2;
        RestartLabel.Show;
        AX := 0;
        AY := 0;
        BX := 0;
        BY := 0;
        CX := 0;
        CY := 0;
        DX := 0;
        DY := 0;
        ArrayOfFigures := [
            [[[-1,0],[0,1],[1,0]], [[0,-1],[-1,0],[0,1]], [[1,0],[0,-1],[-1,0]], [[0,1],[1,0],[0,-1]]],
            [[[0,-1],[0,1],[1,1]], [[1,0],[-1,0],[-1,1]], [[0,1],[0,-1],[-1,-1]], [[-1,0],[1,0],[1,-1]]],
            [[[0,-1],[0,1],[-1,1]], [[1,0],[-1,0],[-1,-1]], [[0,1],[0,-1],[1,-1]], [[-1,0],[1,0],[1,1]]],
            [[[1,0],[0,1],[1,1]]],
            [[[0,-1],[0,1],[0,2]], [[1,0],[-1,0],[-2,0]], [[0,1],[0,-1],[0,-2]], [[-1,0],[1,0],[2,0]]],
            [[[-1,0],[0,-1],[1,-1]], [[0,-1],[1,0],[1,1]], [[1,0],[0,1],[-1,1]], [[0,1],[-1,0],[-1,-1]]],
            [[[1,0],[0,-1],[-1,-1]], [[0,1],[1,0],[1,-1]], [[-1,0],[0,1],[1,1]], [[0,-1],[-1,0],[-1,1]]]];
        for var I := 0 to 24 do
            for var J := 0 to 11 do
                Field[I][J] := 0;
        Paint;
    end;
end;
procedure LoadLeaders();
const
    PATH = 'LeadersTetris.txt';
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
procedure ShowMenu();
begin
    with TetrisForm do
    begin
        LeadersPanel.Hide;
        LeadersPanel.Enabled := False;
        SaveScorePanel.Hide;
        IsMenu := True;
        GamePanel.Hide;
        MenuPanel.Top := 0;
        MenuPanel.Left := 0;
        MenuPanel.Width := ClientWidth;
        MenuPanel.Height := ClientHeight;
        MenuPanel.Show;
        MenuBack.Top := 0;
        MenuBack.Left := 0;
        MenuBack.Width := ClientWidth;
        MenuBack.Height := ClientHeight;
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
        LeaderBoard.Top := ClientHeight * 3 div 5;
        ExitLabel.Top := ClientHeight * 4 div 5;
        PlayLabel.Left := (ClientWidth - PlayLabel.Width) div 2;
        LeaderBoard.Left := (ClientWidth - LeaderBoard.Width) div 2;
        ExitLabel.Left := (ClientWidth - ExitLabel.Width) div 2;
        ChooseShape.Width := LeaderBoard.Width + 8;
        ChooseShape.Top := PlayLabel.Top - 4;
        ChooseShape.Left := LeaderBoard.Left - 4;
    end;
end;
procedure SaveScore();
begin
    with TetrisForm do
    begin
        SaveScorePanel.Width := ClientWidth div 6;
        SaveScorePanel.Height := ClientHeight div 2;
        SaveScorePanel.Top := (ClientHEight - SaveScorePanel.Height) div 2;
        SaveScorePanel.Left := (ClientWidth - SaveScorePanel.Width) div 2;
        SaveScorePanel.Show;
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
procedure TTetrisForm.FormShow(Sender: TObject);
begin
    TetrisForm.ClientHeight := MainMenuForm.ClientHeight;
    TetrisForm.ClientWidth := MainMenuForm.ClientWidth;
    TetrisForm.Top := MainMenuForm.Top;
    TetrisForm.Left := MainMenuForm.Left;
    LoadLeaders;
    ShowMenu;
end;
procedure ShowRestartLabel();
begin
    with TetrisForm do
    begin
        FinishPaint := True;
        RestartLabel.Font.Size := 40 * TetrisForm.ClientWidth div 1280;
        if(Settings.Language = English)then
            RestartLabel.Caption := 'Game over!' + #13#10 + 'Your score: ' + IntToStr(Score) + #13#10 + 'Press SPACE to start again' + #13#10 + 'Press ESC to exit'
        else
            RestartLabel.Caption := 'Игра окончена!' + #13#10 + 'Ваш счёт: ' + IntToStr(Score) + #13#10 + 'Нажмите пробел, чтобы играть снова' + #13#10 + 'Нажмите ESC, чтобы выйти';
        RestartLabel.Top := (Gamefield.Height - RestartLabel.Height) div 2 - Size;
        RestartLabel.Left := (TetrisForm.ClientWidth - RestartLabel.Width) div 2;
        RestartLabel.Show;
    end;
end;
procedure RestartGame();
begin
    Restart := False;
    FinishPaint := False;
    Score := 0;
    Speed := 50;
    if(Settings.Language = English)then
        TetrisForm.ScoreLabel.Caption := 'Score: ' + IntToStr(Score)
    else
        TetrisForm.ScoreLabel.Caption := 'Счёт: ' + IntToStr(Score);
    Randomize;
    NextFigure := Random(7) + 1;
    AX := 4;
    AY := 2;
    CantFall := True;
    for var I := 0 to 24 do
        for var J := 0 to 11 do
            Field[I][J] := 0;
end;
procedure MakeNextFigure();
begin
    CantFall := False;
    Rotation := 0;
    Figure := NextFigure;
    Randomize;
    NextFigure := Random(7) + 1;
    NextBX := NEXTAX + Size * arrayOfFigures[nextFigure - 1][0][0][0];
    NextBY := NEXTAY + Size * arrayOfFigures[nextFigure - 1][0][0][1];
    NextCX := NEXTAX + Size * arrayOfFigures[nextFigure - 1][0][1][0];
    NextCY := NEXTAY + Size * arrayOfFigures[nextFigure - 1][0][1][1];
    NextDX := NEXTAX + Size * arrayOfFigures[nextFigure - 1][0][2][0];
    NextDY := NEXTAY + Size * arrayOfFigures[nextFigure - 1][0][2][1];
    if(Figure = 4)then
        Amount := 1
    else
        Amount := 4;
    AX := 5;
    AY := 2;
end;
procedure LeaveFigure();
begin
    CantFall := True;
    Field[AY - 1][AX] := Figure;
    Field[BY - 1][BX] := Figure;
    Field[CY - 1][CX] := Figure;
    Field[DY - 1][DX] := Figure;
end;
procedure RemoveString();
begin
    Inc(Lines);
    if(Speed - 5 > 0) and (Score mod 100 = 0)then
        Speed := Speed - 5;
    for var J := Str - 1 downto 4 do
        for var I := 1 to 10 do
            Field[J + 1][I] := Field[J][I];
    Inc(Str);
end;
procedure CheckStrings();
var
    IsFull: Boolean;
begin
    Str := 23;
    Lines := 0;
    while(Str > 3)do
    begin
        IsFull := True;
        for var I := 1 to 10 do
            if (Field[Str][I] = 0)then
                IsFull := False;
        if(IsFull)then
            RemoveString;
        Dec(Str);
    end;
    case Lines of
        1: Score := Score + 10;
        2: Score := Score + 30;
        3: Score := Score + 50;
        4: Score := Score + 80;
    end;
    if(Settings.Language = English)then
        TetrisForm.ScoreLabel.Caption := 'Score: ' + IntToStr(Score)
    else
        TetrisForm.ScoreLabel.Caption := 'Счёт: ' + IntToStr(Score);
end;
procedure DropFigure();
begin
    if(Field[AY][AX] = 0) and (AY + 1 < 25) and (Field[BY][BX] = 0) and (BY + 1 < 25) and (Field[CY][CX] = 0) and (CY + 1 < 25) and (Field[DY][DX] = 0) and (DY + 1 < 25)then
        Inc(AY)
    else
    begin
        LeaveFigure();
        CheckStrings();
        for var I := 1 to 10 do
            if not (Field[3][I] = 0)then
            begin
                AX := 5;
                AY := 2;
                Restart := True;
                gameOver := True;
            end;
        if(gameOver)then
        begin
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
    FallTimer := 0;
end;
procedure FindCoordinates();
begin
    Inc(FallTimer);
    bX := aX + arrayOfFigures[figure - 1][rotation][0][0];
    bY := aY + arrayOfFigures[figure - 1][rotation][0][1];
    cX := aX + arrayOfFigures[figure - 1][rotation][1][0];
    cY := aY + arrayOfFigures[figure - 1][rotation][1][1];
    dX := aX + arrayOfFigures[figure - 1][rotation][2][0];
    dY := aY + arrayOfFigures[figure - 1][rotation][2][1];
end;
procedure PressSpace();
begin
    if(gameOver)then
    begin
        gameOver := False;
        TetrisForm.RestartLabel.Hide;
        TetrisForm.GameTimer.Enabled := True;
    end
    else
    begin
        TetrisForm.GameTimer.Enabled := not TetrisForm.GameTimer.Enabled;
        TetrisForm.PauseLabel.Enabled := not TetrisForm.PauseLabel.Enabled;
        if(TetrisForm.PauseLabel.Enabled)then
            TetrisForm.PauseLabel.Show
        else
            TetrisForm.PauseLabel.Hide;
    end;
end;
procedure MoveFigureDown();
begin
    if ((field[aY][aX] = 0) and (aY + 1 < 25) and (field[bY][bX] = 0) and (bY + 1 < 25) and (field[cY][cX] = 0) and (cY + 1 < 25) and (field[dY][dX] = 0) and (dY + 1 < 25))then
    begin
            Inc(aY);
            bY := aY + arrayOfFigures[figure - 1][rotation][0][1];
            cY := aY + arrayOfFigures[figure - 1][rotation][1][1];
            dY := aY + arrayOfFigures[figure - 1][rotation][2][1];
    end;
end;
procedure MoveFigureLeft();
begin
    if (Not cantFall and (field[aY - 1][aX - 1] = 0) and (aX - 1 > 0) and (field[bY - 1][bX - 1] = 0) and (bX - 1 > 0) and (field[cY - 1][cX - 1] = 0) and (cX - 1 > 0) and (field[dY - 1][dX - 1] = 0) and (dX - 1 > 0)) then
    begin
            Dec(aX);
            bX := aX + arrayOfFigures[figure - 1][rotation][0][0];
            cX := aX + arrayOfFigures[figure - 1][rotation][1][0];
            dX := aX + arrayOfFigures[figure - 1][rotation][2][0];
    end;
end;
procedure MoveFigureRight();
begin
    if (Not cantFall and (field[aY - 1][aX + 1] = 0) and (aX + 1 < 11) and (field[bY - 1][bX + 1] = 0) and (bX + 1 < 11) and (field[cY - 1][cX + 1] = 0) and (cX + 1 < 11) and (field[dY - 1][dX + 1] = 0) and (dX + 1 < 11)) then
    begin
            Inc(aX);
            bX := aX + arrayOfFigures[figure - 1][rotation][0][0];
            cX := aX + arrayOfFigures[figure - 1][rotation][1][0];
            dX := aX + arrayOfFigures[figure - 1][rotation][2][0];
    end;
end;
procedure RotateFigure();
begin
    if ((aX + arrayOfFigures[figure-1][(rotation + 1) mod amount][0][0] < 11)and(aX + arrayOfFigures[figure-1][(rotation + 1) mod amount][1][0] < 11)and(aX + arrayOfFigures[figure-1][(rotation + 1) mod amount][2][0] < 11)) then
            if ((aX + arrayOfFigures[figure-1][(rotation + 1) mod amount][0][0] > 0)and(aX + arrayOfFigures[figure-1][(rotation + 1) mod amount][1][0] > 0)and(aX + arrayOfFigures[figure-1][(rotation + 1) mod amount][2][0] > 0)) then
                if ((field[aY + arrayOfFigures[figure-1][(rotation + 1) mod amount][0][1] - 1][aX + arrayOfFigures[figure-1][(rotation + 1) mod amount][0][0]] = 0)and(field[aY + arrayOfFigures[figure-1][(rotation + 1) mod amount][1][1] - 1][aX + arrayOfFigures[figure-1][(rotation + 1) mod amount][1][0]] = 0)and(field[aY + arrayOfFigures[figure-1][(rotation + 1) mod amount][2][1] - 1][aX + arrayOfFigures[figure-1][(rotation + 1) mod amount][2][0]] = 0))then
                    if (aY + arrayOfFigures[figure - 1][(rotation + 1) mod amount][0][1] < 24)and(aY +arrayOfFigures[figure - 1][(rotation + 1) mod amount][1][1] < 24)and (aY + arrayOfFigures[figure - 1][(rotation + 1) mod amount][2][1] < 24) then
                        rotation := (rotation + 1) mod amount;
    TetrisForm.Paint;
end;
procedure TTetrisForm.GameTimerTimer(Sender: TObject);
begin
    if(GameOver)then
        ShowRestartLabel
    else
    begin
        if(Restart)then
            RestartGame();
        if(CantFall)then
            MakeNextFigure
        else
        begin
            if(FallTimer = Speed)then
                DropFigure;
        end;
        FindCoordinates;
    end;
    Paint();
end;

procedure TTetrisForm.InfoPLabelClick(Sender: TObject);
begin
    if(not gameOver)then
    begin
        TetrisForm.GameTimer.Enabled := not TetrisForm.GameTimer.Enabled;
        TetrisForm.PauseLabel.Enabled := Not TetrisForm.PauseLabel.Enabled;
        if(TetrisForm.PauseLabel.Enabled)then
            TetrisForm.PauseLabel.Show
        else
            TetrisForm.PauseLabel.Hide;
    end;
end;

procedure TTetrisForm.LeaderBoardClick(Sender: TObject);
begin
    ShowLeaders;
end;

procedure TTetrisForm.BackLabelClick(Sender: TObject);
begin
    ShowMenu;
end;

procedure TTetrisForm.NameEditChange(Sender: TObject);
begin
    if(Length(NameEdit.Text) > 0)then
        SaveButton.Enabled := True
    else
        SaveButton.Enabled := False;
end;

procedure TTetrisForm.NameEditKeyPress(Sender: TObject; var Key: Char);
begin
    if not(Key in ['0'..'9', 'A'..'Z','a'..'z',#08,'_'])then
        Key := #0;
    if(Length(NameEdit.Text) > 19) and (Key <> #08)then
        Key := #0;
end;

procedure TTetrisForm.PlayLabelClick(Sender: TObject);
begin
    StartGame();
end;


procedure TTetrisForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if(IsMenu)then
    begin
        if(Key = VK_DOWN)then
        begin
            if(ChooseShape.Top + 4 < TetrisForm.ClientHeight * 4 div 5)then
                ChooseShape.Top := ChooseShape.Top + TetrisForm.ClientHeight div 5;
        end;
        if(Key = VK_UP)then
        begin
            if(ChooseShape.Top + 4 > TetrisForm.ClientHeight * 2 div 5)then
                ChooseShape.Top := ChooseShape.Top - TetrisForm.ClientHeight div 5;
        end;
        if(Key = VK_RETURN)then
        begin
            if not (LeadersPanel.Enabled)then
            begin
                if(ChooseShape.Top + 4 = TetrisForm.ClientHeight * 2 div 5)then
                    StartGame;
                if(ChooseShape.Top + 4 = TetrisForm.ClientHeight * 3 div 5)then
                    ShowLeaders;
                if(ChooseShape.Top + 4 = TetrisForm.ClientHeight * 4 div 5)then
                    TetrisForm.Close;
            end;
        end;
        if(LeadersPanel.Enabled) and (Key = VK_ESCAPE)then
            ShowMenu;
    end;
    if(Not IsMenu)then
    begin
        if(Key = VK_SPACE)then
            begin
                PressSpace;
            end;
        if(Not Restart)then
        begin
            if(Key = VK_DOWN)then
            begin
                MoveFigureDown();
            end;
            if(Key = VK_LEFT)Then
            begin
                MoveFigureLeft;
            end;
            if(Key = VK_RIGHT)then
            begin
                MoveFigureRight;
            end;
            if(Key = VK_UP)then
            begin
                RotateFigure;
            end;
        end;
        if(Key = VK_ESCAPE)then
            if(gameOver) or  not (GameTimer.Enabled)then
                ShowMenu;
    end;
end;

end.
