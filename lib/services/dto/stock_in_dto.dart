/// Data Transfer Objects for Stock In operations

import 'package:nexxpharma/data/tables.dart';

/// DTO for creating or updating stock in
class StockInCreateDTO {
  final String productId;
  final int quantity;
  final String? location;
  final double pricePerUnit;
  final String? batchNumber;
  final DateTime? expiryDate;
  final int? reorderLevel;
  final DeviceType deviceType;

  StockInCreateDTO({
    required this.productId,
    required this.quantity,
    this.location,
    required this.pricePerUnit,
    this.batchNumber,
    this.expiryDate,
    this.reorderLevel,
    this.deviceType = DeviceType.PHARMACY_RETAIL,
  });

  /// Validate the DTO
  void validate() {
    if (productId.isEmpty) {
      throw ArgumentError('Product ID is required');
    }
    if (quantity < 0) {
      throw ArgumentError('Quantity must be non-negative');
    }
    if (deviceType == DeviceType.CLINIC_INVENTORY) {
      if (pricePerUnit < 0) {
        throw ArgumentError('Price per unit must be non-negative');
      }
    } else if (pricePerUnit <= 0) {
      throw ArgumentError('Price per unit must be greater than 0');
    }
    if (reorderLevel != null && reorderLevel! < 0) {
      throw ArgumentError('Reorder level must be non-negative');
    }
  }

  /// Create from JSON
  factory StockInCreateDTO.fromJson(Map<String, dynamic> json) {
    return StockInCreateDTO(
      productId: json['productId'] as String,
      quantity: json['quantity'] as int,
      location: json['location'] as String?,
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      batchNumber: json['batchNumber'] as String?,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      reorderLevel: json['reorderLevel'] as int?,
      deviceType: _parseDeviceType(json['deviceType'] as String?),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'location': location,
      'pricePerUnit': pricePerUnit,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'reorderLevel': reorderLevel,
      'deviceType': _deviceTypeToString(deviceType),
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

  static DeviceType _parseDeviceType(String? value) {
    switch (value) {
      case 'PHARMACY_WHOLESALE':
        return DeviceType.PHARMACY_WHOLESALE;
      case 'CLINIC_INVENTORY':
        return DeviceType.CLINIC_INVENTORY;
      case 'PHARMACY_RETAIL':
      default:
        return DeviceType.PHARMACY_RETAIL;
    }
  }
}

/// DTO for stock in response with product details
class StockInDTO {
  final String id;
  final int quantity;
  final String? location;
  final double pricePerUnit;
  final String? batchNumber;
  final DateTime? expiryDate;
  final int? reorderLevel;
  final String productId;
  final String productName;
  final String? userId;
  final String? userName;
  final DateTime createdAt;
  final DateTime updatedAt;

  StockInDTO({
    required this.id,
    required this.quantity,
    this.location,
    required this.pricePerUnit,
    this.batchNumber,
    this.expiryDate,
    this.reorderLevel,
    required this.productId,
    required this.productName,
    this.userId,
    this.userName,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'location': location,
      'pricePerUnit': pricePerUnit,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'reorderLevel': reorderLevel,
      'productId': productId,
      'productName': productName,
      'userId': userId,
      'userName': userName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory StockInDTO.fromJson(Map<String, dynamic> json) {
    return StockInDTO(
      id: json['id'] as String,
      quantity: json['quantity'] as int,
      location: json['location'] as String?,
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      batchNumber: json['batchNumber'] as String?,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      reorderLevel: json['reorderLevel'] as int?,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
