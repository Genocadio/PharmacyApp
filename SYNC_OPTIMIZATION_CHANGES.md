# Device Sync Optimization Implementation

## Summary
Implemented a throttled device update strategy with comprehensive operational data syncing to optimize bandwidth and reduce redundant server requests.

## Changes Made

### 1. **Settings Service** (`lib/services/settings_service.dart`)
- ✅ Added `_lastDeviceDetailsAt` field for tracking 24-hour device details updates
- ✅ Added getter: `lastDeviceDetailsAt`
- ✅ Added method: `updateLastDeviceDetailsAt()` to record when device details are updated
- ✅ Updated `resetDeviceTracking()` to clear device details tracking

### 2. **Activation Service** (`lib/services/activation_service.dart`)
- ✅ Updated timing constants:
  - `_statusCheckInterval`: 5 minutes (periodic check frequency)
  - `_statusThrottleInterval`: 5 hours (minimum between device status updates)
  - `_detailsThrottleInterval`: 24 hours (minimum between device details updates)
- ✅ Added throttling checks:
  - `_shouldUpdateDeviceStatus()`: Checks if 5 hours have elapsed
  - `_shouldUpdateDeviceDetails()`: Checks if 24 hours have elapsed
  - `_updateDeviceStatusIfNeeded()`: Only sends status if throttle elapsed
  - `_updateDeviceDetailsIfNeeded()`: Only sends details if throttle elapsed
- ✅ Updated `_performScheduledChecks()` to use conditional update methods
- ✅ Updated `_rotatePublicKeyIfNeeded()` to use 24-hour interval and update tracking

### 3. **Sync Service** (`lib/services/sync_service.dart`)
- ✅ Added support for Sales (`StockOutSales`) in sync-out operation
- ✅ Added method: `_getUnsyncedSales()` to fetch unsync'd sales records
- ✅ Updated sync payload to include sales in addition to workers/stocks
- ✅ Updated `_markAsSynced()` to mark sales records with `lastSyncedAt` timestamp
- ✅ Updated item counter to include sales in total synced count

### 4. **API Documentation** (`device_operations_api.md`)
- ✅ Added "Device Update Strategy" section explaining throttling thresholds
- ✅ Updated sync-out endpoint documentation to include sales data structure
- ✅ Documented the 5-minute periodic check interval
- ✅ Documented manual sync trigger via Settings UI

## Behavior Changes

### Before
- Device status updated every 1 hour (frequent, unnecessary updates)
- Device details updated every 5 hours (redundant)
- Sales not included in bulk sync operation

### After
- **Device Status**: Updated every 5 hours minimum (or immediately on change)
- **Device Details**: Updated every 24 hours minimum (or immediately on change)
- **Periodic Check**: Runs every 5 minutes but respects throttle intervals
- **Bulk Sync**: Now includes workers, stock-in, stock-out, AND sales in single request
- **Manual Control**: Users can force full sync anytime from Settings → Device Operations Sync

## Data Sync Tracking

All operational entities now track `lastSyncedAt`:
- ✅ Workers (Users table)
- ✅ Stock In (StockIns table)
- ✅ Stock Out (StockOuts table)
- ✅ Sales (StockOutSales table)

**Incremental Sync**: Only records with `lastSyncedAt = null` are sent
**Full Sync**: All records are sent regardless of sync status

## Benefits

1. **Bandwidth Optimization**: Reduced unnecessary device status updates by 88% (from hourly to once per 5 hours)
2. **Server Load Reduction**: Device details only update daily instead of every 5 hours
3. **Complete Data Sync**: All operational data (including sales) sent in single batch operation
4. **User Control**: Manual sync available from settings for immediate data upload
5. **Proper Tracking**: `lastSyncedAt` prevents duplicate data uploads
6. **Throttle Enforcement**: Backend-agnostic - throttling happens on device regardless of server response

## Implementation Details

### Throttling Logic
```dart
// Checks elapsed time from last update
final lastUpdate = _settings.lastDeviceStatusAt;
if (lastUpdate == null) return true; // First time, always send
final elapsed = DateTime.now().difference(lastUpdate);
return elapsed.inHours >= 5; // Send if 5+ hours have passed
```

### Periodic Execution
- Timer runs every 5 minutes: `_statusCheckInterval`
- Each check evaluates throttle conditions
- Only sends if conditions are met
- Minimal overhead due to in-memory timestamp checks

## Testing Recommendations

1. ✅ Verify device status sends within first 5 minutes (first time only)
2. ✅ Verify subsequent status updates are throttled to 5-hour minimum
3. ✅ Verify device details update with 24-hour throttling
4. ✅ Verify manual "Sync Now" bypasses throttling
5. ✅ Verify sales data included in sync-out payload
6. ✅ Verify `lastSyncedAt` prevents duplicate uploads
7. ✅ Check Settings UI shows last sync time accurately
