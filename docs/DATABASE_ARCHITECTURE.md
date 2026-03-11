# NexxStore Database Architecture

## Overview

NexxStore uses **Drift** (modern SQLite wrapper for Dart/Flutter) as its local database layer. Drift provides type-safe database access, automatic migrations, and reactive queries.

## Database Technology

### Why Drift?

- **Type-Safe Queries:** Compile-time verified SQL queries
- **Automatic Schema Generation:** Tables defined in code
- **Reactive Streams:** Data updates trigger UI rebuild automatically
- **Code Generation:** No manual SQL writing
- **Cross-Platform:** Works on all Flutter platforms
- **Performance:** Optimized SQLite with query batching

### Database File

- **Location (Android):** `/data/data/com.genocadio.pharmacyapp/databases/`
- **Location (Windows):** `%APPDATA%\NexxStore\databases\`
- **Location (iOS):** Application Documents folder (sandboxed)
- **Filename:** `pharmacy.db` (SQLite database file)
- **Size:** Typically grows to 50-500 MB depending on transaction history

## Database Schema

### Core Tables

#### 1. Users
Stores user account information and credentials.

```
users
├── id: integer (PRIMARY KEY)
├── username: text (UNIQUE)
├── email: text
├── password_hash: text (bcrypt encrypted)
├── role: text (admin, staff, viewer)
├── is_active: boolean
├── created_at: datetime
└── updated_at: datetime
```

**Purpose:** User authentication and authorization

#### 2. Products
Pharmacy catalog with pricing and stock information.

```
products
├── id: integer (PRIMARY KEY)
├── sku: text (UNIQUE)
├── name: text
├── category: text
├── description: text
├── cost_price: real
├── selling_price: real
├── reorder_quantity: integer
├── minimum_stock: integer
├── current_stock: integer
├── batch_tracking_enabled: boolean
├── expiry_tracking_enabled: boolean
├── created_at: datetime
└── updated_at: datetime
```

**Purpose:** Product master data and current inventory levels

#### 3. Stock Movements
Audit trail for all inventory changes.

```
stock_movements
├── id: integer (PRIMARY KEY)
├── product_id: integer (FOREIGN KEY → products)
├── movement_type: text (in, out, adjustment)
├── quantity: integer
├── reference_id: integer (transaction/adjustment ID)
├── notes: text
├── created_by: integer (FOREIGN KEY → users)
├── created_at: datetime
└── location: text
```

**Purpose:** Track inventory changes for audit and reconciliation

#### 4. Sale Transactions
Records of sale events with line items and totals.

```
sale_transactions
├── id: integer (PRIMARY KEY)
├── transaction_number: text (UNIQUE)
├── transaction_date: datetime
├── mode: text (retail, wholesale, clinic)
├── subtotal: real
├── tax_amount: real
├── discount_amount: real
├── total_amount: real
├── payment_method: text
├── customer_id: integer (FOREIGN KEY → customers, nullable)
├── user_id: integer (FOREIGN KEY → users)
├── invoice_generated: boolean
├── invoice_format: text (a4, 80mm, 57mm, nullable)
├── sync_status: text (pending, synced, failed)
├── created_at: datetime
├── updated_at: datetime
└── synced_at: datetime (nullable)
```

**Purpose:** Main sales records for reporting and sync

#### 5. Sale Items
Line items within sale transactions.

```
sale_items
├── id: integer (PRIMARY KEY)
├── sale_transaction_id: integer (FOREIGN KEY → sale_transactions)
├── product_id: integer (FOREIGN KEY → products)
├── quantity: integer
├── unit_price: real
├── line_total: real (quantity × unit_price)
├── batch_number: text (nullable, if batch tracking enabled)
├── expiry_date: date (nullable, if expiry tracking enabled)
└── created_at: datetime
```

**Purpose:** Itemized details of sales for invoicing and inventory updates

#### 6. Customers
Customer information for loyalty and bulk orders.

```
customers
├── id: integer (PRIMARY KEY)
├── name: text
├── customer_type: text (retail, wholesale, clinic, insurance)
├── phone: text (nullable)
├── email: text (nullable)
├── address: text (nullable)
├── tax_id: text (nullable)
├── credit_limit: real (nullable, for wholesale)
├── loyalty_points: integer
├── is_active: boolean
├── created_at: datetime
└── updated_at: datetime
```

**Purpose:** Customer information for transactions and reporting

#### 7. Device Info
Device activation and identification data.

```
device_info
├── id: integer (PRIMARY KEY)
├── device_id: text (UNIQUE)
├── device_name: text
├── device_type: text (android, windows, ios, etc.)
├── os_version: text
├── app_version: text
├── is_activated: boolean
├── activation_code: text (nullable)
├── api_server: text
├── created_at: datetime
└── last_sync: datetime (nullable)
```

**Purpose:** Device identification and sync coordination

#### 8. Sync Queue
Pending transactions for cloud synchronization.

```
sync_queue
├── id: integer (PRIMARY KEY)
├── entity_type: text (sale, stock, user_action)
├── entity_id: integer
├── operation: text (create, update, delete)
├── payload: text (JSON)
├── retry_count: integer
├── last_retry_at: datetime (nullable)
├── is_synced: boolean
├── created_at: datetime
└── synced_at: datetime (nullable)
```

**Purpose:** Queue transactions for reliable backend sync

#### 9. Settings
Application configuration stored locally.

```
settings
├── id: integer (PRIMARY KEY)
├── user_id: integer (FOREIGN KEY → users, nullable)
├── key: text (UNIQUE)
├── value: text
└── updated_at: datetime
```

**Purpose:** Store user/app preferences (printer, sync interval, theme, etc.)

#### 10. Audit Log
Comprehensive audit trail for compliance.

```
audit_logs
├── id: integer (PRIMARY KEY)
├── user_id: integer (FOREIGN KEY → users)
├── action: text (login, sale, stock_adjustment, etc.)
├── entity_type: text (product, sale, user, etc.)
├── entity_id: integer (nullable)
├── old_values: text (JSON, nullable)
├── new_values: text (JSON, nullable)
├── ip_address: text (nullable)
├── device_id: text
├── created_at: datetime
└── details: text (nullable)
```

**Purpose:** Compliance and security auditing

## Data Relationships

```
┌──────────────────┐
│     Users        │
└────────┬─────────┘
         │ creates
         ↓
┌──────────────────────────────────────┐
│    Sale Transactions & Items         │
│  ├── sale_transactions               │
│  ├── sale_items (belongs to sales)   │
│  └── customers (optional reference)  │
└────────┬─────────────────────────────┘
         │ updates
         ↓
┌──────────────────────┐
│      Products        │  ← Master data
└──────────┬───────────┘
           │ tracked by
           ↓
┌──────────────────────┐
│ Stock Movements      │
├──────────────────────┤
│ - Inventory audit    │
│ - Movement history   │
└──────────────────────┘

┌──────────────────────┐
│    Device Info       │
├──────────────────────┤
│ - Activation status  │
│ - Sync coordination  │
└──────────────────────┘
        ↓
┌──────────────────────┐
│   Sync Queue         │
├──────────────────────┤
│ - Pending syncs      │
│ - Retry logic        │
└──────────────────────┘
```

## Key Indexes and Optimizations

### Indexes for Performance

```sql
-- User lookups
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);

-- Product searches
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_category ON products(category);

-- Transaction lookups
CREATE INDEX idx_sale_transactions_date ON sale_transactions(transaction_date);
CREATE INDEX idx_sale_transactions_status ON sale_transactions(sync_status);
CREATE INDEX idx_sale_items_transaction ON sale_items(sale_transaction_id);
CREATE INDEX idx_sale_items_product ON sale_items(product_id);

-- Stock movement tracking
CREATE INDEX idx_stock_movements_product ON stock_movements(product_id);
CREATE INDEX idx_stock_movements_date ON stock_movements(created_at);
CREATE INDEX idx_stock_movements_type ON stock_movements(movement_type);

-- Sync optimization
CREATE INDEX idx_sync_queue_synced ON sync_queue(is_synced);
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_date ON audit_logs(created_at);
```

## Data Access Patterns

### Using Drift DAOs (Data Access Objects)

Drift organizes database access through type-safe DAOs:

```dart
// Example: Product DAO
@DriftAccessor(tables: [Products])
class ProductDao extends DatabaseAccessor<AppDatabase> {
  ProductDao(AppDatabase db) : super(db);

  // Get all products
  Future<List<Product>> getAllProducts();

  // Search by category
  Future<List<Product>> getProductsByCategory(String category);

  // Get low stock items
  Future<List<Product>> getLowStockItems();
}
```

### Query Examples

```dart
// Get sale transactions for a date range
final dao = database.saleTransactionDao;
final sales = await dao.getTransactionsInRange(
  startDate: DateTime(2026, 3, 1),
  endDate: DateTime(2026, 3, 31),
);

// Get inventory movements for reconciliation
final movements = await database.stockMovementDao
  .getMovementsByProduct(productId)
  .get();

// Get pending syncs
final pending = await database.syncQueueDao
  .getPendingSyncs()
  .get();
```

## Migrations and Schema Changes

### Adding a New Column

1. **Modify Table Definition:**
   ```dart
   @DataClassName('Product')
   class Products extends Table {
     // Existing columns...
     TextColumn get newColumn => text().nullable()();
   }
   ```

2. **Increment Schema Version:**
   ```dart
   @DriftDatabase(
     tables: [...],
     schemaVersion: 2,  // Increment from 1
   )
   class AppDatabase extends _$AppDatabase {
     // Migration logic in onUpgrade
   }
   ```

3. **Add Migration Handler:**
   ```dart
   @override
   MigrationStrategy get migration {
     return MigrationStrategy(
       onUpgrade: (m, oldVersion, newVersion) async {
         // Migration logic
         if (oldVersion < 2) {
           await m.addColumn(database.products, database.products.newColumn);
         }
       },
     );
   }
   ```

4. **Regenerate:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

## Backup and Recovery

### Automatic Backups

- Device performs daily database backups
- Backups stored in encrypted format
- Retained for 30 days
- Location: `<app_data>/backups/`

### Manual Backup

```dart
// Create backup
final backup = await database.backup();
// Save backup to file
```

### Recovery Process

1. Stop application
2. Restore backup file to database location
3. Restart application
4. Verify data integrity

## Database Performance Considerations

### Query Optimization

- **Use Indexes:** Queries use indexes on `user_id`, `product_id`, dates, status fields
- **Pagination:** Load data in pages for long lists
- **Reactive Queries:** UI automatically updates when data changes
- **Batch Operations:** Group inserts/updates for efficiency

### Maintenance

### Weekly Maintenance

```dart
// Analyze table efficiency
await database.customSelect('ANALYZE').get();

// Check database integrity
await database.customSelect('PRAGMA integrity_check').get();
```

### Managing Database Size

- Archive old transactions (> 12 months)
- Purge sync queue items after successful sync
- Clean up temporary/draft records
- Monitor database file size

## Security Considerations

### Password Storage

- User passwords hashed using bcrypt
- Never stored in plain text
- Salt generated uniquely per password

### Data Encryption at Rest

- Sensitive fields encrypted (using `flutter_secure_storage`)
- Database file itself is standard SQLite (not encrypted at DB level)
- Activation codes and tokens stored securely

### Access Control

- Row-level security via user_id
- Users can only access their own data (except admins)
- Audit logs track all access and modifications

## Concurrent Access

### Multi-User Scenarios

- Device activation ensures single-device operation
- SQLite handles concurrent reads/writes
- Drift transactions prevent race conditions
- Sync service coordinates multi-device scenarios

## Related Documentation

- **Programming Guide:** [PROGRAMMING_GUIDE.md](PROGRAMMING_GUIDE.md)
- **API Integration:** [API_INTEGRATION.md](API_INTEGRATION.md)
- **Database Code:** [lib/data/](../lib/data/)

---

**NexxStore Database Architecture v1.0** | Last Updated: March 2026
