unit PongUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.StdCtrls, HideUnit;

type
  TPongForm = class(TForm)
    GameTimer: TTimer;
    GameField: TImage;
    PausePanel: TPanel;
    Border: TShape;
    PauseImage: TImage;
    Score1Label: TLabel;
    Score2Label: TLabel;
    MenuPanel: TPanel;
    PongLabel: TLabel;
    PlayLabel: TLabel;
    SelectShape: TShape;
    ExitLabel: TLabel;
    StartTimer: TTimer;
    InfoLabel: TLabel;
    ChoosePanel: TPanel;
    MouseImage: TImage;
    ArrowImage: TImage;
    Bord: TShape;
    TopLabel: TLabel;
    ChooseShape: TShape;
    BottomLabel: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure GameTimerTimer(Sender: TObject);
    procedure Repaint();
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SelectShapeContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure PlayLabelClick(Sender: TObject);
    procedure SelectShapeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ExitLabelClick(Sender: TObject);
    procedure StartTimerTimer(Sender: TObject);
    procedure PauseImageClick(Sender: TObject);
    procedure ArrowImageClick(Sender: TObject);
    procedure MouseImageClick(Sender: TObject);
    procedure BottomLabelClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure TopLabelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  PongForm: TPongForm;

implementation
uses
    MainMenuUnit;
var
    SizeX, SizeY, Bit1Y, Bit2Y, Bit1X, Bit2X, BallX, BallY, DirX, DirY, SpeedX, SpeedY, Score1, Score2: Integer;
    Game, IsMouse, IsMenu, IsPause: Boolean;
{$R *.dfm}

procedure TPongForm.Repaint();
begin
    with PongForm.GameField.Canvas do
    begin
        Pen.Color := ClBlack;
        Brush.Color := ClBlack;
        Rectangle(0, 0, GameField.Width, GameField.Height);
        Pen.Color := ClWhite;
        Brush.Color := ClWhite;
        Rectangle((GameField.Width - 2) div 2 - 1, 0, (GameField.Width - 2) div 2 + 1, GameField.Height);
        Rectangle(Bit1X, Bit1Y, Bit1X + SizeX, Bit1Y + SizeY);
        Rectangle(Bit2X, Bit2Y,Bit2X + SizeX, Bit2Y + SizeY);
        Rectangle(BallX, BallY, BallX + SizeX, BallY + SizeX);
    end;
end;

procedure Pause();
begin
    if(IsPause)then
        with PongForm do
        begin
            ChoosePanel.Show;
            ChoosePanel.Width := ClientWidth div 3;
            ChoosePanel.Height := ClientHeight div 2;
            ChoosePanel.Top := (ClientHeight - ChoosePanel.Height) div 2;
            ChoosePanel.Left := (ClientWidth - ChoosePanel.Width) div 2;
            MouseImage.Width := ChoosePanel.Width div 4;
            MouseImage.Height := MouseImage.Width;
            ArrowImage.Width := MouseImage.Width;
            ArrowImage.Height := MouseImage.Height;
            MouseImage.Left := (ChoosePanel.Width div 2 - MouseImage.Width) div 2;
            MouseImage.Top := (ChoosePanel.Height - MouseImage.Height) div 2;
            ArrowImage.Top := MouseImage.Top;
            ArrowImage.Left := (ChoosePanel.Width * 3 div 2 - MouseImage.Width) div 2;
            TopLabel.Font.Size := 40 * PongForm.ClientWidth div 1280;
            BottomLabel.Font.Size := 35 * PongForm.ClientWidth div 1280;
            if(Settings.Language = English)then
            begin
                BottomLabel.Caption := 'Exit';
                TopLabel.Caption := 'Pause'
            end
            else
            begin
                BottomLabel.Caption := 'Выход';
                TopLabel.Caption := 'Пауза';
            end;
            TopLabel.Top := ChoosePanel.Height div 15;
            TopLabel.Left := (ChoosePanel.Width - TopLabel.Width) div 2;
            BottomLabel.Top := ChoosePanel.Height * 2 div 3;
            BottomLabel.Left := (ChoosePanel.Width - BottomLabel.Width) div 2;
            ChooseShape.Width := MouseImage.Width + 4;
            ChooseShape.Height := ChooseShape.Width;
            ChooseShape.Top := MouseImage.Top - 2;
            if(IsMouse)then
                ChooseShape.Left := MouseImage.Left - 2
            else
                ChooseShape.Left := ArrowImage.Left - 2
        end
    else
        with PongForm do
        begin
            ChoosePanel.Hide;
        end;
end;

procedure StartGame();
begin
    With PongForm do
    begin
        MenuPanel.Visible := False;
        GameField.Show;
        PausePanel.Visible := True;
        GameField.Top := 0;
        GameField.Left := 0;
        GameField.Width := PongForm.ClientWidth;
        GameField.Height := PongForm.ClientHeight;
        PausePanel.Width := GameField.Width div 10;
        PausePanel.Height := GameField.Height div 10;
        PausePanel.Left := (GameField.Width - PausePanel.Width) div 2;
        PausePanel.Top := -5;
        PauseImage.Width := GameField.Width div 60;
        PauseImage.Height := GameField.Height div 20;
        PauseImage.Left := (PausePanel.Width - PauseImage.Width) div 2;
        PauseImage.Top := (PausePanel.Height - PauseImage.Height) div 2;
        GameField.Canvas.Create;
        SizeY := GameField.Height div 10;
        SizeX := GameField.Width div 62;
        Bit1Y := (GameField.Height - SizeY) div 2;
        Bit2Y := (GameField.Height - SizeY) div 2;
        Bit1X := 0;
        Bit2X := GameField.Width - SizeX;
        BallX := (GameField.Width - SizeX) div 2;
        BallY := (GameField.Height - SizeX) div 2;
        Score1 := 0;
        Score2 := 0;
        Score1Label.Font.Size := 44 * Gamefield.Width div 1920;
        Score2Label.Font.Size := 44 * Gamefield.Width div 1920;
        Score1Label.Caption := IntToStr(Score1);
        Score2Label.Caption := '  ' + IntToStr(Score2);
        Score1Label.Width := PauseImage.Left;
        Score1Label.Height := PausePanel.Height;
        Score1Label.Top := 5;
        Score1Label.Left := 2;
        Score1Label.Width := PauseImage.Left;
        Score1Label.Height := PausePanel.Height;
        Score1Label.Top := 5;
        Score1Label.Left := 2;
        Score2Label.Width := PauseImage.Left;
        Score2Label.Height := PausePanel.Height;
        Score2Label.Top := 5;
        Score2Label.Left := PausePanel.Width - Score2Label.Width;
        Repaint();
        Game := False;
        IsPause := False;
        InfoLabel.Show();
        InfoLabel.Font.Size := 60 * Gamefield.Width div 1920;
        InfoLabel.Caption := '3';
        InfoLabel.Left := (PongForm.ClientWidth - InfoLabel.Width) div 2;
        InfoLabel.Top := (PongForm.ClientHeight - InfoLabel.Height) div 2 - InfoLabel.Height;
        StartTimer.Interval := 1000;
        StartTimer.Enabled := True;
    end;
    IsMenu := False;
end;
procedure ShowMenu();
begin
    with PongForm do
    begin
        ChoosePanel.Hide;
        PausePanel.Visible := False;
        GameField.Enabled := False;
        MenuPanel.Visible := True;
        MenuPanel.Top := 0;
        MenuPanel.Left := 0;
        MenuPanel.Width := ClientWidth;
        MenuPanel.Height := ClientHeight;
        PongLabel.Font.Size := 100 * ClientWidth div 1920;
        PongLabel.Top := ClientHeight div 5;
        PongLabel.Left := (ClientWidth - PongLabel.Width) div 2;
        PlayLabel.Font.Size := 60 * ClientWidth div 1920;
        ExitLabel.Font.Size := 60 * ClientWidth div 1920;
        if(Settings.Language = English)then
        begin
            PlayLabel.Caption := 'Play';
            ExitLabel.Caption := 'Exit';
        end
        else
        begin
            PlayLabel.Caption := 'Играть';
            ExitLabel.Caption := 'Выход';
        end;
        PlayLabel.Top := ClientHeight * 2 div 5;
        PlayLabel.Left := (ClientWidth - PlayLabel.Width) div 2;
        ExitLabel.Top := ClientHeight * 3 div 5;
        ExitLabel.Left := (ClientWidth - ExitLabel.Width) div 2;
        SelectShape.Width := PlayLabel.Width + 20;
        SelectShape.Height := PlayLabel.Height + 2;
        SelectShape.Top := PlayLabel.Top;
        SelectShape.Left := (ClientWidth - SelectShape.Width) div 2;
    end;
    IsMenu := True;
end;

procedure TPongForm.PlayLabelClick(Sender: TObject);
begin
    StartGame();
end;

procedure TPongForm.ArrowImageClick(Sender: TObject);
begin
    IsMouse := False;
    IsPause := not IsPause;
    GameTimer.Enabled := not GameTimer.Enabled;
    Pause();
end;

procedure TPongForm.BottomLabelClick(Sender: TObject);
begin
    ShowMenu;
end;

procedure TPongForm.ExitLabelClick(Sender: TObject);
begin
    PongForm.Close();
end;

procedure TPongForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    MainMenuForm.Show();
    GameTimer.Enabled := False;
    MainMenuForm.Top := PongForm.Top;
    MainMenuForm.Left := PongForm.Left;
end;

procedure TPongForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
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
            lpText := 'Are you sure you want to close PONG?';
        end
        else
        begin
            lpCaption := 'Выход';
            lpText := 'Вы уверены, что хотите закрыть PONG?';
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

procedure TPongForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if(Key = VK_DOWN)then
    begin
        if(Not (IsMouse or IsPause))then
            if(Bit1Y + SizeY div 6 <= GameField.Height - SIZEY)then
                    Bit1Y := Bit1Y + SizeY div 6;
        if(IsMenu)then
            SelectShape.Top := (SelectShape.Top + PongForm.ClientHeight div 5) mod (PongForm.ClientHeight * 2 div 5) + PongForm.ClientHeight * 2 div 5;
        if(IsPause)then
        begin
            ChooseShape.Hide;
            ChooseShape.Width := BottomLabel.Width + 4;
            ChooseShape.Height := BottomLabel.Height + 4;
            ChooseShape.Top := BottomLabel.Top - 2;
            ChooseShape.Left := BottomLabel.Left - 2;
            ChooseShape.Show;
        end;
    end;
    if(Key = VK_UP)then
    begin
        if(Not (IsMouse or IsPause))then
            if(Bit1Y - SizeY div 6 >= 0) then
                    Bit1Y := Bit1Y - SizeY div 6;
        if(IsMenu)then
            SelectShape.Top :=(SelectShape.Top - PongForm.ClientHeight div 5) mod (PongForm.ClientHeight * 2 div 5) + PongForm.ClientHeight * 2 div 5;
        if(not IsMenu and IsPause)then
        begin
            ChooseShape.Hide;
            ChooseShape.Width := MouseImage.Width + 4;
            ChooseShape.Height := ChooseShape.Width;
            ChooseShape.Top := MouseImage.Top - 2;
            ChooseShape.Left := MouseImage.Left - 2;
            ChooseShape.Show;
        end;
    end;
    if(Key = VK_LEFT)then
    begin
        if(Not IsMenu and IsPause)then
            if(ChooseShape.Top + 2 = MouseImage.Top)then
                ChooseShape.Left := MouseImage.Left - 2;
    end;
    if(Key = VK_RIGHT)then
    begin
        if(Not IsMenu and IsPause)then
              if(ChooseShape.Top + 2 = MouseImage.Top)then
                ChooseShape.Left := ArrowImage.Left - 2;
    end;
    if(Key = VK_RETURN)then
    begin
        if(IsMenu)then
            if(SelectShape.Top = PongForm.ClientHeight* 2 div 5)then
                StartGame()
            else
                PongForm.Close();
        if(IsPause)then
            if(ChooseShape.Top + 2 = MouseImage.Top)then
                if(ChooseShape.Left + 2 = MouseImage.Left)then
                begin
                    IsMouse := True;
                    IsPause := not IsPause;
                    GameTimer.Enabled := not GameTimer.Enabled;
                    Pause();
                end
                else
                begin
                    IsMouse := False;
                    IsPause := not IsPause;
                    GameTimer.Enabled := not GameTimer.Enabled;
                    Pause();
                end
            else
            begin
                ShowMenu();
            end;

    end;
    if(Key = VK_ESCAPE)then
    begin
        if(not (IsMenu or StartTimer.Enabled))then
        begin
            IsPause := not IsPause;
            GameTimer.Enabled := not GameTimer.Enabled;
            Pause();
        end;
    end;
    if(Key = VK_SPACE)then
    begin
        if(Not(IsMenu or GameTimer.Enabled or IsPause))then
            StartGame;
    end;
end;

procedure TPongForm.FormShow(Sender: TObject);
begin
    PongForm.ClientHeight := MainMenuForm.ClientHeight;
    PongForm.ClientWidth := MainMenuForm.ClientWidth;
    PongForm.Top := MainMenuForm.Top;
    PongForm.Left := MainMenuForm.Left;
    ShowMenu;
    GameTimer.Enabled := False;
    GameTimer.Interval := 1;
end;

procedure TPongForm.SelectShapeContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
    StartGame();
end;

procedure TPongForm.SelectShapeMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    StartGame();
end;

procedure TPongForm.PauseImageClick(Sender: TObject);
begin
    if(Not StartTimer.Enabled)then
    begin
        IsPause := not IsPause;
        GameTimer.Enabled := not GameTimer.Enabled;
        Pause();
    end;
end;

procedure TPongForm.StartTimerTimer(Sender: TObject);
begin
    InfoLabel.Caption := IntToStr(StrToInt(InfoLabel.Caption) - 1);
    if (InfoLabel.Caption = '0') then
    begin
        StartTimer.Enabled := False;
        GameTimer.Enabled := True;
        InfoLabel.Hide;
    end;
end;

procedure TPongForm.TopLabelClick(Sender: TObject);
begin
    if(Not StartTimer.Enabled)then
    begin
        IsPause := not IsPause;
        GameTimer.Enabled := not GameTimer.Enabled;
        Pause();
    end;
end;

procedure TPongForm.GameTimerTimer(Sender: TObject);
var
    T: TPoint;
begin
    Repaint();
    T:=ScreenToClient(PongForm.FDesignSize);
    if(Game)then
    begin
        if((BallY + DirY*SpeedY < 0) or (BallY + DirY*SpeedY > GameField.Height - SIZEX))then
            DirY := -DirY;
        BallX := BallX + DirX * SpeedX;
        BallY := BallY + DirY * SpeedY;
        if(Bit2Y + SIZEY / 2 > BallY + SIZEX / 2)then
            if(Bit2Y - SizeY div 12 >= 0)then
                Bit2Y := Bit2Y - SizeY div 12;
        if(Bit2Y + SIZEY / 2 < BallY + SIZEX / 2)then
            if(Bit2Y + SizeY div 12 <= GameField.Height - SIZEY)then
                Bit2Y := Bit2Y + SizeY div 12;
        if(BallX > GameField.Width)then
        begin
            Game := False;
            Inc(Score1);
            Score1Label.Caption := IntToStr(Score1);
            if(Score1 > 11)then
            begin
                if(Settings.Language = English)then
                    InfoLabel.Caption := 'Victory' + #13#10 + 'Press SPACE to start again'
                else
                    InfoLabel.Caption := 'Победа' + #13#10 + 'Нажмите пробел, чтобы начать заново';
                InfoLabel.Left := (PongForm.ClientWidth - InfoLabel.Width) div 2;
                InfoLabel.Top := (PongForm.ClientHeight - InfoLabel.Height) div 2;
                InfoLabel.Show;
                GameTimer.Enabled := False;
            end;
        end;
        if(BallX < -SIZEX)then
        begin
            Game := False;
            Inc(Score2);
            Score2Label.Caption := IntToStr(Score2);
            if(StrToInt(Score2label.Caption) < 10)then
                Score2Label.Caption := '  ' + IntToStr(Score2);
            if(Score2 > 11)then
            begin
                if(Settings.Language = English)then
                    InfoLabel.Caption := 'Defeat' + #13#10 + 'Press SPACE to start again'
                else
                    InfoLabel.Caption := 'Поражение' + #13#10 + 'Нажмите пробел, чтобы начать заново';
                InfoLabel.Left := (PongForm.ClientWidth - InfoLabel.Width) div 2;
                InfoLabel.Top := (PongForm.ClientHeight - InfoLabel.Height) div 2;
                InfoLabel.Show;
                GameTimer.Enabled := False;
            end;
        end;
        if((BallX < SIZEX) and (BallX > 0) and (BallY < Bit1Y + SIZEY) and (BallY + SIZEX > Bit1Y) and (DirX = -1))then
        begin
            DirX := -DirX;
            if(SpeedX < GameField.Width div 50)then
                SpeedX := SpeedX + random(GameField.Width div 400);
            if (BallY >= Bit1Y + SIZEY * 2 div 3)then
                SpeedY := SpeedY + Random(GameField.Height div 125) * (-DirY)
            else if((BallY + SIZEX) <= (Bit1Y + SizeY div 3))then
                SpeedY := SpeedY + Random(GameField.Height div 125) * DirY;
        end;
        if((BallX + SIZEX < GameField.Width) and (BallX + SIZEX > GameField.Width - SIZEX ) and (BallY < Bit2Y + SIZEY) and (BallY + SIZEX > Bit2Y) and (DirX = 1))then
        begin
            DirX := -DirX;
            if(SpeedX < GameField.Width div 50)then
                SpeedX := SpeedX + random(GameField.Width div 400);
            if (BallY >= Bit2Y + SIZEY * 2 div 3) then
                    SpeedY := SpeedY + random(GameField.Height div 125) * (-DirY)
                else if((BallY + SIZEX) <= (Bit2Y + SizeY div 3))then
                    SpeedY := SpeedY + random(GameField.Height div 125) * DirY;
        end;
        if(IsMouse)then
        begin
            Bit1Y := Mouse.CursorPos.Y + T.Y - SizeY div 2;
            if(Bit1Y < 0)then
                Bit1Y := 0;
            if(Bit1Y + SizeY > PongForm.ClientHeight)then
                Bit1Y := PongForm.ClientHeight - SizeY;
        end;
    end
    else
    begin
        Game := true;
        BallX := (GameField.Width - SIZEX) div 2;
        BallY := (GameField.Height - SIZEX) div 2;
        Bit1Y := (GameField.Height - SIZEY) div 2;
        Bit2Y := (GameField.Height - SIZEY) div 2;
        SpeedX := GameField.Width div 500;
        SpeedY := GameField.Width div 500;
        Randomize;
        if(Random(2) = 1)then
            DirX := 1
        else
            DirX := -1;
        if(Random(2) = 1)then
            DirY := 1
        else
            DirY := -1;
    end;
end;

procedure TPongForm.MouseImageClick(Sender: TObject);
begin
    IsMouse := True;
    IsPause := not IsPause;
    GameTimer.Enabled := not GameTimer.Enabled;
    Pause();
end;

end.
