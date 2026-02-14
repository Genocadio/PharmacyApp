# Device Management API

This document outlines the API endpoints for device registration, authentication, status updates, and command management.

## Base URL
`/api/devices`

## 1. Register Device
Registers a new device to a module.

- **Endpoint**: `POST /register-device`
- **Request Body**: `ModuleDeviceRegistrationRequest`
  ```json
  {
    "email": "string (optional, one of email/phone required)",
    "phone": "string (optional, one of email/phone required)",
    "code": "string (required, module code)",
    "publicKey": "string (required, RSA public key)",
    "appVersion": "string (required)",
    "deviceName": "string (optional)",
    "latitude": number (optional),
    "longitude": number (optional)
  }
  ```
- **Response**: `DeviceApiResponse<DeviceDTO>`
  ```json
  {
    "data": {
      "id": 1,
      "deviceId": "uuid-string",
      "deviceName": "string",
      ...
    },
    "module": { ... },
    "status": { ... },
    "commands": [ ... ]
  }
  ```

## 2. Generate Device Token
Generates a JWT token for the device to access protected endpoints.

- **Endpoint**: `POST /device-token`
- **Request Body**: `DeviceTokenRequest`
  ```json
  {
    "moduleId": "string",
    "deviceId": "string",
    "message": "string (random string/nonce)",
    "signature": "string (signed message with private key)"
  }
  ```
- **Response**:
  ```json
  {
    "token": "jwt-token-string"
  }
  ```

## 3. Device Status & Heartbeat
Updates device status/IP and retrieves module status and pending commands.

- **Endpoint**: `POST /status`
- **Request Body**: `DeviceSignedRequest<UpdateDeviceInput>`
  ```json
  {
    "deviceId": "string",
    "signature": "string",
    "data": {
      "appVersion": "string",
      "activationStatus": "enum (ACTIVE/INACTIVE)",
      "supportMultiUsers": boolean,
      "lastAction": "string"
    }
  }
  ```
- **Response**: `DeviceApiResponse<Void>` (Data is null, but status and commands are populated)

## 4. Update Public Key
Rotates the device/module public key.

- **Endpoint**: `POST /update-public-key`
- **Request Body**: `DeviceSignedRequest<UpdatePublicKeyPayload>`
  ```json
  {
    "deviceId": "string",
    "signature": "string (signed by NEW private key)",
    "data": {
      "newPublicKey": "string"
    }
  }
  ```
- **Response**: `DeviceApiResponse<Void>`

## 5. Acknowledge Command
Acknowledges that a server command has been processed by the device.

- **Endpoint**: `POST /acknowledge-command`
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

## 6. Recycle Module Code
Generates a new registration code (Only for multi-device modules).

- **Endpoint**: `POST /recycle-code`
- **Request Body**: `DeviceSignedRequest<Void>`
  ```json
  {
    "deviceId": "string",
    "signature": "string",
    "data": null
  }
  ```
- **Response**: `DeviceApiResponse<String>` (Data contains new code)
## Schemas & Objects

### DeviceApiResponse<T>
Standard wrapper for most device-related responses.
- `data`: T - The primary response data.
- `module`: `ModuleResponse` - Relevant module information.
- `status`: `DeviceStatusDTO` - Current device status and sync requirements.
- `commands`: `List<DeviceCommandDTO>` - List of pending commands for the device.

### DeviceDTO
- `id`: Long
- `deviceId`: String (UUID)
- `deviceName`: String
- `appVersion`: String
- `latitude`: Double
- `longitude`: Double
- `lastAction`: String
- `deviceType`: String (Enum: POS, MOBILE, etc.)
- `activationStatus`: String (Enum: ACTIVE, INACTIVE)
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
- `activationStatus`: String (Enum)
- `serviceType`: String (Enum)
- `subType`: String (Enum)
- `expirationDate`: DateTime

### DeviceStatusDTO
- `isActive`: Boolean
- `isSyncRequired`: Boolean
- `supportMultiUsers`: Boolean
- `message`: String

### DeviceCommandDTO
- `id`: Long
- `type`: String (Enum)
- `status`: String (Enum)
- `createdAt`: DateTime
- `deliveredAt`: DateTime
- `acknowledgedAt`: DateTime
