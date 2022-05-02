unit HideUnit;

interface

uses
  Forms, Messages, Windows;

type
  TForm = class(Forms.TForm)
  protected
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;
  end;

implementation

{ MyForm }
procedure TForm.WMSysCommand(var Msg: TWMSysCommand);
begin
  if Msg.CmdType = SC_MINIMIZE then
  Application.Minimize else inherited;
end;

end.
