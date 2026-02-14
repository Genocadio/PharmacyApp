# Device Operations API

This document details how the device sends operational data to the server, including worker sync, stock updates, and sales snapshots.

## Signature Standard

**All device requests use a standardized signature format for authentication.**

### Signature Payload Format

**With Data:**
```
signaturePayload = deviceId|dataJson
```
Where `dataJson` is the JSON-encoded string of the data object.

**Without Data (or empty data):**
```
signaturePayload = deviceId
```

### Example Signature Generation

```dart
// With data
signaturePayload = "abc-123|{\"workers\":[{\"name\":\"John\"}]}"

// Without data (e.g., recycle module)
signaturePayload = "abc-123"

// Sign with RSA-2048 + SHA-256
signature = privateKey.createSignature(signaturePayload)
```

### Backend Verification

```kotlin
val signaturePayload = if (data != null && data.isNotEmpty()) {
    "$deviceId|${objectMapper.writeValueAsString(data)}"
} else {
    deviceId
}
val isValid = rsaVerifier.verify(signaturePayload, signature, publicKey)
```

**📖 See [signature_standard.md](signature_standard.md) for complete documentation.**

---

## 1. Sync Workers
Synchronizes worker (user) data from the device to the server.

- **Endpoint**: `POST /api/devices/sync-workers`
- **Request Body**: `DeviceSignedRequest<WorkerSyncPayload>`
  ```json
  {
    "deviceId": "string",
    "signature": "string (deviceId signed with private key)",
    "data": {
      "workers": [
        {
          "name": "string",
          "role": "string",
           ...
        }
      ]
    }
  }
  ```
- **Response**: `DeviceApiResponse<List<Worker>>`
  - Returns the list of synchronized/saved workers.

## 2. Stock Synchronization (In/Out)
Sends stock movement data (stock-in and stock-out) to the server.

- **Endpoint**: `POST /api/stocks/sync`
- **Request Body**: `StockSyncRequest`
  ```json
  {
    "deviceId": "string",
    "signature": "string (deviceId signed with private key)",
    "stocksIn": [
      {
        "id": "UUID",
        "productId": "UUID",
        "quantity": number,
        "batchNumber": "string",
        "expiryDate": "ISO-Date",
        "pricePerUnit": number,
        "location": "string",
        "reorderLevel": number
      }
    ],
    "stocksOut": [
      {
        "id": "UUID",
        "snapTimestamp": "ISO-Date",
        "items": [
          {
            "stockInId": "UUID",
            "unitsTaken": number,
            "pricePerUnit": number
          }
        ]
      }
    ]
  }
  ```
- **Response**: `DeviceApiResponse<Void>`
  - Uses the standard device response wrapper.

## 3. Sales Snapshot
Uploads a snapshot of sales data for reporting and backup.

- **Endpoint**: `POST /api/devices/sales-snapshot`
- **Request Body**: `DeviceSignedRequest<SalesSnapshotPayload>`
  ```json
  {
    "deviceId": "string",
    "signature": "string (deviceId signed with private key)",
    "data": {
      "sales": [
        {
          "totalAmount": number,
          "items": [...],
          "timestamp": "ISO-Date"
        }
      ],
      "period": "string (e.g., 'DAILY')"
    }
  }
  ```
- **Response**: `DeviceApiResponse<SalesSnapshot>`
  - Returns the saved snapshot details.
## Schemas & Objects

### Worker
- `id`: Long (Server ID)
- `workerId`: String (Device-assigned ID)
- `name`: String
- `phone`: String
- `email`: String (Optional)
- `role`: String
- `isActive`: Boolean
- `createdAt`: DateTime
- `updatedAt`: DateTime

### StockInDTO
- `id`: UUID
- `productId`: UUID
- `quantity`: Integer
- `location`: String
- `pricePerUnit`: BigDecimal
- `batchNumber`: String
- `expiryDate`: LocalDate
- `reorderLevel`: Integer

### StockOutDTO
- `id`: UUID
- `snapTimestamp`: DateTime
- `items`: `List<StockOutItemDTO>`

### StockOutItemDTO
- `stockInId`: UUID
- `unitsTaken`: Integer
- `pricePerUnit`: BigDecimal

### SalesSnapshot
- `id`: Long
- `snapTimestamp`: DateTime
- `totalAmount`: BigDecimal
- `totalPrivateAmount`: BigDecimal
- `totalInsuranceAmount`: BigDecimal
- `topProductId`: String
- `topProductAmount`: BigDecimal
- `topInsuranceId`: String
- `workerRevenues`: `List<WorkerRevenueDTO>`
- `createdAt`: DateTime

### WorkerRevenueDTO
- `workerId`: String
- `revenue`: BigDecimal
