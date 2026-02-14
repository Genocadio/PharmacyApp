# Backend Implementation Verification Checklist

This document ensures your backend signature verification implementation is correct and platform-independent.

---

## Pre-Implementation Review

Before writing any verification code, confirm your understanding:

### ✅ Do you understand the format?
- [ ] Signature payload format: `deviceId|dataJson` (with pipe separator)
- [ ] Empty data format: just `deviceId` (no pipe if data is empty/null)
- [ ] JSON is compact (no extra whitespace)
- [ ] Original data included in request (for reference only)

### ✅ Do you have the data flow?
- [ ] Device sends: `{ deviceId, signature (Base64), data }`
- [ ] Backend extracts: deviceId, signature, data
- [ ] Backend rebuilds: signature payload from deviceId + data
- [ ] Backend looks up: public key for that device
- [ ] Backend verifies: signature against payload with public key

### ✅ Do you have the cryptography right?
- [ ] Algorithm: RSA-2048
- [ ] Hash: SHA-256
- [ ] Padding: PKCS#1 v1.5 (RSA standard)
- [ ] Signature Format: Raw bytes → Base64 encoded
- [ ] Public Key Format: PEM encoded RSA public key

---

## Implementation Steps

### Step 1: Extract Request Data

Your verification function receives an HTTP request.

**Expected Request JSON:**
```json
{
  "deviceId": "device-12345abc",
  "signature": "base64EncodedSignature...",
  "data": {
    "workers": [...],
    "stocks": [...],
    "sales": {...}
  }
}
```

**Java Implementation:**
```java
@PostMapping("/api/devices/sync-workers")
public ResponseEntity<?> syncWorkers(@RequestBody DeviceSyncRequest request) {
    String deviceId = request.getDeviceId();
    String signature = request.getSignature();
    Object data = request.getData();
    
    // Continue to Step 2...
}
```

### Step 2: Rebuild Signature Payload

**CRITICAL: Rebuild EXACTLY as device does**

Show the actual rebuilt payload in logs during development:

**Java Implementation:**
```java
private String rebuildSignaturePayload(String deviceId, Object data) {
    // Step 2a: Check if data is empty
    if (data == null) {
        return deviceId;  // Just deviceId, no pipe
    }
    
    String dataJson;
    if (data instanceof Map) {
        Map<String, Object> map = (Map<String, Object>) data;
        if (map.isEmpty()) {
            return deviceId;  // Just deviceId, no pipe
        }
        // Convert to compact JSON
        dataJson = objectMapper.writeValueAsString(map);
    } else if (data instanceof List) {
        List<?> list = (List<?>) data;
        if (list.isEmpty()) {
            return deviceId;  // Just deviceId, no pipe
        }
        dataJson = objectMapper.writeValueAsString(list);
    } else {
        dataJson = objectMapper.writeValueAsString(data);
    }
    
    // Step 2b: Ensure compact JSON (no spaces)
    // Using Jackson's default writeValueAsString does this correctly
    String payload = deviceId + "|" + dataJson;
    
    // Step 2c: Log for debugging
    logger.debug("Rebuilt signature payload: {}", payload);
    
    return payload;
}
```

**Python Implementation:**
```python
def rebuild_signature_payload(device_id, data):
    """Rebuild signature payload exactly as device does"""
    
    # Check if data is empty
    if data is None:
        return device_id
    
    if isinstance(data, dict) and len(data) == 0:
        return device_id
    
    if isinstance(data, list) and len(data) == 0:
        return device_id
    
    # Convert to compact JSON (no spaces)
    data_json = json.dumps(data, separators=(',', ':'), sort_keys=False)
    
    payload = f"{device_id}|{data_json}"
    
    logger.debug(f"Rebuilt signature payload: {payload}")
    
    return payload
```

**Node.js Implementation:**
```javascript
function rebuildSignaturePayload(deviceId, data) {
    // Check if data is empty
    if (data === null || data === undefined) {
        return deviceId;
    }
    
    if (Array.isArray(data) && data.length === 0) {
        return deviceId;
    }
    
    if (typeof data === 'object' && Object.keys(data).length === 0) {
        return deviceId;
    }
    
    // Convert to compact JSON
    const dataJson = JSON.stringify(data);  // Compact by default
    
    const payload = `${deviceId}|${dataJson}`;
    
    console.log(`Rebuilt signature payload: ${payload}`);
    
    return payload;
}
```

### Step 3: Get Public Key

**Java Implementation:**
```java
private String getPublicKeyPem(String deviceId) {
    // Query database for device
    Device device = deviceRepository.findById(deviceId)
        .orElseThrow(() -> new DeviceNotFoundException("Device not found: " + deviceId));
    
    String publicKeyPem = device.getPublicKey();
    if (publicKeyPem == null || publicKeyPem.isEmpty()) {
        throw new InvalidPublicKeyException("No public key for device: " + deviceId);
    }
    
    logger.debug("Retrieved public key for device: {}", deviceId);
    
    return publicKeyPem;
}

private PublicKey loadPublicKeyFromPem(String pem) throws Exception {
    // Remove PEM headers
    String publicKeyPEM = pem
        .replace("-----BEGIN RSA PUBLIC KEY-----", "")
        .replace("-----END RSA PUBLIC KEY-----", "")
        .replaceAll("\\s+", "");
    
    // Decode from Base64
    byte[] publicKeyDER = Base64.getDecoder().decode(publicKeyPEM);
    
    // Create PublicKey
    KeyFactory keyFactory = KeyFactory.getInstance("RSA");
    X509EncodedKeySpec keySpec = new X509EncodedKeySpec(publicKeyDER);
    PublicKey publicKey = keyFactory.generatePublic(keySpec);
    
    return publicKey;
}
```

**Python Implementation:**
```python
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend

def get_public_key(device_id):
    """Get public key from database"""
    device = Device.objects.get(id=device_id)
    
    if not device.public_key:
        raise ValueError(f"No public key for device: {device_id}")
    
    logger.debug(f"Retrieved public key for device: {device_id}")
    
    return device.public_key

def load_public_key_from_pem(pem_string):
    """Load public key from PEM format"""
    public_key = serialization.load_pem_public_key(
        pem_string.encode(),
        backend=default_backend()
    )
    return public_key
```

### Step 4: Verify Signature

**Java Implementation:**
```java
private boolean verifySignature(String payload, String signatureB64, PublicKey publicKey) 
        throws Exception {
    
    // Convert signature from Base64
    byte[] signatureBytes = Base64.getDecoder().decode(signatureB64);
    
    // Create verifier
    Signature sig = Signature.getInstance("SHA256withRSA");
    sig.initVerify(publicKey);
    sig.update(payload.getBytes(StandardCharsets.UTF_8));
    
    // Verify
    boolean isValid = sig.verify(signatureBytes);
    
    logger.debug("Signature verification: {}", isValid ? "VALID" : "INVALID");
    
    return isValid;
}
```

**Python Implementation:**
```python
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import padding
import base64

def verify_signature(payload, signature_b64, public_key):
    """Verify RSA signature"""
    
    # Decode signature from Base64
    signature_bytes = base64.b64decode(signature_b64)
    
    try:
        # Verify
        public_key.verify(
            signature_bytes,
            payload.encode('utf-8'),
            padding.PKCS1v15(),
            hashes.SHA256()
        )
        logger.debug("Signature verification: VALID")
        return True
    except InvalidSignature:
        logger.debug("Signature verification: INVALID")
        return False
```

**Node.js Implementation:**
```javascript
const crypto = require('crypto');

function verifySignature(payload, signatureB64, publicKeyPem) {
    // Decode signature from Base64
    const signatureBytes = Buffer.from(signatureB64, 'base64');
    
    // Create verifier
    const verifier = crypto.createVerify('RSA-SHA256');
    verifier.update(payload, 'utf8');
    
    // Verify
    const isValid = verifier.verify(publicKeyPem, signatureBytes);
    
    console.log(`Signature verification: ${isValid ? 'VALID' : 'INVALID'}`);
    
    return isValid;
}
```

### Step 5: Put It All Together

**Java Implementation:**
```java
@PostMapping("/api/devices/sync-workers")
public ResponseEntity<?> syncWorkers(@RequestBody DeviceSyncRequest request) {
    try {
        // Step 1: Extract
        String deviceId = request.getDeviceId();
        String signature = request.getSignature();
        Object data = request.getData();
        
        logger.info("Sync request from device: {}", deviceId);
        
        // Step 2: Rebuild payload
        String payload = rebuildSignaturePayload(deviceId, data);
        
        // Step 3: Get public key
        String publicKeyPem = getPublicKeyPem(deviceId);
        PublicKey publicKey = loadPublicKeyFromPem(publicKeyPem);
        
        // Step 4: Verify signature
        if (!verifySignature(payload, signature, publicKey)) {
            logger.warn("Invalid signature from device: {}", deviceId);
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(new ErrorResponse("Invalid signature"));
        }
        
        logger.info("Signature verified for device: {}", deviceId);
        
        // Step 5: Process the data safely
        processSyncWorkers(deviceId, (List<?>) data);
        
        return ResponseEntity.ok(new SuccessResponse("Sync completed"));
        
    } catch (DeviceNotFoundException e) {
        logger.error("Device not found: {}", e.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(new ErrorResponse("Device not found"));
    } catch (Exception e) {
        logger.error("Error processing sync request", e);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
            .body(new ErrorResponse("Internal error"));
    }
}
```

**Python Implementation (Django):**
```python
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
import json
import logging

logger = logging.getLogger(__name__)

@require_http_methods(["POST"])
def sync_workers(request):
    try:
        # Step 1: Extract
        data = json.loads(request.body)
        device_id = data.get('deviceId')
        signature = data.get('signature')
        workers = data.get('data')
        
        logger.info(f"Sync request from device: {device_id}")
        
        # Step 2: Rebuild payload
        payload = rebuild_signature_payload(device_id, workers)
        
        # Step 3: Get public key
        public_key_pem = get_public_key(device_id)
        public_key = load_public_key_from_pem(public_key_pem)
        
        # Step 4: Verify signature
        if not verify_signature(payload, signature, public_key):
            logger.warning(f"Invalid signature from device: {device_id}")
            return JsonResponse({"error": "Invalid signature"}, status=401)
        
        logger.info(f"Signature verified for device: {device_id}")
        
        # Step 5: Process data
        process_sync_workers(device_id, workers)
        
        return JsonResponse({"status": "success", "message": "Sync completed"})
        
    except Device.DoesNotExist:
        logger.error(f"Device not found: {device_id}")
        return JsonResponse({"error": "Device not found"}, status=404)
    except Exception as e:
        logger.error(f"Error processing sync request: {str(e)}")
        return JsonResponse({"error": "Internal error"}, status=500)
```

---

## Testing Your Implementation

### Unit Test Template

**Java (JUnit):**
```java
@Test
public void testValidSignature() throws Exception {
    // Given
    String deviceId = "device-test-001";
    String payload = deviceId + "|{\"workers\":[]}";  // Known payload
    byte[] signatureBytes = createTestSignature(payload);  // Use test private key
    String signatureB64 = Base64.getEncoder().encodeToString(signatureBytes);
    
    // When
    boolean isValid = verifySignature(payload, signatureB64, testPublicKey);
    
    // Then
    assertTrue(isValid);
}

@Test
public void testInvalidSignature() throws Exception {
    // Given
    String deviceId = "device-test-001";
    String payload = deviceId + "|{\"workers\":[]}";
    String tamperingSignature = "invalid+signature+here==";
    
    // When
    boolean isValid = verifySignature(payload, tamperingSignature, testPublicKey);
    
    // Then
    assertFalse(isValid);
}

@Test
public void testEmptyData() throws Exception {
    // Given
    String deviceId = "device-test-001";
    Object emptyData = Collections.emptyMap();
    
    // When
    String payload = rebuildSignaturePayload(deviceId, emptyData);
    
    // Then
    assertEquals(deviceId, payload);  // Should be just deviceId
}
```

**Python (pytest):**
```python
def test_valid_signature():
    # Given
    device_id = "device-test-001"
    data = {"workers": []}
    payload = rebuild_signature_payload(device_id, data)
    signature_b64 = create_test_signature(payload)
    
    # When
    is_valid = verify_signature(payload, signature_b64, test_public_key)
    
    # Then
    assert is_valid is True

def test_invalid_signature():
    # Given
    device_id = "device-test-001"
    data = {"workers": []}
    payload = rebuild_signature_payload(device_id, data)
    invalid_signature = "invalid+signature+here=="
    
    # When
    is_valid = verify_signature(payload, invalid_signature, test_public_key)
    
    # Then
    assert is_valid is False

def test_empty_data():
    # Given
    device_id = "device-test-001"
    empty_data = {}
    
    # When
    payload = rebuild_signature_payload(device_id, empty_data)
    
    # Then
    assert payload == device_id
```

---

## Validation Checklist

Before deploying to production:

### Code Review
- [ ] Device ID correctly extracted
- [ ] Signature correctly Base64 decoded
- [ ] Data correctly extracted and preserved
- [ ] Payload rebuilt exactly as device does
- [ ] Public key retrieved from correct source
- [ ] Public key in correct PEM format
- [ ] Signature verified with correct algorithm (SHA256withRSA)
- [ ] Empty data handled correctly (just deviceId)
- [ ] All error cases handled
- [ ] All exceptions logged

### Testing
- [ ] Valid signature passes
- [ ] Invalid signature fails
- [ ] Tampering detected
- [ ] Empty data handled
- [ ] Missing public key rejected
- [ ] Malformed requests rejected
- [ ] Load test: 100 requests/second
- [ ] Integration test: Real device integration

### Security
- [ ] Public key rotations handled
- [ ] Signature validation never skipped
- [ ] Untrusted data never processed before verification
- [ ] No raw signatures in logs (only indicators)
- [ ] No public keys in logs
- [ ] All operations use UTF-8
- [ ] All Base64 operations validated

---

## Troubleshooting

### Signature Always Fails

**Check these in order:**
1. **Public key correct?**
   - Verify in database: `SELECT public_key FROM devices WHERE id='device-001'`
   - Compare with what device reports

2. **JSON encoding matches?**
   - Device logs: `payload = "device-001|{\"name\":\"John\"}"`
   - Backend logs: rebuild and log same payload
   - Compare strings exactly

3. **Base64 decoding correct?**
   - Decode signature: `echo TlRq8x7vKz... | base64 -d | xxd`
   - Should be binary RSA signature (~256 bytes for RSA-2048)

4. **Payload reconstruction?**
   - Log both before and after
   - Check for whitespace differences
   - Ensure no line breaks

### Empty Data Becomes Valid After Falsely

**Check:**
- Device: checking `isEmpty()` before building payload?
- Backend: checking `== null` OR `isEmpty()`?
- Both must treat `null`, `[]`, and `{}` identically

### Integration Test Fails But Unit Tests Pass

**Check:**
- Device public key updated?
- Backend fetches latest public key?
- Timestamp matching (no clock skew)?
- Network transport doesn't corrupt data?

---

## Production Monitoring

Add metrics for:
- Signature verification success rate
- Verification latency (ms)
- Failed verification reasons (invalid key, tampered data, etc.)
- Device registration success rate

Alert when:
- Verification success rate drops below 99%
- Tampered requests exceed threshold
- Unknown devices attempt sync

This completes your platform-independent backend verification implementation.
