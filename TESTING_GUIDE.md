# Testing the Reactive UI System

## Quick Verification Checklist

Use this checklist to verify the reactive UI system is working correctly.

## Test 1: Device Type Change (Clinic → Pharmacy Retail)

### Steps:
1. Launch the app and log in
2. Navigate to **Settings Screen**
3. Find device type selector
4. Change from `CLINIC_INVENTORY` to `PHARMACY_RETAIL`
5. Observe the main screen automatically

### Expected Results:
- ✅ Stock In/Out tabs reorganize
- ✅ Wholesale-specific fields appear/disappear
- ✅ Invoice labels change (if applicable)
- ✅ No manual page refresh required
- ✅ Navigation back shows updated configuration

### What's Happening Behind the Scenes:
```
User changes device type in Settings
         ↓
settingsService.updateDeviceType(DeviceType.PHARMACY_RETAIL)
         ↓
SettingsService.notifyListeners()
         ↓
DeviceStateManager._onSettingsChanged() detects change
         ↓
_deviceType != newDeviceType → notifyListeners()
         ↓
StockInOutScreen._onDeviceStateChanged() triggered
         ↓
setState(() {}) called
         ↓
Widget tree rebuilds with new device type
         ↓
UI displays PHARMACY_RETAIL layout
```

---

## Test 2: Device Deactivation

### Prerequisites:
- Device must be currently active
- Have admin access to backend (or can simulate)

### Steps:
1. App is running and fully functional
2. Backend deactivates device (or trigger status check manually)
3. Wait for next automatic status check (every 5 minutes)
4. Observe app response

### Expected Results:
- ✅ App detects deactivation within 5 minutes
- ✅ Activation screen appears automatically
- ✅ No manual logout/login needed
- ✅ All features become unavailable

### What's Happening:
```
Backend: Device status changed to INACTIVE
         ↓
ActivationService._performScheduledChecks() runs (every 5 min)
         ↓
Detects activation status change in database
         ↓
Updates Device.activationStatus = INACTIVE
         ↓
ActivationService.notifyListeners()
         ↓
DeviceStateManager._onActivationChanged() detects change
         ↓
_isActivated = false → notifyListeners()
         ↓
Multiple screens react:
  - StockInOutScreen._onDeviceStateChanged()
  - ActivationScreen updates
  - UI shows "Device Inactive" / "Please Reactivate"
```

---

## Test 3: Module Subtype Change

### Prerequisites:
- Device has module configured
- Have admin rights to change module subtype

### Steps:
1. App is running
2. Backend updates module subtype (e.g., wholesale brand configuration)
3. Wait for next sync or manual refresh
4. Observe UI changes

### Expected Results:
- ✅ UI reflects new module subtype
- ✅ Features adjust based on new subtype
- ✅ No error messages appear
- ✅ All functionality remains operational

---

## Test 4: Device Activation Completion

### Prerequisites:
- Device in PENDING activation state
- Activation code available

### Steps:
1. App shows ActivationScreen
2. Enter activation code and complete setup
3. Manager account created
4. Watch transition to StockInOutScreen

### Expected Results:
- ✅ Activation status changes from PENDING to ACTIVE
- ✅ ActivationScreen dismisses automatically
- ✅ StockInOutScreen displays
- ✅ All features enabled
- ✅ Speed of transition: < 1 second

---

## Test 5: Rapid Configuration Changes

### Purpose:
Test that rapid changes don't cause race conditions or crashes

### Steps:
1. Rapidly switch device type A → B → C → A
2. Make changes while sync is in progress
3. Change device type while settings screen is open
4. Monitor for errors

### Expected Results:
- ✅ No crashes
- ✅ No race conditions
- ✅ Final state is correct
- ✅ No duplicate notifications

---

## Manual Testing Code (Debug Mode)

Add this code temporarily to test state changes manually:

```dart
// In StockInOutScreenState, add debug button:
FloatingActionButton(
  onPressed: () async {
    // Simulate device type change
    await widget.settingsService.updateDeviceType(
      DeviceType.PHARMACY_WHOLESALE
    );
    debugPrint('Device type changed to PHARMACY_WHOLESALE');
  },
  child: Text('Test Change'),
)
```

Or trigger via ActivationService:

```dart
// Simulate deactivation in ActivationService
if (kDebugMode) {
  Future.delayed(Duration(seconds: 10), () {
    debugPrint('Simulating device deactivation...');
    // Change device status in database
  });
}
```

---

## Performance Monitoring

### Measure UI Update Speed

Add timing code:

```dart
void _onDeviceStateChanged() {
  final timestamp = DateTime.now();
  debugPrint('Device state change detected at $timestamp');
  
  if (mounted) {
    setState(() {});
    debugPrint('Widget rebuild triggered at ${DateTime.now()}');
    debugPrint('Latency: ${DateTime.now().difference(timestamp).inMilliseconds}ms');
  }
}
```

### Expected Performance:
- Device state change detection: < 10ms
- setState() call: < 5ms
- Widget rebuild: < 50ms
- Total latency: < 100ms

### Monitor Memory

```dart
// Check listener count
debugPrint('Device state listeners: ${widget.deviceStateManager._listeners?.length}');
```

---

## Verification Checklist

- [ ] **Device Type Change**: Switch device types, UI updates automatically
- [ ] **Deactivation**: Device deactivated server-side, app responds within 5 min
- [ ] **Module Subtype**: Module config changes reflected immediately
- [ ] **Activation Complete**: PENDING → ACTIVE transition smooth and fast
- [ ] **No Manual Refresh**: No need to refresh pages or restart app
- [ ] **Performance**: UI updates in < 100ms
- [ ] **Memory**: No memory leaks with repeated changes
- [ ] **Error Handling**: No crashes on rapid changes
- [ ] **Listener Cleanup**: Proper disposal of listeners when screens close

---

## Troubleshooting Guide

### Issue: UI Not Updating on Device Type Change

**Debugging Steps:**
1. Add logging to `_onDeviceStateChanged()`:
   ```dart
   void _onDeviceStateChanged() {
     debugPrint('>>> Device state changed!');
     if (mounted) {
       setState(() {
         debugPrint('>>> setState called');
       });
     } else {
       debugPrint('>>> Widget not mounted');
     }
   }
   ```

2. Check if listener is registered:
   ```dart
   debugPrint('Listeners subscribed: ${widget.deviceStateManager._listeners?.isNotEmpty}');
   ```

3. Verify clean up in dispose():
   ```dart
   void dispose() {
     debugPrint('>>> Disposing state, removing listeners');
     widget.deviceStateManager.removeListener(_onDeviceStateChanged);
     super.dispose();
   }
   ```

### Issue: Deactivation Not Detected

**Debugging Steps:**
1. Check activation service timer:
   ```dart
   debugPrint('Next status check in: ${activationService._statusTimer?.tick}');
   ```

2. Verify database update:
   ```dart
   final device = await database.getDevice();
   debugPrint('Current device status: ${device?.activationStatus}');
   ```

3. Force status check:
   ```dart
   await activationService._updateDeviceStatusIfNeeded();
   ```

### Issue: Memory Leak

**Debugging Steps:**
1. Add listener counting:
   ```dart
   @override
   void initState() {
     super.initState();
     final beforeCount = (widget.deviceStateManager as ChangeNotifier)
         .listeners
         .length;
     widget.deviceStateManager.addListener(_onDeviceStateChanged);
     debugPrint('Listeners before: $beforeCount, after: ${beforeCount + 1}');
   }

   @override
   void dispose() {
     final beforeCount = (widget.deviceStateManager as ChangeNotifier)
         .listeners
         .length;
     widget.deviceStateManager.removeListener(_onDeviceStateChanged);
     debugPrint('Listeners before dispose: $beforeCount, after: ${beforeCount - 1}');
     super.dispose();
   }
   ```

2. Monitor for listener accumulation over time
3. Ensure `dispose()` is called (check console logs)

---

## Automated Testing (Future)

```dart
// Unit test example
void main() {
  test('DeviceStateManager notifies on type change', () async {
    final manager = DeviceStateManager(db, settings, activation);
    
    var notificationCount = 0;
    manager.addListener(() => notificationCount++);
    
    await settings.updateDeviceType(DeviceType.PHARMACY_RETAIL);
    
    expect(notificationCount, equals(1));
  });
  
  test('UI rebuild triggered on state change', () async {
    await tester.pumpWidget(TestApp());
    
    expect(find.byType(StockInOutScreen), findsOneWidget);
    
    await changeDeviceType();
    await tester.pumpAndSettle();
    
    expect(find.byType(NovaLayout), findsOneWidget);
  });
}
```

---

## Success Indicators

✅ System working correctly when:
1. Device type changes reflected in UI instantly
2. Deactivation events trigger activation screen automatically
3. No manual page refresh/reload ever needed
4. No errors in console
5. Performance is smooth (no lag)
6. Memory usage stable over time (no leaks)
7. All listeners properly cleaned up
8. App handles rapid changes gracefully

---

## Support

If tests fail, check:
1. Are all services properly initialized?
2. Are listeners properly registered and cleaned up?
3. Is `mounted` check present before `setState()`?
4. Are there any circular dependencies?
5. Check Flutter analyzer: `flutter analyze`
6. Check runtime errors: Look at console output
