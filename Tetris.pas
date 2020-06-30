unit Tetris;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GLWin32Viewer, GLCrossPlatform, GLScene, GLObjects,
  GLGraph, GLCadencer,
  // *******************
  TetrisEngine, GLKeyboard, GLTexture, GLSkydome, GLSpaceText, GLScreen,
  GLGameMenu, GLFileTGA, GLBitmapFont, GLWindowsFont, GLColor, GLHUDObjects,
  GLCanvas, GLMaterial,
  GLCoordinates, GLBaseClasses;

type
  TForm1 = class(TForm)
    GLScene1: TGLScene;
    GLSceneViewer1: TGLSceneViewer;
    GLCamera1: TGLCamera;
    PlayField: TGLDummyCube;
    GLLightSource1: TGLLightSource;
    GLXYZGrid1: TGLXYZGrid;
    GLCadencer1: TGLCadencer;
    GLPlane1: TGLPlane;
    GLCube1: TGLCube;
    GLCube2: TGLCube;
    GLMaterialLibrary1: TGLMaterialLibrary;
    GLSkyDome1: TGLSkyDome;
    GLDummyCube1: TGLDummyCube;
    GLSpaceText2: TGLSpaceText;
    GLDummyCube2: TGLDummyCube;
    GLGameMenu1: TGLGameMenu;
    GLWindowsBitmapFont1: TGLWindowsBitmapFont;
    IniGame: TGLGameMenu;
    EndGame: TGLGameMenu;
    GLHUDSprite1: TGLHUDSprite;
    Blocks: TGLDummyCube;
    Pause: TGLGameMenu;
    procedure GLCadencer1Progress(Sender: TObject;
      const deltaTime, newTime: Double);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure GLSceneViewer1MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure GLSceneViewer1Click(Sender: TObject);

    // ***********************************************
    Procedure GameProgress();
    Procedure StartGame();
    Procedure SetUI();
    procedure GLSceneViewer1PostRender(Sender: TObject);
    // ***********************************************
  public
    bloco: T3DTBlock;
    proxbloco: T3DTBlockViewer;
    pontos: Integer;
    velocidade: real;
    GameOn: Boolean;
    mx, my: Integer;
  end;

var
  Form1: TForm1;

  UserInput: T3DTInput;
  nextblock: Integer;

implementation

{$R *.dfm}

procedure TForm1.GLCadencer1Progress(Sender: TObject;
  const deltaTime, newTime: Double);
begin
  // GLSkyDome1.TurnAngle:=newTime*pontos/pi;
  GLSpaceText2.Text := inttostr(pontos);
  // GLCursor.Position.SetPoint(mx,my,0);

  if GameOn then
    if IsKeyDown(VK_ESCAPE) then
    begin
      GameOn := False;
      GLCadencer1.Enabled := False;
      Pause.Visible := True;

      PlayField.Visible := False;
      GLSpaceText2.Visible := False;
      GLHUDSprite1.Visible := False;
      GLDummyCube2.Visible := False;
    end;

  // ***************************************
  // Proximo block
  if GLDummyCube2.PitchAngle <= 360 then
  begin
    GLDummyCube2.TurnAngle := GLDummyCube2.TurnAngle + deltaTime * 20;
    GLDummyCube2.PitchAngle := GLDummyCube2.PitchAngle + deltaTime * 20;
    GLDummyCube2.RollAngle := GLDummyCube2.RollAngle + deltaTime * 20;
  end
  else
  begin
    GLDummyCube2.TurnAngle := 0;
    GLDummyCube2.PitchAngle := 0;
    GLDummyCube2.RollAngle := 0;
  end;
  // ***************************************

  GameProgress;
  GLSceneViewer1.Invalidate;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  UserInput := inpNone;

  if Key = Ord('G') then
    GLXYZGrid1.Visible := not GLXYZGrid1.Visible;
  if Key = VK_UP then
    UserInput := inpRotateL;
  if Key = VK_DOWN then
    UserInput := inpRotateR;
  if Key = VK_LEFT then
    UserInput := inpMoveL;
  if Key = VK_RIGHT then
    UserInput := inpMoveR;
  if bloco <> nil then
    bloco.Move(UserInput);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  resolucao: TResolution;
begin
  velocidade := 0.4;
  GameOn := False;

  // FullScreen
  resolucao := 0;
  SetFullscreenMode(resolucao, 85);
  Form1.BorderStyle := bsNone;
  Form1.Color := clBlack;
  SetBounds(0, 0, Screen.Width, Screen.Height);
  GLSceneViewer1.Align := alcustom;
  GLSceneViewer1.SetBounds(0, 0, Screen.Width, Screen.Height - 1);

  SetUI;
end;

procedure TForm1.GLSceneViewer1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin

  mx := X;
  my := Y;
  if not GLCadencer1.Enabled then
    GLSceneViewer1.Invalidate;

  if GLGameMenu1.Visible then
    GLGameMenu1.MouseMenuSelect(X, Y);

  if IniGame.Visible then
    IniGame.MouseMenuSelect(X, Y);

  if Pause.Visible then
    Pause.MouseMenuSelect(X, Y);

  if EndGame.Visible then
    EndGame.MouseMenuSelect(X, Y);
end;

procedure TForm1.GLSceneViewer1Click(Sender: TObject);
begin
  if GLGameMenu1.Visible then
    case GLGameMenu1.Selected of
      0:
        begin
          GLGameMenu1.Visible := False;
          IniGame.Visible := True;
          IniGame.Items.CommaText := '"New Game", Exit';
          Pause.Items.CommaText := '"Resume", "New Game", Exit';
          EndGame.Items.CommaText := 'Retry, Exit';
        end;

      1:
        begin
          GLGameMenu1.Visible := False;
          IniGame.Visible := True;
          IniGame.Items.CommaText := '"Nuevo Juego", Salir';
          Pause.Items.CommaText := '"Seguir", "Nuevo Juego", Salir';
          EndGame.Items.CommaText := '"Intentar Nuevamente", Salir';
        end;

      2:
        begin
          GLGameMenu1.Visible := False;
          IniGame.Visible := True;
          IniGame.Items.CommaText := '"Novo Jogo", Sair';
          Pause.Items.CommaText := '"Continuar", "Novo Jogo", Sair';
          EndGame.Items.CommaText := '"Tentar Novamente", Sair';
        end;
    end;

  if IniGame.Visible then
    case IniGame.Selected of
      0:
        begin
          IniGame.Visible := False;
          StartGame;
        end;
      1:
        begin
          Close;
        end;
    end;

  if Pause.Visible then
    case Pause.Selected of
      0:
        begin
          Pause.Visible := False;

          PlayField.Visible := True;
          GLSpaceText2.Visible := True;
          GLHUDSprite1.Visible := True;
          GLDummyCube2.Visible := True;

          GameOn := True;
          GLCadencer1.Enabled := True;
        end;
      1:
        begin
          Pause.Visible := False;
          StartGame;
        end;
      2:
        begin
          Close;
        end;
    end;

  if EndGame.Visible then
    case EndGame.Selected of
      0:
        begin
          EndGame.Visible := False;
          StartGame;
        end;
      1:
        begin
          Close;
        end;
    end;
end;

// ******************************************************************************
// ******************************************************************************
// ******************************************************************************
procedure TForm1.SetUI();
begin
  // Prepare UI
  PlayField.Visible := False;
  GLSpaceText2.Visible := False;
  GLHUDSprite1.Visible := False;

  GLSpaceText2.Material.FrontProperties.Diffuse.SetColor(1, 1, 0);
  GLSpaceText2.Material.FrontProperties.Emission.SetColor(0.1, 0.1, 0.1);
  GLSpaceText2.Position.SetPoint(-17, 2, 0);
  GLDummyCube2.Position.SetPoint(-17, -2, 0);

  with GLMaterialLibrary1.AddTextureMaterial('Title', 'Titulo.tga') do
  begin
    Material.BlendingMode := bmTransparency;
    Material.Texture.TextureMode := tmReplace;
    Material.FaceCulling := fcNoCull;
  end;

  with GLMaterialLibrary1.AddTextureMaterial('GameOver', 'GameOver.tga') do
  begin
    Material.BlendingMode := bmTransparency;
    Material.Texture.TextureMode := tmReplace;
    Material.FaceCulling := fcNoCull;
  end;

  GLHUDSprite1.Material.MaterialLibrary := GLMaterialLibrary1;
  GLHUDSprite1.Material.LibMaterialName := 'Title';
  GLHUDSprite1.Position.SetPoint((GLSceneViewer1.Width div 2) +
    (GLSceneViewer1.Width div 4), 150, 0);

  GLGameMenu1.MaterialLibrary := GLMaterialLibrary1;
  GLGameMenu1.Position.SetPoint(GLSceneViewer1.Width div 2,
    GLSceneViewer1.Height div 2, 0);
  GLGameMenu1.ActiveColor.SetColor(1, 1, 0);
  GLGameMenu1.InactiveColor.SetColor(0, 0.4, 1);
  GLGameMenu1.Font := GLWindowsBitmapFont1;
  GLGameMenu1.TitleWidth := 512;
  GLGameMenu1.TitleHeight := 128;
  GLGameMenu1.TitleMaterialName := 'Title';
  GLGameMenu1.Spacing := 4;
  GLGameMenu1.Items.CommaText := 'English,Español,Português';

  IniGame.MaterialLibrary := GLMaterialLibrary1;
  IniGame.Position.SetPoint(GLSceneViewer1.Width div 2,
    GLSceneViewer1.Height div 2, 0);
  IniGame.ActiveColor.SetColor(1, 1, 0);
  IniGame.InactiveColor.SetColor(0, 0.4, 1);
  IniGame.Font := GLWindowsBitmapFont1;
  IniGame.TitleWidth := 512;
  IniGame.TitleHeight := 128;
  IniGame.TitleMaterialName := 'Title';
  IniGame.Spacing := 4;
  IniGame.Visible := False;

  Pause.MaterialLibrary := GLMaterialLibrary1;
  Pause.Position.SetPoint(GLSceneViewer1.Width div 2,
    GLSceneViewer1.Height div 2, 0);
  Pause.ActiveColor.SetColor(1, 1, 0);
  Pause.InactiveColor.SetColor(0, 0.4, 1);
  Pause.Font := GLWindowsBitmapFont1;
  Pause.TitleWidth := 512;
  Pause.TitleHeight := 128;
  Pause.TitleMaterialName := 'Title';
  Pause.Spacing := 4;
  Pause.Visible := False;

  EndGame.MaterialLibrary := GLMaterialLibrary1;
  EndGame.Position.SetPoint(GLSceneViewer1.Width div 2,
    GLSceneViewer1.Height div 2, 0);
  EndGame.ActiveColor.SetColor(1, 1, 0);
  EndGame.InactiveColor.SetColor(0, 0.4, 1);
  EndGame.Font := GLWindowsBitmapFont1;
  EndGame.TitleWidth := 512;
  EndGame.TitleHeight := 128;
  EndGame.TitleMaterialName := 'GameOver';
  EndGame.Spacing := 4;
  EndGame.Visible := False;

  GLSceneViewer1.Cursor := crNone;

  GLSkyDome1.Stars.LoadStarsFile('Yale_BSC.stars');
end;

// ******************************************************************************
// ******************************************************************************
// ******************************************************************************

procedure TForm1.GameProgress();
begin
  // ---------------------------------------
  if bloco <> nil then
    // --------------------------
    if not bloco.GameOver then // Se o jogo n�o acabou
    begin

      if GameOn then // Se o jogo est� rodando
        if not bloco.Active then // Se o �LTIMO bloco bateu no floodlevel
        begin
          pontos := pontos + 50; // soma ponto
          bloco := T3DTBlock(Blocks.AddNewChild(T3DTBlock)); // cria novo bloco
          bloco.Speed := velocidade; // ajusta velocidade do novo bloco
          bloco.Block := nextblock; // define a shape do bloco
          proxbloco.Destroy; // destr�i o visualizador antigo
          proxbloco := T3DTBlockViewer(GLDummyCube2.AddNewChild(T3DTBlockViewer)
            ); // cria um novo visualizador
          nextblock := random(6); // define a shape do bloco seguinte
          proxbloco.SetBlock(nextblock); // visualiza o bloco seguinte
        end;

    end
    else // Se o jogo acabou
    begin

      GLCadencer1.Enabled := False; // Para o cadencer
      GameOn := False; // Para de rodar
      EndGame.Visible := True; // Mostra o menu

    end;
  // ---------------------------------------
end;

// ******************************************************************************
// ******************************************************************************
// ******************************************************************************

procedure TForm1.StartGame();
begin
  SetLevel;
  GameOn := True;

  pontos := 0;

  PlayField.Visible := True;
  GLHUDSprite1.Visible := True;
  GLSpaceText2.Visible := True;
  GLDummyCube2.Visible := True; // ***

  Blocks.DeleteChildren;

  GLCadencer1.Enabled := True; // ***

  bloco := T3DTBlock(Blocks.AddNewChild(T3DTBlock));
  bloco.Speed := velocidade;
  bloco.Block := random(6);

  if proxbloco <> nil then // ***
    proxbloco.Destroy; // ***

  proxbloco := T3DTBlockViewer(GLDummyCube2.AddNewChild(T3DTBlockViewer));

  nextblock := random(6);
  proxbloco.SetBlock(nextblock);

end;

// ******************************************************************************
// ******************************************************************************
// ******************************************************************************

procedure TForm1.GLSceneViewer1PostRender(Sender: TObject);
var
  GLC: TGLCanvas;
begin
  GLC := TGLCanvas.Create(GLSceneViewer1.Buffer.Width,
    GLSceneViewer1.Buffer.Height);

  with GLC do
  begin
    PenColor := $00DD00;

    FillRect(mx, my, mx + 4, my + 4);
    FillRect(mx + 5, my, mx + 9, my + 4);
    FillRect(mx, my + 5, mx + 4, my + 9);

    FillRect(mx + 10, my, mx + 14, my + 4);
    FillRect(mx, my + 10, mx + 4, my + 14);
    FillRect(mx + 5, my + 5, mx + 9, my + 9);
    FillRect(mx + 10, my + 10, mx + 14, my + 14);
    FillRect(mx + 15, my + 15, mx + 19, my + 19);

  end;

  GLC.Free;
end;

end.
