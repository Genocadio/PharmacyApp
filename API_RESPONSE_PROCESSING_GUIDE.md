# API Response Processing & Module Management Guide

## Overview

This document describes the complete API response processing system for handling device status, worker synchronization, sales snapshots, and payment method management based on the Device Management API specification.

## Key API Endpoints & Response Processing

### 1. Device Status Endpoint (`POST /api/devices/status`)

**Purpose**: Heartbeat & status check - updates device configuration from server and retrieves pending commands.

**Response contains**:
- `data`: Full DeviceDTO with current device configuration
- `module`: Complete ModuleResponse including all module settings
- `status`: DeviceStatusDTO with activation and sync flags
- `commands`: Pending commands to be processed

**Processing Flow**:
```
API Response → DeviceApiResponse<DeviceDTO> parsed
                    ↓
Module data → _db.saveModule() → Database updated
Device data → _db.saveDevice() → Database updated
Status data → _db.updateDeviceLocal() → Activation status updated
Commands → Logged for future processing
                    ↓
DeviceStateManager.notifyListeners()
                    ↓
All listening screens auto-rebuild with new state
```

**Implementation** (lib/services/activation_service.dart:):
```dart
final apiResponse = DeviceApiResponse<DeviceDTO>.fromJson(
  body,
  parseData: (data) => DeviceDTO.fromJson(data as Map<String, dynamic>),
);

// Process module information including payment methods
if (response.module != null) {
  await _db.saveModule(response.module!, privateKey: privateKeyOverride);
  debugPrint('💳 Payment Methods (${response.module!.paymentMethods.length}):');
  for (final pm in response.module!.paymentMethods) {
    debugPrint('  - ${pm.type}: ${pm.account} (${pm.currency ?? 'N/A'})');
  }
}

// Process device data
if (response.data is DeviceDTO) {
  await _db.saveDevice(device, moduleId: fallbackModuleId);
  await _settings.updateDeviceRole(_mapDeviceRole(device.deviceType));
}

// Process status changes
if (response.status != null) {
  await _db.updateDeviceLocal(
    activationStatus: newStatus,
    supportMultiUsers: response.status!.supportMultiUsers,
  );
}
```

---

### 2. Sync Workers Endpoint (`POST /api/devices/sync-workers`)

**Purpose**: Synchronize user profiles from server for multi-user support.

**Request**:
```json
{
  "deviceId": "device-uuid",
  "signature": "signed-payload",
  "data": {
    "workers": [
      {
        "workerId": "uuid",
        "firstName": "John",
        "lastName": "Doe",
        "phone": "...",
        "email": "...",
        "role": "PHARMACIST",
        "pin": "hashed-pin",
        "active": true,
        "version": 1,
        "deletedAt": null
      }
    ]
  }
}
```

**Response contains**:
- `data`: List<WorkerDTO> of synced users
- `module`: Updated module configuration
- `status`: Device status after sync
- `commands`: Any pending commands

**Processing Flow**:
```
API Response → DeviceApiResponse<List<WorkerDTO>> parsed
                    ↓
Workers → _db.saveWorkers(moduleId, list) → Database cleared & repopulated
Module → _db.saveModule() → Module updated
Status → _db.updateDeviceLocal() → Device status updated
                    ↓
Notify screens about worker list change
```

**Implementation** (lib/services/sync_service.dart):
```dart
final apiResponse = DeviceApiResponse<List<WorkerDTO>>.fromJson(
  body,
  parseData: (data) {
    if (data == null) return [];
    return (data as List)
        .map((w) => WorkerDTO.fromJson(w as Map<String, dynamic>))
        .toList();
  },
);

// Save workers to database
if (apiResponse.data != null && apiResponse.data!.isNotEmpty) {
  await _db.saveWorkers(module.id, apiResponse.data!);
  debugPrint('✅ Saved ${apiResponse.data!.length} workers to database');
}

// Process module updates from response
if (apiResponse.module != null) {
  await _db.saveModule(apiResponse.module!);
  debugPrint('✅ Module information updated');
}
```

---

### 3. Sales Snapshot Endpoint (`POST /api/devices/sales-snapshot`)

**Purpose**: Submit sales records for auditing and reporting.

**Request**:
```json
{
  "deviceId": "device-uuid",
  "signature": "signed-payload",
  "data": {
    "sales": [
      {
        "id": "uuid",
        "transactionId": "ref-123",
        "stockOutId": "uuid",
        "patientName": "Jane Smith",
        "totalPrice": 45.50,
        "userId": "uuid",
        "createdAt": "2024-02-18T10:30:00Z"
      }
    ],
    "period": "MANUAL"
  }
}
```

**Response contains**:
- `module`: Updated module configuration
- `status`: Device status after sales submission
- `commands`: Pending commands from server

**Processing Flow**:
```
API Response → DeviceApiResponse<void> parsed
                    ↓
Module → _db.saveModule() → Module updated
Status → _db.updateDeviceLocal() → Device status updated
Commands → Logged for processing
                    ↓
Notify about sync completion
```

**Implementation** (lib/services/sync_service.dart):
```dart
final apiResponse = DeviceApiResponse<void>.fromJson(body);

// Process module updates
if (apiResponse.module != null) {
  await _db.saveModule(apiResponse.module!);
  debugPrint('✅ Module information updated from sales sync');
}

// Process device status updates
if (apiResponse.status != null) {
  final newStatus = apiResponse.status!.isActive
      ? ActivationStatus.ACTIVE
      : ActivationStatus.INACTIVE;
  await _db.updateDeviceLocal(
    activationStatus: newStatus,
    supportMultiUsers: apiResponse.status!.supportMultiUsers,
  );
  debugPrint('✅ Device status updated from sales sync');
}
```

---

### 4. Acknowledge Command Endpoint (`POST /api/devices/acknowledge-command`)

**Purpose**: Notify server that a device command has been processed.

**Request**:
```json
{
  "deviceId": "device-uuid",
  "signature": "signed-payload",
  "data": {
    "commandId": 12345
  }
}
```

**Response**:
- `data`: DeviceDTO with current device state
- `module`: Updated module info
- `status`: Current device status

**Processing**: Same as device status endpoint - full response is digested and processed.

---

### 5. Update Public Key Endpoint (`POST /api/devices/update-public-key`)

**Purpose**: Rotate device cryptographic keys for security.

**Request**:
```json
{
  "deviceId": "device-uuid",
  "signature": "signed-with-new-key",
  "data": {
    "newPublicKey": "-----BEGIN PUBLIC KEY-----..."
  }
}
```

**Response**:
- `data`: DeviceDTO confirming key rotation
- `module`: Updated module info with new public key
- `status`: Device status

**Processing**: Same as device status - full DeviceDTO is parsed and saved.

---

## Database Tables & Data Storage

### PaymentMethods Table
Stores module payment configurations received from server.

```dart
class PaymentMethods extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get moduleId => integer().references(Modules, #id)();
  TextColumn get account => text()();          // Account/phone number
  TextColumn get currency => text().nullable(); // Currency code
  TextColumn get type => text()();             // MOMO, Bank, Card, etc.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

**Managed by**: `_db.saveModule()` → automatically calls `_savePaymentMethods()`

**Retrieve**: 
```dart
final methods = await _db.getPaymentMethodsByModule(moduleId);
```

### Workers Table
Stores user profiles synced from server for multi-user support.

```dart
class Workers extends Table {
  TextColumn get id => text()();                    // UUID from server
  IntColumn get moduleId => integer().references(Modules, #id)();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get role => textEnum<UserRole>()();   // PHARMACIST, OWNER, etc.
  TextColumn get pinHash => text().nullable()();   // Hashed PIN
  BoolColumn get active => boolean().withDefault(true)();
  IntColumn get version => integer().withDefault(0)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

**Managed by**: `_db.saveWorkers(moduleId, List<WorkerDTO>)`  
**Retrieve**: `await _db.getWorkersByModule(moduleId)`

---

## DTO Classes & Parsing

### ModuleResponse (Enhanced)
```dart
class ModuleResponse {
  // ... existing fields ...
  final List<ModulePaymentMethod> paymentMethods;
  
  factory ModuleResponse.fromJson(Map<String, dynamic> json) {
    final paymentMethodsList = <ModulePaymentMethod>[];
    if (json['paymentMethods'] != null) {
      paymentMethodsList.addAll(
        (json['paymentMethods'] as List).map(
          (pm) => ModulePaymentMethod.fromJson(pm as Map<String, dynamic>),
        ),
      );
    }
    // ... rest of parsing ...
  }
}
```

### ModulePaymentMethod
```dart
class ModulePaymentMethod {
  final int? id;
  final String account;
  final String? currency;
  final String type; // MOMO, Bank, Card, etc.
  
  factory ModulePaymentMethod.fromJson(Map<String, dynamic> json) => ...
}
```

### WorkerDTO
```dart
class WorkerDTO {
  final String id;                    // UUID
  final String firstName;
  final String lastName;
  final String? phone;
  final String? email;
  final UserRole role;                // PHARMACIST, OWNER, NURSE, etc.
  final String? pinHash;              // Hashed PIN
  final bool active;
  final int version;
  final DateTime? deletedAt;
  
  factory WorkerDTO.fromJson(Map<String, dynamic> json) => ...
}
```

---

## Complete Response Handling Flow

```
Endpoint Call (e.g., updateDeviceStatus)
         ↓
HTTP Response received with statusCode 200/201
         ↓
Response body parsed as JSON
         ↓
DeviceApiResponse<T>.fromJson() with parseData closure
         ↓
_handleDeviceApiResponse(response) called
         ↓
┌─────────────────────────────────────────┐
│ Check if fresh activation (new deviceId)│
└─────────────────────────────────────────┘
         ↓
IF module != null:
  • _db.saveModule() → saves module + payment methods
  • Log payment methods info
  • Check expiration warning
         ↓
IF data is DeviceDTO:
  • _db.saveDevice() → saves device config
  • _settings.updateDeviceRole()
         ↓
IF status != null:
  • _db.updateDeviceLocal() → updates activation/multiuser flags
  • Check for status changes
  • Handle deactivation event
  • Handle multi-user changes
         ↓
IF commands.isNotEmpty:
  • Log commands for future processing
         ↓
_refreshActivationState()
         ↓
DeviceStateManager.notifyListeners()
         ↓
All listening screens rebuild with updated state
```

---

## Real-World Scenarios

### Scenario 1: Module Payment Configuration Update
```
Server: Adds new M-Pesa payment method
         ↓
API Response includes updated paymentMethods list
         ↓
_db.saveModule() is called
         ↓
_savePaymentMethods() deletes old methods & inserts new ones
         ↓
Database now reflects: MOMO, M-PESA, Bank Transfer
         ↓
UI can query and display available payment methods
```

### Scenario 2: New User Added by Admin
```
Server: Creates new pharmacist user
         ↓
Next sync-workers call returns updated list
         ↓
_db.saveWorkers() replaces all workers
         ↓
New user now available in multi-user login
```

### Scenario 3: Device Deactivation
```
Server: Deactivates device for non-payment
         ↓
API Response status.isActive = false
         ↓
_handleDeviceApiResponse detects change
         ↓
_authService.logout() called
         ↓
User notification shown
         ↓
App redirects to activation screen
```

---

## Debugging & Logging

All response processing includes detailed logging:

```
=== Device Status Processed ===
Device Type: PHARMACY_RETAIL
Device Status: ACTIVE
Multi-User Support: false

💳 Payment Methods (2):
  - MOMO: +256701234567 (UGX)
  - Bank: 1234567890 (UGX)

👥 Workers (3):
  - John Doe (PHARMACIST, active)
  - Jane Smith (NURSE, active)
  - Bob Johnson (ASSISTANT, active)

📋 Received 1 command(s):
  - [123] UPDATE_PRICE (PENDING)
```

---

## Database Migration

When deploying changes to production:

1. Tables automatically created on first app launch
2. Schema version incremented: `schemaVersion => 11`
3. Migration strategy handles table creation:
```dart
if (from < 11) {
  await m.createTable(paymentMethods);
  await m.createTable(workers);
}
```

---

## Testing Checklist

- [ ] Status endpoint returns with payment methods → methods saved to DB
- [ ] Sync workers endpoint returns list → workers replaced in DB
- [ ] Sales endpoint returns module updates → module config updated
- [ ] Device type change reflected in UI immediately
- [ ] Multi-user support flag change enables/disables user management
- [ ] Payment methods available in checkout screen
- [ ] Worker list available in multi-user login
- [ ] Commands logged when received
- [ ] Deactivation triggers logout properly
- [ ] Module expiration warning shows at 15 days

---

## Files Modified

✅ `lib/data/tables.dart` - Added PaymentMethods & Workers tables
✅ `lib/services/dto/activation_dto.dart` - Added ModulePaymentMethod & WorkerDTO
✅ `lib/data/database.dart` - Added CRUD methods & schema v11
✅ `lib/services/activation_service.dart` - Enhanced response processing logging
✅ `lib/services/sync_service.dart` - Workers & sales endpoint response processing

All changes compile without errors ✅
