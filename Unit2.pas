unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, jpeg;

type
  TForm2 = class(TForm)
    Image1: TImage;
    Timer1: TTimer;
    Label1: TLabel;
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;

Var Form2: TForm2;
    Status2: Integer= 0;
    SecondsToClose: Integer= 10;

implementation

uses Unit1, Unit3;

{$R *.dfm}

Var StartPosX, EndPosX, StartPosY, EndPosY: Integer;
    Pas: Integer= 25;

procedure TForm2.FormCreate(Sender: TObject);
Begin
  KeyPreview:=True;

  Form2.Color:= clWhite;
  Image1.Transparent:= False;

  Form2.Width:= 500;  //300;
  Form2.Height:= 500; //300

  StartPosX:= 2 * Screen.Width Div 3;
  EndPosX:= (Screen.Width- 500) Div 2;
  StartPosY:= Screen.Height- Form1.Height Div 2- Form2.Height Div 2;
  EndPosY:= Screen.Height- Form1.Height Div 2- Form2.Height;

  Form2.Left:= StartPosX;
  Form2.Top:= StartPosY; //Screen.Height- Form2.Height- Form1.Height Div 2
End;

procedure TForm2.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  If Key= VK_Escape Then
    Image1Click(Sender);
end;

procedure TForm2.Image1Click(Sender: TObject);
begin
  Pas:= 100;
  Status2:= 2;
  Timer1.Interval:= 40;
  Timer1.Enabled:= True;
end;

procedure TForm2.Image1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
//  ReleaseCapture;
//  SendMessage(Form1.Handle, WM_SYSCOMMAND, 61458, 0);
//  Form2.Top:= Screen.Height- Form2.Height;
//  Timer1.Enabled:= True;
end;

procedure TForm2.Timer1Timer(Sender: TObject);
begin
  Case Status2 Of
    0:
      If Form2.Left> EndPosX Then
        Begin
          Form2.Left:= Form2.Left- Pas;
          Form2.Top:= Form2.Top- Round((StartPosY- EndPosY)/(StartPosX- EndPosX)* Pas);
        End
      Else
        Begin
          Timer1.Enabled:= False;
          Form3.Image1.Visible:= False;
          Form3.Image2.Visible:= False;
          Form3.Image3.Visible:= False;
          Form3.Left:= Form2.Left+ 2* Form2.Width Div 3+ 90;
          Form3.Top:= Form2.Top- Form3.Height+ 70;
          Form3.Show;
          Form3.Timer1.Enabled:= True;
        End;
    1:
      Begin
        Dec(SecondsToClose);
        If SecondsToClose> 0 Then
          Label1.Caption:= Format('%d', [SecondsToClose])
        Else
          Image1Click(Sender);
      End;
    2:
      Begin
        Form3.Close;
        If Form2.Left> -Form2.Width Then
          Form2.Left:= Form2.Left- Pas
        Else
          Application.Terminate;
      End;
  End;
end;

end.
