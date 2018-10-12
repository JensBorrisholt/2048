unit MainU;

interface

uses
  Winapi.Windows, System.Actions, Winapi.Messages, System.SysUtils, System.UITypes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Grids, Vcl.ActnList, System.Classes,
  Vcl.AppEvnts,
  TileU, GameBoardU, Vcl.ExtCtrls, TransparentPanelU;

type
  TFormMain = class(TForm)
    actDown: TAction;
    actExit: TAction;
    ActionList1: TActionList;
    actLeft: TAction;
    actRestart: TAction;
    actRight: TAction;
    actUp: TAction;
    GameBoardGrid: TStringGrid;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Panel2: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    Shape1: TShape;
    Shape2: TShape;
    Label5: TLabel;
    Label6: TLabel;
    LabelScore: TLabel;
    LabelBest: TLabel;
    procedure actExitExecute(Sender: TObject);
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
    procedure actLeftExecute(Sender: TObject);
    procedure actRestartExecute(Sender: TObject);
    procedure FormClose(aSender: TObject; var aAction: TCloseAction);
    procedure FormCreate(aSender: TObject);
    procedure FormResize(Sender: TObject);
    procedure GameBoardGridDrawCell(aSender: TObject; aCol: Integer; aRow: Integer; aRect: TRect; aState: TGridDrawState);
  private
    procedure OnGameStateChanged(const aOldState, aNewState: TGameState);
    procedure UpdateScreen;
  end;

var
  FormMain: TFormMain;

implementation

uses
  System.StrUtils, HighscoreU;

{$R *.dfm}

procedure TFormMain.actExitExecute(Sender: TObject);
begin
  if (GameBoard.Score = 0) or (MessageDlg('Exit the game?', mtConfirmation, [mbOK, mbCancel], 0) = mrOK) then
    Application.Terminate;
end;

procedure TFormMain.ActionList1Update(Action: TBasicAction; var Handled: Boolean);
begin
  UpdateScreen;
end;

procedure TFormMain.actLeftExecute(Sender: TObject);
begin
  GameBoard.Swap(TDirection((Sender as TComponent).Tag));
end;

procedure TFormMain.actRestartExecute(Sender: TObject);
begin
  if (GameBoard.Score = 0) or (MessageDlg('Restart game?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    GameBoard.NewGame;
end;

procedure TFormMain.FormClose(aSender: TObject; var aAction: TCloseAction);
begin
  actExit.Execute;
end;

procedure TFormMain.FormCreate(aSender: TObject);
const
  NoSelection: TGridRect = (Left: 0; Top: - 1; Right: 0; Bottom: - 1);
begin
  with TTransparentPanel.Create(Self) do
  begin
    Parent := Self;
    Align := alClient;
  end;

  Application.ActionUpdateDelay := 1;

  GameBoardGrid.Selection := NoSelection;
  GameBoardGrid.DoubleBuffered := True;

  GameBoard.NewGame.OnGameStateChanged := OnGameStateChanged;
end;

procedure TFormMain.FormResize(Sender: TObject);
begin
  with GameBoardGrid do
  begin
    DefaultRowHeight := (ClientHeight - (RowCount - 1) * GridLineWidth) div RowCount;
    DefaultColWidth := (ClientWidth - (ColCount - 1) * GridLineWidth) div ColCount;
  end;
end;

procedure TFormMain.GameBoardGridDrawCell(aSender: TObject; aCol: Integer; aRow: Integer; aRect: TRect; aState: TGridDrawState);
var
  CellCenter: TPoint;
  TextSize: TSize;
  Tile: TTile;
begin
  Tile := GameBoard.Tile[aRow + 1, aCol + 1];

  GameBoardGrid.Canvas.FillRect(aRect);
  GameBoardGrid.Canvas.Brush.Color := Tile.Color;
  GameBoardGrid.Canvas.Font.Color := Tile.TextColor;
  GameBoardGrid.Canvas.Font.Style := [fsBold];
  GameBoardGrid.Canvas.Font.Size := 22;
  GameBoardGrid.Canvas.Font.Name := 'Tahoma';

  TextSize := GameBoardGrid.Canvas.TextExtent(Tile.Caption);
  CellCenter.Y := (aRect.Bottom - aRect.Top) div 2 + aRect.Top;
  CellCenter.X := (aRect.Right - aRect.Left) div 2 + aRect.Left;
  GameBoardGrid.Canvas.TextRect(aRect, CellCenter.X - TextSize.cx div 2, CellCenter.Y - TextSize.cy div 2, Tile.Caption);
end;

procedure TFormMain.OnGameStateChanged(const aOldState, aNewState: TGameState);
var
  Message: String;
  Player: String;
begin
  case aNewState of
    gsLost:
      message := 'You lost with %d points. Click "OK" to try again.';
    gsWon:
      message := 'You won with %d points. Click "OK" to restart or "Cancel" to continue.';
    gsHiScore:
      begin
        Player := InputBox(Application.Title, 'You have set a new high score, please enter your name', '');

        if Player <> '' then
          Highscore.WriteHighScore(Player, GameBoard.Score);

        LabelBest.Caption := Highscore.ReadScore.ToString;
      end;
  end;

  if aNewState in [gsLost, gsWon] then
    if MessageDlg(Format(message, [GameBoard.Score]), mtCustom, [mbOK], 0) = mrOK then
      GameBoard.NewGame;
end;

procedure TFormMain.UpdateScreen;
var
  Row: Integer;
  Col: Integer;
begin
  for Row := 0 to GameBoardGrid.RowCount - 1 do
    for Col := 0 to GameBoardGrid.ColCount - 1 do
      GameBoardGrid.Cells[Col, Row] := GameBoard.Tile[Row + 1, Col + 1].Caption;

  LabelScore.Caption := GameBoard.Score.ToString;
  LabelBest.Caption := Highscore.ReadScore.ToString;
end;

end.
