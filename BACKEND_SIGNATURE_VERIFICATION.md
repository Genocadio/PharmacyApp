# Backend Signature Verification - Platform Agnostic

**Universal guide for verifying NexxPharma device signatures in any backend language/framework**

This document shows how to implement signature verification regardless of your platform (Java, Kotlin, Python, Node.js, Go, C#, etc.).

---

## The Verification Process (Platform Agnostic)

### 3-Step Universal Process

```
1. Extract the request:
   - deviceId (string)
   - signature (Base64-encoded string)
   - data (JSON object/array or null)

2. Rebuild the signature payload:
   - If data is null, empty {}, or empty [] → payload = deviceId
   - If data exists and not empty → payload = deviceId + "|" + json.encode(data)

3. Verify signature:
   - Get public key from database using deviceId
   - Use RSA-2048 + SHA-256 to verify(payload, signature, publicKey)
   - If valid → Proceed | If invalid → Reject
```

---

## Implementation by Language

### Java

```java
import java.security.PublicKey;
import java.security.Signature;
import java.util.Base64;
import java.util.Map;
import com.fasterxml.jackson.databind.ObjectMapper;

public class SignatureVerifier {
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final PublicKeyRepository publicKeyRepo;
    
    public boolean verifyDeviceRequest(
            String deviceId,
            String signature,
            Map<String, Object> data) throws Exception {
        
        // Step 1: Build signature payload (exactly as device did)
        String signaturePayload = buildPayload(deviceId, data);
        
        // Step 2: Get public key from database
        PublicKey publicKey = publicKeyRepo.getPublicKey(deviceId)
            .orElseThrow(() -> new IllegalArgumentException("Device not registered: " + deviceId));
        
        // Step 3: Verify signature
        Signature sig = Signature.getInstance("SHA256withRSA");
        sig.initVerify(publicKey);
        sig.update(signaturePayload.getBytes(StandardCharsets.UTF_8));
        
        byte[] decodedSignature = Base64.getDecoder().decode(signature);
        return sig.verify(decodedSignature);
    }
    
    private String buildPayload(String deviceId, Map<String, Object> data) throws Exception {
        // Empty data → just deviceId
        if (data == null || data.isEmpty()) {
            return deviceId;
        }
        
        // Non-empty data → deviceId|jsonData
        String jsonData = objectMapper.writeValueAsString(data);
        return deviceId + "|" + jsonData;
    }
}
```

### Kotlin

```kotlin
import java.security.PublicKey
import java.security.Signature
import java.util.Base64
import com.fasterxml.jackson.databind.ObjectMapper

class SignatureVerifier(
    private val publicKeyRepository: PublicKeyRepository,
    private val objectMapper: ObjectMapper
) {
    
    fun verifyDeviceRequest(
        deviceId: String,
        signature: String,
        data: Map<String, Any>?
    ): Boolean {
        try {
            // Step 1: Build signature payload
            val signaturePayload = buildPayload(deviceId, data)
            
            // Step 2: Get public key
            val publicKey = publicKeyRepository.getPublicKey(deviceId)
                ?: throw IllegalArgumentException("Device not registered: $deviceId")
            
            // Step 3: Verify
            val sig = Signature.getInstance("SHA256withRSA")
            sig.initVerify(publicKey)
            sig.update(signaturePayload.toByteArray(Charsets.UTF_8))
            
            val decodedSignature = Base64.getDecoder().decode(signature)
            return sig.verify(decodedSignature)
        } catch (e: Exception) {
            logger.error("Signature verification failed for device: $deviceId", e)
            return false
        }
    }
    
    private fun buildPayload(deviceId: String, data: Map<String, Any>?): String {
        // Empty data → just deviceId
        if (data == null || data.isEmpty()) {
            return deviceId
        }
        
        // Non-empty data → deviceId|jsonData
        val jsonData = objectMapper.writeValueAsString(data)
        return "$deviceId|$jsonData"
    }
}
```

### Python

```python
import json
import base64
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.primitives.serialization import load_pem_public_key
from cryptography.hazmat.backends import default_backend

class SignatureVerifier:
    def __init__(self, public_key_repository):
        self.public_key_repository = public_key_repository
    
    def verify_device_request(self, device_id, signature, data):
        """
        Verify device request signature
        
        Args:
            device_id: Device identifier string
            signature: Base64-encoded RSA signature
            data: Request data dict or None
            
        Returns:
            True if signature is valid, False otherwise
        """
        try:
            # Step 1: Build signature payload
            signature_payload = self._build_payload(device_id, data)
            
            # Step 2: Get public key from database
            public_key_pem = self.public_key_repository.get_public_key(device_id)
            if not public_key_pem:
                raise ValueError(f"Device not registered: {device_id}")
            
            public_key = load_pem_public_key(
                public_key_pem.encode(),
                backend=default_backend()
            )
            
            # Step 3: Verify signature
            decoded_signature = base64.b64decode(signature)
            public_key.verify(
                decoded_signature,
                signature_payload.encode('utf-8'),
                padding.PKCS1v15(),
                hashes.SHA256()
            )
            
            return True
        except Exception as e:
            print(f"Signature verification failed: {e}")
            return False
    
    def _build_payload(self, device_id, data):
        """Build signature payload (match device format)"""
        # Empty data → just deviceId
        if data is None or not data:
            return device_id
        
        # Non-empty data → deviceId|jsonData
        json_data = json.dumps(data, separators=(',', ':'), sort_keys=True)
        return f"{device_id}|{json_data}"
```

### Node.js

```javascript
const crypto = require('crypto');

class SignatureVerifier {
    constructor(publicKeyRepository) {
        this.publicKeyRepository = publicKeyRepository;
    }
    
    verifyDeviceRequest(deviceId, signature, data) {
        try {
            // Step 1: Build signature payload
            const signaturePayload = this.buildPayload(deviceId, data);
            
            // Step 2: Get public key from database
            const publicKeyPem = this.publicKeyRepository.getPublicKey(deviceId);
            if (!publicKeyPem) {
                throw new Error(`Device not registered: ${deviceId}`);
            }
            
            // Step 3: Verify signature
            const verifier = crypto.createVerify('RSA-SHA256');
            verifier.update(signaturePayload, 'utf8');
            
            const decodedSignature = Buffer.from(signature, 'base64');
            return verifier.verify(publicKeyPem, decodedSignature);
        } catch (error) {
            console.error(`Signature verification failed: ${error.message}`);
            return false;
        }
    }
    
    buildPayload(deviceId, data) {
        // Empty data → just deviceId
        if (!data || Object.keys(data).length === 0) {
            return deviceId;
        }
        
        // Non-empty data → deviceId|jsonData
        const jsonData = JSON.stringify(data, null, 0); // Compact JSON
        return `${deviceId}|${jsonData}`;
    }
}
```

### Go

```go
package main

import (
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"fmt"
	"strings"
)

type SignatureVerifier struct {
	publicKeyRepo PublicKeyRepository
}

func (sv *SignatureVerifier) VerifyDeviceRequest(
	deviceId string,
	signature string,
	data map[string]interface{}) (bool, error) {
	
	// Step 1: Build signature payload
	signaturePayload := sv.buildPayload(deviceId, data)
	
	// Step 2: Get public key from database
	publicKeyPem, err := sv.publicKeyRepo.GetPublicKey(deviceId)
	if err != nil {
		return false, fmt.Errorf("device not registered: %s", deviceId)
	}
	
	publicKey, err := parsePublicKey(publicKeyPem)
	if err != nil {
		return false, err
	}
	
	// Step 3: Verify signature
	decodedSignature, err := base64.StdEncoding.DecodeString(signature)
	if err != nil {
		return false, err
	}
	
	hash := sha256.Sum256([]byte(signaturePayload))
	err = rsa.VerifyPKCS1v15(publicKey, crypto.SHA256, hash[:], decodedSignature)
	
	return err == nil, err
}

func (sv *SignatureVerifier) buildPayload(deviceId string, data map[string]interface{}) string {
	// Empty data → just deviceId
	if len(data) == 0 {
		return deviceId
	}
	
	// Non-empty data → deviceId|jsonData
	jsonBytes, _ := json.Marshal(data)
	jsonData := string(jsonBytes)
	return fmt.Sprintf("%s|%s", deviceId, jsonData)
}

func parsePublicKey(publicKeyPem string) (*rsa.PublicKey, error) {
	block, _ := pem.Decode([]byte(publicKeyPem))
	if block == nil {
		return nil, fmt.Errorf("invalid PEM format")
	}
	
	pub, err := x509.ParsePKIXPublicKey(block.Bytes)
	if err != nil {
		return nil, err
	}
	
	return pub.(*rsa.PublicKey), nil
}
```

### C#

```csharp
using System;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

public class SignatureVerifier {
    private readonly PublicKeyRepository publicKeyRepository;
    
    public SignatureVerifier(PublicKeyRepository publicKeyRepository) {
        this.publicKeyRepository = publicKeyRepository;
    }
    
    public bool VerifyDeviceRequest(
        string deviceId,
        string signature,
        Dictionary<string, object> data) {
        
        try {
            // Step 1: Build signature payload
            string signaturePayload = BuildPayload(deviceId, data);
            
            // Step 2: Get public key
            string publicKeyPem = publicKeyRepository.GetPublicKey(deviceId);
            if (string.IsNullOrEmpty(publicKeyPem)) {
                throw new ArgumentException($"Device not registered: {deviceId}");
            }
            
            // Step 3: Verify signature
            using (var rsa = new RSACryptoServiceProvider()) {
                rsa.ImportFromPem(publicKeyPem);
                
                byte[] payloadBytes = Encoding.UTF8.GetBytes(signaturePayload);
                byte[] signatureBytes = Convert.FromBase64String(signature);
                
                return rsa.VerifyData(
                    payloadBytes,
                    CryptoConfig.MapNameToOID("SHA256"),
                    signatureBytes);
            }
        } catch (Exception ex) {
            Console.WriteLine($"Signature verification failed: {ex.Message}");
            return false;
        }
    }
    
    private string BuildPayload(string deviceId, Dictionary<string, object> data) {
        // Empty data → just deviceId
        if (data == null || data.Count == 0) {
            return deviceId;
        }
        
        // Non-empty data → deviceId|jsonData
        string jsonData = JsonSerializer.Serialize(data);
        return $"{deviceId}|{jsonData}";
    }
}
```

---

## Universal Implementation Guidelines

### 1. Building the Signature Payload

**MUST be done identically on device and backend:**

```
if (data is None/null or empty) {
    payload = deviceId
} else {
    payload = deviceId + "|" + json_encode(data)
}
```

**Critical points:**
- ✅ Use standard JSON encoding (no custom serialization)
- ✅ Compact JSON (no whitespace)
- ✅ UTF-8 encoding
- ✅ Consistent key ordering (if possible)

### 2. Getting the Public Key

```
publicKey = database.getPublicKey(deviceId)
if (publicKey is not found) {
    reject("Device not registered")
}
```

### 3. Verifying the Signature

**Algorithm:** RSA-2048 with SHA-256

```
isValid = RSAVerifier.verify(
    payload = signature_payload,
    signature = base64_decode(signature_from_request),
    publicKey = public_key_from_database
)
```

### 4. Handling Errors

```
if (device not registered) {
    return 401 Unauthorized
}

if (signature invalid) {
    return 401 Unauthorized
    // Or 403 Forbidden depending on security policy
}

if (signature valid) {
    // Proceed with processing request
}
```

---

## Testing Signature Verification

### Unit Test Template (for any language)

```
Test Case: Valid Signature
1. Generate test RSA keypair
2. Create device with public key
3. Build payload: "device-001|{\"test\":\"data\"}"
4. Sign payload with private key
5. Call verifyDeviceRequest(device-001, signature, data)
6. Assert: returns true

Test Case: Invalid Signature
1. Build payload: "device-001|{\"test\":\"data\"}"
2. Sign payload
3. Tamper with signature (change a character)
4. Call verifyDeviceRequest(device-001, tampered_signature, data)
5. Assert: returns false

Test Case: Empty Data
1. Build payload: "device-001" (no pipe, no data)
2. Sign payload
3. Call verifyDeviceRequest(device-001, signature, {})
4. Assert: returns true

Test Case: Device Not Registered
1. Call verifyDeviceRequest(unknown-device, signature, data)
2. Assert: throws exception or returns false
```

---

## JSON Encoding Consistency

### Critical Issue: Ensure Same JSON Encoding

Device uses (Dart):
```dart
json.encode(data)  // Uses dart:convert
```

Backend must use same library/method:

**Java:**
```java
objectMapper.writeValueAsString(data)  // Jackson
```

**Python:**
```python
json.dumps(data, separators=(',', ':'))  # Compact
```

**Node.js:**
```javascript
JSON.stringify(data)  // Compact
```

### Testing JSON Consistency

Device side logs:
```
Signature Payload: device-001|{"test":"data"}
```

Backend must rebuild to exact same string for verification to work.

---

## Troubleshooting Verification Failures

| Issue | Check |
|-------|-------|
| Signature verification fails | JSON encoding matches exactly |
| Signature verification fails | Public key is correct and in PEM format |
| Signature verification fails | Payload includes device ID (not just data) |
| Device not found error | Device registration completed, public key stored |
| Base64 decode error | Signature is properly Base64 encoded from device |
| UTF-8 encoding error | All strings are UTF-8 before signing/verifying |

### Debug Logging Template

```
Device sending:
  DeviceId: device-001
  Payload: device-001|{"test":"data"}
  Signature: base64...

Backend receiving:
  Extracted DeviceId: device-001
  Extracted Signature: base64...
  Extracted Data: {"test":"data"}
  Rebuilt Payload: device-001|{"test":"data"}
  Public Key: -----BEGIN RSA PUBLIC KEY---...
  Verification Result: true/false
```

---

## Key Points to Remember

✅ **Platform independent** - Works with any language  
✅ **One verification function** - Same logic for all endpoints  
✅ **Stateless** - No session, no state tracking needed  
✅ **Deterministic** - Same input always produces same result  
✅ **Secure** - RSA-2048 + SHA-256 standard  
✅ **Simple** - Just payload + signature + public key  

---

## Common Mistakes to Avoid

❌ **Different JSON libraries** - Encoding must match exactly  
❌ **Pretty printing JSON** - Must be compact (no whitespace)  
❌ **Wrong algorithm** - Must be RSA-2048 with SHA-256  
❌ **Missing device ID** - Must be part of payload  
❌ **Platform-specific code** - Use standard libraries  
❌ **Verifying separately** - Verify deviceId + data together  

---

## Reference

**Signature Format:** `deviceId|dataJson` (or just `deviceId` if data empty)  
**Algorithm:** RSA-2048 with SHA-256  
**Encoding:** UTF-8  
**Signature Encoding:** Base64  
**Public Key Format:** PEM  

**Last Updated:** February 14, 2026  
**Status:** ✅ Production Ready  
**Version:** 1.0
