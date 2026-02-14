# Autonomous Sync System

## Overview

This document describes the autonomous background sync system that handles data synchronization, device status updates, and internet connectivity monitoring without user intervention.

## Architecture

The autonomous sync system consists of three main components:

### 1. **ConnectivityService** ([lib/services/connectivity_service.dart](lib/services/connectivity_service.dart))
   - Monitors internet connectivity status
   - Performs periodic checks every 30 seconds
   - Notifies listeners when connectivity changes
   - Triggers sync operations when internet is restored

### 2. **BackgroundSyncManager** ([lib/services/background_sync_manager.dart](lib/services/background_sync_manager.dart))
   - Manages all autonomous background operations
   - Handles initial sync-in
   - Performs periodic sync-out
   - Executes device status checks
   - Queues operations when offline

### 3. **Updated Launch Flow** ([lib/main.dart](lib/main.dart))
   - Integrated connectivity monitoring
   - Automatic background sync initialization
   - Removed manual sync screen

## Launch Flow

### Step-by-Step Process:

1. **App Launch**
   ```
   ├─ Check Activation Status
   │  ├─ Not Activated → Activation Screen
   │  └─ Activated
   │     ├─ No Users → Activation Screen (Add Manager)
   │     └─ Has Users
   │        ├─ Not Logged In → Login Screen
   │        └─ Logged In → Main Screen + Initialize Background Sync
   ```

2. **After Reaching Main Screen**
   - Background Sync Manager initializes automatically
   - Performs initial operations:
     - Check if initial sync needed
     - Perform sync-in if not done yet
     - Execute device status check (if online)
     - Sync-out any pending data (if online)

3. **If App Closed Before Initial Sync**
   - On next launch → automatically retries sync-in
   - User can use the app immediately
   - Sync happens in background

## Autonomous Operations

### 1. Initial Sync-In (First Full Sync)

**When:** After activation and user creation, automatically on first login.

**Behavior:**
- Automatically triggers when BackgroundSyncManager initializes
- If internet unavailable → waits until online
- Shows success toast when completed
- Marks sync as completed in settings
- If app closes before completion → retries on next launch

**Code Location:** `BackgroundSyncManager._performInitialSyncIn()`

### 2. Sync-Out (Outgoing Data Sync)

**When:**
- After stock addition/removal
- After user (worker) addition
- Every 5 minutes (automatic check)
- When internet connectivity is restored

**Behavior:**
- **Online:** Immediately syncs data silently
- **Offline:** Queues the operation, syncs when online
- No user notification unless manually triggered
- Sends only unsynced data

**Manual Trigger:**
```dart
backgroundSyncManager.triggerSyncOut(silent: false);
```

**Code Location:** `BackgroundSyncManager._performSyncOut()`

### 3. Device Status Checks

**When:**
- On app launch (if online)
- Every 2 hours
- When internet connectivity is restored (if check was skipped)

**What's Sent:**
- Device ID and signature (always)
- Additional data only if changed:
  - Latitude/Longitude (if location changed)
  - App version (if updated)
  - Device status (if changed)

**Behavior:**
- Silent operation (no user notification)
- Updates device status on backend
- Receives pending commands from server
- Processes module status updates

**Code Location:** `BackgroundSyncManager._performStatusCheck()`

## Internet Connectivity Handling

### Connectivity Monitoring

- Checks every 30 seconds
- Makes request to google.com for verification
- Tracks last connected/disconnected times
- Notifies all listeners of status changes

### When Internet is Lost

1. **Ongoing Operations:** Complete if possible, fail gracefully
2. **New Operations:** Queue for later execution
3. **User Experience:** App remains fully functional offline
4. **Notifications:** Info toast "Changes saved. Will sync when online."

### When Internet is Restored

Automatically triggers in this order:
1. **Initial Sync-In** (if not completed)
2. **Device Status Check**
3. **Sync-Out** (pending data)

## Timers and Periodicity

| Operation | Frequency | Trigger |
|-----------|-----------|---------|
| Connectivity Check | Every 30 seconds | Automatic |
| Device Status Check | Every 2 hours | Automatic + On Launch |
| Sync-Out Check | Every 5 minutes | Automatic |
| Sync-Out | On Data Change | Manual Trigger |

**Note:** If internet unavailable during scheduled time, operation queues and executes when connectivity restored.

## Integration Points

### How to Trigger Sync-Out After Operations

In your service (e.g., Stock Service, User Service):

```dart
// After stock addition/removal
await backgroundSyncManager.triggerSyncOut(silent: true);
```

**Example in Stock-In Service:**
```dart
Future<StockInDTO> createStockIn(StockInCreateDTO dto) async {
  // ... create stock
  final stockIn = await _repository.create(dto);
  
  // Trigger background sync
  await backgroundSyncManager.triggerSyncOut(silent: true);
  
  return stockIn;
}
```

### Accessing BackgroundSyncManager

The manager is available in main screen widgets. To access it in services, pass it as a dependency:

```dart
class StockInService {
  final AppDatabase database;
  final BackgroundSyncManager? backgroundSyncManager;
  
  StockInService(this.database, {this.backgroundSyncManager});
}
```

## User Experience

### What Users See

**Normal Operation:**
- App works seamlessly
- No sync dialogs or blocking screens
- Toast notifications for important events
- Progress indicators in app bar (optional)

**When Offline:**
- Full app functionality maintained
- "Will sync when online" info messages
- No blocking or errors

**When Online Returns:**
- Silent automatic sync
- Success confirmation if items synced
- No interruption to workflow

## Status Indicators

### Optional: Add Sync Status to App Bar

```dart
// In StockInOutScreen
AppBar(
  actions: [
    ListenableBuilder(
      listenable: backgroundSyncManager,
      builder: (context, _) {
        if (backgroundSyncManager.isSyncingOut) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    ),
  ],
)
```

## Configuration

### Adjust Sync Intervals

**In BackgroundSyncManager Constructor:**

```dart
// Change status check interval (default: 2 hours)
_startPeriodicStatusChecks() {
  _statusCheckTimer = Timer.periodic(
    const Duration(hours: 2), // Change this
    (_) => ...
  );
}

// Change sync-out check interval (default: 5 minutes)
_startPeriodicSyncOutChecks() {
  _syncOutCheckTimer = Timer.periodic(
    const Duration(minutes: 5), // Change this
    (_) => ...
  );
}
```

**In ConnectivityService:**

```dart
// Change connectivity check interval (default: 30 seconds)
_checkTimer = Timer.periodic(
  const Duration(seconds: 30), // Change this
  (_) => checkConnectivity()
);
```

## Debugging

### Enable Debug Logs

Wrapped in `kDebugMode` checks, automatically enabled in debug builds:

```dart
if (kDebugMode) {
  print('Performing initial sync-in...');
  print('Status check completed at $_lastStatusCheck');
  print('Sync-out completed: ${syncService.itemsSynced} items synced');
}
```

### Monitor Sync Status

```dart
// Check if background sync is initialized
backgroundSyncManager.isInitialized

// Check if currently syncing
backgroundSyncManager.isSyncingOut
backgroundSyncManager.isCheckingStatus

// Check last operation times
backgroundSyncManager.lastStatusCheck
backgroundSyncManager.nextScheduledStatusCheck

// Check connectivity
connectivityService.isConnected
connectivityService.lastConnectedTime
connectivityService.lastDisconnectedTime
```

## Benefits

1. **✅ Seamless UX:** No blocking sync screens
2. **✅ Offline Support:** Full functionality without internet
3. **✅ Automatic Recovery:** Syncs when connectivity restored
4. **✅ Efficient:** Only syncs changed data
5. **✅ Reliable:** Periodic checks ensure data consistency
6. **✅ Silent:** Background operations don't interrupt workflow
7. **✅ Smart:** Only sends data when necessary (status checks)

## Implementation Checklist

- [x] Create ConnectivityService
- [x] Create BackgroundSyncManager
- [x] Update main.dart launch flow
- [x] Remove InitialSyncScreen from normal flow
- [x] Add background sync initialization
- [ ] Update StockInService to trigger sync-out
- [ ] Update StockOutService to trigger sync-out
- [ ] Update UserService to trigger sync-out
- [ ] Test offline/online transitions
- [ ] Test initial sync flow
- [ ] Test periodic operations

## Future Enhancements

1. **Retry Logic:** Exponential backoff for failed operations
2. **Conflict Resolution:** Handle concurrent data modifications
3. **Bandwidth Optimization:** Compress data for slow connections
4. **Battery Awareness:** Reduce frequency when low battery
5. **Selective Sync:** Sync only priority data when offline
6. **Sync Queue UI:** Show pending operations to user
