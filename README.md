# WindowDarkMode
 Dark mode for Window frame (Win only)

Based on https://github.com/chuacw/Delphi-Dark-Mode-demo


## Usage
uses DarkModeApi.FMX; {or DarkModeApi.Vcl}

```Pascal
procedure TFormMain.FormCreate(Sender: TObject);
begin
  {$IFDEF MSWINDOWS}
  SetWindowColorModeAsSystem;
  {$ENDIF}
end;
```