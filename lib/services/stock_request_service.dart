import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/data/tables.dart';
import 'package:nexxpharma/services/dto/stock_request_dto.dart';
import 'package:uuid/uuid.dart';

/// Service for managing stock requests
class StockRequestService {
  final AppDatabase _database;
  final _uuid = const Uuid();

  StockRequestService(this._database);

  /// Generate a unique request number in format: REQ-YYYYMMDD-XXX
  Future<String> _generateRequestNumber() async {
    final today = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(today);
    final prefix = 'REQ-$dateStr-';

    // Find the highest sequence number for today
    final existingRequests =
        await (_database.select(_database.stockRequests)
              ..where((tbl) => tbl.requestNumber.like('$prefix%'))
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.requestNumber)]))
            .get();

    int sequence = 1;
    if (existingRequests.isNotEmpty) {
      final lastNumber = existingRequests.first.requestNumber;
      final lastSequence = int.tryParse(lastNumber.split('-').last) ?? 0;
      sequence = lastSequence + 1;
    }

    return '$prefix${sequence.toString().padLeft(3, '0')}';
  }

  /// Create a new draft stock request
  Future<StockRequestDTO> createRequest({
    required String userId,
    required DateTime requestDate,
    DateTime? neededByDate,
    String? notes,
  }) async {
    final requestId = _uuid.v4();
    final requestNumber = await _generateRequestNumber();
    final now = DateTime.now();

    await _database
        .into(_database.stockRequests)
        .insert(
          StockRequestsCompanion.insert(
            id: requestId,
            userId: userId,
            requestNumber: requestNumber,
            requestDate: requestDate,
            neededByDate: Value(neededByDate),
            status: StockRequestStatus.DRAFT,
            notes: Value(notes),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

    return getRequestById(requestId);
  }

  /// Create a new stock request with initial items atomically
  Future<StockRequestDTO> createRequestWithItems({
    required String userId,
    required DateTime requestDate,
    required List<StockRequestItemCreateDTO> items,
    DateTime? neededByDate,
    String? notes,
    bool submit = false,
  }) async {
    if (items.isEmpty) {
      throw Exception('Cannot create a request with no items');
    }

    final requestId = _uuid.v4();
    final requestNumber = await _generateRequestNumber();
    final now = DateTime.now();

    return _database.transaction(() async {
      await _database
          .into(_database.stockRequests)
          .insert(
            StockRequestsCompanion.insert(
              id: requestId,
              userId: userId,
              requestNumber: requestNumber,
              requestDate: requestDate,
              neededByDate: Value(neededByDate),
              status: submit
                  ? StockRequestStatus.SUBMITTED
                  : StockRequestStatus.DRAFT,
              notes: Value(notes),
              createdAt: Value(now),
              updatedAt: Value(now),
              submittedAt: Value(submit ? now : null),
            ),
          );

      for (final item in items) {
        await _database
            .into(_database.stockRequestItems)
            .insert(
              StockRequestItemsCompanion.insert(
                id: _uuid.v4(),
                requestId: requestId,
                productId: item.productId,
                quantityRequested: item.quantityRequested,
                notes: Value(item.notes),
              ),
            );
      }

      return getRequestById(requestId);
    });
  }

  /// Update a draft request
  Future<void> updateRequest({
    required String requestId,
    DateTime? requestDate,
    DateTime? neededByDate,
    String? notes,
  }) async {
    final request = await (_database.select(
      _database.stockRequests,
    )..where((tbl) => tbl.id.equals(requestId))).getSingle();

    if (request.status != StockRequestStatus.DRAFT) {
      throw Exception('Cannot update a submitted or received request');
    }

    await (_database.update(
      _database.stockRequests,
    )..where((tbl) => tbl.id.equals(requestId))).write(
      StockRequestsCompanion(
        requestDate: Value(requestDate ?? request.requestDate),
        neededByDate: Value(neededByDate ?? request.neededByDate),
        notes: Value(notes ?? request.notes),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Add an item to a request
  Future<void> addItemToRequest({
    required String requestId,
    required String productId,
    required int quantityRequested,
    String? notes,
  }) async {
    final request = await (_database.select(
      _database.stockRequests,
    )..where((tbl) => tbl.id.equals(requestId))).getSingle();

    if (request.status != StockRequestStatus.DRAFT) {
      throw Exception('Cannot add items to a submitted or received request');
    }

    // Check if product already exists in request
    final existing =
        await (_database.select(_database.stockRequestItems)..where(
              (tbl) =>
                  tbl.requestId.equals(requestId) &
                  tbl.productId.equals(productId),
            ))
            .getSingleOrNull();

    if (existing != null) {
      // Update quantity if already exists
      await (_database.update(
        _database.stockRequestItems,
      )..where((tbl) => tbl.id.equals(existing.id))).write(
        StockRequestItemsCompanion(
          quantityRequested: Value(
            existing.quantityRequested + quantityRequested,
          ),
          notes: Value(notes ?? existing.notes),
        ),
      );
    } else {
      // Insert new item
      await _database
          .into(_database.stockRequestItems)
          .insert(
            StockRequestItemsCompanion.insert(
              id: _uuid.v4(),
              requestId: requestId,
              productId: productId,
              quantityRequested: quantityRequested,
              notes: Value(notes),
            ),
          );
    }

    // Update request's updatedAt timestamp
    await (_database.update(_database.stockRequests)
          ..where((tbl) => tbl.id.equals(requestId)))
        .write(StockRequestsCompanion(updatedAt: Value(DateTime.now())));
  }

  /// Remove an item from a request
  Future<void> removeItemFromRequest({
    required String requestId,
    required String itemId,
  }) async {
    final request = await (_database.select(
      _database.stockRequests,
    )..where((tbl) => tbl.id.equals(requestId))).getSingle();

    if (request.status != StockRequestStatus.DRAFT) {
      throw Exception(
        'Cannot remove items from a submitted or received request',
      );
    }

    await (_database.delete(
      _database.stockRequestItems,
    )..where((tbl) => tbl.id.equals(itemId))).go();

    // Update request's updatedAt timestamp
    await (_database.update(_database.stockRequests)
          ..where((tbl) => tbl.id.equals(requestId)))
        .write(StockRequestsCompanion(updatedAt: Value(DateTime.now())));
  }

  /// Submit a draft request
  Future<void> submitRequest(String requestId) async {
    final request = await (_database.select(
      _database.stockRequests,
    )..where((tbl) => tbl.id.equals(requestId))).getSingle();

    if (request.status != StockRequestStatus.DRAFT) {
      throw Exception('Only draft requests can be submitted');
    }

    // Check if request has items
    final items = await (_database.select(
      _database.stockRequestItems,
    )..where((tbl) => tbl.requestId.equals(requestId))).get();

    if (items.isEmpty) {
      throw Exception('Cannot submit a request with no items');
    }

    final now = DateTime.now();
    await (_database.update(
      _database.stockRequests,
    )..where((tbl) => tbl.id.equals(requestId))).write(
      StockRequestsCompanion(
        status: const Value(StockRequestStatus.SUBMITTED),
        submittedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  /// Mark a request as received
  Future<void> markAsReceived(String requestId) async {
    final request = await (_database.select(
      _database.stockRequests,
    )..where((tbl) => tbl.id.equals(requestId))).getSingle();

    if (request.status != StockRequestStatus.SUBMITTED) {
      throw Exception('Only submitted requests can be marked as received');
    }

    final now = DateTime.now();
    await (_database.update(
      _database.stockRequests,
    )..where((tbl) => tbl.id.equals(requestId))).write(
      StockRequestsCompanion(
        status: const Value(StockRequestStatus.RECEIVED),
        receivedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  /// Delete a draft request
  Future<void> deleteRequest(String requestId) async {
    final request = await (_database.select(
      _database.stockRequests,
    )..where((tbl) => tbl.id.equals(requestId))).getSingle();

    if (request.status != StockRequestStatus.DRAFT) {
      throw Exception('Only draft requests can be deleted');
    }

    // Items will be cascade deleted
    await (_database.delete(
      _database.stockRequests,
    )..where((tbl) => tbl.id.equals(requestId))).go();
  }

  /// Get a single request by ID
  Future<StockRequestDTO> getRequestById(String requestId) async {
    final query = _database.select(_database.stockRequests).join([
      leftOuterJoin(
        _database.users,
        _database.users.id.equalsExp(_database.stockRequests.userId),
      ),
    ])..where(_database.stockRequests.id.equals(requestId));

    final result = await query.getSingle();
    final request = result.readTable(_database.stockRequests);
    final user = result.readTableOrNull(_database.users);

    // Get items
    final itemsQuery = _database.select(_database.stockRequestItems).join([
      leftOuterJoin(
        _database.products,
        _database.products.id.equalsExp(_database.stockRequestItems.productId),
      ),
    ])..where(_database.stockRequestItems.requestId.equals(requestId));

    final itemsResult = await itemsQuery.get();
    final items = itemsResult.map((row) {
      final item = row.readTable(_database.stockRequestItems);
      final product = row.readTableOrNull(_database.products);

      return StockRequestItemDTO(
        id: item.id,
        requestId: item.requestId,
        productId: item.productId,
        productName: product?.name ?? 'Unknown Product',
        quantityRequested: item.quantityRequested,
        notes: item.notes,
      );
    }).toList();

    return StockRequestDTO(
      id: request.id,
      userId: request.userId,
      userName: user?.names ?? 'Unknown User',
      requestNumber: request.requestNumber,
      requestDate: request.requestDate,
      neededByDate: request.neededByDate,
      status: request.status,
      notes: request.notes,
      createdAt: request.createdAt,
      updatedAt: request.updatedAt,
      submittedAt: request.submittedAt,
      receivedAt: request.receivedAt,
      items: items,
    );
  }

  /// Get all requests with optional status filter
  Future<List<StockRequestDTO>> getAllRequests({
    StockRequestStatus? status,
  }) async {
    final query = _database.select(_database.stockRequests).join([
      leftOuterJoin(
        _database.users,
        _database.users.id.equalsExp(_database.stockRequests.userId),
      ),
    ]);

    if (status != null) {
      query.where(_database.stockRequests.status.equals(status.name));
    }

    query.orderBy([OrderingTerm.desc(_database.stockRequests.createdAt)]);

    final results = await query.get();

    final requests = <StockRequestDTO>[];
    for (final result in results) {
      final request = result.readTable(_database.stockRequests);
      final user = result.readTableOrNull(_database.users);

      // Get items for this request
      final itemsQuery = _database.select(_database.stockRequestItems).join([
        leftOuterJoin(
          _database.products,
          _database.products.id.equalsExp(
            _database.stockRequestItems.productId,
          ),
        ),
      ])..where(_database.stockRequestItems.requestId.equals(request.id));

      final itemsResult = await itemsQuery.get();
      final items = itemsResult.map((row) {
        final item = row.readTable(_database.stockRequestItems);
        final product = row.readTableOrNull(_database.products);

        return StockRequestItemDTO(
          id: item.id,
          requestId: item.requestId,
          productId: item.productId,
          productName: product?.name ?? 'Unknown Product',
          quantityRequested: item.quantityRequested,
          notes: item.notes,
        );
      }).toList();

      requests.add(
        StockRequestDTO(
          id: request.id,
          userId: request.userId,
          userName: user?.names ?? 'Unknown User',
          requestNumber: request.requestNumber,
          requestDate: request.requestDate,
          neededByDate: request.neededByDate,
          status: request.status,
          notes: request.notes,
          createdAt: request.createdAt,
          updatedAt: request.updatedAt,
          submittedAt: request.submittedAt,
          receivedAt: request.receivedAt,
          items: items,
        ),
      );
    }

    return requests;
  }

  /// Get draft requests only
  Future<List<StockRequestDTO>> getDraftRequests() async {
    return getAllRequests(status: StockRequestStatus.DRAFT);
  }
}
