# NexxStore Windows Setup Guide

## System Requirements

Before installing NexxStore on Windows, ensure your system meets the minimum requirements:

### Minimum Requirements
- **OS:** Windows 10 (Build 19041) or Windows 11
- **Processor:** Intel Core i5 (7th Gen) or equivalent AMD processor
- **RAM:** 4 GB minimum (8 GB recommended)
- **Storage:** 500 MB free disk space
- **Display:** 1366x768 resolution minimum
- **Network:** Internet connection for initial activation and sync

### Recommended Requirements
- **OS:** Windows 11 (latest version)
- **Processor:** Intel Core i7 or AMD Ryzen 5
- **RAM:** 8 GB or more
- **Storage:** SSD with 1 GB free space
- **Display:** 1920x1080 or higher
- **Network:** Stable broadband connection

## Installation

### Step 1: Download NexxStore

1. Visit the [GitHub Releases page](https://github.com/Genocadio/PharmacyApp/releases)
2. Download the latest `NexxStore-windows-installer.exe` file
3. Save to a known location (e.g., Downloads folder)

### Step 2: Run the Installer

1. Navigate to your Downloads folder
2. Double-click `NexxStore-windows-installer.exe`
3. Click "Yes" when prompted by User Account Control (UAC)
4. Wait for the installation wizard to launch

### Step 3: Complete Installation Wizard

1. **License Agreement:** Accept the terms
2. **Installation Folder:** Use default or select custom location
3. **Additional Tasks:** Check all options (desktop shortcut, Start Menu, auto-launch)
4. **Installation:** Wait for completion (1-2 minutes)
5. **Finish:** Application launches automatically

## Initial Configuration

### First Launch

When NexxStore opens for the first time:

### First Launch

1. **Welcome:** NexxStore will initialize
2. **Server Configuration:** Configuration is handled automatically upon activation

### Step 2: Credentials

Upon first launch, you'll need activation credentials:

1. **Request Credentials:**
   - Email: yvesgeno@outlook.com
   - Provide: Device name and location
   - You'll receive: Username and activation code

2. **Enter Credentials:**
   - Username: From email
   - Activation Code: From email
   - Click "Activate"

### Network Configuration

1. Go to **Settings → Network**
2. Verify settings are configured correctly
3. Click "Test Connection" to verify
4. Click "Save"

### Printer Setup

1. Open **Settings → Printing**
2. Click "Detect Printers"
3. Select your primary printer from the list
4. Configure receipt paper size:
   - **A4:** 210 × 297 mm
   - **80mm:** 80 × 200 mm receipt
   - **57mm:** 57 × 150 mm receipt
5. Test print settings before using in production
6. Click "Save"

## Device Activation

Device activation happens during first launch setup.

### If You Need to Reactivate

1. Open NexxStore
2. Go to **Settings → Device Status**
3. If device is offline:
   - Email yvesgeno@outlook.com
   - Include your Device ID
   - Receive new activation code
   - Return to Settings and reactivate

## Updating the Application

### Getting Updates

NexxStore checks for updates on startup:

1. If available, you'll see a notification
2. Click "Update Now" to install
3. Application will restart with new version
4. All data is preserved

Alternatively, download latest version from [GitHub Releases](https://github.com/Genocadio/PharmacyApp/releases)

## Platform-Specific Features

### Windows Auto-Update Integration

NexxStore system integration:

1. Check **Settings → System Integration**
2. Enable "Allow Windows Update Integration"
3. Application will restart outside of business hours when updates are available

### Single-Instance Application

- Only one instance of NexxStore can run on your computer
- If you try to launch it again, it will switch to the already-running window
- This prevents data inconsistencies

### System Tray Integration

- NexxStore minimizes to system tray when closed
- Click the icon in the system tray to restore
- Right-click for menu options (Restore, Settings, Exit)

## Uninstallation

To remove NexxStore from your computer:

1. Press **Windows Key + R**
2. Type `control panel` and press Enter
3. Go to **Programs → Programs and Features**
4. Find "NexxStore" in the list
5. Click on it and select "Uninstall"
6. Follow the uninstall wizard
7. Click "Finish"

All application data is retained in `C:\Users\[YourUsername]\AppData\Local\NexxStore` for potential recovery.

## Troubleshooting Windows Installation

### Installation Fails

**Problem:** Installer won't run
- **Solution 1:** Right-click installer → "Run as Administrator"
- **Solution 2:** Temporarily disable antivirus software
- **Solution 3:** Delete any existing NexxStore folder from Program Files
- **Solution 4:** Restart computer and try again

**Problem:** "File in use" error during installation
- Close all running programs
- Restart computer
- Run installer as Administrator

### Application Won't Start

**Problem:** NexxStore crashes on startup
- **Solution 1:** Use Windows Compatibility Mode:
  - Right-click NexxStore → Properties
  - Go to Compatibility tab
  - Try running in Windows 10 compatibility mode
  - Click Apply and OK
- **Solution 2:** Reinstall the application
- **Solution 3:** Check Windows Event Viewer for error details

### Connection Issues

**Problem:** Cannot connect to server
- Verify internet connection (try opening a web browser)
- Check firewall settings (port 443 must be open)
- Verify server address in Settings → Network
- Try restarting the application
- Check with IT if using corporate proxy

### Printer Not Working

**Problem:** Printer not detected
- Ensure printer is turned on and connected
- Go to Settings → Printing → Detect Printers
- Manually select printer from list if not detected
- Check Windows Print Spooler service is running:
  - Press Windows Key + R
  - Type `services.msc`
  - Find "Print Spooler"
  - Ensure it's running (status = "Running")

## Maintenance

### Regular Tasks

**Weekly:**
- Verify sync status is successful
- Check for pending transactions
- Review system storage space

**Monthly:**
- Check for application updates
- Verify printer connectivity
- Review backup status

### Storage Management

NexxStore database grows over time. To manage storage:

1. Go to **Settings → Advanced**
2. View current database size
3. Archive old transactions (optional):
   - Click "Archive Transactions"
   - Select date range
   - Click "Archive"
4. Clear cache (optional):
   - Click "Clear Cache"
   - Confirm action

### Database Integrity

NexxStore automatically maintains database integrity:

1. Weekly automatic checks occur at 2 AM
2. Manual verification:
   - Go to **Settings → Advanced**
   - Click "Verify Database"
   - Wait for completion message

## Support and Resources

- **User Guide:** [USER_GUIDE.md](USER_GUIDE.md)
- **Programming Guide:** [PROGRAMMING_GUIDE.md](PROGRAMMING_GUIDE.md)
- **Database Architecture:** [DATABASE_ARCHITECTURE.md](DATABASE_ARCHITECTURE.md)
- **API Integration:** [API_INTEGRATION.md](API_INTEGRATION.md)
- **Repository:** [GitHub](https://github.com/Genocadio/PharmacyApp)
- **Activation:** yvesgeno@outlook.com

---

**NexxStore Windows Setup Guide v1.0** | Last Updated: March 2026
