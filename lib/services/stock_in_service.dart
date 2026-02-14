import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/services/dto/stock_in_dto.dart';
import 'package:nexxpharma/services/exceptions/service_exceptions.dart';

/// Service layer for Stock In management
/// Handles business logic, validation, and DTO conversion
class StockInService {
  final AppDatabase _database;

  StockInService(this._database);

  /// Create a new stock in entry
  Future<StockInDTO> createStockIn(
    StockInCreateDTO createDTO, {
    String? userId,
  }) async {
    // Validate input
    createDTO.validate();

    // Verify product exists
    try {
      await _database.getProductById(createDTO.productId);
    } catch (e) {
      throw ResourceNotFoundException('Product', 'id', createDTO.productId);
    }

    // Create stock in database
    final stockIn = await _database.createStockIn(
      productId: createDTO.productId,
      quantity: createDTO.quantity,
      location: createDTO.location,
      pricePerUnit: createDTO.pricePerUnit,
      batchNumber: createDTO.batchNumber,
      expiryDate: createDTO.expiryDate,
      reorderLevel: createDTO.reorderLevel,
      userId: userId,
    );

    // Convert to DTO
    return _convertToDTO(stockIn);
  }

  // ... (keeping updateStock, getStockById, etc. same until _convertToDTO)

  /// Update existing stock in entry
  Future<StockInDTO> updateStockIn(
    String id,
    StockInCreateDTO updateDTO,
  ) async {
    // Validate input
    updateDTO.validate();

    // Verify stock exists
    try {
      await _database.getStockInById(id);
    } catch (e) {
      throw ResourceNotFoundException('Stock In', 'id', id);
    }

    // Verify product exists if being changed
    try {
      await _database.getProductById(updateDTO.productId);
    } catch (e) {
      throw ResourceNotFoundException('Product', 'id', updateDTO.productId);
    }

    // Update stock
    final success = await _database.updateStockIn(
      id: id,
      quantity: updateDTO.quantity,
      location: updateDTO.location,
      pricePerUnit: updateDTO.pricePerUnit,
      batchNumber: updateDTO.batchNumber,
      expiryDate: updateDTO.expiryDate,
      reorderLevel: updateDTO.reorderLevel,
    );

    if (!success) {
      throw Exception('Failed to update stock');
    }

    // Get updated stock
    final stockIn = await _database.getStockInById(id);
    return _convertToDTO(stockIn);
  }

  /// Get stock in entry by ID
  Future<StockInDTO> getStockInById(String id) async {
    try {
      final stockIn = await _database.getStockInById(id);
      return _convertToDTO(stockIn);
    } catch (e) {
      throw ResourceNotFoundException('Stock In', 'id', id);
    }
  }

  /// Get all stock in entries
  Future<List<StockInDTO>> getAllStockIns() async {
    final stockIns = await _database.getAllStockIns();
    return Future.wait(stockIns.map((stockIn) => _convertToDTO(stockIn)));
  }

  /// Get stock in entries for a specific product
  Future<List<StockInDTO>> getStockInsByProduct(String productId) async {
    // Verify product exists
    try {
      await _database.getProductById(productId);
    } catch (e) {
      throw ResourceNotFoundException('Product', 'id', productId);
    }

    final stockIns = await _database.getStockInsByProduct(productId);
    return Future.wait(stockIns.map((stockIn) => _convertToDTO(stockIn)));
  }

  /// Get stock in entries below reorder level
  Future<List<StockInDTO>> getLowStockInItems() async {
    final stockIns = await _database.getStockInsBelowReorderLevel();
    return Future.wait(stockIns.map((stockIn) => _convertToDTO(stockIn)));
  }

  /// Get items expiring within specified days
  Future<List<StockInDTO>> getExpiringItems(int days) async {
    if (days < 0) {
      throw ArgumentError('Days must be non-negative');
    }

    final allStockIns = await _database.getAllStockIns();
    final expiryDate = DateTime.now().add(Duration(days: days));

    final expiringStockIns = allStockIns.where((stockIn) {
      if (stockIn.expiryDate == null) return false;
      return stockIn.expiryDate!.isBefore(expiryDate) &&
          stockIn.expiryDate!.isAfter(DateTime.now());
    }).toList();

    return Future.wait(
      expiringStockIns.map((stockIn) => _convertToDTO(stockIn)),
    );
  }

  /// Get total quantity for a product across all stock entries
  Future<int> getTotalQuantityByProduct(String productId) async {
    // Verify product exists
    try {
      await _database.getProductById(productId);
    } catch (e) {
      throw ResourceNotFoundException('Product', 'id', productId);
    }

    final stockIns = await _database.getStockInsByProduct(productId);
    return stockIns.fold<int>(0, (sum, stockIn) => sum + stockIn.quantity);
  }

  /// Delete stock in entry
  Future<void> deleteStockIn(String id) async {
    // Verify stock exists
    try {
      await _database.getStockInById(id);
    } catch (e) {
      throw ResourceNotFoundException('Stock In', 'id', id);
    }

    await _database.deleteStockIn(id);
  }

  /// Search stock by product name
  Future<List<StockInDTO>> searchByProductName(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      throw ArgumentError('Search term cannot be empty');
    }

    // Get all stocks
    final allStockIns = await _database.getAllStockIns();

    // Filter by product name
    final matchingStockIns = <StockInDTO>[];
    for (final stockIn in allStockIns) {
      final product = await _database.getProductById(stockIn.productId);
      if (product.name.toLowerCase().contains(searchTerm.toLowerCase())) {
        matchingStockIns.add(await _convertToDTO(stockIn));
      }
    }

    return matchingStockIns;
  }

  /// Convert database entity to DTO
  Future<StockInDTO> _convertToDTO(StockIn stockIn) async {
    // Get product details
    final product = await _database.getProductById(stockIn.productId);

    // Get user details if userId exists
    String? userName;
    if (stockIn.userId != null) {
      try {
        final user = await _database.getUserById(stockIn.userId!);
        userName =
            user.names; // Assuming 'names' is the name field in User entity
      } catch (e) {
        // User might be deleted or not found, just ignore
        userName = 'Unknown';
      }
    }

    return StockInDTO(
      id: stockIn.id,
      quantity: stockIn.quantity,
      location: stockIn.location,
      pricePerUnit: stockIn.pricePerUnit ?? 0.0,
      batchNumber: stockIn.batchNumber,
      expiryDate: stockIn.expiryDate,
      reorderLevel: stockIn.reorderLevel,
      productId: stockIn.productId,
      productName: product.name,
      userId: stockIn.userId,
      userName: userName,
      createdAt: stockIn.createdAt,
      updatedAt: stockIn.updatedAt,
    );
  }
}
