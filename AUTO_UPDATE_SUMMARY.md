# Auto-Update Implementation Summary

## ✅ What Was Implemented

A complete Windows automatic update system that:
1. **Checks GitHub releases** for new versions
2. **Downloads updates** when available
3. **Automatically installs** using PowerShell script
4. **Relaunches** the app with the new version
5. **Logs everything** for troubleshooting
6. **Handles errors gracefully** with backup/rollback

## 📁 Files Created

### 1. PowerShell Updater Script
**Location:** `updater/update.ps1`
- Kills running app process
- Creates backup of current installation
- Extracts new version from ZIP
- Replaces all files
- Relaunches app
- Logs to `%TEMP%\nexxpharma_update.log`

### 2. Auto-Update Service
**Location:** `lib/services/auto_update_service.dart`
- Checks GitHub API for latest release
- Compares versions (semantic versioning)
- Downloads ZIP to temp directory
- Launches PowerShell updater
- Provides status via ChangeNotifier

### 3. UI Integration
**Modified:** `lib/ui/screens/settings_screen.dart`
- Added update checker to About section (Windows only)
- Shows: Check for Updates → Download → Install
- Progress indicator during download
- Confirmation dialog before installation

### 4. Main App Configuration
**Modified:** `lib/main.dart`
- Added auto-update service initialization
- **⚠️ YOU MUST CONFIGURE**: Set your GitHub org/repo

### 5. Installer Integration
**Modified:** `installer/installer.iss`
- Includes updater script in installation
- Script deployed to: `C:\Program Files\NexxPharma\update.ps1`

### 6. Dependencies
**Modified:** `pubspec.yaml`
- Added `path` package for file path operations

### 7. Documentation
- **`AUTO_UPDATE_GUIDE.md`** - Complete usage guide
- **`updater/README.md`** - Updater script documentation

## 🔧 Configuration Required

### Step 1: Set Your GitHub Repository

Edit `lib/main.dart` around line 48:

```dart
// Configure auto-update service (Windows only)
if (Platform.isWindows) {
  AutoUpdateService().configure(
    owner: 'YOUR_GITHUB_ORG',  // ⚠️ CHANGE THIS
    repo: 'nexxpharma',         // Repository name
  );
}
```

**Example:**
```dart
AutoUpdateService().configure(
  owner: 'nexxserve',  // Your GitHub username or organization
  repo: 'nexxpharma',
);
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

## 🚀 How It Works

### Automatic Release Creation

Your existing workflows already create releases:

1. **Inner Build Workflow** (`Inner Build.yml`):
   - Reads version from `pubspec.yaml`
   - Builds Windows app
   - Creates ZIP: `nexxpharma-{VERSION}.zip`
   - Creates GitHub Release with tag: `v{VERSION}`
   - Uploads ZIP to release

2. **User Opens App** → Settings → About
3. **Clicks "Check for Updates"**
4. **Auto-Update Service**:
   - Calls GitHub API: `https://api.github.com/repos/{owner}/{repo}/releases/latest`
   - Compares versions
   - If newer version available: Shows "Update Available"

5. **User Clicks "Download"**:
   - Downloads ZIP from GitHub release
   - Shows progress bar
   - When complete: Shows "Install" button

6. **User Clicks "Install"**:
   - Confirmation dialog appears
   - Launches `update.ps1` script
   - App closes
   - PowerShell script:
     - Creates backup
     - Extracts new version
     - Replaces files
     - Relaunches app
   - User sees new version running!

## 📋 Version Comparison Logic

Supports semantic versioning: `MAJOR.MINOR.PATCH+BUILD`

```
Examples:
  Current: 1.0.0+1  vs  Latest: 1.0.1+1  → Update available ✅
  Current: 1.0.0+1  vs  Latest: 1.1.0+1  → Update available ✅
  Current: 1.0.0+1  vs  Latest: 2.0.0+1  → Update available ✅
  Current: 1.0.0+2  vs  Latest: 1.0.0+1  → No update (newer build) ❌
  Current: 1.0.1+1  vs  Latest: 1.0.1+1  → Up to date ❌
```

## 📝 Usage Examples

### Manual Update Check (Already Integrated)

Users can:
1. Open Settings
2. Scroll to "About" section
3. Click "Check for Updates"
4. Follow prompts to download and install

### Programmatic Update Check

Add anywhere in your app:

```dart
// Check for updates silently
await AutoUpdateService().checkForUpdates(silent: true);

// Check if update is available
if (AutoUpdateService().isUpdateAvailable) {
  final latestVersion = AutoUpdateService().latestRelease?.version;
  print('New version available: $latestVersion');
}
```

### Automatic Check on Startup

Already included in the guide, but here's a simple example:

```dart
@override
void initState() {
  super.initState();
  
  // Check for updates 5 seconds after app starts (Windows only)
  if (Platform.isWindows) {
    Future.delayed(const Duration(seconds: 5), () {
      AutoUpdateService().checkForUpdates(silent: true);
    });
  }
}
```

### Listen to Update Status

```dart
AutoUpdateService().addListener(() {
  final status = AutoUpdateService().status;
  
  switch (status) {
    case UpdateStatus.available:
      // Show notification that update is available
      Toast.info('New version available!');
      break;
    case UpdateStatus.error:
      // Handle error
      final error = AutoUpdateService().errorMessage;
      Toast.error('Update check failed: $error');
      break;
    // ... other statuses
  }
});
```

## 🧪 Testing Locally

### 1. Build and Install Current Version

```bash
# Build Windows release
flutter build windows --release

# Create installer
cd installer
iscc /DAPPVERSION=1.0.0 installer.iss

# Install
output\NexxPharmaSetup-1.0.0.exe
```

### 2. Create Test Update

```bash
# Update version in pubspec.yaml
# version: 1.0.1+2

# Build new version
flutter build windows --release

# Create ZIP
cd build\windows\x64\runner\Release
Compress-Archive -Path * -DestinationPath nexxpharma-1.0.1+2.zip
```

### 3. Create GitHub Release

1. Go to: `https://github.com/YOUR_ORG/nexxpharma/releases/new`
2. Tag: `v1.0.1+2`
3. Title: `nexxpharma v1.0.1+2`
4. Upload: `nexxpharma-1.0.1+2.zip`
5. Publish release

### 4. Test in App

1. Open installed app (v1.0.0)
2. Go to Settings → About
3. Click "Check for Updates"
4. Should detect v1.0.1+2
5. Click "Download"
6. Wait for download to complete
7. Click "Install"
8. Confirm installation
9. App closes, updates, and relaunches
10. Verify new version in Settings

## 📊 Update States

| Status | Description | User Action |
|--------|-------------|-------------|
| `checking` | Checking GitHub for updates | Wait |
| `available` | New version found | Click "Download" |
| `downloading` | Downloading ZIP file | Wait (see progress) |
| `readyToInstall` | Download complete | Click "Install" |
| `installing` | PowerShell script running | App will close |
| `upToDate` | Already on latest | Click to check again |
| `error` | Something went wrong | Check error, retry |
| `noConnection` | No internet | Check connection |

## 🛡️ Error Handling

### PowerShell Not Available

```
Error: PowerShell is not available on this system
```

**Cause:** PowerShell not installed or not in PATH

**Solution:** PowerShell comes with Windows. If missing:
- Windows 10/11: Pre-installed
- Older Windows: Install Windows Management Framework

### Updater Script Not Found

```
Error: Updater script not found at: C:\Program Files\NexxPharma\update.ps1
```

**Cause:** Script wasn't packaged with installer

**Solution:**
1. Verify `installer/installer.iss` includes updater
2. Rebuild installer
3. Reinstall app

### Download Failed

```
Error: Failed to download update: 404
```

**Cause:** Release or asset not found

**Solution:**
1. Check GitHub release exists
2. Verify ZIP file name: `nexxpharma-*.zip`
3. Ensure release is published (not draft)

### Installation Failed

Check log file:
```
%TEMP%\nexxpharma_update.log
```

Common issues:
- Permission denied → Run as admin
- File in use → Close all app instances
- Disk full → Free up space

## 🔒 Security Notes

### Current Implementation
- ✅ HTTPS downloads from GitHub
- ✅ Detached PowerShell execution
- ✅ Backup creation before update
- ✅ Rollback on failure
- ✅ Comprehensive logging

### Production Recommendations

1. **Code Signing** (Recommended)
   ```powershell
   # Sign the executable
   signtool sign /f cert.pfx /p password nexxpharma.exe
   
   # Sign the PowerShell script
   Set-AuthenticodeSignature -FilePath update.ps1 -Certificate $cert
   ```

2. **Checksum Verification** (Future Enhancement)
   - Add SHA256 checksum to releases
   - Verify before extraction

3. **Release Channel** (Future Enhancement)
   - Stable, Beta, Dev channels
   - Users opt-in to preview builds

## 📦 What Gets Updated

The entire application folder is replaced:

```
C:\Program Files\NexxPharma\
├── nexxpharma.exe ✅ Updated
├── update.ps1     ✅ Updated (if changed)
├── *.dll          ✅ Updated
├── data/          ✅ Updated
└── flutter_assets/ ✅ Updated

User data is NOT affected:
- Database files (stored in AppData)
- User preferences
- Settings
```

## 🎯 Next Steps

1. ✅ **Configure GitHub repo** in `lib/main.dart`
2. ✅ **Run `flutter pub get`**
3. ✅ **Test update flow** locally
4. ✅ **Deploy** new installer with updater
5. ⏩ **Monitor** update logs
6. ⏩ **Iterate** on user feedback

## 📚 Documentation References

- [AUTO_UPDATE_GUIDE.md](AUTO_UPDATE_GUIDE.md) - Complete guide
- [VERSION_MANAGEMENT_GUIDE.md](VERSION_MANAGEMENT_GUIDE.md) - Version management
- [updater/README.md](updater/README.md) - Updater script details

## 🐛 Troubleshooting Quick Reference

| Problem | Check | Solution |
|---------|-------|----------|
| Update check fails | GitHub repo configured? | Edit `main.dart` |
| No releases found | Release published? | Create release on GitHub |
| Download fails | Internet connection? | Check connectivity |
| Install button disabled | Download complete? | Wait for download |
| App won't close | Other instances running? | Close all instances |
| Files not replaced | Running as admin? | Right-click → Run as admin |
| App won't relaunch | Executable path correct? | Check updater log |

## ✨ Features Included

✅ Automatic version checking
✅ Semantic version comparison
✅ GitHub release integration  
✅ Download progress tracking
✅ PowerShell-based installation
✅ Automatic backup/rollback
✅ Comprehensive error handling
✅ User-friendly UI
✅ Detailed logging
✅ Windows-only (appropriate for desktop app)

## 🚀 You're Ready!

The auto-update system is fully implemented and integrated. Users will be able to:
- Check for updates from Settings
- Download updates with progress
- Install with one click
- App automatically restarts with new version

All you need to do is:
1. Configure your GitHub repository name in `main.dart`
2. Run `flutter pub get`
3. Test it works!

Happy updating! 🎉
