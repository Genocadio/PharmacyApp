import 'package:flutter/material.dart';
import 'package:nexxpharma/data/tables.dart';
import 'package:nexxpharma/services/activation_service.dart';
import 'package:nexxpharma/services/settings_service.dart';
import 'package:nexxpharma/services/sync_service.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsService settingsService;
  final SyncService syncService;
  final ActivationService activationService;

  const SettingsScreen({
    super.key,
    required this.settingsService,
    required this.syncService,
    required this.activationService,
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
  }

  @override
  void dispose() {
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

    if (widget.syncService.status == SyncStatus.error && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: ${widget.syncService.error}')),
      );
    } else if (widget.syncService.status == SyncStatus.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sync completed successfully')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Synced ${widget.syncService.itemsSynced} items successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else if (widget.syncService.status == SyncStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sync failed: ${widget.syncService.error ?? "Unknown error"}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleRecycleCode() async {
    final code = await widget.activationService.recycleModuleCode();

    if (!mounted) return;

    if (code == null || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate module code')),
      );
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Backend URL saved'),
                                  ),
                                );
                              },
                            ),
                          ),
                          onSubmitted: (value) {
                            widget.settingsService.updateBackendUrl(value);
                          },
                        ),
                        const SizedBox(height: 24),
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
              const SizedBox(height: 32),              _buildSectionHeader('Invoice Settings', theme),
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
              const SizedBox(height: 32),
              _buildSectionHeader('About', theme),
              const SizedBox(height: 8),
              _buildSettingsCard(
                theme,
                children: [
                  ListTile(
                    title: const Text('App Version'),
                    leading: Icon(Icons.info_outline, color: accentColor),
                    trailing: Text(
                      '1.0.0',
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.5,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
}
