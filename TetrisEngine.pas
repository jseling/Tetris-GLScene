// To do implementation of Line Destructor for to score  (most of commented lines is for line destructor)

unit TetrisEngine;

interface

uses
  GLScene, GLObjects, Classes, GLVectorTypes, GLVectorGeometry, GLBaseClasses, GLPersistentClasses,
  GLCoordinates;

type
  T3DTInput = (inpNone, inpMoveL, inpMoveR, inpRotateL, inpRotateR);
  T3DTSlideOrLift = (TSlide, TLift, TRSlide, TRLift);
  T3DTRightOrLeft = (TNone, TRight, TLeft);
  T3DTRotation = (r0, r90, r180, r270);

type
  T3DTBlockViewer = class(TGLDummyCube)
  private
    FCubes: array [0 .. 3] of TGLCube;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetBlock(Block: Integer);
  end;

type
  T3DTBlock = class(TGLDummyCube)
  private
    FBlock: Integer;
    FBlockRotation: T3DTRotation;
    FRotate: Boolean;
    FBlockDirection: T3DTRightOrLeft;
    FSlideOrLift: T3DTSlideOrLift;
    FBlockCubes: array [0 .. 3] of TGLCube;
    FActive: Boolean;
    FSpeed: real;
    FTime: single;
    FGame: Boolean;
    FDoRotation: T3DTRotation;
    // TYTile:Integer;
    // TXTile:Integer;
  protected
    procedure SetBlock(Block: Integer);
  public
    // O bloco está tivo ou desativo?
    // The block is active or inactive?
    property Active: Boolean read FActive write FActive;

    // Velocidade de queda do bloco
    // Falling block speed
    property Speed: real read FSpeed write FSpeed;

    // Forma do bloco
    // Block shape
    property Block: Integer read FBlock write SetBlock;

    // O jogo acabou?
    // The game is over?
    property GameOver: Boolean read FGame;

    // property XTileBlocks: Integer read TXTile write TXTile;
    // property YTileBlocks: Integer read TYTile write TYTile;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Move(UserInput: T3DTInput);
    procedure DoProgress(const progressTime: TGLProgressTimes); override;
  end;

procedure SetLevel();
function NextRot(Rot: T3DTRotation): T3DTRotation;
function PrevRot(Rot: T3DTRotation): T3DTRotation;

// const          //To do implementation with rows'n lines variables
// Para implementação com colunas e linhas variáveis
// MAX_LINES=100;
// MAX_ROWS=50;

var
  FloodLevels: array [-6 .. 6] of array [-11 .. 10] of Boolean;
  // FloodLevels: array[-MAX_ROWS..MAX_ROWS] of array[-MAX_LINES..MAX_LINES] of Boolean;

implementation

constructor T3DTBlock.Create(AOwner: TComponent);
var
  i: Integer;
begin
  inherited;
  FSpeed := 1;
  FActive := True;
  FTime := 0;
  // ShowAxes:=True;
  FBlockRotation := r0;
  FDoRotation := FBlockRotation;

  FGame := False;
  FRotate := False;
  FSlideOrLift := TSlide;
  Position.SetPoint(0, 9, 0);
  Randomize();

  for i := 0 to 3 do
  begin
    FBlockCubes[i] := TGLCube(T3DTBlock(self).AddNewChild(TGLCube));
    FBlockCubes[i].CubeWidth := 0.95;
    FBlockCubes[i].CubeHeight := 0.95;
    FBlockCubes[i].CubeDepth := 0.95;
  end;
  SetBlock(0);
end;

destructor T3DTBlock.Destroy;
begin
  inherited Destroy;
end;

// define movimentos ao block ativo
procedure T3DTBlock.Move(UserInput: T3DTInput);
begin
  // ******************************************************************************
  if Active then
    case UserInput of

      inpMoveL:
        begin
          Case FBlockRotation of
            r0:
              FSlideOrLift := TSlide;
            r90:
              FSlideOrLift := TLift;
            r180:
              FSlideOrLift := TRSlide;
            r270:
              FSlideOrLift := TRLift;
          end;

          FBlockDirection := TLeft;

        end;

      inpMoveR:
        begin
          Case FBlockRotation of
            r0:
              FSlideOrLift := TSlide;
            r90:
              FSlideOrLift := TLift;
            r180:
              FSlideOrLift := TRSlide;
            r270:
              FSlideOrLift := TRLift;
          end;
          FBlockDirection := TRight;

        end;

      inpRotateR:
        begin
          FDoRotation := NextRot(FBlockRotation);
          FRotate := True;
        end;

      inpRotateL:
        begin
          FDoRotation := PrevRot(FBlockRotation);
          FRotate := True;
        end;

    end;
  // ******************************************************************************
end;

procedure T3DTBlock.DoProgress(const progressTime: TGLProgressTimes);
var
  i, j: Integer;
  absPos: TVector;
  FloodRight, FloodLeft: Boolean;
  ValRot: Boolean;
  SimBlock: TGLDummyCube;
  SimCube: array [0 .. 3] of TGLDummyCube;
  // -----------------------
  // VARIABLES FOR LINE DESTRUCTOR
  // k:integer;
  // isline:Boolean;
  // line: array [0..3] of integer;
  // lineind:integer;
begin
  inherited;
  // ******************************************************************************
  // Testa se o bloco está ativo
  // If the block is active
  if Active then
  begin
    // ------------------------------------
    // POSIÇÃO-POSITION
    // ------------------
    FloodRight := False;
    FloodLeft := False;

    for i := 0 to 3 do
    begin
      setVector(absPos, Children[i].AbsolutePosition);

      if (FloodRight = False) then
        FloodRight := FloodLevels[round(absPos.x) - 1][round(absPos.y)];

      if (FloodLeft = False) then
        FloodLeft := FloodLevels[round(absPos.x) + 1][round(absPos.y)];
    end;

    if (FBlockDirection = TRight) and (FloodRight = False) then
    begin
      Case FSlideOrLift of
        TSlide:
          T3DTBlock(self).Slide(1);
        TLift:
          T3DTBlock(self).Lift(1);
        TRSlide:
          T3DTBlock(self).Slide(-1);
        TRLift:
          T3DTBlock(self).Lift(-1);
      end;
      FBlockDirection := TNone;
    end;

    if (FBlockDirection = TLeft) and (FloodLeft = False) then
    begin
      Case FSlideOrLift of
        TSlide:
          T3DTBlock(self).Slide(-1);
        TLift:
          T3DTBlock(self).Lift(-1);
        TRSlide:
          T3DTBlock(self).Slide(1);
        TRLift:
          T3DTBlock(self).Lift(1);
      end;
      FBlockDirection := TNone;
    end;
    // ------------------------------------

    // ------------------------------------
    // ROTAÇÃO-ROTATION
    // ------------------

    if FRotate then
    begin
      SimBlock := TGLDummyCube(T3DTBlock(self).Parent.AddNewChild
        (TGLDummyCube));
      SimBlock.AbsolutePosition := T3DTBlock(self).AbsolutePosition;
      SimBlock.RollAngle := T3DTBlock(self).RollAngle;

      for i := 0 to 3 do
      begin
        SimCube[i] := TGLDummyCube(SimBlock.AddNewChild(TGLDummyCube));
        // SimCube[i].VisibleAtRunTime:=True; //Uncomment this line for Debug -Descomente esta linha para debug
        SimCube[i].AbsolutePosition := Children[i].AbsolutePosition;
      end;

      case FDoRotation of
        r0:
          begin
            SimBlock.RollAngle := 0;
          end;

        r90:
          begin
            SimBlock.RollAngle := 90;
          end;

        r180:
          begin
            SimBlock.RollAngle := 180;
          end;

        r270:
          begin
            SimBlock.RollAngle := -90;
          end;
      end;

      ValRot := False;
      for i := 0 to 3 do
      begin
        setVector(absPos, SimCube[i].AbsolutePosition);
        if (ValRot = False) then
          ValRot := FloodLevels[round(absPos.x)][round(absPos.y)];
      end;

      SimBlock.Destroy;
      // Comment this line for Debug -Comente esta linha para debug

      if ValRot = False then // Don't Collide - Não Colide
      begin
        Case FDoRotation of
          r0:
            begin
              T3DTBlock(self).RollAngle := 0;
            end;
          r90:
            begin
              T3DTBlock(self).RollAngle := 90;
            end;
          r180:
            begin
              T3DTBlock(self).RollAngle := 180;
            end;
          r270:
            begin
              T3DTBlock(self).RollAngle := -90;
            end;
        end;
        FBlockRotation := FDoRotation;
      end;
      FRotate := False;
    end;
    // ------------------------------------

    // ------------------------------------
    // COLISÃO COM FLOODLEVEL-COLLISION WITH FLOODLEVEL
    // ------------------
    // Passa por cada cubo que forma o bloco
    // Iterate for each cube that make up the block
    for i := 0 to 3 do
    begin
      // Pega a posição absoluta do cubo
      // Get de cube absolute position
      setVector(absPos, Children[i].AbsolutePosition);

      // Se o bloco da matriz logo abaixo for true
      // If the matrix block botton is true
      if FloodLevels[round(absPos.x)][round(absPos.y) - 1] then
      begin
        // O bloco inteiro pára de cair se colidir com floodlevel
        // The whole block stop of falling if collide with floodlevel
        FActive := False;
      end;

      if FActive = False then
        // Se o cubo colidinte não é o primeiro, devemos verificar todos de novo
        // If the colliding block is not the first, we must check all again
        for j := 0 to 3 do
        begin
          setVector(absPos, Children[j].AbsolutePosition);
          // Ocupa o FloodLevel do cubo
          // Take up the cube floodlevel
          FloodLevels[round(absPos.x)][round(absPos.y)] := True;
        end;
    end;
    // -------------------------------------

    // -----------------------------------
    // QUEDA-FALL
    // ------------------
    // Os blocos caem se estão ativados
    // The blocks fall if active
    FTime := FTime + progressTime.deltatime;
    if FTime >= FSpeed then
    begin
      Position.y := Position.y - 1;
      FTime := 0;
    end;
    // ------------------------------------

  end;
  // ******************************************************************************
  // ------------------------------------
  // LINE DESTRUCTOR      //Possible fix: use one line storer, dont four
  // to do the block fall when one line is detructed
  // ------------------------------------
  { lineind:=0;
    isline:=True;
    for j:=0 to 20 do
    begin
    for i:=0 to 10 do
    begin
    if isline=true then
    isline:=floodlevels[i-5][j-10];
    end;
    if isline=true then
    begin
    line[lineind]:=j-10;
    lineind:=lineind+1;
    end;
    end;
    //searched lines
    //linhas encontradas

    for i:=0 to T3DTBlock(Self).Parent.Count-1 do
    if T3DTBlock(T3DTBlock(Self).Parent.Children[i]).Active=false then
    for j:= 0 to T3DTBlock(T3DTBlock(Self).Parent.Children[i]).Count-1 do
    begin
    setVector(absPos, T3DTBlock(T3DTBlock(Self).Parent.Children[i]).Children[j].AbsolutePosition);
    for k:=0 to 3 do
    if absPos[1]=line[k] then
    TGLCube(T3DTBlock(T3DTBlock(Self).Parent.Children[i]).Children[j]).destroy;        //Don't Work!
    //TGLCube(T3DTBlock(T3DTBlock(Self).Parent.Children[i]).Children[j]).Material.FrontProperties.Diffuse.SetColor(random, random, random);   //Work why?
    end; }
  // ------------------------------------

  // GAMEOVER DEFINER
  for i := -5 to 5 do
    if FloodLevels[i][9] then
      FGame := True;
end;

procedure T3DTBlock.SetBlock(Block: Integer);
var
  j: Integer;
begin
  FBlock := Block;
  case Block of
    0: // I
      begin
        FBlockCubes[0].Position.SetPoint(2, 0, 0);
        FBlockCubes[1].Position.SetPoint(1, 0, 0);
        FBlockCubes[2].Position.SetPoint(0, 0, 0);
        FBlockCubes[3].Position.SetPoint(-1, 0, 0);
        for j := 0 to 3 do // Azul-Blue
          TGLCube(Children[j]).Material.FrontProperties.Diffuse.
            SetColor(0, 0, 1);
      end;
    1: // L
      begin
        FBlockCubes[0].Position.SetPoint(-1, 0, 0);
        FBlockCubes[1].Position.SetPoint(0, 0, 0);
        FBlockCubes[2].Position.SetPoint(1, 0, 0);
        FBlockCubes[3].Position.SetPoint(1, 1, 0);
        for j := 0 to 3 do // Verde-Green
          TGLCube(Children[j]).Material.FrontProperties.Diffuse.
            SetColor(0, 1, 0);
      end;
    2: // L*
      begin
        FBlockCubes[0].Position.SetPoint(-1, 1, 0);
        FBlockCubes[1].Position.SetPoint(-1, 0, 0);
        FBlockCubes[2].Position.SetPoint(0, 0, 0);
        FBlockCubes[3].Position.SetPoint(1, 0, 0);
        for j := 0 to 3 do // Amarelo-Yellow
          TGLCube(Children[j]).Material.FrontProperties.Diffuse.
            SetColor(1, 1, 0);
      end;
    3: // S
      begin
        FBlockCubes[0].Position.SetPoint(-1, 0, 0);
        FBlockCubes[1].Position.SetPoint(0, 0, 0);
        FBlockCubes[2].Position.SetPoint(0, 1, 0);
        FBlockCubes[3].Position.SetPoint(1, 1, 0);
        for j := 0 to 3 do // Ciano-Cyan
          TGLCube(Children[j]).Material.FrontProperties.Diffuse.
            SetColor(0, 1, 1);
      end;
    4: // S*
      begin
        FBlockCubes[0].Position.SetPoint(-1, 1, 0);
        FBlockCubes[1].Position.SetPoint(0, 1, 0);
        FBlockCubes[2].Position.SetPoint(0, 0, 0);
        FBlockCubes[3].Position.SetPoint(1, 0, 0);
        for j := 0 to 3 do // Roxo-Purple
          TGLCube(Children[j]).Material.FrontProperties.Diffuse.
            SetColor(1, 0, 1);
      end;
    5: // T
      begin
        FBlockCubes[0].Position.SetPoint(-1, 0, 0);
        FBlockCubes[1].Position.SetPoint(0, 1, 0);
        FBlockCubes[2].Position.SetPoint(0, 0, 0);
        FBlockCubes[3].Position.SetPoint(1, 0, 0);
        for j := 0 to 3 do // Vermelho-Red
          TGLCube(Children[j]).Material.FrontProperties.Diffuse.
            SetColor(1, 0, 0);
      end;
  end;

end;

procedure SetLevel();
// procedure SetLevel(XTile:integer;YTile:integer);
var
  i, j: Integer;
begin
  // TYTile:=(YTile-YTile div 2)
  // TYTile:=(XTile-XTile div 2)

  for i := -5 to 5 do
    for j := -10 to 10 do
      FloodLevels[i][j] := False;
  // Floor-Chão
  for i := -5 to 5 do
    FloodLevels[i][-11] := True;
  // Walls-Paredes
  for i := -10 to 10 do
  begin
    FloodLevels[-6][i] := True;
    FloodLevels[6][i] := True;
  end;
end;

function NextRot(Rot: T3DTRotation): T3DTRotation;
begin
  Case Rot of
    r0:
      Result := r90;
    r90:
      Result := r180;
    r180:
      Result := r270;
    r270:
      Result := r0
  else
    Result := r0;
  end;
end;

function PrevRot(Rot: T3DTRotation): T3DTRotation;
begin
  Case Rot of
    r0:
      Result := r270;
    r90:
      Result := r0;
    r180:
      Result := r90;
    r270:
      Result := r180
  else
    Result := r0;
  end;
end;

constructor T3DTBlockViewer.Create(AOwner: TComponent);
var
  j: Integer;
begin
  inherited;
  for j := 0 to 3 do
  begin
    FCubes[j] := TGLCube(T3DTBlockViewer(self).AddNewChild(TGLCube));
    FCubes[j].CubeWidth := 0.95;
    FCubes[j].CubeHeight := 0.95;
    FCubes[j].CubeDepth := 0.95;
  end;
end;

destructor T3DTBlockViewer.Destroy;
begin
  inherited Destroy;
end;

procedure T3DTBlockViewer.SetBlock(Block: Integer);
var
  j: Integer;
begin
  case Block of
    0: // I
      begin
        FCubes[0].Position.SetPoint(2, 0, 0);
        FCubes[1].Position.SetPoint(1, 0, 0);
        FCubes[2].Position.SetPoint(0, 0, 0);
        FCubes[3].Position.SetPoint(-1, 0, 0);
        for j := 0 to 3 do // Azul-Blue
          FCubes[j].Material.FrontProperties.Diffuse.SetColor(0, 0, 1);
      end;
    1: // L
      begin
        FCubes[0].Position.SetPoint(-1, 0, 0);
        FCubes[1].Position.SetPoint(0, 0, 0);
        FCubes[2].Position.SetPoint(1, 0, 0);
        FCubes[3].Position.SetPoint(1, 1, 0);
        for j := 0 to 3 do // Verde-Green
          FCubes[j].Material.FrontProperties.Diffuse.SetColor(0, 1, 0);
      end;
    2: // L*
      begin
        FCubes[0].Position.SetPoint(-1, 1, 0);
        FCubes[1].Position.SetPoint(-1, 0, 0);
        FCubes[2].Position.SetPoint(0, 0, 0);
        FCubes[3].Position.SetPoint(1, 0, 0);
        for j := 0 to 3 do // Amarelo-Yellow
          FCubes[j].Material.FrontProperties.Diffuse.SetColor(1, 1, 0);
      end;
    3: // S
      begin
        FCubes[0].Position.SetPoint(-1, 0, 0);
        FCubes[1].Position.SetPoint(0, 0, 0);
        FCubes[2].Position.SetPoint(0, 1, 0);
        FCubes[3].Position.SetPoint(1, 1, 0);
        for j := 0 to 3 do // Ciano-Cyan
          FCubes[j].Material.FrontProperties.Diffuse.SetColor(0, 1, 1);
      end;
    4: // S*
      begin
        FCubes[0].Position.SetPoint(-1, 1, 0);
        FCubes[1].Position.SetPoint(0, 1, 0);
        FCubes[2].Position.SetPoint(0, 0, 0);
        FCubes[3].Position.SetPoint(1, 0, 0);
        for j := 0 to 3 do // Roxo-Purple
          FCubes[j].Material.FrontProperties.Diffuse.SetColor(1, 0, 1);
      end;
    5: // T
      begin
        FCubes[0].Position.SetPoint(-1, 0, 0);
        FCubes[1].Position.SetPoint(0, 1, 0);
        FCubes[2].Position.SetPoint(0, 0, 0);
        FCubes[3].Position.SetPoint(1, 0, 0);
        for j := 0 to 3 do // Vermelho-Red
          FCubes[j].Material.FrontProperties.Diffuse.SetColor(1, 0, 0);
      end;
  end;
end;

end.
