unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Generics.Collections, FMX.Layouts, FMX.ListBox, FMX.Memo.Types,
  PythonEngine, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo,
  FMX.StdCtrls,
  FMX.Objects;

type
  TBullet = class
  private
    FCount: integer;
    FSpeedX: Single;
    FSpeedY: Single;
    FTop: Single;
    FLeft: Single;
  public
    property top: Single read FTop write FTop;
    property left: Single read FLeft write FLeft;
    property speedx: Single read FSpeedX write FSpeedX;
    property speedy: Single read FSpeedY write FSpeedY;
    property count: integer read FCount write FCount;
  end;

  TCharObj = class(TBullet)
  private
    FTheta: Single;
    FList: TList<TBullet>;
    FCanvas: TCanvas;
  public
    constructor Create(ACanvas: TCanvas);
    destructor Destroy; override;
    procedure shooting;
    procedure beams;
    property theta: Single read FTheta write FTheta;
  end;

  TForm1 = class(TForm)
    Memo1: TMemo;
    PythonEngine1: TPythonEngine;
    PythonModule1: TPythonModule;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    PaintBox1: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PythonModule1Events0Execute(Sender: TObject;
      PSelf, Args: PPyObject; var Result: PPyObject);
  private
    { private éŒ¾ }
    enemy: TCharObj;
    time: TTime;
    procedure AppOnIdle(Sender: TObject; var Done: Boolean);
  public
    { public éŒ¾ }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.AppOnIdle(Sender: TObject; var Done: Boolean);
const
  fps = 60;
var
  new: TTime;
begin
  Done := false;
  new := Now - time;
  if fps * new * 24 * 3600 > 1 then
  begin
    PaintBox1.Canvas.BeginScene;
//    PaintBox1.Canvas.Clear(TAlphaColors.White);
    if SpeedButton1.IsPressed then
      PythonEngine1.ExecStrings(Memo1.Lines);
    enemy.beams;
    time := time + new;
    PaintBox1.Canvas.EndScene;
  end;
  enemy.count := enemy.count + 1;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  enemy := TCharObj.Create(PaintBox1.Canvas);
  enemy.left := ClientWidth div 2;
  enemy.top := 50;
  time := Now;
  PaintBox1.Canvas.Fill.Color := TAlphaColors.Blue;
  Application.OnIdle := AppOnIdle;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  enemy.Free;
end;

procedure TForm1.PythonModule1Events0Execute(Sender: TObject;
  PSelf, Args: PPyObject; var Result: PPyObject);
begin
  enemy.shooting;
end;

{ TCharObj }

procedure TCharObj.beams;
begin
  top := top + 1;
  FCanvas.FillRect(RectF(left, top, left + 10, top + 10), 1.0);
  for var i := 0 to FList.count - 1 do
    with FList[i] do
    begin
      left := left + speedx;
      top := top + speedy;
      count := count + 1;
      if count > 20 then
        FCanvas.FillEllipse(RectF(left, top, left + 5, top + 5), 1.0);
    end;
end;

constructor TCharObj.Create(ACanvas: TCanvas);
begin
  inherited Create;
  FList := TList<TBullet>.Create;
  FCanvas := ACanvas;
end;

destructor TCharObj.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TCharObj.shooting;
const
  a = 2;
  theta = pi / 18;
begin
  with FList[FList.Add(TBullet.Create)] do
  begin
    left := Self.left;
    top := Self.top;
    speedx := a * cos(Self.theta);
    speedy := a * sin(Self.theta);
  end;
  Self.theta := Self.theta + theta;
end;

end.
