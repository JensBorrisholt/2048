program Game2048;

uses
  Vcl.Forms,
  MainU in 'MainU.pas' {FormMain},
  GameBoardU in 'GameBoardU.pas',
  HighScoreU in 'HighScoreU.pas',
  TileU in 'TileU.pas',
  TransparentPanelU in 'TransparentPanelU.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'A clone of the clasic game 2048';
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
