unit DarkModeApi.FMX;

{$IFDEF MSWINDOWS}
interface

uses
  FMX.Forms, FMX.Types;

type
  TFormHelper = class helper for TForm
    procedure SetWindowColorModeAsSystem;
    procedure SetWindowColorMode(IsDark: Boolean);
    class function SystemIsDarkMode: Boolean;
  end;

  procedure SetWindowColorModeAsSystemFor(Handle: TWindowHandle);

  procedure SetWindowColorModeFor(Handle: TWindowHandle; IsDark: Boolean);

implementation

uses
  DarkModeApi, FMX.Platform.Win, Winapi.Windows;

procedure SetWindowColorModeAsSystemFor(Handle: TWindowHandle);
var
  Value: LongBool;
  WinHandle: HWND;
begin
  Value := IsDarkMode;
  WinHandle := FmxHandleToHWND(Handle);
  DwmSetWindowAttribute(WinHandle, ImmersiveDarkMode, Value, SizeOf(Value));
  AllowDarkModeForWindow(WinHandle, Value);
  AllowDarkModeForApp(Value);
end;

procedure SetWindowColorModeFor(Handle: TWindowHandle; IsDark: Boolean);
var
  Value: LongBool;
  WinHandle: HWND;
begin
  Value := IsDark;
  WinHandle := FmxHandleToHWND(Handle);
  DwmSetWindowAttribute(WinHandle, ImmersiveDarkMode, Value, SizeOf(Value));
  AllowDarkModeForWindow(WinHandle, Value);
  AllowDarkModeForApp(Value);
end;

{ TFormHelper }

procedure TFormHelper.SetWindowColorMode(IsDark: Boolean);
begin
  try
    SetWindowColorModeFor(handle, IsDark);
  except
    //
  end;
end;

procedure TFormHelper.SetWindowColorModeAsSystem;
begin
  try
    SetWindowColorModeAsSystemFor(Handle);
  except
    //
  end;
end;

class function TFormHelper.SystemIsDarkMode: Boolean;
begin
  try
    Result := IsDarkMode;
  except
    Result := False;
  end;
end;

{$ELSE}

interface

implementation

{$ENDIF}

end.

