# Device Signature Standard

This document defines the **standardized signature format** used by NexxPharma device for all API requests requiring authentication.

## Overview

All device-to-server communications that require authentication use **RSA-2048 digital signatures** with SHA-256 hashing. The signature format is **consistent and predictable** across all endpoints.

---

## Signature Format

### Standard Format

```
Signature Payload = deviceId|dataJson
```

Where:
- `deviceId`: The unique device identifier (string)
- `|`: Pipe character as separator (literal)
- `dataJson`: JSON-encoded string of the data payload

### Empty Data Format

When there is **no data** or data is **empty**:

```
Signature Payload = deviceId
```

---

## Signature Generation Process

### 1. Build Signature Payload

**With Data:**
```dart
signaturePayload = "$deviceId|${json.encode(data)}"
```

**Without Data (or empty data):**
```dart
signaturePayload = deviceId
```

### 2. Sign the Payload

```dart
signature = RSAPrivateKey.createSignature(signaturePayload)
// Uses RSA-2048 with SHA-256
// Returns Base64-encoded signature
```

### 3. Include in Request

```json
{
  "deviceId": "device-uuid",
  "signature": "base64-encoded-signature",
  "data": { ... } // or other fields depending on endpoint
}
```

---

## Examples by Endpoint

### 1. Device Status Update
**Endpoint:** `POST /api/devices/status`

**Signature Payload:**
```
deviceId|{"appVersion":"1.0.0","activationStatus":"ACTIVE","supportMultiUsers":true,"lastAction":"STARTUP"}
```

**Request:**
```json
{
  "deviceId": "abc-123",
  "signature": "TlRq8...",
  "data": {
    "appVersion": "1.0.0",
    "activationStatus": "ACTIVE",
    "supportMultiUsers": true,
    "lastAction": "STARTUP"
  }
}
```

---

### 2. Sync Workers
**Endpoint:** `POST /api/devices/sync-workers`

**Data Structure:**
```json
{
  "workers": [
    {
      "name": "John Doe",
      "role": "PHARMACIST",
      ...
    }
  ]
}
```

**Signature Payload:**
```
deviceId|{"workers":[{"name":"John Doe","role":"PHARMACIST",...}]}
```

**Request:**
```json
{
  "deviceId": "abc-123",
  "signature": "8xKz2...",
  "data": {
    "workers": [...]
  }
}
```

---

### 3. Sync Stocks
**Endpoint:** `POST /api/stocks/sync`

**Data Structure:**
```json
{
  "stocksIn": [...],
  "stocksOut": [...]
}
```

**Signature Payload:**
```
deviceId|{"stocksIn":[...],"stocksOut":[...]}
```

**Request:**
```json
{
  "deviceId": "abc-123",
  "signature": "9pLm3...",
  "stocksIn": [...],
  "stocksOut": [...]
}
```

**Note:** This endpoint puts stocks directly in the root, not inside a `data` wrapper.

---

### 4. Sales Snapshot
**Endpoint:** `POST /api/devices/sales-snapshot`

**Data Structure:**
```json
{
  "sales": [...],
  "period": "MANUAL"
}
```

**Signature Payload:**
```
deviceId|{"sales":[...],"period":"MANUAL"}
```

**Request:**
```json
{
  "deviceId": "abc-123",
  "signature": "7nBv5...",
  "data": {
    "sales": [...],
    "period": "MANUAL"
  }
}
```

---

### 5. Update Public Key
**Endpoint:** `POST /api/devices/update-public-key`

**Data Structure:**
```json
{
  "newPublicKey": "-----BEGIN RSA PUBLIC KEY-----\n..."
}
```

**Signature Payload:**
```
deviceId|{"newPublicKey":"-----BEGIN RSA PUBLIC KEY-----\n..."}
```

**Important:** Signed with the **CURRENT private key**, not the new one. Server must verify using the existing public key on file.

---

### 6. Acknowledge Command
**Endpoint:** `POST /api/devices/acknowledge-command`

**Data Structure:**
```json
{
  "commandId": 123
}
```

**Signature Payload:**
```
deviceId|{"commandId":123}
```

---

### 7. Recycle Module Code
**Endpoint:** `POST /api/devices/recycle-module-code`

**Data Structure:** (Empty)
```json
{}
```

**Signature Payload:**
```
deviceId
```

**Note:** Empty data, so signature is just the deviceId.

---

## Backend Verification Process

### Step 1: Extract Request Components
```kotlin
val deviceId = request.deviceId
val signature = request.signature
val data = request.data // May be null or empty
```

### Step 2: Rebuild Signature Payload
```kotlin
val signaturePayload = if (data != null && data.isNotEmpty()) {
    "$deviceId|${objectMapper.writeValueAsString(data)}"
} else {
    deviceId
}
```

### Step 3: Verify Signature
```kotlin
val publicKey = getDevicePublicKey(deviceId) // From database
val isValid = RSAVerifier.verify(
    payload = signaturePayload,
    signature = signature,
    publicKey = publicKey
)
```

### Step 4: Process Request
```kotlin
if (isValid) {
    // Process the request
} else {
    throw SignatureVerificationException("Invalid signature")
}
```

---

## Key Points

### ✅ Consistent
- Same format across all endpoints
- Predictable signature payload structure
- No variations or special cases (except empty data)

### ✅ Secure
- RSA-2048 bit encryption
- SHA-256 hashing
- Private key never leaves device
- Each signature is unique to its data

### ✅ Verifiable
- Backend can reconstruct exact payload
- JSON encoding is deterministic
- Clear separation with pipe character
- Device ID always present

### ✅ Debuggable
- Signature payload logged in debug mode
- Easy to trace what was signed
- Backend can log verification attempts
- Clear error messages when verification fails

---

## JSON Encoding Rules

To ensure signature verification works:

1. **Use standard JSON encoding** - No custom serialization
2. **Consistent encoding** - Same library/method for signing and verification
3. **No whitespace variations** - Compact JSON (no pretty printing)
4. **UTF-8 encoding** - Throughout the process
5. **Deterministic order** - Object keys should be in consistent order

### Dart (Device Side)
```dart
import 'dart:convert';
final dataJson = json.encode(data); // Uses dart:convert
```

### Kotlin (Backend Side)
```kotlin
import com.fasterxml.jackson.databind.ObjectMapper
val dataJson = objectMapper.writeValueAsString(data)
```

---

## Migration Notes

### Before (Inconsistent)
- Device status: signed `{"deviceId":"...","data":{...}}`
- Sync operations: signed just `deviceId`
- Token request: signed random timestamp

### After (Standardized)
- **All operations**: sign `deviceId|dataJson` or just `deviceId`
- **Predictable and stable**
- **Backend can use single verification function**

---

## Error Handling

### Common Signature Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `Invalid signature` | Payload mismatch | Check data encoding matches |
| `Public key not found` | Device not registered | Complete device registration |
| `Signature format invalid` | Base64 decode failed | Check signature encoding |
| `Key mismatch` | Wrong keys used | Verify correct key pair |

### Debug Checklist

When signature verification fails:

1. ✅ Check signature payload logged on device
2. ✅ Rebuild exact payload on backend
3. ✅ Compare character-by-character
4. ✅ Verify JSON encoding is identical
5. ✅ Check pipe separator present (if data exists)
6. ✅ Confirm using correct public key
7. ✅ Validate RSA key format (PEM)

---

## Version History

- **v1.0** (Feb 2026) - Initial standardized format
  - Format: `deviceId|dataJson` or `deviceId`
  - Replaces inconsistent legacy formats
  - Applied across all device operations

---

## Questions?

Contact: Backend Team
Last Updated: February 14, 2026
