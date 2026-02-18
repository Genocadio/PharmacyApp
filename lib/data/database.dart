import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';
import 'tables.dart';
import 'package:nexxpharma/services/dto/activation_dto.dart';

part 'database.g.dart';

// Database class
@DriftDatabase(
  tables: [
    Insurances,
    Products,
    ProductInsurances,
    StockIns,
    StockOutSales,
    StockOuts,
    Users,
    StockRequests,
    StockRequestItems,
    Modules,
    Devices,
    PaymentMethods,
    Workers,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 7 && to == 8) {
          // Add destination_clinic_service column to stock_out_sales table
          await m.addColumn(
            stockOutSales,
            stockOutSales.destinationClinicService,
          );
        }
        if (from < 9) {
          await m.createTable(devices);
        }
        if (from < 10) {
          await m.addColumn(modules, modules.subType);
        }
        if (from < 11) {
          await m.createTable(paymentMethods);
          await m.createTable(workers);
        }
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'nexxpharma_db');
  }

  // UUID generator
  final _uuid = const Uuid();

  // ==================== Insurance CRUD ====================

  /// Create a new insurance
  Future<Insurance> createInsurance({
    required String name,
    required String acronym,
    required double clientPercentage,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final companion = InsurancesCompanion(
      id: Value(id),
      name: Value(name),
      acronym: Value(acronym),
      clientPercentage: Value(clientPercentage),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await into(insurances).insert(companion);
    return getInsuranceById(id);
  }

  /// Get insurance by ID
  Future<Insurance> getInsuranceById(String id) async {
    return (select(insurances)..where((t) => t.id.equals(id))).getSingle();
  }

  /// Get all insurances (excluding soft-deleted)
  Future<List<Insurance>> getAllInsurances() async {
    return (select(insurances)..where((t) => t.deletedAt.isNull())).get();
  }

  /// Watch all insurances (excluding soft-deleted)
  Stream<List<Insurance>> watchAllInsurances() {
    return (select(insurances)..where((t) => t.deletedAt.isNull())).watch();
  }

  /// Search insurances by name
  Future<List<Insurance>> searchInsurancesByName(String searchTerm) async {
    return (select(
      insurances,
    )..where((t) => t.name.like('%$searchTerm%') & t.deletedAt.isNull())).get();
  }

  /// Update insurance
  Future<bool> updateInsurance({
    required String id,
    String? name,
    String? acronym,
    double? clientPercentage,
  }) async {
    final updates = InsurancesCompanion(
      id: Value(id),
      name: name != null ? Value(name) : const Value.absent(),
      acronym: acronym != null ? Value(acronym) : const Value.absent(),
      clientPercentage: clientPercentage != null
          ? Value(clientPercentage)
          : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    return await (update(
          insurances,
        )..where((t) => t.id.equals(id))).write(updates) >
        0;
  }

  /// Soft delete insurance
  Future<bool> deleteInsurance(String id) async {
    return await (update(insurances)..where((t) => t.id.equals(id))).write(
          InsurancesCompanion(deletedAt: Value(DateTime.now())),
        ) >
        0;
  }

  /// Hard delete insurance (permanent)
  Future<int> hardDeleteInsurance(String id) async {
    return await (delete(insurances)..where((t) => t.id.equals(id))).go();
  }

  /// Import insurance data (for sync from server)
  /// Accepts complete data including ID, timestamps, and version
  Future<Insurance> importInsurance({
    required String id,
    required String name,
    required String acronym,
    required double clientPercentage,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    int? version,
  }) async {
    final companion = InsurancesCompanion(
      id: Value(id),
      name: Value(name),
      acronym: Value(acronym),
      clientPercentage: Value(clientPercentage),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: Value(deletedAt),
      version: Value(version ?? 0),
    );

    // Use insertOnConflictUpdate to handle both insert and update
    await into(insurances).insertOnConflictUpdate(companion);
    return getInsuranceById(id);
  }

  /// Batch import insurances (for bulk sync)
  Future<void> importInsurances(
    List<Map<String, dynamic>> insuranceList,
  ) async {
    await batch((batch) {
      for (final data in insuranceList) {
        final companion = InsurancesCompanion(
          id: Value(data['id'] as String),
          name: Value(data['name'] as String),
          acronym: Value(data['acronym'] as String),
          clientPercentage: Value((data['clientPercentage'] as num).toDouble()),
          createdAt: Value(DateTime.parse(data['createdAt'] as String)),
          updatedAt: Value(DateTime.parse(data['updatedAt'] as String)),
          deletedAt: Value(
            data['deletedAt'] != null
                ? DateTime.parse(data['deletedAt'] as String)
                : null,
          ),
          version: Value((data['version'] as num?)?.toInt() ?? 0),
        );
        batch.insert(
          insurances,
          companion,
          onConflict: DoUpdate((_) => companion),
        );
      }
    });
  }

  // ==================== Product CRUD ====================

  /// Create a new product
  Future<Product> createProduct({
    required String name,
    required ItemType type,
    String? description,
    String? sellingUnit,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final companion = ProductsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      description: Value(description),
      sellingUnit: Value(sellingUnit),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await into(products).insert(companion);
    return getProductById(id);
  }

  /// Get product by ID
  Future<Product> getProductById(String id) async {
    return (select(products)..where((t) => t.id.equals(id))).getSingle();
  }

  /// Get all products (excluding soft-deleted)
  Future<List<Product>> getAllProducts() async {
    return (select(products)..where((t) => t.deletedAt.isNull())).get();
  }

  /// Search products by name
  Future<List<Product>> searchProductsByName(String searchTerm) async {
    return (select(
      products,
    )..where((t) => t.name.like('%$searchTerm%') & t.deletedAt.isNull())).get();
  }

  /// Get products filtered by name, type, and insurance
  Future<List<Product>> getFilteredProducts({
    String? searchQuery,
    ItemType? type,
    String? insuranceId,
    bool onlyAvailable = false,
  }) async {
    final query = select(products)..where((t) => t.deletedAt.isNull());

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.where(
        (t) => t.name.contains(searchQuery),
      ); // DRIFT contains is safer than like %
    }

    if (type != null) {
      query.where((t) => t.type.equals(type.name));
    }

    if (insuranceId != null) {
      // Join or subquery to filter by insurance
      final subquery = selectOnly(productInsurances)
        ..addColumns([productInsurances.productId])
        ..where(
          productInsurances.insuranceId.equals(insuranceId) &
              productInsurances.cost.isBiggerThanValue(0) &
              productInsurances.deletedAt.isNull(),
        );

      query.where((t) => t.id.isInQuery(subquery));
    }

    if (onlyAvailable) {
      final stockSubquery = selectOnly(stockIns)
        ..addColumns([stockIns.productId])
        ..where(stockIns.quantity.isBiggerThanValue(0));
      query.where((t) => t.id.isInQuery(stockSubquery));
    }

    return query.get();
  }

  /// Update product
  Future<bool> updateProduct({
    required String id,
    String? name,
    ItemType? type,
    String? description,
    String? sellingUnit,
  }) async {
    final updates = ProductsCompanion(
      id: Value(id),
      name: name != null ? Value(name) : const Value.absent(),
      type: type != null ? Value(type) : const Value.absent(),
      description: description != null
          ? Value(description)
          : const Value.absent(),
      sellingUnit: sellingUnit != null
          ? Value(sellingUnit)
          : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    return await (update(
          products,
        )..where((t) => t.id.equals(id))).write(updates) >
        0;
  }

  /// Soft delete product
  Future<bool> deleteProduct(String id) async {
    return await (update(products)..where((t) => t.id.equals(id))).write(
          ProductsCompanion(deletedAt: Value(DateTime.now())),
        ) >
        0;
  }

  /// Hard delete product (permanent)
  Future<int> hardDeleteProduct(String id) async {
    return await (delete(products)..where((t) => t.id.equals(id))).go();
  }

  /// Import product data (for sync from server)
  /// Accepts complete data including ID, timestamps, and version
  Future<Product> importProduct({
    required String id,
    required String name,
    required ItemType type,
    String? description,
    String? sellingUnit,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    int? version,
  }) async {
    final companion = ProductsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      description: Value(description),
      sellingUnit: Value(sellingUnit),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: Value(deletedAt),
      version: Value(version ?? 0),
    );

    await into(products).insertOnConflictUpdate(companion);
    return getProductById(id);
  }

  /// Batch import products (for bulk sync)
  Future<void> importProducts(List<Map<String, dynamic>> productList) async {
    await batch((batch) {
      for (final data in productList) {
        // Parse metadata if present
        final metadata = data['metadata'] as Map<String, dynamic>?;
        final sellingUnit = metadata?['sellingUnit'] as String?;

        final companion = ProductsCompanion(
          id: Value(data['id'] as String),
          name: Value(data['name'] as String),
          type: Value(
            ItemType.values.firstWhere(
              (e) => e.name == data['type'],
              orElse: () => ItemType.DRUG,
            ),
          ),
          description: Value(data['description'] as String?),
          sellingUnit: Value(sellingUnit),
          createdAt: Value(DateTime.parse(data['createdAt'] as String)),
          updatedAt: Value(DateTime.parse(data['updatedAt'] as String)),
          deletedAt: Value(
            data['deletedAt'] != null
                ? DateTime.parse(data['deletedAt'] as String)
                : null,
          ),
          version: Value((data['version'] as num?)?.toInt() ?? 0),
        );
        batch.insert(
          products,
          companion,
          onConflict: DoUpdate((_) => companion),
        );
      }
    });
  }

  // ==================== ProductInsurance CRUD ====================

  /// Link a product to an insurance
  Future<ProductInsurance> linkProductInsurance({
    required String productId,
    required String insuranceId,
    required String code,
    required Unit unit,
    required double cost,
    required AuthorisedLevel authorisedLevel,
    required MustPrescribedBy mustPrescribedBy,
    int? utilizationCount,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final companion = ProductInsurancesCompanion.insert(
      id: id,
      code: code,
      utilizationCount: Value(utilizationCount),
      unit: unit,
      cost: cost,
      authorisedLevel: authorisedLevel,
      mustPrescribedBy: mustPrescribedBy,
      productId: productId,
      insuranceId: insuranceId,
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await into(productInsurances).insert(companion);
    return getProductInsuranceById(id);
  }

  /// Get product insurance by ID
  Future<ProductInsurance> getProductInsuranceById(String id) async {
    return (select(
      productInsurances,
    )..where((t) => t.id.equals(id))).getSingle();
  }

  /// Get all product-insurance links (excluding soft-deleted)
  Future<List<ProductInsurance>> getAllProductInsurances() async {
    return (select(
      productInsurances,
    )..where((t) => t.deletedAt.isNull())).get();
  }

  /// Get insurances for a specific product
  Future<List<ProductInsurance>> getInsurancesForProduct(
    String productId,
  ) async {
    return (select(productInsurances)
          ..where((t) => t.productId.equals(productId) & t.deletedAt.isNull()))
        .get();
  }

  /// Get products for a specific insurance
  Future<List<ProductInsurance>> getProductsForInsurance(
    String insuranceId,
  ) async {
    return (select(productInsurances)..where(
          (t) => t.insuranceId.equals(insuranceId) & t.deletedAt.isNull(),
        ))
        .get();
  }

  /// Update product insurance link
  Future<bool> updateProductInsurance({
    required String id,
    String? code,
    int? utilizationCount,
    Unit? unit,
    double? cost,
    AuthorisedLevel? authorisedLevel,
    MustPrescribedBy? mustPrescribedBy,
  }) async {
    final updates = ProductInsurancesCompanion(
      id: Value(id),
      code: code != null ? Value(code) : const Value.absent(),
      utilizationCount: utilizationCount != null
          ? Value(utilizationCount)
          : const Value.absent(),
      unit: unit != null ? Value(unit) : const Value.absent(),
      cost: cost != null ? Value(cost) : const Value.absent(),
      authorisedLevel: authorisedLevel != null
          ? Value(authorisedLevel)
          : const Value.absent(),
      mustPrescribedBy: mustPrescribedBy != null
          ? Value(mustPrescribedBy)
          : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    return await (update(
          productInsurances,
        )..where((t) => t.id.equals(id))).write(updates) >
        0;
  }

  /// Soft delete product insurance link
  Future<bool> deleteProductInsurance(String id) async {
    return await (update(
          productInsurances,
        )..where((t) => t.id.equals(id))).write(
          ProductInsurancesCompanion(deletedAt: Value(DateTime.now())),
        ) >
        0;
  }

  /// Hard delete product insurance link (permanent)
  Future<int> hardDeleteProductInsurance(String id) async {
    return await (delete(
      productInsurances,
    )..where((t) => t.id.equals(id))).go();
  }

  /// Import product insurance data (for sync from server)
  /// Accepts complete data including ID, timestamps, and version
  Future<ProductInsurance> importProductInsurance({
    required String id,
    required String productId,
    required String insuranceId,
    required String code,
    required Unit unit,
    required double cost,
    required AuthorisedLevel authorisedLevel,
    required MustPrescribedBy mustPrescribedBy,
    int? utilizationCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    int? version,
  }) async {
    final companion = ProductInsurancesCompanion(
      id: Value(id),
      code: Value(code),
      utilizationCount: Value(utilizationCount),
      unit: Value(unit),
      cost: Value(cost),
      authorisedLevel: Value(authorisedLevel),
      mustPrescribedBy: Value(mustPrescribedBy),
      productId: Value(productId),
      insuranceId: Value(insuranceId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: Value(deletedAt),
      version: Value(version ?? 0),
    );

    await into(productInsurances).insertOnConflictUpdate(companion);
    return getProductInsuranceById(id);
  }

  /// Batch import product insurances (for bulk sync)
  Future<void> importProductInsurances(
    List<Map<String, dynamic>> productInsuranceList,
  ) async {
    await batch((batch) {
      for (final data in productInsuranceList) {
        final companion = ProductInsurancesCompanion(
          id: Value(data['id'] as String),
          code: Value(data['code'] as String),
          utilizationCount: Value(data['utilizationCount'] as int?),
          unit: Value(
            Unit.values.firstWhere(
              (e) => e.name == data['unit'],
              orElse: () => Unit.UNKNOWN,
            ),
          ),
          cost: Value((data['cost'] as num).toDouble()),
          authorisedLevel: Value(
            AuthorisedLevel.values.firstWhere(
              (e) => e.name == data['authorisedLevel'],
              orElse: () => AuthorisedLevel.All,
            ),
          ),
          mustPrescribedBy: Value(
            MustPrescribedBy.values.firstWhere(
              (e) => e.name == data['mustPrescribedBy'],
              orElse: () => MustPrescribedBy.All,
            ),
          ),
          productId: Value(data['productId'] as String),
          insuranceId: Value(data['insuranceId'] as String),
          createdAt: Value(DateTime.parse(data['createdAt'] as String)),
          updatedAt: Value(DateTime.parse(data['updatedAt'] as String)),
          deletedAt: Value(
            data['deletedAt'] != null
                ? DateTime.parse(data['deletedAt'] as String)
                : null,
          ),
          version: Value((data['version'] as num?)?.toInt() ?? 0),
        );
        batch.insert(
          productInsurances,
          companion,
          onConflict: DoUpdate((_) => companion),
        );
      }
    });
  }

  /// Unlink product from insurance (soft delete)
  Future<bool> unlinkProductInsurance({
    required String productId,
    required String insuranceId,
  }) async {
    return await (update(productInsurances)..where(
              (t) =>
                  t.productId.equals(productId) &
                  t.insuranceId.equals(insuranceId),
            ))
            .write(
              ProductInsurancesCompanion(deletedAt: Value(DateTime.now())),
            ) >
        0;
  }

  // ==================== Advanced Queries ====================

  /// Get product with all its insurances (JOIN query)
  Future<Map<Product, List<ProductInsurance>>> getProductWithInsurances(
    String productId,
  ) async {
    final product = await getProductById(productId);
    final insuranceLinks = await getInsurancesForProduct(productId);
    return {product: insuranceLinks};
  }

  /// Get insurance with all its products (JOIN query)
  Future<Map<Insurance, List<ProductInsurance>>> getInsuranceWithProducts(
    String insuranceId,
  ) async {
    final insurance = await getInsuranceById(insuranceId);
    final productLinks = await getProductsForInsurance(insuranceId);
    return {insurance: productLinks};
  }

  // ==================== StockIn CRUD ====================

  /// Create a new stock in entry
  Future<StockIn> createStockIn({
    required String productId,
    required int quantity,
    String? location,
    double? pricePerUnit,
    String? batchNumber,
    DateTime? expiryDate,
    int? reorderLevel,
    String? userId,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final companion = StockInsCompanion.insert(
      id: id,
      quantity: quantity,
      location: Value(location),
      pricePerUnit: Value(pricePerUnit),
      batchNumber: Value(batchNumber),
      expiryDate: Value(expiryDate),
      reorderLevel: Value(reorderLevel),
      productId: productId,
      userId: Value(userId),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await into(stockIns).insert(companion);
    return getStockInById(id);
  }

  /// Get stock in by ID
  Future<StockIn> getStockInById(String id) async {
    return (select(stockIns)..where((t) => t.id.equals(id))).getSingle();
  }

  /// Get all stock in entries
  Future<List<StockIn>> getAllStockIns() async {
    return select(stockIns).get();
  }

  /// Get stock in entries for a specific product
  Future<List<StockIn>> getStockInsByProduct(String productId) async {
    return (select(stockIns)..where((t) => t.productId.equals(productId))).get();
  }

  /// Get stock in entries below reorder level
  Future<List<StockIn>> getStockInsBelowReorderLevel() async {
    return (select(
      stockIns,
    )..where((t) => t.quantity.isSmallerOrEqual(t.reorderLevel))).get();
  }

  /// Update stock in entry
  Future<bool> updateStockIn({
    required String id,
    int? quantity,
    String? location,
    double? pricePerUnit,
    String? batchNumber,
    DateTime? expiryDate,
    int? reorderLevel,
  }) async {
    final updates = StockInsCompanion(
      id: Value(id),
      quantity: quantity != null ? Value(quantity) : const Value.absent(),
      location: location != null ? Value(location) : const Value.absent(),
      pricePerUnit: pricePerUnit != null
          ? Value(pricePerUnit)
          : const Value.absent(),
      batchNumber: batchNumber != null
          ? Value(batchNumber)
          : const Value.absent(),
      expiryDate: expiryDate != null ? Value(expiryDate) : const Value.absent(),
      reorderLevel: reorderLevel != null
          ? Value(reorderLevel)
          : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    return await (update(
          stockIns,
        )..where((t) => t.id.equals(id))).write(updates) >
        0;
  }

  /// Delete stock in entry (hard delete)
  Future<int> deleteStockIn(String id) async {
    return await (delete(stockIns)..where((t) => t.id.equals(id))).go();
  }

  /// Adjust stock in quantity (add or subtract)
  Future<bool> adjustStockInQuantity(String id, int adjustment) async {
    final stockIn = await getStockInById(id);
    final newQuantity = stockIn.quantity + adjustment;
    return updateStockIn(id: id, quantity: newQuantity);
  }

  // ==================== StockOutSale CRUD ====================

  /// Create a new stock out sale record
  Future<StockOutSale> createStockOutSale({
    required String transactionId,
    required String stockOutId,
    required String patientName,
    required double totalPrice,
    String? insuranceCardNumber,
    String? issuingCompany,
    String? prescriberName,
    String? prescriberLicenseId,
    String? prescribingOrganization,
    String? destinationClinicService,
    String? userId,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final companion = StockOutSalesCompanion.insert(
      id: id,
      transactionId: transactionId,
      stockOutId: stockOutId,
      patientName: patientName,
      totalPrice: totalPrice,
      destinationClinicService: Value(destinationClinicService),
      insuranceCardNumber: Value(insuranceCardNumber),
      issuingCompany: Value(issuingCompany),
      prescriberName: Value(prescriberName),
      prescriberLicenseId: Value(prescriberLicenseId),
      prescribingOrganization: Value(prescribingOrganization),
      userId: Value(userId),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await into(stockOutSales).insert(companion);
    return getStockOutSaleById(id);
  }

  /// Get stock out sale record by ID
  Future<StockOutSale> getStockOutSaleById(String id) async {
    return (select(stockOutSales)..where((t) => t.id.equals(id))).getSingle();
  }

  /// Get all stock out sale records
  Future<List<StockOutSale>> getAllStockOutSales() async {
    return select(stockOutSales).get();
  }

  /// Search stock out sales by patient name
  Future<List<StockOutSale>> searchStockOutSalesByPatient(
    String patientName,
  ) async {
    return (select(
      stockOutSales,
    )..where((t) => t.patientName.like('%$patientName%'))).get();
  }

  /// Get stock out sales within date range
  Future<List<StockOutSale>> getStockOutSalesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return (select(
      stockOutSales,
    )..where((t) => t.createdAt.isBetweenValues(startDate, endDate))).get();
  }

  /// Get stock out sales by transaction ID
  Future<List<StockOutSale>> getStockOutSalesByTransactionId(
    String transactionId,
  ) async {
    return (select(stockOutSales)
          ..where((t) => t.transactionId.equals(transactionId)))
        .get();
  }

  /// Update stock out sale record
  Future<bool> updateStockOutSale({
    required String id,
    String? transactionId,
    String? stockOutId,
    String? patientName,
    double? totalPrice,
    String? insuranceCardNumber,
    String? issuingCompany,
    String? prescriberName,
    String? prescriberLicenseId,
    String? prescribingOrganization,
  }) async {
    final updates = StockOutSalesCompanion(
      id: Value(id),
      transactionId: transactionId != null
          ? Value(transactionId)
          : const Value.absent(),
      stockOutId: stockOutId != null
          ? Value(stockOutId)
          : const Value.absent(),
      patientName: patientName != null
          ? Value(patientName)
          : const Value.absent(),
      totalPrice: totalPrice != null ? Value(totalPrice) : const Value.absent(),
      insuranceCardNumber: insuranceCardNumber != null
          ? Value(insuranceCardNumber)
          : const Value.absent(),
      issuingCompany: issuingCompany != null
          ? Value(issuingCompany)
          : const Value.absent(),
      prescriberName: prescriberName != null
          ? Value(prescriberName)
          : const Value.absent(),
      prescriberLicenseId: prescriberLicenseId != null
          ? Value(prescriberLicenseId)
          : const Value.absent(),
      prescribingOrganization: prescribingOrganization != null
          ? Value(prescribingOrganization)
          : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    return await (update(
          stockOutSales,
        )..where((t) => t.id.equals(id))).write(updates) >
        0;
  }

  /// Delete stock out sale record (hard delete)
  Future<int> deleteStockOutSale(String id) async {
    return await (delete(stockOutSales)..where((t) => t.id.equals(id))).go();
  }

  // ==================== StockOut CRUD ====================

  /// Create a new stock out item
  Future<StockOut> createStockOut({
    required String stockInId,
    required int quantitySold,
    required double pricePerUnit,
    required double itemTotal,
    required double patientPays,
    required double insurancePays,
    String? insuranceId,
  }) async {
    final id = _uuid.v4();

    final companion = StockOutsCompanion.insert(
      id: id,
      stockInId: stockInId,
      quantitySold: quantitySold,
      pricePerUnit: pricePerUnit,
      itemTotal: itemTotal,
      patientPays: patientPays,
      insurancePays: insurancePays,
      insuranceId: Value(insuranceId),
    );

    await into(stockOuts).insert(companion);

    // Automatically adjust stock in quantity
    await adjustStockInQuantity(stockInId, -quantitySold);

    return getStockOutById(id);
  }

  /// Get stock out item by ID
  Future<StockOut> getStockOutById(String id) async {
    return (select(stockOuts)..where((t) => t.id.equals(id))).getSingle();
  }

  /// Get all stock out items
  Future<List<StockOut>> getAllStockOuts() async {
    return select(stockOuts).get();
  }

  /// Get stock out items for a specific stock in
  Future<List<StockOut>> getStockOutsByStockIn(String stockInId) async {
    return (select(stockOuts)
          ..where((t) => t.stockInId.equals(stockInId)))
        .get();
  }

  /// Update stock out item
  Future<bool> updateStockOut({
    required String id,
    int? quantitySold,
    double? pricePerUnit,
    double? itemTotal,
    double? patientPays,
    double? insurancePays,
    String? insuranceId,
  }) async {
    final updates = StockOutsCompanion(
      id: Value(id),
      quantitySold: quantitySold != null
          ? Value(quantitySold)
          : const Value.absent(),
      pricePerUnit: pricePerUnit != null
          ? Value(pricePerUnit)
          : const Value.absent(),
      itemTotal: itemTotal != null ? Value(itemTotal) : const Value.absent(),
      patientPays: patientPays != null
          ? Value(patientPays)
          : const Value.absent(),
      insurancePays: insurancePays != null
          ? Value(insurancePays)
          : const Value.absent(),
      insuranceId: insuranceId != null
          ? Value(insuranceId)
          : const Value.absent(),
    );

    return await (update(
          stockOuts,
        )..where((t) => t.id.equals(id))).write(updates) >
        0;
  }

  /// Delete stock out item (hard delete)
  Future<int> deleteStockOut(String id) async {
    return await (delete(stockOuts)..where((t) => t.id.equals(id))).go();
  }

  // ==================== Advanced StockOut Queries ====================

  /// Get stock out report for a date range with totals
  Future<Map<String, dynamic>> getStockOutReport(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final salesRows = await getStockOutSalesByDateRange(startDate, endDate);
    final transactions = <String, StockOutSale>{};
    for (final row in salesRows) {
      transactions.putIfAbsent(row.transactionId, () => row);
    }
    final totalRevenue = transactions.values.fold<double>(
      0,
      (sum, sale) => sum + sale.totalPrice,
    );

    return {
      'sales': transactions.values.toList(),
      'totalSales': transactions.length,
      'totalRevenue': totalRevenue,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  // ==================== User CRUD ====================

  /// Create a new user
  Future<User> createUser({
    required String names,
    required String phoneNumber,
    required String password,
    required UserRole role,
    String? email,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final companion = UsersCompanion.insert(
      id: id,
      names: names,
      phoneNumber: phoneNumber,
      password: password,
      role: role,
      email: Value(email),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    await into(users).insert(companion);
    return getUserById(id);
  }

  /// Get user by ID
  Future<User> getUserById(String id) async {
    return (select(users)..where((t) => t.id.equals(id))).getSingle();
  }

  /// Get user by email (optional field)
  Future<User?> getUserByEmail(String email) async {
    return (select(
      users,
    )..where((t) => t.email.equals(email))).getSingleOrNull();
  }

  /// Get all users (excluding soft-deleted)
  Future<List<User>> getAllUsers() async {
    return (select(users)..where((t) => t.deletedAt.isNull())).get();
  }

  /// Update user
  Future<bool> updateUser({
    required String id,
    String? names,
    String? phoneNumber,
    String? password,
    UserRole? role,
    String? email,
  }) async {
    final updates = UsersCompanion(
      id: Value(id),
      names: names != null ? Value(names) : const Value.absent(),
      phoneNumber: phoneNumber != null
          ? Value(phoneNumber)
          : const Value.absent(),
      password: password != null ? Value(password) : const Value.absent(),
      role: role != null ? Value(role) : const Value.absent(),
      email: email != null ? Value(email) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    return await (update(users)..where((t) => t.id.equals(id))).write(updates) >
        0;
  }

  /// Soft delete user
  Future<bool> deleteUser(String id) async {
    return await (update(users)..where((t) => t.id.equals(id))).write(
          UsersCompanion(deletedAt: Value(DateTime.now())),
        ) >
        0;
  }

  /// Hard delete user (permanent)
  Future<int> hardDeleteUser(String id) async {
    return await (delete(users)..where((t) => t.id.equals(id))).go();
  }

  // ==================== Module (Activation) CRUD ====================

  /// Get the module activation info (should only be one)
  Future<Module?> getModule() async {
    return (select(modules)..limit(1)).getSingleOrNull();
  }

  /// Save or update the module activation info
  Future<void> saveModule(ModuleResponse response, {String? privateKey}) async {
    final companion = ModulesCompanion(
      moduleCode: Value(response.moduleCode),
      publicKey: Value(response.publicKey),
      name: Value(response.name),
      phone: Value(response.phone),
      email: Value(response.email),
      country: Value(response.country),
      province: Value(response.province),
      district: Value(response.district),
      sector: Value(response.sector),
      logoUrl: Value(response.logoUrl),
      activationStatus: Value(response.activationStatus),
      activationTime: Value(response.activationTime),
      subscriptionTier: Value(response.subscriptionTier),
      expirationDate: Value(response.expirationDate),
      timestamp: Value(response.timestamp),
      latitude: Value(response.latitude),
      longitude: Value(response.longitude),
      serviceType: Value(response.serviceType),
      subType: Value(response.subType),
      privateKey: privateKey != null ? Value(privateKey) : const Value.absent(),
    );

    final existing = await getModule();
    if (existing != null) {
      await (update(
        modules,
      )..where((t) => t.id.equals(existing.id))).write(companion);
    } else {
      await into(modules).insert(companion);
    }

    // Save payment methods if available
    if (response.paymentMethods.isNotEmpty && response.id != null) {
      await _savePaymentMethods(response.id!, response.paymentMethods);
    }
  }

  /// Save payment methods for a module
  Future<void> _savePaymentMethods(
    int moduleId,
    List<ModulePaymentMethod> pmList,
  ) async {
    // Delete existing payment methods for this module
    await (delete(paymentMethods)
        ..where((t) => t.moduleId.equals(moduleId)))
        .go();

    // Insert new payment methods
    for (final pm in pmList) {
      await into(paymentMethods).insert(
        PaymentMethodsCompanion(
          moduleId: Value(moduleId),
          account: Value(pm.account),
          currency: Value(pm.currency),
          type: Value(pm.type),
        ),
      );
    }
  }

  /// Get payment methods for a module
  Future<List<PaymentMethod>> getPaymentMethodsByModule(int moduleId) async {
    return (select(paymentMethods)
        ..where((t) => t.moduleId.equals(moduleId)))
        .get();
  }

  /// Get total count of active users
  Future<int> getUsersCount() async {
    final countExp = users.id.count();
    final query = selectOnly(users)
      ..addColumns([countExp])
      ..where(users.deletedAt.isNull());
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  /// Delete module info (for reset)
  Future<void> deleteModule() async {
    await delete(modules).go();
  }

  // ==================== Device (Registration) CRUD ====================

  /// Get the device registration info (should only be one)
  Future<Device?> getDevice() async {
    return (select(devices)..limit(1)).getSingleOrNull();
  }

  /// Save or update the device registration info
  Future<void> saveDevice(DeviceDTO response, {String? moduleId}) async {
    final companion = DevicesCompanion(
      moduleId: moduleId != null ? Value(moduleId) : const Value.absent(),
      deviceId: Value(response.deviceId ?? ''),
      deviceName: Value(response.deviceName),
      appVersion: Value(response.appVersion),
      latitude: Value(response.latitude),
      longitude: Value(response.longitude),
      lastAction: Value(response.lastAction),
      deviceType: Value(response.deviceType),
      activationStatus: Value(response.activationStatus),
      supportMultiUsers: Value(response.supportMultiUsers),
      lastSeenAt: Value(response.lastSeenAt),
      createdAt: Value(response.createdAt),
    );

    final existing = await getDevice();
    if (existing != null) {
      await (update(devices)..where((t) => t.id.equals(existing.id))).write(
        companion,
      );
    } else {
      await into(devices).insert(companion);
    }
  }

  /// Update selected device fields without replacing the whole record
  Future<void> updateDeviceLocal({
    ActivationStatus? activationStatus,
    bool? supportMultiUsers,
    String? appVersion,
    double? latitude,
    double? longitude,
    String? lastAction,
  }) async {
    final existing = await getDevice();
    if (existing == null) return;

    final companion = DevicesCompanion(
      activationStatus: activationStatus != null
          ? Value(activationStatus)
          : const Value.absent(),
      supportMultiUsers: supportMultiUsers != null
          ? Value(supportMultiUsers)
          : const Value.absent(),
      appVersion: appVersion != null ? Value(appVersion) : const Value.absent(),
      latitude: latitude != null ? Value(latitude) : const Value.absent(),
      longitude: longitude != null ? Value(longitude) : const Value.absent(),
      lastAction: lastAction != null ? Value(lastAction) : const Value.absent(),
    );

    await (update(devices)..where((t) => t.id.equals(existing.id))).write(
      companion,
    );
  }

  /// Update module private key without replacing other fields
  Future<void> updateModulePrivateKey(String privateKey) async {
    final existing = await getModule();
    if (existing == null) return;

    await (update(modules)..where((t) => t.id.equals(existing.id))).write(
      ModulesCompanion(privateKey: Value(privateKey)),
    );
  }

  /// Delete device info (for reset)
  Future<void> deleteDevice() async {
    await delete(devices).go();
  }

  // ==================== Workers (Synced Users) CRUD ====================

  /// Get all workers for a module
  Future<List<Worker>> getWorkersByModule(int moduleId) async {
    return (select(workers)..where((t) => t.moduleId.equals(moduleId))).get();
  }

  /// Save or update workers synced from server
  Future<void> saveWorkers(int moduleId, List<WorkerDTO> workerDtoList) async {
    // Delete existing workers for this module (since we get full list from server)
    await (delete(workers)..where((t) => t.moduleId.equals(moduleId))).go();

    // Insert new workers
    for (final worker in workerDtoList) {
      await into(workers).insert(
        WorkersCompanion(
          id: Value(worker.id),
          moduleId: Value(moduleId),
          firstName: Value(worker.firstName),
          lastName: Value(worker.lastName),
          phone: Value(worker.phone),
          email: Value(worker.email),
          role: Value(worker.role),
          pinHash: Value(worker.pinHash),
          active: Value(worker.active),
          version: Value(worker.version),
          deletedAt: Value(worker.deletedAt),
        ),
      );
    }
  }

  /// Get a specific worker
  Future<Worker?> getWorker(String workerId) async {
    return (select(workers)..where((t) => t.id.equals(workerId)))
        .getSingleOrNull();
  }

  /// Clear all workers (for reset)
  Future<void> clearWorkers() async {
    await delete(workers).go();
  }

  /// Clear all data (used when registering a new device/fresh start)
  /// Keeps only the module and device records but clears all operational data
  Future<void> clearAllOperationalData() async {
    // Clear all tables except modules and devices
    await delete(users).go();
    await delete(insurances).go();
    await delete(products).go();
    await delete(productInsurances).go();
    await delete(stockIns).go();
    await delete(stockOuts).go();
    await delete(stockOutSales).go();
    await delete(stockRequests).go();
    await delete(stockRequestItems).go();
    await delete(workers).go();
  }

  /// Complete reset - clears everything including module and device
  Future<void> clearAllData() async {
    await clearAllOperationalData();
    await delete(paymentMethods).go();
    await delete(modules).go();
    await delete(devices).go();
  }
}
