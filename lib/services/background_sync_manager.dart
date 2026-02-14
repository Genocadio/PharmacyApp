import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:nexxpharma/services/sync_service.dart';
import 'package:nexxpharma/services/activation_service.dart';
import 'package:nexxpharma/services/connectivity_service.dart';
import 'package:nexxpharma/services/settings_service.dart';
import 'package:nexxpharma/ui/widgets/toast.dart';

/// Manages autonomous background syncing and status checks
class BackgroundSyncManager extends ChangeNotifier {
  final SyncService syncService;
  final ActivationService activationService;
  final ConnectivityService connectivityService;
  final SettingsService settingsService;

  Timer? _statusCheckTimer;
  Timer? _syncOutCheckTimer;
  bool _isInitialized = false;
  bool _isSyncingOut = false;
  bool _isCheckingStatus = false;
  DateTime? _lastStatusCheck;
  DateTime? _nextScheduledStatusCheck;

  BackgroundSyncManager({
    required this.syncService,
    required this.activationService,
    required this.connectivityService,
    required this.settingsService,
  }) {
    // Listen to connectivity changes
    connectivityService.addListener(_onConnectivityChange);
  }

  bool get isInitialized => _isInitialized;
  bool get isSyncingOut => _isSyncingOut;
  bool get isCheckingStatus => _isCheckingStatus;
  DateTime? get lastStatusCheck => _lastStatusCheck;
  DateTime? get nextScheduledStatusCheck => _nextScheduledStatusCheck;

  /// Initialize the background sync manager
  /// Should be called after successful activation
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (kDebugMode) {
      print('Initializing BackgroundSyncManager...');
    }

    _isInitialized = true;

    // Perform initial operations
    await _performInitialOperations();

    // Start periodic status checks (every 2 hours)
    _startPeriodicStatusChecks();

    // Start periodic sync-out checks (every 5 minutes)
    _startPeriodicSyncOutChecks();

    notifyListeners();
  }

  /// Perform initial operations on app launch
  Future<void> _performInitialOperations() async {
    // 1. Check initial sync status
    if (!settingsService.hasCompletedInitialSync) {
      if (kDebugMode) {
        print('Initial sync not completed. Will perform when possible.');
      }
      
      // Try to perform initial sync if online
      if (connectivityService.isConnected) {
        await _performInitialSyncIn();
      }
    }

    // 2. Perform status check on launch
    if (connectivityService.isConnected) {
      await _performStatusCheck(isInitial: true);
    }

    // 3. Try to sync out any pending data
    if (connectivityService.isConnected) {
      await _performSyncOut(silent: true);
    }
  }

  /// Perform initial sync-in
  Future<void> _performInitialSyncIn() async {
    if (kDebugMode) {
      print('Performing initial sync-in...');
    }

    try {
      await syncService.performSync();
      
      if (syncService.status == SyncStatus.success) {
        await settingsService.setInitialSyncCompleted(true);
        Toast.success('Initial data sync completed');
        
        if (kDebugMode) {
          print('Initial sync-in completed successfully');
        }
      } else {
        if (kDebugMode) {
          print('Initial sync-in failed: ${syncService.error}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during initial sync-in: $e');
      }
    }
  }

  /// Perform status check with device signature
  Future<void> _performStatusCheck({bool isInitial = false}) async {
    if (_isCheckingStatus) return;
    if (!connectivityService.isConnected) return;

    _isCheckingStatus = true;
    _lastStatusCheck = DateTime.now();
    notifyListeners();

    try {
      await activationService.updateDeviceStatus();
      
      if (kDebugMode) {
        print('Status check completed at $_lastStatusCheck');
      }

      // Schedule next check
      _nextScheduledStatusCheck = DateTime.now().add(const Duration(hours: 2));
    } catch (e) {
      if (kDebugMode) {
        print('Error during status check: $e');
      }
    } finally {
      _isCheckingStatus = false;
      notifyListeners();
    }
  }

  /// Perform sync-out silently
  Future<void> _performSyncOut({bool silent = true}) async {
    if (_isSyncingOut) return;
    if (!connectivityService.isConnected) {
      if (kDebugMode) {
        print('Sync-out skipped: No internet connection');
      }
      return;
    }

    _isSyncingOut = true;
    notifyListeners();

    try {
      final success = await syncService.syncOut(fullSync: false);
      
      if (success && syncService.itemsSynced > 0) {
        if (!silent) {
          Toast.success('Synced ${syncService.itemsSynced} items');
        }
        
        if (kDebugMode) {
          print('Sync-out completed: ${syncService.itemsSynced} items synced');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during sync-out: $e');
      }
    } finally {
      _isSyncingOut = false;
      notifyListeners();
    }
  }

  /// Called when connectivity changes
  void _onConnectivityChange() {
    if (connectivityService.isConnected) {
      if (kDebugMode) {
        print('Connectivity restored. Triggering pending operations...');
      }

      // When internet comes back:
      // 1. Check if initial sync is needed
      if (!settingsService.hasCompletedInitialSync) {
        _performInitialSyncIn();
      }

      // 2. Perform a status check immediately
      _performStatusCheck();

      // 3. Try to sync out pending data
      _performSyncOut(silent: true);
    }
  }

  /// Start periodic status checks (every 2 hours)
  void _startPeriodicStatusChecks() {
    _statusCheckTimer?.cancel();
    
    _statusCheckTimer = Timer.periodic(const Duration(hours: 2), (_) {
      if (connectivityService.isConnected) {
        _performStatusCheck();
      } else {
        if (kDebugMode) {
          print('Status check skipped: No internet connection');
        }
      }
    });

    // Set next scheduled check
    _nextScheduledStatusCheck = DateTime.now().add(const Duration(hours: 2));
  }

  /// Start periodic sync-out checks (every 5 minutes)
  void _startPeriodicSyncOutChecks() {
    _syncOutCheckTimer?.cancel();
    
    _syncOutCheckTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (connectivityService.isConnected) {
        _performSyncOut(silent: true);
      }
    });
  }

  /// Manually trigger sync-out (e.g., after stock addition/removal)
  Future<void> triggerSyncOut({bool silent = false}) async {
    if (connectivityService.isConnected) {
      await _performSyncOut(silent: silent);
    } else {
      if (kDebugMode) {
        print('Sync-out queued: Will sync when internet is available');
      }
      
      if (!silent) {
        Toast.info('Changes saved. Will sync when online.');
      }
    }
  }

  /// Manually trigger status check
  Future<void> triggerStatusCheck() async {
    if (connectivityService.isConnected) {
      await _performStatusCheck();
    }
  }

  /// Stop all background operations
  void stop() {
    _statusCheckTimer?.cancel();
    _syncOutCheckTimer?.cancel();
    _isInitialized = false;
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    connectivityService.removeListener(_onConnectivityChange);
    super.dispose();
  }
}
