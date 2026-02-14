# NexxPharma Updater

This directory contains the PowerShell updater script used for automatic updates on Windows.

## Files

- **`update.ps1`** - PowerShell script that handles the update process

## How It Works

1. **Packaging**: The updater script is automatically included in the Windows installer by Inno Setup (see `installer/installer.iss`)

2. **Deployment**: When users install NexxPharma, `update.ps1` is copied to the installation directory:
   ```
   C:\Program Files\NexxPharma\update.ps1
   ```

3. **Execution**: When an update is available:
   - App downloads new version ZIP to temp folder
   - App launches `update.ps1` with parameters
   - Script kills the app process
   - Script backs up current installation
   - Script extracts and replaces files
   - Script relaunches the app
   - Script cleans up temp files

## Script Parameters

```powershell
.\update.ps1 `
  -ZipPath "C:\Temp\nexxpharma-1.0.1.zip" `
  -InstallPath "C:\Program Files\NexxPharma" `
  -ProcessId 12345 `
  -AppExeName "nexxpharma.exe"
```

## Logging

All update operations are logged to:
```
%TEMP%\nexxpharma_update.log
```

Example log location:
```
C:\Users\YourName\AppData\Local\Temp\nexxpharma_update.log
```

## Testing

To test the updater script manually:

1. Build a release version:
   ```bash
   flutter build windows --release
   ```

2. Create a test ZIP:
   ```powershell
   Compress-Archive -Path "build\windows\x64\runner\Release\*" -DestinationPath "test-update.zip"
   ```

3. Install NexxPharma using the installer

4. Run the updater script:
   ```powershell
   $appPath = "C:\Program Files\NexxPharma"
   $processId = (Get-Process nexxpharma).Id
   
   & "$appPath\update.ps1" `
     -ZipPath "C:\path\to\test-update.zip" `
     -InstallPath $appPath `
     -ProcessId $processId `
     -AppExeName "nexxpharma.exe"
   ```

5. Check the log for any errors:
   ```powershell
   notepad $env:TEMP\nexxpharma_update.log
   ```

## Error Handling

The script includes comprehensive error handling:

- **Backup Creation**: Creates a backup before updating
- **Rollback**: Restores from backup if update fails
- **Logging**: Logs all operations for troubleshooting
- **Graceful Failure**: Attempts to relaunch app even on error

## Security

### Execution Policy

The script is executed with `-ExecutionPolicy Bypass` to avoid user intervention:
```powershell
powershell -ExecutionPolicy Bypass -File update.ps1 ...
```

### Code Signing (Recommended for Production)

For production deployment, sign the PowerShell script:

```powershell
# Get code signing certificate
$cert = Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert

# Sign the script
Set-AuthenticodeSignature -FilePath update.ps1 -Certificate $cert -TimestampServer http://timestamp.digicert.com
```

### Permissions

The updater requires:
- **Write permissions** to installation directory
- **Process termination** permissions
- **File extraction** permissions

If installed in Program Files, may require admin elevation.

## Troubleshooting

### Script Won't Run

**Issue**: PowerShell execution policy prevents script execution

**Solution**: The app launches with `-ExecutionPolicy Bypass`. If still blocked:
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

### Files Not Replaced

**Issue**: Access denied errors during file replacement

**Solution**: 
- Close all instances of the app
- Run as administrator
- Check antivirus settings

### App Won't Relaunch

**Issue**: App doesn't start after update

**Solution**:
- Check log file in `%TEMP%`
- Verify executable path is correct
- Check Windows Event Viewer for errors
- Restore from backup manually

### Backup Not Created

**Issue**: Backup creation fails

**Solution**:
- Ensure sufficient disk space
- Check TEMP directory is writable
- Update continues even if backup fails (logged as warning)

## Development

### Modifying the Script

1. Edit `updater/update.ps1`
2. Test changes locally
3. Rebuild installer (will include updated script)
4. Test full update flow

### Adding Features

Common enhancements:
- Progress callbacks to app
- Checksum verification
- Incremental/delta updates
- Multi-file update support
- Network retry logic

## Related Documentation

- [AUTO_UPDATE_GUIDE.md](../AUTO_UPDATE_GUIDE.md) - Complete auto-update system documentation
- [VERSION_MANAGEMENT_GUIDE.md](../VERSION_MANAGEMENT_GUIDE.md) - Version management guide
- [installer/installer.iss](../installer/installer.iss) - Inno Setup installer configuration

## Support

For issues or questions:
1. Check log file: `%TEMP%\nexxpharma_update.log`
2. Review error messages in script output
3. Test script manually with verbose logging
4. Contact development team
