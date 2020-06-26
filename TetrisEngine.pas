//To do implementation of Line Destructor for to score  (most of commented lines is for line destructor)


unit TetrisEngine;

interface

uses
  GLScene, GLObjects, GLMisc, Classes, VectorTypes, VectorGeometry;

type
  T3DTInput = (inpNone,inpMoveL,inpMoveR,inpRotateL,inpRotateR);
  T3DTSlideOrLift = (TSlide, TLift, TRSlide, TRLift);
  T3DTRightOrLeft = (TNone, TRight, TLeft);
  T3DTRotation = (r0,r90,r180,r270);


type
  T3DTBlockViewer = class(TGLDummyCube)
private
  Cubes:array [0..3] of TGLCube;
public
  constructor Create(AOwner : TComponent); override;
  destructor Destroy; override;
  procedure SetBlock(Block:Integer);
end;





type
  T3DTBlock = class(TGLDummyCube)
private
  TBlock: Integer;
  TRotation:T3DTRotation;
  TRotate:Boolean;
  TDirection:T3DTRightOrLeft;
  TSlideOrLift:T3DTSlideOrLift;
  TBlockCubes: array [0..3] of TGLCube; 
  TActive: Boolean;
  TSpeed: real;
  TTime:single;
  TGame: Boolean;
  TDoRotation:T3DTRotation;

 // TYTile:Integer;
  //TXTile:Integer;

protected

  procedure SetBlock(Block:Integer);

published

  //O bloco está tivo ou desativo?
  //The block is active or inactive?
  property Active:Boolean read TActive write TActive;

  //Velocidade de queda do bloco
  //Falling block speed
  property Speed: real read TSpeed write TSpeed;

  //Forma do bloco
  //Block shape
  property Block: integer read TBlock write SetBlock;

  //O jogo acabou?
  //The game is over?
  property GameOver: Boolean read TGame;

  //property XTileBlocks: Integer read TXTile write TXTile;
  //property YTileBlocks: Integer read TYTile write TYTile;


public

  constructor Create(AOwner : TComponent); override;
  destructor Destroy; override;
  procedure Move(UserInput:T3DTInput);
  procedure DoProgress(const progressTime : TProgressTimes); override;
  
end;

procedure SetLevel();
function NextRot(Rot: T3DTRotation):T3DTRotation;
function PrevRot(Rot: T3DTRotation):T3DTRotation;

//const          //To do implementation with rows'n lines variables
               //Para implementação com colunas e linhas variáveis
//  MAX_LINES=100;
//  MAX_ROWS=50;

var
  FloodLevels: array[-6..6] of array[-11..10] of Boolean;
//  FloodLevels: array[-MAX_ROWS..MAX_ROWS] of array[-MAX_LINES..MAX_LINES] of Boolean;

implementation

constructor T3DTBlock.Create(AOwner : TComponent);
var
  i:integer;
begin
    inherited;
    TSpeed:=1;
    TActive:=True;
    TTime:=0;
    //ShowAxes:=True;
    TRotation:=r0;
    TDoRotation:=TRotation;

    TGame:=False;
    TRotate:=false;
    TSlideOrLift:=TSlide;
    Position.SetPoint(0,9,0);
    Randomize();

    for i:=0 to 3 do
    begin
      TBlockCubes[i]:=TGLCube(T3DTBlock(self).AddNewChild(TGLCube));
      TBlockCubes[i].CubeWidth:=0.95;
      TBlockCubes[i].CubeHeight:=0.95;
      TBlockCubes[i].CubeDepth:=0.95;
    end;
    SetBlock(0);  
end; 

destructor T3DTBlock.Destroy;
begin
      inherited Destroy;
end;

//define movimentos ao block ativo
procedure T3DTBlock.Move(UserInput:T3DTInput);
begin
//******************************************************************************
  if Active then
  case UserInput of

  inpMoveL:
  begin
    Case TRotation of
       r0:TSlideOrLift:=TSlide;
       r90:TSlideOrLift:=TLift;
       r180:TSlideOrLift:=TRSlide;
       r270:TSlideOrLift:=TRLift;
    end;

    TDirection:=TLeft;

  end;

  inpMoveR:
  begin
     Case TRotation of
       r0:TSlideOrLift:=TSlide;
       r90:TSlideOrLift:=TLift;
       r180:TSlideOrLift:=TRSlide;
       r270:TSlideOrLift:=TRLift;
     end;
     TDirection:=TRight;

  end;

  inpRotateR:
  begin
      TDoRotation:=NextRot(TRotation);
      TRotate:=True;
  end;

  inpRotateL:
  begin
      TDoRotation:=PrevRot(TRotation);
      TRotate:=True;
  end;
  
end;
//******************************************************************************
end; 

procedure T3DTBlock.DoProgress(const progressTime : TProgressTimes);
var
  i,j:integer;
  absPos: TVector;
  FloodRight, FloodLeft: Boolean;
  ValRot:Boolean;
  SimBlock:TGLDummyCube;
  SimCube: array [0..3] of TGLDummyCube;
  //-----------------------
  //VARIABLES FOR LINE DESTRUCTOR
  //k:integer;
  //isline:Boolean;
  //line: array [0..3] of integer;
  //lineind:integer;

begin

inherited;

//******************************************************************************
//Testa se o bloco está ativo
//If the block is active
if Active then
begin


//------------------------------------
//POSIÇÃO-POSITION
//------------------
FloodRight:=False;
FloodLeft:=False;

for i:=0 to 3 do
begin
    setVector(absPos, Children[i].AbsolutePosition);

    if (FloodRight=False) then
    FloodRight:=Floodlevels[round(absPos[0])-1][round(absPos[1])];
    
    if (FloodLeft=False) then
    FloodLeft:=Floodlevels[round(absPos[0])+1][round(absPos[1])]; 
end;

      if (TDirection=TRight) and (FloodRight=False) then
      begin
          Case TSlideOrLift of
            TSlide:T3DTBlock(Self).Slide(1);
            TLift:T3DTBlock(Self).Lift(1);
            TRSlide:T3DTBlock(Self).Slide(-1);
            TRLift:T3DTBlock(Self).Lift(-1);
          end;
          TDirection:=TNone;
      end;                 

      if (TDirection=TLeft) and (FloodLeft=False) then
      begin
          Case TSlideOrLift of
            TSlide:T3DTBlock(Self).Slide(-1);
            TLift:T3DTBlock(Self).Lift(-1);
            TRSlide:T3DTBlock(Self).Slide(1);
            TRLift:T3DTBlock(Self).Lift(1);
          end;
          TDirection:=TNone;
      end;
//------------------------------------     

//------------------------------------
//ROTAÇÃO-ROTATION
//------------------


if TRotate then
begin
SimBlock:=TGLDummyCube(T3DTBlock(self).Parent.AddNewChild(TGLDummyCube));
SimBlock.AbsolutePosition:=T3DTBlock(self).AbsolutePosition;
SimBlock.RollAngle:=T3DTBlock(self).RollAngle;

for i:=0 to 3 do
begin
    SimCube[i]:=TGLDummyCube(SimBlock.AddNewChild(TGLDummyCube));
    //SimCube[i].VisibleAtRunTime:=True; //Uncomment this line for Debug -Descomente esta linha para debug
    SimCube[i].AbsolutePosition:=Children[i].AbsolutePosition;
end;

Case TDoRotation of
       r0:
       begin
         SimBlock.RollAngle:=0;
       end;

       r90:
       begin
          SimBlock.RollAngle:=90;
       end;

       r180:
       begin
          SimBlock.RollAngle:=180;
       end;

       r270:
       begin
          SimBlock.RollAngle:=-90;
       end;
end;

ValRot:=False;
for i:=0 to 3 do
begin
    setVector(absPos, SimCube[i].AbsolutePosition);
    if (ValRot=False) then
      ValRot:=Floodlevels[round(absPos[0])][round(absPos[1])];
end;

SimBlock.Destroy;   //Comment this line for Debug -Comente esta linha para debug

if ValRot=False then //Don't Collide - Não Colide
begin
    Case TDoRotation of
       r0:
       begin
         T3DTBlock(Self).RollAngle:=0;
       end;
       r90:
       begin
          T3DTBlock(Self).RollAngle:=90;
       end;
       r180:
       begin
          T3DTBlock(Self).RollAngle:=180;
       end;
       r270:
       begin
          T3DTBlock(Self).RollAngle:=-90;
       end;       
    end;
TRotation:=TDoRotation;
end;
TRotate:=False;
end;
//------------------------------------ 

//------------------------------------
//COLISÃO COM FLOODLEVEL-COLLISION WITH FLOODLEVEL                   
//------------------
    //Passa por cada cubo que forma o bloco
    //Iterate for each cube that make up the block 
for i:=0 to 3 do
begin
    //Pega a posição absoluta do cubo
    //Get de cube absolute position 
    setVector(absPos, Children[i].AbsolutePosition);

    //Se o bloco da matriz logo abaixo for true
    //If the matrix block botton is true
    if FloodLevels[round(absPos[0])][round(absPos[1])-1] then
    begin
      //O bloco inteiro pára de cair se colidir com floodlevel
      //The whole block stop of falling if collide with floodlevel
      TActive:=False;
    end;

    if TActive=False then
    //Se o cubo colidinte não é o primeiro, devemos verificar todos de novo
    //If the colliding block is not the first, we must check all again
    for j:=0 to 3 do
    begin
      setVector(absPos, Children[j].AbsolutePosition);
      //Ocupa o FloodLevel do cubo
      //Take up the cube floodlevel
      FloodLevels[round(absPos[0])][round(absPos[1])]:=True;
    end;
end;
//-------------------------------------

//-----------------------------------
//QUEDA-FALL
//------------------
//Os blocos caem se estão ativados
//The blocks fall if active
TTime:=TTime+progressTime.deltatime;
if TTime>=TSpeed then
begin
  Position.Y := Position.Y-1;
  TTime:=0;
end;
//------------------------------------

end;
//******************************************************************************
//------------------------------------
//LINE DESTRUCTOR      //Possible fix: use one line storer, dont four
                       //to do the block fall when one line is detructed
//------------------------------------   
{lineind:=0;
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
    end;     }
//------------------------------------ 

//GAMEOVER DEFINER
for i:=-5 to 5 do
if floodlevels[i][9] then
TGame:=True;


end;


procedure T3DTBlock.SetBlock(Block:Integer);
var
  j:integer;
begin

TBlock:=Block;

case Block of
    0:     //I
      begin
         TBlockCubes[0].Position.SetPoint(2,0,0);
         TBlockCubes[1].Position.SetPoint(1,0,0);
         TBlockCubes[2].Position.SetPoint(0,0,0);
         TBlockCubes[3].Position.SetPoint(-1,0,0);
         for j:=0 to 3 do //Azul-Blue
            TGLCube(children[j]).Material.FrontProperties.Diffuse.SetColor(0,0,1);

      end;
    1:     //L
      begin
         TBlockCubes[0].Position.SetPoint(-1,0,0);
         TBlockCubes[1].Position.SetPoint(0,0,0);
         TBlockCubes[2].Position.SetPoint(1,0,0);
         TBlockCubes[3].Position.SetPoint(1,1,0);
          for j:=0 to 3 do //Verde-Green
            TGLCube(children[j]).Material.FrontProperties.Diffuse.SetColor(0,1,0);

      end;
    2:     //L*
      begin
         TBlockCubes[0].Position.SetPoint(-1,1,0);
         TBlockCubes[1].Position.SetPoint(-1,0,0);
         TBlockCubes[2].Position.SetPoint(0,0,0);
         TBlockCubes[3].Position.SetPoint(1,0,0);
         for j:=0 to 3 do //Amarelo-Yellow
            TGLCube(children[j]).Material.FrontProperties.Diffuse.SetColor(1,1,0);

      end;
    3:    //S
      begin
         TBlockCubes[0].Position.SetPoint(-1,0,0);
         TBlockCubes[1].Position.SetPoint(0,0,0);
         TBlockCubes[2].Position.SetPoint(0,1,0);
         TBlockCubes[3].Position.SetPoint(1,1,0);
         for j:=0 to 3 do //Ciano-Cyan
            TGLCube(children[j]).Material.FrontProperties.Diffuse.SetColor(0,1,1);

      end;
    4:    //S*
      begin
         TBlockCubes[0].Position.SetPoint(-1,1,0);
         TBlockCubes[1].Position.SetPoint(0,1,0);
         TBlockCubes[2].Position.SetPoint(0,0,0);
         TBlockCubes[3].Position.SetPoint(1,0,0);
         for j:=0 to 3 do //Roxo-Purple
            TGLCube(children[j]).Material.FrontProperties.Diffuse.SetColor(1,0,1);

      end;
    5:    //T
      begin
         TBlockCubes[0].Position.SetPoint(-1,0,0);
         TBlockCubes[1].Position.SetPoint(0,1,0);
         TBlockCubes[2].Position.SetPoint(0,0,0);
         TBlockCubes[3].Position.SetPoint(1,0,0);
         for j:=0 to 3 do //Vermelho-Red
            TGLCube(children[j]).Material.FrontProperties.Diffuse.SetColor(1,0,0);

      end;
end;      

end; 

procedure SetLevel ();
//procedure SetLevel(XTile:integer;YTile:integer);
var
  i,j:integer;
begin
//TYTile:=(YTile-YTile div 2)
//TYTile:=(XTile-XTile div 2)


  for i:=-5 to 5 do
    for j:=-10 to 10 do
      FloodLevels[i][j]:=false;
  //Floor-Chão
  for i:=-5 to 5 do
      FloodLevels[i][-11]:=true;
  //Walls-Paredes
  for i:=-10 to 10 do
  begin
      FloodLevels[-6][i]:=true;
      FloodLevels[6][i]:=true;
  end;

end;

function NextRot(Rot:T3DTRotation):T3DTRotation;
begin
  Case Rot of
   r0:Result:=r90;
   r90:Result:=r180;
   r180:Result:=r270;
   r270:Result:=r0
  else
  Result:=r0;
  end;

end;

function PrevRot(Rot:T3DTRotation):T3DTRotation;
begin
  Case Rot of
   r0:Result:=r270;
   r90:Result:=r0;
   r180:Result:=r90;
   r270:Result:=r180
  else
  result:=r0;
  end;
end;       

constructor T3DTBlockViewer.Create(AOwner : TComponent);
var
j:integer;
begin
    inherited;

for j:=0 to 3 do
begin
  Cubes[j]:=TGLCube(T3DTBlockViewer(self).AddNewChild(TGLCube));
  Cubes[j].CubeWidth:=0.95;
  Cubes[j].CubeHeight:=0.95;
  Cubes[j].CubeDepth:=0.95;
end;

end;

destructor T3DTBlockViewer.Destroy;
begin
      inherited Destroy;
end;


procedure T3DTBlockViewer.SetBlock(Block:Integer);
var
j:integer;
begin 

case Block of
    0:     //I
      begin
         Cubes[0].Position.SetPoint(2,0,0);
         Cubes[1].Position.SetPoint(1,0,0);
         Cubes[2].Position.SetPoint(0,0,0);
         Cubes[3].Position.SetPoint(-1,0,0);


         for j:=0 to 3 do//Azul-Blue
            Cubes[j].Material.FrontProperties.Diffuse.SetColor(0,0,1);


      end;
    1:     //L
      begin
         Cubes[0].Position.SetPoint(-1,0,0);
         Cubes[1].Position.SetPoint(0,0,0);
         Cubes[2].Position.SetPoint(1,0,0);
         Cubes[3].Position.SetPoint(1,1,0);

         for j:=0 to 3 do //Verde-Green
            Cubes[j].Material.FrontProperties.Diffuse.SetColor(0,1,0);

      end;
    2:     //L*
      begin
         Cubes[0].Position.SetPoint(-1,1,0);
         Cubes[1].Position.SetPoint(-1,0,0);
         Cubes[2].Position.SetPoint(0,0,0);
         Cubes[3].Position.SetPoint(1,0,0);

         for j:=0 to 3 do//Amarelo-Yellow
            Cubes[j].Material.FrontProperties.Diffuse.SetColor(1,1,0);

      end;
    3:    //S
      begin
         Cubes[0].Position.SetPoint(-1,0,0);
         Cubes[1].Position.SetPoint(0,0,0);
         Cubes[2].Position.SetPoint(0,1,0);
         Cubes[3].Position.SetPoint(1,1,0);

         for j:=0 to 3 do //Ciano-Cyan
            Cubes[j].Material.FrontProperties.Diffuse.SetColor(0,1,1);

      end;
    4:    //S*
      begin
         Cubes[0].Position.SetPoint(-1,1,0);
         Cubes[1].Position.SetPoint(0,1,0);
         Cubes[2].Position.SetPoint(0,0,0);
         Cubes[3].Position.SetPoint(1,0,0);

         for j:=0 to 3 do //Roxo-Purple
            Cubes[j].Material.FrontProperties.Diffuse.SetColor(1,0,1);

      end;
    5:    //T
      begin
         Cubes[0].Position.SetPoint(-1,0,0);
         Cubes[1].Position.SetPoint(0,1,0);
         Cubes[2].Position.SetPoint(0,0,0);
         Cubes[3].Position.SetPoint(1,0,0);

         for j:=0 to 3 do //Vermelho-Red
            Cubes[j].Material.FrontProperties.Diffuse.SetColor(1,0,0);
      end;
      
end;
end;

end.
