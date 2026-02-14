import 'package:flutter/material.dart';

enum ToastType {
  success,
  error,
  warning,
  info,
}

class ToastNotification {
  final String id;
  final String message;
  final ToastType type;
  final Duration duration;
  final DateTime createdAt;

  ToastNotification({
    required this.id,
    required this.message,
    required this.type,
    this.duration = const Duration(seconds: 4),
  }) : createdAt = DateTime.now();
}

/// Service to manage toast notifications globally
/// Similar to React Toastify
class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<ToastNotification> _notifications = [];
  List<ToastNotification> get notifications => List.unmodifiable(_notifications);

  /// Show a success toast
  void showSuccess(String message, {Duration? duration}) {
    _addNotification(
      message: message,
      type: ToastType.success,
      duration: duration,
    );
  }

  /// Show an error toast
  void showError(String message, {Duration? duration}) {
    _addNotification(
      message: message,
      type: ToastType.error,
      duration: duration,
    );
  }

  /// Show a warning toast
  void showWarning(String message, {Duration? duration}) {
    _addNotification(
      message: message,
      type: ToastType.warning,
      duration: duration,
    );
  }

  /// Show an info toast
  void showInfo(String message, {Duration? duration}) {
    _addNotification(
      message: message,
      type: ToastType.info,
      duration: duration,
    );
  }

  /// Add a notification to the list
  void _addNotification({
    required String message,
    required ToastType type,
    Duration? duration,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final notification = ToastNotification(
      id: id,
      message: message,
      type: type,
      duration: duration ?? const Duration(seconds: 4),
    );

    _notifications.add(notification);
    notifyListeners();

    // Auto-dismiss after duration
    Future.delayed(notification.duration, () {
      dismiss(id);
    });
  }

  /// Dismiss a notification by ID
  void dismiss(String id) {
    _notifications.removeWhere((notification) => notification.id == id);
    notifyListeners();
  }

  /// Clear all notifications
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}
