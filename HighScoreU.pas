unit HighScoreU;

interface

uses
  System.Win.Registry, WinApi.Windows;

type
  THighScoreRecord = record
    Player: String;
    Score: Integer;
  end;

  THighScore = class
  private
  const
    KEY_PLAYER: String = 'Player';
    KEY_SCORE: String = 'Score';
    Section = 'High Score';
  var
    FInifile: TRegistryIniFile;
  class var
    FInstance: THighScore;
    constructor Create; reintroduce;
    function ReadInteger(const Ident: String): Integer;
    function ReadString(const Ident: String): String;
    procedure WriteInteger(const Ident: String; Value: Integer);
    procedure WriteString(const Ident, Value: String);
  public
    class destructor Destroy;
    destructor Destroy; override;
    procedure DeleteHighScore;
    function HasHighScore: Boolean;
    function ReadHighScore: THighScoreRecord;
    function ReadPlayer: String;
    function ReadScore: Integer;
    procedure WriteHighScore(const aPlayer: String; const aScore: Integer); overload;
    procedure WriteHighScore(const aHighScore: THighScoreRecord); overload;
  end;

function Highscore: THighScore;

implementation

uses
  System.Sysutils;

function Highscore: THighScore;
begin
  if THighScore.FInstance = nil then
    THighScore.Create;
  Result := THighScore.FInstance;
end;

constructor THighScore.Create;
begin
  inherited;
  FInifile := TRegistryIniFile.Create('Software\Borrisholt\2048');
  FInstance := self;
end;

destructor THighScore.Destroy;
begin
  FInifile.Free;
  inherited;
end;

class destructor THighScore.Destroy;
begin
  FreeAndNil(FInstance);
end;

procedure THighScore.DeleteHighScore;
begin
  FInifile.EraseSection(Section);
end;

function THighScore.HasHighScore: Boolean;
begin
  Result := ReadScore <> 0;
end;

function THighScore.ReadHighScore: THighScoreRecord;
begin
  Result.Player := ReadString(KEY_PLAYER);
  Result.Score := ReadInteger(KEY_SCORE);
end;

function THighScore.ReadInteger(const Ident: String): Integer;
begin
  Result := FInifile.ReadInteger(Section, Ident, 0);
end;

function THighScore.ReadPlayer: String;
begin
  Result := ReadHighScore.Player;
end;

function THighScore.ReadScore: Integer;
begin
  Result := ReadHighScore.Score;
end;

function THighScore.ReadString(const Ident: String): String;
begin
  Result := FInifile.ReadString(Section, Ident, '');
end;

procedure THighScore.WriteHighScore(const aPlayer: String; const aScore: Integer);
begin
  if aScore = 0 then
    exit;

  WriteString(KEY_PLAYER, aPlayer);
  WriteInteger(KEY_SCORE, aScore);
end;

procedure THighScore.WriteHighScore(const aHighScore: THighScoreRecord);
begin
  WriteHighScore(aHighScore.Player, aHighScore.Score);
end;

procedure THighScore.WriteInteger(const Ident: String; Value: Integer);
begin
  FInifile.WriteInteger(Section, Ident, Value);
end;

procedure THighScore.WriteString(const Ident, Value: String);
begin
  FInifile.WriteString(Section, Ident, Value);
end;

end.
