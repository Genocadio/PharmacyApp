import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:nexxpharma/services/activation_service.dart';
import 'package:nexxpharma/services/settings_service.dart';
import 'package:nexxpharma/services/sync_service.dart';
import 'package:nexxpharma/services/sync_session_manager.dart';
import 'package:nexxpharma/services/notification_service.dart';
import 'package:nexxpharma/ui/widgets/toast.dart';
import 'package:nexxpharma/ui/widgets/sync_widgets.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsService settingsService;
  final SyncService syncService;
  final ActivationService activationService;
  final SyncSessionManager? syncSessionManager;

  const SettingsScreen({
    super.key,
    required this.settingsService,
    required this.syncService,
    required this.activationService,
    this.syncSessionManager,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _backendUrlController;
  late SyncSessionManager _sessionManager;

  @override
  void initState() {
    super.initState();
    _backendUrlController = TextEditingController(
      text: widget.settingsService.backendUrl,
    );
    // Default to Full Sync if never synced
    _isForceFullSync = !widget.settingsService.hasCompletedInitialSync;
    
    // Use provided manager or create one
    _sessionManager = widget.syncSessionManager ?? SyncSessionManager(
      syncService: widget.syncService,
      notificationService: NotificationService(),
    );
  }

  @override
  void dispose() {
    _backendUrlController.dispose();
    // Only dispose if we created it
    if (widget.syncSessionManager == null) {
      _sessionManager.dispose();
    }
    super.dispose();
  }

  bool _isForceFullSync = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = Colors.blue[700] ?? Colors.blue;
    final isSyncing = widget.syncService.isSyncing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 28),
          // ... existing sections ...
          
          const SizedBox(height: 32),
          _buildSectionHeader('Synchronization', theme),
          const SizedBox(height: 8),
          _buildSettingsCard(
            theme,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Background sync session indicator
                    SyncSessionAttachWidget(
                      sessionManager: _sessionManager,
                      onSessionFound: () {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Attached to background sync session'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                    
                    if (kDebugMode) ...[
                      TextField(
                        controller: _backendUrlController,
                        decoration: InputDecoration(
                          labelText: 'Main Backend URL',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.cloud_outlined),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.save_outlined),
                            onPressed: () {
                              widget.settingsService.updateBackendUrl(
                                _backendUrlController.text,
                              );
                              Toast.success('Backend URL saved');
                            },
                          ),
                        ),
                        onSubmitted: (value) {
                          widget.settingsService.updateBackendUrl(value);
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Last Sync',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.5),
                                ),
                              ),
                              Text(
                                widget.settingsService.lastSyncTime != null
                                    ? '${widget.settingsService.lastSyncTime!.day}/${widget.settingsService.lastSyncTime!.month} ${widget.settingsService.lastSyncTime!.hour}:${widget.settingsService.lastSyncTime!.minute}'
                                    : 'Never',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.settingsService.hasCompletedInitialSync) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: theme.dividerColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<bool>(
                              value: _isForceFullSync,
                              icon: const Icon(Icons.arrow_drop_down),
                              underline: const SizedBox(),
                              isDense: true,
                              items: const [
                                DropdownMenuItem(
                                  value: false,
                                  child: Text(
                                    'Incremental',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: true,
                                  child: Text(
                                    'Full Sync',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                              onChanged: isSyncing
                                  ? null
                                  : (value) {
                                      if (value != null) {
                                        setState(() {
                                          _isForceFullSync = value;
                                        });
                                      }
                                    },
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        // Enhanced background sync button
                        BackgroundSyncButton(
                          sessionManager: _sessionManager,
                          syncService: widget.syncService,
                          isForceFullSync: _isForceFullSync,
                          accentColor: accentColor,
                          label: 'Sync Now',
                          onSyncComplete: () {
                            if (mounted) {
                              setState(() {});
                            }
                          },
                        ),
                      ],
                    ),
                    
                    // Sync progress widget
                    const SizedBox(height: 16),
                    SyncProgressWidget(
                      sessionManager: _sessionManager,
                      syncService: widget.syncService,
                      accentColor: accentColor,
                      onDone: () {
                        if (mounted) {
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),              _buildSectionHeader('Device Operations Sync', theme),
          const SizedBox(height: 8),
          _buildSettingsCard(
            theme,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Sync all device operations (workers, stock movements) to the backend',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: accentColor.withOpacity(0.2),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                color: accentColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Background Upload',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Operations sync runs in background',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _startBackgroundSyncOut(),
                                icon: const Icon(Icons.cloud_upload),
                                label: const Text('Upload'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _startBackgroundSyncOut() async {
    try {
      await _sessionManager.performBackgroundSyncOut(
        fullSync: _isForceFullSync,
      );
    } catch (e) {
      if (mounted) {
        Toast.error('Sync out failed: $e');
      }
    }
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    ThemeData theme, {
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(children: children),
    );
  }
}
