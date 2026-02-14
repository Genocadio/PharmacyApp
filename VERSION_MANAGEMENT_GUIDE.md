# Version Management Guide

## Current Version Status

**Current Version:** `1.0.0+1` (defined in [pubspec.yaml](pubspec.yaml#L21))

## Where to Find Last Published Version

### 1. **GitHub Releases** (Recommended)
- Go to: `https://github.com/YOUR_ORG/nexxpharma/releases`
- The Inner Build workflow creates releases with tags like `v1.0.0`
- Each release includes the zip file: `nexxpharma-1.0.0.zip`

### 2. **GitHub Actions Artifacts**
- Go to: Repository → Actions → Select workflow run
- Inner Build uploads artifact: `nexxpharma-windows-release`
- Release Build uploads artifact: `nexxpharma-installer`

### 3. **Package Info at Runtime**
The app can check its own version using:
```dart
final packageInfo = await PackageInfo.fromPlatform();
final appVersion = packageInfo.version; // Returns: "1.0.0"
final buildNumber = packageInfo.buildNumber; // Returns: "1"
```

This is already used in:
- [lib/services/activation_service.dart](lib/services/activation_service.dart#L108-L109)

## How Version Propagates from pubspec.yaml

### ✅ Single Source of Truth: `pubspec.yaml`
```yaml
version: 1.0.0+1
```
This defines:
- **Version name:** `1.0.0`
- **Build number:** `1`

### Platform-Specific Version Handling

#### 🪟 **Windows**
1. **Build Process** ([windows/runner/CMakeLists.txt](windows/runner/CMakeLists.txt#L24-L28))
   - Flutter automatically passes version to CMake as:
     - `FLUTTER_VERSION="1.0.0"`
     - `FLUTTER_VERSION_MAJOR=1`
     - `FLUTTER_VERSION_MINOR=0`
     - `FLUTTER_VERSION_PATCH=0`
     - `FLUTTER_VERSION_BUILD=1`

2. **Executable Metadata** ([windows/runner/Runner.rc](windows/runner/Runner.rc#L62-L74))
   - Uses `FLUTTER_VERSION` preprocessor definitions
   - Embeds version in `.exe` file properties
   - Displays in Windows Explorer → Properties → Details

3. **Installer** ([installer/installer.iss](installer/installer.iss#L1-L3))
   - Can extract version from built executable
   - Or use passed `APPVERSION` parameter from [release-build.yml](.github/workflows/release-build.yml#L67)

#### 🤖 **Android** ([android/app/build.gradle.kts](android/app/build.gradle.kts#L29-L30))
```kotlin
versionCode = flutter.versionCode      // Reads build number: 1
versionName = flutter.versionName      // Reads version: "1.0.0"
```
✅ Automatically synced from pubspec.yaml

#### 🍎 **iOS/macOS** ([ios/Runner/Info.plist](ios/Runner/Info.plist#L19-L24))
```xml
<key>CFBundleShortVersionString</key>
<string>$(FLUTTER_BUILD_NAME)</string>
<key>CFBundleVersion</key>
<string>$(FLUTTER_BUILD_NUMBER)</string>
```
✅ Automatically synced from pubspec.yaml

#### 🐧 **Linux**
Uses Flutter's version variables (similar to Windows)

#### 🌐 **Web**
Flutter handles version automatically

## Issues Found: Hardcoded Versions

### ❌ Problem 1: Settings Screen
**File:** [lib/ui/screens/settings_screen.dart](lib/ui/screens/settings_screen.dart#L673)
```dart
trailing: Text(
  '1.0.0',  // ❌ HARDCODED!
  style: TextStyle(...)
),
```

**Solution:** Use `PackageInfo`:
```dart
FutureBuilder<PackageInfo>(
  future: PackageInfo.fromPlatform(),
  builder: (context, snapshot) {
    final version = snapshot.data?.version ?? 'Loading...';
    return Text(version);
  },
)
```

### ❌ Problem 2: Installer Script (Minor)
**File:** [installer/installer.iss](installer/installer.iss#L1)
```iss
#define AppVersion "1.0.0"
```
This is a fallback, but should be updated when version changes.

## How to Update Version (Step-by-Step)

### 1️⃣ Update Version in ONE Place
Edit [pubspec.yaml](pubspec.yaml#L21):
```yaml
version: 1.0.1+2  # Format: MAJOR.MINOR.PATCH+BUILD_NUMBER
```

### 2️⃣ Update Installer Fallback (Optional but Recommended)
Edit [installer/installer.iss](installer/installer.iss#L1):
```iss
#define AppVersion "1.0.1"
```

### 3️⃣ Run Flutter Commands
```bash
# Get dependencies (refreshes version)
flutter pub get

# Build for your platform
flutter build windows --release
flutter build apk --release
flutter build ios --release
```

### 4️⃣ Verify Version Propagation

**Check Windows Executable:**
```bash
# PowerShell - View file properties
Get-Item build\windows\x64\runner\Release\nexxpharma.exe | Select-Object VersionInfo
```

**Check at Runtime:**
```dart
final info = await PackageInfo.fromPlatform();
print('Version: ${info.version}');
print('Build: ${info.buildNumber}');
```

**Check GitHub Workflow:**
The Inner Build workflow ([.github/workflows/Inner Build.yml](.github/workflows/Inner%20Build.yml#L28-L31)) reads version automatically:
```yaml
- name: Read Version from pubspec.yaml
  id: version
  run: |
    version=$(grep '^version:' pubspec.yaml | awk '{print $2}')
    echo "VERSION=$version" >> $GITHUB_ENV
```

## CI/CD Version Flow

```
pubspec.yaml (1.0.0+1)
        ↓
Inner Build Workflow
  ├→ Reads version from pubspec.yaml
  ├→ Builds app with embedded version
  ├→ Creates artifact: nexxpharma-windows-release
  ├→ Creates GitHub Release: v1.0.0
  └→ Uploads: nexxpharma-1.0.0.zip
        ↓
Release Build Workflow
  ├→ Downloads artifact from Inner Build
  ├→ Extracts version from pubspec.yaml
  ├→ Builds installer with version
  └→ Creates installer: NexxPharmaSetup-1.0.0.exe
```

## Best Practices

### ✅ DO:
1. **Only update version in `pubspec.yaml`**
2. **Use `PackageInfo.fromPlatform()` to display version in UI**
3. **Follow semantic versioning:** MAJOR.MINOR.PATCH+BUILD
4. **Increment build number** for each build (+1, +2, +3...)
5. **Increment version** for public releases (1.0.0 → 1.0.1)

### ❌ DON'T:
1. **Don't hardcode version strings in Dart code**
2. **Don't manually edit platform-specific version files** (they auto-sync)
3. **Don't forget to update installer fallback version**

## Quick Reference

| Platform | Auto-Synced? | Source File |
|----------|--------------|-------------|
| Windows  | ✅ Yes | `windows/runner/Runner.rc` (via CMake) |
| Android  | ✅ Yes | `android/app/build.gradle.kts` |
| iOS      | ✅ Yes | `ios/Runner/Info.plist` |
| macOS    | ✅ Yes | `macos/Runner/Info.plist` |
| Linux    | ✅ Yes | Auto-handled by Flutter |
| Web      | ✅ Yes | Auto-handled by Flutter |
| Installer| ⚠️ Manual | `installer/installer.iss` (fallback) |
| Dart UI  | ⚠️ Manual | Use `PackageInfo.fromPlatform()` |

## Version Numbering Convention

```
1.0.0+1
│ │ │ └─ Build Number (increments with each build)
│ │ └─── Patch (bug fixes)
│ └───── Minor (new features, backward compatible)
└─────── Major (breaking changes)
```

**Examples:**
- `1.0.0+1` → Initial release
- `1.0.0+2` → Rebuild with same version
- `1.0.1+3` → Bug fix release
- `1.1.0+4` → New feature release
- `2.0.0+5` → Breaking change release
