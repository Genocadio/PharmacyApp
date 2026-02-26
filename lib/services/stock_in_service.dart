import 'dart:convert';

import 'package:crypton/crypton.dart';
import 'package:http/http.dart' as http;
import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/data/tables.dart';
import 'package:nexxpharma/services/dto/activation_dto.dart';
import 'package:nexxpharma/services/dto/stock_in_dto.dart';
import 'package:nexxpharma/services/exceptions/service_exceptions.dart';
import 'package:nexxpharma/services/settings_service.dart';

/// Service layer for Stock In management
/// Handles business logic, validation, and DTO conversion
class StockInService {
  final AppDatabase _database;
  final SettingsService _settingsService;
  List<StockInDTO> _latestCache = const [];

  StockInService(this._database, this._settingsService);

  Future<bool> _shouldUseRemoteStock() async {
    final device = await _database.getDevice();
    return device?.supportMultiUsers ?? false;
  }

  Future<_SignedContext> _getSignedContext() async {
    final module = await _database.getModule();
    final device = await _database.getDevice();
    if (module == null || module.privateKey == null || device == null) {
      throw Exception('Device not activated. Missing device or private key.');
    }
    return _SignedContext(
      deviceId: device.deviceId,
      privateKey: RSAPrivateKey.fromPEM(module.privateKey!),
    );
  }

  String _buildSignaturePayload(String deviceId, dynamic data) {
    if (data == null) return deviceId;
    if (data is Map && data.isEmpty) return deviceId;
    if (data is List && data.isEmpty) return deviceId;
    return '$deviceId|${json.encode(data)}';
  }

  Future<Map<String, dynamic>> _signedRequest({
    required String method,
    required String path,
    Map<String, dynamic>? data,
  }) async {
    final signedContext = await _getSignedContext();
    final payload = _buildSignaturePayload(signedContext.deviceId, data ?? {});
    final signature = base64Encode(
      signedContext.privateKey.createSHA256Signature(utf8.encode(payload)),
    );

    final uri = Uri.parse('${_settingsService.backendUrl}$path');
    final requestBody = DeviceSignedRequest<Map<String, dynamic>>(
      deviceId: signedContext.deviceId,
      signature: signature,
      data: data,
    );

    late http.Response response;
    switch (method) {
      case 'POST':
        response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody.toJson((d) => d)),
        );
        break;
      case 'PUT':
        response = await http.put(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody.toJson((d) => d)),
        );
        break;
      default:
        throw Exception('Unsupported method: $method');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Stock API error ${response.statusCode}: ${response.body}');
    }

    final decoded = json.decode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected stock API response format');
    }
    await _applyApiSideEffects(decoded);
    return decoded;
  }

  Future<Map<String, dynamic>> _signedGet(String path) async {
    final signedContext = await _getSignedContext();
    final payload = _buildSignaturePayload(signedContext.deviceId, {});
    final signature = base64Encode(
      signedContext.privateKey.createSHA256Signature(utf8.encode(payload)),
    );

    final separator = path.contains('?') ? '&' : '?';
    final uri = Uri.parse(
      '${_settingsService.backendUrl}$path${separator}deviceId=${Uri.encodeQueryComponent(signedContext.deviceId)}&signature=${Uri.encodeQueryComponent(signature)}',
    );

    final response = await http.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Stock API error ${response.statusCode}: ${response.body}');
    }

    final decoded = json.decode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected stock API response format');
    }
    await _applyApiSideEffects(decoded);
    return decoded;
  }

  Future<void> _signedDelete(String path) async {
    final signedContext = await _getSignedContext();
    final payload = _buildSignaturePayload(signedContext.deviceId, {});
    final signature = base64Encode(
      signedContext.privateKey.createSHA256Signature(utf8.encode(payload)),
    );

    final separator = path.contains('?') ? '&' : '?';
    final uri = Uri.parse(
      '${_settingsService.backendUrl}$path${separator}deviceId=${Uri.encodeQueryComponent(signedContext.deviceId)}&signature=${Uri.encodeQueryComponent(signature)}',
    );

    final response = await http.delete(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Stock API error ${response.statusCode}: ${response.body}');
    }

    if (response.body.trim().isNotEmpty) {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) {
        await _applyApiSideEffects(decoded);
      }
    }
  }

  Future<void> _applyApiSideEffects(Map<String, dynamic> response) async {
    final parsed = DeviceApiResponse<void>.fromJson(response);
    if (parsed.module != null) {
      await _database.saveModule(parsed.module!);
    }
    if (parsed.status != null) {
      await _database.updateDeviceLocal(
        activationStatus: parsed.status!.isActive
            ? ActivationStatus.ACTIVE
            : ActivationStatus.INACTIVE,
        supportMultiUsers: parsed.status!.supportMultiUsers,
      );
    }
  }

  StockInDTO _parseRemoteStockIn(Map<String, dynamic> jsonMap) {
    final rawPrice = jsonMap['pricePerUnit'] as num?;
    final rawCreated = jsonMap['createdAt'] as String?;
    final rawUpdated = jsonMap['updatedAt'] as String?;
    return StockInDTO(
      id: (jsonMap['id'] ?? '').toString(),
      quantity: (jsonMap['quantity'] as num?)?.toInt() ?? 0,
      location: jsonMap['location'] as String?,
      pricePerUnit: rawPrice?.toDouble() ?? 0.0,
      batchNumber: jsonMap['batchNumber'] as String?,
      expiryDate: jsonMap['expiryDate'] != null
          ? DateTime.tryParse(jsonMap['expiryDate'].toString())
          : null,
      reorderLevel: (jsonMap['reorderLevel'] as num?)?.toInt(),
      productId: (jsonMap['productId'] ?? '').toString(),
      productName: (jsonMap['productName'] ?? '').toString(),
      userId: jsonMap['userId']?.toString(),
      userName: jsonMap['userName']?.toString(),
      createdAt: rawCreated != null
          ? DateTime.parse(rawCreated)
          : DateTime.now(),
      updatedAt: rawUpdated != null
          ? DateTime.parse(rawUpdated)
          : DateTime.now(),
    );
  }

  List<Map<String, dynamic>> _extractPageContent(dynamic data) {
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    if (data is Map<String, dynamic>) {
      final content = data['content'];
      if (content is List) {
        return content.cast<Map<String, dynamic>>();
      }
    }
    return const [];
  }

  /// Create a new stock in entry
  Future<StockInDTO> createStockIn(
    StockInCreateDTO createDTO, {
    String? userId,
  }) async {
    // Validate input
    createDTO.validate();

    if (await _shouldUseRemoteStock()) {
      final payload = {
        ...createDTO.toJson()..remove('deviceType'),
        if (userId != null) 'createdByUserId': userId,
      };
      final response = await _signedRequest(
        method: 'POST',
        path: '/api/stocks/in',
        data: payload,
      );
      final data = response['data'];
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid stock-in response payload');
      }
      final created = _parseRemoteStockIn(data);
      _latestCache = [created, ..._latestCache.where((s) => s.id != created.id)];
      return created;
    }

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

    if (await _shouldUseRemoteStock()) {
      final response = await _signedRequest(
        method: 'PUT',
        path: '/api/stocks/in',
        data: {
          'id': id,
          ...updateDTO.toJson()..remove('deviceType'),
        },
      );
      final data = response['data'];
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid stock-in response payload');
      }
      final updated = _parseRemoteStockIn(data);
      _latestCache = [updated, ..._latestCache.where((s) => s.id != updated.id)];
      return updated;
    }

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
    if (await _shouldUseRemoteStock()) {
      final response = await _signedGet('/api/stocks/in/$id');
      final data = response['data'];
      if (data is! Map<String, dynamic>) {
        throw ResourceNotFoundException('Stock In', 'id', id);
      }
      final stockIn = _parseRemoteStockIn(data);
      _latestCache = [stockIn, ..._latestCache.where((s) => s.id != stockIn.id)];
      return stockIn;
    }
    try {
      final stockIn = await _database.getStockInById(id);
      return _convertToDTO(stockIn);
    } catch (e) {
      throw ResourceNotFoundException('Stock In', 'id', id);
    }
  }

  /// Get all stock in entries
  Future<List<StockInDTO>> getAllStockIns() async {
    if (await _shouldUseRemoteStock()) {
      final all = <StockInDTO>[];
      var page = 0;
      var hasMore = true;

      while (hasMore) {
        final response = await _signedGet('/api/stocks/in?page=$page&size=200');
        final content = _extractPageContent(response['data']);
        all.addAll(content.map(_parseRemoteStockIn));

        final data = response['data'];
        if (data is Map<String, dynamic>) {
          final last = data['last'];
          final totalPages = (data['totalPages'] as num?)?.toInt();
          if (last is bool) {
            hasMore = !last;
          } else if (totalPages != null) {
            hasMore = page + 1 < totalPages;
          } else {
            hasMore = content.isNotEmpty;
          }
        } else {
          hasMore = false;
        }
        page++;
      }

      _latestCache = all;
      return all;
    }
    final stockIns = await _database.getAllStockIns();
    return Future.wait(stockIns.map((stockIn) => _convertToDTO(stockIn)));
  }

  /// Get stock in entries for a specific product
  Future<List<StockInDTO>> getStockInsByProduct(String productId) async {
    if (await _shouldUseRemoteStock()) {
      final stocks = _latestCache.isNotEmpty ? _latestCache : await getAllStockIns();
      return stocks.where((stock) => stock.productId == productId).toList();
    }
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
    if (await _shouldUseRemoteStock()) {
      final stocks = _latestCache.isNotEmpty ? _latestCache : await getAllStockIns();
      return stocks
          .where((stock) => stock.reorderLevel != null && stock.quantity <= stock.reorderLevel!)
          .toList();
    }
    final stockIns = await _database.getStockInsBelowReorderLevel();
    return Future.wait(stockIns.map((stockIn) => _convertToDTO(stockIn)));
  }

  /// Get items expiring within specified days
  Future<List<StockInDTO>> getExpiringItems(int days) async {
    if (days < 0) {
      throw ArgumentError('Days must be non-negative');
    }

    if (await _shouldUseRemoteStock()) {
      final allStockIns = _latestCache.isNotEmpty ? _latestCache : await getAllStockIns();
      final expiryDate = DateTime.now().add(Duration(days: days));
      return allStockIns.where((stockIn) {
        if (stockIn.expiryDate == null) return false;
        return stockIn.expiryDate!.isBefore(expiryDate) &&
            stockIn.expiryDate!.isAfter(DateTime.now());
      }).toList();
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
    if (await _shouldUseRemoteStock()) {
      final stockIns = await getStockInsByProduct(productId);
      return stockIns.fold<int>(0, (sum, stockIn) => sum + stockIn.quantity);
    }
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
    if (await _shouldUseRemoteStock()) {
      await _signedDelete('/api/stocks/in/$id');
      _latestCache = _latestCache.where((s) => s.id != id).toList();
      return;
    }
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

    if (await _shouldUseRemoteStock()) {
      final all = _latestCache.isNotEmpty ? _latestCache : await getAllStockIns();
      final query = searchTerm.toLowerCase();
      return all.where((s) => s.productName.toLowerCase().contains(query)).toList();
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

class _SignedContext {
  final String deviceId;
  final RSAPrivateKey privateKey;

  _SignedContext({required this.deviceId, required this.privateKey});
}
