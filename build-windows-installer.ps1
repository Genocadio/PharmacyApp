# Build Windows release and create Inno Setup installer

param(
    [Parameter(Mandatory=$false)]
    [string]$AppVersion,

    [Parameter(Mandatory=$false)]
    [string]$IsccPath = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
)

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

function Get-AppVersionFromPubspec {
    $versionLine = Select-String -Path "pubspec.yaml" -Pattern "^version:\s*(.+)$" | ForEach-Object { $_.Matches[0].Groups[1].Value }
    if (-not $versionLine) {
        return $null
    }
    return $versionLine.Trim()
}

try {
    if (-not $AppVersion) {
        $AppVersion = Get-AppVersionFromPubspec
    }

    if (-not $AppVersion) {
        $AppVersion = "1.0.0"
    }

    Write-Host "Using AppVersion: $AppVersion"

    Write-Host "Enabling Windows desktop target..."
    flutter config --enable-windows-desktop

    Write-Host "Fetching dependencies..."
    flutter pub get

    Write-Host "Building Windows release..."
    flutter build windows --release

    $exePath = "build\windows\x64\runner\Release\NexxPharma.exe"
    if (-not (Test-Path $exePath)) {
        throw "Expected build output not found at: $exePath"
    }

    if (-not (Test-Path $IsccPath)) {
        throw "Inno Setup compiler not found at: $IsccPath"
    }

    $outputDir = "installer\output"
    if (Test-Path $outputDir) {
        Remove-Item $outputDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

    Write-Host "Building installer..."
    & $IsccPath "/O$outputDir" "/DAPPVERSION=$AppVersion" "installer\installerlocal.iss"

    Write-Host "Installer created in: $outputDir"
} catch {
    Write-Error $_
    exit 1
}

exit 0
