unit DarkModeApi.Consts;

interface

{$IFDEF MSWINDOWS}

uses
  System.UITypes;

const
  BackColor: TColor = $1E1E1E;
  TextColor: TColor = $F0F0F0;
  InputBackColor: TColor = $303030;
  Dwmapi = 'dwmapi.dll';
  CDarkModeExplorer = 'DarkMode_Explorer';
  CModeExplorer = 'Explorer';
  CDarkModeControlCFD = 'DarkMode_CFD';
  DWM_CLOAKED_APP = $0000001;
  DWM_CLOAKED_SHELL = $0000002;
  DWM_CLOAKED_INHERITED = $0000004;
  ODS_NOACCEL = $0100;
  WM_UAHDESTROYWINDOW = $0090;	// handled by DefWindowProc
  WM_UAHDRAWMENU = $0091;	// lParam is UAHMENU
  WM_UAHDRAWMENUITEM = $0092;	// lParam is UAHDRAWMENUITEM
  WM_UAHINITMENU = $0093;	// handled by DefWindowProc
  WM_UAHMEASUREMENUITEM = $0094;	// lParam is UAHMEASUREMENUITEM
  WM_UAHNCPAINTMENUPOPUP = $0095;	// handled by DefWindowProc
  WM_UAHUPDATE = $0096;

{$ENDIF}

implementation

end.

