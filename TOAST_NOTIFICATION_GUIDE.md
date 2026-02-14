# Toast Notification System

This app includes a React Toastify-like floating notification system that displays toast notifications from the left side of the screen.

## Features

- 🎨 **4 notification types**: Success, Error, Warning, and Info
- 🎭 **Smooth animations**: Slides in from the left with fade effect
- ⏱️ **Auto-dismiss**: Automatically disappears after a configurable duration (default: 4 seconds)
- 👆 **Tap to dismiss**: Click on any notification to dismiss it immediately
- 🌓 **Theme-aware**: Adapts to light and dark themes
- 📚 **Stacking**: Multiple notifications stack vertically (max 6 visible, scrollable)
- 🎯 **Easy to use**: Simple static methods for quick access
- 📜 **Scrollable**: If many notifications appear, they become scrollable to prevent overflow

## Usage

### Basic Usage

Import the Toast utility:

```dart
import 'package:nexxpharma/ui/widgets/toast.dart';
```

Then use it anywhere in your app:

```dart
// Success notification
Toast.success('User created successfully');

// Error notification
Toast.error('Failed to save data');

// Warning notification
Toast.warning('This action cannot be undone');

// Info notification
Toast.info('New update available');
```

### Custom Duration

By default, notifications disappear after 4 seconds. You can customize this:

```dart
Toast.success(
  'This will stay for 10 seconds',
  duration: const Duration(seconds: 10),
);

Toast.error(
  'Quick message',
  duration: const Duration(seconds: 2),
);
```

### Advanced Usage

For more control, you can use the NotificationService directly:

```dart
import 'package:nexxpharma/services/notification_service.dart';

// Get the notification service instance
final notificationService = NotificationService();

// Show notifications
notificationService.showSuccess('Success message');
notificationService.showError('Error message');

// Clear all notifications
notificationService.clearAll();

// Dismiss a specific notification
notificationService.dismiss(notificationId);
```

## Replacing ScaffoldMessenger

### Before (using ScaffoldMessenger):

```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('User created successfully')),
);
```

### After (using Toast):

```dart
Toast.success('User created successfully');
```

## Examples in Different Scenarios

### User Management

```dart
Future<void> _createUser() async {
  try {
    await userService.register(userDto);
    Toast.success('User created successfully');
    Navigator.pop(context);
  } catch (e) {
    Toast.error('Failed to create user: $e');
  }
}
```

### Form Validation

```dart
void _validateForm() {
  if (!_formKey.currentState!.validate()) {
    Toast.warning('Please fill in all required fields');
    return;
  }
  _submitForm();
}
```

### Sync Operations

```dart
Future<void> _syncData() async {
  try {
    Toast.info('Starting sync...');
    await syncService.syncOut();
    Toast.success('Synced ${syncService.itemsSynced} items successfully');
  } catch (e) {
    Toast.error('Sync failed: $e');
  }
}
```

### API Updates

```dart
Future<void> _updateSettings() async {
  try {
    await settingsService.updateBackendUrl(url);
    Toast.success('Settings saved');
  } catch (e) {
    Toast.error('Failed to save settings');
  }
}
```

## Implementation Details

The notification system consists of three main components:

1. **NotificationService** (`lib/services/notification_service.dart`):
   - Manages the state of all active notifications
   - Provides methods to add and remove notifications
   - Handles auto-dismiss timing

2. **ToastNotificationWidget** (`lib/ui/widgets/toast_notification.dart`):
   - Renders individual notification cards
   - Handles slide-in and fade-out animations
   - Provides tap-to-dismiss functionality

3. **ToastOverlay** (`lib/ui/widgets/toast_overlay.dart`):
   - Positions notifications on the screen (left side, below app bar)
   - Manages multiple notifications in a stack
   - Integrated into the MaterialApp builder
   - Limits visible notifications to 6 max to prevent overflow
   - Scrollable if more notifications than available space

## Theming

The notifications automatically adapt to your app's theme:

- **Light mode**: Colored backgrounds with subtle borders
- **Dark mode**: Darker colored backgrounds with appropriate contrast
- **Icons**: Each notification type has a distinct icon
  - Success: ✓ Check circle (green)
  - Error: ⚠ Error icon (red)
  - Warning: ⚠ Warning icon (orange)
  - Info: ℹ Info icon (blue)

## Best Practices

1. **Be concise**: Keep messages short and actionable
2. **Use appropriate types**: Match the notification type to the message context
3. **Don't spam**: Avoid showing too many notifications at once (max 6 will be displayed)
4. **Provide context**: Include relevant details in error messages
5. **Use success sparingly**: Only for important confirmations
6. **Consider debouncing**: If an action might trigger multiple notifications, debounce them

## Migration Guide

To migrate existing code from ScaffoldMessenger:

1. Find all instances of `ScaffoldMessenger.of(context).showSnackBar`
2. Replace with appropriate `Toast.success()`, `Toast.error()`, etc.
3. Remove the `context` dependency (Toast works globally)
4. Adjust the message text if needed (remove SnackBar widget wrapper)

Example migration:

```dart
// Old code
if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Synced ${syncService.itemsSynced} items'),
      backgroundColor: Colors.green,
    ),
  );
}

// New code
Toast.success('Synced ${syncService.itemsSynced} items');
```

Note: No need to check `mounted` anymore since Toast doesn't depend on context!
