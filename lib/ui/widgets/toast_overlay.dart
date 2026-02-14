import 'package:flutter/material.dart';
import 'package:nexxpharma/services/notification_service.dart';
import 'package:nexxpharma/ui/widgets/toast_notification.dart';

/// Overlay widget that displays all toast notifications
/// Similar to React Toastify's container
class ToastOverlay extends StatelessWidget {
  final NotificationService notificationService;
  final Widget child;

  const ToastOverlay({
    super.key,
    required this.notificationService,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main app content
        child,
        // Toast notifications overlay
        Positioned(
          left: 0,
          top: 80, // Below app bar
          bottom: 20,
          child: ListenableBuilder(
            listenable: notificationService,
            builder: (context, _) {
              final notifications = notificationService.notifications;
              
              if (notifications.isEmpty) {
                return const SizedBox.shrink();
              }

              // Limit to max 6 visible notifications to prevent overflow
              final visibleNotifications = notifications.take(6).toList();

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: visibleNotifications.map((notification) {
                    return ToastNotificationWidget(
                      key: ValueKey(notification.id),
                      notification: notification,
                      onDismiss: () {
                        notificationService.dismiss(notification.id);
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
