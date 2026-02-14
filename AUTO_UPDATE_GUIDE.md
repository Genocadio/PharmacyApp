# Auto-Update System Documentation

## Overview

NexxPharma implements a Windows-only automatic update system that checks GitHub releases for new versions and installs them seamlessly.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      User Interaction                        │
│              (Settings Screen - Check Updates)               │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  AutoUpdateService                           │
│  • Checks GitHub releases API                                │
│  • Compares versions                                         │
│  • Downloads update zip                                      │
│  • Launches PowerShell updater script                        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│               PowerShell Updater Script                      │
│                  (update.ps1)                                │
│  • Kills the running app                                     │
│  • Backs up current installation                             │
│  • Extracts new version                                      │
│  • Replaces files                                            │
│  • Relaunches app                                            │
└─────────────────────────────────────────────────────────────┘
```

## Components

### 1. AutoUpdateService (`lib/services/auto_update_service.dart`)

Dart service that manages the update process:
- Checks GitHub API for latest release
- Downloads ZIP file to temp directory
- Launches PowerShell updater script
- Provides update status via ChangeNotifier

**Key Methods:**
```dart
// Check for updates
await AutoUpdateService().checkForUpdates();

// Download update
await AutoUpdateService().downloadUpdate();

// Install update
await AutoUpdateService().installUpdate();

// Auto-update (check + download if available)
await AutoUpdateService().autoUpdate();
```

### 2. PowerShell Updater Script (`updater/update.ps1`)

Handles the actual file replacement:
- Terminates the running application
- Creates backup of current installation
- Extracts new version from ZIP
- Replaces all files
- Relaunches the application
- Logs everything to temp folder

**Script Parameters:**
- `-ZipPath`: Path to downloaded update ZIP
- `-InstallPath`: Application installation directory
- `-ProcessId`: PID of running app to terminate
- `-AppExeName`: Name of executable to relaunch

### 3. Settings UI Integration

Update checker integrated into Settings screen's About section (Windows only):
- Shows current version
- Check for updates button
- Download progress indicator
- Install update confirmation

## Installation Structure

When installed via Inno Setup, files are organized as:

```
C:\Program Files\NexxPharma\
├── nexxpharma.exe          # Main application
├── update.ps1              # Updater script (packaged by installer)
├── app_icon.ico            # Application icon
├── data/                   # Flutter data directory
│   ├── app.so
│   ├── icudtl.dat
│   └── flutter_assets/
└── *.dll                   # Flutter dependencies
```

## Configuration

### Step 1: Configure GitHub Repository

In your `main.dart` or initialization code:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure auto-update service
  AutoUpdateService().configure(
    owner: 'YOUR_GITHUB_ORG',      // Replace with your org/username
    repo: 'nexxpharma',            // Repository name
  );
  
  runApp(MyApp());
}
```

### Step 2: Enable Auto-Update on Startup (Optional)

Check for updates automatically when app starts:

```dart
void initState() {
  super.initState();
  
  // Check for updates silently on startup
  if (Platform.isWindows) {
    Future.delayed(const Duration(seconds: 5), () {
      AutoUpdateService().checkForUpdates(silent: true);
    });
  }
}
```

### Step 3: Build and Release

The workflows are already configured to create proper releases:

1. **Update version in pubspec.yaml:**
   ```yaml
   version: 1.0.1+2  # Increment version
   ```

2. **Commit and push to main:**
   ```bash
   git add pubspec.yaml
   git commit -m "Bump version to 1.0.1"
   git push origin main
   ```

3. **Inner Build Workflow** automatically:
   - Builds Windows app
   - Creates ZIP: `nexxpharma-1.0.1+2.zip`
   - Creates GitHub Release: `v1.0.1+2`
   - Uploads ZIP to release

4. **App checks and updates automatically** when users click "Check for Updates"

## Update Flow

### Manual Update (User-Initiated)

```
1. User opens Settings → About section
2. Clicks "Check for Updates" button
3. AutoUpdateService checks GitHub API
4. If newer version found:
   ├─ Shows "Update Available" with version
   ├─ User clicks "Download"
   ├─ Progress bar shows download status
   ├─ When complete, shows "Install" button
   ├─ User clicks "Install"
   ├─ Confirmation dialog appears
   ├─ User confirms
   ├─ PowerShell script launches
   ├─ App closes
   ├─ Files updated in background
   └─ App relaunches with new version
5. If no update: Shows "You are on the latest version"
```

### Automatic Update (Background)

```dart
// In app initialization or periodic timer
AutoUpdateService().autoUpdate();  // Checks and downloads silently

// User can then choose when to install
// Or prompt user when download completes
```

## Version Comparison

The service uses semantic versioning comparison:

```
Format: MAJOR.MINOR.PATCH+BUILD

Examples:
  1.0.0+1  vs  1.0.1+1  →  Update available (patch bump)
  1.0.0+1  vs  1.1.0+1  →  Update available (minor bump)
  1.0.0+1  vs  2.0.0+1  →  Update available (major bump)
  1.0.0+1  vs  1.0.0+2  →  Update available (build bump)
  1.0.0+2  vs  1.0.0+1  →  No update (newer build)
```

## Error Handling

### PowerShell Not Available
```dart
if (errorMessage?.contains('PowerShell is not available')) {
  // Log error - PowerShell required for updates on Windows
  Toast.error('PowerShell is required for automatic updates');
}
```

### Network Errors
```dart
if (status == UpdateStatus.error) {
  // Check internet connection
  // Retry later or prompt user
}
```

### Update Script Missing
```dart
if (errorMessage?.contains('Updater script not found')) {
  // Updater script was not packaged with installer
  // User must reinstall or download manually
}
```

### Rollback on Failure

The updater script automatically:
1. Creates backup before updating
2. If update fails, restores from backup
3. Relaunches old version
4. Logs errors to: `%TEMP%\nexxpharma_update.log`

## Testing

### Test Update Flow Locally

1. **Build current version:**
   ```bash
   flutter build windows --release
   ```

2. **Create installer and install:**
   ```bash
   # Build installer with Inno Setup
   iscc /DAPPVERSION=1.0.0 installer\installer.iss
   
   # Install the app
   installer\output\NexxPharmaSetup-1.0.0.exe
   ```

3. **Bump version and create release:**
   ```yaml
   # pubspec.yaml
   version: 1.0.1+2
   ```

4. **Build and package new version:**
   ```bash
   flutter build windows --release
   cd build/windows/x64/runner/Release
   Compress-Archive -Path * -DestinationPath nexxpharma-1.0.1+2.zip
   ```

5. **Create GitHub release manually:**
   - Tag: `v1.0.1+2`
   - Upload: `nexxpharma-1.0.1+2.zip`

6. **Test in app:**
   - Open Settings → About
   - Click "Check for Updates"
   - Should detect v1.0.1+2
   - Download and install

### Test Updater Script Directly

```powershell
# Create a test zip
Compress-Archive -Path "build\windows\x64\runner\Release\*" -DestinationPath "test-update.zip"

# Run updater script manually
powershell -ExecutionPolicy Bypass -File "C:\Program Files\NexxPharma\update.ps1" `
  -ZipPath "C:\path\to\test-update.zip" `
  -InstallPath "C:\Program Files\NexxPharma" `
  -ProcessId 12345 `
  -AppExeName "nexxpharma.exe"

# Check log
notepad $env:TEMP\nexxpharma_update.log
```

## Security Considerations

### 1. **Code Signing**
For production, sign both the app and PowerShell script:
```powershell
# Sign executable
signtool sign /f certificate.pfx /p password /t http://timestamp.server nexxpharma.exe

# Sign PowerShell script
Set-AuthenticodeSignature -FilePath update.ps1 -Certificate $cert -TimestampServer http://timestamp.server
```

### 2. **HTTPS Only**
GitHub releases are always served over HTTPS, ensuring secure downloads.

### 3. **Checksum Verification** (Future Enhancement)
Add ZIP checksum verification:
```dart
// In AutoUpdateService
final expectedChecksum = latestRelease.checksumSHA256;
final actualChecksum = await computeSHA256(downloadedFile);
if (expectedChecksum != actualChecksum) {
  throw Exception('Checksum mismatch - file corrupted');
}
```

### 4. **Permissions**
The updater requires:
- Write access to installation directory
- Ability to kill processes
- Ability to launch processes

If installed in Program Files, may require admin elevation.

## Troubleshooting

### Update Check Fails
```
Error: Failed to check for updates: 404

Solution:
- Verify GitHub repository owner/repo in AutoUpdateService.configure()
- Ensure repository is public or token has access
- Check if any releases exist
```

### Download Fails
```
Error: Failed to download update: 403

Solution:
- Check internet connection
- Verify release asset exists
- Check if ZIP file name matches pattern: nexxpharma-*.zip
```

### Installation Fails
```
Error: Updater script not found

Solution:
- Reinstall app using latest installer
- Verify update.ps1 exists in installation directory
- Check Inno Setup installer.iss includes updater script
```

### PowerShell Execution Policy
```
Error: PowerShell execution policy prevents script execution

Solution:
The updater automatically uses -ExecutionPolicy Bypass
If still blocked, user must run:
  Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### App Doesn't Relaunch
```
Check updater log:
  notepad %TEMP%\nexxpharma_update.log

Common causes:
- Executable path incorrect
- Permissions issue
- Antivirus blocking
```

## Future Enhancements

### 1. **Delta Updates**
- Download only changed files instead of full ZIP
- Reduce bandwidth and update time

### 2. **Background Downloads**
- Download updates silently in background
- Notify user when ready to install

### 3. **Scheduled Updates**
- Check for updates daily/weekly
- Silent installation during off-hours

### 4. **Update Channels**
- Stable, Beta, Dev channels
- Users can opt into beta updates

### 5. **Rollback Feature**
- Keep last N versions
- Allow user to rollback if issues

### 6. **P2P Distribution**
- Reduce server load
- Faster downloads via peer network

### 7. **In-App Update Notifications**
- Toast notification when update available
- "Update and Restart" button in title bar

## References

- [Semantic Versioning](https://semver.org/)
- [GitHub Releases API](https://docs.github.com/en/rest/releases)
- [Inno Setup Documentation](https://jrsoftware.org/ishelp/)
- [PowerShell Script Signing](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-authenticodesignature)

## Support

For issues or questions:
1. Check log file: `%TEMP%\nexxpharma_update.log`
2. Check GitHub Issues
3. Contact support team
