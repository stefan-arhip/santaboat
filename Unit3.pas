unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TForm3 = class(TForm)
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

Uses Unit2;

Var Status3: Integer= 1;

procedure TForm3.FormCreate(Sender: TObject);
begin
  KeyPreview:=True;

  Form3.Color:= clWhite;

end;

procedure TForm3.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Form2.OnKeyDown(Sender, Key, Shift);
end;

procedure TForm3.Image1Click(Sender: TObject);
begin
  Form2.Image1Click(Sender);
end;

procedure TForm3.Timer1Timer(Sender: TObject);
begin
  Case Status3 Of
    1:
      Image1.Visible:= True;
    2:
      Image2.Visible:= True;
    3:
      Image3.Visible:= True;
    Else
      Begin
        Timer1.Enabled:= False;
        Status2:= 1;
        SecondsToClose:= 10;
        Form2.Timer1.Interval:= 1000;
        Form2.Timer1.Enabled:= True;
        Form2.Label1.Visible:= True;
      End;
  End;
  Inc(Status3);
end;

end.
