/// Service for intelligent stock selection with FEFO algorithm
import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/services/dto/stock_selection_dto.dart';

class StockSelectionService {
  final AppDatabase _database;

  StockSelectionService(this._database);

  /// Get all unique products with their stock entries grouped
  Future<List<ProductStockGroup>> getAllProductsGrouped() async {
    final allStocks = await _database.getAllStockIns();
    final groupedByProduct = <String, List<StockIn>>{};

    for (final stock in allStocks) {
      if (!groupedByProduct.containsKey(stock.productId)) {
        groupedByProduct[stock.productId] = [];
      }
      groupedByProduct[stock.productId]!.add(stock);
    }

    final productGroups = <ProductStockGroup>[];
    for (final entry in groupedByProduct.entries) {
      try {
        final product = await _database.getProductById(entry.key);
        final views = entry.value
            .map((stock) => StockEntryView.fromStockIn(stock, product.name))
            .toList();

        productGroups.add(
          ProductStockGroup(
            productId: entry.key,
            productName: product.name,
            entries: views,
          ),
        );
      } catch (e) {
        // Skip products that can't be loaded
        continue;
      }
    }

    return productGroups;
  }

  /// Get stock entries for a specific product, sorted by FEFO
  Future<ProductStockGroup> getProductStockGroup(String productId) async {
    final stocks = await _database.getStockInsByProduct(productId);

    try {
      final product = await _database.getProductById(productId);
      final entries = stocks
          .map((stock) => StockEntryView.fromStockIn(stock, product.name))
          .toList();

      return ProductStockGroup(
        productId: productId,
        productName: product.name,
        entries: entries,
      );
    } catch (e) {
      throw Exception('Failed to load product or stock entries: $e');
    }
  }

  /// Auto-allocate stock using FEFO algorithm
  /// Automatically distributes quantity across multiple stock entries
  Future<StockAllocationResult> autoAllocateStock(
    String productId,
    int requestedQuantity,
  ) async {
    if (requestedQuantity < 1) {
      throw ArgumentError('Requested quantity must be at least 1');
    }

    final productGroup = await getProductStockGroup(productId);

    if (productGroup.entries.isEmpty) {
      throw StockAllocationException(
        'No stock available for product: ${productGroup.productName}',
      );
    }

    if (productGroup.totalAvailableQuantity < requestedQuantity) {
      throw StockAllocationException(
        'Insufficient total stock for product: ${productGroup.productName}. '
        'Available: ${productGroup.totalAvailableQuantity}, '
        'Requested: $requestedQuantity',
      );
    }

    final allocations = <SelectedStockAllocation>[];
    var remainingQty = requestedQuantity;

    // Allocate using FEFO sorted order
    for (final entry in productGroup.fefoSortedEntries) {
      if (remainingQty <= 0) break;

      final allocateQty = remainingQty > entry.availableQuantity
          ? entry.availableQuantity
          : remainingQty;

      allocations.add(
        SelectedStockAllocation(
          stockInId: entry.id,
          quantityToAllocate: allocateQty,
          entry: entry,
        ),
      );

      remainingQty -= allocateQty;
    }

    // Check if we have expired stock allocations
    final hasExpiredAllocations =
        allocations.any((a) => a.entry.isExpiredOrExpiringSoon);

    return StockAllocationResult(
      productId: productId,
      productName: productGroup.productName,
      requestedQuantity: requestedQuantity,
      allocations: allocations,
      warningMessage: hasExpiredAllocations
          ? 'Warning: Some allocated stock is expired or expiring soon'
          : null,
    );
  }

  /// Allocate stock to a specific entry (user override FEFO)
  /// Only uses the specified stock entry, fails if insufficient
  Future<StockAllocationResult> allocateToSpecificStock(
    String productId,
    String stockInId,
    int requestedQuantity,
  ) async {
    if (requestedQuantity < 1) {
      throw ArgumentError('Requested quantity must be at least 1');
    }

    final productGroup = await getProductStockGroup(productId);
    final entry =
        productGroup.entries.firstWhere(
          (e) => e.id == stockInId,
          orElse: () =>
              throw Exception('Stock entry not found: $stockInId'),
        );

    if (entry.availableQuantity < requestedQuantity) {
      throw StockAllocationException(
        'Insufficient stock for specific entry. '
        'Available: ${entry.availableQuantity}, '
        'Requested: $requestedQuantity',
      );
    }

    return StockAllocationResult(
      productId: productId,
      productName: productGroup.productName,
      requestedQuantity: requestedQuantity,
      allocations: [
        SelectedStockAllocation(
          stockInId: stockInId,
          quantityToAllocate: requestedQuantity,
          entry: entry,
        ),
      ],
      warningMessage: entry.isExpiredOrExpiringSoon
          ? 'Warning: This stock batch is expired or expiring soon'
          : null,
    );
  }

  /// Search products by name, returning unique products with stock grouped
  Future<List<ProductStockGroup>> searchProductsByName(String query) async {
    if (query.trim().isEmpty) {
      return getAllProductsGrouped();
    }

    final allGroups = await getAllProductsGrouped();
    final searchQuery = query.toLowerCase();

    return allGroups
        .where((group) =>
            group.productName.toLowerCase().contains(searchQuery))
        .toList();
  }
}
