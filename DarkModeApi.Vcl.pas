unit DarkModeApi.Vcl;

interface

uses
  Vcl.Forms;

type
  TFormHelper = class helper for TForm
    procedure SetWindowColorModeAsSystem;
    procedure SetWindowColorMode(IsDark: Boolean);
    class function SystemIsDarkMode: Boolean;
  end;

  procedure SetWindowColorModeAsSystemFor(Handle: THandle);

  procedure SetWindowColorModeFor(Handle: THandle; IsDark: Boolean);

implementation

uses
  DarkModeApi, FMX.Platform.Win, Winapi.Windows;

procedure SetWindowColorModeAsSystemFor(Handle: THandle);
var
  Value: LongBool;
begin
  Value := IsDarkMode;
  DwmSetWindowAttribute(Handle, ImmersiveDarkMode, Value, SizeOf(Value));
  AllowDarkModeForWindow(Handle, Value);
  AllowDarkModeForApp(Value);
end;

procedure SetWindowColorModeFor(Handle: THandle; IsDark: Boolean);
var
  Value: LongBool;
begin
  Value := IsDark;
  DwmSetWindowAttribute(Handle, ImmersiveDarkMode, Value, SizeOf(Value));
  AllowDarkModeForWindow(Handle, Value);
  AllowDarkModeForApp(Value);
end;

{ TFormHelper }

procedure TFormHelper.SetWindowColorMode(IsDark: Boolean);
begin
  SetWindowColorModeFor(handle, IsDark);
end;

procedure TFormHelper.SetWindowColorModeAsSystem;
begin
  SetWindowColorModeAsSystemFor(Handle);
end;

class function TFormHelper.SystemIsDarkMode: Boolean;
begin
  Result := IsDarkMode;
end;

end.

