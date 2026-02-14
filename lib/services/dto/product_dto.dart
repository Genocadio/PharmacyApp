import 'package:nexxpharma/data/tables.dart';
import 'package:nexxpharma/services/dto/insurance_dto.dart';

/// Data Transfer Objects for Product operations

/// DTO for product response with full details and insurance links
class ProductDTO {
  final String id;
  final String name;
  final ItemType type;
  final String? description;
  final ProductMetadataDTO? metadata;
  final List<InsuranceDataDTO> insurances;

  ProductDTO({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.metadata,
    required this.insurances,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'description': description,
      'metadata': metadata?.toJson(),
      'insurances': insurances.map((i) => i.toJson()).toList(),
    };
  }

  /// Create from JSON
  factory ProductDTO.fromJson(Map<String, dynamic> json) {
    return ProductDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      type: ItemType.values.firstWhere((e) => e.name == json['type']),
      description: json['description'] as String?,
      metadata: json['metadata'] != null
          ? ProductMetadataDTO.fromJson(
              json['metadata'] as Map<String, dynamic>,
            )
          : null,
      insurances: (json['insurances'] as List)
          .map((i) => InsuranceDataDTO.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// DTO for product metadata
class ProductMetadataDTO {
  final String? sellingUnit;

  ProductMetadataDTO({this.sellingUnit});

  Map<String, dynamic> toJson() => {'sellingUnit': sellingUnit};

  factory ProductMetadataDTO.fromJson(Map<String, dynamic> json) {
    return ProductMetadataDTO(sellingUnit: json['sellingUnit'] as String?);
  }
}

/// DTO for insurance data linked to a product
class InsuranceDataDTO {
  final String code;
  final int? utilizationCount;
  final String unit;
  final double cost;
  final String authorisedLevel;
  final String mustPrescribedBy;
  final InsuranceDTO insurance;

  InsuranceDataDTO({
    required this.code,
    this.utilizationCount,
    required this.unit,
    required this.cost,
    required this.authorisedLevel,
    required this.mustPrescribedBy,
    required this.insurance,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'utilizationCount': utilizationCount,
      'unit': unit,
      'cost': cost,
      'authorisedLevel': authorisedLevel,
      'mustPrescribedBy': mustPrescribedBy,
      'insurance': insurance.toJson(),
    };
  }

  factory InsuranceDataDTO.fromJson(Map<String, dynamic> json) {
    return InsuranceDataDTO(
      code: json['code'] as String,
      utilizationCount: json['utilizationCount'] as int?,
      unit: json['unit'] as String,
      cost: (json['cost'] as num).toDouble(),
      authorisedLevel: json['authorisedLevel'] as String,
      mustPrescribedBy: json['mustPrescribedBy'] as String,
      insurance: InsuranceDTO.fromJson(
        json['insurance'] as Map<String, dynamic>,
      ),
    );
  }
}

/// DTO for creating or updating product
class ProductCreateDTO {
  final String name;
  final ItemType type;
  final String? description;
  final String? sellingUnit;

  ProductCreateDTO({
    required this.name,
    required this.type,
    this.description,
    this.sellingUnit,
  });

  /// Validate the DTO
  void validate() {
    if (name.trim().isEmpty) {
      throw ArgumentError('Product name is required');
    }
  }

  factory ProductCreateDTO.fromJson(Map<String, dynamic> json) {
    return ProductCreateDTO(
      name: json['name'] as String,
      type: ItemType.values.firstWhere((e) => e.name == json['type']),
      description: json['description'] as String?,
      sellingUnit: json['sellingUnit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.name,
      'description': description,
      'sellingUnit': sellingUnit,
    };
  }
}
