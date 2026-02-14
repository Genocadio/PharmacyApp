// Example: How to integrate BackgroundSyncManager with services
//
// This file demonstrates how to update your services to trigger
// automatic sync-out operations after data changes.

import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/services/dto/stock_in_dto.dart';
import 'package:nexxpharma/services/background_sync_manager.dart';

/// Example: StockInService with autonomous sync integration
class StockInServiceWithSync {
  final AppDatabase database;
  final BackgroundSyncManager? backgroundSyncManager;

  StockInServiceWithSync(
    this.database, {
    this.backgroundSyncManager,
  });

  /// Create a new stock-in entry and trigger sync
  Future<StockInDTO> createStockIn(StockInCreateDTO dto) async {
    // 1. Perform the database operation
    final stockIn = await _createStockInInDb(dto);

    // 2. Trigger background sync (silent, non-blocking)
    backgroundSyncManager?.triggerSyncOut(silent: true);

    return stockIn;
  }

  /// Update stock quantity and trigger sync
  Future<void> updateStockQuantity(int stockId, int newQuantity) async {
    // 1. Update in database
    await _updateStockInDb(stockId, newQuantity);

    // 2. Trigger background sync
    backgroundSyncManager?.triggerSyncOut(silent: true);
  }

  /// Delete stock and trigger sync
  Future<void> deleteStock(int stockId) async {
    // 1. Delete from database
    await _deleteStockFromDb(stockId);

    // 2. Trigger background sync
    backgroundSyncManager?.triggerSyncOut(silent: true);
  }

  // Mock implementations (replace with actual logic)
  Future<StockInDTO> _createStockInInDb(StockInCreateDTO dto) async {
    // Your actual implementation
    throw UnimplementedError();
  }

  Future<void> _updateStockInDb(int stockId, int newQuantity) async {
    // Your actual implementation
  }

  Future<void> _deleteStockFromDb(int stockId) async {
    // Your actual implementation
  }
}

/// Example: UserService with autonomous sync integration
class UserServiceWithSync {
  final AppDatabase database;
  final BackgroundSyncManager? backgroundSyncManager;

  UserServiceWithSync(
    this.database, {
    this.backgroundSyncManager,
  });

  /// Register new user and trigger sync
  Future<void> registerUser(/* params */) async {
    // 1. Create user in database
    // ... your code

    // 2. Trigger background sync
    backgroundSyncManager?.triggerSyncOut(silent: true);
  }

  /// Update user and trigger sync
  Future<void> updateUser(/* params */) async {
    // 1. Update user in database
    // ... your code

    // 2. Trigger background sync
    backgroundSyncManager?.triggerSyncOut(silent: true);
  }
}

/// Example: Accessing BackgroundSyncManager in a Screen/Widget
class ExampleScreenWithSync /* extends StatefulWidget */ {
  final BackgroundSyncManager backgroundSyncManager;

  const ExampleScreenWithSync({
    required this.backgroundSyncManager,
  });

  // In your methods:
  void onStockAdded() async {
    // ... add stock logic

    // Trigger sync with user notification
    await backgroundSyncManager.triggerSyncOut(silent: false);
  }

  void onBulkImport() async {
    // ... bulk import logic

    // Silent sync (no toast notification)
    await backgroundSyncManager.triggerSyncOut(silent: true);
  }

  // Manually trigger status check
  void refreshDeviceStatus() async {
    await backgroundSyncManager.triggerStatusCheck();
  }

  // Check sync status in UI
  void buildSyncIndicator(/* BuildContext context */) {
    if (backgroundSyncManager.isSyncingOut) {
      // Show loading indicator
    } else {
      // Show idle state
    }
  }
}

/// Example: Global access pattern (Alternative approach)
///
/// If you need to access BackgroundSyncManager from multiple places,
/// you can create a global service locator or use provider pattern.

// Using a simple service locator:
class ServiceLocator {
  static BackgroundSyncManager? _backgroundSyncManager;

  static void registerBackgroundSyncManager(BackgroundSyncManager manager) {
    _backgroundSyncManager = manager;
  }

  static BackgroundSyncManager? get backgroundSyncManager =>
      _backgroundSyncManager;
}

// Then in main.dart:
void mainExample() {
  // ... create services

  // final backgroundSyncManager = BackgroundSyncManager(...);
  // ServiceLocator.registerBackgroundSyncManager(backgroundSyncManager);

  // Now access from anywhere:
  // ServiceLocator.backgroundSyncManager?.triggerSyncOut();
}

/// Example: Conditional sync based on connectivity
class SmartSyncExample {
  final BackgroundSyncManager backgroundSyncManager;

  SmartSyncExample(this.backgroundSyncManager);

  void onCriticalDataChange() async {
    // Always try to sync, manager handles offline scenarios
    await backgroundSyncManager.triggerSyncOut(silent: false);

    // Or check connectivity first:
    if (backgroundSyncManager.connectivityService.isConnected) {
      // Online - sync immediately
      await backgroundSyncManager.triggerSyncOut(silent: false);
    } else {
      // Offline - queued automatically, show info
      // Toast.info('Changes saved. Will sync when online.');
    }
  }
}
