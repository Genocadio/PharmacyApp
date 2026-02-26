# Stock API Reference

Base path: `/api/stocks`

All endpoints require a signed `DeviceSignedRequest` envelope. Every request must carry the device's digital signature so the server can verify the caller's identity before processing.

---

## Authentication & Request Envelope

Every body sent to these endpoints (except paginated GET endpoints) must be wrapped in the following JSON structure:

```json
{
  "deviceId": "string (required)",
  "signature": "string (required) — base64-encoded RSA/ECDSA signature",
  "data": { ... }
}
```

GET (paginated) endpoints pass `deviceId` and `signature` as **query parameters** instead of a body.

### How to sign a request

1. Serialise the `data` payload to a canonical JSON string (keys sorted, consistent date format `yyyy-MM-dd'T'HH:mm:ss.SSS`).
2. Sign the canonical JSON with the device private key.
3. Base64-encode the signature bytes.
4. Put the result in the `signature` field.

---

## Standard Response Envelope

All endpoints return the same outer shape:

```json
{
  "data": { ... },          // the actual payload, may be null
  "module": { ... },        // current module info
  "status": { ... },        // current device status
  "commands": [ ... ]       // any pending commands for the device
}
```

---

## Endpoints

### Bulk Sync

#### `POST /api/stocks/sync`

Bulk-upsert stock-in and stock-out records from the device. Used for initial sync and incremental push.

**Request body** (`data` field is `StockSyncData`):

```json
{
  "deviceId": "abc-device-001",
  "signature": "<base64>",
  "data": {
    "stocksIn": [ <StockInDTO>, ... ],
    "stocksOut": [ <StockOutDTO>, ... ]
  }
}
```

> **Upsert logic:** if `id` is provided in a record, the server will find and update it. If `id` is absent or not found, a new record is created.
>
> **Partial tolerance:** missing `StockIn` references on a `StockOutItem` during sync are **skipped with a warning** (non-fatal) — the rest of the sync continues.

**Response `data`:** `null` (check `status` and `commands` for device updates)

---

### Stock-In (Purchases / Received Inventory)

#### `POST /api/stocks/in`

Create a single new stock-in record.

**Request body** (`data` is `StockInDTO`):

```json
{
  "deviceId": "abc-device-001",
  "signature": "<base64>",
  "data": {
    "productId": "uuid",
    "quantity": 100,
    "location": "Shelf A",
    "pricePerUnit": 5.50,
    "batchNumber": "BATCH-2024-01",
    "expiryDate": "2026-12-31T00:00:00.000",
    "reorderLevel": 10
  }
}
```

| Field | Type | Required | Notes |
|---|---|---|---|
| `productId` | `UUID` | ✅ | Must exist in the system |
| `quantity` | `Integer` | ✅ | Units received |
| `pricePerUnit` | `BigDecimal` | ✅ | Cost/buying price per unit |
| `location` | `String` | ❌ | Storage location label |
| `batchNumber` | `String` | ❌ | Manufacturer batch ID |
| `expiryDate` | `DateTime` | ❌ | ISO-8601 datetime |
| `reorderLevel` | `Integer` | ❌ | Threshold for low-stock alerts |

**Response `data`:** `StockInDTO` (the created record including server-assigned `id` and `createdAt`)

---

#### `GET /api/stocks/in/{id}`

Fetch a single stock-in record by ID.

**Query params:** `deviceId`, `signature`

**Response `data`:** `StockInDTO`

---

#### `PUT /api/stocks/in`

Update an existing stock-in record.

**Request body** (`data` is `StockInDTO`):  
Same fields as POST + `id` (required to identify the record).

> **Note:** `productId` cannot be changed after creation. Other fields are updatable.

**Response `data`:** `StockInDTO` (updated)

---

#### `DELETE /api/stocks/in/{id}`

Delete a stock-in record.

**Query params:** `deviceId`, `signature`

**Response `data`:** `null`

---

#### `GET /api/stocks/in` — Paginated List

List stock-in records with optional filtering and pagination.

**Query params:**

| Param | Type | Required | Description |
|---|---|---|---|
| `deviceId` | `String` | ✅ | |
| `signature` | `String` | ✅ | |
| `productName` | `String` | ❌ | Partial, case-insensitive match |
| `startDate` | `DateTime` | ❌ | ISO-8601, filters by `createdAt >=` |
| `endDate` | `DateTime` | ❌ | ISO-8601, filters by `createdAt <=` |
| `page` | `Integer` | ❌ | 0-indexed, default `0` |
| `size` | `Integer` | ❌ | Default `20` |
| `sort` | `String` | ❌ | e.g. `createdAt,desc` |

**Response `data`:** `Page<StockInDTO>`

---

### Stock-Out (Dispensing / Sales)

#### `POST /api/stocks/out`

Create a new stock-out transaction (for one or more dispensed items).

**Request body** (`data` is `StockOutDTO`):

```json
{
  "deviceId": "abc-device-001",
  "signature": "<base64>",
  "data": {
    "mode": "RETAIL",
    "counterpartyName": "John Doe",
    "createdByUserId": "uuid",
    "items": [
      {
        "stockInId": "uuid-of-stock-in-batch",
        "quantitySold": 5,
        "pricePerUnit": 7.00
      }
    ],
    "insuranceCardNumber": "RSSB-12345",
    "issuingCompany": "RSSB",
    "prescriberName": "Dr. Smith",
    "prescriberLicenseId": "LIC-0001",
    "prescribingOrganization": "King Faisal Hospital"
  }
}
```

**`mode` values:**

| Value | Description | Extra fields used |
|---|---|---|
| `RETAIL` | Dispensing to a patient | `insuranceCardNumber`, `issuingCompany`, `prescriberName`, `prescriberLicenseId`, `prescribingOrganization` |
| `WHOLESALE` | Selling to another pharmacy | `destinationPharmacyPhone`, `tinNumber` |
| `CLINIC` | Supplying a clinic service | `destinationClinicService` |

**`items` array (required, one or more):**

| Field | Type | Required | Notes |
|---|---|---|---|
| `stockInId` | `UUID` | ✅ | The specific batch to deduct from |
| `quantitySold` | `Integer` | ✅ | Units dispensed from that batch |
| `pricePerUnit` | `BigDecimal` | ✅ | Selling price per unit |

**`status` values:**

| Value | Description |
|---|---|
| `POSTED` | Default — active transaction |
| `VOIDED` | Cancelled, `voidReason` should be set |

**Response `data`:** `StockOutDTO` (created record with `id`, `createdAt`, full `items` list)

---

#### `GET /api/stocks/out/{id}`

Fetch a single stock-out transaction by ID.

**Query params:** `deviceId`, `signature`

**Response `data`:** `StockOutDTO`

---

#### `PUT /api/stocks/out`

Update an existing stock-out transaction.

**Request body** (`data` is `StockOutDTO`):  
Same as POST + `id`. The existing `items` list is **fully replaced** by the new one provided.

**Response `data`:** `StockOutDTO` (updated)

---

#### `DELETE /api/stocks/out/{id}`

Delete a stock-out transaction.

**Query params:** `deviceId`, `signature`

**Response `data`:** `null`

---

#### `GET /api/stocks/out` — Paginated List

List stock-out transactions with optional filtering.

**Query params:** same as `GET /api/stocks/in` plus:

| Param | Type | Required | Description |
|---|---|---|---|
| `productName` | `String` | ❌ | Filters by product name across all items in the transaction |

> **Note:** When filtering by `productName`, duplicate transactions are automatically de-duplicated (a transaction with 3 matching items is returned once).

**Response `data`:** `Page<StockOutDTO>`

---

## Error Responses

All errors follow:
```json
{
  "status": 404,
  "message": "StockIn not found with id: <uuid>",
  "timestamp": "2026-02-24T10:00:00",
  "path": "uri=/api/stocks/out"
}
```

| Status | Situation |
|---|---|
| `400` | Invalid request body, validation failure, missing required field |
| `401` | Invalid or missing signature / expired JWT |
| `404` | Referenced resource not found (product, stock-in batch, etc.) |
| `500` | Unexpected server error |
