program Tetris3D;

uses
  Forms,
  Tetris in 'Tetris.pas' {Form1},
  TetrisEngine in 'TetrisEngine.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Tetris 3D';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
