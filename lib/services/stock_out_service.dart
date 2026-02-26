import 'dart:convert';

import 'package:crypton/crypton.dart';
import 'package:http/http.dart' as http;
import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/data/tables.dart';
import 'package:nexxpharma/services/dto/activation_dto.dart';
import 'package:nexxpharma/services/dto/stock_out_dto.dart';
import 'package:nexxpharma/services/exceptions/service_exceptions.dart';
import 'package:nexxpharma/services/settings_service.dart';
import 'package:uuid/uuid.dart';

/// Service layer for Stock Out management
/// Handles business logic, validation, insurance calculations, and automatic stock reduction
class StockOutService {
  final AppDatabase _database;
  final SettingsService _settingsService;
  final Uuid _uuid = const Uuid();
  List<StockOutDTO> _latestCache = const [];

  StockOutService(this._database, this._settingsService);

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

  String _toStockOutMode(DeviceType type) {
    switch (type) {
      case DeviceType.PHARMACY_RETAIL:
        return 'RETAIL';
      case DeviceType.PHARMACY_WHOLESALE:
        return 'WHOLESALE';
      case DeviceType.CLINIC_INVENTORY:
        return 'CLINIC';
    }
  }

  String? _clinicServiceToString(ClinicService? service) {
    if (service == null) return null;
    switch (service) {
      case ClinicService.DENTAL:
        return 'DENTAL';
      case ClinicService.INTERNAL_MEDICINE:
        return 'INTERNAL_MEDICINE';
      case ClinicService.LABORATORY:
        return 'LABORATORY';
      case ClinicService.SURGERY:
        return 'SURGERY';
      case ClinicService.PEDIATRICS:
        return 'PEDIATRICS';
      case ClinicService.CARDIOLOGY:
        return 'CARDIOLOGY';
      case ClinicService.ORTHOPEDICS:
        return 'ORTHOPEDICS';
    }
  }

  StockOutItemDTO _parseRemoteStockOutItem(Map<String, dynamic> item) {
    return StockOutItemDTO(
      id: (item['id'] ?? item['stockOutItemId'] ?? '').toString(),
      stockInId: (item['stockInId'] ?? '').toString(),
      productName: (item['productName'] ?? 'Unknown Product').toString(),
      batchNumber: item['batchNumber']?.toString(),
      location: item['location']?.toString(),
      quantitySold: (item['quantitySold'] as num?)?.toInt() ?? 0,
      pricePerUnit: (item['pricePerUnit'] as num?)?.toDouble() ?? 0,
      insuranceId: item['insuranceId']?.toString(),
      insuranceName: item['insuranceName']?.toString(),
      itemTotal: (item['itemTotal'] as num?)?.toDouble() ?? 0,
      patientPays: (item['patientPays'] as num?)?.toDouble() ?? 0,
      insurancePays: (item['insurancePays'] as num?)?.toDouble() ?? 0,
    );
  }

  StockOutDTO _parseRemoteStockOut(Map<String, dynamic> jsonMap) {
    final itemsRaw = jsonMap['items'] ?? jsonMap['stockOutItems'];
    final items = itemsRaw is List
        ? itemsRaw
              .whereType<Map<String, dynamic>>()
              .map(_parseRemoteStockOutItem)
              .toList()
        : <StockOutItemDTO>[];

    final counterparty = jsonMap['counterpartyName']?.toString();
    final patientName =
        jsonMap['patientName']?.toString() ?? counterparty ?? 'Customer';

    return StockOutDTO(
      id: (jsonMap['id'] ?? '').toString(),
      patientName: patientName,
      destinationClinicService: jsonMap['destinationClinicService']?.toString(),
      insuranceCardNumber: jsonMap['insuranceCardNumber']?.toString(),
      issuingCompany: jsonMap['issuingCompany']?.toString(),
      prescriberName: jsonMap['prescriberName']?.toString(),
      prescriberLicenseId: jsonMap['prescriberLicenseId']?.toString(),
      prescribingOrganization: jsonMap['prescribingOrganization']?.toString(),
      totalPrice: (jsonMap['totalPrice'] as num?)?.toDouble() ??
          items.fold<double>(0, (sum, item) => sum + item.itemTotal),
      stockOutItems: items,
      userId: jsonMap['createdByUserId']?.toString() ?? jsonMap['userId']?.toString(),
      userName: jsonMap['userName']?.toString(),
      createdAt: jsonMap['createdAt'] != null
          ? DateTime.parse(jsonMap['createdAt'].toString())
          : DateTime.now(),
      updatedAt: jsonMap['updatedAt'] != null
          ? DateTime.parse(jsonMap['updatedAt'].toString())
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

  /// Create a new stock out with automatic stock reduction and insurance calculation
  Future<StockOutDTO> createStockOut(
    StockOutCreateDTO createDTO, {
    String? userId,
  }) async {
    if (await _shouldUseRemoteStock()) {
      createDTO.validate();

      final mode = _toStockOutMode(createDTO.deviceType);
      final payload = <String, dynamic>{
        'mode': mode,
        'counterpartyName': createDTO.deviceType == DeviceType.PHARMACY_RETAIL
            ? (createDTO.patientName ?? 'Walk-in Customer')
            : (createDTO.destinationPharmacyName ??
                  _clinicServiceToString(createDTO.destinationClinicService) ??
                  'Stock Out'),
        if (userId != null) 'createdByUserId': userId,
        'items': createDTO.items
            .map((item) => {
                  'stockInId': item.stockInId,
                  'quantitySold': item.quantitySold,
                  'pricePerUnit': item.pricePerUnit ?? 0,
                })
            .toList(),
      };

      if (createDTO.deviceType == DeviceType.PHARMACY_RETAIL) {
        payload.addAll({
          if (createDTO.insuranceCardNumber != null)
            'insuranceCardNumber': createDTO.insuranceCardNumber,
          if (createDTO.issuingCompany != null)
            'issuingCompany': createDTO.issuingCompany,
          if (createDTO.prescriberName != null)
            'prescriberName': createDTO.prescriberName,
          if (createDTO.prescriberLicenseId != null)
            'prescriberLicenseId': createDTO.prescriberLicenseId,
          if (createDTO.prescribingOrganization != null)
            'prescribingOrganization': createDTO.prescribingOrganization,
        });
      }
      if (createDTO.deviceType == DeviceType.PHARMACY_WHOLESALE) {
        payload.addAll({
          if (createDTO.destinationPharmacyPhone != null)
            'destinationPharmacyPhone': createDTO.destinationPharmacyPhone,
          if (createDTO.tinNumber != null) 'tinNumber': createDTO.tinNumber,
        });
      }
      if (createDTO.deviceType == DeviceType.CLINIC_INVENTORY) {
        payload.addAll({
          if (createDTO.destinationClinicService != null)
            'destinationClinicService':
                _clinicServiceToString(createDTO.destinationClinicService),
        });
      }

      final response = await _signedRequest(
        method: 'POST',
        path: '/api/stocks/out',
        data: payload,
      );
      final data = response['data'];
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid stock-out response payload');
      }
      final created = _parseRemoteStockOut(data);
      _latestCache = [created, ..._latestCache.where((s) => s.id != created.id)];
      return created;
    }

    // Validate input
    createDTO.validate();

    // Validate stock availability for all items
    await _validateStockInAvailability(createDTO.items);

    final transactionId = _uuid.v4();
    double totalPrice = 0.0;
    final createdStockOuts = <StockOut>[];
    final allowInsurance =
      createDTO.deviceType == DeviceType.PHARMACY_RETAIL;

    for (final itemDTO in createDTO.items) {
      final stockOutData = await _createStockOutItem(
        itemDTO,
        allowInsurance: allowInsurance,
      );
      createdStockOuts.add(stockOutData['stockOut'] as StockOut);
      totalPrice += stockOutData['itemTotal'] as double;
    }

    final fallbackName = createDTO.deviceType == DeviceType.PHARMACY_RETAIL
        ? 'Walk-in Customer'
        : (createDTO.deviceType == DeviceType.PHARMACY_WHOLESALE
            ? (createDTO.destinationPharmacyName ?? 'Wholesale Transaction')
            : 'Clinic Inventory');
    final resolvedPatientName =
        createDTO.patientName?.trim().isNotEmpty == true
            ? createDTO.patientName!.trim()
            : fallbackName;

    for (final stockOut in createdStockOuts) {
      await _database.createStockOutSale(
        transactionId: transactionId,
        stockOutId: stockOut.id,
        patientName: resolvedPatientName,
        totalPrice: totalPrice,
        insuranceCardNumber: createDTO.insuranceCardNumber,
        issuingCompany: createDTO.issuingCompany,
        prescriberName: createDTO.prescriberName,
        prescriberLicenseId: createDTO.prescriberLicenseId,
        prescribingOrganization: createDTO.prescribingOrganization,
        destinationClinicService: createDTO.destinationClinicService != null
            ? _clinicServiceToString(createDTO.destinationClinicService)
            : null,
        userId: userId,
      );
    }

    return _convertToDTOFromTransaction(transactionId);
  }

  /// Validate stock availability for all items
  Future<void> _validateStockInAvailability(
    List<StockOutItemCreateDTO> items,
  ) async {
    for (final item in items) {
      try {
        final stockIn = await _database.getStockInById(item.stockInId);

        if (stockIn.quantity < item.quantitySold) {
          final product = await _database.getProductById(stockIn.productId);
          throw InsufficientStockException(
            'Insufficient stock for product \'${product.name}\'. '
            'Available: ${stockIn.quantity}, Requested: ${item.quantitySold}',
          );
        }
      } catch (e) {
        if (e is InsufficientStockException) rethrow;
        throw ResourceNotFoundException('Stock In', 'id', item.stockInId);
      }
    }
  }

  /// Create a stock out item with insurance calculation and stock reduction
  Future<Map<String, dynamic>> _createStockOutItem(
    StockOutItemCreateDTO itemDTO,
    {
      required bool allowInsurance,
    }
  ) async {
    final stockIn = await _database.getStockInById(itemDTO.stockInId);
    final product = await _database.getProductById(stockIn.productId);

    final pricePerUnit = itemDTO.pricePerUnit ?? 0.0;
    final itemTotal = pricePerUnit * itemDTO.quantitySold;

    double insurancePays = 0.0;
    double patientPays = itemTotal;
    String? insuranceName;

    if (allowInsurance && itemDTO.insuranceId != null) {
      try {
        final productInsurances = await _database.getInsurancesForProduct(
          product.id,
        );
        final hasCoverage = productInsurances.any(
          (pi) => pi.insuranceId == itemDTO.insuranceId,
        );

        if (!hasCoverage) {
          throw ValidationException(
            'Product \'${product.name}\' is not covered by insurance \'${itemDTO.insuranceId}\'',
          );
        }

        final insurance = await _database.getInsuranceById(
          itemDTO.insuranceId!,
        );
        insuranceName = insurance.name;

        final insuranceCoveragePercent = 100.0 - insurance.clientPercentage;
        insurancePays = (itemTotal * insuranceCoveragePercent) / 100.0;
        patientPays = itemTotal - insurancePays;
      } catch (e) {
        if (e is ValidationException) rethrow;
        throw ResourceNotFoundException(
          'Insurance',
          'id',
          itemDTO.insuranceId!,
        );
      }
    }

    final stockOut = await _database.createStockOut(
      stockInId: itemDTO.stockInId,
      quantitySold: itemDTO.quantitySold,
      pricePerUnit: pricePerUnit,
      itemTotal: itemTotal,
      patientPays: patientPays,
      insurancePays: insurancePays,
      insuranceId: itemDTO.insuranceId,
    );

    final stockOutItemDTO = StockOutItemDTO(
      id: stockOut.id,
      stockInId: stockOut.stockInId,
      productName: product.name,
      batchNumber: stockIn.batchNumber,
      location: stockIn.location,
      quantitySold: stockOut.quantitySold,
      pricePerUnit: stockOut.pricePerUnit,
      insuranceId: stockOut.insuranceId,
      insuranceName: insuranceName,
      itemTotal: stockOut.itemTotal,
      patientPays: stockOut.patientPays,
      insurancePays: stockOut.insurancePays,
    );

    return {
      'dto': stockOutItemDTO,
      'itemTotal': itemTotal,
      'stockOut': stockOut,
    };
  }

  /// Get stock out by transaction ID with all items
  Future<StockOutDTO> getStockOutById(String transactionId) async {
    if (await _shouldUseRemoteStock()) {
      final response = await _signedGet('/api/stocks/out/$transactionId');
      final data = response['data'];
      if (data is! Map<String, dynamic>) {
        throw ResourceNotFoundException('Stock Out', 'transactionId', transactionId);
      }
      final stockOut = _parseRemoteStockOut(data);
      _latestCache = [stockOut, ..._latestCache.where((s) => s.id != stockOut.id)];
      return stockOut;
    }

    try {
      return await _convertToDTOFromTransaction(transactionId);
    } catch (e) {
      throw ResourceNotFoundException('Stock Out', 'transactionId', transactionId);
    }
  }

  /// Get all stock outs
  Future<List<StockOutDTO>> getAllStockOuts() async {
    if (await _shouldUseRemoteStock()) {
      final all = <StockOutDTO>[];
      var page = 0;
      var hasMore = true;

      while (hasMore) {
        final response = await _signedGet('/api/stocks/out?page=$page&size=200');
        final content = _extractPageContent(response['data']);
        all.addAll(content.map(_parseRemoteStockOut));

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

    final salesRows = await _database.getAllStockOutSales();
    final transactionIds = salesRows.map((row) => row.transactionId).toSet();
    return Future.wait(
      transactionIds.map((transactionId) => _convertToDTOFromTransaction(transactionId)),
    );
  }

  /// Search stock outs by patient name
  Future<List<StockOutDTO>> getStockOutsByPatient(String patientName) async {
    if (await _shouldUseRemoteStock()) {
      final all = _latestCache.isNotEmpty ? _latestCache : await getAllStockOuts();
      final query = patientName.toLowerCase();
      return all
          .where((stockOut) => stockOut.patientName.toLowerCase().contains(query))
          .toList();
    }

    final salesRows = await _database.searchStockOutSalesByPatient(patientName);
    final transactionIds = salesRows.map((row) => row.transactionId).toSet();
    return Future.wait(
      transactionIds.map((transactionId) => _convertToDTOFromTransaction(transactionId)),
    );
  }

  /// Get stock outs within date range
  Future<List<StockOutDTO>> getStockOutsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (endDate.isBefore(startDate)) {
      throw ArgumentError('End date must be after start date');
    }

    if (await _shouldUseRemoteStock()) {
      final all = _latestCache.isNotEmpty ? _latestCache : await getAllStockOuts();
      return all.where((stockOut) {
        return stockOut.createdAt.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
            stockOut.createdAt.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    }

    final salesRows = await _database.getStockOutSalesByDateRange(
      startDate,
      endDate,
    );
    final transactionIds = salesRows.map((row) => row.transactionId).toSet();
    return Future.wait(
      transactionIds.map((transactionId) => _convertToDTOFromTransaction(transactionId)),
    );
  }

  /// Get stock out report with totals
  Future<Map<String, dynamic>> getStockOutReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (await _shouldUseRemoteStock()) {
      final stockOuts = await getStockOutsByDateRange(startDate, endDate);
      final total = stockOuts.fold<double>(0, (sum, sale) => sum + sale.totalPrice);
      final insurance = stockOuts.fold<double>(
        0,
        (sum, sale) =>
            sum + sale.stockOutItems.fold<double>(0, (iSum, i) => iSum + i.insurancePays),
      );
      final patient = stockOuts.fold<double>(
        0,
        (sum, sale) =>
            sum + sale.stockOutItems.fold<double>(0, (iSum, i) => iSum + i.patientPays),
      );
      return {
        'count': stockOuts.length,
        'totalRevenue': total,
        'insuranceRevenue': insurance,
        'patientRevenue': patient,
      };
    }

    return await _database.getStockOutReport(startDate, endDate);
  }

  /// Search stock outs by product name
  Future<List<StockOutDTO>> searchByProductName(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      throw ArgumentError('Search term cannot be empty');
    }

    if (await _shouldUseRemoteStock()) {
      final all = _latestCache.isNotEmpty ? _latestCache : await getAllStockOuts();
      final query = searchTerm.toLowerCase();
      return all.where((stockOut) {
        return stockOut.stockOutItems.any(
          (item) => item.productName.toLowerCase().contains(query),
        );
      }).toList();
    }

    final query = searchTerm.toLowerCase();
    final salesRows = await _database.getAllStockOutSales();
    final transactionIds = salesRows.map((row) => row.transactionId).toSet();

    final matchingStockOuts = <StockOutDTO>[];
    for (final transactionId in transactionIds) {
      final items = await _getStockOutItemsForTransaction(transactionId);
      final hasMatchingProduct = items.any(
        (item) => item.productName.toLowerCase().contains(query),
      );
      if (hasMatchingProduct) {
        matchingStockOuts.add(
          await _convertToDTOFromTransaction(transactionId),
        );
      }
    }

    return matchingStockOuts;
  }

  /// Get stock outs filtered by insurance ID
  Future<List<StockOutDTO>> getStockOutsByInsurance(String insuranceId) async {
    if (await _shouldUseRemoteStock()) {
      final all = _latestCache.isNotEmpty ? _latestCache : await getAllStockOuts();
      return all.where((stockOut) {
        return stockOut.stockOutItems.any((item) => item.insuranceId == insuranceId);
      }).toList();
    }

    try {
      await _database.getInsuranceById(insuranceId);
    } catch (e) {
      throw ResourceNotFoundException('Insurance', 'id', insuranceId);
    }

    final salesRows = await _database.getAllStockOutSales();
    final transactionIds = salesRows.map((row) => row.transactionId).toSet();

    final matchingStockOuts = <StockOutDTO>[];
    for (final transactionId in transactionIds) {
      final items = await _getStockOutItemsForTransaction(transactionId);
      final hasInsurance = items.any((item) => item.insuranceId == insuranceId);
      if (hasInsurance) {
        matchingStockOuts.add(
          await _convertToDTOFromTransaction(transactionId),
        );
      }
    }

    return matchingStockOuts;
  }

  Future<List<StockOutItemDTO>> _getStockOutItemsForTransaction(
    String transactionId,
  ) async {
    final salesRows = await _database.getStockOutSalesByTransactionId(
      transactionId,
    );
    final stockOutItemDTOs = <StockOutItemDTO>[];

    for (final row in salesRows) {
      final stockOut = await _database.getStockOutById(row.stockOutId);
      final stockIn = await _database.getStockInById(stockOut.stockInId);
      final product = await _database.getProductById(stockIn.productId);

      String? insuranceName;
      if (stockOut.insuranceId != null) {
        try {
          final insurance = await _database.getInsuranceById(
            stockOut.insuranceId!,
          );
          insuranceName = insurance.name;
        } catch (e) {
          insuranceName = null;
        }
      }

      stockOutItemDTOs.add(
        StockOutItemDTO(
          id: stockOut.id,
          stockInId: stockOut.stockInId,
          productName: product.name,
          batchNumber: stockIn.batchNumber,
          location: stockIn.location,
          quantitySold: stockOut.quantitySold,
          pricePerUnit: stockOut.pricePerUnit,
          insuranceId: stockOut.insuranceId,
          insuranceName: insuranceName,
          itemTotal: stockOut.itemTotal,
          patientPays: stockOut.patientPays,
          insurancePays: stockOut.insurancePays,
        ),
      );
    }

    return stockOutItemDTOs;
  }

  /// Convert transaction data to DTO
  Future<StockOutDTO> _convertToDTOFromTransaction(
    String transactionId,
  ) async {
    final salesRows = await _database.getStockOutSalesByTransactionId(
      transactionId,
    );
    if (salesRows.isEmpty) {
      throw ResourceNotFoundException('Stock Out', 'transactionId', transactionId);
    }

    salesRows.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final primary = salesRows.first;

    final stockOutItems = await _getStockOutItemsForTransaction(transactionId);

    String? userName;
    if (primary.userId != null) {
      try {
        final user = await _database.getUserById(primary.userId!);
        userName = user.names;
      } catch (e) {
        userName = 'Unknown';
      }
    }

    return StockOutDTO(
      id: transactionId,
      patientName: primary.patientName,
      destinationClinicService: primary.destinationClinicService,
      insuranceCardNumber: primary.insuranceCardNumber,
      issuingCompany: primary.issuingCompany,
      prescriberName: primary.prescriberName,
      prescriberLicenseId: primary.prescriberLicenseId,
      prescribingOrganization: primary.prescribingOrganization,
      totalPrice: primary.totalPrice,
      stockOutItems: stockOutItems,
      userId: primary.userId,
      userName: userName,
      createdAt: primary.createdAt,
      updatedAt: primary.updatedAt,
    );
  }
}

class _SignedContext {
  final String deviceId;
  final RSAPrivateKey privateKey;

  _SignedContext({required this.deviceId, required this.privateKey});
}
