import 'package:nexxpharma/data/database.dart';

/// Represents a single stock-in entry with metadata for UI display
class StockEntryView {
  final String id;
  final String productId;
  final String productName;
  final int availableQuantity;
  final double? pricePerUnit;
  final String? batchNumber;
  final String? location;
  final DateTime? expiryDate;
  final DateTime createdAt;

  bool get isExpiredOrExpiringSoon {
    if (expiryDate == null) return false;
    final today = DateTime.now();
    return expiryDate!.isBefore(today);
  }

  bool get expiringWithin30Days {
    if (expiryDate == null) return false;
    final today = DateTime.now();
    final thirtyDaysFromNow = today.add(const Duration(days: 30));
    return expiryDate!.isBefore(thirtyDaysFromNow) &&
        !isExpiredOrExpiringSoon;
  }

  int get daysUntilExpiry {
    if (expiryDate == null) return 99999;
    final today = DateTime.now();
    return expiryDate!.difference(today).inDays;
  }

  StockEntryView({
    required this.id,
    required this.productId,
    required this.productName,
    required this.availableQuantity,
    required this.pricePerUnit,
    required this.batchNumber,
    required this.location,
    required this.expiryDate,
    required this.createdAt,
  });

  factory StockEntryView.fromStockIn(StockIn stockIn, String productName) {
    return StockEntryView(
      id: stockIn.id,
      productId: stockIn.productId,
      productName: productName,
      availableQuantity: stockIn.quantity,
      pricePerUnit: stockIn.pricePerUnit,
      batchNumber: stockIn.batchNumber,
      location: stockIn.location,
      expiryDate: stockIn.expiryDate,
      createdAt: stockIn.createdAt,
    );
  }
}

/// Represents a product with multiple stock entries grouped for UI display
class ProductStockGroup {
  final String productId;
  final String productName;
  final List<StockEntryView> entries;

  int get totalAvailableQuantity =>
      entries.fold(0, (sum, entry) => sum + entry.availableQuantity);

  /// Get entries sorted by FEFO (First Expired First Out)
  /// Priority: expired → expiring soon → oldest batch creation
  List<StockEntryView> get fefoSortedEntries {
    final sorted = [...entries];
    sorted.sort((a, b) {
      // Priority 1: Expired entries first
      if (a.isExpiredOrExpiringSoon && !b.isExpiredOrExpiringSoon) return -1;
      if (!a.isExpiredOrExpiringSoon && b.isExpiredOrExpiringSoon) return 1;

      // Priority 2: Expiring within 30 days
      if (a.expiringWithin30Days && !b.expiringWithin30Days) return -1;
      if (!a.expiringWithin30Days && b.expiringWithin30Days) return 1;

      // Priority 3: Earliest expiry date first
      if (a.expiryDate != null && b.expiryDate != null) {
        return a.expiryDate!.compareTo(b.expiryDate!);
      }

      // Priority 4: Oldest batch creation (FIFO fallback)
      return a.createdAt.compareTo(b.createdAt);
    });
    return sorted;
  }

  ProductStockGroup({
    required this.productId,
    required this.productName,
    required this.entries,
  });
}

/// Represents a selected stock entry with quantity allocation
class SelectedStockAllocation {
  final String stockInId;
  final int quantityToAllocate;
  final StockEntryView entry;

  SelectedStockAllocation({
    required this.stockInId,
    required this.quantityToAllocate,
    required this.entry,
  });
}

/// Represents the result of auto-selecting and allocating stock using FEFO
class StockAllocationResult {
  final String productId;
  final String productName;
  final int requestedQuantity;
  final int totalAllocated;
  final List<SelectedStockAllocation> allocations;
  final String? warningMessage;

  bool get isFullyAllocated => totalAllocated == requestedQuantity;

  bool get isPartiallyAllocated =>
      totalAllocated > 0 && !isFullyAllocated;

  bool get isNotAllocated => totalAllocated == 0;

  StockAllocationResult({
    required this.productId,
    required this.productName,
    required this.requestedQuantity,
    required this.allocations,
    this.warningMessage,
  }) : totalAllocated = allocations.fold(
      0, (sum, a) => sum + a.quantityToAllocate);
}

/// Exception thrown when stock allocation fails
class StockAllocationException implements Exception {
  final String message;
  final StockAllocationResult? partialResult;

  StockAllocationException(this.message, {this.partialResult});

  @override
  String toString() => 'StockAllocationException: $message';
}
