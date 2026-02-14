# Service Layer - Stock and Sales Management

## Overview

The service layer provides business logic and data conversion between external interfaces and the database layer. It handles validation, complex operations, and ensures data integrity.

## Architecture

```
External Interface (UI/API)
         ↓
    DTOs (Data Transfer Objects)
         ↓
    Service Layer (Business Logic)
         ↓
    Database Layer (CRUD Operations)
```

## Services

### ProductService

Manages the product catalog with enriched data (linked insurances).

**Features:**
- Search products by name (efficient database search)
- Get enriched product details including all linked insurance data
- Create and update products
- Soft delete support

**Usage:**
```dart
final productService = ProductService(database);

// Search products
final products = await productService.searchByName('Para');

// Get enriched product including insurance splits
final product = await productService.getProductById(productId);
for (var link in product.insurances) {
  print('Insurance: ${link.insurance.name}, Cost: ${link.cost}');
}
```

### InsuranceService

Manages insurance entities.

**Features:**
- Search insurances by name
- CRUD operations
- Soft delete support

**Usage:**
```dart
final insuranceService = InsuranceService(database);

// Search insurances
final insurances = await insuranceService.searchByName('RAMA');

// Create insurance
await insuranceService.createInsurance(InsuranceCreateDTO(
  name: 'MMI',
  acronym: 'MMI',
  clientPercentage: 15.0,
));
```

### StockService

Manages inventory with business logic for stock tracking and alerts.

**Features:**
- Create and update stock entries
- Track stock by product, location, batch
- Low stock alerts (below reorder level)
- Expiry date tracking
- Automatic product validation

**Usage:**
```dart
final stockService = StockService(database);

// Create stock
final stockDTO = await stockService.createStock(StockCreateDTO(
  productId: productId,
  quantity: 100,
  location: 'Warehouse A',
  pricePerUnit: 2500.0,
  batchNumber: 'BATCH-001',
  expiryDate: DateTime(2025, 12, 31),
  reorderLevel: 20,
));

// Get low stock items
final lowStock = await stockService.getLowStockItems();

// Get expiring items (within 30 days)
final expiring = await stockService.getExpiringItems(30);
```

### SaleService

Processes sales with automatic stock reduction and insurance calculations.

**Features:**
- Create sales with validation
- Automatic stock quantity reduction
- Insurance coverage calculation
- Business rule validation (insurance requirements)
- Sales reporting and queries

**Usage:**
```dart
final saleService = SaleService(database);

// Private sale (no insurance)
final privateSale = await saleService.createSale(SaleCreateDTO(
  patientName: 'John Doe',
  items: [
    SaleItemCreateDTO(
      stockId: stockId,
      quantitySold: 2,
      pricePerUnit: 2500.0,
    ),
  ],
));

// Insurance sale
final insuranceSale = await saleService.createSale(SaleCreateDTO(
  patientName: 'Jane Smith',
  insuranceCardNumber: 'INS-12345',
  issuingCompany: 'RSSB',
  prescriberName: 'Dr. Smith',
  prescriberLicenseId: 'LIC-98765',
  prescribingOrganization: 'City Hospital',
  items: [
    SaleItemCreateDTO(
      stockId: stockId,
      quantitySold: 3,
      pricePerUnit: 2500.0,
      insuranceId: insuranceId,
    ),
  ],
));
```

## DTOs (Data Transfer Objects)

### Stock DTOs

- **StockCreateDTO** - Input for creating/updating stock
- **StockDTO** - Output with product details

### Sale DTOs

- **SaleCreateDTO** - Input for creating sales
- **SaleItemCreateDTO** - Input for individual items
- **SaleDTO** - Output with complete sale details
- **SaleItemDTO** - Output with enriched item data

## Business Logic

### Insurance Calculation

When a sale item includes insurance:
1. Verify product is covered by the insurance
2. Get insurance client percentage
3. Calculate split:
   - Insurance pays: `(100 - clientPercentage)% of total`
   - Patient pays: `clientPercentage% of total`

**Example:**
- Item total: 7500.0
- Client percentage: 10%
- Insurance pays: 6750.0 (90%)
- Patient pays: 750.0 (10%)

### Stock Validation

Before creating a sale:
1. Verify all stock items exist
2. Check sufficient quantity available
3. Throw `InsufficientStockException` if not enough stock

### Automatic Stock Reduction

When a sale is created:
- Stock quantities are automatically reduced
- Happens atomically with sale creation
- Ensures inventory accuracy

## Exception Handling

### ResourceNotFoundException
Thrown when entity not found (Product, Stock, Insurance, Sale)

### InsufficientStockException
Thrown when stock quantity insufficient for sale

### ValidationException
Thrown when business rules violated (e.g., insurance requirements)

## Example

See `lib/services/service_example.dart` for complete examples including:
- Creating stock
- Private sales
- Insurance sales
- Low stock queries
- Expiring items
- Error handling

Run with:
```bash
dart lib/services/service_example.dart
```

## Integration

```dart
// Initialize
final database = AppDatabase();
final stockService = StockService(database);
final saleService = SaleService(database);

// Use services
final stock = await stockService.createStock(createDTO);
final sale = await saleService.createSale(saleDTO);
```

## Benefits

✅ **Separation of Concerns** - Business logic separate from database  
✅ **Validation** - Input validation before database operations  
✅ **Type Safety** - DTOs provide clear contracts  
✅ **Error Handling** - Custom exceptions for better error messages  
✅ **Testability** - Services can be tested independently  
✅ **Maintainability** - Changes to business logic isolated in services
