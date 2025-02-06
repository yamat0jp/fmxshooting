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
    procedure SetCount(const Value: integer);
  public
    property top: Single read FTop write FTop;
    property left: Single read FLeft write FLeft;
    property speedx: Single read FSpeedX write FSpeedX;
    property speedy: Single read FSpeedY write FSpeedY;
    property count: integer read FCount write SetCount;
  end;

  TCharObj = class(TBullet)
  private
    FTheta: Single;
    FState: integer;
    procedure SetState(const Value: integer);
    procedure SetCount(const Value: integer);
  protected
    FList: TList<TBullet>;
    FCanvas: TCanvas;
    procedure shooting;
    procedure beams;
  public
    constructor Create(ACanvas: TCanvas);
    destructor Destroy; override;
    procedure Execute;
    property theta: Single read FTheta write FTheta;
    property state: integer read FState write SetState;
    property count: integer read FCount write SetCount;
  end;

  TForm1 = class(TForm)
    Memo1: TMemo;
    PythonEngine1: TPythonEngine;
    PythonModule1: TPythonModule;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    PaintBox1: TPaintBox;
    ListBox1: TListBox;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PythonModule1Events0Execute(Sender: TObject;
      PSelf, Args: PPyObject; var Result: PPyObject);
    procedure PythonModule1Events2Execute(Sender: TObject;
      PSelf, Args: PPyObject; var Result: PPyObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure PythonModule1Events1Execute(Sender: TObject;
      PSelf, Args: PPyObject; var Result: PPyObject);
    procedure ListBox1Change(Sender: TObject);
    procedure PythonModule1Events3Execute(Sender: TObject;
      PSelf, Args: PPyObject; var Result: PPyObject);
    procedure PythonModule1Events4Execute(Sender: TObject;
      PSelf, Args: PPyObject; var Result: PPyObject);
  private
    { private éŒ¾ }
    enemy: TCharObj;
    time: TTime;
    procedure AppOnIdle(Sender: TObject; var Done: Boolean);
    procedure touroku;
  public
    { public éŒ¾ }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses Math;

const
  stop = 0;
  start = 1;
  shooting = 2;

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
    PaintBox1.Canvas.Clear(TAlphaColors.White);
    enemy.Execute;
    PaintBox1.Canvas.EndScene;
    Panel1.Repaint;
    time := time + new;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  enemy := TCharObj.Create(PaintBox1.Canvas);
  enemy.left := ClientWidth div 2;
  enemy.top := 50;
  time := Now;
  PaintBox1.Canvas.Fill.Color := TAlphaColors.Blue;
  touroku;
  Application.OnIdle := AppOnIdle;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  enemy.Free;
end;

procedure TForm1.ListBox1Change(Sender: TObject);
begin
  with PythonModule1.Events do
    for var i := 0 to count - 1 do
      if Items[i].Name = ListBox1.Items[ListBox1.ItemIndex] then
        Label1.Text := Items[i].DocString.Text;
end;

procedure TForm1.PythonModule1Events0Execute(Sender: TObject;
  PSelf, Args: PPyObject; var Result: PPyObject);
begin
  enemy.state := 1;
end;

procedure TForm1.PythonModule1Events1Execute(Sender: TObject;
  PSelf, Args: PPyObject; var Result: PPyObject);
begin
  enemy.state := 0;
end;

procedure TForm1.PythonModule1Events2Execute(Sender: TObject;
  PSelf, Args: PPyObject; var Result: PPyObject);
var
  i: integer;
  a, b, t: Single;
begin
  if PythonEngine1.PyArg_ParseTuple(Args, 'i', @i) > 0 then
  begin
    a := enemy.speedx;
    b := enemy.speedy;
    t := DegToRad(i);
    enemy.speedx := cos(t) * a - sin(t) * b;
    enemy.speedy := sin(t) * a + cos(t) * b;
  end;
end;

procedure TForm1.PythonModule1Events3Execute(Sender: TObject;
  PSelf, Args: PPyObject; var Result: PPyObject);
begin
  enemy.left := PaintBox1.Canvas.Width div 2;
  enemy.top := 50;
end;

procedure TForm1.PythonModule1Events4Execute(Sender: TObject;
  PSelf, Args: PPyObject; var Result: PPyObject);
begin
  enemy.state := 2;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  PythonEngine1.ExecStrings(Memo1.Lines);
end;

procedure TForm1.touroku;
begin
  for var i := 0 to PythonModule1.Events.count - 1 do
    ListBox1.Items.Add(PythonModule1.Events.Items[i].Name);
end;

{ TCharObj }

procedure TCharObj.beams;
begin
  if state = 1 then
  begin
    left := left + speedx;
    top := top + speedy;
  end;
  FCanvas.FillRect(RectF(left, top, left + 10, top + 10), 1.0);
  for var i := FList.count - 1 downto 0 do
    with FList[i] do
    begin
      try
        left := left + speedx;
        top := top + speedy;
        if count > 20 then
          FCanvas.FillEllipse(RectF(left, top, left + 5, top + 5), 1.0);
        count := count + 1;
      except
        on Exception do
        begin
          Free;
          FList.Delete(i);
        end;
      end;
    end;
end;

constructor TCharObj.Create(ACanvas: TCanvas);
begin
  inherited Create;
  FList := TList<TBullet>.Create;
  FCanvas := ACanvas;
  speedy := 1;
end;

destructor TCharObj.Destroy;
begin
  for var i := 0 to FList.count - 1 do
    FList[i].Free;
  FList.Free;
  inherited;
end;

procedure TCharObj.Execute;
begin
  if (left < 0) or (FCanvas.Width < left) or (top < 0) or (FCanvas.Height < top)
  then
    state := 1;
  if state > 0 then
    shooting;
  beams;
  count := count + 1;
end;

procedure TCharObj.SetCount(const Value: integer);
begin
  if FCount > 1000 then
    FCount := 0
  else
    FCount := Value;
end;

procedure TCharObj.SetState(const Value: integer);
begin
  if Value <> FState then
  begin
    FState := Value;
    FCount := 0;
  end;
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
    if state = 1 then
    begin
      speedx := speedx + Self.speedx;
      speedy := speedy + Self.speedy;
    end;
  end;
  Self.theta := Self.theta + theta;
end;

{ TBullet }

procedure TBullet.SetCount(const Value: integer);
begin
  if FCount < 150 then
    FCount := Value
  else
    raise Exception.Create('time to Free');
end;

end.
