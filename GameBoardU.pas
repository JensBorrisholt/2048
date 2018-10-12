unit GameBoardU;

interface

uses
  System.Classes, System.SysUtils, System.Math, System.Generics.Collections, TileU;

type
  TDirection = (dLeft, dRight, dUp, dDown);
  TGameState = (gsPlaying, gsLost, gsWon, gsHiScore);

  TGameStateChanged = procedure(const aOldState, aNewState: TGameState) of object;

  TTileList = class(TObjectList<TTile>)
  public
    constructor Create(aTileList: TTileList; aOwnsObjects: Boolean = True); reintroduce;
    function Add(const Value: TTile): TTile; reintroduce;
  end;

  TGameBoard = class
  private
    FColCount: Integer;
    FGameState: TGameState;
    FOnGameStateChanged: TGameStateChanged;
    FRowCount: Integer;
    FScore: Integer;
    FTiles: TTileList;
  class var
    class var Finstance: TGameBoard;
    constructor Create(const aRowCount: Integer; const aColCount: Integer); reintroduce;
    procedure AlignDown;
    procedure AlignLeft;
    procedure AlignRight;
    procedure AlignUp;
    procedure FillRandomEmptyTile;
    function GetTile(aRow: Integer; aCol: Integer): TTile;
    function GetTilesCount: Integer; inline;
    function HasLost: Boolean;
    function HasWon: Boolean;
    procedure IncScore(const aScore: Integer);
    procedure Initialize;
    procedure SetGameState(NewGameState: TGameState);
    procedure UpdateGameState;
  public
    class constructor Create;
    destructor Destroy; override;
    class destructor Destroy;
    function NewGame: TGameBoard;
    function Swap(const aDirection: TDirection): Boolean;
    property GameState: TGameState read FGameState;
    property Score: Integer read FScore;
    property Tile[aRow: Integer; aCol: Integer]: TTile read GetTile; default;
    property OnGameStateChanged: TGameStateChanged read FOnGameStateChanged write FOnGameStateChanged;
  end;

function GameBoard: TGameBoard;

implementation

uses
  System.Threading, HighScoreU;

const
  DEFAULT_INDEX: Integer = -1;

function GameBoard: TGameBoard;
begin
  if TGameBoard.Finstance = nil then
    TGameBoard.Create(4, 4);
  Result := TGameBoard.Finstance;
end;

class constructor TGameBoard.Create;
begin
  Randomize;
end;

class destructor TGameBoard.Destroy;
begin
  FreeAndNil(Finstance);
end;

constructor TGameBoard.Create(const aRowCount: Integer; const aColCount: Integer);
begin
  inherited Create;
  FScore := 0;
  FRowCount := aRowCount;
  FColCount := aColCount;
  Finstance := Self;
  Initialize;
end;

destructor TGameBoard.Destroy;
begin
  FreeAndNil(FTiles);
  inherited;
end;

procedure TGameBoard.AlignDown;
var
  Tile: TTile;
begin
  for Tile in FTiles do
    Tile.AlignDown;
end;

procedure TGameBoard.AlignLeft;
var
  Tile: TTile;
begin
  for Tile in FTiles do
    Tile.AlignLeft;
end;

procedure TGameBoard.AlignRight;
var
  Tile: TTile;
begin
  for Tile in FTiles do
    Tile.AlignRight;
end;

procedure TGameBoard.AlignUp;
var
  Tile: TTile;
begin
  for Tile in FTiles do
    Tile.AlignUp;
end;

procedure TGameBoard.FillRandomEmptyTile;
var
  Tile: TTile;
  TileList: TTileList;
begin
  TileList := TTileList.Create(nil, False);
  try
    for Tile in FTiles do
      if Tile.IsEmpty then
        TileList.Add(Tile);
    TileList[Random(TileList.Count)].Fill
  finally
    TileList.Free
  end;
end;

function TGameBoard.GetTile(aRow: Integer; aCol: Integer): TTile;
begin
  if (aRow <= FRowCount) and (aCol <= FColCount) then
    Result := FTiles.Items[(aCol - 1) + ((aRow - 1) * FColCount)]
  else
    Result := nil;
end;

function TGameBoard.GetTilesCount: Integer;
begin
  Result := FRowCount * FColCount;
end;

function TGameBoard.HasLost: Boolean;
var
  Tile: TTile;
begin
  Result := True;
  for Tile in FTiles do
    if Tile.CanMerge then
      exit(False);
end;

function TGameBoard.HasWon: Boolean;
var
  Tile: TTile;
begin
  Result := False;
  for Tile in FTiles do
    if Tile.IsMax then
      exit(True);
end;

procedure TGameBoard.IncScore(const aScore: Integer);
begin
  Inc(FScore, aScore);
end;

procedure TGameBoard.Initialize;
var
  Row, Col: Integer;
begin
  if GetTilesCount > 0 then
  begin
    FTiles := TTileList.Create(nil);

    for Row := 1 to FRowCount do
      for Col := 1 to FColCount do
        FTiles.Add(TTile.Create(Row, Col)).OnIncScore := IncScore;
  end;

  for Row := 1 to FRowCount do
    for Col := 1 to FColCount do
    begin
      if (FRowCount > 1) then
      begin
        if Row > 1 then
          Tile[Row, Col].UpTile := Tile[Row - 1, Col];

        if Row < FRowCount then
          Tile[Row, Col].DownTile := Tile[Row + 1, Col];
      end;

      if (FColCount > 1) then
      begin
        if Col > 1 then
          Tile[Row, Col].LeftTile := Tile[Row, Col - 1];

        if Col < FColCount then
          Tile[Row, Col].RightTile := Tile[Row, Col + 1];
      end;
    end;
end;

function TGameBoard.NewGame: TGameBoard;
begin
  FTiles.Clear;
  Initialize;
  FScore := 0;
  SetGameState(TGameState.gsPlaying);
  FillRandomEmptyTile;
  FillRandomEmptyTile;
  Result := Self;
end;

procedure TGameBoard.SetGameState(NewGameState: TGameState);
begin
  if Assigned(FOnGameStateChanged) then
    FOnGameStateChanged(FGameState, NewGameState);

  FGameState := NewGameState;
end;

function TGameBoard.Swap(const aDirection: TDirection): Boolean;
var
  Tile: TTile;
begin
  Result := False;

  if GetTilesCount = 0 then
    exit;

  case aDirection of
    dLeft:
      AlignLeft;
    dRight:
      AlignRight;
    dUp:
      AlignUp;
    dDown:
      AlignDown;
  end;

  for Tile in FTiles do
    if Tile.Changed then
    begin
      Result := True;
      Tile.Changed := False;
    end;

  if Result then
    FillRandomEmptyTile;

  if Result then
    TTask.Run(
      procedure
      begin
        TThread.Synchronize(nil,
          procedure
          begin
            UpdateGameState;
          end);
      end);
end;

procedure TGameBoard.UpdateGameState;
begin
  if HasLost then
    SetGameState(TGameState.gsLost)
  else if HasWon then
    SetGameState(TGameState.gsWon);

  if (FGameState <> TGameState.gsHiScore) and (GameBoard.Score > Highscore.ReadHighScore.Score) then
    SetGameState(TGameState.gsHiScore);
end;

constructor TTileList.Create(aTileList: TTileList; aOwnsObjects: Boolean);
var
  aTile: TTile;
begin
  inherited Create;

  OwnsObjects := aOwnsObjects;

  if aTileList <> nil then
    for aTile in aTileList do
      Add(TTile.Create(aTile));
end;

{ TTileList }

function TTileList.Add(const Value: TTile): TTile;
begin
  inherited Add(Value);
  Result := Value;
end;

end.
