# Signature Verification Example - Step by Step

**Practical example showing exactly how to create and verify a device signature**

---

## Scenario: Device Syncs Workers

### Step 1: Device Prepares Request

Device wants to sync 2 workers to the backend.

**Data to Send:**
```json
{
  "workers": [
    {
      "id": "worker-001",
      "name": "John Doe",
      "role": "PHARMACIST"
    },
    {
      "id": "worker-002", 
      "name": "Jane Smith",
      "role": "TECHNICIAN"
    }
  ]
}
```

**Device Information:**
```
deviceId: "device-12345abc"
privateKey: -----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA2...
-----END RSA PRIVATE KEY-----
```

---

### Step 2: Device Builds Signature Payload

**Device Code (Dart):**
```dart
final deviceId = "device-12345abc";
final data = {
  "workers": [
    {"id": "worker-001", "name": "John Doe", "role": "PHARMACIST"},
    {"id": "worker-002", "name": "Jane Smith", "role": "TECHNICIAN"}
  ]
};

// Build signature payload
final dataJson = json.encode(data);
// Result: {"workers":[{"id":"worker-001","name":"John Doe","role":"PHARMACIST"},{"id":"worker-002","name":"Jane Smith","role":"TECHNICIAN"}]}

final signaturePayload = '$deviceId|$dataJson';
// Result: "device-12345abc|{"workers":[{"id":"worker-001","name":"John Doe","role":"PHARMACIST"},{"id":"worker-002","name":"Jane Smith","role":"TECHNICIAN"}]}"
```

**Signature Payload (exact string to sign):**
```
device-12345abc|{"workers":[{"id":"worker-001","name":"John Doe","role":"PHARMACIST"},{"id":"worker-002","name":"Jane Smith","role":"TECHNICIAN"}]}
```

---

### Step 3: Device Signs the Payload

**Device Code (Dart):**
```dart
final privateKey = RSAPrivateKey.fromPEM("""-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA2...
-----END RSA PRIVATE KEY-----""");

final signature = privateKey.createSignature(signaturePayload);
// Result (Base64): TlRq8x7vKz2mP9qL3nZ5w8aB1cD4eF6gH7jK0mN2oP5qR8sT1uV3wX6yZ9aB2cD5eF8gH0jK3mN5oP7qR9sT2uV4wX7yZ0=
```

**Signature Generated:**
```
TlRq8x7vKz2mP9qL3nZ5w8aB1cD4eF6gH7jK0mN2oP5qR8sT1uV3wX6yZ9aB2cD5eF8gH0jK3mN5oP7qR9sT2uV4wX7yZ0=
```

---

### Step 4: Device Sends HTTP Request

**HTTP Request:**
```
POST /api/devices/sync-workers
Content-Type: application/json

{
  "deviceId": "device-12345abc",
  "signature": "TlRq8x7vKz2mP9qL3nZ5w8aB1cD4eF6gH7jK0mN2oP5qR8sT1uV3wX6yZ9aB2cD5eF8gH0jK3mN5oP7qR9sT2uV4wX7yZ0=",
  "data": {
    "workers": [
      {
        "id": "worker-001",
        "name": "John Doe",
        "role": "PHARMACIST"
      },
      {
        "id": "worker-002",
        "name": "Jane Smith",
        "role": "TECHNICIAN"
      }
    ]
  }
}
```

---

### Step 5: Backend Receives Request

**Backend extracts:**
```
deviceId = "device-12345abc"
signature = "TlRq8x7vKz2mP9qL3nZ5w8aB1cD4eF6gH7jK0mN2oP5qR8sT1uV3wX6yZ9aB2cD5eF8gH0jK3mN5oP7qR9sT2uV4wX7yZ0="
data = {
  "workers": [
    {"id": "worker-001", "name": "John Doe", "role": "PHARMACIST"},
    {"id": "worker-002", "name": "Jane Smith", "role": "TECHNICIAN"}
  ]
}
```

---

### Step 6: Backend Rebuilds Signature Payload

**Backend Code (Java):**
```java
String deviceId = request.getDeviceId(); // "device-12345abc"
Map<String, Object> data = request.getData();

// Rebuild signature payload (MUST match device exactly)
String dataJson = objectMapper.writeValueAsString(data);
// Result: {"workers":[{"id":"worker-001","name":"John Doe","role":"PHARMACIST"},{"id":"worker-002","name":"Jane Smith","role":"TECHNICIAN"}]}

String signaturePayload = deviceId + "|" + dataJson;
// Result: "device-12345abc|{"workers":[{"id":"worker-001","name":"John Doe","role":"PHARMACIST"},{"id":"worker-002","name":"Jane Smith","role":"TECHNICIAN"}]}"
```

**Rebuilt Payload (must match device's):**
```
device-12345abc|{"workers":[{"id":"worker-001","name":"John Doe","role":"PHARMACIST"},{"id":"worker-002","name":"Jane Smith","role":"TECHNICIAN"}]}
```

✅ **Matches device payload exactly!**

---

### Step 7: Backend Gets Public Key

**Backend Code (Java):**
```java
// From database (stored during device registration)
DbDevice device = deviceRepository.findById("device-12345abc");
String publicKeyPem = device.getPublicKey();

PublicKey publicKey = loadPublicKey(publicKeyPem);
// Loaded from: -----BEGIN RSA PUBLIC KEY-----
// MIIBCgKCAQEA2...
// -----END RSA PUBLIC KEY-----
```

**Public Key Retrieved:**
```
-----BEGIN RSA PUBLIC KEY-----
MIIBCgKCAQEA2...
-----END RSA PUBLIC KEY-----
```

---

### Step 8: Backend Verifies Signature

**Backend Code (Java):**
```java
Signature sig = Signature.getInstance("SHA256withRSA");
sig.initVerify(publicKey);
sig.update(signaturePayload.getBytes(StandardCharsets.UTF_8));

byte[] decodedSignature = Base64.getDecoder().decode(
  "TlRq8x7vKz2mP9qL3nZ5w8aB1cD4eF6gH7jK0mN2oP5qR8sT1uV3wX6yZ9aB2cD5eF8gH0jK3mN5oP7qR9sT2uV4wX7yZ0="
);

boolean isValid = sig.verify(decodedSignature);
```

**Verification Result:**
```
✅ VALID = true
```

---

### Step 9: Backend Processes Request

```java
if (isValid) {
  // ✅ Signature verified!
  // Proceed safely with processing
  
  processSyncWorkers("device-12345abc", workers);
  
  return {
    "status": "success",
    "message": "Workers synced successfully",
    "count": 2
  };
} else {
  // ❌ Signature invalid!
  return {
    "status": "error",
    "message": "Invalid signature - request rejected"
  };
}
```

---

## Scenario 2: Empty Data Request (Recycle Module)

### Device Side

**Device Code (Dart):**
```dart
final deviceId = "device-12345abc";
final data = <String, dynamic>{}; // Empty map

// Check if data is empty
if (data.isEmpty) {
  signaturePayload = deviceId;  // Just deviceId, NO pipe!
} else {
  signaturePayload = '$deviceId|${json.encode(data)}';
}

// Result: "device-12345abc" (no pipe, no data)

final signature = privateKey.createSignature(signaturePayload);
// Signed: just the deviceId
```

### Backend Side

**Backend Code (Java):**
```java
String deviceId = "device-12345abc";
Map<String, Object> data = new HashMap<>(); // Empty

// Rebuild payload
if (data == null || data.isEmpty()) {
  signaturePayload = deviceId;  // Just deviceId
} else {
  signaturePayload = deviceId + "|" + objectMapper.writeValueAsString(data);
}

// Result: "device-12345abc" (matches device)

// Verify with public key
boolean isValid = sig.verify(decodedSignature);
```

---

## Complete Verification Checklist

When implementing signature verification, verify these points:

### ✅ Device Side
- [ ] Data to sync collected
- [ ] Signature payload built: `deviceId|dataJson` or just `deviceId`
- [ ] Empty check: {} or [] → just `deviceId`
- [ ] JSON encoded compactly (no whitespace)
- [ ] Signed with private key using RSA-2048 + SHA-256
- [ ] Signature Base64 encoded
- [ ] Request sent with deviceId, signature, and data

### ✅ Backend Side
- [ ] Request received
- [ ] Extract: deviceId, signature, data
- [ ] Rebuild payload (match device format exactly)
- [ ] Get public key from database using deviceId
- [ ] Public key exists (device registered)
- [ ] Verify signature using RSA-2048 + SHA-256
- [ ] Compare to expected payload (if logging)
- [ ] Return success/error appropriately

---

## Testing Your Implementation

### Test Case 1: Valid Synchronized Workers Sync

**Test Data:**
```
DeviceId: device-test-001
Workers: [{"id":"w1","name":"Alice","role":"PHARMACIST"}]
Expected: ✅ Verification passes
```

### Test Case 2: Empty Data Request

**Test Data:**
```
DeviceId: device-test-001
Data: {} (empty)
Expected: ✅ Verification passes (payload is just deviceId)
```

### Test Case 3: Tampered Signature

**Test Data:**
```
DeviceId: device-test-001
Data: {"workers":[...]}
Signature: [original + 1 character changed]
Expected: ❌ Verification fails
```

### Test Case 4: Tampered Data

**Test Data:**
```
DeviceId: device-test-001
Data: {"workers":[...]} (changed after signing)
Original Signature: [signed original data]
Expected: ❌ Verification fails (payload doesn't match)
```

### Test Case 5: Wrong Device ID

**Test Data:**
```
DeviceId: device-wrong
Signature: [signed with device-test-001]
Expected: ❌ Verification fails (public key not found or mismatch)
```

---

## Debugging Signature Mismatches

**If verification fails, check in this order:**

1. **JSON Encoding Mismatch**
   - Device logged: `device-001|{"name":"John","age":30}`
   - Backend rebuilt: `device-001|{"age":30,"name":"John"}` (different order)
   - Solution: Ensure both use same JSON library and format

2. **Whitespace in JSON**
   - Device: `device-001|{"name":"John"}` (compact)
   - Backend: `device-001|{"name": "John"}` (pretty - HAS SPACES!)
   - Solution: Use compact JSON on both sides

3. **Public Key Mismatch**
   - Signature signed with Device's current private key
   - Backend using Device's OLD public key (not updated)
   - Solution: Ensure public key rotation is handled

4. **UTF-8 Encoding Issue**
   - Device uses UTF-16
   - Backend uses UTF-8
   - Solution: Standardize to UTF-8 everywhere

5. **Base64 Decoding Error**
   - Signature not properly Base64 encoded
   - Solution: Verify Base64 encoding on device side

---

## Summary

**This example shows:**
✅ How device creates signature payload: `deviceId|dataJson`  
✅ How device signs it with private key  
✅ How backend receives the request  
✅ How backend rebuilds exact same payload  
✅ How backend verifies signature with public key  
✅ How to handle empty data (no pipe)  
✅ How to debug if verification fails  

Use this as a reference when implementing signature verification in any backend language.
