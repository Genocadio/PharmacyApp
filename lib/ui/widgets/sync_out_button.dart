import 'package:flutter/material.dart';
import 'package:nexxpharma/services/sync_service.dart';

/// Button and dialog for triggering device sync-out operations
class SyncOutButton extends StatelessWidget {
  final SyncService syncService;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const SyncOutButton({
    super.key,
    required this.syncService,
    this.onSuccess,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: syncService,
      builder: (context, child) {
        return FloatingActionButton.extended(
          onPressed: syncService.isSyncing
              ? null
              : () => _showSyncDialog(context),
          icon: syncService.isSyncing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.cloud_upload),
          label: Text(syncService.isSyncing ? 'Syncing...' : 'Sync Data'),
        );
      },
    );
  }

  void _showSyncDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SyncOutDialog(
        syncService: syncService,
        onSuccess: onSuccess,
        onError: onError,
      ),
    );
  }
}

class _SyncOutDialog extends StatefulWidget {
  final SyncService syncService;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const _SyncOutDialog({
    required this.syncService,
    this.onSuccess,
    this.onError,
  });

  @override
  State<_SyncOutDialog> createState() => _SyncOutDialogState();
}

class _SyncOutDialogState extends State<_SyncOutDialog> {
  bool _isFullSync = false;
  bool _didSync = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: widget.syncService,
      builder: (context, child) {
        return AlertDialog(
          title: const Text('Sync Device Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose sync type:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              RadioListTile<bool>(
                title: const Text('Incremental Sync'),
                subtitle: const Text('Only unsynchronized data'),
                value: false,
                groupValue: _isFullSync,
                onChanged: (value) {
                  setState(() => _isFullSync = value ?? false);
                },
              ),
              RadioListTile<bool>(
                title: const Text('Full Sync'),
                subtitle: const Text('Re-sync all data'),
                value: true,
                groupValue: _isFullSync,
                onChanged: (value) {
                  setState(() => _isFullSync = value ?? false);
                },
              ),
              if (widget.syncService.syncError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.syncService.syncError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ),
              if (widget.syncService.isSyncing)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        'Syncing... (${widget.syncService.itemsSynced} items)',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              if (_didSync && !widget.syncService.isSyncing)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Synced ${widget.syncService.itemsSynced} items successfully',
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            if (!widget.syncService.isSyncing)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            if (!widget.syncService.isSyncing)
              ElevatedButton(
                onPressed: () => _performSync(context),
                child: const Text('Sync'),
              ),
            if (widget.syncService.isSyncing)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Syncing...',
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _performSync(BuildContext context) async {
    final success = await widget.syncService.syncOut(fullSync: _isFullSync);

    if (mounted) {
      setState(() => _didSync = true);

      if (success) {
        widget.onSuccess?.call();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Synced ${widget.syncService.itemsSynced} items successfully',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          // Auto close after delay
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) Navigator.pop(context);
        }
      } else {
        widget.onError?.call();
      }
    }
  }
}

/// Simple sync status indicator for app bar
class SyncStatusIndicator extends StatelessWidget {
  final SyncService syncService;

  const SyncStatusIndicator({
    super.key,
    required this.syncService,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: syncService,
      builder: (context, child) {
        Color indicatorColor;
        String tooltip;

        switch (syncService.status) {
          case SyncStatus.idle:
            indicatorColor = Colors.grey;
            tooltip = 'Not syncing';
            break;
          case SyncStatus.syncing:
            indicatorColor = Colors.orange;
            tooltip = 'Syncing...';
            break;
          case SyncStatus.success:
            indicatorColor = Colors.green;
            tooltip = 'Sync successful';
            break;
          case SyncStatus.error:
            indicatorColor = Colors.red;
            tooltip = 'Sync failed';
            break;
        }

        Widget indicator;
        if (syncService.status == SyncStatus.syncing) {
          indicator = SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(indicatorColor),
              strokeWidth: 2,
            ),
          );
        } else {
          indicator = Icon(
            Icons.cloud_done,
            color: indicatorColor,
            size: 20,
          );
        }

        return Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: indicator,
          ),
        );
      },
    );
  }
}
