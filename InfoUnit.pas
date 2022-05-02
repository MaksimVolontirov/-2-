unit InfoUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TInfoForm = class(TForm)
    NameLabel: TLabel;
    GitHubLabel: TLabel;
    GitLinkLabel: TLabel;
    GmailLabel: TLabel;
    Label1: TLabel;
    BSUIRLabel: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InfoForm: TInfoForm;

implementation
uses MainMenuUnit;
{$R *.dfm}

procedure TInfoForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
    if(Key = Char(VK_ESCAPE))then
        InfoForm.Close;
end;

procedure TInfoForm.FormShow(Sender: TObject);
begin
    InfoForm.Top := MainMenuForm.Top + (MainMenuForm.Height - InfoForm.Height) div 2;
    InfoForm.Left := MainMenuForm.Left + (MainMenuForm.Width - InfoForm.Width) div 2;
    if(Settings.Language = English)then
    begin
        InfoForm.Caption := 'Info';
        BSUIRLabel.Caption := 'BSUIR, 2022';
    end
    else
    begin
        InfoForm.Caption := '»ÌÙÓ';
        BSUIRLabel.Caption := '¡√”»–, 2022';
    end;
end;

end.
