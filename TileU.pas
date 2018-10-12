unit TileU;

interface

uses
  System.Math, System.UITypes, System.SysUtils, System.StrUtils;

type
  TIncScoreEvent = procedure(const aScore: Integer) of object;

  TTile = class
  strict private
  const
    COLOR_DEFAULT: TColor = $B4C0CD;
    COLORS: array [1 .. 11] of TColor = ($DAE4EE, $C8E0ED, $79B1F2, $6395F5, $5F7CF6, $3B5EF6, $72CFED, $61CCED, $50C8ED, $3FC5ED, $2EC2ED);

    BASE: Integer = 2;
    DEFAULT_POWER: Integer = 0;
    INITIAL_POWER: Integer = 1;
    MAX_POWER: Integer = 11;
  private
    FChanged: Boolean;
    FCol: Integer;
    FDownTile: TTile;
    FLeftTile: TTile;
    FOnIncScore: TIncScoreEvent;
    FPower: Integer;
    FRightTile: TTile;
    FRow: Integer;
    FUpTile: TTile;
    procedure DoMerge(aTile: TTile);
    function GetContrastColor(aColor: TColor): TColor;
    procedure Clear;
    procedure DoOnIncScore(const aScore: Integer);
    function GetCanMerge: Boolean;
    function GetCaption: String; inline;
    function GetColor: TColor;
    function GetValue: Integer;
    function HasSamePower(const aTile: TTile): Boolean;
    function DoMove(aTile: TTile): Boolean;
    procedure MoveDown;
    procedure MoveLeft;
    procedure MoveRight;
    procedure MoveUp;

    procedure MergeDown;
    procedure MergeLeft;
    procedure MergeRight;
    procedure MergeUp;

    procedure RecursiveMergeDown;
    procedure RecursiveMergeLeft;
    procedure RecursiveMergeRight;
    procedure RecursiveMergeUp;
    procedure RecursiveMoveDown;
    procedure RecursiveMoveLeft;
    procedure RecursiveMoveRight;
    procedure RecursiveMoveUp;
    function GetTextColor: TColor;
    function HasDownTile: Boolean; {$IFNDEF DEBUG}inline; {$ENDIF}
    function HasLeftTile: Boolean; {$IFNDEF DEBUG}inline; {$ENDIF}
    function HasRightTile: Boolean; {$IFNDEF DEBUG}inline; {$ENDIF}
    function HasUpTile: Boolean; {$IFNDEF DEBUG}inline; {$ENDIF}
    function IsDownTile: Boolean; {$IFNDEF DEBUG}inline; {$ENDIF}
    function IsLeftTile: Boolean; {$IFNDEF DEBUG}inline; {$ENDIF}
    function IsRightTile: Boolean; {$IFNDEF DEBUG}inline; {$ENDIF}
    function IsUpTile: Boolean; {$IFNDEF DEBUG}inline; {$ENDIF}
  public
    constructor Create(const aRow: Integer; const aCol: Integer); overload;
    constructor Create(const aTile: TTile); overload;
    procedure AlignDown;
    procedure AlignLeft;
    procedure AlignRight;
    procedure AlignUp;
    procedure Fill;
    function IsMax: Boolean; {$IFNDEF DEBUG}inline; {$ENDIF}
    function IsEmpty: Boolean; {$IFNDEF DEBUG}inline; {$ENDIF}
    function ToString: String; override;
    property CanMerge: Boolean read GetCanMerge;
    property Caption: String read GetCaption;
    property TilePower: Integer read FPower write FPower;
    property Changed: Boolean read FChanged write FChanged;
    property Col: Integer read FCol write FCol;
    property Color: TColor read GetColor;
    property DownTile: TTile read FDownTile write FDownTile;
    property LeftTile: TTile read FLeftTile write FLeftTile;
    property RightTile: TTile read FRightTile write FRightTile;
    property Row: Integer read FRow write FRow;
    property UpTile: TTile read FUpTile write FUpTile;
    property Value: Integer read GetValue;
    property OnIncScore: TIncScoreEvent read FOnIncScore write FOnIncScore;
    property TextColor: TColor read GetTextColor;
  end;

implementation

uses
  VCL.GraphUtil;

constructor TTile.Create(const aRow: Integer; const aCol: Integer);
begin
  FPower := DEFAULT_POWER;
  FRow := aRow;
  FCol := aCol;
  FLeftTile := nil;
  FRightTile := nil;
  FUpTile := nil;
  FDownTile := nil;
  FOnIncScore := nil;
end;

constructor TTile.Create(const aTile: TTile);
begin
  FPower := aTile.FPower;
  FRow := aTile.FRow;
  FCol := aTile.FCol;
  FLeftTile := aTile.FLeftTile;
  FRightTile := aTile.FRightTile;
  FUpTile := aTile.FUpTile;
  FDownTile := aTile.FDownTile;
  FOnIncScore := aTile.FOnIncScore;
end;

procedure TTile.AlignDown;
begin
  if not IsDownTile then
    exit;

  RecursiveMoveDown;
  RecursiveMergeDown;
  RecursiveMoveDown;
end;

procedure TTile.AlignLeft;
begin
  if not IsLeftTile then
    exit;

  RecursiveMoveLeft;
  RecursiveMergeLeft;
  RecursiveMoveLeft;
end;

procedure TTile.AlignRight;
begin
  if not IsRightTile then
    exit;

  RecursiveMoveRight;
  RecursiveMergeRight;
  RecursiveMoveRight;
end;

procedure TTile.AlignUp;
begin
  if not IsUpTile then
    exit;

  RecursiveMoveUp;
  RecursiveMergeUp;
  RecursiveMoveUp;
end;

procedure TTile.Clear;
begin
  FPower := DEFAULT_POWER;
  FChanged := True;
end;

procedure TTile.DoMerge(aTile: TTile);
begin
  if not Assigned(aTile) then
    exit;

  if aTile.IsEmpty then
    exit;

  if FPower <> aTile.TilePower then
    exit;

  Inc(FPower);
  aTile.Clear;
  DoOnIncScore(Value);
end;

function TTile.DoMove(aTile: TTile): Boolean;
begin
  if (not Assigned(aTile)) or (IsEmpty or (not aTile.IsEmpty)) then
    exit(false);

  Result := True;
  aTile.TilePower := FPower;
  Clear;
end;

procedure TTile.DoOnIncScore(const aScore: Integer);
begin
  FChanged := True;
  if Assigned(FOnIncScore) then
    FOnIncScore(aScore);
end;

procedure TTile.Fill;
begin
  FPower := INITIAL_POWER;
  FChanged := false;
end;

function TTile.GetCanMerge: Boolean;
begin
  Result := IsEmpty;
  if (not Result) and HasLeftTile then
    Result := HasSamePower(FLeftTile);
  if (not Result) and HasRightTile then
    Result := HasSamePower(FRightTile);
  if (not Result) and HasUpTile then
    Result := HasSamePower(FUpTile);
  if (not Result) and HasDownTile then
    Result := HasSamePower(FDownTile);
end;

function TTile.GetCaption: String;
begin
  Result := IfThen(IsEmpty, String.Empty, Value.ToString);
end;

function TTile.GetColor: TColor;
begin
  if IsEmpty then
    Result := COLOR_DEFAULT
  else
    Result := COLORS[FPower];
end;

function TTile.GetContrastColor(aColor: TColor): TColor;
var
  Hue, Luminance, Saturation: Word;
begin
  // convert the color in hue, luminance, saturation
  ColorRGBToHLS(aColor, Hue, Luminance, Saturation);

  if (Luminance < 120) or ((Luminance = 120) and (Hue > 120)) then
    Result := TColors.White
  else
    Result := TColors.Black;
end;

function TTile.GetTextColor: TColor;
begin
  Result := GetContrastColor(Color);
end;

function TTile.GetValue: Integer;
begin
  Result := Round(Power(BASE, FPower));
end;

function TTile.HasDownTile: Boolean;
begin
  Result := Assigned(FDownTile);
end;

function TTile.HasLeftTile: Boolean;
begin
  Result := Assigned(FLeftTile);
end;

function TTile.HasRightTile: Boolean;
begin
  Result := Assigned(FRightTile);
end;

function TTile.HasSamePower(const aTile: TTile): Boolean;
begin
  Result := false;
  if Assigned(aTile) then
    Result := FPower = aTile.TilePower;
end;

function TTile.HasUpTile: Boolean;
begin
  Result := Assigned(FUpTile);
end;

function TTile.IsDownTile: Boolean;
begin
  Result := not HasDownTile;
end;

function TTile.IsEmpty: Boolean;
begin
  Result := FPower = DEFAULT_POWER;
end;

function TTile.IsLeftTile: Boolean;
begin
  Result := not HasLeftTile;
end;

function TTile.IsMax: Boolean;
begin
  Result := FPower >= MAX_POWER;
end;

function TTile.IsRightTile: Boolean;
begin
  Result := not HasRightTile;
end;

function TTile.IsUpTile: Boolean;
begin
  Result := not HasUpTile;
end;

procedure TTile.MergeDown;
begin
  DoMerge(FUpTile);
end;

procedure TTile.MergeLeft;
begin
  DoMerge(FRightTile);
end;

procedure TTile.MergeRight;
begin
  DoMerge(FLeftTile);
end;

procedure TTile.MergeUp;
begin
  DoMerge(FDownTile);
end;

procedure TTile.MoveDown;
begin
  if DoMove(FDownTile) then
    FDownTile.MoveDown;
end;

procedure TTile.MoveLeft;
begin
  if DoMove(FLeftTile) then
    FLeftTile.MoveLeft;
end;

procedure TTile.MoveRight;
begin
  if DoMove(FRightTile) then
    FRightTile.MoveRight;
end;

procedure TTile.MoveUp;
begin
  if DoMove(FUpTile) then
    FUpTile.MoveUp;
end;

procedure TTile.RecursiveMergeDown;
begin
  MergeDown;
  if HasUpTile then
    FUpTile.RecursiveMergeDown;
end;

procedure TTile.RecursiveMergeLeft;
begin
  MergeLeft;
  if HasRightTile then
    FRightTile.RecursiveMergeLeft;
end;

procedure TTile.RecursiveMergeRight;
begin
  MergeRight;
  if HasLeftTile then
    FLeftTile.RecursiveMergeRight;
end;

procedure TTile.RecursiveMergeUp;
begin
  MergeUp;
  if HasDownTile then
    FDownTile.RecursiveMergeUp;
end;

procedure TTile.RecursiveMoveDown;
begin
  MoveDown;
  if HasUpTile then
    FUpTile.RecursiveMoveDown;
end;

procedure TTile.RecursiveMoveLeft;
begin
  MoveLeft;
  if HasRightTile then
    FRightTile.RecursiveMoveLeft;
end;

procedure TTile.RecursiveMoveRight;
begin
  MoveRight;
  if HasLeftTile then
    FLeftTile.RecursiveMoveRight;
end;

procedure TTile.RecursiveMoveUp;
begin
  MoveUp;
  if HasDownTile then
    FDownTile.RecursiveMoveUp;
end;

function TTile.ToString: String;
begin
  Result := Caption;
end;

end.
