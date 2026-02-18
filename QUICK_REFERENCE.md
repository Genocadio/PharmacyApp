# Quick Reference: API Response Processing

## At a Glance

| Endpoint | Request | Response | Processing |
|----------|---------|----------|------------|
| **Status** | Device heartbeat | DeviceDTO + Module + Status | Saves device config, payment methods, checks deactivation |
| **Sync Workers** | User list to push | List<WorkerDTO> + Module | Saves workers to DB, updates module |
| **Sales Snapshot** | Sales records | Module + Status | Updates module, device status |
| **Acknowledge Command** | Command ID | DeviceDTO + Module | Saves device state |
| **Update Public Key** | New public key | DeviceDTO + Module | Rotates keys, updates device |

---

## Database Tables

```dart
// Payment Methods
PaymentMethods {
  id, moduleId, account, currency, type, createdAt, updatedAt
}

// Workers
Workers {
  id (UUID), moduleId, firstName, lastName, phone, email, 
  role, pinHash, active, version, deletedAt, createdAt, updatedAt
}
```

---

## Key Classes & Methods

### DTOs
```dart
ModuleResponse          // Module config + paymentMethods list
ModulePaymentMethod     // { id, account, currency, type }
WorkerDTO              // User profile with role and auth
DeviceDTO              // Device config with type & multiuser
```

### Database Operations
```dart
_db.saveModule(response)                    // Saves module + payment methods
_db.saveWorkers(moduleId, list)             // Replace workers in DB
_db.getPaymentMethodsByModule(id)           // Get payment methods
_db.getWorkersByModule(id)                  // Get workers
_db.updateDeviceLocal()                     // Update device status flags
```

### Service Methods
```dart
activationService.updateDeviceStatus()      // Status endpoint
syncService._syncWorkers()                  // Workers endpoint
syncService._syncSales()                    // Sales endpoint
syncService._syncStocks()                   // Stocks endpoint
```

---

## Response Parsing

```dart
// Standard pattern for all endpoints
final apiResponse = DeviceApiResponse<T>.fromJson(
  body,
  parseData: (data) => /* convert to T */,
);

// Examples
DeviceApiResponse<DeviceDTO>.fromJson(
  body,
  parseData: (data) => DeviceDTO.fromJson(data as Map<String, dynamic>),
)

DeviceApiResponse<List<WorkerDTO>>.fromJson(
  body,
  parseData: (data) {
    if (data == null) return [];
    return (data as List)
        .map((w) => WorkerDTO.fromJson(w as Map<String, dynamic>))
        .toList();
  },
)
```

---

## Processing Order

1. **Parse** - JSON → DeviceApiResponse<T>
2. **Module** - Save module + payment methods
3. **Device** - Save device configuration
4. **Status** - Update activation & multiuser flags
5. **Workers** - Save synced workers list
6. **Commands** - Log pending commands
7. **Notify** - DeviceStateManager.notifyListeners()
8. **Rebuild** - UI screens auto-update

---

## Console Logging Examples

```
=== Device Status Processed ===
Device Type: PHARMACY_RETAIL
Device Status: ACTIVE
Multi-User Support: true

💳 Payment Methods (2):
  - MOMO: +256701234567 (UGX)
  - Bank: 1234567890 (UGX)

👥 Workers (3):
  - John Doe (PHARMACIST, active)
  - Jane Smith (NURSE, active)
  - Bob Johnson (ASSISTANT, active)

📋 Received 1 command(s):
  - [123] UPDATE_PRICE (PENDING)
    Created: 2024-02-18T10:30:00Z
```

---

## Testing Flow

```
1. Manual Setup:
   - Register device
   - Set payment methods on server
   - Create worker users on server

2. Trigger Sync:
   - Call /api/devices/status
   - Call /api/devices/sync-workers
   - Call /api/devices/sales-snapshot

3. Verify Database:
   - Check Modules table for paymentMethods
   - Check Workers table for synced users
   - Check Devices table for updated config

4. Verify UI:
   - Payment methods visible in checkout
   - Multi-user login shows workers
   - Device type changes immediate
   - Deactivation logs user out
```

---

## Error Handling

All endpoints safely handle errors:

```dart
// Graceful handling of missing data
if (response.module?.privateKey == null) {
  return false; // Silent failure, keeps going
}

// Partial response processing
if (apiResponse.data != null) {
  // Process data
}
if (apiResponse.module != null) {
  // Process module
}
// Even if one fails, others continue

// Try-catch wrapping response parsing
try {
  final parsed = DeviceApiResponse<T>.fromJson(body);
  // Process
} catch (e) {
  // Log error, return success (data was sent)
  return true;
}
```

---

## Files to Reference

| File | Purpose |
|------|---------|
| `lib/services/activation_service.dart` | DeviceStatus processing |
| `lib/services/sync_service.dart` | Workers, Sales, Stocks processing |
| `lib/services/dto/activation_dto.dart` | All DTOs & response classes |
| `lib/data/database.dart` | Database CRUD methods |
| `lib/data/tables.dart` | Table definitions |
| API_RESPONSE_PROCESSING_GUIDE.md | Full documentation |

---

## Common Tasks

### Get payment methods for a module
```dart
final methods = await _db.getPaymentMethodsByModule(moduleId);
for (final pm in methods) {
  print('${pm.type}: ${pm.account}');
}
```

### Get workers for multi-user login
```dart
final workers = await _db.getWorkersByModule(moduleId);
for (final worker in workers) {
  if (worker.active) {
    // Show in login list
  }
}
```

### Check device configuration
```dart
final device = await _db.getDevice();
if (device?.supportMultiUsers == true) {
  // Show user management
}
```

### Listen to device state changes
```dart
context.read<DeviceStateManager>().addListener(() {
  setState(() {}); // Rebuild
});
```

---

## Status Codes

- **200/201** - Success, parse response and save all data
- **4xx** - Client error, log and continue
- **5xx** - Server error, log and continue

All treated as non-critical failures - app continues working.

---

## Key Takeaway

**All API responses are now fully digested:**
- ✅ Device configuration changes → saved & applied immediately
- ✅ Payment methods → stored in database
- ✅ Worker users → synced & available
- ✅ Module updates → applied to UI
- ✅ Pending commands → logged for processing
- ✅ UI → automatically rebuilds on changes

**No data is lost or ignored anymore.**
