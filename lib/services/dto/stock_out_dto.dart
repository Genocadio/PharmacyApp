import 'package:nexxpharma/data/tables.dart';

/// DTO for creating a stock out item (flexible for different device types)
class StockOutItemCreateDTO {
  final String stockInId;
  final int quantitySold;
  final double? pricePerUnit; // Optional for clinic inventory mode
  final String? insuranceId; // Only for pharmacy retail

  StockOutItemCreateDTO({
    required this.stockInId,
    required this.quantitySold,
    this.pricePerUnit,
    this.insuranceId,
  });

  /// Validate the DTO based on device type
  void validate({required DeviceType deviceType}) {
    if (stockInId.isEmpty) {
      throw ArgumentError('Stock In ID is required');
    }
    if (quantitySold < 1) {
      throw ArgumentError('Quantity sold must be at least 1');
    }
    
    // Only validate price for non-clinic inventory modes
    if (deviceType != DeviceType.CLINIC_INVENTORY) {
      if (pricePerUnit == null || pricePerUnit! <= 0) {
        throw ArgumentError('Price per unit must be greater than 0');
      }
    }
  }

  /// Create from JSON
  factory StockOutItemCreateDTO.fromJson(Map<String, dynamic> json) {
    return StockOutItemCreateDTO(
      stockInId: json['stockInId'] as String,
      quantitySold: json['quantitySold'] as int,
      pricePerUnit: (json['pricePerUnit'] as num?)?.toDouble(),
      insuranceId: json['insuranceId'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'stockInId': stockInId,
      'quantitySold': quantitySold,
      if (pricePerUnit != null) 'pricePerUnit': pricePerUnit,
      if (insuranceId != null) 'insuranceId': insuranceId,
    };
  }
}

/// DTO for creating a stock out (flexible for different device types)
class StockOutCreateDTO {
  // Common fields
  final DeviceType deviceType;
  final List<StockOutItemCreateDTO> items;
  
  // PHARMACY_RETAIL fields
  final String? patientName;
  final String? insuranceCardNumber;
  final String? issuingCompany;
  final String? prescriberName;
  final String? prescriberLicenseId;
  final String? prescribingOrganization;
  
  // PHARMACY_WHOLESALE fields
  final String? destinationPharmacyName;
  final String? destinationPharmacyPhone;
  final String? tinNumber;
  
  // CLINIC_INVENTORY fields
  final ClinicService? destinationClinicService;

  StockOutCreateDTO({
    required this.deviceType,
    required this.items,
    // Retail fields
    this.patientName,
    this.insuranceCardNumber,
    this.issuingCompany,
    this.prescriberName,
    this.prescriberLicenseId,
    this.prescribingOrganization,
    // Wholesale fields
    this.destinationPharmacyName,
    this.destinationPharmacyPhone,
    this.tinNumber,
    // Clinic fields
    this.destinationClinicService,
  });

  /// Validate the DTO based on device type
  void validate() {
    if (items.isEmpty) {
      throw ArgumentError('Transaction must contain at least one item');
    }

    // Validate each item
    for (var item in items) {
      item.validate(deviceType: deviceType);
    }

    // Device-specific validation
    switch (deviceType) {
      case DeviceType.PHARMACY_RETAIL:
        _validateRetail();
        break;
      case DeviceType.PHARMACY_WHOLESALE:
        _validateWholesale();
        break;
      case DeviceType.CLINIC_INVENTORY:
        _validateClinic();
        break;
    }
  }

  void _validateRetail() {
    if (patientName == null || patientName!.trim().isEmpty) {
      throw ArgumentError('Patient name is required');
    }

    // Check if any items use insurance
    final hasInsuranceItems = items.any((item) => item.insuranceId != null);

    if (hasInsuranceItems) {
      if (insuranceCardNumber == null || insuranceCardNumber!.trim().isEmpty) {
        throw ArgumentError(
          'Insurance card number is required when using insurance',
        );
      }
      if (issuingCompany == null || issuingCompany!.trim().isEmpty) {
        throw ArgumentError('Issuing company is required when using insurance');
      }
      if (prescriberName == null || prescriberName!.trim().isEmpty) {
        throw ArgumentError('Prescriber name is required when using insurance');
      }
      if (prescriberLicenseId == null || prescriberLicenseId!.trim().isEmpty) {
        throw ArgumentError(
          'Prescriber license ID is required when using insurance',
        );
      }
    }
  }

  void _validateWholesale() {
    if (destinationPharmacyName == null ||
        destinationPharmacyName!.trim().isEmpty) {
      throw ArgumentError('Destination pharmacy name is required');
    }
  }

  void _validateClinic() {
    if (destinationClinicService == null) {
      throw ArgumentError('Destination clinic service is required');
    }
  }

  /// Create from JSON
  factory StockOutCreateDTO.fromJson(Map<String, dynamic> json) {
    final deviceTypeStr = json['deviceType'] as String?;
    final deviceType = _parseDeviceType(deviceTypeStr ?? 'PHARMACY_RETAIL');
    
    return StockOutCreateDTO(
      deviceType: deviceType,
      patientName: json['patientName'] as String?,
      insuranceCardNumber: json['insuranceCardNumber'] as String?,
      issuingCompany: json['issuingCompany'] as String?,
      prescriberName: json['prescriberName'] as String?,
      prescriberLicenseId: json['prescriberLicenseId'] as String?,
      prescribingOrganization: json['prescribingOrganization'] as String?,
      destinationPharmacyName: json['destinationPharmacyName'] as String?,
      destinationPharmacyPhone: json['destinationPharmacyPhone'] as String?,
      tinNumber: json['tinNumber'] as String?,
      destinationClinicService: _parseClinicService(json['destinationClinicService'] as String?),
      items: (json['items'] as List)
          .map(
            (item) =>
                StockOutItemCreateDTO.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'deviceType': _deviceTypeToString(deviceType),
      'items': items.map((item) => item.toJson()).toList(),
      if (patientName != null) 'patientName': patientName,
      if (insuranceCardNumber != null) 'insuranceCardNumber': insuranceCardNumber,
      if (issuingCompany != null) 'issuingCompany': issuingCompany,
      if (prescriberName != null) 'prescriberName': prescriberName,
      if (prescriberLicenseId != null) 'prescriberLicenseId': prescriberLicenseId,
      if (prescribingOrganization != null) 'prescribingOrganization': prescribingOrganization,
      if (destinationPharmacyName != null) 'destinationPharmacyName': destinationPharmacyName,
      if (destinationPharmacyPhone != null) 'destinationPharmacyPhone': destinationPharmacyPhone,
      if (tinNumber != null) 'tinNumber': tinNumber,
      if (destinationClinicService != null) 'destinationClinicService': _clinicServiceToString(destinationClinicService),
    };
  }

  static String _deviceTypeToString(DeviceType type) {
    switch (type) {
      case DeviceType.PHARMACY_RETAIL:
        return 'PHARMACY_RETAIL';
      case DeviceType.PHARMACY_WHOLESALE:
        return 'PHARMACY_WHOLESALE';
      case DeviceType.CLINIC_INVENTORY:
        return 'CLINIC_INVENTORY';
    }
  }

  static DeviceType _parseDeviceType(String str) {
    switch (str) {
      case 'PHARMACY_WHOLESALE':
        return DeviceType.PHARMACY_WHOLESALE;
      case 'CLINIC_INVENTORY':
        return DeviceType.CLINIC_INVENTORY;
      default:
        return DeviceType.PHARMACY_RETAIL;
    }
  }

  static String? _clinicServiceToString(ClinicService? service) {
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

  static ClinicService? _parseClinicService(String? str) {
    if (str == null) return null;
    switch (str) {
      case 'DENTAL':
        return ClinicService.DENTAL;
      case 'INTERNAL_MEDICINE':
        return ClinicService.INTERNAL_MEDICINE;
      case 'LABORATORY':
        return ClinicService.LABORATORY;
      case 'SURGERY':
        return ClinicService.SURGERY;
      case 'PEDIATRICS':
        return ClinicService.PEDIATRICS;
      case 'CARDIOLOGY':
        return ClinicService.CARDIOLOGY;
      case 'ORTHOPEDICS':
        return ClinicService.ORTHOPEDICS;
      default:
        return null;
    }
  }
}

/// DTO for stock out item response
class StockOutItemDTO {
  final String id;
  final String stockInId;
  final String productName;
  final String? batchNumber;
  final String? location;
  final int quantitySold;
  final double pricePerUnit;
  final String? insuranceId;
  final String? insuranceName;
  final double itemTotal;
  final double patientPays;
  final double insurancePays;

  StockOutItemDTO({
    required this.id,
    required this.stockInId,
    required this.productName,
    this.batchNumber,
    this.location,
    required this.quantitySold,
    required this.pricePerUnit,
    this.insuranceId,
    this.insuranceName,
    required this.itemTotal,
    required this.patientPays,
    required this.insurancePays,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stockInId': stockInId,
      'productName': productName,
      'batchNumber': batchNumber,
      'location': location,
      'quantitySold': quantitySold,
      'pricePerUnit': pricePerUnit,
      'insuranceId': insuranceId,
      'insuranceName': insuranceName,
      'itemTotal': itemTotal,
      'patientPays': patientPays,
      'insurancePays': insurancePays,
    };
  }
}

/// DTO for stock out response
class StockOutDTO {
  final String id;
  final String patientName;
  final String? destinationClinicService;
  final String? insuranceCardNumber;
  final String? issuingCompany;
  final String? prescriberName;
  final String? prescriberLicenseId;
  final String? prescribingOrganization;
  final double totalPrice;
  final List<StockOutItemDTO> stockOutItems;
  final String? userId;
  final String? userName;
  final DateTime createdAt;
  final DateTime updatedAt;

  StockOutDTO({
    required this.id,
    required this.patientName,
    this.destinationClinicService,
    this.insuranceCardNumber,
    this.issuingCompany,
    this.prescriberName,
    this.prescriberLicenseId,
    this.prescribingOrganization,
    required this.totalPrice,
    required this.stockOutItems,
    this.userId,
    this.userName,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      if (destinationClinicService != null) 'destinationClinicService': destinationClinicService,
      'insuranceCardNumber': insuranceCardNumber,
      'issuingCompany': issuingCompany,
      'prescriberName': prescriberName,
      'prescriberLicenseId': prescriberLicenseId,
      'prescribingOrganization': prescribingOrganization,
      'totalPrice': totalPrice,
      'stockOutItems': stockOutItems.map((item) => item.toJson()).toList(),
      'userId': userId,
      'userName': userName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
