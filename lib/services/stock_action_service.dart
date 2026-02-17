import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:nexxpharma/services/dto/stock_in_dto.dart';

/// Represents the state of an action (Edit/Delete capability)
enum ActionState {
  available,     // Within 4 hour window
  expired,       // Beyond 4 hour window
  unavailable,   // Never performs action (e.g., synced items)
}

/// Holds action information for a stock item
class StockActionInfo {
  final String stockId;
  final DateTime createdAt;
  bool isSynced;
  ActionState _state;
  Duration _timeRemaining;

  StockActionInfo({
    required this.stockId,
    required this.createdAt,
    required this.isSynced,
  })  : _state = ActionState.unavailable,
        _timeRemaining = Duration.zero {
    _updateState();
  }

  ActionState get state => _state;
  Duration get timeRemaining => _timeRemaining;
  DateTime get expiresAt => createdAt.add(const Duration(hours: 4));
  bool get canEdit => _state == ActionState.available && !isSynced;
  bool get canDelete => _state == ActionState.available && !isSynced;
  String get stateMessage {
    switch (_state) {
      case ActionState.available:
        return 'Available';
      case ActionState.expired:
        return 'Expired';
      case ActionState.unavailable:
        return 'Not Available';
    }
  }

  /// Update the state based on current time
  void _updateState() {
    if (isSynced) {
      _state = ActionState.unavailable;
      _timeRemaining = Duration.zero;
      return;
    }

    final now = DateTime.now();
    final expiresAt = createdAt.add(const Duration(hours: 4));

    if (now.isBefore(expiresAt)) {
      _state = ActionState.available;
      _timeRemaining = expiresAt.difference(now);
    } else {
      _state = ActionState.expired;
      _timeRemaining = Duration.zero;
    }
  }

  /// Refresh state (call periodically or on time changes)
  void refresh() {
    _updateState();
  }

  /// Format time remaining as human-readable string
  String formatTimeRemaining() {
    if (_state != ActionState.available) {
      return stateMessage;
    }

    final hours = _timeRemaining.inHours;
    final minutes = _timeRemaining.inMinutes % 60;

    if (hours > 0) {
      return '$hours h $minutes m';
    } else {
      return '$minutes m';
    }
  }
}

/// Service to manage stock action states with real-time updates
class StockActionService extends ChangeNotifier {
  final Map<String, StockActionInfo> _actionStates = {};
  Timer? _updateTimer;
  
  // Callbacks for UI refresh
  void Function(String)? onActionStateChanged;

  StockActionService() {
    _startPeriodicUpdates();
  }

  /// Register a stock item for action tracking
  void registerStock({
    required String stockId,
    required DateTime createdAt,
    required bool isSynced,
  }) {
    _actionStates[stockId] = StockActionInfo(
      stockId: stockId,
      createdAt: createdAt,
      isSynced: isSynced,
    );
    notifyListeners();
  }

  /// Update sync status for a stock item
  void setSynced(String stockId, bool synced) {
    if (_actionStates.containsKey(stockId)) {
      _actionStates[stockId]!.isSynced = synced;
      _actionStates[stockId]!.refresh();
      notifyListeners();
      onActionStateChanged?.call(stockId);
    }
  }

  /// Get action state for a stock item
  StockActionInfo? getActionInfo(String stockId) {
    return _actionStates[stockId];
  }

  /// Check if edit is allowed
  bool canEdit(String stockId) {
    return _actionStates[stockId]?.canEdit ?? false;
  }

  /// Check if delete is allowed
  bool canDelete(String stockId) {
    return _actionStates[stockId]?.canDelete ?? false;
  }

  /// Get formatted time remaining
  String getTimeRemaining(String stockId) {
    return _actionStates[stockId]?.formatTimeRemaining() ?? 'N/A';
  }

  /// Get expiration time
  DateTime? getExpiresAt(String stockId) {
    return _actionStates[stockId]?.expiresAt;
  }

  /// Register multiple stocks
  void registerStocks(List<StockInDTO> stocks, {bool isSynced = false}) {
    for (var stock in stocks) {
      registerStock(
        stockId: stock.id,
        createdAt: stock.createdAt,
        isSynced: isSynced,
      );
    }
  }

  /// Clear all registrations
  void clear() {
    _actionStates.clear();
    notifyListeners();
  }

  /// Start periodic updates to refresh time remaining
  void _startPeriodicUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(
      const Duration(seconds: 10), // Update every 10 seconds
      (_) {
        bool hasChanges = false;
        
        for (var actionInfo in _actionStates.values) {
          final oldState = actionInfo.state;
          actionInfo.refresh();
          
          if (oldState != actionInfo.state) {
            hasChanges = true;
            onActionStateChanged?.call(actionInfo.stockId);
          }
        }
        
        if (hasChanges) {
          notifyListeners();
        }
      },
    );
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}
