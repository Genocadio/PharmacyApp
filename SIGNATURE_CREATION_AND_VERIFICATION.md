# Understanding Device Signature Creation & Verification

## The Simple Flow

### Device Creates Signature

```
┌─────────────────────────────────────────────────────────────────┐
│ DEVICE SIDE: Creating Signature                                 │
└─────────────────────────────────────────────────────────────────┘

Step 1: Get the data to send
┌────────────────────────────────────────────────────────────────┐
│ data = {                                                         │
│   "workers": [{"name": "John", "role": "PHARMACIST"}, ...]     │
│ }                                                                │
└────────────────────────────────────────────────────────────────┘

Step 2: Build what to sign (SIGNATURE PAYLOAD)
┌────────────────────────────────────────────────────────────────┐
│ deviceId = "abc-123"                                             │
│ dataJson = json.encode(data)  // {"workers":[...]}              │
│                                                                  │
│ signaturePayload = deviceId + "|" + dataJson                    │
│ Result: "abc-123|{"workers":[...]}"                             │
│                                                                  │
│ ⚠️ THIS IS WHAT GETS SIGNED - NOT THE ENTIRE REQUEST            │
└────────────────────────────────────────────────────────────────┘

Step 3: Sign it with private key
┌────────────────────────────────────────────────────────────────┐
│ signature = privateKey.createSignature(signaturePayload)        │
│                                                                  │
│ RSA-2048 + SHA-256                                              │
│ Input:  "abc-123|{"workers":[...]}"                             │
│ Output: "base64-encoded-signature-value..."                     │
└────────────────────────────────────────────────────────────────┘

Step 4: Send the full request
┌────────────────────────────────────────────────────────────────┐
│ POST /api/devices/sync-workers                                  │
│ {                                                                │
│   "deviceId": "abc-123",          ← Part of signature payload   │
│   "signature": "base64-sig...",   ← The signature itself        │
│   "data": {"workers": [...]}      ← Part of signature payload   │
│ }                                                                │
└────────────────────────────────────────────────────────────────┘
```

### Backend Verifies Signature

```
┌─────────────────────────────────────────────────────────────────┐
│ BACKEND SIDE: Verifying Signature                               │
└─────────────────────────────────────────────────────────────────┘

Step 1: Receive the request (already shown above)
┌────────────────────────────────────────────────────────────────┐
│ Incoming: {                                                      │
│   "deviceId": "abc-123",                                         │
│   "signature": "base64-sig...",                                  │
│   "data": {"workers": [...]}                                     │
│ }                                                                │
└────────────────────────────────────────────────────────────────┘

Step 2: Extract components
┌────────────────────────────────────────────────────────────────┐
│ deviceId = "abc-123"              (from request)                │
│ signature = "base64-sig..."       (from request)                │
│ data = {"workers": [...]}         (from request)                │
└────────────────────────────────────────────────────────────────┘

Step 3: REBUILD THE EXACT PAYLOAD
┌────────────────────────────────────────────────────────────────┐
│ ⚠️ CRITICAL: Must rebuild EXACTLY what device signed            │
│                                                                  │
│ signaturePayload = deviceId + "|" + json.encode(data)           │
│ Result: "abc-123|{"workers":[...]}"                             │
│                                                                  │
│ This MUST match what device signed!                             │
└────────────────────────────────────────────────────────────────┘

Step 4: Get the public key
┌────────────────────────────────────────────────────────────────┐
│ publicKey = database.getPublicKey("abc-123")                    │
│                                                                  │
│ This public key was stored when device registered              │
│ It's the pair of the private key device is using to sign        │
└────────────────────────────────────────────────────────────────┘

Step 5: Verify the signature
┌────────────────────────────────────────────────────────────────┐
│ isValid = RSAVerifier.verify(                                    │
│   payload = "abc-123|{"workers":[...]}"  ← Rebuilt payload      │
│   signature = "base64-sig..."             ← From request        │
│   publicKey = ...                         ← From database       │
│ )                                                                │
│                                                                  │
│ If isValid = true  → Device with matching private key signed it │
│ If isValid = false → Either wrong payload or wrong signature    │
└────────────────────────────────────────────────────────────────┘
```

---

## The Relationship: deviceId + data = Payload to Sign

### Key Concept

**The `deviceId` and `data` are NOT verified separately. They're combined to create ONE payload:**

```
Signature Payload = deviceId + "|" + json.encode(data)
```

**Example:**

```dart
// On device
deviceId = "device-001"
data = {"appVersion": "1.0.0", "status": "ACTIVE"}

// Build signature payload
signaturePayload = "device-001|{\"appVersion\":\"1.0.0\",\"status\":\"ACTIVE\"}"

// Sign this combined string
signature = privateKey.createSignature(signaturePayload)

// Send in request
{
  "deviceId": "device-001",
  "signature": signature,
  "data": {"appVersion": "1.0.0", "status": "ACTIVE"}
}
```

```kotlin
// On backend
// 1. Extract from request
deviceId = "device-001"
signature = "base64-value..."
data = {"appVersion": "1.0.0", "status": "ACTIVE"}

// 2. Rebuild the SAME payload
signaturePayload = "device-001|{\"appVersion\":\"1.0.0\",\"status\":\"ACTIVE\"}"

// 3. Verify with public key
isValid = RSAVerifier.verify(signaturePayload, signature, publicKey)
```

### Why Both Are Needed

**deviceId is part of the signature because:**
- ✅ Prevents a device from spoofing another device's request
- ✅ Ensures the signature is bound to a specific device
- ✅ If deviceId changed, signature would be invalid

**data is part of the signature because:**
- ✅ Ensures data hasn't been tampered with
- ✅ Any change to data invalidates the signature
- ✅ Proves the exact data the device sent

---

## Real Code Example from Your App

### Device Side (sync_service.dart)

```dart
// 1. Collect data to sync
final dataPayload = {'workers': workers};

// 2. Build signature payload (deviceId + data)
final signaturePayload = _buildSignaturePayload(deviceId, dataPayload);
// Result: "abc-123|{\"workers\":[...]}"

// 3. Sign it
final signature = privateKey.createSignature(signaturePayload);

// 4. Send request
final request = {
  'deviceId': deviceId,
  'signature': signature,
  'data': dataPayload,
};
```

### Backend Verification (Pseudocode)

```kotlin
@PostMapping("/api/devices/sync-workers")
fun syncWorkers(@RequestBody request: DeviceSignedRequest<WorkerSyncPayload>) {
    // 1. Extract
    val deviceId = request.deviceId
    val signature = request.signature
    val data = request.data
    
    // 2. Rebuild signature payload (MUST match device)
    val signaturePayload = "$deviceId|${objectMapper.writeValueAsString(data)}"
    
    // 3. Get public key
    val publicKey = database.getPublicKey(deviceId)
    
    // 4. Verify
    val isValid = RSAVerifier.verify(signaturePayload, signature, publicKey)
    
    if (!isValid) {
        throw UnauthorizedException("Invalid signature")
    }
    
    // ✅ Signature verified! Now process the data safely
    processSyncWorkers(deviceId, data.workers)
}
```

---

## What Gets Verified

```
┌──────────────────────────────────────────────────────────────┐
│ SIGNATURE PROVES:                                            │
├──────────────────────────────────────────────────────────────┤
│ ✅ Request came from this specific device                     │
│    (has correct private key)                                 │
│                                                              │
│ ✅ Data has NOT been modified                                │
│    (any change would break signature)                        │
│                                                              │
│ ✅ This exact deviceId and data were signed                  │
│    (can't mix and match)                                     │
└──────────────────────────────────────────────────────────────┘
```

---

## Common Mistakes to Avoid

### ❌ Backend Mistake 1: Checking deviceId and data separately

```kotlin
// ❌ WRONG - Checking fields individually
if (request.deviceId != device.id) {
    // This is already checked by signature!
}
```

**Why wrong:** The signature already proves deviceId and data match. Checking them separately is redundant and misses the point of signing.

### ❌ Backend Mistake 2: Rebuilding payload differently

```kotlin
// ❌ WRONG - Different format
val payload = objectMapper.writeValueAsString(request.data)  // No deviceId!
val isValid = RSAVerifier.verify(payload, signature, publicKey)
```

**Why wrong:** Device signed `deviceId|data`, not just `data`. The payload MUST match exactly.

### ❌ Backend Mistake 3: Pretty-printing JSON for signature

```kotlin
// ❌ WRONG - Adds whitespace
val json = objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(data)
val signaturePayload = "$deviceId|$json"
```

**Why wrong:** Device used compact JSON. Extra whitespace changes the signature. Must match exactly.

### ✅ Backend Correct Way

```kotlin
// ✅ CORRECT - Rebuild exactly
val signaturePayload = "$deviceId|${objectMapper.writeValueAsString(data)}"
val isValid = RSAVerifier.verify(signaturePayload, signature, publicKey)
```

---

## Summary

**The relationship is simple:**

1. **Device combines**: `deviceId` + `data` → creates signature payload
2. **Device signs**: the combined payload with its private key
3. **Device sends**: deviceId, signature, and data in request
4. **Backend rebuilds**: the same `deviceId` + `data` combination
5. **Backend verifies**: that the signature matches using public key
6. **Result**: Proves device is authentic and data is unmodified

**Key insight:** They're not verified separately. They're verified together as one signed payload to ensure integrity and authenticity.
