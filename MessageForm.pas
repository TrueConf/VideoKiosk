unit MessageForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

const
  A_ALPHA_STEP = 20;
  A_TIMER_INTERVAL = 30;
  MAX_ALPHA = 210;

type
  TfrmMessage = class(TForm)
    timerShow: TTimer;
    timerHide: TTimer;
    lblMessage: TLabel;
    timerLife: TTimer;
    procedure timerShowTimer(Sender: TObject);
    procedure timerHideTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure timerLifeTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SoftShow(AMessage: string; const AIntervalSec: integer);
    procedure SoftHide;
  end;

implementation

{$R *.dfm}

{ TfrmMessage }

procedure TfrmMessage.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmMessage.FormCreate(Sender: TObject);
begin
  timerShow.Enabled := False;
  timerHide.Enabled := False;
  timerShow.Interval := A_TIMER_INTERVAL;
  timerHide.Interval := A_TIMER_INTERVAL;
end;

procedure TfrmMessage.SoftHide;
begin
  timerShow.Enabled := False;
  timerHide.Enabled := False;

  if not Visible then
    Exit;

  AlphaBlendValue := MAX_ALPHA;

  timerHide.Enabled := True;
end;

procedure TfrmMessage.SoftShow(AMessage: string; const AIntervalSec: integer);
begin
  lblMessage.Caption := AMessage;
  // будет золотое сечение
  Width := Round(Screen.Width / 1.618);

  timerShow.Enabled := False;
  timerHide.Enabled := False;

  if Visible then
    Exit;

  AlphaBlendValue := 50;
  Show;

  timerShow.Enabled := True;

  // Life time
  timerLife.Enabled := False;
  timerLife.Interval := AIntervalSec * 1000;
  timerLife.Enabled := True;
end;

procedure TfrmMessage.timerHideTimer(Sender: TObject);
var alpha: integer;
begin
  alpha := AlphaBlendValue - A_ALPHA_STEP;

  if alpha <= 50 then
  begin
    alpha := 50;
    timerHide.Enabled := False;
    Close;
  end;
  AlphaBlendValue := alpha;
end;

procedure TfrmMessage.timerLifeTimer(Sender: TObject);
begin
  SoftHide;
end;

procedure TfrmMessage.timerShowTimer(Sender: TObject);
var alpha: integer;
begin
  alpha := AlphaBlendValue + A_ALPHA_STEP;

  if alpha >= MAX_ALPHA then
  begin
    alpha := MAX_ALPHA;
    timerShow.Enabled := False;
  end;
  AlphaBlendValue := alpha;
end;

end.
