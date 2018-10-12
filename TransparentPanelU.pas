unit TransparentPanelU;

interface

uses
  System.Classes, System.Types, System.Sysutils, Winapi.Windows, Winapi.Messages, Vcl.ExtCtrls, Vcl.Controls, VCL.Forms;

const
  ERROwnerNotForm = 'The owner is not a TForm';

type
  TFormNotOwner = class(Exception);

  TTransparentPanel = class(TPanel)
  private
    FOwner: TForm;
    IsDown: boolean;
    a, b: Integer;
  protected
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
    procedure CreateParams(var Params: TCreateParams); override;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{ TTransparentPanel }

constructor TTransparentPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if (AOwner is TForm) then
    FOwner := (AOwner as TForm)
  else if (AOwner.Owner is TForm) then
    FOwner := (AOwner.Owner as TForm)
  else if (AOwner.Owner.Owner is TForm) then
    FOwner := (AOwner.Owner.Owner as TForm)
  else
    raise TFormNotOwner.Create(ERROwnerNotForm);
  IsDown := false;
  a := 0;
  b := 0;
end;

procedure TTransparentPanel.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.ExStyle := Params.ExStyle or WS_EX_TRANSPARENT;
end;

procedure TTransparentPanel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    IsDown := True;
    a := X;
    b := Y;
  end;
  inherited;
end;

procedure TTransparentPanel.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
begin
  if IsDown then
    if (abs(X - a) > 5) or (abs(Y - b) > 5) then
    begin
      P := Point(X, Y);
      P := FOwner.ClientToScreen(P);
      MoveWindow(FOwner.Handle, P.X - a, P.Y - b, FOwner.Width, FOwner.Height, True);
    end;
  inherited;
end;

procedure TTransparentPanel.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  IsDown := false;
  inherited;
end;

procedure TTransparentPanel.WMEraseBkGnd(var Msg: TWMEraseBkGnd);
begin
  SetBkMode(Msg.DC, TRANSPARENT);
  Msg.result := 1;
end;

end.
