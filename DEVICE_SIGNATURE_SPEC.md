# Device Signature Specification & Verification Guide

**Complete specification for device authentication signatures in NexxPharma**

This document defines the standardized signature format used by devices and how the backend verifies these signatures.

---

## 🔐 TL;DR - Backend Verification in 3 Steps

If a device has the right signature and you have the public key, verification is simple:

```kotlin
// That's it! Everything needed is in the request.
val signaturePayload = "$deviceId|${json.encode(data)}"  // Rebuild what was signed
val publicKey = getPublicKey(deviceId)                   // One DB lookup
val isValid = RSAVerifier.verify(payload, signature, publicKey)  // Verify
```

**No complex lookups. No additional data needed. Just verify and done.**

---

## Table of Contents

1. [Overview](#overview)
2. [Cryptography Model](#cryptography-model)
3. [Standardized Signature Format](#standardized-signature-format)
4. [Key Exchange & Rotation](#key-exchange--rotation)
5. [Signature Generation (Device)](#signature-generation-device)
6. [Signature Verification (Backend)](#signature-verification-backend)
7. [Examples by Endpoint](#examples-by-endpoint)
8. [JSON Encoding Rules](#json-encoding-rules)
9. [Error Handling & Debugging](#error-handling--debugging)
10. [Security Considerations](#security-considerations)

---

## Overview

All device-to-server communications requiring authentication use **RSA-2048 digital signatures** with SHA-256 hashing. The signature format is **consistent and predictable** across all endpoints.

### What Backend Needs to Verify Signatures

The verification process is **simple and self-contained**. Everything needed is either:
1. **In the request** - deviceId, signature, data (from request body)
2. **Stored once** - public key (stored during device registration)

**No additional data lookup required!** The signature contains everything the backend needs to verify authenticity.

| Component | Source | Purpose |
|-----------|--------|---------|
| `deviceId` | Request body | Identifies the device |
| `signature` | Request body | The RSA signature to verify |
| `data` | Request body | The actual payload data |
| `publicKey` | Database (one lookup) | Verifies the signature |

**That's all you need!** One database query for the public key, then pure cryptographic verification.

### How It Works (Simple Overview)

```
┌──────────────────────────────────────────────────────────────────┐
│ DEVICE SENDS REQUEST                                             │
│ {                                                                │
│   "deviceId": "abc-123",                                         │
│   "signature": "base64-signature-here",                         │
│   "data": {"appVersion": "1.0.0"}                               │
│ }                                                                │
└──────────────────────────────────────────────────────────────────┘
                              ↓
┌──────────────────────────────────────────────────────────────────┐
│ BACKEND VERIFIES                                                 │
│                                                                  │
│ 1. Extract from request: deviceId, signature, data              │
│ 2. Get public key from DB (stored during registration)          │
│ 3. Rebuild payload: "abc-123|{\"appVersion\":\"1.0.0\"}"       │
│ 4. Verify: RSA.verify(payload, signature, publicKey)            │
│                                                                  │
│ Result: ✅ Valid = Authenticated & Untampered                    │
│         ❌ Invalid = Reject request                              │
└──────────────────────────────────────────────────────────────────┘
```

### Key Principles

✅ **Standardized** - Same format for all endpoints  
✅ **Secure** - RSA-2048 + SHA-256 encryption  
✅ **Self-contained** - All data in the request  
✅ **Simple** - One DB lookup, one crypto operation  
✅ **Verifiable** - Backend can reconstruct exact payload  
✅ **Debuggable** - Clear logging and error messages

### What Backend Does NOT Need

The backend **does not** need to:
- ❌ Look up device details (name, status, etc.)
- ❌ Verify timestamps or nonces (unless you add them)
- ❌ Query additional user or module data
- ❌ Check device activation status for signature verification
- ❌ Validate business logic before verifying signature

**Signature verification is pure cryptography:**  
`signature + publicKey + payload → valid/invalid`

Everything else (business logic, authorization checks, data validation) happens **after** signature verification succeeds.  

---

## How Signatures Are Created (Device Side)

Understanding how the device creates signatures helps backend developers verify them correctly.

### The 3-Step Signature Process

**Step 1: Build Payload String**
```dart
// Format: deviceId|dataJson (or just deviceId if empty)
String _buildSignaturePayload(String deviceId, [dynamic data]) {
  if (data == null) {
    return deviceId;
  }
  final dataJson = json.encode(data);  // Standard JSON encoding
  return '$deviceId|$dataJson';        // Concatenate with pipe
}
```

**Step 2: Sign with Private Key**
```dart
final signature = privateKey.createSignature(signaturePayload);
// Uses RSA-2048 + SHA-256
// Returns Base64-encoded signature
```

**Step 3: Send Request**
```dart
final request = {
  'deviceId': deviceId,
  'signature': signature,
  'data': data,
};
// POST to backend with JSON body
```

### Real Example

If device wants to update status with `{"appVersion":"1.0.0"}`:

```dart
// 1. Build payload
final deviceId = "abc-123";
final data = {"appVersion": "1.0.0"};
final signaturePayload = '$deviceId|${json.encode(data)}';
// Result: "abc-123|{\"appVersion\":\"1.0.0\"}"

// 2. Sign
final signature = privateKey.createSignature(signaturePayload);
// Result: "TlRq8x7vKz2..." (Base64)

// 3. Send
POST /api/devices/status
{
  "deviceId": "abc-123",
  "signature": "TlRq8x7vKz2...",
  "data": {"appVersion": "1.0.0"}
}
```

### Backend Just Reverses This

```kotlin
// 1. Extract from request
val deviceId = request.deviceId              // "abc-123"
val signature = request.signature            // "TlRq8x7vKz2..."
val data = request.data                      // {"appVersion": "1.0.0"}

// 2. Rebuild EXACT payload device signed
val signaturePayload = "$deviceId|${objectMapper.writeValueAsString(data)}"
// Result: "abc-123|{\"appVersion\":\"1.0.0\"}"

// 3. Verify with public key
val publicKey = getPublicKey(deviceId)       // From DB (stored during registration)
val isValid = RSAVerifier.verify(signaturePayload, signature, publicKey)
// Result: true = authenticated, false = reject
```

**That's the entire process!** No hidden complexity, no additional lookups.

---

## Cryptography Model

### Algorithm Specifications

- **Encryption**: RSA (Rivest-Shamir-Adleman)
- **Key Size**: 2048 bits
- **Hash Function**: SHA-256
- **Signature Encoding**: Base64
- **Character Encoding**: UTF-8

### Key Management

| Key Type | Location | Transmitted? | Purpose |
|----------|----------|--------------|---------|
| Private Key | Device only | **Never** | Signs requests |
| Public Key | Backend database | Yes (during registration) | Verifies signatures |

### Signing/Verification Methods

**Device (Dart):**
```dart
final signature = RSAPrivateKey.createSignature(signaturePayload);
```

**Backend (Kotlin/Java):**
```kotlin
val isValid = RSAPublicKey.verifySignature(payload, signature)
```

---

## Standardized Signature Format

### ⚠️ CRITICAL: Standard Format (v1.0)

All device signatures now use this **consistent format**:

#### With Data
```
signaturePayload = deviceId|dataJson
```

Where:
- `deviceId` = Device UUID string
- `|` = Pipe character separator (literal)
- `dataJson` = JSON-encoded string of data object

#### Without Data (or empty)
```
signaturePayload = deviceId
```

### Format Rules

1. **Always start with deviceId**
2. **Use pipe `|` as separator** (not comma, colon, or other)
3. **JSON encode data** using standard `json.encode()` / `objectMapper.writeValueAsString()`
4. **No added whitespace** - Use compact JSON
5. **UTF-8 encoding throughout**

### Examples

**With data:**
```
abc-123|{"appVersion":"1.0.0","activationStatus":"ACTIVE"}
```

**Without data:**
```
abc-123
```

---

## Key Exchange & Rotation

### 1. Initial Device Registration

```
┌─────────┐                                    ┌─────────┐
│ Device  │                                    │ Backend │
└────┬────┘                                    └────┬────┘
     │                                              │
     │ Generate RSA-2048 keypair                    │
     │ (privateKey + publicKey)                     │
     │                                              │
     │  POST /api/devices/register-device           │
     │  {                                           │
     │    code, email, publicKey,                   │
     │    appVersion, lat?, lon?                    │
     │  }                                           │
     ├─────────────────────────────────────────────>│
     │                                              │
     │                            Store: deviceId,  │
     │                            publicKey,        │
     │                            moduleId          │
     │                                              │
     │  Response: {                                 │
     │    deviceId, moduleId,                       │
     │    module, status, commands                  │
     │  }                                           │
     │<─────────────────────────────────────────────┤
     │                                              │
     │ ✅ Store privateKey locally (secure)         │
     │ ✅ Never transmit privateKey again           │
     │                                              │
```

**Note:** Device registration does NOT require signature (it's the bootstrap step).

### 2. Public Key Rotation (Optional, every 24 hours)

```
┌─────────┐                                    ┌─────────┐
│ Device  │                                    │ Backend │
└────┬────┘                                    └────┬────┘
     │                                              │
     │ Generate NEW RSA-2048 keypair                │
     │ (newPrivateKey + newPublicKey)               │
     │                                              │
     │  POST /api/devices/update-public-key         │
     │  {                                           │
     │    deviceId,                                 │
     │    signature: signedWith(CURRENT_PRIVATE),   │
     │    data: { newPublicKey }                    │
     │  }                                           │
     ├─────────────────────────────────────────────>│
     │                                              │
     │                      Verify using OLD public │
     │                      key (already in DB)     │
     │                                              │
     │                      ✅ If valid: Update     │
     │                      publicKey in DB         │
     │                                              │
     │  Response: Success                           │
     │<─────────────────────────────────────────────┤
     │                                              │
     │ ✅ Replace privateKey with newPrivateKey     │
     │ ✅ Discard old privateKey                    │
     │ ✅ Use new keys for all future requests      │
     │                                              │
```

**⚠️ Critical:** Rotation request is signed with **CURRENT** private key, not the new one!

---

## Signature Generation (Device)

### Step-by-Step Process

#### 1. Build Signature Payload

**Implementation (sync_service.dart & activation_service.dart):**

```dart
String _buildSignaturePayload(String deviceId, [dynamic data]) {
  if (data == null || (data is Map && data.isEmpty)) {
    return deviceId;
  }
  final dataJson = json.encode(data);
  return '$deviceId|$dataJson';
}
```

#### 2. Sign the Payload

```dart
final privateKey = RSAPrivateKey.fromPEM(module.privateKey);
final signature = privateKey.createSignature(signaturePayload);
// Returns Base64-encoded signature string
```

#### 3. Build Request

```dart
final request = {
  'deviceId': deviceId,
  'signature': signature,
  'data': data, // or other fields depending on endpoint
};
```

#### 4. Send HTTP Request

```dart
final response = await http.post(
  Uri.parse('${backendUrl}/api/endpoint'),
  headers: {'Content-Type': 'application/json'},
  body: json.encode(request),
);
```

### Debug Logging (Enabled in Debug Mode)

```dart
debugPrint('=== Request Signature Debug ===');
debugPrint('DeviceId: $deviceId');
debugPrint('Signature Payload: $signaturePayload');
debugPrint('PrivateKey (first 100 chars): ${privateKey.substring(0, 100)}...');
debugPrint('PublicKey: ${publicKey.toString()}');
debugPrint('Signature: $signature');
```

---

## Signature Verification (Backend)

### Core Concept

**Simple 3-Step Verification:**
1. Extract `deviceId`, `signature`, and `data` from the incoming request
2. Rebuild the exact payload the device signed: `deviceId|dataJson`
3. Verify signature using the device's public key (stored during registration)

**That's it!** No additional data lookup, no complex logic. Everything needed is in the request.

---

### Step-by-Step Process

#### 1. Extract Request Components (Everything is in the request)

```kotlin
@PostMapping("/api/devices/status")
fun updateStatus(@RequestBody request: DeviceSignedRequest<UpdateDeviceInput>) {
    val deviceId = request.deviceId        // ✅ From request
    val signature = request.signature      // ✅ From request
    val data = request.data                // ✅ From request
}
```

**Note:** All required data is in the request body. No need to query or lookup additional data.

#### 2. Get Device Public Key (One-time lookup from registration)

```kotlin
// Public key was stored when device registered
val publicKey = deviceRepository.getPublicKey(deviceId)
    .orElseThrow { UnauthorizedException("Device not registered") }
```

**Note:** This is the only database lookup needed - just the public key associated with this deviceId.

#### 3. Rebuild Signature Payload (Match device's format exactly)

```kotlin
val signaturePayload = if (data != null && data.isNotEmpty()) {
    "$deviceId|${objectMapper.writeValueAsString(data)}"
} else {
    deviceId
}
```

**Example:**
- Device sent: `{"deviceId":"abc-123","data":{"appVersion":"1.0.0"}}`
- Payload to verify: `"abc-123|{\"appVersion\":\"1.0.0\"}"`

**⚠️ Critical:** JSON encoding MUST be identical to device's encoding!

#### 4. Verify Signature (Pure cryptographic operation)

```kotlin
val isValid = RSAVerifier.verify(
    payload = signaturePayload,
    signature = signature,
    publicKey = publicKey
)

if (!isValid) {
    throw UnauthorizedException("Signature verification failed")
}
```

**This verifies:**
- ✅ Request was signed by device with matching private key
- ✅ Data has not been tampered with
- ✅ Request is authentic

#### 5. Process Request (Now safe to use the data)

```kotlin
// Signature is valid - data is authentic and untampered
updateDeviceStatus(deviceId, data)
return DeviceApiResponse.success(...)
```

### Complete Verification Function Example

**Simple, Reusable Verifier:**

```kotlin
@Component
class DeviceSignatureVerifier(
    private val deviceRepository: DeviceRepository,
    private val objectMapper: ObjectMapper
) {
    
    /**
     * Verifies device request signature
     * 
     * @param deviceId - From request body
     * @param signature - From request body  
     * @param data - From request body (or null)
     * @return true if signature is valid, throws exception otherwise
     */
    fun verifyAndAuthenticate(deviceId: String, signature: String, data: Any?): Boolean {
        // Step 1: Get public key (only DB lookup needed)
        val publicKey = deviceRepository.getPublicKey(deviceId)
            .orElseThrow { UnauthorizedException("Device not registered: $deviceId") }
        
        // Step 2: Rebuild signature payload (exactly as device built it)
        val signaturePayload = buildPayload(deviceId, data)
        
        // Step 3: Verify signature (pure crypto operation)
        val isValid = RSAVerifier.verify(signaturePayload, signature, publicKey)
        
        if (!isValid) {
            logger.warn("Signature verification failed for device: $deviceId")
            throw UnauthorizedException("Invalid signature")
        }
        
        logger.debug("✅ Device authenticated: $deviceId")
        return true
    }
    
    private fun buildPayload(deviceId: String, data: Any?): String {
        // Match device format: deviceId|dataJson or just deviceId
        return if (data != null && isNotEmpty(data)) {
            "$deviceId|${objectMapper.writeValueAsString(data)}"
        } else {
            deviceId
        }
    }
    
    private fun isNotEmpty(data: Any?): Boolean {
        return when (data) {
            null -> false
            is Map<*, *> -> data.isNotEmpty()
            is Collection<*> -> data.isNotEmpty()
            is String -> data.isNotBlank()
            else -> true
        }
    }
}
```

### Usage in Controllers

```kotlin
@RestController
class DeviceController(
    private val signatureVerifier: DeviceSignatureVerifier,
    private val deviceService: DeviceService
) {
    
    @PostMapping("/api/devices/status")
    fun updateStatus(@RequestBody request: DeviceSignedRequest<UpdateDeviceInput>): DeviceApiResponse<*> {
        // Verify signature (throws UnauthorizedException if invalid)
        signatureVerifier.verifyAndAuthenticate(
            request.deviceId,
            request.signature,
            request.data
        )
        
        // Signature valid - proceed with business logic
        return deviceService.updateStatus(request.deviceId, request.data)
    }
    
    @PostMapping("/api/devices/sync-workers")
    fun syncWorkers(@RequestBody request: DeviceSignedRequest<WorkerSyncPayload>): DeviceApiResponse<*> {
        // Same verification for all endpoints
        signatureVerifier.verifyAndAuthenticate(
            request.deviceId,
            request.signature,
            request.data
        )
        
        return deviceService.syncWorkers(request.deviceId, request.data.workers)
    }
}
```

**Key Points:**
- ✅ **Single verification function** for all endpoints
- ✅ **Everything in request** - no additional data lookup
- ✅ **One database query** - just the public key
- ✅ **Pure crypto verification** - no business logic in verification
- ✅ **Reusable** - same code for all device endpoints

---

## Examples by Endpoint

### 1. Device Status Update

**Endpoint:** `POST /api/devices/status`

**Device Code:**
```dart
final data = {
  'appVersion': '1.0.0',
  'activationStatus': 'ACTIVE',
  'supportMultiUsers': true,
  'lastAction': 'STARTUP'
};

final signaturePayload = '$deviceId|${json.encode(data)}';
// Result: "abc-123|{\"appVersion\":\"1.0.0\",\"activationStatus\":\"ACTIVE\",...}"

final signature = privateKey.createSignature(signaturePayload);

final request = {
  'deviceId': deviceId,
  'signature': signature,
  'data': data,
};
```

**Backend Verification:**
```kotlin
// All data is in the request - just verify!
val signaturePayload = "$deviceId|${objectMapper.writeValueAsString(request.data)}"
val publicKey = getPublicKey(deviceId) // One DB lookup
val isValid = RSAVerifier.verify(signaturePayload, signature, publicKey)
// That's it!
```

---

### 2. Sync Workers

**Endpoint:** `POST /api/devices/sync-workers`

**Device Code:**
```dart
final data = {
  'workers': [
    {'name': 'John Doe', 'role': 'PHARMACIST', ...},
    {'name': 'Jane Smith', 'role': 'TECHNICIAN', ...},
  ]
};

final signaturePayload = '$deviceId|${json.encode(data)}';
final signature = privateKey.createSignature(signaturePayload);

final request = {
  'deviceId': deviceId,
  'signature': signature,
  'data': data,
};
```

**Backend Verification:**
```kotlin
// All data is in the request - just verify!
val signaturePayload = "$deviceId|${objectMapper.writeValueAsString(request.data)}"
val publicKey = getPublicKey(deviceId) // One DB lookup
val isValid = RSAVerifier.verify(signaturePayload, signature, publicKey)
```

---

### 3. Sync Stocks

**Endpoint:** `POST /api/stocks/sync`

**Device Code:**
```dart
final data = {
  'stocksIn': [...],
  'stocksOut': [...],
};

final signaturePayload = '$deviceId|${json.encode(data)}';
final signature = privateKey.createSignature(signaturePayload);

final request = {
  'deviceId': deviceId,
  'signature': signature,
  'stocksIn': data['stocksIn'],
  'stocksOut': data['stocksOut'],
};
```

**Note:** This endpoint puts stocks at root level, but signature signs the combined data.

**Backend Verification:**
```kotlin
// Combine stocks into data object to match what was signed
val data = mapOf("stocksIn" to request.stocksIn, "stocksOut" to request.stocksOut)
val signaturePayload = "$deviceId|${objectMapper.writeValueAsString(data)}"
val publicKey = getPublicKey(deviceId)
val isValid = RSAVerifier.verify(signaturePayload, signature, publicKey)
```

---

### 4. Sales Snapshot

**Endpoint:** `POST /api/devices/sales-snapshot`

**Device Code:**
```dart
final data = {
  'sales': [...],
  'period': 'MANUAL',
};

final signaturePayload = '$deviceId|${json.encode(data)}';
final signature = privateKey.createSignature(signaturePayload);

final request = {
  'deviceId': deviceId,
  'signature': signature,
  'data': data,
};
```

---

### 5. Update Public Key Rotation

**Endpoint:** `POST /api/devices/update-public-key`

**Device Code:**
```dart
// Generate NEW keypair
final newKeypair = RSAKeypair.fromRandom();
final newPublicKey = newKeypair.publicKey;

final data = {
  'newPublicKey': newPublicKey.toString(),
};

// ⚠️ Sign with CURRENT private key (not new one!)
final signaturePayload = '$deviceId|${json.encode(data)}';
final signature = currentPrivateKey.createSignature(signaturePayload);

final request = {
  'deviceId': deviceId,
  'signature': signature,
  'data': data,
};
```

**Backend Verification:**
```kotlin
// ⚠️ Use OLD/CURRENT public key (not the new one being sent)
val currentPublicKey = getPublicKey(deviceId) // This is the OLD key
val signaturePayload = "$deviceId|${objectMapper.writeValueAsString(request.data)}"
val isValid = RSAVerifier.verify(signaturePayload, signature, currentPublicKey)

if (isValid) {
    // Now safe to update to new public key
    updatePublicKey(deviceId, request.data.newPublicKey)
}
```

---

### 6. Acknowledge Command

**Endpoint:** `POST /api/devices/acknowledge-command`

**Device Code:**
```dart
final data = {
  'commandId': 123,
};

final signaturePayload = '$deviceId|${json.encode(data)}';
final signature = privateKey.createSignature(signaturePayload);
```

---

### 7. Recycle Module Code

**Endpoint:** `POST /api/devices/recycle-module-code`

**Device Code:**
```dart
final data = <String, dynamic>{}; // Empty

final signaturePayload = deviceId; // No pipe, no data
final signature = privateKey.createSignature(signaturePayload);

final request = {
  'deviceId': deviceId,
  'signature': signature,
  'data': null,
};
```

**Backend Verification:**
```kotlin
// Empty data - just verify deviceId
val signaturePayload = deviceId // No pipe, no data
val publicKey = getPublicKey(deviceId)
val isValid = RSAVerifier.verify(signaturePayload, signature, publicKey)
```

---

## JSON Encoding Rules

To ensure signature verification works across device and backend:

### Critical Requirements

1. ✅ **Standard JSON encoding** - Use `json.encode()` (Dart) and `objectMapper.writeValueAsString()` (Kotlin)
2. ✅ **Compact format** - No pretty printing, no extra whitespace
3. ✅ **UTF-8 encoding** - Throughout the entire process
4. ✅ **Consistent library** - Same JSON library for all operations
5. ✅ **No special characters** - Let JSON encoder handle escaping

### Device (Dart)

```dart
import 'dart:convert';

// ✅ Correct
final dataJson = json.encode(data);

// ❌ Wrong - adds whitespace
final dataJson = JsonEncoder.withIndent('  ').convert(data);
```

### Backend (Kotlin)

```kotlin
import com.fasterxml..jackson.databind.ObjectMapper

// ✅ Correct
val dataJson = objectMapper.writeValueAsString(data)

// ❌ Wrong - custom serialization
val dataJson = customSerializer.serialize(data)
```

### Object Key Ordering

**Recommendation:** While JSON spec doesn't guarantee key order, use **LinkedHashMap** or sorted maps for consistency.

**Dart:**
```dart
// Keys maintain insertion order by default in Dart Map
final data = {
  'appVersion': '1.0.0',
  'status': 'ACTIVE',
};
```

**Kotlin:**
```kotlin
// Use LinkedHashMap to preserve order
val data = linkedMapOf(
    "appVersion" to "1.0.0",
    "status" to "ACTIVE"
)
```

---

## Error Handling & Debugging

### Common Signature Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `Invalid signature` | Payload mismatch | Compare signature payloads character-by-character |
| `Public key not found` | Device not registered | Complete device registration first |
| `Signature format invalid` | Base64 decode failed | Ensure Base64 encoding is correct |
| `Key mismatch` | Wrong key pair | Verify keys were generated together |
| `JSON mismatch` | Different encoding | Use same JSON library and format |
| `Pipe separator missing` | Old format used | Update to v1.0 format: `deviceId|dataJson` |

### Debug Checklist (When Verification Fails)

#### Device Side

1. ✅ Log signature payload being signed
2. ✅ Log public key derived from private key
3. ✅ Log final signature (Base64)
4. ✅ Verify JSON encoding is compact (no whitespace)
5. ✅ Confirm pipe separator present (if data exists)

**Debug Output Example:**
```
=== Sync Workers Request ===
DeviceId: abc-123
Workers count: 2
Signature Payload: abc-123|{"workers":[{"name":"John","role":"PHARMACIST"}]}
PrivateKey (first 100 chars): -----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA...
PublicKey: -----BEGIN RSA PUBLIC KEY-----
MIIBCgKCAQEA7nZk...
Signature: TlRq8x7vKz2...
```

#### Backend Side

1. ✅ Log deviceId from request
2. ✅ Log public key retrieved from database
3. ✅ Log reconstructed signature payload
4. ✅ Log signature from request
5. ✅ Log verification result (true/false)
6. ✅ Compare reconstructed payload with device's logged payload

**Debug Output Example:**
```kotlin
logger.debug("=== Signature Verification ===")
logger.debug("DeviceId: abc-123")
logger.debug("Public key from DB: -----BEGIN RSA PUBLIC KEY----- ...")
logger.debug("Reconstructed payload: abc-123|{\"workers\":[{\"name\":\"John\",\"role\":\"PHARMACIST\"}]}")
logger.debug("Signature received: TlRq8x7vKz2...")
logger.debug("Verification result: true")
```

#### Character-by-Character Comparison

If verification fails, compare payloads byte-by-byte:

**Device:**
```dart
debugPrint('Payload bytes: ${utf8.encode(signaturePayload)}');
debugPrint('Payload length: ${signaturePayload.length}');
```

**Backend:**
```kotlin
logger.debug("Payload bytes: ${signaturePayload.toByteArray(Charsets.UTF_8).contentToString()}")
logger.debug("Payload length: ${signaturePayload.length}")
```

### Testing Signature Verification

**Unit Test (Backend):**

```kotlin
@Test
fun `should verify valid device signature`() {
    // 1. Generate test keypair
    val keypair = RSAKeypair.fromRandom()
    val privateKey = keypair.privateKey
    val publicKey = keypair.publicKey
    
    // 2. Create signature payload
    val deviceId = "test-device-123"
    val data = mapOf("appVersion" to "1.0.0")
    val signaturePayload = "$deviceId|${objectMapper.writeValueAsString(data)}"
    
    // 3. Sign on "device side"
    val signature = privateKey.createSignature(signaturePayload)
    
    // 4. Verify on "backend side"
    val isValid = publicKey.verifySignature(signaturePayload, signature)
    
    // 5. Assert
    assertTrue(isValid)
}
```

---

## Security Considerations

### 1. Private Key Security

✅ **Stored securely on device** - Use encrypted storage  
✅ **Never logged in production** - Only first 100 chars in debug  
✅ **Never transmitted** - Not even during registration  
✅ **Rotated periodically** - Every 24 hours recommended  

### 2. Public Key Management

✅ **Stored in backend database** - Indexed by deviceId  
✅ **Updated during rotation** - After verifying old signature  
✅ **Cached for performance** - Reduce database lookups  
✅ **Validated format** - Ensure valid PEM format  

### 3. Signature Properties

✅ **Unique per request** - Different data = different signature  
✅ **Non-repudiable** - Only device with private key can sign  
✅ **Tamper-evident** - Any modification invalidates signature  
✅ **Time-independent** - No expiration (timestamp in data if needed)  

### 4. Replay Attack Mitigation

While signatures prevent tampering, they don't prevent replay attacks. Consider:

```dart
final data = {
  'appVersion': '1.0.0',
  'timestamp': DateTime.now().millisecondsSinceEpoch,
  'nonce': uuid.v4(),
};
```

Backend should:
- Reject requests with timestamps older than 5 minutes
- Track used nonces to prevent replay

### 5. Key Rotation Benefits

- **Limits key exposure window** - Compromised key only valid until next rotation
- **Enables recovery** - Can rotate if key suspected compromised
- **Complies with security policies** - Regular key refresh best practice

### Performance Notes

- **RSA-2048 signing**: ~10-50ms on device
- **RSA-2048 verification**: ~5-20ms on backend
- **Recommend**: Sign asynchronously, don't block UI
- **Cache**: Public keys in memory to avoid DB hits

---

## Endpoint Signature Requirements

| Endpoint | Signature Required? | Notes |
|----------|-------------------|-------|
| `POST /api/devices/register-device` | ❌ No | Bootstrap - no keys yet |
| `POST /api/devices/device-token` | ⚠️ Special | Uses module-level signing (different format) |
| `POST /api/devices/status` | ✅ Yes | Standard format: `deviceId\|data` |
| `POST /api/devices/sync-workers` | ✅ Yes | Standard format: `deviceId\|data` |
| `POST /api/stocks/sync` | ✅ Yes | Standard format: `deviceId\|data` |
| `POST /api/devices/sales-snapshot` | ✅ Yes | Standard format: `deviceId\|data` |
| `POST /api/devices/update-public-key` | ✅ Yes | Signs with OLD key! |
| `POST /api/devices/acknowledge-command` | ✅ Yes | Standard format: `deviceId\|data` |
| `POST /api/devices/recycle-module-code` | ✅ Yes | Empty data: just `deviceId` |

---

## Migration Notes

### Previous Format (Before v1.0)

Different endpoints used different formats:
- Some signed: `{"deviceId":"...","data":{...}}`
- Some signed: just `deviceId`
- Some signed: random timestamp

**Problems:**
- ❌ Inconsistent
- ❌ Confusing for backend
- ❌ Different verification logic per endpoint
- ❌ Hard to debug

### Current Format (v1.0)

All endpoints use:
- Standard: `deviceId|dataJson` or `deviceId`
- Consistent separator: pipe `|`
- Same verification logic everywhere

**Benefits:**
- ✅ Single verification function
- ✅ Predictable behavior
- ✅ Easy to debug
- ✅ Clear documentation

---

## Version History

### v1.0 (February 14, 2026)
- **Initial standardized format**
- Format: `deviceId|dataJson` or `deviceId` (empty data)
- Applied across all device operations
- Replaces inconsistent legacy formats
- Complete documentation

---

## Quick Reference Card

### Device Signing (Dart)

```dart
// 1. Build payload
final signaturePayload = data != null && data.isNotEmpty()
    ? '$deviceId|${json.encode(data)}'
    : deviceId;

// 2. Sign
final signature = privateKey.createSignature(signaturePayload);

// 3. Send
final request = {'deviceId': deviceId, 'signature': signature, 'data': data};
await http.post(url, body: json.encode(request));
```

### Backend Verification (Kotlin)

```kotlin
// 1. Extract from request (everything is here!)
val deviceId = request.deviceId
val signature = request.signature
val data = request.data

// 2. Rebuild payload (match device format exactly)
val signaturePayload = if (data != null && data.isNotEmpty()) {
    "$deviceId|${objectMapper.writeValueAsString(data)}"
} else deviceId

// 3. Get public key (one DB lookup)
val publicKey = getPublicKey(deviceId)

// 4. Verify (pure crypto)
val isValid = RSAVerifier.verify(signaturePayload, signature, publicKey)
if (!isValid) throw UnauthorizedException("Invalid signature")

// ✅ Authenticated! Now process request safely
```

### Important Reminders

✅ **All data is in the request** - No need to look up additional data  
✅ **One database lookup** - Just get the public key  
✅ **Pure verification** - It's just cryptography, nothing complex  
✅ **Same code for all endpoints** - Reusable verification function  
✅ **Verify first, process second** - Always verify before business logic

---

## Support & Questions

For issues or questions about signature verification:

1. Check debug logs on both device and backend
2. Compare signature payloads character-by-character
3. Verify JSON encoding is identical
4. Confirm public key matches private key
5. Contact backend team with full debug output

**Last Updated:** February 14, 2026  
**Version:** 1.0  
**Status:** ✅ Production Ready
