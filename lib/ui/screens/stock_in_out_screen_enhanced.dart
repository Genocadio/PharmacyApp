// STOCK_IN_OUT_SCREEN ENHANCEMENTS - Integration Guide
// 
// This file documents the changes needed to integrate StockActionService
// into the existing stock_in_out_screen.dart
//
// FOLLOW THESE STEPS TO UPDATE YOUR EXISTING FILE:

// ============================================================================
// STEP 1: ADD IMPORT
// ============================================================================
// Add this import at the top with other service imports:
/*
import 'package:nexxpharma/services/stock_action_service.dart';
import 'package:nexxpharma/ui/widgets/stock_action_widgets.dart';
*/

// ============================================================================
// STEP 2: UPDATE THE StatefulWidget
// ============================================================================
// In the StockInOutScreen class constructor, add this parameter:
/*
class StockInOutScreen extends StatefulWidget {
  final AppDatabase database;
  final StockInService stockInService;
  final StockOutService stockOutService;
  final AuthService authService;
  final SettingsService settingsService;
  final SyncService syncService;
  final ActivationService activationService;
  
  // ADD THIS LINE:
  final StockActionService stockActionService;  // Add this parameter

  const StockInOutScreen({
    super.key,
    required this.database,
    required this.stockInService,
    required this.stockOutService,
    required this.authService,
    required this.settingsService,
    required this.syncService,
    required this.activationService,
    required this.stockActionService,  // Add this in const constructor
  });

  @override
  State<StockInOutScreen> createState() => _StockInOutScreenState();
}
*/

// ============================================================================
// STEP 3: ADD SERVICE REFERENCE IN STATE CLASS
// ============================================================================
// In the _StockInOutScreenState class, add this field:
/*
class _StockInOutScreenState extends State<StockInOutScreen> {
  // ... existing fields ...
  
  // ADD THESE LINES:
  late StockActionService _stockActionService;
*/

// ============================================================================
// STEP 4: INITIALIZE SERVICE IN initState
// ============================================================================
// In the initState method, add:
/*
@override
void initState() {
  super.initState();
  
  // ADD THESE LINES AT THE START:
  _stockActionService = widget.stockActionService;
  
  _loadStockIn();  // ... rest of existing code ...
  _loadStockOuts();
  // ... rest of existing initState code ...
}
*/

// ============================================================================
// STEP 5: REGISTER STOCKS AFTER LOADING
// ============================================================================
// In the _loadStockIn() method, after stocks are loaded, register them:
/*
Future<void> _loadStockIn() async {
  setState(() => _isLoading = true);
  try {
    final stockIn = await widget.stockInService.getAllStockIns();
    if (mounted) {
      setState(() {
        _allStockIn = stockIn;
        _isLoading = false;
        
        // ADD THESE LINES - Register all stocks with action service:
        for (var stock in _allStockIn) {
          _stockActionService.registerStock(
            stockId: stock.id,
            createdAt: stock.createdAt,
            isSynced: stock.isSynced ?? false,
          );
        }
      });
    }
  } catch (e) {
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading stock: $e')),
      );
    }
  }
}
*/

// ============================================================================
// STEP 6: ADD ACTION COLUMN TO DataTable
// ============================================================================
// Find the _buildStockInColumns() method and add this column:
/*
List<DataColumn> _buildStockInColumns(ThemeData theme, Color accentColor) {
  return [
    // ... existing columns ...
    
    // ADD THIS COLUMN:
    DataColumn(
      label: Text(
        'Action',
        style: TextStyle(
          color: accentColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    
    // OPTIONAL: Add Status column to show countdown
    DataColumn(
      label: Text(
        'Edit Status',
        style: TextStyle(
          color: accentColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ];
}
*/

// ============================================================================
// STEP 7: UPDATE DataRow TO INCLUDE ACTION CELLS
// ============================================================================
// Find _buildStockInDataRow() and update the cells list:
/*
DataRow _buildStockInDataRow(
  StockInDTO stock,
  ThemeData theme,
  Color accentColor,
) {
  return DataRow(
    cells: [
      // ... existing cells ...
      
      // ADD THESE CELLS AT THE END:
      
      // Action buttons cell
      DataCell(
        StockActionCell(
          stockId: stock.id,
          actionService: _stockActionService,
          accentColor: accentColor,
          onEdit: () => _handleEditStock(stock),
          onDelete: () => _handleDeleteStock(stock),
        ),
      ),
      
      // Status/countdown cell
      DataCell(
        StockActionStatus(
          stockId: stock.id,
          actionService: _stockActionService,
          accentColor: accentColor,
        ),
      ),
    ],
  );
}
*/

// ============================================================================
// STEP 8: ADD HANDLER METHODS
// ============================================================================
// Add these new methods to your _StockInOutScreenState class:
/*
Future<void> _handleEditStock(StockInDTO stock) async {
  // Check if still within edit window
  final actionInfo = _stockActionService.getActionInfo(stock.id);
  if (actionInfo == null || !actionInfo.canEdit) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This stock item cannot be edited anymore'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  // Show edit dialog
  if (!mounted) return;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Stock'),
      content: Text(
        'Edit ${stock.productName}?\n'
        'Quantity: ${stock.quantity}\n'
        'Time remaining: ${_stockActionService.getTimeRemaining(stock.id)}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Edit'),
        ),
      ],
    ),
  );

  if (result == true) {
    // Implement your edit logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit feature to be implemented')),
    );
  }
}

Future<void> _handleDeleteStock(StockInDTO stock) async {
  // Check if still within delete window
  final actionInfo = _stockActionService.getActionInfo(stock.id);
  if (actionInfo == null || !actionInfo.canDelete) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This stock item cannot be deleted anymore'),
        duration: Duration(seconds: 2),
      ),
    );
    return;
  }

  // Show delete dialog
  if (!mounted) return;
  showDialog(
    context: context,
    builder: (context) => StockActionConfirmDialog(
      title: 'Delete Stock',
      message: 'Are you sure you want to delete ${stock.productName}?\n'
          'Remaining time: ${_stockActionService.getTimeRemaining(stock.id)}',
      actionButtonLabel: 'Delete',
      accentColor: Colors.red,
      onConfirm: () async {
        Navigator.pop(context);
        
        try {
          // Call your delete service
          // await widget.stockInService.deleteStockIn(stock.id);
          
          // Remove from action tracking
          _stockActionService._actionStates.remove(stock.id);
          
          // Reload stocks
          await _loadStockIn();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Stock deleted successfully')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error deleting stock: $e')),
            );
          }
        }
      },
    ),
  );
}

// Call this when adding new stock
Future<void> _handleAddStock() async {
  // After successfully creating new stock:
  // final newStock = await widget.stockInService.createStockIn(...);
  
  // Register it immediately with action service
  // _stockActionService.registerStock(
  //   stockId: newStock.id,
  //   createdAt: newStock.createdAt,
  //   isSynced: false,
  // );
  
  // Reload to show new stock
  // await _loadStockIn();
}

// Call this when sync completes
Future<void> _handleSyncComplete() async {
  // Get all synced stock IDs
  final allStocks = await widget.stockInService.getAllStockIns();
  
  for (var stock in allStocks) {
    if (stock.isSynced ?? false) {
      // Mark as synced in action service
      _stockActionService.setSynced(stock.id, true);
    }
  }
  
  // This will automatically disable edit/delete for synced items
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Sync complete - action statuses updated')),
  );
}
*/

// ============================================================================
// STEP 9: UPDATE DISPOSAL (if needed)
// ============================================================================
// If you have a dispose() method, no need to dispose _stockActionService
// since it's managed by Main.dart. Just dispose text controllers as before.

// ============================================================================
// STEP 10: UPDATE MAIN.DAD (where StockInOutScreen is instantiated)
// ============================================================================
// In your main.dart or navigation code:
/*
// Create the service instance (singleton or scoped)
final stockActionService = StockActionService();

// Pass it to the screen
StockInOutScreen(
  database: database,
  stockInService: stockInService,
  stockOutService: stockOutService,
  authService: authService,
  settingsService: settingsService,
  syncService: syncService,
  activationService: activationService,
  stockActionService: stockActionService,  // Add this parameter
);
*/

// ============================================================================
// COMPLETE INTEGRATION EXAMPLE
// ============================================================================
/*
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/data/tables.dart';
import 'package:nexxpharma/services/stock_in_service.dart';
import 'package:nexxpharma/services/stock_out_service.dart';
import 'package:nexxpharma/services/stock_action_service.dart';  // NEW
import 'package:nexxpharma/services/dto/stock_in_dto.dart';
import 'package:nexxpharma/services/auth_service.dart';
import 'package:nexxpharma/services/settings_service.dart';
import 'package:nexxpharma/services/sync_service.dart';
import 'package:nexxpharma/services/activation_service.dart';
import 'package:nexxpharma/ui/widgets/stock_action_widgets.dart';  // NEW
import 'package:nexxpharma/ui/widgets/toast.dart';

class StockInOutScreen extends StatefulWidget {
  final AppDatabase database;
  final StockInService stockInService;
  final StockOutService stockOutService;
  final AuthService authService;
  final SettingsService settingsService;
  final SyncService syncService;
  final ActivationService activationService;
  final StockActionService stockActionService;  // NEW

  const StockInOutScreen({
    super.key,
    required this.database,
    required this.stockInService,
    required this.stockOutService,
    required this.authService,
    required this.settingsService,
    required this.syncService,
    required this.activationService,
    required this.stockActionService,  // NEW
  });

  @override
  State<StockInOutScreen> createState() => _StockInOutScreenState();
}

class _StockInOutScreenState extends State<StockInOutScreen> {
  // ... existing fields ...
  
  late StockActionService _stockActionService;  // NEW

  @override
  void initState() {
    super.initState();
    
    _stockActionService = widget.stockActionService;  // NEW
    _loadStockIn();
    // ... rest of initState ...
  }

  Future<void> _loadStockIn() async {
    setState(() => _isLoading = true);
    try {
      final stockIn = await widget.stockInService.getAllStockIns();
      if (mounted) {
        setState(() {
          _allStockIn = stockIn;
          _isLoading = false;
          
          // Register all stocks with action service  // NEW
          for (var stock in _allStockIn) {
            _stockActionService.registerStock(
              stockId: stock.id,
              createdAt: stock.createdAt,
              isSynced: stock.isSynced ?? false,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading stock: $e')),
        );
      }
    }
  }

  // ... rest of existing code ...
  
  // NEW: Add these handler methods
  Future<void> _handleEditStock(StockInDTO stock) async {
    final actionInfo = _stockActionService.getActionInfo(stock.id);
    if (actionInfo == null || !actionInfo.canEdit) {
      Toast.error('This stock cannot be edited');
      return;
    }
    // Implement edit logic
  }

  Future<void> _handleDeleteStock(StockInDTO stock) async {
    final actionInfo = _stockActionService.getActionInfo(stock.id);
    if (actionInfo == null || !actionInfo.canDelete) {
      Toast.error('This stock cannot be deleted');
      return;
    }
    // Implement delete logic
  }
}
*/

// ============================================================================
// KEY DIFFERENCES FROM BEFORE
// ============================================================================
// BEFORE: Action buttons showed "NA" with no countdown
// AFTER:  Action buttons show "Edit" / "Delete" with "1h 23m" remaining
//
// BEFORE: Had to refresh app or logout/login to see status changes
// AFTER:  UI updates automatically every 10 seconds via ChangeNotifier
//
// BEFORE: No time tracking for edit window
// AFTER:  4-hour window from stock.createdAt tracked automatically
//
// BEFORE: Could edit/delete after sync
// AFTER:  Synced items automatically marked as unavailable
//
// BEFORE: No visual feedback for action availability
// AFTER:  Buttons gray out, colored status badge, countdown timer shown

// ============================================================================
// TESTING CHECKLIST
// ============================================================================
// ✓ Stock loads with action buttons visible
// ✓ Countdown timer shows accurate time (e.g., "3h 59m")
// ✓ Time updates every 10 seconds or immediately on UI interaction
// ✓ After 4 hours, buttons become disabled and show "Expired"
// ✓ Synced items show "Not Available" and buttons are disabled
// ✓ Edit/Delete buttons trigger confirmations with time shown
// ✓ No refresh needed - UI updates automatically in background
// ✓ No logout/login needed - all state managed in service
// ✓ Multiple stocks show independent countdowns (not synchronized)
// ✓ New stocks added appear with full 4-hour window immediately

// ============================================================================
// COMMON PITFALLS TO AVOID
// ============================================================================
// ❌ NOT initializing _stockActionService in initState
// ❌ NOT registering stocks after loading from database
// ❌ Using stock.updatedAt instead of stock.createdAt for window calculation
// ❌ NOT checking canEdit/canDelete before allowing operations
// ❌ Calling setSynced(id, true) without actually syncing to server
// ❌ Forgetting to pass StockActionService in screen constructor
// ❌ Using setState() to manually refresh instead of letting ChangeNotifier handle it
// ❌ Creating multiple instances of StockActionService (use singleton in main.dart)

// ============================================================================
// TROUBLESHOOTING
// ============================================================================
// Q: Why do action buttons show "N/A"?
// A: Stock not registered. Check that _stockActionService.registerStock() is called
//    in _loadStockIn() after setState.
//
// Q: Why doesn't time update?
// A: Timer runs every 10 seconds by default. Wait 10 seconds. If still not updating,
//    ensure widgets use AnimatedBuilder or ListenableBuilder to listen for changes.
//
// Q: Why can I still edit after 4 hours?
// A: Service only checks time when getActionInfo() is called. You must check
//    canEdit/canDelete before showing edit dialog. Add validation in handlers.
//
// Q: Why do synced items still show as available?
// A: Call setSynced(stockId, true) when sync completes. If missed, edit handlers
//    won't check sync status.
//
// Q: Do I need to dispose the StockActionService?
// A: No - it's managed by your app-level service provider (main.dart). Just ensure
//    it's created once and reused throughout the app lifecycle.
