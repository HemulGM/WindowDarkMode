unit DarkModeApi;

{$IFDEF MSWINDOWS}

{$WARN SYMBOL_PLATFORM OFF}

interface

// See also https://github.com/adzm/win32-custom-menubar-aero-theme

uses
  Winapi.Windows, DarkModeApi.Types;

function DwmSetWindowAttribute(hwnd: HWND; dwAttribute: DWORD; pvAttribute: Pointer; cbAttribute: DWORD): HResult; stdcall; overload;

function DwmSetWindowAttribute(hwnd: HWND; dwAttribute: TDwmWindowAttribute; var pvAttribute; cbAttribute: DWORD): HResult; stdcall; overload;

function DwmSetWindowAttribute(hwnd: HWND; dwAttribute: TDwmWindowAttribute; var pvAttribute: TDWMWindowCornerPreference; cbAttribute: DWORD): HResult; stdcall; overload;

/// <summary>
/// Enables dark context menus which change automatically depending on the theme.
/// </summary>
procedure AllowDarkModeForApp(allow: BOOL); stdcall;

function AllowDarkModeForWindow(hWnd: HWND; allow: Boolean): Boolean; stdcall;

// See https://en.wikipedia.org/wiki/Windows_10_version_history
function CheckBuildNumber(buildNumber: DWORD): Boolean;

function IsWindows10OrGreater(buildNumber: DWORD = 10000): Boolean;

function IsWindows11OrGreater(buildNumber: DWORD = 22000): Boolean;

function IsDarkModeAllowedForWindow(hWnd: HWND): BOOL; stdcall;

procedure RefreshImmersiveColorPolicyState; stdcall;

procedure RefreshTitleBarThemeColor(hWnd: HWND);

function ShouldAppsUseDarkMode: BOOL; stdcall;

function ShouldSystemUseDarkMode: BOOL; stdcall;

function ImmersiveDarkMode: TDwmWindowAttribute;

/// <summary>
/// Checks the system registry to see if Dark mode is enabled
/// </summary>
function IsDarkMode: Boolean;

const
  LOAD_LIBRARY_SEARCH_SYSTEM32 = $00000800;

implementation

uses
  System.Classes,  System.SysUtils, DarkModeApi.Consts, System.Win.Registry;

var
  _AllowDarkModeForApp: TAllowDarkModeForApp = nil;
  _AllowDarkModeForWindow: TAllowDarkModeForWindow = nil;
  _GetIsImmersiveColorUsingHighContrast: TGetIsImmersiveColorUsingHighContrast = nil;
  _IsDarkModeAllowedForWindow: TIsDarkModeAllowedForWindow = nil;
  _OpenNcThemeData: TOpenNcThemeData = nil;
  _RefreshImmersiveColorPolicyState: TRefreshImmersiveColorPolicyState = nil;
  _SetPreferredAppMode: TSetPreferredAppMode = nil;
  _SetWindowCompositionAttribute: TSetWindowCompositionAttribute = nil;
  _ShouldAppsUseDarkMode: TShouldAppsUseDarkMode = nil;
  _ShouldSystemUseDarkMode: TShouldSystemUseDarkMode = nil;
  GDarkModeSupported: BOOL = False; // changed type to BOOL
  GDarkModeEnabled: BOOL = False;
  GUxTheme: HMODULE = 0;

function DwmSetWindowAttribute(hwnd: hwnd; dwAttribute: DWORD; pvAttribute: Pointer; cbAttribute: DWORD): HResult; stdcall; overload; external Dwmapi name 'DwmSetWindowAttribute' delayed;

function DwmSetWindowAttribute(hwnd: hwnd; dwAttribute: TDwmWindowAttribute; var pvAttribute: TDWMWindowCornerPreference; cbAttribute: DWORD): HResult; stdcall; overload; external Dwmapi name 'DwmSetWindowAttribute' delayed;

procedure AllowDarkModeForApp(allow: BOOL);
begin
  if Assigned(_AllowDarkModeForApp) then
    _AllowDarkModeForApp(allow)
  else if Assigned(_SetPreferredAppMode) then
  begin
    if allow then
      _SetPreferredAppMode(TPreferredAppMode.AllowDarkMode)
    else
      _SetPreferredAppMode(TPreferredAppMode.DefaultMode);
  end;
end;

function DwmSetWindowAttribute(hwnd: hwnd; dwAttribute: TDwmWindowAttribute; var pvAttribute; cbAttribute: DWORD): HResult;
begin
  Result := DwmSetWindowAttribute(hwnd, Ord(dwAttribute), @pvAttribute, cbAttribute);
end;

function IsDarkModeAllowedForWindow(hWnd: hWnd): BOOL;
begin
  Result := Assigned(_IsDarkModeAllowedForWindow) and _IsDarkModeAllowedForWindow(hWnd);
end;

function GetIsImmersiveColorUsingHighContrast(mode: TImmersiveHCCacheMode): BOOL;
begin
  Result := Assigned(_GetIsImmersiveColorUsingHighContrast) and _GetIsImmersiveColorUsingHighContrast(mode);
end;

function ImmersiveDarkMode: TDwmWindowAttribute;
begin
  if IsWindows10OrGreater(18985) then
    Result := DWMWA_USE_IMMERSIVE_DARK_MODE
  else
    Result := DWMWA_USE_IMMERSIVE_DARK_MODE_BEFORE_20H1;
end;

procedure RefreshImmersiveColorPolicyState;
begin
  if Assigned(_RefreshImmersiveColorPolicyState) then
    _RefreshImmersiveColorPolicyState;
end;

function IsDarkMode: Boolean;
var
  LRegistry: TRegistry;
begin
  LRegistry := TRegistry.Create;
  try
    LRegistry.RootKey := HKEY_CURRENT_USER;
    LRegistry.OpenKeyReadOnly('\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize');
    Result := not LRegistry.ReadBool('AppsUseLightTheme');
  finally
    LRegistry.Free;
  end;
end;

function ShouldSystemUseDarkMode: BOOL;
begin
  Result := Assigned(_ShouldSystemUseDarkMode) and _ShouldSystemUseDarkMode;
end;
function CheckBuildNumber(buildNumber: DWORD): Boolean;
begin
  Result :=
    IsWindows10OrGreater(20348) or
    IsWindows10OrGreater(19045) or  //
    IsWindows10OrGreater(19044) or  //
    IsWindows10OrGreater(19043) or  //
    IsWindows10OrGreater(19042) or  //
    IsWindows10OrGreater(19041) or  // 2004
    IsWindows10OrGreater(18363) or  // 1909
    IsWindows10OrGreater(18362) or  // 1903
    IsWindows10OrGreater(17763);    // 1809
end;

function IsWindows10OrGreater(buildNumber: DWORD): Boolean;
begin
  Result := (TOSVersion.Major > 10) or ((TOSVersion.Major = 10) and (TOSVersion.Minor = 0) and (DWORD(TOSVersion.Build) >= buildNumber));
end;

function IsWindows11OrGreater(buildNumber: DWORD): Boolean;
begin
  Result := IsWindows10OrGreater(22000) or IsWindows10OrGreater(buildNumber);
end;

function AllowDarkModeForWindow(hWnd: hWnd; allow: Boolean): Boolean;
begin
  Result := GDarkModeSupported and _AllowDarkModeForWindow(hWnd, allow);
end;

function IsHighContrast: Boolean;
var
  highContrast: HIGHCONTRASTW;
begin
  highContrast.cbSize := SizeOf(highContrast);
  if SystemParametersInfo(SPI_GETHIGHCONTRAST, SizeOf(highContrast), @highContrast, Ord(False)) then
    Result := highContrast.dwFlags and HCF_HIGHCONTRASTON <> 0
  else
    Result := False;
end;

procedure RefreshTitleBarThemeColor(hWnd: hWnd);
var
  LUseDark: BOOL;
  LData: TWindowCompositionAttribData;
begin
  LUseDark := _IsDarkModeAllowedForWindow(hWnd) and _ShouldAppsUseDarkMode and not IsHighContrast;
  if TOSVersion.Build < 18362 then
    SetProp(hWnd, 'UseImmersiveDarkModeColors', THandle(LUseDark))
  else if Assigned(_SetWindowCompositionAttribute) then
  begin
    LData.Attrib := WCA_USEDARKMODECOLORS;
    LData.pvData := @LUseDark;
    LData.cbData := SizeOf(LUseDark);
    _SetWindowCompositionAttribute(hWnd, @LData);
  end;
end;

function ShouldAppsUseDarkMode: BOOL;
begin
  Result := Assigned(_ShouldAppsUseDarkMode) and _ShouldAppsUseDarkMode;
end;

procedure InitDarkMode;
begin
  if ((TOSVersion.Major = 10) and (TOSVersion.Minor = 0) and CheckBuildNumber(TOSVersion.Build)) then
  begin
    GUxTheme := LoadLibraryEx('uxtheme.dll', 0, LOAD_LIBRARY_SEARCH_SYSTEM32);
    if GUxTheme <> 0 then
    begin
      @_AllowDarkModeForWindow := GetProcAddress(GUxTheme, MAKEINTRESOURCEA(133));
      @_GetIsImmersiveColorUsingHighContrast := GetProcAddress(GUxTheme, MAKEINTRESOURCEA(106));
      @_IsDarkModeAllowedForWindow := GetProcAddress(GUxTheme, MAKEINTRESOURCEA(137));
      @_RefreshImmersiveColorPolicyState := GetProcAddress(GUxTheme, MAKEINTRESOURCEA(104));
      @_SetWindowCompositionAttribute := GetProcAddress(GetModuleHandle(user32), 'SetWindowCompositionAttribute');
      @_ShouldAppsUseDarkMode := GetProcAddress(GUxTheme, MAKEINTRESOURCEA(132));

      var P := GetProcAddress(GUxTheme, MAKEINTRESOURCEA(135));
      if TOSVersion.Build < 18362 then
        @_AllowDarkModeForApp := P
      else
        @_SetPreferredAppMode := P;

      if Assigned(_RefreshImmersiveColorPolicyState) and
        Assigned(_ShouldAppsUseDarkMode) and Assigned(_AllowDarkModeForWindow) and
        (Assigned(_AllowDarkModeForApp) or Assigned(_SetPreferredAppMode)) and
        Assigned(_IsDarkModeAllowedForWindow) then
      begin
        GDarkModeSupported := True;
        AllowDarkModeForApp(True);
        _RefreshImmersiveColorPolicyState;
        GDarkModeEnabled := ShouldAppsUseDarkMode and not IsHighContrast;
      end;
    end;
  end;
end;

procedure DoneDarkMode;
begin
  if GUxTheme <> 0 then
    FreeLibrary(GUxTheme);
end;

initialization
  InitDarkMode;

finalization
  DoneDarkMode;

{$ELSE}

interface

implementation

{$ENDIF}

end.

