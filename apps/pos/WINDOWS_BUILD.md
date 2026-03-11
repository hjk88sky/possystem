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

What the script does:

- Creates a stable ASCII junction at `C:\possystem-build`
- Runs `flutter clean`
- Runs `flutter pub get`
- Runs `flutter build windows`

Output:

- `apps\pos\build\windows\x64\runner\Release\pos.exe`
