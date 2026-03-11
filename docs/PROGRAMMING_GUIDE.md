# NexxStore Programming Guide

## Overview

This document provides an overview of the NexxStore architecture, development structure, and guidance for developers contributing to or extending the application.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Tech Stack](#tech-stack)
3. [Project Structure](#project-structure)
4. [Development Setup](#development-setup)
5. [Key Concepts](#key-concepts)
6. [Contributing Guidelines](#contributing-guidelines)
7. [Build Process](#build-process)
8. [Deployment](#deployment)

## Architecture Overview

### Application Layers

NexxStore follows a layered architecture with clear separation of concerns:

```
┌─────────────────────────────────┐
│     Presentation Layer (UI)     │
│  - Screens, Widgets, Navigation │
└─────────────────────────────────┘
              ↓
┌─────────────────────────────────┐
│    Business Logic Layer         │
│  - Services, State Management   │
└─────────────────────────────────┘
              ↓
┌─────────────────────────────────┐
│    Data Access Layer            │
│   - Database, APIs, Caching     │
└─────────────────────────────────┘
```

### Design Patterns Used

- **Layered Architecture:** Separation of UI, business logic, and data access
- **Repository Pattern:** Abstraction layer for data sources
- **Service Locator/Dependency Injection:** Using GetIt for service management
- **State Management:** Provider patterns for reactive UI updates
- **Singleton Pattern:** Services initialized once and reused

## Tech Stack

### Core Framework
- **Framework:** Flutter (Dart SDK ^3.10.8)
- **Language:** Dart
- **Target Platforms:** Android, iOS, Windows, macOS, Linux, Web

### Database
- **Local Storage:** Drift (SQLite wrapper)
- **Database:** SQLite
- **Migrations:** Drift-managed schema versioning

### Networking
- **HTTP Client:** `http` package
- **API Communication:** RESTful JSON APIs
- **Signing:** Cryptographic request signing

### Security
- **Encryption:** `crypton` package for RSA/cryptographic operations
- **Hashing:** `bcrypt` for password hashing
- **Secure Storage:** `flutter_secure_storage` for sensitive tokens

### UI/UX
- **State Management:** Provider
- **Navigation:** Go Router
- **PDF Generation:** `pdf` and `printing` packages

### Device/System Integration
- **Location Services:** `geolocator`
- **Device Info:** `package_info_plus`
- **Preferences:** `shared_preferences`
- **Geolocation:** Device location services

### Utilities
- **UUID Generation:** `uuid` for unique identifiers
- **Internationalization:** `intl` for date/number formatting
- **Path Handling:** `path` package

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── data/
│   ├── database.dart         # Drift database setup
│   ├── tables/               # Database table definitions
│   ├── daos/                 # Data Access Objects
│   └── models/               # Data models
├── services/
│   ├── auth_service.dart     # Authentication logic
│   ├── stock_service.dart    # Inventory operations
│   ├── sales_service.dart    # Transaction processing
│   ├── sync_service.dart     # Backend synchronization
│   ├── invoice_service.dart  # Invoice generation
│   ├── activation_service.dart # Device activation
│   └── settings_service.dart # Configuration management
├── ui/
│   ├── screens/              # Full-page screens
│   ├── widgets/              # Reusable UI components
│   ├── theme/                # Theme & styling
│   └── navigation/           # Navigation configuration
└── utils/
    ├── constants.dart        # App-wide constants
    ├── validators.dart       # Input validation
    └── helpers.dart          # Utility functions
```

## Development Setup

### Prerequisites

Ensure you have installed:
- Flutter SDK (latest stable version)
- Dart SDK (bundled with Flutter)
- Git
- Android Studio or Xcode (for simulation/deployment)

### Step 1: Clone Repository

```bash
git clone https://github.com/Genocadio/PharmacyApp.git
cd PharmacyApp
```

### Step 2: Get Dependencies

```bash
flutter pub get
```

### Step 3: Generate Database Files

Drift requires code generation:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 4: Run the Application

```bash
# Run on default device/emulator
flutter run

# Run on specific device
flutter run -d <device_id>

# Run in debug mode (default)
flutter run -d <device_id>

# Run in profile mode (optimized but debuggable)
flutter run -d <device_id> --profile

# Run in release mode (optimized, no debugging)
flutter run -d <device_id> --release
```

## Key Concepts

### Authentication System

NexxStore uses secure credentials storage:

```dart
// Example: Login flow
final authService = serviceLocator<AuthService>();
final result = await authService.login(username, password);
if (result.success) {
  // User logged in, token stored securely
  // Subsequent requests include authentication
}
```

### Database Access (Drift)

Database queries use Drift's type-safe approach:

```dart
// Example: Fetching products
final database = serviceLocator<AppDatabase>();
final products = await database.productDao.getAllProducts();
```

### Stock Management

Three inventory modes are supported:

1. **Retail:** Individual customer sales
2. **Wholesale:** Bulk orders
3. **Clinic:** Internal facility consumption

```dart
// Example: Processing a stock-out (sale)
final stockService = serviceLocator<StockService>();
await stockService.processSaleTransaction(
  items: [
    SaleItem(productId: 1, quantity: 10, price: 100.0),
  ],
  mode: InventoryMode.retail,
);
```

### Invoice Generation

Invoices are generated on-demand from transactions:

```dart
// Example: Generate invoice
final invoiceService = serviceLocator<InvoiceService>();
final pdf = await invoiceService.generateInvoice(
  transactionId: 123,
  format: InvoiceFormat.a4,
);
```

### Device Synchronization

Scheduled sync communicates with backend using signed requests:

```dart
// Example: Manual sync trigger
final syncService = serviceLocator<SyncService>();
await syncService.synchronize();
// Handles conflicts, retries, and state updates automatically
```

### Device Activation and Unique Identification

**Core Principle:** Every NexxStore installation operates as a unique, independently activated device with immutable sales records and comprehensive audit trails.

#### Device Identity

Each app installation receives a unique device ID that serves as the permanent identifier for that installation:

```dart
// Example: Getting device information
final deviceInfoService = serviceLocator<DeviceInfoService>();
final deviceId = await deviceInfoService.getUniqueDeviceId();
// Returns: A unique identifier assigned at first app launch
// Format: UUID v4 stored in device_info table
```

**Key characteristics:**
- Generated on first app launch (never changes for that installation)
- Persisted in the `device_info` table in the local database
- Used in all backend synchronization requests
- Sent with every API call to identify the source device
- Enables backend to track which device originated each transaction

#### Activation Requirement

Devices must be activated before any backend operations are allowed:

```dart
// Example: Device activation flow
final activationService = serviceLocator<ActivationService>();

// User requests activation code from administrator
// Code format: Unique alphanumeric code tied to device/license

await activationService.activateDevice(
  activationCode: 'ABC123XYZ789',
  userEmail: 'staff@pharmacy.com',
);

// After activation:
// - Device flags set to is_activated = true
// - API server registered
// - Sync service can begin
```

**Activation Requirements:**
- One activation code per device
- Code validated against backend license database
- Maps device to specific pharmacy location/license
- Cannot be transferred between installations
- Prevents unauthorized app distribution

**This ensures:**
- Controlled app distribution and licensing
- Backend knows exactly which physical location each device represents
- Prevents unauthorized copies from accessing production data
- Each device is accountable for its transactions

### Session Monitoring and Sales Tracking

#### User Session Tracking

All user activity is monitored at the device and user level:

```dart
// Session information tracked per user
users
├── id: integer
├── username: text
├── email: text
├── role: text (admin, staff, viewer)
└── is_active: boolean

// Activity logged in audit logs
audit_logs
├── user_id: integer          // Which user?
├── action: text              // What action (login, sale, adjustment)?
├── entity_type: text         // What entity (product, sale)?
├── entity_id: integer        // Specific record ID?
├── device_id: text           // Which device?
├── ip_address: text          // Network source
├── created_at: datetime      // When?
└── details: text (JSON)      // Additional context
```

#### Sales Source Identification

Every sale transaction explicitly records its source:

```dart
sale_transactions
├── id: integer
├── transaction_number: text (UNIQUE)
├── user_id: integer (FOREIGN KEY → users)         // Who made the sale?
├── device_id: text                                 // Which device?
├── transaction_date: datetime                      // When?
├── mode: text (retail, wholesale, clinic)         // Type of transaction
├── sync_status: text (pending, synced, failed)    // Server sync status
└── synced_at: datetime                             // When confirmed on server?
```

**Example: Tracing a transaction**
```dart
// For any sale, you can determine:
// 1. User who created it (user_id)
// 2. Which device/installation (device_id)
// 3. When it was created (transaction_date)
// 4. Its sync status with backend (sync_status)
// 5. When backend confirmed it (synced_at)
```

#### Active Sessions Monitoring

User login/logout is tracked to monitor active sessions:

```dart
// Each login creates an audit entry
audit_logs {
  user_id: 5,
  action: 'login',
  device_id: 'device-abc-123',
  created_at: 2026-03-09 09:15:00,
  details: { session_id: 'sess-xyz-789', ip_address: '192.168.1.100' }
}

// Access control per user role
if (user.role == 'admin') {
  // Full access to all inventory
} else if (user.role == 'staff') {
  // Can perform sales, limited adjustments
} else if (user.role == 'viewer') {
  // Read-only access to reports
}
```

**Session guarantees:**
- Only one active user per device at a time
- All operations tied to specific user
- Logout triggers session termination
- Backend can invalidate sessions remotely if needed

### Immutable Sales Records

#### Why Sales are Immutable

Sales transactions represent critical financial and inventory records that must never change after creation. This is enforced at multiple levels:

1. **Database Level:** Sales records cannot be deleted or modified after creation
2. **Business Logic Level:** API prevents updates to completed sales
3. **Audit Level:** Any correction creates a new adjustment record, not a modification
4. **Compliance Level:** Immutability supports pharmacy regulations and financial audits

#### Sales Data Structure

```dart
sale_transactions
├── id: integer (PRIMARY KEY)
├── transaction_number: text (UNIQUE, IMMUTABLE)
├── transaction_date: datetime (IMMUTABLE)
├── mode: text (IMMUTABLE)
├── user_id: integer (IMMUTABLE)
├── device_id: text (IMMUTABLE)
├── total_amount: real (IMMUTABLE)
├── sync_status: text (allowed to change: pending → synced)
└── created_at: datetime (IMMUTABLE)

sale_items
├── id: integer (PRIMARY KEY)
├── sale_transaction_id: integer (FOREIGN KEY)
├── product_id: integer (IMMUTABLE)
├── quantity: integer (IMMUTABLE)
├── unit_price: real (IMMUTABLE)
└── line_total: real (IMMUTABLE)
```

#### Correcting Sales Errors

Errors are corrected through adjustments, not deletion:

```dart
// WRONG: Attempting to modify/delete a sale
await saleTransactionDao.deleteTransaction(transactionId);
// ❌ This is prevented by business logic and database constraints

// CORRECT: Create adjustment transaction
await stockAdjustmentService.createAdjustment(
  originalSaleId: saleTransactionId,
  reason: 'Price correction - customer refund',
  adjustmentItems: [
    AdjustmentItem(
      productId: 1,
      originalQuantity: 10,
      correctedQuantity: 8,  // Only 8 should have been sold
      refundAmount: 50.0,
    ),
  ],
);

// Result:
// - Original sale_transaction remains unchanged
// - Adjustment transaction created with negative quantity
// - Stock levels corrected
// - Both records visible in audit trail
// - Full traceability maintained
```

#### Audit Trail for All Sales

Every sale is immutably recorded and traceable:

```dart
// Complete sales history includes:
1. Original transaction record (immutable)
2. Device and user who created it (immutable)
3. Timestamp of creation (immutable)
4. All line items with prices (immutable)
5. Backend sync confirmation (immutable once synced)
6. Any adjustments made after the fact (separate records)

// This supports:
- Financial audits
- Inventory reconciliation
- User accountability
- Regulatory compliance
- Dispute resolution
- Loss investigation
```

#### Backend Sync and Immutability

Once a sale is synced to the backend, it becomes permanently immutable:

```dart
sale_transactions {
  id: 123,
  sync_status: 'synced',           // ← Status changed after first sync
  synced_at: 2026-03-09 14:30:00,  // ← Timestamp when confirmed on server
  
  // After this point: Database prevents any modification
  // Backend also prevents updates to synced transactions
}
```

**Sync guarantees:**
- Offline sales stored locally
- Once synced, marked with sync timestamp
- Backend performs final validation
- Backend prevents updates to confirmed sales
- Device cannot modify after backend confirmation

## Contributing Guidelines

### Code Style

- Follow Dart style guide: [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use meaningful variable/function names
- Keep functions focused and small (< 50 lines ideal)
- Add documentation comments to public APIs

### Naming Conventions

- Classes: `PascalCase` (e.g., `AuthService`, `ProductDao`)
- Methods/variables: `camelCase` (e.g., `getUserById`, `isActive`)
- Constants: `camelCase` (e.g., `defaultTimeout`, `maxRetries`)
- Files: `snake_case` (e.g., `auth_service.dart`, `product_model.dart`)

### Comments and Documentation

```dart
/// Processes a sale transaction in the specified inventory mode.
///
/// [items] - List of items being sold
/// [mode] - Inventory mode (retail, wholesale, clinic)
/// [customerId] - Optional customer ID for loyalty tracking
///
/// Returns a [SaleTransaction] with generated invoice.
/// Throws [InsufficientStockException] if stock unavailable.
Future<SaleTransaction> processSale({
  required List<SaleItem> items,
  required InventoryMode mode,
  String? customerId,
}) async {
  // Implementation
}
```

### Testing

Write tests for critical business logic:

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/services/auth_service_test.dart
```

### Pull Request Process

1. Create feature branch: `git checkout -b feature/my-feature`
2. Make changes with meaningful commits
3. Add tests for new functionality
4. Run `flutter analyze` and fix warnings
5. Run `flutter test` to ensure all tests pass
6. Submit PR with clear description of changes

## Build Process

### Development Build

```bash
# Debug build (fastest, largest)
flutter build apk --debug
flutter build appbundle --debug
flutter build windows --debug
```

### Release Build

```bash
# Android (APK)
flutter build apk --release

# Android (App Bundle - Google Play)
flutter build appbundle --release

# Windows (EXE)
flutter build windows --release

# Web
flutter build web --release --dart2js-optimization O4
```

### Analysis and Validation

```bash
# Run analyzer
flutter analyze

# Format code
dart format lib/

# Get dependency information
flutter pub deps

# Check for outdated packages
flutter pub outdated
```

## Deployment

### Android Release

See [ANDROID_RELEASE_GUIDE.md](ANDROID_RELEASE_GUIDE.md) for detailed instructions.

Key steps:
1. Update version in `pubspec.yaml`
2. Generate signed APK: `flutter build apk --release --split-per-abi`
3. Create app bundle for Play Store: `flutter build appbundle --release`
4. Sign with release keystore
5. Upload to Google Play or distribute directly

### Windows Release

See [build-windows-installer.ps1](../build-windows-installer.ps1) script for production builds.

Key steps:
1. Build Windows release: `flutter build windows --release`
2. Run installer build script: `powershell .\build-windows-installer.ps1`
3. Signed installer generated in `release/windows/`
4. Test on clean installation

### Android Release

See [build-android-release.sh](../build-android-release.sh) script for production builds.

Key steps:
1. Setup keystore and signing credentials (one-time)
2. Run build script: `bash ./build-android-release.sh`
3. Generates signed APK and AAB in `release/android/`
4. See [ANDROID_RELEASE_GUIDE.md](../ANDROID_RELEASE_GUIDE.md) for signing setup

### Database Migrations

When schema changes are needed:

1. Modify tables in `lib/data/database.dart`
2. Increment database schema version
3. Run: `dart run build_runner build --delete-conflicting-outputs`
4. Test migration path: old → new schema
5. Document breaking changes if any

## Additional Resources

- **Repository:** [GitHub](https://github.com/Genocadio/PharmacyApp)
- **Build Scripts:**
  - [build-android-release.sh](../build-android-release.sh) - Android production builds
  - [build-windows-installer.ps1](../build-windows-installer.ps1) - Windows installer
- **Database Guide:** [DATABASE_ARCHITECTURE.md](DATABASE_ARCHITECTURE.md)
- **API Reference:** [API_INTEGRATION.md](API_INTEGRATION.md)
- **User Guide:** [USER_GUIDE.md](USER_GUIDE.md)
- **Flutter Documentation:** [flutter.dev](https://flutter.dev)
- **Dart Documentation:** [dart.dev](https://dart.dev)

---

**NexxStore Programming Guide v1.0** | Last Updated: March 2026
