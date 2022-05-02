program Collection;

{$R *.dres}

uses
  Vcl.Forms,
  MainMenuUnit in 'MainMenuUnit.pas' {MainMenuForm},
  TetrisUnit in 'TetrisUnit.pas' {TetrisForm},
  PongUnit in 'PongUnit.pas' {PongForm},
  HideUnit in 'HideUnit.pas',
  SnakeUnit in 'SnakeUnit.pas' {SnakeForm},
  ListUnit in 'ListUnit.pas',
  InfoUnit in 'InfoUnit.pas' {InfoForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := False;
  Application.CreateForm(TMainMenuForm, MainMenuForm);
  Application.CreateForm(TTetrisForm, TetrisForm);
  Application.CreateForm(TPongForm, PongForm);
  Application.CreateForm(TSnakeForm, SnakeForm);
  Application.CreateForm(TInfoForm, InfoForm);
  Application.Icon.LoadFromFile('Game.ico');
  Application.Run;
end.
