# NexxPharma

NexxPharma is a Flutter-based pharmacy operations app focused on inventory, sales/stock-out workflows, invoice generation, and secure device-based synchronization.

## Project Focus

- Manage pharmacy catalog and stock with local-first storage.
- Process stock-out/sales for retail, wholesale, and clinic inventory modes.
- Generate printable invoices/receipts (A4, 80mm, 57mm).
- Synchronize data with backend APIs using signed device requests.
- Support module/device activation and multi-user operations.

## Core Capabilities

- **Authentication & User Management**
	- Login/session management
	- User profile and user administration flows

- **Inventory & Sales**
	- Product and insurance-aware stock operations
	- Stock in / stock out with business validations
	- Retail, wholesale, and clinic-specific behaviors

- **Invoicing & Printing**
	- PDF invoice generation on demand for preview/print
	- Receipt and A4 layouts
	- Insurance split handling (where applicable)

- **Device Lifecycle & Sync**
	- Device/module activation flow
	- Signed sync/status communication
	- Background sync and connectivity-aware behavior

- **Desktop/Multi-platform Utilities**
	- Single-instance app lock on desktop targets
	- Windows auto-update integration

## Tech Stack

- **Framework:** Flutter (Dart SDK `^3.10.8`)
- **Local DB:** Drift (SQLite)
- **Networking:** `http`
- **PDF/Printing:** `pdf`, `printing`
- **Crypto/Signatures:** `crypton`, `bcrypt`
- **Storage/Prefs:** `shared_preferences`, `flutter_secure_storage`
- **Location/System:** `geolocator`, `package_info_plus`

## Project Structure

- `lib/main.dart` — app bootstrap, service wiring, theme setup, app lifecycle setup
- `lib/data/` — Drift database schema and data-access layer
- `lib/services/` — business logic (auth, stock, sync, activation, invoice, settings, etc.)
- `lib/ui/` — screens, widgets, and UI flows
- `updater/` — update scripts/utilities
- Platform folders: `android/`, `ios/`, `linux/`, `macos/`, `windows/`, `web/`

## Getting Started

### Prerequisites

- Flutter SDK installed and available in PATH
- Dart SDK (bundled with Flutter)
- Platform toolchain for your target (Android Studio/Xcode/desktop toolchains)

### Install Dependencies

```bash
flutter pub get
```

### Generate Drift Files (if schema changed)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Run the App

```bash
flutter run
```

## Development Notes

- Invoices are generated on demand (preview/print), not at sale creation time.
- Stock-out creation writes transactional records and adjusts inventory quantities.
- Sync/device APIs are documented in internal project docs and service implementations.
- If startup-level behavior changes (for example logging filters), use full restart instead of hot reload.

## Useful Commands

```bash
# Analyze
flutter analyze

# Run tests
flutter test

# Clean build artifacts
flutter clean
```

## Additional Internal Docs

- `lib/data/README.md` — database schema and CRUD layer details
- `lib/services/README.md` — service-layer architecture and business logic patterns

## License

Private/internal project. Add or update licensing terms as needed by your organization.
