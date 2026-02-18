import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:nexxpharma/data/tables.dart';
import 'package:nexxpharma/services/activation_service.dart';
import 'package:nexxpharma/services/auth_service.dart';
import 'package:nexxpharma/services/auto_update_service.dart';
import 'package:nexxpharma/services/settings_service.dart';
import 'package:nexxpharma/services/sync_service.dart';
import 'package:nexxpharma/ui/widgets/toast.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsService settingsService;
  final SyncService syncService;
  final ActivationService activationService;
  final AuthService authService;

  const SettingsScreen({
    super.key,
    required this.settingsService,
    required this.syncService,
    required this.activationService,
    required this.authService,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _backendUrlController;

  @override
  void initState() {
    super.initState();
    _backendUrlController = TextEditingController(
      text: widget.settingsService.backendUrl,
    );
    // Default to Full Sync if never synced
    _isForceFullSync = !widget.settingsService.hasCompletedInitialSync;
    
    // Listen for device configuration changes
    widget.settingsService.addListener(_onSettingsChanged);
    widget.activationService.addListener(_onActivationChanged);
    widget.authService.addListener(_onAuthChanged);
  }

  /// Called when device type, device role, or other settings change
  void _onSettingsChanged() {
    if (mounted) {
      setState(() {
        // Rebuild UI with new settings
      });
    }
  }

  /// Called when activation status or module subtype changes
  void _onActivationChanged() {
    if (mounted) {
      setState(() {
        // Rebuild UI with new activation status
      });
    }
  }

  /// Called when authentication state changes (e.g., session expires)
  void _onAuthChanged() {
    if (mounted && !widget.authService.isAuthenticated) {
      // Session expired, return to root (which will show login screen)
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    // Clean up listeners to prevent memory leaks
    widget.settingsService.removeListener(_onSettingsChanged);
    widget.activationService.removeListener(_onActivationChanged);
    widget.authService.removeListener(_onAuthChanged);
    
    _backendUrlController.dispose();
    super.dispose();
  }

  bool _isForceFullSync = false;

  void _handleSync() async {
    if (_isForceFullSync) {
      await widget.syncService.forceFullSync();
    } else {
      await widget.syncService.performSync();
    }

    if (widget.syncService.status == SyncStatus.error) {
      Toast.error('Sync failed: ${widget.syncService.error}');
    } else if (widget.syncService.status == SyncStatus.success) {
      Toast.success('Sync completed successfully');
      // Reset to incremental after successful full sync
      if (_isForceFullSync) {
        setState(() {
          _isForceFullSync = false;
        });
      }
    }
  }

  Future<void> _handleSyncOut() async {
    await widget.syncService.syncOut(fullSync: _isForceFullSync);

    if (!mounted) return;

    if (widget.syncService.status == SyncStatus.success) {
      Toast.success(
        'Synced ${widget.syncService.itemsSynced} items successfully',
      );
    } else if (widget.syncService.status == SyncStatus.error) {
      Toast.error(
        'Sync failed: ${widget.syncService.error ?? "Unknown error"}',
      );
    }
  }

  Future<void> _handleRecycleCode() async {
    final code = await widget.activationService.recycleModuleCode();

    if (!mounted) return;

    if (code == null || code.isEmpty) {
      Toast.error('Failed to generate module code');
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Module Code'),
        content: SelectableText(code),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Update activity when building to keep session alive
    widget.authService.updateActivity();
    
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListenableBuilder(
        listenable: Listenable.merge([
          widget.settingsService,
          widget.syncService,
        ]),
        builder: (context, child) {
          final isSyncing = widget.syncService.status == SyncStatus.syncing;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildSectionHeader('Appearance', theme),
              const SizedBox(height: 8),
              _buildSettingsCard(
                theme,
                children: [
                  RadioListTile<ThemeMode>(
                    title: const Text('Light'),
                    secondary: Icon(
                      Icons.light_mode_outlined,
                      color: accentColor,
                    ),
                    value: ThemeMode.light,
                    groupValue: widget.settingsService.themeMode,
                    activeColor: accentColor,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        widget.settingsService.updateThemeMode(value);
                      }
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<ThemeMode>(
                    title: const Text('Dark'),
                    secondary: Icon(
                      Icons.dark_mode_outlined,
                      color: accentColor,
                    ),
                    value: ThemeMode.dark,
                    groupValue: widget.settingsService.themeMode,
                    activeColor: accentColor,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        widget.settingsService.updateThemeMode(value);
                      }
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<ThemeMode>(
                    title: const Text('System Default'),
                    secondary: Icon(
                      Icons.settings_brightness_outlined,
                      color: accentColor,
                    ),
                    value: ThemeMode.system,
                    groupValue: widget.settingsService.themeMode,
                    activeColor: accentColor,
                    onChanged: (ThemeMode? value) {
                      if (value != null) {
                        widget.settingsService.updateThemeMode(value);
                      }
                    },
                  ),
                ],
              ),
              if (widget.settingsService.deviceRole == DeviceRole.ADMIN) ...[
                const SizedBox(height: 32),
                _buildSectionHeader('Administration', theme),
                const SizedBox(height: 8),
                _buildSettingsCard(
                  theme,
                  children: [
                    ListTile(
                      title: const Text('Generate New Module Code'),
                      subtitle: const Text('Recycles the module code'),
                      leading: Icon(
                        Icons.qr_code_2_outlined,
                        color: accentColor,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: accentColor,
                      ),
                      onTap: _handleRecycleCode,
                    ),
                  ],
                ),
              ],
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
                            if (widget
                                .settingsService
                                .hasCompletedInitialSync) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
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
                            ElevatedButton.icon(
                              onPressed: isSyncing ? null : _handleSync,
                              icon: isSyncing
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Icon(Icons.sync),
                              label: Text(
                                isSyncing ? 'Syncing...' : 'Sync Now',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (isSyncing) ...[
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: widget.syncService.progress,
                              backgroundColor: accentColor.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation(accentColor),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              '${(widget.syncService.progress * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ],
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Device Data Sync',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Upload device operations to backend',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: theme.textTheme.bodySmall
                                                ?.color
                                                ?.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ListenableBuilder(
                                listenable: widget.syncService,
                                builder: (context, child) {
                                  final isSyncing =
                                      widget.syncService.status ==
                                          SyncStatus.syncing;
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Sync Type:',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: theme
                                                    .textTheme.bodyMedium
                                                    ?.color
                                                    ?.withOpacity(0.5),
                                              ),
                                            ),
                                            Container(
                                              margin:
                                                  const EdgeInsets.only(top: 4),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: theme.dividerColor,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: DropdownButton<bool>(
                                                value: _isForceFullSync,
                                                icon: const Icon(
                                                  Icons.arrow_drop_down,
                                                ),
                                                underline: const SizedBox(),
                                                isDense: true,
                                                items: const [
                                                  DropdownMenuItem(
                                                    value: false,
                                                    child: Text(
                                                      'Incremental',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: true,
                                                    child: Text(
                                                      'Full Sync',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                onChanged: isSyncing
                                                    ? null
                                                    : (value) {
                                                        if (value != null) {
                                                          setState(() {
                                                            _isForceFullSync =
                                                                value;
                                                          });
                                                        }
                                                      },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      ElevatedButton.icon(
                                        onPressed: isSyncing
                                            ? null
                                            : () => _handleSyncOut(),
                                        icon: isSyncing
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation(
                                                    Colors.white,
                                                  ),
                                                ),
                                              )
                                            : const Icon(Icons.cloud_upload),
                                        label: Text(
                                          isSyncing
                                              ? 'Syncing...'
                                              : 'Sync Now',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: accentColor,
                                          foregroundColor:
                                              theme.colorScheme.onPrimary,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              if (widget.syncService.status ==
                                  SyncStatus.syncing) ...[
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value:
                                        widget.syncService.progress.isFinite
                                            ? widget.syncService.progress
                                            : 0.0,
                                    backgroundColor: accentColor
                                        .withOpacity(0.1),
                                    valueColor: AlwaysStoppedAnimation(
                                      accentColor,
                                    ),
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                              if (widget.syncService.status ==
                                  SyncStatus.success) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    border: Border.all(
                                      color: Colors.green,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Synced ${widget.syncService.itemsSynced} items successfully',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                              if (widget.syncService.status ==
                                  SyncStatus.error) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    border: Border.all(
                                      color: Colors.red,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Sync failed: ${widget.syncService.error ?? "Unknown error"}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (widget.settingsService.deviceType != DeviceType.CLINIC_INVENTORY) ...[
                const SizedBox(height: 32),
                _buildSectionHeader('Invoice Settings', theme),
                const SizedBox(height: 8),
                _buildSettingsCard(
                  theme,
                  children: [
                    RadioListTile<InvoicePaperSize>(
                      title: const Text('A4 (Standard)'),
                      subtitle: const Text('Full-page invoice'),
                      secondary: Icon(
                        Icons.description_outlined,
                        color: accentColor,
                      ),
                      value: InvoicePaperSize.a4,
                      groupValue: widget.settingsService.invoicePaperSize,
                      activeColor: accentColor,
                      onChanged: (InvoicePaperSize? value) {
                        if (value != null) {
                          widget.settingsService.updateInvoicePaperSize(value);
                        }
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<InvoicePaperSize>(
                      title: const Text('80mm (Receipt)'),
                      subtitle: const Text('Thermal printer receipt'),
                      secondary: Icon(
                        Icons.receipt_long_outlined,
                        color: accentColor,
                      ),
                      value: InvoicePaperSize.mm80,
                      groupValue: widget.settingsService.invoicePaperSize,
                      activeColor: accentColor,
                      onChanged: (InvoicePaperSize? value) {
                        if (value != null) {
                          widget.settingsService.updateInvoicePaperSize(value);
                        }
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<InvoicePaperSize>(
                      title: const Text('57mm (Compact Receipt)'),
                      subtitle: const Text('Compact thermal printer'),
                      secondary: Icon(Icons.receipt_outlined, color: accentColor),
                      value: InvoicePaperSize.mm57,
                      groupValue: widget.settingsService.invoicePaperSize,
                      activeColor: accentColor,
                      onChanged: (InvoicePaperSize? value) {
                        if (value != null) {
                          widget.settingsService.updateInvoicePaperSize(value);
                        }
                      },
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 32),
              _buildSectionHeader('About', theme),
              const SizedBox(height: 8),
              _buildSettingsCard(
                theme,
                children: [
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      final version = snapshot.data?.version ?? 'Loading...';
                      final buildNumber = snapshot.data?.buildNumber ?? '';
                      final versionText = buildNumber.isNotEmpty 
                          ? '$version+$buildNumber' 
                          : version;
                      
                      return ListTile(
                        title: const Text('App Version'),
                        leading: Icon(Icons.info_outline, color: accentColor),
                        trailing: Text(
                          versionText,
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(
                              0.5,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                  if (Platform.isWindows) ..._buildUpdateSection(theme, accentColor),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary.withOpacity(0.7),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(ThemeData theme, {required List<Widget> children}) {
    return Card(
      elevation: 0,
      color: theme.brightness == Brightness.light
          ? Colors.white
          : Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(children: children),
    );
  }

  List<Widget> _buildUpdateSection(ThemeData theme, Color accentColor) {
    return [
      const Divider(height: 1),
      // Manual check button and status (auto-update checks every 5 hours in background)
      ListenableBuilder(
        listenable: AutoUpdateService(),
        builder: (context, _) {
          final updateService = AutoUpdateService();
          final status = updateService.status;
          final isUpdateAvailable = updateService.isUpdateAvailable;
          final lastCheck = updateService.lastCheckTime;
          final lastCheckStr = lastCheck != null
              ? 'Last checked: ${_formatLastCheckTime(lastCheck)}'
              : 'Never checked';

          return ListTile(
            title: Text(
              isUpdateAvailable ? 'Update Available' : 'Check for Updates',
            ),
            subtitle: _buildUpdateSubtitle(status, updateService, lastCheckStr),
            leading: Icon(
              _getUpdateIcon(status),
              color: isUpdateAvailable ? Colors.orange : accentColor,
            ),
            trailing: _buildUpdateTrailing(status, updateService, accentColor),
            onTap: () => _handleUpdateTap(status, updateService),
          );
        },
      ),
    ];
  }

  String _formatLastCheckTime(DateTime lastCheck) {
    final now = DateTime.now();
    final difference = now.difference(lastCheck);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget? _buildUpdateSubtitle(UpdateStatus status, AutoUpdateService service, String lastCheckStr) {
    switch (status) {
      case UpdateStatus.checking:
        return const Text('Checking for updates...');
      case UpdateStatus.available:
        return Text(
          'Version ${service.latestRelease?.version} is available',
          style: const TextStyle(color: Colors.orange),
        );
      case UpdateStatus.downloading:
        return LinearProgressIndicator(
          value: service.downloadProgress,
          backgroundColor: Colors.grey.shade300,
        );
      case UpdateStatus.readyToInstall:
        return const Text('Update ready to install');
      case UpdateStatus.installing:
        return const Text('Installing update...');
      case UpdateStatus.upToDate:
        return Text('You are on the latest version • $lastCheckStr');
      case UpdateStatus.error:
        return Text(
          service.errorMessage ?? 'Update check failed',
          style: const TextStyle(color: Colors.red),
        );
      case UpdateStatus.noConnection:
        return Text('No internet connection • $lastCheckStr');
    }
  }

  IconData _getUpdateIcon(UpdateStatus status) {
    switch (status) {
      case UpdateStatus.checking:
        return Icons.refresh;
      case UpdateStatus.available:
        return Icons.system_update;
      case UpdateStatus.downloading:
        return Icons.download;
      case UpdateStatus.readyToInstall:
        return Icons.check_circle;
      case UpdateStatus.installing:
        return Icons.hourglass_empty;
      case UpdateStatus.upToDate:
        return Icons.check_circle_outline;
      case UpdateStatus.error:
        return Icons.error_outline;
      case UpdateStatus.noConnection:
        return Icons.cloud_off;
    }
  }

  Widget? _buildUpdateTrailing(
    UpdateStatus status,
    AutoUpdateService service,
    Color accentColor,
  ) {
    switch (status) {
      case UpdateStatus.checking:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case UpdateStatus.available:
        return TextButton(
          onPressed: () => _downloadUpdate(service),
          child: const Text('Download'),
        );
      case UpdateStatus.downloading:
        return Text(
          '${(service.downloadProgress * 100).toInt()}%',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: accentColor,
          ),
        );
      case UpdateStatus.readyToInstall:
        return TextButton(
          onPressed: () => _installUpdate(service),
          child: const Text('Install'),
        );
      case UpdateStatus.installing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      default:
        return null;
    }
  }

  void _handleUpdateTap(UpdateStatus status, AutoUpdateService service) {
    if (status == UpdateStatus.upToDate ||
        status == UpdateStatus.error ||
        status == UpdateStatus.noConnection) {
      // Check for updates
      service.checkForUpdates();
    } else if (status == UpdateStatus.available) {
      // Download update
      _downloadUpdate(service);
    } else if (status == UpdateStatus.readyToInstall) {
      // Install update
      _installUpdate(service);
    }
  }

  Future<void> _downloadUpdate(AutoUpdateService service) async {
    final success = await service.downloadUpdate();
    if (mounted) {
      if (success) {
        Toast.success('Update downloaded successfully');
      } else {
        Toast.error('Failed to download update');
      }
    }
  }

  Future<void> _installUpdate(AutoUpdateService service) async {
    if (!mounted) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Install Update'),
        content: const Text(
          'The application will close and restart to install the update. '
          'Make sure all your work is saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Install'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      service.installUpdate();
    }
  }
}
