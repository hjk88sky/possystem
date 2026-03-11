param(
  [string]$AliasPath = 'C:\possystem-build',
  [string]$ApiOrigin = 'http://localhost:3000'
)

$ErrorActionPreference = 'Stop'

function Assert-Command {
  param([string]$Name)

  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "Required command not found on PATH: $Name"
  }
}

function Ensure-Junction {
  param(
    [string]$Path,
    [string]$Target
  )

  if (Test-Path $Path) {
    $item = Get-Item $Path -Force
    if ($item.LinkType -ne 'Junction') {
      throw "Alias path already exists and is not a junction: $Path"
    }

    $currentTarget = @($item.Target)[0]
    if ($currentTarget -ne $Target) {
      throw "Alias path points to a different target: $Path -> $currentTarget"
    }

    return
  }

  New-Item -ItemType Junction -Path $Path -Target $Target | Out-Null
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot
$appPath = Join-Path $repoRoot 'apps\pos'

Assert-Command 'flutter'

Ensure-Junction -Path $AliasPath -Target $repoRoot

$aliasAppPath = Join-Path $AliasPath 'apps\pos'

Push-Location $aliasAppPath
try {
  & flutter clean
  if ($LASTEXITCODE -ne 0) {
    throw 'flutter clean failed.'
  }

  & flutter pub get
  if ($LASTEXITCODE -ne 0) {
    throw 'flutter pub get failed.'
  }

  & flutter build windows "--dart-define=POS_API_ORIGIN=$ApiOrigin"
  if ($LASTEXITCODE -ne 0) {
    throw 'flutter build windows failed.'
  }

  $exePath = Join-Path $aliasAppPath 'build\windows\x64\runner\Release\pos.exe'
  if (Test-Path $exePath) {
    Write-Host "Built executable: $exePath"
  } else {
    throw "Build completed but executable was not found: $exePath"
  }
} finally {
  Pop-Location
}
