#ifndef APPVERSION
  ; Try to read version from the built exe, fallback to 1.0.0
  #define APPVERSION GetStringFileInfo(AddBackslash(SourcePath) + "Release\NexxPharma.exe", "ProductVersion")
  #if APPVERSION == ""
    #define APPVERSION "1.0.0"
  #endif
#endif

[Setup]
AppName=NexxPharma
AppVersion={#APPVERSION}
AppPublisher=NexxServe
AppCopyright=Copyright 2026 NexxServe
DefaultDirName={autopf}\NexxPharma
DefaultGroupName=NexxPharma
OutputDir=output
OutputBaseFilename=NexxPharmaSetup-{#APPVERSION}
Compression=lzma
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64
SetupIconFile=..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\app_icon.ico
WizardStyle=modern
ShowLanguageDialog=no

[Files]
; Copy everything from inner build Release folder
Source: "Release\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion
; Copy app icon
Source: "..\windows\runner\resources\app_icon.ico"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\NexxPharma"; Filename: "{app}\NexxPharma.exe"; IconFileName: "{app}\app_icon.ico"; IconIndex: 0
Name: "{commondesktop}\NexxPharma"; Filename: "{app}\NexxPharma.exe"; IconFileName: "{app}\app_icon.ico"; IconIndex: 0
Name: "{group}\Uninstall NexxPharma"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\NexxPharma.exe"; Description: "Launch NexxPharma"; Flags: nowait postinstall skipifsilent

[Uninstall]
Type: filesandordirs; Name: "{app}"