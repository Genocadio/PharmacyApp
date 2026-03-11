# NexxStore API Integration Guide

## Overview

NexxStore communicates with backend services via secure, signed RESTful APIs. This document details the API architecture, authentication mechanism, endpoints, and integration patterns used throughout the application.

## Table of Contents

1. [API Architecture](#api-architecture)
2. [Authentication & Security](#authentication--security)
3. [Request/Response Format](#requestresponse-format)
4. [Core API Endpoints](#core-api-endpoints)
5. [Synchronization Protocol](#synchronization-protocol)
6. [Device Activation](#device-activation)
7. [Error Handling](#error-handling)
8. [Integration Patterns](#integration-patterns)
9. [Troubleshooting](#troubleshooting)

## API Architecture

### API Server Configuration

NexxStore connects to a backend API server. Configuration is set during device activation.

### API Communication Flow

```
┌─────────────────────┐
│   Mobile/Desktop    │
│     Application     │
└──────────┬──────────┘
           │
    1. Sign Request
    2. Add Headers
    3. POST/GET/etc
           │
           ↓
┌─────────────────────┐
│   API Gateway       │
│  - Load Balancer    │
│  - Rate Limiting    │
└──────────┬──────────┘
           │
    4. Verify Signature
    5. Check Device Auth
    6. Route Request
           │
           ↓
┌──────────────────────────────┐
│   Backend Services           │
│  - Auth Service              │
│  - Inventory Service         │
│  - Sync Service              │
│  - Activation Service        │
└──────────┬───────────────────┘
           │
    7. Process Business Logic
    8. Update Backend DB
           │
           ↓
┌─────────────────────┐
│   Response          │
│  - Status Code      │
│  - Data/Error       │
│  - Signature        │
└─────────────────────┘
```

## Authentication & Security

### Request Signing with Crypton

All requests to NexxStore API must be cryptographically signed using the device's private key:

```dart
// Using crypton for RSA signing
import 'package:crypton/crypton.dart';

class ApiSigningService {
  late RSAPrivateKey _privateKey;
  late RSAPublicKey _publicKey;

  Future<void> initializeKeys() async {
    // Load keys from secure storage
    final keyPair = RSAKeyPair.fromRandom();
    _privateKey = keyPair.privateKey;
    _publicKey = keyPair.publicKey;
  }

  String signRequest(String requestBody, String timestamp) {
    // Create signature
    final signature = _privateKey.createSignature(requestBody + timestamp);
    return base64Encode(signature);
  }

  bool verifyResponse(String response, String signature) {
    // Verify server response signature
    return _publicKey.verifySignature(response, base64Decode(signature));
  }
}
```

### Request Headers

Every API request includes authentication headers:

```dart
final headers = {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $authToken',
  'X-Device-ID': deviceId,
  'X-Timestamp': timestamp,
  'X-Signature': signature,
  'X-API-Version': 'v1',
};
```

### API Token Management

```dart
class AuthService {
  String? _accessToken;
  DateTime? _tokenExpiresAt;

  Future<String> getValidToken() async {
    // Return existing token if still valid
    if (_accessToken != null && 
        _tokenExpiresAt != null &&
        DateTime.now().isBefore(_tokenExpiresAt!)) {
      return _accessToken!;
    }

    // Refresh expired token
    final newToken = await _refreshToken();
    return newToken;
  }

  Future<String> _refreshToken() async {
    // Call /auth/refresh endpoint
    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: _buildHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      _tokenExpiresAt = DateTime.now().add(
        Duration(seconds: data['expires_in']),
      );
      return _accessToken!;
    } else {
      throw AuthTokenRefreshException();
    }
  }
}
```

## Request/Response Format

### Standard Request Format

```json
{
  "method": "POST",
  "endpoint": "/sync/upload-transactions",
  "timestamp": "2026-03-05T10:30:00Z",
  "device_id": "DEVICE-ABC123XYZ789",
  "payload": {
    "transactions": [
      {
        "id": 1,
        "type": "sale",
        "data": {...}
      }
    ]
  }
}
```

### Standard Response Format

```json
{
  "status": "success",
  "code": 200,
  "message": "Transaction processed successfully",
  "data": {
    "sync_id": "SYNC-12345",
    "processed_count": 5,
    "failed_count": 0,
    "next_sync_after": "2026-03-05T10:45:00Z"
  },
  "timestamp": "2026-03-05T10:30:05Z",
  "signature": "MIIBIjANBgkqhk...base64_signature..."
}
```

### Response Status Codes

| Code | Meaning | Action |
|------|---------|--------|
| 200 | Success | Process response normally |
| 201 | Created | Resource created successfully |
| 400 | Bad Request | Fix request format and retry |
| 401 | Unauthorized | Refresh auth token and retry |
| 402 | Device Not Activated | Activate device first |
| 403 | Forbidden | User lacks permission for this action |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Data conflict (sync issue) - resolve locally |
| 429 | Too Many Requests | Rate limited - implement backoff |
| 500 | Server Error | Retry with exponential backoff |
| 503 | Service Unavailable | Server maintenance - retry later |

## Core API Endpoints

### Authentication Endpoints

#### POST /auth/login
**Purpose:** User login
```dart
// Request
{
  "username": "pharmacist@pharmacy.com",
  "password": "hashed_password"
}

// Response (200)
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
  "expires_in": 3600,
  "user_id": 1,
  "user_role": "admin"
}
```

#### POST /auth/refresh
**Purpose:** Refresh expired access token
```dart
// Request
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}

// Response (200)
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "expires_in": 3600
}
```

#### POST /auth/logout
**Purpose:** User logout
```dart
// Request (no body, uses Authorization header)

// Response (200)
{
  "message": "Logged out successfully"
}
```

### Device Management Endpoints

#### POST /device/register
**Purpose:** Register new device
```dart
// Request
{
  "device_id": "DEVICE-ABC123XYZ789",
  "device_name": "Pharmacy Counter 1",
  "device_type": "android",
  "os_version": "11.0",
  "app_version": "1.0.0"
}

// Response (201)
{
  "device_id": "DEVICE-ABC123XYZ789",
  "status": "pending_activation",
  "public_key": "-----BEGIN PUBLIC KEY-----\n...\n-----END PUBLIC KEY-----"
}
```

#### POST /device/activate
**Purpose:** Activate registered device
```dart
// Request
{
  "device_id": "DEVICE-ABC123XYZ789",
  "activation_code": "NEXX-2026-MARCH-12345"
}

// Response (200)
{
  "status": "activated",
  "pharmacy_id": 42,
  "permissions": ["sales", "inventory", "reports"],
  "sync_frequency": 900
}
```

#### GET /device/status
**Purpose:** Get device status and sync info
```dart
// Response (200)
{
  "device_id": "DEVICE-ABC123XYZ789",
  "is_activated": true,
  "last_sync": "2026-03-05T10:30:00Z",
  "pending_syncs": 0,
  "sync_errors": [],
  "offline_capable": true
}
```

### Synchronization Endpoints

#### POST /sync/upload-transactions
**Purpose:** Upload local transactions to backend
```dart
// Request
{
  "transactions": [
    {
      "id": 1001,
      "type": "sale",
      "timestamp": "2026-03-05T09:15:00Z",
      "data": {
        "items": [...],
        "total": 1500.00
      }
    },
    {
      "id": 1002,
      "type": "stock_adjustment",
      "timestamp": "2026-03-05T09:20:00Z",
      "data": {...}
    }
  ]
}

// Response (200)
{
  "sync_id": "SYNC-20260305-001",
  "processed": 2,
  "failed": 0,
  "conflicts": [],
  "next_sync_after": 900
}
```

#### GET /sync/download-updates
**Purpose:** Download backend updates for device
```dart
// Response (200)
{
  "products": [
    {
      "id": 101,
      "sku": "MED-001",
      "name": "Aspirin 500mg",
      "price": 5.50
    }
  ],
  "inventory_adjustments": [...],
  "user_updates": [...],
  "settings": {...}
}
```

### Inventory Endpoints

#### GET /inventory/products
**Purpose:** Fetch product catalog
```dart
// Response (200)
{
  "products": [
    {
      "id": 1,
      "sku": "MED-001",
      "name": "Paracetamol 500mg",
      "category": "Analgesic",
      "cost_price": 2.50,
      "selling_price": 5.00,
      "stock_quantity": 150
    }
  ],
  "total": 245,
  "page": 1
}
```

#### POST /inventory/stock-adjustment
**Purpose:** Adjust stock for inventory discrepancies
```dart
// Request
{
  "product_id": 1,
  "quantity_adjustment": -5,
  "reason": "Physical count discrepancy",
  "verified_by": "pharmacist@pharmacy.com"
}

// Response (200)
{
  "adjustment_id": "ADJ-12345",
  "new_stock_level": 145,
  "timestamp": "2026-03-05T10:35:00Z"
}
```

### Sales Endpoints

#### POST /sales/create-transaction
**Purpose:** Create a new sale transaction
```dart
// Request
{
  "mode": "retail",
  "items": [
    {
      "product_id": 1,
      "quantity": 2,
      "unit_price": 5.00
    },
    {
      "product_id": 5,
      "quantity": 1,
      "unit_price": 12.50
    }
  ],
  "customer_id": null,
  "payment_method": "cash",
  "discount": 0
}

// Response (201)
{
  "transaction_id": 1001,
  "transaction_number": "TXN-20260305-001",
  "total_amount": 22.50,
  "invoice_ready": true
}
```

#### GET /sales/invoice/:id
**Purpose:** Download invoice data
```dart
### Sync Queue

Pending transactions for cloud synchronization.

```
sync_queue
├── id: integer (PRIMARY KEY)
├── entity_type: text (sale, stock, user_action)
├── entity_id: integer
├── operation: text (create, update, delete)
├── payload: text (JSON)
├── retry_count: integer
├── last_retry_at: datetime (nullable)
├── is_synced: boolean
├── created_at: datetime
└── synced_at: datetime (nullable)
```

**Purpose:** Queue transactions for reliable backend sync

#### 9. Settings

Application configuration stored locally.

```
settings
├── id: integer (PRIMARY KEY)
├── user_id: integer (FOREIGN KEY → users, nullable)
├── key: text (UNIQUE)
├── value: text
└── updated_at: datetime
```

**Purpose:** Store user/app preferences (printer, sync interval, theme, etc.)

#### 10. Audit Log

Comprehensive audit trail for compliance.

```
audit_logs
├── id: integer (PRIMARY KEY)
├── user_id: integer (FOREIGN KEY → users)
├── action: text (login, sale, stock_adjustment, etc.)
├── entity_type: text (product, sale, user, etc.)
├── entity_id: integer (nullable)
├── old_values: text (JSON, nullable)
├── new_values: text (JSON, nullable)
├── ip_address: text (nullable)
├── device_id: text
├── created_at: datetime
└── details: text (nullable)
```

**Purpose:** Compliance and security auditing

## Scheduled Sync Flow

NexxStore performs periodic synchronization:

```dart
class SyncService {
  final _syncInterval = Duration(minutes: 15);

  Future<void> startPeriodicSync() async {
    Timer.periodic(_syncInterval, (_) async {
      await synchronize();
    });
  }

  Future<void> synchronize() async {
    try {
      // 1. Check offline status
      if (!await isConnected()) {
        _logger.info('Offline mode - skipping sync');
        return;
      }

      // 2. Upload local changes
      await _uploadTransactions();

      // 3. Download backend updates
      await _downloadUpdates();

      // 4. Resolve conflicts if any
      await _resolveConflicts();

      // 5. Update last sync time
      await _updateSyncStatus(
        status: 'synced',
        lastSyncAt: DateTime.now(),
      );

      _notifySuccess();
    } catch (e) {
      _logger.error('Sync failed: $e');
      _notifyError(e);
    }
  }

  Future<void> _uploadTransactions() async {
    // Get pending transactions from local DB
    final pending = await _database.getPendingSyncs();

    if (pending.isEmpty) return;

    // Batch upload to server
    final response = await _uploadBatch(pending, batchSize: 50);

    // Mark as synced locally
    for (final transaction in pending) {
      await _database.markAsSynced(transaction.id);
    }
  }

  Future<void> _downloadUpdates() async {
    final response = await _apiClient.get(
      '/sync/download-updates',
      queryParameters: {
        'since': _lastSyncTimestamp.toIso8601String(),
      },
    );

    // Process updates and store locally
    await _processDownloadedData(response.data);
  }
}
```

### Conflict Resolution

When server and local data conflict:

```dart
class ConflictResolutionStrategy {
  // Strategy 1: Last-write-wins (default)
  Future<void> lastWriteWins(SyncConflict conflict) async {
    if (conflict.localTimestamp.isAfter(conflict.serverTimestamp)) {
      // Local change is newer - upload it
      await _uploadLocalChange(conflict);
    } else {
      // Server change is newer - download it
      await _downloadServerChange(conflict);
    }
  }

  // Strategy 2: Custom merge
  Future<void> customMerge(SyncConflict conflict) async {
    final merged = _mergeData(
      localData: conflict.localData,
      serverData: conflict.serverData,
    );
    await _applyMerged(merged);
  }

  // Strategy 3: Manual resolution (prompt user)
  Future<void> promptUser(SyncConflict conflict) async {
    final resolution = await _showConflictDialog(conflict);
    if (resolution == ConflictResolution.useLocal) {
      await _uploadLocalChange(conflict);
    } else {
      await _downloadServerChange(conflict);
    }
  }
}
```

## Device Activation

### Activation Workflow

```
1. Device Registers
   └─> Generate RSA Key Pair
   └─> Send public key to backend
   └─> Get Device ID

2. Administrator Activates Device
   └─> Generate Activation Code
   └─> Provide code to device owner

3. Device Activates
   └─> Submit Device ID + Activation Code
   └─> Receive permissions and settings
   └─> Start synchronization
```

### Activation Code Generation (Backend)

```dart
class ActivationService {
  String generateActivationCode(String deviceId, String pharmacyId) {
    // Format: NEXX-YYYY-MMDD-XXXXXX
    final date = DateTime.now();
    final randomPart = _generateRandomString(6);
    return 'NEXX-${date.year}-${date.month.toString().padLeft(2, '0')}'
           '${date.day.toString().padLeft(2, '0')}-$randomPart';
  }

  Future<bool> validateActivationCode(
    String deviceId,
    String code,
  ) async {
    // Verify code against stored codes
    // Check code hasn't expired
    // Check device not already activated
    return _isValidCode(deviceId, code);
  }
}
```

## Error Handling

### Network Error Handling

```dart
class ApiClient {
  Future<Response> request(String endpoint, {required String method}) async {
    try {
      final response = await _http.request(
        method,
        Uri.parse('$_baseUrl$endpoint'),
        headers: _buildHeaders(),
      ).timeout(Duration(seconds: 30));

      return _handleResponse(response);
    } on SocketException catch (e) {
      throw NetworkException('No internet connection');
    } on TimeoutException catch (e) {
      throw NetworkException('Request timeout');
    } on FormatException catch (e) {
      throw NetworkException('Invalid response format');
    }
  }

  Response _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return Response.success(response);

      case 400:
        throw BadRequestException(response.body);

      case 401:
        throw UnauthorizedException('Please log in again');

      case 402:
        throw DeviceNotActivatedException(
          'Device must be activated. Contact administrator.'
        );

      case 409:
        throw SyncConflictException(response.body);

      case 429:
        throw RateLimitedException(
          'Too many requests. Please try again later.'
        );

      case 500:
        throw ServerException('Server error. Please try again later.');

      default:
        throw UnknownException('Unknown error occurred.');
    }
  }
}
```

### Retry Logic with Exponential Backoff

```dart
class RetryStrategy {
  Future<T> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
  }) async {
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempt++;

        if (attempt >= maxRetries) rethrow;

        // Exponential backoff: 1s, 2s, 4s
        final delay = Duration(seconds: pow(2, attempt - 1).toInt());
        await Future.delayed(delay);
      }
    }

    throw Exception('Max retries exceeded');
  }
}

// Usage
final result = await retryStrategy.executeWithRetry(
  () => apiClient.get('/inventory/products'),
  maxRetries: 3,
);
```

## Integration Patterns

### Service Locator for Dependency Injection

```dart
// Setup (main.dart)
final serviceLocator = GetIt.instance;

void setupServiceLocator() {
  // Register database
  serviceLocator.registerSingleton<AppDatabase>(
    AppDatabase(),
  );

  // Register HTTP client
  serviceLocator.registerSingleton<http.Client>(
    http.Client(),
  );

  // Register API service
  serviceLocator.registerSingleton<ApiService>(
    ApiService(
      client: serviceLocator<http.Client>(),
      database: serviceLocator<AppDatabase>(),
    ),
  );

  // Register other services
  serviceLocator.registerSingleton<AuthService>(
    AuthService(apiService: serviceLocator<ApiService>()),
  );

  serviceLocator.registerSingleton<SyncService>(
    SyncService(
      apiService: serviceLocator<ApiService>(),
      database: serviceLocator<AppDatabase>(),
    ),
  );
}

// Usage anywhere in the app
final authService = serviceLocator<AuthService>();
final syncService = serviceLocator<SyncService>();
```

### Reactive State Management

```dart
class InventoryViewModel with ChangeNotifier {
  final SyncService _syncService = serviceLocator<SyncService>();

  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _syncService.getProducts();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// In Widget
Consumer<InventoryViewModel>(
  builder: (context, viewModel, _) {
    if (viewModel.isLoading) {
      return LoadingWidget();
    }
    return ProductListWidget(products: viewModel.products);
  },
)
```

## Troubleshooting

### Common API Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `401 Unauthorized` | Token expired | Refresh token automatically |
| `402 Device Not Activated` | No activation | Complete device activation |
| `409 Conflict` | Data mismatch | Resolve conflict locally |
| `429 Rate Limited` | Too many requests | Implement exponential backoff |
| `Connection timeout` | Network issue | Retry with offline fallback |

### Debugging API Calls

```dart
// Enable HTTP logging in debug mode
void setupHttpLogging() {
  if (kDebugMode) {
    HttpClient().badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
  }
}

// Log all requests/responses
class LoggingHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    print('>>> Request: ${request.method} ${request.url}');
    print('>>> Headers: ${request.headers}');

    final response = await _inner.send(request);

    print('<<< Status: ${response.statusCode}');
    print('<<< Headers: ${response.headers}');

    return response;
  }
}
```

## Related Documentation

- **Programming Guide:** [PROGRAMMING_GUIDE.md](PROGRAMMING_GUIDE.md)
- **Database Architecture:** [DATABASE_ARCHITECTURE.md](DATABASE_ARCHITECTURE.md)
- **User Guide:** [USER_GUIDE.md](USER_GUIDE.md)
- **Repository:** [GitHub](https://github.com/Genocadio/PharmacyApp)

---

**NexxStore API Integration Guide v1.0** | Last Updated: March 2026
