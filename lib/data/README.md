# NexxPharma - Drift Database Layer

## Overview

This is a comprehensive Drift database layer for the NexxPharma medical catalog system. It provides a local SQLite database with full CRUD operations for managing medical products, insurance, stock, and sales.

## Database Schema

### Tables

1. **Insurances** - Insurance providers and their coverage details
2. **Products** - Medical products (drugs and consumable devices)
3. **ProductInsurances** - Junction table linking products to insurances with pricing
4. **Stocks** - Inventory management for products
5. **Sales** - Sales transactions
6. **SaleItems** - Individual items within a sale

### Enums

- `ItemType`: DRUG, CONSUMABLE_DEVICE
- `Unit`: Various units (AMPOULE, BOTTLE, BOX, TABLET, etc.)
- `AuthorisedLevel`: All, HOSPITAL_USE_DRUG
- `MustPrescribedBy`: Various prescriber types

## Features

### Insurance Management
- Create, read, update, and delete insurance providers
- Soft delete support with `deletedAt` field
- Track client percentage for each insurance

### Product Management
- Manage drugs and consumable devices
- Search products by name
- Soft delete support
- Track product metadata (selling unit, description)

### Product-Insurance Linking
- Link products to multiple insurances
- Define insurance-specific pricing and authorization levels
- Track utilization counts and prescriber requirements

### Stock Management
- Track inventory levels for each product
- Batch number and expiry date tracking
- Reorder level alerts
- Automatic stock adjustment on sales
- Location-based inventory

### Sales Management
- Record sales transactions with patient information
- Support for insurance and private sales
- Track prescriber information
- Date range queries and sales reports

### Sale Items
- Individual line items for each sale
- Automatic stock quantity adjustment
- Split pricing between patient and insurance
- Track insurance coverage per item

## Installation

1. Add dependencies to `pubspec.yaml`:
```yaml
dependencies:
  drift: ^2.23.0
  drift_flutter: ^0.2.0
  uuid: ^4.5.1

dev_dependencies:
  drift_dev: ^2.23.0
  build_runner: ^2.4.13
```

2. Run code generation:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Usage

### Initialize Database

```dart
import 'package:nexxpharma/data/database.dart';

final database = AppDatabase();
```

### Insurance Operations

```dart
// Create insurance
final insurance = await database.createInsurance(
  name: 'Rwanda Social Security Board',
  acronym: 'RSSB',
  clientPercentage: 10.0,
);

// Get all insurances
final insurances = await database.getAllInsurances();

// Update insurance
await database.updateInsurance(
  id: insurance.id,
  clientPercentage: 12.5,
);

// Soft delete
await database.deleteInsurance(insurance.id);
```

### Product Operations

```dart
// Create product
final product = await database.createProduct(
  name: 'Paracetamol 500mg',
  type: ItemType.DRUG,
  description: 'Pain relief and fever reducer',
  sellingUnit: 'Box of 20 tablets',
);

// Search products
final results = await database.searchProductsByName('Paracetamol');

// Update product
await database.updateProduct(
  id: product.id,
  description: 'Updated description',
);
```

### Link Product to Insurance

```dart
final link = await database.linkProductInsurance(
  productId: product.id,
  insuranceId: insurance.id,
  code: 'PARA-500-RSSB',
  unit: Unit.BOX,
  cost: 2500.0,
  authorisedLevel: AuthorisedLevel.All,
  mustPrescribedBy: MustPrescribedBy.All,
  utilizationCount: 1,
);
```

### Import Data from Server

The database supports importing complete data from the server, including IDs and timestamps. This is useful for data synchronization.

```dart
// Import single insurance with server-provided ID and timestamps
final insurance = await database.importInsurance(
  id: "987fcdeb-51a2-43c1-x999-543210987000",
  name: "RSSB RAMA",
  acronym: "RAMA",
  clientPercentage: 15.0,
  createdAt: DateTime.parse("2026-01-01T09:00:00"),
  updatedAt: DateTime.parse("2026-01-01T09:00:00"),
  version: 1,
);

// Import product with metadata
final product = await database.importProduct(
  id: "123e4567-e89b-12d3-a456-426614174000",
  name: "Paracetamol 500mg",
  type: ItemType.DRUG,
  description: "Pain reliever",
  sellingUnit: "PACK",
  createdAt: DateTime.parse("2026-01-01T10:00:00"),
  updatedAt: DateTime.parse("2026-01-28T10:00:00"),
  version: 1,
);

// Import product-insurance link
final link = await database.importProductInsurance(
  id: "55555555-4444-3333-2222-111111111111",
  productId: "123e4567-e89b-12d3-a456-426614174000",
  insuranceId: "987fcdeb-51a2-43c1-x999-543210987000",
  code: "PARA-001",
  unit: Unit.TABLET,
  cost: 100.0,
  authorisedLevel: AuthorisedLevel.All,
  mustPrescribedBy: MustPrescribedBy.All,
  utilizationCount: 1,
  createdAt: DateTime.parse("2026-01-15T10:00:00"),
  updatedAt: DateTime.parse("2026-01-15T10:00:00"),
  version: 1,
);

// Batch import from JSON
final insuranceListJson = [
  {
    "id": "111-222-333",
    "name": "MMI",
    "acronym": "MMI",
    "clientPercentage": 20.0,
    "createdAt": "2026-01-02T09:00:00",
    "updatedAt": "2026-01-02T09:00:00",
    "version": 1
  },
  // ... more insurances
];

await database.importInsurances(insuranceListJson);
```

**Import vs Create:**
- **Create methods** (`createInsurance`, `createProduct`, etc.) - Generate new UUIDs and timestamps automatically for local data
- **Import methods** (`importInsurance`, `importProduct`, etc.) - Use server-provided IDs and timestamps for synchronization
- Import methods use `insertOnConflictUpdate` to handle both insert and update (upsert)

### Stock Management

```dart
// Create stock entry
final stock = await database.createStock(
  productId: product.id,
  quantity: 100,
  location: 'Warehouse A',
  pricePerUnit: 150.0,
  batchNumber: 'BATCH-2024-001',
  expiryDate: DateTime(2025, 12, 31),
  reorderLevel: 20,
);

// Get stocks below reorder level
final lowStocks = await database.getStocksBelowReorderLevel();

// Adjust stock quantity
await database.adjustStockQuantity(stock.id, -10); // Subtract 10
```

### Sales Operations

```dart
// Create sale
final sale = await database.createSale(
  patientName: 'John Doe',
  totalPrice: 5000.0,
  insuranceCardNumber: 'INS-12345',
  issuingCompany: 'RSSB',
  prescriberName: 'Dr. Smith',
);

// Create sale item (automatically adjusts stock)
final saleItem = await database.createSaleItem(
  saleId: sale.id,
  stockId: stock.id,
  quantitySold: 2,
  pricePerUnit: 2500.0,
  itemTotal: 5000.0,
  patientPays: 500.0,
  insurancePays: 4500.0,
  insuranceId: insurance.id,
);

// Get complete sale with items
final saleWithItems = await database.getSaleWithItems(sale.id);

// Generate sales report
final report = await database.getSalesReport(
  DateTime(2024, 1, 1),
  DateTime(2024, 12, 31),
);
print('Total Sales: ${report['totalSales']}');
print('Total Revenue: ${report['totalRevenue']}');
```

### Advanced Queries

```dart
// Get product with all its insurances
final productWithIns = await database.getProductWithInsurances(product.id);

// Get insurance with all its products
final insuranceWithProds = await database.getInsuranceWithProducts(insurance.id);

// Get stocks for a specific product
final productStocks = await database.getStocksByProduct(product.id);

// Search sales by patient
final patientSales = await database.searchSalesByPatient('John');

// Get sales within date range
final salesInRange = await database.getSalesByDateRange(
  DateTime(2024, 1, 1),
  DateTime(2024, 12, 31),
);
```

## Database Structure

### Relationships

```
Products ──┬── ProductInsurances ── Insurances
           │
           └── Stocks ── SaleItems ── Sales
```

### Soft Delete Support

The following tables support soft deletes (using `deletedAt` field):
- Insurances
- Products
- ProductInsurances

Soft-deleted records are automatically excluded from standard queries.

### Automatic Features

1. **UUID Generation**: All IDs are automatically generated as UUIDs
2. **Timestamps**: `createdAt` and `updatedAt` are automatically managed
3. **Stock Adjustment**: Creating a sale item automatically reduces stock quantity
4. **Versioning**: Optimistic locking support with `version` field

## API Reference

### Insurance CRUD
- `createInsurance()` - Create new insurance
- `getInsuranceById()` - Get by ID
- `getAllInsurances()` - Get all (excluding deleted)
- `updateInsurance()` - Update insurance
- `deleteInsurance()` - Soft delete
- `hardDeleteInsurance()` - Permanent delete

### Product CRUD
- `createProduct()` - Create new product
- `getProductById()` - Get by ID
- `getAllProducts()` - Get all (excluding deleted)
- `searchProductsByName()` - Search by name
- `updateProduct()` - Update product
- `deleteProduct()` - Soft delete
- `hardDeleteProduct()` - Permanent delete

### ProductInsurance CRUD
- `linkProductInsurance()` - Link product to insurance
- `getProductInsuranceById()` - Get by ID
- `getAllProductInsurances()` - Get all links
- `getInsurancesForProduct()` - Get insurances for a product
- `getProductsForInsurance()` - Get products for an insurance
- `updateProductInsurance()` - Update link
- `deleteProductInsurance()` - Soft delete
- `unlinkProductInsurance()` - Unlink (soft delete)

### Stock CRUD
- `createStock()` - Create stock entry
- `getStockById()` - Get by ID
- `getAllStocks()` - Get all stocks
- `getStocksByProduct()` - Get stocks for a product
- `getStocksBelowReorderLevel()` - Get low stock items
- `updateStock()` - Update stock
- `deleteStock()` - Delete stock
- `adjustStockQuantity()` - Add/subtract quantity

### Sale CRUD
- `createSale()` - Create new sale
- `getSaleById()` - Get by ID
- `getAllSales()` - Get all sales
- `searchSalesByPatient()` - Search by patient name
- `getSalesByDateRange()` - Get sales in date range
- `updateSale()` - Update sale
- `deleteSale()` - Delete sale

### SaleItem CRUD
- `createSaleItem()` - Create sale item (auto-adjusts stock)
- `getSaleItemById()` - Get by ID
- `getAllSaleItems()` - Get all items
- `getSaleItemsBySale()` - Get items for a sale
- `getSaleItemsByStock()` - Get items for a stock
- `updateSaleItem()` - Update item
- `deleteSaleItem()` - Delete item

### Advanced Queries
- `getProductWithInsurances()` - Product with all insurances
- `getInsuranceWithProducts()` - Insurance with all products
- `getSaleWithItems()` - Sale with all items
- `getSalesReport()` - Sales report with totals

## Notes

- All monetary values are stored as `double` (REAL in SQLite)
- UUIDs are stored as TEXT
- Dates are stored as DateTime
- The database uses SQLite via drift_flutter
- Schema version is currently 1

## License

This database layer is part of the NexxPharma medical catalog system.
