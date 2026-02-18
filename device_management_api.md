# Device Management API

This document outlines the API endpoints for device registration, authentication, status updates, and data synchronization.

## Base URL
`/api/devices`

---

## 1. Register Device
Registers a new device to a module.

- **Endpoint**: `POST /api/devices/register-device`
- **Request Body**: `ModuleDeviceRegistrationRequest`
  ```json
  {
    "email": "string (optional)",
    "phone": "string (optional)",
    "code": "string (required, module registration code)",
    "publicKey": "string (required, RSA public key)",
    "appVersion": "string (required)",
    "latitude": number (optional),
    "longitude": number (optional),
    "deviceName": "string (optional)"
  }
  ```
- **Response**: `DeviceApiResponse<DeviceDTO>`

---

## 2. Generate Device Token
Generates a JWT token for the device to access protected endpoints.

- **Endpoint**: `POST /api/devices/device-token`
- **Request Body**: `DeviceTokenRequest`
  ```json
  {
    "moduleId": "number (required)",
    "deviceId": "string (required)",
    "message": "string (required, random nonce)",
    "signature": "string (required, signed message)"
  }
  ```
- **Response**:
  ```json
  {
    "token": "jwt-token-string"
  }
  ```

---

## 3. Device Status & Heartbeat
Updates device status/IP and retrieves module status and pending commands.

- **Endpoint**: `POST /api/devices/status`
- **Request Body**: `DeviceSignedRequest<DeviceStatusPayload>`
  ```json
  {
    "deviceId": "string (required)",
    "signature": "string (required)",
    "data": {
      "appVersion": "string (required)",
      "lastAction": "string (required)",
      "latitude": number (optional),
      "longitude": number (optional),
      "deviceName": "string (optional)"
    }
  }
  ```
- **Response**: `DeviceApiResponse<DeviceDTO>`

---

## 4. Sync Workers
Synchronizes workers associated with the module.

- **Endpoint**: `POST /api/devices/sync-workers`
- **Request Body**: `DeviceSignedRequest<WorkerSyncPayload>`
  ```json
  {
    "deviceId": "string (required)",
    "signature": "string (required)",
    "data": {
      "workers": [
        {
          "workerId": "string (UUID)",
          "firstName": "string",
          "lastName": "string",
          "phone": "string",
          "email": "string",
          "role": "enum (PHARMACIST, OWNER, etc.)",
          "pin": "string (hashed)",
          "active": boolean,
          "version": number,
          "deletedAt": "DateTime (optional)"
        }
      ]
    }
  }
  ```
- **Response**: `DeviceApiResponse<List<Worker>>`

---

## 5. Sales Snapshot
Saves a snapshot of detailed sales records for auditing and reporting.

- **Endpoint**: `POST /api/devices/sales-snapshot`
- **Request Body**: `DeviceSignedRequest<SalesSnapshotPayload>`
  ```json
  {
    "deviceId": "string (required)",
    "signature": "string (required)",
    "data": {
      "sales": [
        {
          "id": "string (UUID)",
          "transactionId": "string",
          "stockOutId": "string (UUID)",
          "patientName": "string",
          "totalPrice": number,
          "userId": "string (UUID)",
          "createdAt": "DateTime"
        }
      ],
      "period": "string (e.g., 2024-02)"
    }
  }
  ```
- **Response**: `DeviceApiResponse<SalesSnapshot>`

---

## 6. Acknowledge Command
Acknowledges that a server command has been processed by the device.

- **Endpoint**: `POST /api/devices/acknowledge-command`
- **Request Body**: `DeviceSignedRequest<CommandAcknowledgmentPayload>`
  ```json
  {
    "deviceId": "string",
    "signature": "string",
    "data": {
      "commandId": number
    }
  }
  ```
- **Response**: `DeviceApiResponse<Void>`

---

## 7. Update Public Key
Rotates the device/module public key.

- **Endpoint**: `POST /api/devices/update-public-key`
- **Request Body**: `DeviceSignedRequest<UpdatePublicKeyPayload>`
  ```json
  {
    "deviceId": "string",
    "signature": "string (signed with NEW private key)",
    "data": {
      "newPublicKey": "string"
    }
  }
  ```
- **Response**: `DeviceApiResponse<Void>`

---

## 8. Recycle Module Code
Generates a new module registration code.

- **Endpoint**: `POST /api/devices/recycle-code`
- **Request Body**: `DeviceSignedRequest<Void>`
- **Response**: `DeviceApiResponse<String>` (Data contains the new code)

---

## Schemas & Objects

### DeviceApiResponse<T>
- `data`: T - Primary response data.
- `module`: `ModuleResponse` - Basic module info.
- `status`: `DeviceStatusDTO` - Sync and activation status.
- `commands`: `List<DeviceCommandDTO>` - Pending server commands.

### DeviceDTO
- `id`: Long
- `deviceId`: String (UUID)
- `deviceName`: String
- `appVersion`: String
- `latitude`: Double
- `longitude`: Double
- `lastAction`: String
- `deviceType`: Enum (POS, MOBILE)
- `activationStatus`: Enum (PENDING, ACTIVE, INACTIVE)
- `supportMultiUsers`: Boolean
- `lastSeenAt`: DateTime
- `createdAt`: DateTime

### ModuleResponse
- `id`: Long
- `moduleCode`: String
- `name`: String
- `phone`: String
- `email`: String
- `country`: String
- `province`: String
- `district`: String
- `sector`: String
- `logoUrl`: String
- `activationStatus`: Enum
- `subscriptionTier`: Enum
- `expirationDate`: DateTime
- `serviceType`: Enum
- `subType`: Enum
- `paymentMethods`: `List<ModulePaymentMethodDTO>`

### ModulePaymentMethodDTO
- `id`: Long
- `account`: String
- `currency`: String
- `type`: String (e.g., MOMO, Bank, Card)

### DeviceStatusDTO
- `isActive`: Boolean
- `isSyncRequired`: Boolean
- `message`: String

### DeviceCommandDTO
- `id`: Long
- `type`: String
- `status`: String
- `createdAt`: DateTime
- `deliveredAt`: DateTime
- `acknowledgedAt`: DateTime
