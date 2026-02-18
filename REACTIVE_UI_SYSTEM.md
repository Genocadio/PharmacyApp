# Reactive Device State Management System

## Overview

The app now has a comprehensive reactive UI system that automatically updates the user interface whenever device configuration changes. This includes:

- **Device Type Changes** (CLINIC_INVENTORY ↔ PHARMACY_RETAIL ↔ PHARMACY_WHOLESALE)
- **Activation Status Changes** (PENDING → ACTIVE → INACTIVE)
- **Module Subtype Changes** (e.g., wholesale brand changes)
- **Deactivation Events** (device deactivated by admin)
- **Device Role Changes** (ADMIN ↔ NORMAL)

## Architecture

### 1. DeviceStateManager Service
**Location:** `lib/services/device_state_manager.dart`

Central service that consolidates all device configuration changes into a single notification source. It:

- Listens to `SettingsService` changes (device type, device role)
- Listens to `ActivationService` changes (activation status, module subtype)
- Provides unified notifications to UI layers
- Exposes helper getters like `isClinicInventory`, `isPharmacyWholesale`, `isDeviceActive`, etc.

```dart
// Usage in screens
widget.deviceStateManager.isClinicInventory  // bool
widget.deviceStateManager.isPharmacyWholesale // bool
widget.deviceStateManager.isDeviceActive     // bool
widget.deviceStateManager.deviceType         // DeviceType?
widget.deviceStateManager.activationStatus   // ActivationStatus?
widget.deviceStateManager.moduleSubtype      // String?
```

### 2. Screen-Level Listeners

All main screens now listen to device state changes and automatically rebuild when changes occur:

#### Stock In/Out Screen (`lib/ui/screens/stock_in_out_screen.dart`)
```dart
void initState() {
  // Listen for device configuration changes
  widget.deviceStateManager.addListener(_onDeviceStateChanged);
}

void _onDeviceStateChanged() {
  if (mounted) {
    setState(() {
      // Triggers automatic UI rebuild with new device state
    });
  }
}

void dispose() {
  widget.deviceStateManager.removeListener(_onDeviceStateChanged);
  super.dispose();
}
```

#### Activation Screen (`lib/ui/screens/activation_screen.dart`)
- Listens to activation status changes
- Automatically re-checks device activation state on changes
- Updates UI when activation completes

#### Settings Screen (`lib/ui/screens/settings_screen.dart`)
- Monitors activation and settings changes
- Reflects configuration updates immediately
- Shows device status dynamically

### 3. App-Level Integration

In `lib/main.dart`:
- DeviceStateManager is created and initialized with all dependencies
- Passed to all screens via constructor injection
- Included in main `ListenableBuilder` merge for app-wide change notification

```dart
final deviceStateManager = DeviceStateManager(
  database,
  settingsService,
  activationService,
);

return ListenableBuilder(
  listenable: Listenable.merge([
    authService,
    settingsService,
    syncService,
    activationService,
    backgroundSyncManager,
    connectivityService,
    deviceStateManager,  // <-- Merged for app-wide notifications
  ]),
  builder: (context, child) { ... }
);
```

## How It Works

### Example: Device Type Change (Clinic → Pharmacy Retail)

1. **User Action**: Admin changes device type in settings to PHARMACY_RETAIL

2. **Settings Update**:
   ```dart
   await settingsService.updateDeviceType(DeviceType.PHARMACY_RETAIL);
   // SettingsService calls notifyListeners()
   ```

3. **DeviceStateManager Detection**:
   ```dart
   void _onSettingsChanged() {
     final newDeviceType = _settingsService.deviceType;
     if (newDeviceType != _deviceType) {
       _deviceType = newDeviceType;
       notifyListeners();  // <-- Notifies all listeners
     }
   }
   ```

4. **UI Screens Rebuild**:
   ```dart
   void _onDeviceStateChanged() {
     setState(() {});  // <-- Rebuilds widget tree
   }
   ```

5. **UI Changes Reflect**:
   - Stock In/Out tabs reorganize based on device type
   - Wholesale-specific features appear/disappear
   - Invoice labels change (Patient → Pharmacy or vice versa)
   - Permission checks update immediately

### Example: Device Deactivation

1. **Server Event**: Backend deactivates device (admin action)

2. **Activation Service Detection**:
   - Periodic status check discovers deactivation
   - Updates device.activationStatus = INACTIVE in database
   - Calls `notifyListeners()`

3. **DeviceStateManager Captures Change**:
   ```dart
   Future<void> _onActivationChanged() async {
     final device = await _database.getDevice();
     final newStatus = device?.activationStatus;
     if (newStatus != _activationStatus) {
       _activationStatus = newStatus;
       notifyListeners();
     }
   }
   ```

4. **All Screens React Automatically**:
   - App shows activation screen if device inactive
   - Or shows warning banner
   - Or disables key features depending on your business logic

## Benefits

1. **Consistency**: All UI changes triggered by same source
2. **No Manual Syncing**: Changes propagate automatically without explicit refresh calls
3. **No State Duplication**: Single truth source via DeviceStateManager
4. **Type Safety**: Uses enums (DeviceType, ActivationStatus) not strings
5. **Performance**: Only rebuilds affected screens, not entire app
6. **Memory Safe**: Proper listener cleanup in dispose() prevents leaks

## Implementation Checklist

- ✅ DeviceStateManager created with consolidated listeners
- ✅ StockInOutScreen listens to device state changes
- ✅ ActivationScreen listens to activation changes
- ✅ SettingsScreen listens to all device changes
- ✅ DeviceStateManager passed to all screens via constructor
- ✅ Proper listener cleanup in all screen dispose() methods
- ✅ Main app merges deviceStateManager in ListenableBuilder

## Testing the System

To verify the reactive system works:

1. **Change Device Type**:
   - Go to Settings
   - Change device type from CLINIC_INVENTORY to PHARMACY_RETAIL
   - Observe: Tab layout changes, invoice labels update, fields reorganize

2. **Test Deactivation**:
   - Backend deactivates device
   - App automatically shows activation screen on next status check
   - No manual refresh needed

3. **Monitor Logs**:
   ```dart
   // Add to DeviceStateManager._onActivationChanged()
   debugPrint('Device state changed: $newStatus, $newSubtype');
   ```

## Adding New Listeners

To make a new screen reactive to device changes:

```dart
class MyScreen extends StatefulWidget { ... }

class _MyScreenState extends State<MyScreen> {
  @override
  void initState() {
    super.initState();
    widget.deviceStateManager.addListener(_onDeviceStateChanged);
  }

  void _onDeviceStateChanged() {
    if (mounted) {
      setState(() {
        // UI rebuilds with new device state
      });
    }
  }

  @override
  void dispose() {
    widget.deviceStateManager.removeListener(_onDeviceStateChanged);
    super.dispose();
  }
}
```

## Notes

- DeviceStateManager is a `ChangeNotifier`, not a Provider or GetX (uses Flutter's built-in Observer pattern)
- Async device database checks are cached in DeviceStateManager to prevent redundant queries
- The system respects lifecycle (only notifies if `mounted`)
- All listeners are properly cleaned up to prevent memory leaks
