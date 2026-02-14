/// Data Transfer Objects for Insurance operations

/// DTO for insurance response with full details
class InsuranceDTO {
  final String id;
  final String name;
  final String acronym;
  final double clientPercentage;
  final DateTime createdAt;
  final DateTime updatedAt;

  InsuranceDTO({
    required this.id,
    required this.name,
    required this.acronym,
    required this.clientPercentage,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'acronym': acronym,
      'clientPercentage': clientPercentage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory InsuranceDTO.fromJson(Map<String, dynamic> json) {
    return InsuranceDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      acronym: json['acronym'] as String,
      clientPercentage: (json['clientPercentage'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// DTO for creating or updating insurance
class InsuranceCreateDTO {
  final String name;
  final String acronym;
  final double clientPercentage;

  InsuranceCreateDTO({
    required this.name,
    required this.acronym,
    required this.clientPercentage,
  });

  /// Validate the DTO
  void validate() {
    if (name.trim().isEmpty) {
      throw ArgumentError('Insurance name is required');
    }
    if (acronym.trim().isEmpty) {
      throw ArgumentError('Insurance acronym is required');
    }
    if (clientPercentage < 0 || clientPercentage > 100) {
      throw ArgumentError('Client percentage must be between 0 and 100');
    }
  }

  /// Create from JSON
  factory InsuranceCreateDTO.fromJson(Map<String, dynamic> json) {
    return InsuranceCreateDTO(
      name: json['name'] as String,
      acronym: json['acronym'] as String,
      clientPercentage: (json['clientPercentage'] as num).toDouble(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'acronym': acronym,
      'clientPercentage': clientPercentage,
    };
  }
}
