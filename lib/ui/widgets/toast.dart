import 'package:nexxpharma/services/notification_service.dart';

/// Global toast utility for easy access throughout the app
/// Similar to React Toastify's toast() function
class Toast {
  static final NotificationService _service = NotificationService();

  /// Show a success notification
  /// 
  /// Example:
  /// ```dart
  /// Toast.success('User created successfully');
  /// ```
  static void success(String message, {Duration? duration}) {
    _service.showSuccess(message, duration: duration);
  }

  /// Show an error notification
  /// 
  /// Example:
  /// ```dart
  /// Toast.error('Failed to save data');
  /// ```
  static void error(String message, {Duration? duration}) {
    _service.showError(message, duration: duration);
  }

  /// Show a warning notification
  /// 
  /// Example:
  /// ```dart
  /// Toast.warning('This action cannot be undone');
  /// ```
  static void warning(String message, {Duration? duration}) {
    _service.showWarning(message, duration: duration);
  }

  /// Show an info notification
  /// 
  /// Example:
  /// ```dart
  /// Toast.info('New update available');
  /// ```
  static void info(String message, {Duration? duration}) {
    _service.showInfo(message, duration: duration);
  }

  /// Dismiss a specific notification by ID
  static void dismiss(String id) {
    _service.dismiss(id);
  }

  /// Clear all notifications
  static void clearAll() {
    _service.clearAll();
  }
}
