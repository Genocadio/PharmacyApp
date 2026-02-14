import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:crypton/crypton.dart';
import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/data/tables.dart';
import 'package:nexxpharma/services/settings_service.dart';

enum SyncStatus { idle, syncing, success, error }

class SyncService extends ChangeNotifier {
  final AppDatabase _db;
  final SettingsService _settings;

  SyncStatus _status = SyncStatus.idle;
  double _progress = 0.0;
  String? _error;
  int _itemsSynced = 0;
  String? _syncError;

  SyncService(this._db, this._settings);

  SyncStatus get status => _status;
  double get progress => _progress;
  String? get error => _error;
  bool get isSyncing => _status == SyncStatus.syncing;
  int get itemsSynced => _itemsSynced;
  String? get syncError => _syncError;

  Future<void> performSync() async {
    if (_status == SyncStatus.syncing) return;

    _status = SyncStatus.syncing;
    _progress = 0.0;
    _error = null;
    notifyListeners();

    try {
      if (!_settings.hasCompletedInitialSync) {
        await _fullSync();
      } else {
        await _incrementalSync();
      }

      _status = SyncStatus.success;
      _progress = 1.0;
    } catch (e) {
      _status = SyncStatus.error;
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> forceFullSync() async {
    if (_status == SyncStatus.syncing) return;

    _status = SyncStatus.syncing;
    _progress = 0.0;
    _error = null;
    notifyListeners();

    try {
      await _fullSync();
      _status = SyncStatus.success;
      _progress = 1.0;
    } catch (e) {
      _status = SyncStatus.error;
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Token management
  String? _cachedToken;

  Future<String> _getSyncToken({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedToken != null) {
      return _cachedToken!;
    }

    final module = await _db.getModule();
    final device = await _db.getDevice();
    if (module == null || module.privateKey == null || device == null) {
      throw Exception('Device not registered or missing private key');
    }
    if (device.deviceId.isEmpty) {
      throw Exception('Device registration is missing deviceId');
    }

    // Use moduleId from Module table (source of truth)
    final moduleId = module.id.toString();
    if (moduleId.isEmpty) {
      throw Exception('Module is missing ID');
    }

    // 1. Generate random hash text
    final hashText = DateTime.now().toIso8601String();

    // 2. Sign the hash text using private key
    final privateKey = RSAPrivateKey.fromPEM(module.privateKey!);
    final signature = privateKey.createSignature(hashText);

    final body = json.encode({
      'moduleId': moduleId,
      'deviceId': device.deviceId,
      'message': hashText, // Server expects 'message', not 'hashText'
      'signature': signature,
    });

    debugPrint('=== Device Token Request ===');
    debugPrint('ModuleId: $moduleId');
    debugPrint('DeviceId: ${device.deviceId}');
    debugPrint('Request Body: $body');

    // 3. Request token
    final response = await http.post(
      Uri.parse('${_settings.backendUrl}/api/devices/device-token'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    debugPrint('=== Device Token Response ===');
    debugPrint('Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      _cachedToken = body['token'];
      return _cachedToken!;
    } else {
      print('Failed to get sync token: ${response.body}');
      throw Exception('Failed to authenticate: ${response.statusCode}');
    }
  }

  Future<void> _sendAcknowledgment(int serverCursor, SyncStatus status) async {
    try {
      final token = await _getSyncToken();
      final body = json.encode({'cursor': serverCursor});

      print('Acknowledgment Body: $body');

      final response = await http.post(
        Uri.parse('${_settings.backendUrl}/api/sync/ack'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode != 200) {
        print('Failed to send acknowledgment: ${response.statusCode}');
      } else {
        print('Acknowledgment sent for cursor: $serverCursor');
      }
    } catch (e) {
      print('Error sending acknowledgment: $e');
    }
  }

  Future<void> _fullSync() async {
    final datasets = ['insurances', 'products', 'productInsurances'];
    final totalSteps = datasets.length;

    print('Starting full sync...');

    for (int i = 0; i < datasets.length; i++) {
      final dataset = datasets[i];
      int page = 0;
      bool hasMore = true;
      int serverCursor = 0;
      bool pendingProductTokenRefresh = false;

      print('Syncing dataset: $dataset');

      while (hasMore) {
        if (pendingProductTokenRefresh) {
          await _getSyncToken(forceRefresh: true);
          pendingProductTokenRefresh = false;
        }
        final token = await _getSyncToken();
        final url = Uri.parse(
          '${_settings.backendUrl}/api/sync/full?dataset=$dataset&page=$page&limit=500',
        );

        print('Requesting $dataset header page $page...');

        final requestStart = DateTime.now();
        final response = await http.get(
          url,
          headers: {'Authorization': 'Bearer $token'},
        );
        final requestDuration = DateTime.now().difference(requestStart);

        if (response.statusCode != 200) {
          if (response.statusCode == 401) {
            // Token expired, clear cache and retry once
            _cachedToken = null;
            continue;
          }
          throw Exception('Failed to fetch $dataset: ${response.statusCode}');
        }

        if (dataset == 'products' && page == 0) {
          if (requestDuration > const Duration(minutes: 5)) {
            pendingProductTokenRefresh = true;
          }
        }

        final body = json.decode(response.body);
        final List<dynamic> data = body['data'];
        hasMore = body['hasMore'] ?? false;
        page = body['nextCursor'] ?? (page + 1); // Use nextCursor for page
        serverCursor = body['serverCursor'] ?? 0;

        print('Received ${data.length} items for $dataset. Has more: $hasMore');

        // Import data into DB
        if (dataset == 'insurances') {
          await _db.importInsurances(data.cast<Map<String, dynamic>>());
        } else if (dataset == 'products') {
          await _db.importProducts(data.cast<Map<String, dynamic>>());
        } else if (dataset == 'productInsurances') {
          await _db.importProductInsurances(data.cast<Map<String, dynamic>>());
        }

        // Update progress (roughly)
        _progress =
            (i / totalSteps) + (1.0 / totalSteps * (hasMore ? 0.5 : 1.0));
        notifyListeners();
      }

      // If it's the last dataset of full sync, we update local state and acknowledge
      if (i == datasets.length - 1) {
        await _settings.updateSyncState(serverCursor, DateTime.now());
        await _settings.setInitialSyncCompleted(true);
        // Send acknowledgment only after the complete full sync sequence
        await _sendAcknowledgment(serverCursor, SyncStatus.success);
        print('Full sync completed. Local cursor updated to: $serverCursor');
      }
    }
  }

  Future<void> _incrementalSync() async {
    bool hasMore = true;
    int sinceCursor = _settings.lastSyncCursor;
    print('Starting incremental sync from cursor: $sinceCursor');

    while (hasMore) {
      final token = await _getSyncToken();
      final url = Uri.parse(
        '${_settings.backendUrl}/api/sync/changes?limit=500',
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          _cachedToken = null;
          continue;
        }
        throw Exception('Failed to fetch changes: ${response.statusCode}');
      }

      final body = json.decode(response.body);
      final List<dynamic> changes = body['changes'];
      hasMore = body['hasMore'] ?? false;
      int serverCursor = body['serverCursor'] ?? sinceCursor;

      print('Received ${changes.length} changes. Server cursor: $serverCursor');

      for (final change in changes) {
        final entity = change['entity'];
        final operation = change['operation'];
        final data = change['data'] as Map<String, dynamic>?;
        final entityId = change['entityId'] as String;

        print('Processing $operation on $entity ($entityId)');

        if (operation == 'DELETE') {
          if (entity == 'insurance') await _db.hardDeleteInsurance(entityId);
          if (entity == 'product') await _db.hardDeleteProduct(entityId);
          if (entity == 'productInsurance')
            await _db.hardDeleteProductInsurance(entityId);
        } else {
          // INSERT or UPDATE
          if (data != null) {
            if (entity == 'insurance') {
              await _db.importInsurance(
                id: data['id'],
                name: data['name'],
                acronym: data['acronym'],
                clientPercentage: (data['clientPercentage'] as num).toDouble(),
                createdAt: DateTime.parse(data['createdAt']),
                updatedAt: DateTime.parse(data['updatedAt']),
                deletedAt: data['deletedAt'] != null
                    ? DateTime.parse(data['deletedAt'])
                    : null,
                version: data['version'],
              );
            } else if (entity == 'product') {
              final metadata = data['metadata'] as Map<String, dynamic>?;
              await _db.importProduct(
                id: data['id'],
                name: data['name'],
                type: ItemType.values.firstWhere(
                  (e) => e.name == data['type'],
                  orElse: () => ItemType.DRUG,
                ),
                description: data['description'],
                sellingUnit: metadata?['sellingUnit'],
                createdAt: DateTime.parse(data['createdAt']),
                updatedAt: DateTime.parse(data['updatedAt']),
                deletedAt: data['deletedAt'] != null
                    ? DateTime.parse(data['deletedAt'])
                    : null,
                version: data['version'],
              );
            } else if (entity == 'productInsurance') {
              await _db.importProductInsurance(
                id: data['id'],
                productId: data['productId'],
                insuranceId: data['insuranceId'],
                code: data['code'],
                unit: Unit.values.firstWhere(
                  (e) => e.name == data['unit'],
                  orElse: () => Unit.UNKNOWN,
                ),
                cost: (data['cost'] as num).toDouble(),
                authorisedLevel: AuthorisedLevel.values.firstWhere(
                  (e) => e.name == data['authorisedLevel'],
                  orElse: () => AuthorisedLevel.All,
                ),
                mustPrescribedBy: MustPrescribedBy.values.firstWhere(
                  (e) => e.name == data['mustPrescribedBy'],
                  orElse: () => MustPrescribedBy.All,
                ),
                utilizationCount: data['utilizationCount'],
                createdAt: DateTime.parse(data['createdAt']),
                updatedAt: DateTime.parse(data['updatedAt']),
                deletedAt: data['deletedAt'] != null
                    ? DateTime.parse(data['deletedAt'])
                    : null,
                version: data['version'],
              );
            }
          }
        }
      }

      // Update local state and acknowledge
      sinceCursor = serverCursor;
      await _settings.updateSyncState(sinceCursor, DateTime.now());
      await _sendAcknowledgment(serverCursor, SyncStatus.success);

      _progress = hasMore ? 0.5 : 1.0;
      notifyListeners();
    }
  }

  /// Sync out: Upload all unsynchronized operational data to server
  /// 
  /// This sends workers, stock movements, and sales data using the CURRENT device keys.
  /// Public key rotation happens independently in the background (every 24 hours).
  /// This method does NOT handle key rotation - it only syncs operational data.
  Future<bool> syncOut({bool fullSync = false}) async {
    if (_status == SyncStatus.syncing) return false;

    _status = SyncStatus.syncing;
    _progress = 0.0;
    _error = null;
    _syncError = null;
    _itemsSynced = 0;
    notifyListeners();

    try {
      // Fetch unsynchronized data
      final workers = await _getUnsyncedWorkers(fullSync);
      final stocksIn = await _getUnsyncedStockIns(fullSync);
      final stocksOut = await _getUnsyncedStockOuts(fullSync);
      final sales = await _getUnsyncedSales(fullSync);

      debugPrint('=== SyncOut Summary ===');
      debugPrint('Workers to sync: ${workers.length}');
      debugPrint('StockIns to sync: ${stocksIn.length}');
      debugPrint('StockOuts to sync: ${stocksOut.length}');
      debugPrint('Sales to sync: ${sales.length}');

      if (workers.isEmpty && stocksIn.isEmpty && stocksOut.isEmpty && sales.isEmpty) {
        debugPrint('No data to sync.');
        _status = SyncStatus.success;
        _progress = 1.0;
        _itemsSynced = 0;
        notifyListeners();
        return true;
      }

      final device = await _db.getDevice();
      if (device == null) {
        _error = 'Device not registered. Cannot sync.';
        _syncError = _error;
        _status = SyncStatus.error;
        notifyListeners();
        return false;
      }

      final module = await _db.getModule();
      if (module?.privateKey == null) {
        _error = 'Missing private key. Cannot sync.';
        _syncError = _error;
        _status = SyncStatus.error;
        notifyListeners();
        return false;
      }

      int totalItems = workers.length + stocksIn.length + stocksOut.length + sales.length;
      int processedItems = 0;

      // Step 1: Sync workers (if any)
      if (workers.isNotEmpty) {
        debugPrint('Syncing ${workers.length} workers...');
        final workersSuccess = await _syncWorkers(
          deviceId: device.deviceId,
          workers: workers,
        );
        if (!workersSuccess) {
          _syncError = _error ?? 'Failed to sync workers';
          _status = SyncStatus.error;
          notifyListeners();
          return false;
        }
        processedItems += workers.length;
        _progress = processedItems / totalItems;
        notifyListeners();
      }

      // Step 2: Sync stocks (if any)
      if (stocksIn.isNotEmpty || stocksOut.isNotEmpty) {
        debugPrint('Syncing stocks (${stocksIn.length} in, ${stocksOut.length} out)...');
        final stocksSuccess = await _syncStocks(
          deviceId: device.deviceId,
          stocksIn: stocksIn,
          stocksOut: stocksOut,
        );
        if (!stocksSuccess) {
          _syncError = _error ?? 'Failed to sync stocks';
          _status = SyncStatus.error;
          notifyListeners();
          return false;
        }
        processedItems += stocksIn.length + stocksOut.length;
        _progress = processedItems / totalItems;
        notifyListeners();
      }

      // Step 3: Sync sales (if any)
      if (sales.isNotEmpty) {
        debugPrint('Syncing ${sales.length} sales...');
        final salesSuccess = await _syncSales(
          deviceId: device.deviceId,
          sales: sales,
        );
        if (!salesSuccess) {
          _syncError = _error ?? 'Failed to sync sales';
          _status = SyncStatus.error;
          notifyListeners();
          return false;
        }
        processedItems += sales.length;
        _progress = processedItems / totalItems;
        notifyListeners();
      }

      // Mark all as synced
      await _markAsSynced(workers, stocksIn, stocksOut, sales);
      _itemsSynced = totalItems;
      _status = SyncStatus.success;
      _progress = 1.0;
      notifyListeners();
      return true;

    } catch (e) {
      _error = 'SyncOut error: $e';
      _syncError = _error;
      debugPrint(_error);
      _status = SyncStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Build standardized signature payload
  /// Format: deviceId|dataJson if data exists, otherwise just deviceId
  /// Build standardized signature payload
  /// Format: deviceId|dataJson if data exists and is not empty
  /// Empty arrays, objects, or null => just deviceId
  String _buildSignaturePayload(String deviceId, [dynamic data]) {
    // Treat null, empty lists, and empty maps as no data
    if (data == null) {
      return deviceId;
    }
    
    if (data is List && data.isEmpty) {
      return deviceId;
    }
    
    if (data is Map && data.isEmpty) {
      return deviceId;
    }
    
    final dataJson = json.encode(data);
    return '$deviceId|$dataJson';
  }

  Future<List<Map<String, dynamic>>> _getUnsyncedWorkers(bool fullSync) async {
    final query = _db.select(_db.users);
    if (!fullSync) {
      query.where((u) => u.lastSyncedAt.isNull());
    }
    final users = await query.get();
    return users
        .map((u) => {
              'id': u.id,
              'name': u.names,
              'phoneNumber': u.phoneNumber,
              'email': u.email,
              'role': u.role.name,
              'isActive': u.deletedAt == null,
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> _getUnsyncedStockIns(
      bool fullSync) async {
    final query = _db.select(_db.stockIns);
    if (!fullSync) {
      query.where((s) => s.lastSyncedAt.isNull());
    }
    final stocks = await query.get();
    return stocks
        .map((s) => {
              'id': s.id,
              'productId': s.productId,
              'quantity': s.quantity,
              'location': s.location,
              'pricePerUnit': s.pricePerUnit,
              'batchNumber': s.batchNumber,
              'expiryDate': s.expiryDate?.toIso8601String(),
              'reorderLevel': s.reorderLevel,
              'userId': s.userId,
              'createdAt': s.createdAt.toIso8601String(),
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> _getUnsyncedStockOuts(
      bool fullSync) async {
    final query = _db.select(_db.stockOuts);
    if (!fullSync) {
      query.where((s) => s.lastSyncedAt.isNull());
    }
    final stocks = await query.get();
    return stocks
        .map((s) => {
              'id': s.id,
              'stockInId': s.stockInId,
              'quantitySold': s.quantitySold,
              'pricePerUnit': s.pricePerUnit,
              'insuranceId': s.insuranceId,
              'itemTotal': s.itemTotal,
              'patientPays': s.patientPays,
              'insurancePays': s.insurancePays,
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> _getUnsyncedSales(bool fullSync) async {
    final query = _db.select(_db.stockOutSales);
    if (!fullSync) {
      query.where((s) => s.lastSyncedAt.isNull());
    }
    final sales = await query.get();
    return sales
        .map((s) => {
              'id': s.id,
              'transactionId': s.transactionId,
              'stockOutId': s.stockOutId,
              'patientName': s.patientName,
              'destinationClinicService': s.destinationClinicService,
              'insuranceCardNumber': s.insuranceCardNumber,
              'issuingCompany': s.issuingCompany,
              'prescriberName': s.prescriberName,
              'prescriberLicenseId': s.prescriberLicenseId,
              'prescribingOrganization': s.prescribingOrganization,
              'totalPrice': s.totalPrice,
              'userId': s.userId,
              'createdAt': s.createdAt.toIso8601String(),
            })
        .toList();
  }

  Future<bool> _syncWorkers({
    required String deviceId,
    required List<Map<String, dynamic>> workers,
  }) async {
    if (workers.isEmpty) return true;

    try {
      final module = await _db.getModule();
      if (module?.privateKey == null) {
        _error = 'Missing private key';
        return false;
      }

      final privateKey = RSAPrivateKey.fromPEM(module!.privateKey!);
      final publicKey = privateKey.publicKey;
      
      final dataPayload = {'workers': workers};
      final signaturePayload = _buildSignaturePayload(deviceId, dataPayload);
      final signature = privateKey.createSignature(signaturePayload);

      final request = {
        'deviceId': deviceId,
        'signature': signature,
        'data': dataPayload,
      };

      debugPrint('=== Sync Workers Request ===');
      debugPrint('DeviceId: $deviceId');
      debugPrint('Workers count: ${workers.length}');
      debugPrint('Signature Payload: $signaturePayload');
      debugPrint('PrivateKey (first 100 chars): ${module.privateKey!.substring(0, 100)}...');
      debugPrint('PublicKey: ${publicKey.toString()}');
      debugPrint('Signature: $signature');

      final response = await http
          .post(
            Uri.parse('${_settings.backendUrl}/api/devices/sync-workers'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(request),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('=== Sync Workers Response ===');
      debugPrint('Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Workers synced successfully');
        return true;
      } else {
        _error = 'Workers sync failed: ${response.statusCode}';
        debugPrint('Error: ${response.body}');
        return false;
      }
    } catch (e) {
      _error = 'Workers sync error: $e';
      debugPrint(_error);
      return false;
    }
  }

  Future<bool> _syncStocks({
    required String deviceId,
    required List<Map<String, dynamic>> stocksIn,
    required List<Map<String, dynamic>> stocksOut,
  }) async {
    if (stocksIn.isEmpty && stocksOut.isEmpty) return true;

    try {
      final module = await _db.getModule();
      if (module?.privateKey == null) {
        _error = 'Missing private key';
        return false;
      }

      final privateKey = RSAPrivateKey.fromPEM(module!.privateKey!);
      final publicKey = privateKey.publicKey;
      
      final dataPayload = {'stocksIn': stocksIn, 'stocksOut': stocksOut};
      final signaturePayload = _buildSignaturePayload(deviceId, dataPayload);
      final signature = privateKey.createSignature(signaturePayload);

      final request = {
        'deviceId': deviceId,
        'signature': signature,
        'stocksIn': stocksIn,
        'stocksOut': stocksOut,
      };

      debugPrint('=== Sync Stocks Request ===');
      debugPrint('DeviceId: $deviceId');
      debugPrint('StocksIn count: ${stocksIn.length}');
      debugPrint('StocksOut count: ${stocksOut.length}');
      debugPrint('Signature Payload: $signaturePayload');
      debugPrint('PrivateKey (first 100 chars): ${module.privateKey!.substring(0, 100)}...');
      debugPrint('PublicKey: ${publicKey.toString()}');
      debugPrint('Signature: $signature');

      final response = await http
          .post(
            Uri.parse('${_settings.backendUrl}/api/stocks/sync'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(request),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('=== Sync Stocks Response ===');
      debugPrint('Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Stocks synced successfully');
        return true;
      } else {
        _error = 'Stocks sync failed: ${response.statusCode}';
        debugPrint('Error: ${response.body}');
        return false;
      }
    } catch (e) {
      _error = 'Stocks sync error: $e';
      debugPrint(_error);
      return false;
    }
  }

  Future<bool> _syncSales({
    required String deviceId,
    required List<Map<String, dynamic>> sales,
  }) async {
    if (sales.isEmpty) return true;

    try {
      final module = await _db.getModule();
      if (module?.privateKey == null) {
        _error = 'Missing private key';
        return false;
      }

      final privateKey = RSAPrivateKey.fromPEM(module!.privateKey!);
      final publicKey = privateKey.publicKey;
      
      final dataPayload = {
        'sales': sales,
        'period': 'MANUAL',
      };
      final signaturePayload = _buildSignaturePayload(deviceId, dataPayload);
      final signature = privateKey.createSignature(signaturePayload);

      final request = {
        'deviceId': deviceId,
        'signature': signature,
        'data': dataPayload,
      };

      debugPrint('=== Sync Sales Request ===');
      debugPrint('DeviceId: $deviceId');
      debugPrint('Sales count: ${sales.length}');
      debugPrint('Signature Payload: $signaturePayload');
      debugPrint('PrivateKey (first 100 chars): ${module.privateKey!.substring(0, 100)}...');
      debugPrint('PublicKey: ${publicKey.toString()}');
      debugPrint('Signature: $signature');

      final response = await http
          .post(
            Uri.parse('${_settings.backendUrl}/api/devices/sales-snapshot'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(request),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('=== Sync Sales Response ===');
      debugPrint('Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Sales synced successfully');
        return true;
      } else {
        _error = 'Sales sync failed: ${response.statusCode}';
        debugPrint('Error: ${response.body}');
        return false;
      }
    } catch (e) {
      _error = 'Sales sync error: $e';
      debugPrint(_error);
      return false;
    }
  }

  Future<void> _markAsSynced(
    List<Map<String, dynamic>> workers,
    List<Map<String, dynamic>> stocksIn,
    List<Map<String, dynamic>> stocksOut,
    List<Map<String, dynamic>> sales,
  ) async {
    final now = DateTime.now();

    for (final worker in workers) {
      await (_db.update(_db.users)..where((u) => u.id.equals(worker['id'])))
          .write(UsersCompanion(lastSyncedAt: Value(now)));
    }

    for (final stock in stocksIn) {
      await (_db.update(_db.stockIns)..where((s) => s.id.equals(stock['id'])))
          .write(StockInsCompanion(lastSyncedAt: Value(now)));
    }

    for (final stock in stocksOut) {
      await (_db.update(_db.stockOuts)..where((s) => s.id.equals(stock['id'])))
          .write(StockOutsCompanion(lastSyncedAt: Value(now)));
    }

    for (final sale in sales) {
      await (_db.update(_db.stockOutSales)..where((s) => s.id.equals(sale['id'])))
          .write(StockOutSalesCompanion(lastSyncedAt: Value(now)));
    }

    debugPrint('All synced data marked with lastSyncedAt timestamp.');
  }
}
