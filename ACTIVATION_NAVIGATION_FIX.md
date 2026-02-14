# Activation Navigation Fix

## Problem
The app was randomly navigating users back to the activation screen during normal operation, even when the device was properly activated.

## Root Cause
The `BackgroundSyncManager` performs periodic status checks (every 2 hours or when connectivity is restored) by calling `activationService.updateDeviceStatus()`. This method:

1. Sends a heartbeat request to the backend
2. Receives a `DeviceApiResponse` containing a `status` field
3. Updates the local device's activation status
4. Calls `_refreshActivationState()` which updates `_isActivated`
5. Calls `notifyListeners()` triggering navigation logic rebuild

The navigation logic in [main.dart](main.dart) uses a `ListenableBuilder` that listens to `activationService`. When `_isActivated` is refreshed, even if the status hasn't changed, it triggers a rebuild, causing unwanted navigation.

## Solution
Modified `_handleDeviceApiResponse()` in [lib/services/activation_service.dart](lib/services/activation_service.dart) to:

1. **Track current activation status** before updating
2. **Compare with new status** from the server response
3. **Only call `_refreshActivationState()` and `notifyListeners()`** when the activation status **actually changes**

### Key Changes
```dart
// Before: Always refreshed and notified
await _db.updateDeviceLocal(activationStatus: newStatus, ...);
await _refreshActivationState(); // Always called

// After: Only refresh when status changes
final currentStatus = currentDevice?.activationStatus;
final newStatus = response.status!.isActive ? ActivationStatus.ACTIVE : ActivationStatus.INACTIVE;

await _db.updateDeviceLocal(activationStatus: newStatus, ...);

if (currentStatus != newStatus) {
  shouldNotify = true; // Only notify on actual change
}
```

## Behavior After Fix
- ✅ **Status checks run silently** when activation status is unchanged
- ✅ **Navigation remains stable** during routine heartbeat operations
- ✅ **Navigation only triggers** when device is genuinely deactivated by backend
- ✅ **No impact on legitimate activation flows** (registration, deactivation)

## Testing Scenarios
1. **Normal operation**: Status checks should happen every 2 hours without affecting navigation
2. **Connectivity restore**: When internet comes back, status check should run silently
3. **Backend deactivation**: If backend sets device to INACTIVE, navigation should trigger to activation screen
4. **Initial activation**: Registration flow should work normally with navigation to main screen

## Related Files
- [lib/services/activation_service.dart](lib/services/activation_service.dart) - Main fix location
- [lib/services/background_sync_manager.dart](lib/services/background_sync_manager.dart) - Calls updateDeviceStatus()
- [lib/main.dart](lib/main.dart) - Navigation logic with ListenableBuilder
