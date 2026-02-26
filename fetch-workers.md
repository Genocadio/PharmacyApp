# Fetch Workers for a Module

**Endpoint:** `POST /api/devices/fetch-workers`  
**Auth:** Device JWT token (`Authorization: Bearer <token>`) **or** signed request (no JWT needed — signature is used instead)

---

## Overview

Returns the full list of workers registered under the module that the requesting device belongs to. The request must include a valid cryptographic signature to prove device identity.

> **No `data` payload is needed.** The signature is computed over the bare `deviceId` string.

---

## Request

### Headers

| Header | Value |
|---|---|
| `Content-Type` | `application/json` |

### Body

```json
{
  "deviceId": "550e8400-e29b-41d4-a716-446655440000",
  "signature": "<base64-RSA-SHA256-signature>",
  "data": null
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `deviceId` | `string` | ✅ | UUID of the requesting device |
| `signature` | `string` | ✅ | Base64-encoded RSA-SHA256 signature (see [Signing](#signing-the-request)) |
| `data` | `null` | — | Must be omitted or `null` for this endpoint |

### Signing the Request

Because there is no `data` payload, the **canonical message** is simply the raw device ID string:

```
message = deviceId
```

Sign the UTF-8 bytes of `message` with the device's RSA private key using `SHA256withRSA`, then Base64-encode the result:

```kotlin
// Kotlin/Android example
val message = deviceId
val sig = Signature.getInstance("SHA256withRSA").apply {
    initSign(privateKey)
    update(message.toByteArray(Charsets.UTF_8))
}
val signature = Base64.encodeToString(sig.sign(), Base64.NO_WRAP)
```

---

## Response

**`200 OK`**

```json
{
  "data": [
    {
      "id": "W001",
      "name": "Alice Mutoni",
      "phoneNumber": "+250788000001",
      "email": "alice@example.com",
      "role": "cashier",
      "isActive": true
    },
    {
      "id": "W002",
      "name": "Bob Nkurunziza",
      "phoneNumber": "+250788000002",
      "email": null,
      "role": "manager",
      "isActive": false
    }
  ],
  "module": {
    "id": 1,
    "name": "Pharmacy Central",
    "activationStatus": "ACTIVE",
    "subscriptionTier": "MONTHLY",
    "expirationDate": "2026-03-26T00:00:00"
  },
  "status": {
    "isActive": true,
    "isSyncRequired": false,
    "supportMultiUsers": true,
    "message": "Module status retrieved"
  },
  "commands": []
}
```

### `data[]` – Worker Object

| Field | Type | Description |
|---|---|---|
| `id` | `string` | Worker ID assigned by the module branch |
| `name` | `string` | Full name |
| `phoneNumber` | `string` | Phone number |
| `email` | `string \| null` | Email address (optional) |
| `role` | `string` | Role within the module (e.g. `cashier`, `manager`) |
| `isActive` | `boolean` | Whether this worker is currently active |

### `status` Object

| Field | Type | Description |
|---|---|---|
| `isActive` | `boolean` | Module is ACTIVE |
| `isSyncRequired` | `boolean` | Device has pending sync changes |
| `supportMultiUsers` | `boolean` | Device is configured for multi-user mode |
| `message` | `string` | Human-readable status note |

### `commands[]`

Pending commands queued for this device (e.g. `LOGOUT`, `DELETE`). May be empty. Each command is marked **DELIVERED** upon receipt.

---

## Error Responses

| Status | When |
|---|---|
| `400 Bad Request` | `deviceId` or `signature` missing/null |
| `403 Forbidden` | Signature verification failed |
| `404 Not Found` | `deviceId` does not match any registered device |

```json
{
  "status": 403,
  "message": "Invalid signature for device ID: 550e8400-...",
  "timestamp": "2026-02-26T16:15:00",
  "path": "uri=/api/devices/fetch-workers"
}
```

---

## Related Endpoints

| Endpoint | Purpose |
|---|---|
| `POST /api/devices/sync-workers` | Push / upsert workers from device to server |
| `POST /api/devices/status` | Report device status and receive pending commands |
| `POST /api/devices/device-token` | Obtain a JWT for authenticated sync endpoints |
