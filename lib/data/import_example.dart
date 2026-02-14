import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/data/tables.dart';

/// Example demonstrating data import from server
/// Shows how to import complete data with existing IDs and timestamps
void main() async {
  final database = AppDatabase();

  print('=== Data Import Example ===\n');

  // ==================== Import Insurance from Server ====================
  print('--- Importing Insurance Data ---');

  // Simulating data received from server
  final insuranceJson = {
    "id": "987fcdeb-51a2-43c1-x999-543210987000",
    "name": "RSSB RAMA",
    "acronym": "RAMA",
    "clientPercentage": 15.00,
    "createdAt": "2026-01-01T09:00:00",
    "updatedAt": "2026-01-01T09:00:00",
    "version": 1,
  };

  // Import single insurance
  final insurance = await database.importInsurance(
    id: insuranceJson['id'] as String,
    name: insuranceJson['name'] as String,
    acronym: insuranceJson['acronym'] as String,
    clientPercentage: (insuranceJson['clientPercentage'] as num).toDouble(),
    createdAt: DateTime.parse(insuranceJson['createdAt'] as String),
    updatedAt: DateTime.parse(insuranceJson['updatedAt'] as String),
    version: insuranceJson['version'] as int,
  );
  print('Imported: ${insurance.name} (${insurance.id})');

  // ==================== Import Product from Server ====================
  print('\n--- Importing Product Data ---');

  final productJson = {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "name": "Paracetamol 500mg",
    "type": "DRUG",
    "description": "Pain reliever",
    "metadata": {"sellingUnit": "PACK"},
    "insurances": [], // Always empty in sync to prevent recursion
    "createdAt": "2026-01-01T10:00:00",
    "updatedAt": "2026-01-28T10:00:00",
    "version": 1,
  };

  final metadata = productJson['metadata'] as Map<String, dynamic>;
  final product = await database.importProduct(
    id: productJson['id'] as String,
    name: productJson['name'] as String,
    type: ItemType.values.firstWhere((e) => e.name == productJson['type']),
    description: productJson['description'] as String?,
    sellingUnit: metadata['sellingUnit'] as String?,
    createdAt: DateTime.parse(productJson['createdAt'] as String),
    updatedAt: DateTime.parse(productJson['updatedAt'] as String),
    version: productJson['version'] as int,
  );
  print('Imported: ${product.name} (${product.id})');

  // ==================== Import ProductInsurance from Server ====================
  print('\n--- Importing Product-Insurance Link ---');

  final productInsuranceJson = {
    "id": "55555555-4444-3333-2222-111111111111",
    "productId": "123e4567-e89b-12d3-a456-426614174000",
    "insuranceId": "987fcdeb-51a2-43c1-x999-543210987000",
    "code": "PARA-001",
    "utilizationCount": 1,
    "unit": "TABLET",
    "cost": 100.0,
    "authorisedLevel": "All",
    "mustPrescribedBy": "All",
    "createdAt": "2026-01-15T10:00:00",
    "updatedAt": "2026-01-15T10:00:00",
    "deletedAt": null,
    "version": 1,
  };

  final productInsurance = await database.importProductInsurance(
    id: productInsuranceJson['id'] as String,
    productId: productInsuranceJson['productId'] as String,
    insuranceId: productInsuranceJson['insuranceId'] as String,
    code: productInsuranceJson['code'] as String,
    unit: Unit.values.firstWhere((e) => e.name == productInsuranceJson['unit']),
    cost: (productInsuranceJson['cost'] as num).toDouble(),
    authorisedLevel: AuthorisedLevel.values.firstWhere(
      (e) => e.name == productInsuranceJson['authorisedLevel'],
    ),
    mustPrescribedBy: MustPrescribedBy.values.firstWhere(
      (e) => e.name == productInsuranceJson['mustPrescribedBy'],
    ),
    utilizationCount: productInsuranceJson['utilizationCount'] as int?,
    createdAt: DateTime.parse(productInsuranceJson['createdAt'] as String),
    updatedAt: DateTime.parse(productInsuranceJson['updatedAt'] as String),
    deletedAt: productInsuranceJson['deletedAt'] != null
        ? DateTime.parse(productInsuranceJson['deletedAt'] as String)
        : null,
    version: productInsuranceJson['version'] as int,
  );
  print(
    'Imported link: ${productInsurance.code} (Cost: ${productInsurance.cost})',
  );

  // ==================== Batch Import ====================
  print('\n--- Batch Importing Multiple Insurances ---');

  final insuranceListJson = [
    {
      "id": "111-222-333",
      "name": "MMI",
      "acronym": "MMI",
      "clientPercentage": 20.0,
      "createdAt": "2026-01-02T09:00:00",
      "updatedAt": "2026-01-02T09:00:00",
      "version": 1,
    },
    {
      "id": "444-555-666",
      "name": "Soras",
      "acronym": "SORAS",
      "clientPercentage": 25.0,
      "createdAt": "2026-01-03T09:00:00",
      "updatedAt": "2026-01-03T09:00:00",
      "version": 1,
    },
  ];

  await database.importInsurances(insuranceListJson);
  print('Batch imported ${insuranceListJson.length} insurances');

  // ==================== Verify Imports ====================
  print('\n--- Verifying Imported Data ---');

  final allInsurances = await database.getAllInsurances();
  print('Total insurances in DB: ${allInsurances.length}');

  final allProducts = await database.getAllProducts();
  print('Total products in DB: ${allProducts.length}');

  final allLinks = await database.getAllProductInsurances();
  print('Total product-insurance links: ${allLinks.length}');

  // ==================== Update Imported Data ====================
  print('\n--- Updating Imported Data (Simulating Server Update) ---');

  // Reimport with updated data (upsert)
  final updatedInsurance = await database.importInsurance(
    id: insuranceJson['id'] as String,
    name: insuranceJson['name'] as String,
    acronym: insuranceJson['acronym'] as String,
    clientPercentage: 18.0, // Updated percentage
    createdAt: DateTime.parse(insuranceJson['createdAt'] as String),
    updatedAt: DateTime.now(), // New update time
    version: 2, // Incremented version
  );
  print(
    'Updated ${updatedInsurance.name} - New percentage: ${updatedInsurance.clientPercentage}%',
  );

  // ==================== Mix Local Creation and Import ====================
  print('\n--- Mixing Local Creation and Server Import ---');

  // Create locally (generates new UUID and timestamps)
  final localInsurance = await database.createInsurance(
    name: 'Local Insurance Co',
    acronym: 'LIC',
    clientPercentage: 12.0,
  );
  print('Created locally: ${localInsurance.name} (${localInsurance.id})');

  // Import from server (uses provided UUID and timestamps)
  final serverInsurance = await database.importInsurance(
    id: 'server-generated-uuid-789',
    name: 'Server Insurance Co',
    acronym: 'SIC',
    clientPercentage: 14.0,
    createdAt: DateTime(2026, 1, 1, 8, 0, 0),
    updatedAt: DateTime(2026, 1, 1, 8, 0, 0),
    version: 1,
  );
  print(
    'Imported from server: ${serverInsurance.name} (${serverInsurance.id})',
  );

  print('\n=== Import operations completed successfully! ===');

  await database.close();
}
