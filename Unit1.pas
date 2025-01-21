unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Generics.Collections;

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
  public
    property theta: Single read FTheta write FTheta;
  end;

  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
  private
    { private êÈåæ }
    enemy: TCharObj;
    time: TTime;
    list: TList<TBullet>;
    procedure AppOnIdle(Sender: TObject; var Done: Boolean);
    procedure shooting(enemy: TCharObj);
  public
    { public êÈåæ }
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
    shooting(enemy);
    FormPaint(nil, Canvas, ClientRect);
    time := time + new;
  end;
  enemy.count := enemy.count + 1;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  enemy := TCharObj.Create;
  enemy.left := ClientWidth div 2;
  enemy.top := 50;
  time := Now;
  list := TList<TBullet>.Create;
  Application.OnIdle := AppOnIdle;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  list.Free;
end;

procedure TForm1.FormPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin
  Canvas.BeginScene;
  Canvas.Fill.Color := TAlphaColors.White;
  Canvas.FillRect(ClientRect, 1.0);
  Canvas.Fill.Color := TAlphaColors.Blue;
  for var i := 0 to list.count - 1 do
    with list[i] do
    begin
      left := left + speedx;
      top := top + speedy;
      count := count + 1;
      if count > 20 then
        Canvas.FillEllipse(RectF(left, top, left + 5, top + 5), 1.0);
    end;
  with enemy do
  begin
    top := top + 1;
    Canvas.FillRect(RectF(left, top, left + 10, top + 10), 1.0);
  end;
  Canvas.EndScene;
end;

procedure TForm1.shooting(enemy: TCharObj);
const
  a = 2;
  theta = pi / 18;
begin
  with list[list.Add(TBullet.Create)] do
  begin
    left := enemy.left;
    top := enemy.top;
    speedx := a * cos(enemy.theta);
    speedy := a * sin(enemy.theta);
  end;
  enemy.theta := enemy.theta + theta;
end;

end.
