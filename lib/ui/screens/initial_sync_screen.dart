import 'package:flutter/material.dart';
import 'package:nexxpharma/services/sync_service.dart';

class InitialSyncScreen extends StatefulWidget {
  final SyncService syncService;

  const InitialSyncScreen({super.key, required this.syncService});

  @override
  State<InitialSyncScreen> createState() => _InitialSyncScreenState();
}

class _InitialSyncScreenState extends State<InitialSyncScreen> {
  @override
  void initState() {
    super.initState();
    // Start sync immediately after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSync();
    });
  }

  void _startSync() {
    if (widget.syncService.status != SyncStatus.syncing) {
      widget.syncService.forceFullSync();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: widget.syncService,
        builder: (context, child) {
          final status = widget.syncService.status;
          final error = widget.syncService.error;
          final progress = widget.syncService.progress;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (status == SyncStatus.syncing) ...[
                    const SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Setting up your pharmacy...',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Downloading initial data. Please do not close the app.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    LinearProgressIndicator(value: progress),
                    const SizedBox(height: 8),
                    Text('${(progress * 100).toInt()}%'),
                  ] else if (status == SyncStatus.error) ...[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Setup Failed',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      error ?? 'An unknown error occurred during sync.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _startSync,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry Setup'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
