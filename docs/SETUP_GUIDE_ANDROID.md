# NexxStore Android Setup Guide

## System Requirements

Before installing NexxStore on Android, ensure your device meets the minimum requirements:

### Minimum Requirements
- **Android Version:** Android 7.0 (API Level 24) or higher
- **RAM:** 2 GB minimum (4 GB recommended)
- **Storage:** 200 MB free disk space
- **Display:** 4.5-inch screen minimum
- **Network:** WiFi or mobile data for activation and sync

### Recommended Requirements
- **Android Version:** Android 10 or higher (Android 12+ ideal)
- **RAM:** 4 GB or more
- **Storage:** 500 MB free disk space or SD card support
- **Display:** 5.5-inch or larger screen
- **Network:** Stable WiFi connection for optimal performance
- **Device Type:** Tablet recommended for retail environments

## Installation

### Step 1: Download APK
1. Visit [GitHub Releases](https://github.com/Genocadio/PharmacyApp/releases)
2. Download `NexxStore-android.apk`
3. Save to your device

### Step 2: Install
1. Open your file manager
2. Navigate to Downloads
3. Tap `NexxStore-android.apk`
4. Tap "Install"
5. Wait for completion
6. Tap "Open"

### Step 3: Grant Permissions
When prompted, grant:
- **Storage:** Required for data and invoices
- **Location:** Required for device features
- **Camera:** Optional, for captures
- Tap "Allow" for each

## Initial Configuration

### First Launch Setup

When you open NexxStore for the first time:

#### Step 1: Activation Credentials

1. You'll see your **Device ID**
2. Email yvesgeno@outlook.com with:
   - Device ID
   - Device name/location
3. Receive activation credentials by email
4. Return to app and enter:
   - Username (from email)
   - Activation Code (from email)
5. Tap "Activate"
6. Wait for confirmation

### Network Configuration

1. In the app, tap **Menu (☰) → Settings**
2. Tap **"Network"**
3. Configure settings:
   - **API Server:** Should be pre-filled
   - **Sync Interval:** 15 minutes (default, adjustable)
   - **Offline Mode:** Leave enabled for better reliability
4. Tap **"Test Connection"**
5. Wait for confirmation
6. Tap **"Save"**

## Device Activation

Device activation happens during first launch setup.

### If You Need to Reactivate

1. Open NexxStore
2. Tap **Menu (☰) → Settings → Device Status**
3. If device is offline:
   - Email yvesgeno@outlook.com
   - Include your Device ID
   - Receive new activation code
   - Return to Settings and reactivate

## Application Permissions

NexxStore requires different permissions:

### Required Permissions
- **Storage:** Read/Write files for invoices and data backup
- **Internet:** Required for server sync and activation

### Optional Permissions
- **Camera:** For product photo capture (request permission when feature used)
- **Location:** For geolocation-aware features
- **Contacts:** For customer/supplier lookup

### Managing Permissions on Android

1. Open **Android Settings**
2. Go to **Apps → NexxStore**
3. Tap **"Permissions"**
4. Toggle permissions ON/OFF as needed
5. Some features may not work if permissions are denied

## Using NexxStore on Android

### Main Interface

Upon launching NexxStore:

- **Bottom Navigation Menu:**
  - 🏠 Dashboard
  - 📦 Inventory
  - 💰 Sales
  - 📄 Reports
  - ☰ Menu

- **Dashboard:** Quick statistics and recent transactions
- **Inventory:** Stock levels, add products, stock movements
- **Sales:** Process new sales transactions
- **Reports:** View summaries and history
- **Menu:** Settings, sync, user management

### Key Features on Mobile

- **Offline-First:** Works without internet
- **Auto-Sync:** Syncs when connection available
- **Battery Efficient:** Optimized for mobile power efficiency
- **Touch-Optimized:** Large buttons for retail environments
- **Receipt Printing:** Via Bluetooth-enabled receipt printer

## Setting Up Hardware

### Barcode Scanner

If using a Bluetooth barcode scanner:

1. Turn on barcode scanner
2. Put scanner in pairing mode
3. On Android device: **Settings → Bluetooth → Available Devices**
4. Select your scanner from list
5. Confirm pairing
6. In NexxStore **Settings → Hardware → Barcode Scanner**
7. Enable scanner integration
8. Test scan a product

### Receipt Printer

For Bluetooth receipt printers:

1. Power on the receipt printer
2. Put printer in pairing mode (usually button press for 3 seconds)
3. On Android: **Settings → Bluetooth → Available Devices**
4. Select printer from list
5. Confirm pairing
6. In NexxStore: **Settings → Printing → Printer Selection**
7. Select your printer
8. Test print a receipt

### Mobile Card Reader

If accepting card payments via mobile reader:

1. Connect card reader via Bluetooth
2. Open NexxStore
3. Go to **Settings → Payment Methods**
4. Enable "Mobile Card Reader"
5. Select device from list
6. Follow payment provider's pairing instructions
7. Complete payment test transaction

## Updating the Application

### Getting Updates

NexxStore checks for updates on startup:

1. If available, you'll see a notification
2. Tap "Update Now"
3. Download and install latest version
4. Restart app
5. All data preserved

Or download manually from [GitHub Releases](https://github.com/Genocadio/PharmacyApp/releases)

## Data Backup

### Automatic Cloud Backup

NexxStore automatically syncs to backend:

1. Open NexxStore
2. Tap **Menu (☰) → Settings → Sync**
3. Tap **"Sync Now"** for manual sync
4. Check "Last Sync Time" for confirmation

### Local Backup

To create local backup:

1. Go to **Menu (☰) → Settings → Backup**
2. Tap **"Create Backup"**
3. Select storage location (Device or SD Card)
4. Wait for backup to complete
5. Backup saved as encrypted file

### Restore from Backup

1. Go to **Menu (☰) → Settings → Backup**
2. Tap **"Restore from Backup"**
3. Select backup file
4. Enter backup password (if created with one)
5. Confirm restoration
6. Wait for process to complete
7. App will restart with restored data

## Troubleshooting

### App Won't Install

**Problem:** "Installation Blocked" error
- Solution 1: Enable "Unknown Sources" in Settings → Security
- Solution 2: Check available storage (needs at least 200 MB free)
- Solution 3: Restart device and try again
- Solution 4: Uninstall any old version first

**Problem:** "Insufficient Storage" error
- Solution 1: Delete unused apps or files
- Solution 2: Clear cached data:
  - Settings → Apps → NexxStore → Storage → Clear Cache
- Solution 3: Use SD card for storage (if available)

### App Crashes or Won't Start

**Problem:** App force closes immediately
- Solution 1: Force stop and clear cache:
  - Settings → Apps → NexxStore → Force Stop
  - Settings → Apps → NexxStore → Storage → Clear Cache
- Solution 2: Update the app to latest version
- Solution 3: Reinstall the application
- Solution 4: Restart device

### Connection Issues

**Problem:** Cannot connect to server
- Check WiFi/data connection (try opening web browser)
- Go to **Settings → Network → Test Connection**
- Verify server address is correct
- Try again with different network
- Contact administrator if issue persists

**Problem:** Slow sync
- Ensure stable internet connection
- Go to **Settings → Network → Sync Interval** and increase time between syncs
- Close other apps using data
- Try sync over WiFi instead of mobile data

### Login Issues

**Problem:** Cannot log in
- Verify username and password
- Check device date/time is correct
- Try password reset (if available)
- Contact administrator if account locked

**Problem:** Session expires frequently
- Go to **Settings → Security**
- Increase session timeout duration
- Enable "Remember Login" (less secure on shared devices)

### Performance Issues

**Problem:** App is slow
- Solution 1: Close other apps
- Solution 2: Restart device
- Solution 3: Clear app cache:
  - Settings → Apps → NexxStore → Storage → Clear Cache
- Solution 4: Update to latest version

**Problem:** Battery drains quickly
- Reduce sync interval in **Settings → Network**
- Disable location if not using that feature
- Disable Bluetooth when not using scanners/printers
- Check background app activity in Settings

## Uninstallation

To remove NexxStore:

1. Open **Android Settings**
2. Go to **Apps → NexxStore**
3. Tap **"Uninstall"**
4. Confirm uninstallation
5. All application data will be removed

To keep data for later recovery:
1. Create backup before uninstalling (see [Data Backup](#data-backup))
2. Reinstall app and restore backup

## Support and Resources

- **User Guide:** [USER_GUIDE.md](USER_GUIDE.md)
- **Programming Guide:** [PROGRAMMING_GUIDE.md](PROGRAMMING_GUIDE.md)
- **Database Architecture:** [DATABASE_ARCHITECTURE.md](DATABASE_ARCHITECTURE.md)
- **API Integration:** [API_INTEGRATION.md](API_INTEGRATION.md)
- **Repository:** [GitHub](https://github.com/Genocadio/PharmacyApp)
- **Activation:** yvesgeno@outlook.com

---

**NexxStore Android Setup Guide v1.0** | Last Updated: March 2026
