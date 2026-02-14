# NexxPharma Auto-Updater Script
# This script updates the application by replacing files with a new version

param(
    [Parameter(Mandatory=$true)]
    [string]$ZipPath,
    
    [Parameter(Mandatory=$true)]
    [string]$InstallPath,
    
    [Parameter(Mandatory=$true)]
    [int]$ProcessId,
    
    [Parameter(Mandatory=$false)]
    [string]$AppExeName = "NexxPharma.exe"
)

$ErrorActionPreference = "Stop"
$LogFile = Join-Path $env:TEMP "nexxpharma_update.log"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Add-Content -Path $LogFile -Value $logMessage
    Write-Host $logMessage
}

try {
    Write-Log "========================================="
    Write-Log "NexxPharma Auto-Update Started"
    Write-Log "========================================="
    Write-Log "Zip Path: $ZipPath"
    Write-Log "Install Path: $InstallPath"
    Write-Log "Process ID to kill: $ProcessId"
    Write-Log "App Exe Name: $AppExeName"

    # Wait a moment for the app to initiate shutdown
    Write-Log "Waiting 2 seconds for app to prepare..."
    Start-Sleep -Seconds 2

    # Kill the application process
    Write-Log "Attempting to terminate application process (PID: $ProcessId)..."
    try {
        $process = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
        if ($process) {
            $process | Stop-Process -Force
            Write-Log "Process terminated successfully"
            Start-Sleep -Seconds 1
        } else {
            Write-Log "Process already terminated"
        }
    } catch {
        Write-Log "Warning: Could not kill process: $_"
    }

    # Verify zip file exists
    if (-not (Test-Path $ZipPath)) {
        throw "Update zip file not found at: $ZipPath"
    }
    Write-Log "Update zip file verified"

    # Verify install path exists
    if (-not (Test-Path $InstallPath)) {
        throw "Installation directory not found at: $InstallPath"
    }
    Write-Log "Installation directory verified"

    # Create temporary extraction directory
    $TempExtractPath = Join-Path $env:TEMP "nexxpharma_update_$(Get-Date -Format 'yyyyMMddHHmmss')"
    New-Item -ItemType Directory -Path $TempExtractPath -Force | Out-Null
    Write-Log "Created temp extraction directory: $TempExtractPath"

    # Extract the update
    Write-Log "Extracting update files..."
    try {
        Expand-Archive -Path $ZipPath -DestinationPath $TempExtractPath -Force
        Write-Log "Extraction completed successfully"
    } catch {
        throw "Failed to extract update: $_"
    }

    # Backup current installation
    $BackupPath = Join-Path $env:TEMP "nexxpharma_backup_$(Get-Date -Format 'yyyyMMddHHmmss')"
    Write-Log "Creating backup at: $BackupPath"
    try {
        Copy-Item -Path $InstallPath -Destination $BackupPath -Recurse -Force
        Write-Log "Backup created successfully"
    } catch {
        Write-Log "Warning: Backup creation failed: $_"
    }

    # Delete old files (except data and updater)
    Write-Log "Removing old application files..."
    Get-ChildItem -Path $InstallPath -Exclude "data", "*.ps1", "*.log" | ForEach-Object {
        try {
            Remove-Item $_.FullName -Recurse -Force -ErrorAction Stop
            Write-Log "Removed: $($_.Name)"
        } catch {
            Write-Log "Warning: Could not remove $($_.Name): $_"
        }
    }

    # Copy new files
    Write-Log "Copying new application files..."
    $filesCopied = 0
    Get-ChildItem -Path $TempExtractPath -Recurse | ForEach-Object {
        $targetPath = $_.FullName.Replace($TempExtractPath, $InstallPath)
        
        if ($_.PSIsContainer) {
            if (-not (Test-Path $targetPath)) {
                New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
            }
        } else {
            try {
                Copy-Item -Path $_.FullName -Destination $targetPath -Force
                $filesCopied++
            } catch {
                Write-Log "Warning: Failed to copy $($_.Name): $_"
            }
        }
    }
    Write-Log "Copied $filesCopied files successfully"

    # Clean up temporary files
    Write-Log "Cleaning up temporary files..."
    try {
        Remove-Item -Path $TempExtractPath -Recurse -Force
        Remove-Item -Path $ZipPath -Force
        Write-Log "Cleanup completed"
    } catch {
        Write-Log "Warning: Cleanup failed: $_"
    }

    # Relaunch the application
    $exePath = Join-Path $InstallPath $AppExeName
    if (Test-Path $exePath) {
        Write-Log "Relaunching application: $exePath"
        Start-Process -FilePath $exePath
        Write-Log "Application relaunched successfully"
    } else {
        throw "Application executable not found at: $exePath"
    }

    Write-Log "========================================="
    Write-Log "Update completed successfully!"
    Write-Log "========================================="
    
    # Show success notification (brief)
    Start-Sleep -Seconds 2

} catch {
    Write-Log "========================================="
    Write-Log "ERROR: Update failed!"
    Write-Log "Error: $_"
    Write-Log "========================================="
    
    # Try to restore from backup if it exists
    if (Test-Path $BackupPath) {
        Write-Log "Attempting to restore from backup..."
        try {
            Remove-Item -Path $InstallPath -Recurse -Force
            Copy-Item -Path $BackupPath -Destination $InstallPath -Recurse -Force
            Write-Log "Backup restored successfully"
            
            # Relaunch old version
            $exePath = Join-Path $InstallPath $AppExeName
            if (Test-Path $exePath) {
                Start-Process -FilePath $exePath
            }
        } catch {
            Write-Log "Failed to restore backup: $_"
        }
    }
    
    exit 1
}

exit 0
