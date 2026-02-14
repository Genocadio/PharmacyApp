import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/data/tables.dart';
import 'package:nexxpharma/services/dto/stock_out_dto.dart';
import 'package:nexxpharma/services/exceptions/service_exceptions.dart';
import 'package:uuid/uuid.dart';

/// Service layer for Stock Out management
/// Handles business logic, validation, insurance calculations, and automatic stock reduction
class StockOutService {
  final AppDatabase _database;
  final Uuid _uuid = const Uuid();

  StockOutService(this._database);

  /// Create a new stock out with automatic stock reduction and insurance calculation
  Future<StockOutDTO> createStockOut(
    StockOutCreateDTO createDTO, {
    String? userId,
  }) async {
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

  /// Convert ClinicService enum to string for storage
  String _clinicServiceToString(ClinicService? service) {
    if (service == null) return '';
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
    try {
      return await _convertToDTOFromTransaction(transactionId);
    } catch (e) {
      throw ResourceNotFoundException('Stock Out', 'transactionId', transactionId);
    }
  }

  /// Get all stock outs
  Future<List<StockOutDTO>> getAllStockOuts() async {
    final salesRows = await _database.getAllStockOutSales();
    final transactionIds = salesRows.map((row) => row.transactionId).toSet();
    return Future.wait(
      transactionIds.map((transactionId) => _convertToDTOFromTransaction(transactionId)),
    );
  }

  /// Search stock outs by patient name
  Future<List<StockOutDTO>> getStockOutsByPatient(String patientName) async {
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
    return await _database.getStockOutReport(startDate, endDate);
  }

  /// Search stock outs by product name
  Future<List<StockOutDTO>> searchByProductName(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      throw ArgumentError('Search term cannot be empty');
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
