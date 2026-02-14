# Signature Verification Guide

This document explains how device request signatures are created and verified by the backend.

## Overview

Devices use **RSA (Rivest-Shamir-Adleman)** cryptography to sign all authenticated requests. The backend verifies these signatures using the device's public key stored during registration.

## Signature Model: RSA-2048

- **Algorithm**: RSA with 2048-bit key pairs
- **Signing Method**: RSAPrivateKey.createSignature()
- **Verification Method**: RSAPublicKey.verifySignature()
- **Hash**: SHA-256 (implicit in crypton library)

## Key Exchange Process

### 1. Device Registration (Initial Setup)

```
Device generates RSA keypair (2048-bit)
    ↓
Device sends: { code, email/phone, publicKey, appVersion, latitude?, longitude? }
    ↓
Backend stores: { deviceId, publicKey, moduleId, ... }
    ↓
Backend returns: { deviceId, moduleId, module, status, commands }
    ↓
Device stores privately: privateKey (never sent to backend)
```

### 2. Public Key Rotation (Optional)

```
Device generates NEW RSA keypair
    ↓
Device signs new public key with NEW private key
    ↓
Backend verifies signature using OLD public key (already stored)
    ↓
Backend updates stored public key to NEW public key
    ↓
Device discards old private key, uses new one going forward
```

## Signature Payload Structure

### For Signed Requests (Status, Acknowledge, Recycle, Key Rotation)

The signature is computed over a JSON payload with this structure:

```json
{
  "deviceId": "uuid-string",
  "data": {
    "appVersion": "1.0.0",
    ...request-specific-fields
  }
}
```

**Encoding**: UTF-8 JSON string → Sign with private key → Base64-encoded signature

### Request Format (Signed)

```json
{
  "deviceId": "550e8400-e29b-41d4-a716-446655440000",
  "signature": "base64-encoded-rsa-signature-of-payload",
  "data": {
    "appVersion": "1.0.0",
    "activationStatus": "ACTIVE",
    "supportMultiUsers": false,
    "lastAction": "sync"
  }
}
```

## Backend Verification Process

### Step 1: Retrieve Device Public Key

```
SELECT publicKey FROM devices WHERE deviceId = request.deviceId
```

### Step 2: Reconstruct Signature Payload

```dart
final payload = json.encode({
  'deviceId': request.deviceId,
  'data': request.data,
});
```

### Step 3: Verify Signature

```dart
final isValid = publicKey.verifySignature(payload, request.signature);
if (!isValid) {
  throw UnauthorizedException('Signature verification failed');
}
```

### Step 4: Process Request

If signature is valid, proceed with request logic.

## Endpoints Using Device Signatures

| Endpoint | Method | Signature Required |
|----------|--------|-------------------|
| `/register-device` | POST | No (public) |
| `/device-token` | POST | No (uses module-level signing) |
| `/status` | POST | **Yes** (DeviceSignedRequest) |
| `/acknowledge-command` | POST | **Yes** (DeviceSignedRequest) |
| `/recycle-code` | POST | **Yes** (DeviceSignedRequest) |
| `/update-public-key` | POST | **Yes** (signed by NEW private key) |

## Security Considerations

1. **Private Key Storage**: Never transmitted, stored securely on device
2. **Public Key Rotation**: Enables key compromise recovery
3. **Signature Tampering**: Impossible without the private key
4. **Replay Attacks**: Mitigated by including timestamps/nonces in data
5. **Payload Integrity**: Entire request is signed, no selective signing

## Example: Signing a Status Update

### Device Side

```dart
// 1. Build payload
final payload = {
  'deviceId': '550e8400-e29b-41d4-a716-446655440000',
  'data': {
    'appVersion': '1.0.0',
    'activationStatus': 'ACTIVE',
    'supportMultiUsers': false,
    'lastAction': 'sync_completed',
  },
};

// 2. Create signature payload string
final signaturePayload = json.encode(payload);

// 3. Sign with private key
final signature = privateKey.createSignature(signaturePayload);

// 4. Send request
final request = DeviceSignedRequest(
  deviceId: payload['deviceId'],
  signature: signature,  // Base64-encoded
  data: payload['data'],
);

// 5. POST to backend
http.post(
  Uri.parse('${backendUrl}/api/devices/status'),
  headers: {'Content-Type': 'application/json'},
  body: json.encode(request.toJson((data) => data?.toJson())),
);
```

### Backend Side

```java
// 1. Receive request
DeviceSignedRequest request = objectMapper.readValue(body, DeviceSignedRequest.class);

// 2. Get device's public key
PublicKey publicKey = deviceRepository.findById(request.deviceId)
  .orElseThrow()
  .getPublicKey();

// 3. Reconstruct payload
String payload = objectMapper.writeValueAsString({
  "deviceId": request.deviceId,
  "data": request.data,
});

// 4. Verify signature
Signature sig = Signature.getInstance("SHA256withRSA");
sig.initVerify(publicKey);
sig.update(payload.getBytes(StandardCharsets.UTF_8));

boolean isValid = sig.verify(Base64.getDecoder().decode(request.signature));
if (!isValid) {
  throw new UnauthorizedException("Invalid signature");
}

// 5. Process request
updateDeviceStatus(request.data);
```

## Debugging Signature Issues

### Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| "Signature verification failed" | Private/public key mismatch | Verify key pair was generated together |
| "Invalid base64" | Signature encoding error | Ensure signature is properly base64-encoded |
| "Payload mismatch" | JSON field order changed | Use canonical JSON encoding |
| "Wrong algorithm" | Mixing RSA vs other algorithms | Ensure both sides use RSA-2048 |

### Debug Logging (Device)

```dart
debugPrint('=== Signature Debug ===');
debugPrint('DeviceId: ${request.deviceId}');
debugPrint('PrivateKey: ${privateKey.toString()}');
debugPrint('PublicKey: ${privateKey.publicKey.toString()}');
debugPrint('Payload: $payload');
debugPrint('Signature: $signature');
```

### Debug Logging (Backend)

```java
logger.debug("DeviceId: {}", request.getDeviceId());
logger.debug("PublicKey from DB: {}", publicKey.toString());
logger.debug("Payload for verification: {}", payload);
logger.debug("Signature from request: {}", request.getSignature());
logger.debug("Verification result: {}", isValid);
```

## Performance Notes

- RSA-2048 signing/verification takes ~5-50ms depending on platform
- Signature generation should be done asynchronously on device
- Backend should cache public keys to avoid repeated DB lookups
- Consider adding signature caching for idempotent operations

## References

- [RSA Cryptography](https://en.wikipedia.org/wiki/RSA_(cryptosystem))
- [PKCS #1: RSA Cryptography Standard](https://tools.ietf.org/html/rfc3447)
- [SHA-256 Secure Hash Algorithm](https://en.wikipedia.org/wiki/SHA-2)
