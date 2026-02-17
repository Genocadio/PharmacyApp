import 'package:flutter/material.dart';
import 'package:nexxpharma/services/sync_session_manager.dart';
import 'package:nexxpharma/services/sync_service.dart';

/// Enhanced sync progress widget with background session support
class SyncProgressWidget extends StatelessWidget {
  final SyncSessionManager sessionManager;
  final SyncService syncService;
  final VoidCallback onDone;
  final Color accentColor;

  const SyncProgressWidget({
    super.key,
    required this.sessionManager,
    required this.syncService,
    required this.onDone,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([sessionManager, syncService]),
      builder: (context, _) {
        final session = sessionManager.activeSession;
        final isSyncing = sessionManager.isAnySyncActive;

        if (!isSyncing) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentColor.withOpacity(0.3)),
            color: accentColor.withOpacity(0.05),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(accentColor),
                      value: session!.progress < 1.0 ? session.progress : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getSyncTitle(session.type),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        if (session.currentStep != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            session.currentStep!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    '${(session.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: session.progress,
                  backgroundColor: accentColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(accentColor),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    session.itemsProcessed > 0
                        ? '${session.itemsProcessed}/${session.totalItems} items'
                        : 'Preparing...',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    _formatDuration(session.elapsedTime),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getSyncTitle(SyncSessionType type) {
    switch (type) {
      case SyncSessionType.fullSync:
        return 'Full Sync in Progress';
      case SyncSessionType.incrementalSync:
        return 'Incremental Sync in Progress';
      case SyncSessionType.syncOut:
        return 'Uploading Operations';
      case SyncSessionType.statusCheck:
        return 'Checking Status';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    }
  }
}

/// Enhanced sync button with background capability
class BackgroundSyncButton extends StatelessWidget {
  final SyncSessionManager sessionManager;
  final SyncService syncService;
  final bool isForceFullSync;
  final Color accentColor;
  final String label;
  final VoidCallback? onSyncComplete;

  const BackgroundSyncButton({
    super.key,
    required this.sessionManager,
    required this.syncService,
    required this.isForceFullSync,
    required this.accentColor,
    this.label = 'Sync Now',
    this.onSyncComplete,
  });

  Future<void> _startBackgroundSync() async {
    if (isForceFullSync) {
      await sessionManager.performBackgroundForceFullSync();
    } else {
      await sessionManager.performBackgroundFullSync();
    }
    onSyncComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([sessionManager, syncService]),
      builder: (context, _) {
        final isSyncing = sessionManager.isAnySyncActive;
        final session = sessionManager.activeSession;

        return ElevatedButton.icon(
          onPressed: isSyncing ? null : _startBackgroundSync,
          icon: isSyncing
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      isSyncing ? Colors.white : accentColor,
                    ),
                  ),
                )
              : const Icon(Icons.sync),
          label: Text(
            isSyncing
                ? 'Syncing (${(session?.progress ?? 0 * 100).toInt()}%)'
                : label,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: accentColor.withOpacity(0.5),
          ),
        );
      },
    );
  }
}

/// Widget to attach to existing sync session
class SyncSessionAttachWidget extends StatelessWidget {
  final SyncSessionManager sessionManager;
  final VoidCallback onSessionFound;

  const SyncSessionAttachWidget({
    super.key,
    required this.sessionManager,
    required this.onSessionFound,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sessionManager,
      builder: (context, _) {
        if (sessionManager.isAnySyncActive) {
          // Auto-attach to existing session
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onSessionFound();
          });
        }
        return const SizedBox.shrink();
      },
    );
  }
}
