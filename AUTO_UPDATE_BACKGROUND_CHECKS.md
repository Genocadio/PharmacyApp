# Auto-Update: Background Checks & Manual Controls

## ✅ New Features Added

### 1. Automatic Periodic Background Checks
- **Default Interval**: Every 6 hours
- **Initial Check**: 10 seconds after app startup
- **Silent Operation**: Checks in background without UI disruption
- **Configurable**: Can change interval or disable completely

### 2. Settings UI Controls

#### Toggle Switch
- **Enable/Disable** automatic checks
- **Last Check Time**: Shows when last check occurred (e.g., "2h ago", "just now")
- **Persistent**: Setting is remembered

#### Check Interval Selector
- **Options**: 1h, 3h, 6h, 12h, 24h
- **Easy Selection**: Dropdown menu
- **Live Updates**: Changes take effect immediately
- **Hidden When Disabled**: Only shows when auto-check is enabled

#### Manual Check Button
- **Always Available**: Check updates anytime
- **Real-time Status**: Shows checking/downloading/installing states
- **Update Actions**: Download and Install buttons when update available

## 🎯 User Experience

### Settings → About Section

```
┌─────────────────────────────────────────┐
│ ☰ Automatic Update Checks        [ON]  │
│   Last checked: 2h ago                  │
├─────────────────────────────────────────┤
│ ⏰ Check Interval                       │
│   Check every 6 hours        [6 hours ▼]│
├─────────────────────────────────────────┤
│ 📥 Check for Updates            [Check] │
│   You are on the latest version         │
└─────────────────────────────────────────┘
```

### When Update Available

```
┌─────────────────────────────────────────┐
│ ⚠️ Update Available          [Download] │
│   Version 1.0.1+2 is available          │
└─────────────────────────────────────────┘
```

### After Download

```
┌─────────────────────────────────────────┐
│ ✅ Update Available           [Install] │
│   Update ready to install               │
└─────────────────────────────────────────┘
```

## 🔧 Configuration

### Default Settings (in main.dart)

```dart
AutoUpdateService().initialize(
  autoCheck: true,                          // Enable automatic checks
  checkInterval: const Duration(hours: 6),  // Check every 6 hours
  checkImmediately: true,                   // Check 10s after startup
);
```

### Customization Options

**Change Default Interval:**
```dart
checkInterval: const Duration(hours: 12),  // Check every 12 hours
```

**Disable Auto-Check:**
```dart
autoCheck: false,  // Only manual checks
```

**Skip Initial Check:**
```dart
checkImmediately: false,  // Don't check on startup
```

## 📊 Behavior

### Automatic Checks
1. **Silent Operation**: No UI changes during background checks
2. **Notification**: Only notifies if update is found (via internal state)
3. **User Action**: User sees "Update Available" next time they open Settings
4. **No Interruption**: Never forces user to update

### Manual Checks
1. **Immediate Feedback**: Shows "Checking..." status
2. **Progress Tracking**: Download progress bar
3. **User Control**: User decides when to download and install

### Check Intervals
- Timer starts when app launches
- Resets when interval is changed
- Stops when auto-check is disabled
- Resumes when auto-check is re-enabled

## 🎨 UI States

| State | Icon | Color | Action |
|-------|------|-------|--------|
| Checking | 🔄 refresh | Accent | Wait |
| Available | ⚠️ system_update | Orange | Download |
| Downloading | 📥 download | Accent | Wait + Progress |
| Ready | ✅ check_circle | Accent | Install |
| Installing | ⏳ hourglass_empty | Accent | Wait |
| Up to Date | ✓ check_circle_outline | Accent | Check Again |
| Error | ⚠️ error_outline | Red | Retry |
| No Connection | ☁️ cloud_off | Grey | Try Later |

## 💡 Tips

### For Users
- **Keep Auto-Check On**: Get notified of updates automatically
- **Adjust Interval**: Set based on internet data concerns
- **Manual Override**: Can always check manually anytime
- **Install When Ready**: No rush, install when convenient

### For Developers
- **Test Silent Checks**: Verify background checks don't impact performance
- **Monitor Logs**: Check `debugPrint` output for update checks
- **Adjust Intervals**: Based on release frequency

## 🔍 Debugging

### Check Auto-Update Status

```dart
final service = AutoUpdateService();
print('Auto-check enabled: ${service.autoCheckEnabled}');
print('Check interval: ${service.checkInterval.inHours}h');
print('Last check: ${service.lastCheckTime}');
print('Status: ${service.status}');
print('Update available: ${service.isUpdateAvailable}');
```

### Force Manual Check

```dart
await AutoUpdateService().checkForUpdates(silent: false);
```

### Reset Service

```dart
AutoUpdateService().reset();
```

### Stop Auto-Checks

```dart
AutoUpdateService().stopAutoCheck();
```

## 📝 Code Changes Summary

### AutoUpdateService
- ✅ Added `Timer` for periodic checks
- ✅ Added `initialize()` method
- ✅ Added `setAutoCheckEnabled()` method
- ✅ Added `setCheckInterval()` method
- ✅ Added `stopAutoCheck()` method
- ✅ Added `lastCheckTime` tracking
- ✅ Added `dispose()` for cleanup

### Settings Screen  
- ✅ Added toggle for auto-check
- ✅ Added interval selector dropdown
- ✅ Added last check time display
- ✅ Added formatted time (e.g., "2h ago")
- ✅ Keep existing manual check button

### Main App
- ✅ Initialize auto-update with defaults
- ✅ Start checking 10s after launch
- ✅ Configure 6-hour interval

## 🚀 Result

Users now have:
1. ✅ **Automatic background checks** every 6 hours
2. ✅ **Manual trigger button** in Settings
3. ✅ **Full control** over check frequency
4. ✅ **Toggle on/off** automatic checks
5. ✅ **Last check time** visibility

No action needed - works out of the box! 🎉
