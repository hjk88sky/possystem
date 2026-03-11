# Windows Build

Use this when the repo lives under a non-ASCII path such as `OneDrive\Desktop` with Korean folder names.

## Prerequisites

- Flutter SDK on `PATH`
- Visual Studio 2022 with Desktop C++ support
- Windows Developer Mode enabled

## Build

Run from the repository root:

```powershell
.\scripts\build-windows.ps1
```

To target a different API server:

```powershell
.\scripts\build-windows.ps1 -ApiOrigin http://192.168.0.10:3000
```

What the script does:

- Creates a stable ASCII junction at `C:\possystem-build`
- Runs `flutter clean`
- Runs `flutter pub get`
- Runs `flutter build windows --dart-define=POS_API_ORIGIN=...`

Output:

- `apps\pos\build\windows\x64\runner\Release\pos.exe`
