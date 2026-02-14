/// Data Transfer Objects for SyncOut operations
/// Covers workers, stock movements, and sales snapshots

class SyncOutPayload {
  final List<WorkerSyncPayload> workers;
  final List<StockInSyncPayload> stocksIn;
  final List<StockOutSyncPayload> stocksOut;
  final List<SalesSnapshotPayload> salesSnapshots;

  SyncOutPayload({
    required this.workers,
    required this.stocksIn,
    required this.stocksOut,
    required this.salesSnapshots,
  });

  Map<String, dynamic> toJson() {
    return {
      'workers': workers.map((w) => w.toJson()).toList(),
      'stocksIn': stocksIn.map((s) => s.toJson()).toList(),
      'stocksOut': stocksOut.map((s) => s.toJson()).toList(),
      'salesSnapshots': salesSnapshots.map((s) => s.toJson()).toList(),
    };
  }
}

class WorkerSyncPayload {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String role;
  final bool isActive;

  WorkerSyncPayload({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    required this.role,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'role': role,
      'isActive': isActive,
    };
  }
}

class StockInSyncPayload {
  final String id;
  final String productId;
  final int quantity;
  final String? location;
  final double? pricePerUnit;
  final String? batchNumber;
  final DateTime? expiryDate;
  final int? reorderLevel;
  final String? userId;
  final DateTime createdAt;

  StockInSyncPayload({
    required this.id,
    required this.productId,
    required this.quantity,
    this.location,
    this.pricePerUnit,
    this.batchNumber,
    this.expiryDate,
    this.reorderLevel,
    this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'quantity': quantity,
      'location': location,
      'pricePerUnit': pricePerUnit,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'reorderLevel': reorderLevel,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class StockOutSyncPayload {
  final String id;
  final String stockInId;
  final int quantitySold;
  final double pricePerUnit;
  final String? insuranceId;
  final double itemTotal;
  final double patientPays;
  final double insurancePays;
  final DateTime createdAt;

  StockOutSyncPayload({
    required this.id,
    required this.stockInId,
    required this.quantitySold,
    required this.pricePerUnit,
    this.insuranceId,
    required this.itemTotal,
    required this.patientPays,
    required this.insurancePays,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stockInId': stockInId,
      'quantitySold': quantitySold,
      'pricePerUnit': pricePerUnit,
      'insuranceId': insuranceId,
      'itemTotal': itemTotal,
      'patientPays': patientPays,
      'insurancePays': insurancePays,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class SalesSnapshotPayload {
  final String id;
  final DateTime snapTimestamp;
  final double totalAmount;
  final double totalPrivateAmount;
  final double totalInsuranceAmount;
  final String? topProductId;
  final double? topProductAmount;
  final String? topInsuranceId;
  final List<WorkerRevenuePayload> workerRevenues;

  SalesSnapshotPayload({
    required this.id,
    required this.snapTimestamp,
    required this.totalAmount,
    required this.totalPrivateAmount,
    required this.totalInsuranceAmount,
    this.topProductId,
    this.topProductAmount,
    this.topInsuranceId,
    required this.workerRevenues,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'snapTimestamp': snapTimestamp.toIso8601String(),
      'totalAmount': totalAmount,
      'totalPrivateAmount': totalPrivateAmount,
      'totalInsuranceAmount': totalInsuranceAmount,
      'topProductId': topProductId,
      'topProductAmount': topProductAmount,
      'topInsuranceId': topInsuranceId,
      'workerRevenues': workerRevenues.map((w) => w.toJson()).toList(),
    };
  }
}

class WorkerRevenuePayload {
  final String workerId;
  final double revenue;

  WorkerRevenuePayload({
    required this.workerId,
    required this.revenue,
  });

  Map<String, dynamic> toJson() {
    return {
      'workerId': workerId,
      'revenue': revenue,
    };
  }
}
