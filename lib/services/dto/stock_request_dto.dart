import 'package:nexxpharma/data/tables.dart';

/// DTO for a stock request item
class StockRequestItemDTO {
  final String id;
  final String requestId;
  final String productId;
  final String productName;
  final int quantityRequested;
  final String? notes;

  StockRequestItemDTO({
    required this.id,
    required this.requestId,
    required this.productId,
    required this.productName,
    required this.quantityRequested,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'requestId': requestId,
    'productId': productId,
    'productName': productName,
    'quantityRequested': quantityRequested,
    'notes': notes,
  };

  factory StockRequestItemDTO.fromJson(Map<String, dynamic> json) {
    return StockRequestItemDTO(
      id: json['id'] as String,
      requestId: json['requestId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantityRequested: json['quantityRequested'] as int,
      notes: json['notes'] as String?,
    );
  }
}

/// DTO for a complete stock request with items
class StockRequestDTO {
  final String id;
  final String userId;
  final String userName;
  final String requestNumber;
  final DateTime requestDate;
  final DateTime? neededByDate;
  final StockRequestStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? submittedAt;
  final DateTime? receivedAt;
  final List<StockRequestItemDTO> items;

  StockRequestDTO({
    required this.id,
    required this.userId,
    required this.userName,
    required this.requestNumber,
    required this.requestDate,
    this.neededByDate,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.submittedAt,
    this.receivedAt,
    required this.items,
  });

  int get totalItems => items.length;
  int get totalQuantity =>
      items.fold(0, (sum, item) => sum + item.quantityRequested);

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'requestNumber': requestNumber,
    'requestDate': requestDate.toIso8601String(),
    'neededByDate': neededByDate?.toIso8601String(),
    'status': status.name,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'submittedAt': submittedAt?.toIso8601String(),
    'receivedAt': receivedAt?.toIso8601String(),
    'items': items.map((item) => item.toJson()).toList(),
  };

  factory StockRequestDTO.fromJson(Map<String, dynamic> json) {
    return StockRequestDTO(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      requestNumber: json['requestNumber'] as String,
      requestDate: DateTime.parse(json['requestDate'] as String),
      neededByDate: json['neededByDate'] != null
          ? DateTime.parse(json['neededByDate'] as String)
          : null,
      status: StockRequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String)
          : null,
      receivedAt: json['receivedAt'] != null
          ? DateTime.parse(json['receivedAt'] as String)
          : null,
      items: (json['items'] as List)
          .map((item) => StockRequestItemDTO.fromJson(item))
          .toList(),
    );
  }
}

/// DTO for creating a new stock request
class StockRequestCreateDTO {
  final DateTime requestDate;
  final DateTime? neededByDate;
  final String? notes;
  final List<StockRequestItemCreateDTO> items;

  StockRequestCreateDTO({
    required this.requestDate,
    this.neededByDate,
    this.notes,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'requestDate': requestDate.toIso8601String(),
    'neededByDate': neededByDate?.toIso8601String(),
    'notes': notes,
    'items': items.map((item) => item.toJson()).toList(),
  };
}

/// DTO for creating a stock request item
class StockRequestItemCreateDTO {
  final String productId;
  final int quantityRequested;
  final String? notes;

  StockRequestItemCreateDTO({
    required this.productId,
    required this.quantityRequested,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantityRequested': quantityRequested,
    'notes': notes,
  };
}
