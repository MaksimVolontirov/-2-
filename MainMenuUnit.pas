unit MainMenuUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.StdCtrls;

type
  TMainMenuForm = class(TForm)
    Background: TImage;
    CenterGame: TImage;
    SwapRightTimer: TTimer;
    LeftGame: TImage;
    RightGame: TImage;
    AddImage: TImage;
    SwapLeftTimer: TTimer;
    SlidesImage: TImage;
    ExitImage: TImage;
    SettingsImage: TImage;
    InfoImage: TImage;
    InfoLabel: TLabel;
    ExitLabel: TLabel;
    SettingsLabel: TLabel;
    ChooseShape: TShape;
    SettingsPanel: TPanel;
    BGPanel: TPanel;
    Bg1Radio: TRadioButton;
    Bg2Radio: TRadioButton;
    Bg1Image: TImage;
    Bg2Image: TImage;
    EngLabel: TLabel;
    RusLabel: TLabel;
    LanPanel: TPanel;
    RusRadio: TRadioButton;
    EngRadio: TRadioButton;
    Label1920: TLabel;
    Label1280: TLabel;
    SizePanel: TPanel;
    Radio1920: TRadioButton;
    Radio1280: TRadioButton;
    SaveButton: TButton;
    BackButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SwapRightTimerTimer(Sender: TObject);
    procedure SwapLeftTimerTimer(Sender: TObject);
    procedure RightGameClick(Sender: TObject);
    procedure LeftGameClick(Sender: TObject);
    procedure CenterGameClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ExitImageClick(Sender: TObject);
    procedure SettingsImageClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure BackButtonClick(Sender: TObject);
    procedure InfoImageClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
type
    TLanguage = (Russian, English);
    TSettings = Record
        Background: String[50];
        Language: TLanguage;
        ScreenWidth, ScreenHeight: Integer;
    end;
var
  MainMenuForm: TMainMenuForm;
  Settings: TSettings;
implementation
uses
    PongUnit, TetrisUnit, SnakeUnit, InfoUnit;
const
    SETTINGS_PATH = 'Settings.txt';
    BG1_PATH = 'Background1';
    BG2_PATH = 'Background2';
    FULL_HD_W = 1920;
    FULL_HD_H = 1000;
    HD_W = 1280;
    HD_H = 720;
{$R *.dfm}

type
    TGame = (Tetris, Pong, Snake);
var
    Games: Array[0..2] of TGame;
    PngImages: Array [0..2] of TPngImage;
    Bg: TPngImage;
    IsAnimation, IsGame: Boolean;
    LeftX, LeftY, RightX, RightY, CenterX, CenterY, DeltaXCL, DeltaY, DeltaXCR, DeltaW, DeltaH: Integer;
function Max(A,B: Integer): Integer;
begin
    Result := B;
    if(A > B)then
        Result := A;
end;
procedure CreateSettings();
var
    OutputFile: File of TSettings;
begin
    Settings.Background := BG1_PATH;
    Settings.Language := English;
    Settings.ScreenWidth := HD_W;
    Settings.ScreenHeight := HD_H;
    Assign(OutputFile, SETTINGS_PATH);
    Rewrite(OutputFile);
    Write(OutputFile, Settings);
    Close(OutputFile);
end;
procedure LoadSettings();
var
    InputFile: File of TSettings;
    IsCorrect: Boolean;
begin
    IsCorrect := True;
    try
        AssignFile(InputFile, SETTINGS_PATH);
        Reset(InputFile);
    except
        IsCorrect := False;
        CreateSettings();
        Application.MessageBox('Couldn''t load settings', 'Error', MB_ICONERROR);
    end;
    if(IsCorrect)then
    begin
        try
            Read(InputFile, Settings);
        except
            Application.MessageBox('Couldn''t load settings', 'Error', MB_ICONERROR);
            CreateSettings;
        end;
        Close(InputFile);
    end;
end;
procedure LoadImages();
begin
    with MainMenuForm do
    begin
        LeftGame.Picture.Graphic := PngImages[ord(Games[0])];
        CenterGame.Picture.Graphic := PngImages[ord(Games[1])];
        RightGame.Picture.Graphic := PngImages[ord(Games[2])];
    end;
end;
procedure SetImagesSettings();
begin
    with MainMenuForm do
    begin
        CenterGame.Height := MainMenuForm.ClientHeight div 3 * 2;
        CenterGame.Width := CenterGame.Height * 9 div 10;
        CenterGame.Left := (MainMenuForm.ClientWidth - CenterGame.Width) div 2;
        CenterGame.Top := (MainMenuForm.ClientHeight - CenterGame.Height) div 2;
        LeftGame.Height := CenterGame.Height div 2;
        LeftGame.Width := CenterGame.Width div 2;
        LeftGame.Top := (MainMenuForm.ClientHeight - LeftGame.Height) div 2;
        LeftGame.Left := ((MainMenuForm.ClientWidth - CenterGame.Width) div 2 - LeftGame.Width) div 2;
        RightGame.Height := CenterGame.Height div 2;
        RightGame.Width := CenterGame.Width div 2;
        RightGame.Top := (MainMenuForm.ClientHeight - RightGame.Height) div 2;
        RightGame.Left := ((MainMenuForm.ClientWidth + CenterGame.Width) div 2 + MainMenuForm.ClientWidth - RightGame.Width) div 2;
        AddImage.Hide();
    end;
end;
procedure TMainMenuForm.ExitImageClick(Sender: TObject);
begin
    MainMenuForm.Close;
end;

procedure TMainMenuForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
    WND: HWND;
    lpCaption, lpText: PChar;
    Tip: Integer;
begin
    WND := Handle;
    if(Settings.Language = English)then
    begin
        lpCaption := 'Exit';
        lpText := 'Are you sure you want to close application?';
    end
    else
    begin
        lpCaption := 'Выход';
        lpText := 'Вы уверены, что хотите закрыть приложение?';
    end;
    Tip := MB_YESNO + MB_ICONINFORMATION + MB_DEFBUTTON2;
    case MessageBox(WND, lpText, lpCaption, Tip) of
        IDYES : CanClose := True;
        IDNO : CanClose := False;
    end
end;
procedure SetSettings();
begin
    with MainMenuForm do
    begin
        MainMenuForm.ClientHeight := Settings.ScreenHeight;
        MainMenuForm.ClientWidth := Settings.ScreenWidth;
        MainMenuForm.Left:= (Screen.WorkAreaWidth - MainMenuForm.Width) div 2;
        MainMenuForm.Top:= (Screen.WorkAreaHeight - MainMenuForm.Height) div 2;
        Background.Width := MainMenuForm.ClientWidth;
        Background.Height := MainMenuForm.ClientHeight;
        SlidesImage.top := 0;
        SlidesImage.Left := 0;
        SlidesImage.Width := MainMenuForm.ClientWidth;
        SlidesImage.Height := MainMenuForm.ClientHeight;
        Bg := TPngImage.Create;
        Bg.LoadFromResourceName(HInstance, Settings.Background);
        Background.Picture.Graphic := Bg;
        Games[0] := Pong;
        Games[1] := Tetris;
        Games[2] := Snake;
        SetImagesSettings();
        AddImage.Width := RightGame.Width;
        AddImage.Height := RightGame.Height;
        PngImages[0] := TPngImage.Create;
        PngImages[1] := TPngImage.Create;
        PngImages[2] := TPngImage.Create;
        PngImages[0].LoadFromResourceName(HInstance, 'TetrisImage');
        PngImages[1].LoadFromResourceName(HInstance, 'PongImage');
        PngImages[2].LoadFromResourceName(HInstance, 'SnakeImage');
        CenterX := CenterGame.left;
        CenterY := CenterGame.Top;
        LeftX := LeftGame.Left;
        LeftY := LeftGame.Top;
        RightX := RightGame.Left;
        RightY := RightGame.Top;
        DeltaXCL := (CenterGame.Left - LeftGame.Left) div 10;
        DeltaY := (LeftGame.Top - CenterGame.Top) div 10;
        DeltaXCR := (RightGame.Left - CenterGame.Left) div 10;
        DeltaW := CenterGame.Width div 20;
        DeltaH := CenterGame.Height div 20;
        SwapRightTimer.Enabled := False;
        SwapLeftTimer.Enabled := False;
        SettingsImage.Height := MainMenuForm.ClientHeight div 15;
        SettingsImage.Width := SettingsImage.Height;
        InfoImage.Height := MainMenuForm.ClientHeight div 15;
        InfoImage.Width := InfoImage.Height;
        ExitImage.Height := MainMenuForm.ClientHeight div 15;
        ExitImage.Width := ExitImage.Height;
        InfoImage.Left := (MainMenuForm.ClientWidth - InfoImage.Width) div 2;
        InfoImage.Top := MainMenuForm.ClientHeight div 50;
        SettingsImage.Top := InfoImage.Top;
        SettingsImage.Left := MainMenuForm.ClientWidth * 3 div 9;
        ExitImage.Left := MainMenuForm.ClientWidth * 6 div 9 - ExitImage.Width;
        ExitImage.Top := InfoImage.Top;
        LoadImages;
        InfoLabel.Font.Size := 10 * ClientWidth div 1280;
        ExitLabel.Font.Size := InfoLabel.Font.Size;
        SettingsLabel.Font.Size := InfoLabel.Font.Size;
        if(Settings.Language = English)then
        begin
            InfoLabel.Caption := 'Info';
            ExitLabel.Caption := 'Exit';
            SettingsLabel.Caption := 'Settings';
        end
        else
        begin
            InfoLabel.Caption := 'Инфо';
            ExitLabel.Caption := 'Выход';
            SettingsLabel.Caption := 'Настройки';
        end;
        InfoLabel.Left := InfoImage.Left + (InfoImage.Width - InfoLabel.Width) div 2;
        ExitLabel.Left := ExitImage.Left + (ExitImage.Width - ExitLabel.Width) div 2;
        SettingsLabel.Left := SettingsImage.Left + (SettingsImage.Width - SettingsLabel.Width) div 2;
        InfoLabel.Top := InfoImage.Top + InfoImage.Height;
        ExitLabel.Top := InfoLabel.Top;
        SettingsLabel.Top := InfoLabel.Top;
        ChooseShape.Pen.Width := 10;
        ChooseShape.Width := CenterGame.Width + 20;
        ChooseShape.Height := CenterGame.Height + 20;
        ChooseShape.Top := CenterGame.Top - 10;
        ChooseShape.Left := CenterGame.Left - 10;
    end;
    IsGame := True;
end;
procedure ShowSettings();
begin
    with MainMenuForm do
    begin
        SettingsPanel.Enabled := True;
        SettingsPanel.Show;
        SettingsPanel.Top := 0;
        SettingsPanel.Left := 0;
        SettingsPanel.Width := ClientWidth;
        SettingsPanel.Height := ClientHeight;
        BGPanel.Left := 0;
        BGPanel.Height := Bg1Radio.Height;
        BGPanel.Width := ClientWidth;
        Bg1Image.Height := ClientHeight div 6;
        Bg1Image.Width := Bg1Image.Height * 16 div 9;
        Bg2Image.Height := Bg1Image.Height;
        Bg2Image.Width := Bg1Image.Width;
        Bg1Image.Left := (ClientWidth div 2 - Bg1Image.Width) div 2;
        Bg2Image.Top := ClientHeight div 5;
        Bg2Image.Left := (ClientWidth * 3 div 2 - Bg1Image.Width) div 2;
        Bg1Image.Top := Bg2Image.Top;
        BGPanel.Top := Bg1Image.Top + Bg1Image.Height;
        Bg1Radio.Top := 0;
        Bg2Radio.Top := 0;
        Bg1Radio.Left := Bg1Image.Left + Bg1Image.Width div 2;
        Bg2Radio.Left := Bg2Image.Left + Bg2Image.Width div 2;
        if(Settings.Background = BG1_PATH)then
            Bg1Radio.Checked := True
        else
            Bg2Radio.Checked := True;
        RusLabel.Font.Size := 20 * ClientWidth div 1280;
        EngLabel.Font.Size := 20 * ClientWidth div 1280;
        Label1920.Font.Size := 20 * ClientWidth div 1280;
        Label1280.Font.Size := 20 * ClientWidth div 1280;
        if(Settings.Language = English)then
        begin
            BackButton.Caption := 'Back';
            SaveButton.Caption := 'Save';
            EngRadio.Checked := True;
            RusLabel.Caption := 'Russian';
            EngLabel.Caption := 'English';
        end
        else
        begin
            BackButton.Caption := 'Назад';
            SaveButton.Caption := 'Сохранить';
            RusRadio.Checked := True;
            RusLabel.Caption := 'Русский';
            EngLabel.Caption := 'Английский';
        end;
        RusLabel.Top := ClientHeight div 2;
        EngLabel.Top := RusLabel.Top;
        EngLabel.Left := (ClientWidth div 2 - EngLabel.Width) div 2;
        RusLabel.Left := (ClientWidth * 3 div 2 - RusLabel.Width) div 2;
        LanPanel.Height := EngRadio.Height;
        LanPanel.Width := ClientWidth;
        LanPanel.Left := 0;
        LanPanel.Top := EngLabel.Top + EngLabel.Height;
        EngRadio.Top := 0;
        RusRadio.Top := 0;
        EngRadio.Left := EngLabel.Left + EngLabel.Width div 2;
        RusRadio.Left := RusLabel.Left + RusLabel.Width div 2;
        Label1920.Top := ClientHeight * 2 div 3;
        Label1280.Top := Label1920.Top;
        Label1920.Left := (ClientWidth div 2 - Label1920.Width) div 2;
        Label1280.Left := (ClientWidth * 3 div 2 - Label1280.Width) div 2;
        SizePanel.Width := ClientWidth;
        SizePanel.Height := Radio1920.Height;
        SizePanel.Left := 0;
        SizePanel.Top := Label1920.Top + Label1920.Height;
        Radio1920.Top := 0;
        Radio1280.Top := 0;
        Radio1920.Left := Label1920.Left + Label1920.Width div 2;
        Radio1280.Left := Label1280.Left + Label1280.Width div 2;
        if(Settings.ScreenWidth = FULL_HD_W)then
            Radio1920.Checked := True
        else
            Radio1280.Checked := True;
        SaveButton.Top := ClientHeight - SaveButton.Height - 5;
        BackButton.Top := SaveButton.Top;
        SaveButton.Left := ClientWidth div 2 - SaveButton.Width - 5;
        BackButton.Left := ClientWidth div 2 + 5;
    end;
end;
procedure TMainMenuForm.FormCreate(Sender: TObject);
begin
    LoadSettings();
    SetSettings;
    SettingsPanel.Enabled := False;
    SettingsPanel.Hide;
    IsGame := True;
    ChooseShape.Pen.Color := $FF8000;
end;
procedure SwapArrayLeft();
var
    Tmp: TGame;
begin
    Tmp := Games[2];
    Games[2] := Games[1];
    Games[1] := Games[0];
    Games[0] := Tmp;
end;
procedure SwapArrayRight();
var
    Tmp: TGame;
begin
    Tmp := Games[0];
    Games[0] := Games[1];
    Games[1] := Games[2];
    Games[2] := Tmp;
end;


procedure TMainMenuForm.SaveButtonClick(Sender: TObject);
var
    OutputFile: File of TSettings;
    IsCorrect: Boolean;
begin
    if(Radio1920.Checked)then
    begin
        Settings.ScreenWidth := FULL_HD_W;
        Settings.ScreenHeight := FULL_HD_H;
    end
    else
    begin
        Settings.ScreenWidth := HD_W;
        Settings.ScreenHeight := HD_H;
    end;
    if(Bg1Radio.Checked)then
        Settings.Background := BG1_PATH
    else
        Settings.Background := BG2_PATH;
    if(EngRadio.Checked)then
        Settings.Language := English
    else
        Settings.Language := Russian;
    SetSettings;
    IsCorrect := True;
    try
        AssignFile(OutputFile,SETTINGS_PATH);
        Rewrite(OutputFile);
    except
        IsCorrect := False;
        if(Settings.Language = English)then
            Application.MessageBox('Couldn''t save settings', 'Error', MB_ICONERROR)
        else
            Application.MessageBox('Не удалось сохранит настройки', 'Ошибка', MB_ICONERROR);
    end;
    if(IsCorrect)then
    begin
        ShowSettings;
        Write(OutputFile, Settings);
        CloseFile(OutputFile);
        if(Settings.Language = English)then
            Application.MessageBox('Settings were successfully saved!', 'Success')
        else
            Application.MessageBox('Настройки успешно сохранены!', 'Успех');
    end;
end;

procedure TMainMenuForm.SettingsImageClick(Sender: TObject);
begin
    ShowSettings;
end;

procedure TMainMenuForm.SwapLeftTimerTimer(Sender: TObject);
begin
    if(LeftGame.Left < CenterX)then
    begin
        CenterGame.Left := CenterGame.Left + DeltaXCR;
        CenterGame.Top := CenterGame.Top + DeltaY;
        LeftGame.left := LeftGame.Left + DeltaXCL;
        RightGame.left := RightGame.Left + DeltaXCR;
        LeftGame.Top := LeftGame.Top - DeltaY;
        CenterGame.Width := CenterGame.Width - DeltaW;
        CenterGame.Height := CenterGame.Height - DeltaH;
        LeftGame.Width := LeftGame.Width + DeltaW;
        LeftGame.Height := LeftGame.Height + DeltaH;
        AddImage.left := AddImage.Left + DeltaXCL;
    end else
    begin
        SwapLeftTimer.Enabled := False;
        SwapArrayLeft();
        SetImagesSettings();
        LoadImages;
        IsAnimation := False;
        ChooseShape.Show;
    end;
end;

procedure TMainMenuForm.SwapRightTimerTimer(Sender: TObject);
begin
    if(CenterGame.Left > LeftX)then
    begin
        CenterGame.Left := CenterGame.Left - DeltaXCL;
        CenterGame.Top := CenterGame.Top + DeltaY;
        LeftGame.left := LeftGame.Left - DeltaXCL;
        RightGame.left := RightGame.Left - DeltaXCR;
        RightGame.Top := RightGame.Top - DeltaY;
        CenterGame.Width := CenterGame.Width - DeltaW;
        CenterGame.Height := CenterGame.Height - DeltaH;
        RightGame.Width := RightGame.Width + DeltaW;
        RightGame.Height := RightGame.Height + DeltaH;
        AddImage.left := AddImage.Left - DeltaXCR;
    end else
    begin
        SwapRightTimer.Enabled := False;
        SwapArrayRight();
        SetImagesSettings();
        LoadImages;
        IsAnimation := False;
        ChooseShape.Show;
    end;
end;

procedure Swap(Right: Boolean);
begin
    IsAnimation := True;
    if(Right)then
    begin
        MainMenuForm.AddImage.Top := MainMenuForm.RightGame.Top;
        MainMenuForm.AddImage.Left := MainMenuForm.RightGame.Left + DeltaXCR * 10;
        MainMenuForm.AddImage.Picture.Graphic := PngImages[ord(Games[0])];
        MainMenuForm.AddImage.Show();
        MainMenuForm.SwapRightTimer.Enabled := True;
        MainMenuForm.SwapRightTimer.Interval := 15;
    end
    else
    begin
        MainMenuForm.AddImage.Top := MainMenuForm.RightGame.Top;
        MainMenuForm.AddImage.Left := MainMenuForm.LeftGame.Left - DeltaXCL * 10;
        MainMenuForm.AddImage.Picture.Graphic := PngImages[ord(Games[2])];
        MainMenuForm.AddImage.Show();
        MainMenuForm.SwapLeftTimer.Enabled := True;
        MainMenuForm.SwapLeftTimer.Interval := 15;
    end;
    MainMenuForm.ChooseShape.Hide;
end;
procedure OpenGame();
begin
    case Games[1] of
        Tetris: begin
            MainMenuForm.Hide();
            TetrisForm.Show();
        end;
        Pong: begin
            MainMenuForm.Hide();
            PongForm.Show();
        end;
        Snake: begin
            MainMenuForm.Hide();
            SnakeForm.Show();
        end;
    end;
end;
procedure TMainMenuForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if(Not (SettingsPanel.Enabled))then
    begin
        if(IsGame)then
        begin
            if(Not IsAnimation)then
            begin
                if(Key = VK_RIGHT)then
                    Swap(True);
                if(Key = VK_LEFT)then
                    Swap(False);
                if(Key = VK_RETURN)then
                    OpenGame();
                if(Key = VK_UP)then
                    IsGame := False;
                if(Key = VK_UP)then
                begin
                    IsGame := False;
                    ChooseShape.Pen.Width := 4;
                    ChooseShape.Height := InfoImage.Height + InfoLabel.Height + 8;
                    ChooseShape.Width := ChooseShape.Height;
                    ChooseShape.Top := InfoImage.Top - 4;
                    ChooseShape.Left := InfoImage.Left - (ChooseShape.Width - InfoImage.Width) div 2;
                end;
            end;
        end;
        if(Not IsGame)then
        begin
            If(Key = VK_DOWN)then
            begin
                IsGame := True;
                ChooseShape.Pen.Width := 10;
                ChooseShape.Width := CenterGame.Width + 20;
                ChooseShape.Height := CenterGame.Height + 20;
                ChooseShape.Top := CenterGame.Top - 10;
                ChooseShape.Left := CenterGame.Left - 10;
            end;
            if(Key = VK_Left)then
                if(ChooseShape.Left > SettingsImage.Left)then
                    ChooseShape.Left := ChooseShape.Left - (InfoImage.Left - SettingsImage.Left);
            if(Key = VK_Right)then
                if(ChooseShape.Left < InfoImage.Left)then
                    ChooseShape.Left := ChooseShape.Left + (InfoImage.Left - SettingsImage.Left);
            if(Key = VK_Return)then
            begin
                if(ChooseShape.Left < SettingsImage.Left)then
                begin
                    ShowSettings;
                end
                else
                    if(ChooseShape.Left > InfoImage.Left)then
                        MainMenuForm.Close
                    else
                    begin
                        InfoForm.ShowModal;
                    end;
            end;
        end;
    end;
end;

procedure TMainMenuForm.InfoImageClick(Sender: TObject);
begin
    InfoForm.ShowModal;
end;

procedure TMainMenuForm.LeftGameClick(Sender: TObject);
begin
    if(Not IsAnimation)then Swap(False);
end;

procedure TMainMenuForm.RightGameClick(Sender: TObject);
begin
    if(Not IsAnimation)then Swap(True);
end;
procedure TMainMenuForm.BackButtonClick(Sender: TObject);
begin
    SettingsPanel.Enabled := False;
    SettingsPanel.Hide;
end;

procedure TMainMenuForm.CenterGameClick(Sender: TObject);
begin
    if(Not IsAnimation)then OpenGame();
end;

end.
