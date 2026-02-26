# Build signed Android release artifacts locally and stage them for publishing

param(
    [Parameter(Mandatory=$false)]
    [switch]$BuildApk = $true,

    [Parameter(Mandatory=$false)]
    [switch]$BuildAab = $true,

    [Parameter(Mandatory=$false)]
    [string]$OutputDir = "release/android"
)

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

function Get-VersionFromPubspec {
    $versionLine = Select-String -Path "pubspec.yaml" -Pattern "^version:\s*(.+)$" | ForEach-Object { $_.Matches[0].Groups[1].Value }
    if (-not $versionLine) {
        throw "Unable to read version from pubspec.yaml"
    }
    return $versionLine.Trim()
}

function Ensure-AndroidSigningConfig {
    $keyPropsPath = Join-Path $Root "android\key.properties"
    if (-not (Test-Path $keyPropsPath)) {
        throw "Missing android\key.properties. Configure release signing before building."
    }

    $requiredKeys = @("storeFile", "storePassword", "keyAlias", "keyPassword")
    $content = Get-Content $keyPropsPath -Raw

    foreach ($k in $requiredKeys) {
        if ($content -notmatch "(?m)^$k\s*=") {
            throw "android\key.properties is missing required key: $k"
        }
    }
}

try {
    $version = Get-VersionFromPubspec
    Write-Host "Building Android release for version: $version"

    Ensure-AndroidSigningConfig

    flutter --version | Out-Null
    flutter pub get

    if (Test-Path $OutputDir) {
        Remove-Item $OutputDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

    if ($BuildApk) {
        Write-Host "Building signed APK..."
        flutter build apk --release

        $apkSource = "build\app\outputs\flutter-apk\app-release.apk"
        if (-not (Test-Path $apkSource)) {
            throw "APK not found at $apkSource"
        }

        $apkTarget = Join-Path $OutputDir "nexxpharma-android-$version.apk"
        Copy-Item $apkSource $apkTarget -Force
        Write-Host "APK staged at: $apkTarget"
    }

    if ($BuildAab) {
        Write-Host "Building signed App Bundle (AAB)..."
        flutter build appbundle --release

        $aabSource = "build\app\outputs\bundle\release\app-release.aab"
        if (-not (Test-Path $aabSource)) {
            throw "AAB not found at $aabSource"
        }

        $aabTarget = Join-Path $OutputDir "nexxpharma-android-$version.aab"
        Copy-Item $aabSource $aabTarget -Force
        Write-Host "AAB staged at: $aabTarget"
    }

    Write-Host "Android release artifacts ready in: $OutputDir"
    Write-Host "Commit and push files in $OutputDir to trigger publish workflow."
}
catch {
    Write-Error $_
    exit 1
}

exit 0
