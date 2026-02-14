import 'package:flutter/material.dart';
import 'package:nexxpharma/services/notification_service.dart';

/// Individual toast notification widget
/// Slides in from the left side
class ToastNotificationWidget extends StatefulWidget {
  final ToastNotification notification;
  final VoidCallback onDismiss;

  const ToastNotificationWidget({
    super.key,
    required this.notification,
    required this.onDismiss,
  });

  @override
  State<ToastNotificationWidget> createState() =>
      _ToastNotificationWidgetState();
}

class _ToastNotificationWidgetState extends State<ToastNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  Color _getBackgroundColor(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    switch (widget.notification.type) {
      case ToastType.success:
        return isDark ? Colors.green.shade800 : Colors.green.shade50;
      case ToastType.error:
        return isDark ? Colors.red.shade800 : Colors.red.shade50;
      case ToastType.warning:
        return isDark ? Colors.orange.shade800 : Colors.orange.shade50;
      case ToastType.info:
        return isDark ? Colors.blue.shade800 : Colors.blue.shade50;
    }
  }

  Color _getBorderColor() {
    switch (widget.notification.type) {
      case ToastType.success:
        return Colors.green;
      case ToastType.error:
        return Colors.red;
      case ToastType.warning:
        return Colors.orange;
      case ToastType.info:
        return Colors.blue;
    }
  }

  IconData _getIcon() {
    switch (widget.notification.type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = _getBorderColor();
    final textColor = theme.brightness == Brightness.dark
        ? Colors.white
        : theme.textTheme.bodyMedium?.color ?? Colors.black87;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          constraints: const BoxConstraints(
            maxWidth: 400,
            minWidth: 300,
          ),
          decoration: BoxDecoration(
            color: _getBackgroundColor(theme),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _dismiss,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: borderColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getIcon(),
                        color: borderColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Message
                    Expanded(
                      child: Text(
                        widget.notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Close button
                    InkWell(
                      onTap: _dismiss,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: textColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
