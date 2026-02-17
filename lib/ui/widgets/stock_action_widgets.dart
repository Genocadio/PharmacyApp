import 'package:flutter/material.dart';
import 'package:nexxpharma/services/stock_action_service.dart';

/// Widget to display action buttons with time-based availability
class StockActionCell extends StatelessWidget {
  final String stockId;
  final StockActionService actionService;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Color accentColor;
  final Color? disabledColor;

  const StockActionCell({
    super.key,
    required this.stockId,
    required this.actionService,
    this.onEdit,
    this.onDelete,
    required this.accentColor,
    this.disabledColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: actionService,
      builder: (context, _) {
        final actionInfo = actionService.getActionInfo(stockId);
        
        if (actionInfo == null) {
          return const Text('N/A');
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit button
            Tooltip(
              message: actionInfo.canEdit
                  ? 'Edit (${actionInfo.formatTimeRemaining()} remaining)'
                  : 'Edit not available - ${actionInfo.stateMessage}',
              child: IconButton(
                icon: Icon(
                  Icons.edit,
                  size: 18,
                  color: actionInfo.canEdit ? accentColor : (disabledColor ?? Colors.grey),
                ),
                onPressed: actionInfo.canEdit ? onEdit : null,
                splashRadius: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Delete button
            Tooltip(
              message: actionInfo.canDelete
                  ? 'Delete (${actionInfo.formatTimeRemaining()} remaining)'
                  : 'Delete not available - ${actionInfo.stateMessage}',
              child: IconButton(
                icon: Icon(
                  Icons.delete,
                  size: 18,
                  color: actionInfo.canDelete ? Colors.red[400] : (disabledColor ?? Colors.grey),
                ),
                onPressed: actionInfo.canDelete ? onDelete : null,
                splashRadius: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Widget to display action time status
class StockActionStatus extends StatelessWidget {
  final String stockId;
  final StockActionService actionService;
  final Color accentColor;

  const StockActionStatus({
    super.key,
    required this.stockId,
    required this.actionService,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: actionService,
      builder: (context, _) {
        final actionInfo = actionService.getActionInfo(stockId);
        
        if (actionInfo == null) {
          return const Text(
            'N/A',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          );
        }

        Color statusColor;
        String statusText;

        switch (actionInfo.state) {
          case ActionState.available:
            statusColor = Colors.green;
            statusText = 'Edit: ${actionInfo.formatTimeRemaining()}';
            break;
          case ActionState.expired:
            statusColor = Colors.orange;
            statusText = 'Expired';
            break;
          case ActionState.unavailable:
            statusColor = Colors.grey;
            statusText = 'Not Available';
            break;
        }

        return Tooltip(
          message: 'Expires at: ${actionInfo.expiresAt.toString()}',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: statusColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Widget showing compact action indicators
class StockActionIndicator extends StatelessWidget {
  final String stockId;
  final StockActionService actionService;
  final Color accentColor;

  const StockActionIndicator({
    super.key,
    required this.stockId,
    required this.actionService,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: actionService,
      builder: (context, _) {
        final actionInfo = actionService.getActionInfo(stockId);
        
        if (actionInfo == null) {
          return const SizedBox.shrink();
        }

        if (actionInfo.state == ActionState.available) {
          return Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          );
        } else if (actionInfo.state == ActionState.expired) {
          return Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Dialog to confirm action before edit/delete
class StockActionConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String actionButtonLabel;
  final VoidCallback onConfirm;
  final Color accentColor;

  const StockActionConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.actionButtonLabel,
    required this.onConfirm,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
          ),
          child: Text(actionButtonLabel),
        ),
      ],
    );
  }
}
