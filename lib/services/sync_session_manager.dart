import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:nexxpharma/services/sync_service.dart';
import 'package:nexxpharma/services/notification_service.dart';

/// Represents a background sync session
class SyncSession {
  final String id;
  final SyncSessionType type;
  final DateTime startedAt;
  DateTime? completedAt;
  
  // Progress tracking
  double _progress = 0.0;
  int _itemsProcessed = 0;
  int _totalItems = 0;
  String? _currentStep;
  SyncStatus? _status;
  String? _error;

  SyncSession({
    required this.id,
    required this.type,
    required this.startedAt,
  });

  double get progress => _progress;
  int get itemsProcessed => _itemsProcessed;
  int get totalItems => _totalItems;
  String? get currentStep => _currentStep;
  SyncStatus? get status => _status;
  String? get error => _error;
  bool get isComplete => completedAt != null;
  Duration get elapsedTime => (completedAt ?? DateTime.now()).difference(startedAt);

  void updateProgress({
    required double progress,
    required int itemsProcessed,
    required int totalItems,
    String? currentStep,
  }) {
    _progress = progress.clamp(0.0, 1.0);
    _itemsProcessed = itemsProcessed;
    _totalItems = totalItems;
    _currentStep = currentStep;
  }

  void markComplete(SyncStatus status, {String? error}) {
    completedAt = DateTime.now();
    _status = status;
    _error = error;
    _progress = status == SyncStatus.success ? 1.0 : _progress;
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.name,
    'startedAt': startedAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'progress': _progress,
    'itemsProcessed': _itemsProcessed,
    'totalItems': _totalItems,
    'currentStep': _currentStep,
    'status': _status?.name,
    'error': _error,
  };
}

enum SyncSessionType {
  fullSync,
  incrementalSync,
  syncOut,
  statusCheck,
}

/// Manages background sync sessions and attaches to active sessions
class SyncSessionManager extends ChangeNotifier {
  final SyncService syncService;
  final NotificationService notificationService;

  SyncSession? _activeSession;
  final List<SyncSession> _completedSessions = [];
  StreamSubscription? _syncServiceListener;

  SyncSessionManager({
    required this.syncService,
    required this.notificationService,
  }) {
    // Listen to sync service changes
    syncService.addListener(_onSyncServiceChange);
  }

  SyncSession? get activeSession => _activeSession;
  List<SyncSession> get completedSessions => List.unmodifiable(_completedSessions);
  bool get isAnySyncActive => _activeSession != null && !_activeSession!.isComplete;

  /// Start a new sync session
  Future<void> startSync({
    required SyncSessionType type,
    required Future<void> Function() syncFn,
  }) async {
    // Attach to active session if one exists
    if (_activeSession != null && !_activeSession!.isComplete) {
      if (kDebugMode) {
        print('Attaching to existing sync session: ${_activeSession!.id}');
      }
      notifyListeners();
      return;
    }

    // Create new session
    _activeSession = SyncSession(
      id: _generateSessionId(),
      type: type,
      startedAt: DateTime.now(),
    );

    if (kDebugMode) {
      print('Starting new sync session: ${_activeSession!.id} (${type.name})');
    }

    notifyListeners();

    try {
      await syncFn();
    } catch (e) {
      if (kDebugMode) {
        print('Sync session error: $e');
      }
      _activeSession?.markComplete(SyncStatus.error, error: e.toString());
      _notifyCompletion();
      rethrow;
    }
  }

  /// Perform full sync in background
  Future<void> performBackgroundFullSync() => startSync(
    type: SyncSessionType.fullSync,
    syncFn: () => syncService.performSync(),
  );

  /// Perform force full sync in background
  Future<void> performBackgroundForceFullSync() => startSync(
    type: SyncSessionType.fullSync,
    syncFn: () => syncService.forceFullSync(),
  );

  /// Perform sync out in background
  Future<void> performBackgroundSyncOut({bool fullSync = false}) => startSync(
    type: SyncSessionType.syncOut,
    syncFn: () => syncService.syncOut(fullSync: fullSync),
  );

  /// Listen to sync service changes and update active session
  void _onSyncServiceChange() {
    if (_activeSession == null) return;

    final status = syncService.status;
    final progress = syncService.progress;
    final itemsSynced = syncService.itemsSynced;

    // Calculate total items based on sync type
    int totalItems = itemsSynced;
    if (_activeSession!.type == SyncSessionType.syncOut && itemsSynced > 0) {
      totalItems = itemsSynced;
    }

    _activeSession!.updateProgress(
      progress: progress,
      itemsProcessed: itemsSynced,
      totalItems: totalItems > 0 ? totalItems : _activeSession!.totalItems,
      currentStep: _getCurrentStepName(status),
    );

    // Check if sync is complete
    if (status == SyncStatus.success || status == SyncStatus.error) {
      if (!_activeSession!.isComplete) {
        _activeSession!.markComplete(status);
        _notifyCompletion();
      }
    }

    notifyListeners();
  }

  /// Get current step name based on sync service state
  String _getCurrentStepName(SyncStatus status) {
    if (status == SyncStatus.syncing) {
      if (_activeSession!.type == SyncSessionType.fullSync) {
        return _getFullSyncStep();
      } else if (_activeSession!.type == SyncSessionType.syncOut) {
        return _getSyncOutStep();
      }
      return 'Syncing...';
    } else if (status == SyncStatus.success) {
      return 'Completed';
    } else if (status == SyncStatus.error) {
      return 'Failed';
    }
    return 'Idle';
  }

  /// Get detailed step for full sync based on progress
  String _getFullSyncStep() {
    final progress = _activeSession!.progress;
    if (progress < 0.33) {
      return 'Syncing insurances...';
    } else if (progress < 0.66) {
      return 'Syncing products...';
    } else {
      return 'Syncing product associations...';
    }
  }

  /// Get detailed step for sync out based on progress
  String _getSyncOutStep() {
    final processed = _activeSession!.itemsProcessed;
    final total = _activeSession!.totalItems;
    
    if (processed == 0) {
      return 'Preparing data...';
    } else if (processed <= total * 0.25) {
      return 'Syncing workers...';
    } else if (processed <= total * 0.5) {
      return 'Syncing stock movements...';
    } else {
      return 'Syncing sales...';
    }
  }

  /// Notify user of sync completion
  void _notifyCompletion() {
    if (_activeSession == null) return;

    final session = _activeSession!;
    final duration = session.elapsedTime;

    if (session.status == SyncStatus.success) {
      final message = session.type == SyncSessionType.syncOut
          ? 'Synced ${session.itemsProcessed} items successfully'
          : 'Sync completed successfully';
      
      notificationService.showSuccess(message);
      
      if (kDebugMode) {
        print('Sync completed: $message (${duration.inSeconds}s)');
      }
    } else if (session.status == SyncStatus.error) {
      notificationService.showError(
        'Sync failed: ${session.error ?? "Unknown error"}',
      );
      
      if (kDebugMode) {
        print('Sync failed: ${session.error}');
      }
    }

    // Archive completed session
    _completedSessions.add(session);
    if (_completedSessions.length > 10) {
      _completedSessions.removeAt(0);
    }

    _activeSession = null;
  }

  /// Generate unique session ID
  String _generateSessionId() {
    final random = Random().nextInt(999999);
    return '${DateTime.now().millisecondsSinceEpoch}_$random';
  }

  /// Get session history (for debugging)
  Map<String, dynamic> getSessionHistory() => {
    'activeSession': _activeSession?.toMap(),
    'completedSessions': _completedSessions.map((s) => s.toMap()).toList(),
  };

  @override
  void dispose() {
    syncService.removeListener(_onSyncServiceChange);
    _syncServiceListener?.cancel();
    super.dispose();
  }
}
