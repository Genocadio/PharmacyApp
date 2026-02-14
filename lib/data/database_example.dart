import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/data/tables.dart';

/// Example usage of the AppDatabase
/// This demonstrates all CRUD operations for Insurance, Product, and ProductInsurance
void main() async {
  // Initialize database
  final database = AppDatabase();

  print('=== Medical Catalog Database Example ===\n');

  // ==================== Insurance Operations ====================
  print('--- Creating Insurances ---');

  final insurance1 = await database.createInsurance(
    name: 'Rwanda Social Security Board',
    acronym: 'RSSB',
    clientPercentage: 10.0,
  );
  print('Created: ${insurance1.name} (${insurance1.acronym})');

  final insurance2 = await database.createInsurance(
    name: 'Medical Insurance Company',
    acronym: 'MMI',
    clientPercentage: 15.0,
  );
  print('Created: ${insurance2.name} (${insurance2.acronym})');

  // Read all insurances
  print('\n--- All Insurances ---');
  final allInsurances = await database.getAllInsurances();
  for (var ins in allInsurances) {
    print('${ins.name} - Client pays: ${ins.clientPercentage}%');
  }

  // Update insurance
  print('\n--- Updating Insurance ---');
  await database.updateInsurance(id: insurance1.id, clientPercentage: 12.5);
  final updatedIns = await database.getInsuranceById(insurance1.id);
  print(
    'Updated ${updatedIns.name} - New client percentage: ${updatedIns.clientPercentage}%',
  );

  // ==================== Product Operations ====================
  print('\n--- Creating Products ---');

  final product1 = await database.createProduct(
    name: 'Paracetamol 500mg',
    type: ItemType.DRUG,
    description: 'Pain relief and fever reducer',
    sellingUnit: 'Box of 20 tablets',
  );
  print('Created: ${product1.name}');

  final product2 = await database.createProduct(
    name: 'Surgical Gloves',
    type: ItemType.CONSUMABLE_DEVICE,
    description: 'Sterile latex gloves',
    sellingUnit: 'Box of 100',
  );
  print('Created: ${product2.name}');

  // Search products
  print('\n--- Searching Products ---');
  final searchResults = await database.searchProductsByName('Paracetamol');
  for (var product in searchResults) {
    print('Found: ${product.name} - Type: ${product.type}');
  }

  // Update product
  print('\n--- Updating Product ---');
  await database.updateProduct(
    id: product1.id,
    description: 'Pain relief, fever reducer, and anti-inflammatory',
  );
  final updatedProduct = await database.getProductById(product1.id);
  print('Updated description: ${updatedProduct.description}');

  // ==================== Product-Insurance Linking ====================
  print('\n--- Linking Products to Insurances ---');

  final link1 = await database.linkProductInsurance(
    productId: product1.id,
    insuranceId: insurance1.id,
    code: 'PARA-500-RSSB',
    unit: Unit.BOX,
    cost: 2500.0,
    authorisedLevel: AuthorisedLevel.All,
    mustPrescribedBy: MustPrescribedBy.All,
    utilizationCount: 1,
  );
  print(
    'Linked ${product1.name} to ${insurance1.acronym} - Cost: ${link1.cost} RWF',
  );

  final link2 = await database.linkProductInsurance(
    productId: product1.id,
    insuranceId: insurance2.id,
    code: 'PARA-500-MMI',
    unit: Unit.BOX,
    cost: 3000.0,
    authorisedLevel: AuthorisedLevel.All,
    mustPrescribedBy: MustPrescribedBy.All,
    utilizationCount: 1,
  );
  print(
    'Linked ${product1.name} to ${insurance2.acronym} - Cost: ${link2.cost} RWF',
  );

  final link3 = await database.linkProductInsurance(
    productId: product2.id,
    insuranceId: insurance1.id,
    code: 'GLOVE-RSSB',
    unit: Unit.BOX,
    cost: 15000.0,
    authorisedLevel: AuthorisedLevel.HOSPITAL_USE_DRUG,
    mustPrescribedBy: MustPrescribedBy.All,
  );
  print(
    'Linked ${product2.name} to ${insurance1.acronym} - Cost: ${link3.cost} RWF',
  );

  // Get product with all its insurances
  print('\n--- Product with Insurance Details ---');
  final productWithIns = await database.getProductWithInsurances(product1.id);
  productWithIns.forEach((product, insuranceLinks) {
    print('Product: ${product.name}');
    print('Available under ${insuranceLinks.length} insurance(s):');
    for (var link in insuranceLinks) {
      print(
        '  - Code: ${link.code}, Cost: ${link.cost} RWF, Unit: ${link.unit}',
      );
    }
  });

  // Get insurance with all its products
  print('\n--- Insurance with Product Details ---');
  final insuranceWithProds = await database.getInsuranceWithProducts(
    insurance1.id,
  );
  insuranceWithProds.forEach((insurance, productLinks) {
    print('Insurance: ${insurance.name}');
    print('Covers ${productLinks.length} product(s):');
    for (var link in productLinks) {
      print('  - Code: ${link.code}, Cost: ${link.cost} RWF');
    }
  });

  // Update product insurance link
  print('\n--- Updating Product-Insurance Link ---');
  await database.updateProductInsurance(id: link1.id, cost: 2800.0);
  final updatedLink = await database.getProductInsuranceById(link1.id);
  print('Updated cost for ${updatedLink.code}: ${updatedLink.cost} RWF');

  // ==================== Soft Delete Operations ====================
  print('\n--- Soft Delete Operations ---');

  // Soft delete a product-insurance link
  await database.deleteProductInsurance(link3.id);
  print('Soft deleted link: ${link3.code}');

  // Verify it's not in active list
  final activeLinks = await database.getInsurancesForProduct(product2.id);
  print('Active links for ${product2.name}: ${activeLinks.length}');

  // Soft delete a product
  await database.deleteProduct(product2.id);
  print('Soft deleted product: ${product2.name}');

  final activeProducts = await database.getAllProducts();
  print('Active products count: ${activeProducts.length}');

  // ==================== Advanced Queries ====================
  print('\n--- Advanced Queries ---');

  // Get all insurances for a specific product
  final productInsurances = await database.getInsurancesForProduct(product1.id);
  print(
    '${product1.name} is covered by ${productInsurances.length} insurance(s)',
  );

  // Get all products for a specific insurance
  final insuranceProducts = await database.getProductsForInsurance(
    insurance1.id,
  );
  print('${insurance1.acronym} covers ${insuranceProducts.length} product(s)');

  print('\n=== Database operations completed successfully! ===');

  // Close database connection
  await database.close();
}
