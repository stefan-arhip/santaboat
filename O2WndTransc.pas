{====================================================================}
{   TOxygenWndTranslucency Component, v1.0 © 2000 Oxygen Software    }
{--------------------------------------------------------------------}
{     NB! This component works only under Microsoft Windows 2000     }
{--------------------------------------------------------------------}
{          Written by Oleg Fyodorov, ofyodorov@mtu-net.ru            }
{                    delphi@oxygensoftware.com                       }
{                  http://www.oxygensoftware.com                     }
{====================================================================}

{.$DEFINE O2_SW}

unit O2WndTransc;

  interface

    uses Windows, Classes, SysUtils, Graphics, Forms, Messages, Dialogs, Controls, ShellApi;

    type

      TOxygenWndTranslucency = class(TComponent)
        private
          FOwnerWnd : HWnd;
          FWindowHandle : HWnd;
          FTransparentColor : TColor;
          FOnChangeTransparentColor : TNotifyEvent;
          procedure WndProc(var Msg: TMessage);
          procedure SetTransparentColor(const Value : TColor);
        protected
          procedure DoChangeTransparentColor; virtual;
        public
          constructor Create(AOwner : TComponent); override;
          destructor Destroy; override;
{$IFNDEF O2_SW}
          {$IFNDEF VER100}
          function SetWndTranslucency(const WindowTitle : String; const ATransparentColor : Byte) : Boolean; overload;
          function SetWndTranslucency(const WindowHandle : Integer; const ATransparentColor : Byte) : Boolean; overload;
          function ResetWndTranslucency(const WindowTitle : String) : Boolean; overload;
          function ResetWndTranslucency(const WindowHandle : Integer) : Boolean; overload;
          {$ELSE}
          function SetWndTranslucency(const WindowTitle : String; const ATransparentColor : Byte) : Boolean;
          function SetWndTranslucencyHandle(const WindowHandle : Integer; const ATransparentColor : Byte) : Boolean;
          function ResetWndTranslucency(const WindowTitle : String) : Boolean;
          function ResetWndTranslucencyHandle(const WindowHandle : Integer) : Boolean;
          {$ENDIF}
{$ENDIF}
        published
          property TransparentColor : TColor read FTransparentColor write SetTransparentColor;
          property OnChangeTransparentColor : TNotifyEvent read FOnChangeTransparentColor write FOnChangeTransparentColor;
      end;

    procedure Register;

implementation

  const
      WS_EX_LAYERED = $80000;
      LWA_COLORKEY  = 1;
      LWA_ALPHA     = 2;

  function SetLayeredWindowAttributes(
            hwnd : HWND;         // handle to the layered window
            crKey : TColor;      // specifies the color key
            bAlpha : Byte;       // value for the blend function
            dwFlags : DWORD      // action
            ): BOOL; stdcall; external 'user32.dll';

// TOxygenWndTranslucency
constructor TOxygenWndTranslucency.Create(AOwner : TComponent);
begin
  if not (AOwner is TCustomForm) then raise Exception.Create('This component works only with TCustomForm descendants!');
  inherited Create(AOwner);
  FOnChangeTransparentColor := nil;
  FTransparentColor := clNone;
  FOwnerWnd := (AOwner as TCustomForm).Handle;
  FWindowHandle := AllocateHWnd(WndProc);
{$IFDEF O2_SW}
  if (MessageDlg('This version of TOxygenWndTranslucency is NOT REGISTERED. '+#13#10+
                 'Press Ok to visit http://www.oxygensoftware.com and register.',
                 mtWarning,[mbOk,mbCancel],0) = mrOk) then ShellExecute(0,'open','http://www.oxygensoftware.com',nil,nil,SW_SHOWNORMAL);
{$ENDIF}
end;

destructor TOxygenWndTranslucency.Destroy;
begin
  DeallocateHWnd(FWindowHandle);
  inherited Destroy;
end;

procedure TOxygenWndTranslucency.WndProc(var Msg: TMessage);
begin
  with Msg do
    if Msg = WM_CREATE then
      try
        SetTransparentColor(FTransparentColor);
      except
        Application.HandleException(Self);
      end
    else Result := DefWindowProc(FWindowHandle, Msg, wParam, lParam);
end;

procedure TOxygenWndTranslucency.SetTransparentColor(const Value : TColor);
  var wl : DWord;
begin
  FTransparentColor := Value;
  if (csDesigning in ComponentState) then Exit;
  if (FTransparentColor = clNone) then begin
    wl := (GetWindowLong(FOwnerWnd, GWL_EXSTYLE) and (not WS_EX_LAYERED));
    SetWindowLong(FOwnerWnd, GWL_EXSTYLE, wl);
    Exit;
  end;

  wl := GetWindowLong(FOwnerWnd, GWL_EXSTYLE);
  if ((wl and WS_EX_LAYERED) = 0) then
    if (SetWindowLong(FOwnerWnd, GWL_EXSTYLE, wl or WS_EX_LAYERED) = 0) then Exception.Create(SysErrorMessage(GetLastError));
  if not SetLayeredWindowAttributes(FOwnerWnd, FTransparentColor, 0, LWA_COLORKEY) then Exception.Create(SysErrorMessage(GetLastError));
  DoChangeTransparentColor;
end;

procedure TOxygenWndTranslucency.DoChangeTransparentColor;
begin
  if Assigned(FOnChangeTransparentColor) then FOnChangeTransparentColor(Self);
end;

{$IFNDEF O2_SW}
function TOxygenWndTranslucency.SetWndTranslucency(const WindowTitle : String; const ATransparentColor : Byte) : Boolean;
  var wl : DWord;
      Wnd : HWnd;
begin
  Result := False;
  Wnd := FindWindow(nil,PChar(WindowTitle));
  if (Wnd = 0) then Exit;
  wl := GetWindowLong(Wnd, GWL_EXSTYLE);
  if ((wl and WS_EX_LAYERED) = 0) then if (SetWindowLong(Wnd, GWL_EXSTYLE, wl or WS_EX_LAYERED) = 0) then Exit;
  Result := SetLayeredWindowAttributes(Wnd, ATransparentColor, 0, LWA_COLORKEY);
end;

function TOxygenWndTranslucency.ResetWndTranslucency(const WindowTitle : String) : Boolean;
  var wl : DWord;
      Wnd : HWnd;
begin
  Result := False;
  Wnd := FindWindow(nil,PChar(WindowTitle));
  if (Wnd = 0) then Exit;
  wl := (GetWindowLong(Wnd, GWL_EXSTYLE) and (not WS_EX_LAYERED));
  Result := (SetWindowLong(Wnd, GWL_EXSTYLE, wl) <> 0);
end;

{$IFNDEF VER100}
function TOxygenWndTranslucency.SetWndTranslucency(const WindowHandle : Integer; const ATransparentColor : Byte) : Boolean;
  var wl : DWord;
begin
  Result := False;
  if (WindowHandle = 0) then Exit;
  wl := GetWindowLong(WindowHandle, GWL_EXSTYLE);
  if ((wl and WS_EX_LAYERED) = 0) then if (SetWindowLong(WindowHandle, GWL_EXSTYLE, wl or WS_EX_LAYERED) = 0) then Exit;
  Result := SetLayeredWindowAttributes(WindowHandle, ATransparentColor, 0, LWA_COLORKEY);
end;

function TOxygenWndTranslucency.ResetWndTranslucency(const WindowHandle : Integer) : Boolean;
  var wl : DWord;
begin
  Result := False;
  if (WindowHandle = 0) then Exit;
  wl := (GetWindowLong(WindowHandle, GWL_EXSTYLE) and (not WS_EX_LAYERED));
  Result := (SetWindowLong(WindowHandle, GWL_EXSTYLE, wl) <> 0);
end;

{$ELSE}

function TOxygenWndTranslucency.SetWndTranslucencyHandle(const WindowHandle : Integer; const ATransparentColor : Byte) : Boolean;
  var wl : DWord;
begin
  Result := False;
  if (WindowHandle = 0) then Exit;
  wl := GetWindowLong(WindowHandle, GWL_EXSTYLE);
  if ((wl and WS_EX_LAYERED) = 0) then if (SetWindowLong(WindowHandle, GWL_EXSTYLE, wl or WS_EX_LAYERED) = 0) then Exit;
  Result := SetLayeredWindowAttributes(WindowHandle, ATransparentColor, 0, LWA_COLORKEY);
end;

function TOxygenWndTranslucency.ResetWndTranslucencyHandle(const WindowHandle : Integer) : Boolean;
  var wl : DWord;
begin
  Result := False;
  if (WindowHandle = 0) then Exit;
  wl := (GetWindowLong(WindowHandle, GWL_EXSTYLE) and (not WS_EX_LAYERED));
  Result := (SetWindowLong(WindowHandle, GWL_EXSTYLE, wl) <> 0);
end;

{$ENDIF}
{$ENDIF}

procedure Register;
begin
  RegisterComponents('Oxygen', [TOxygenWndTranslucency]);
end;

end.