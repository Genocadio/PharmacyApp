import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/data/tables.dart';
import 'package:nexxpharma/services/dto/stock_dto.dart';
import 'package:nexxpharma/services/dto/sale_dto.dart';
import 'package:nexxpharma/services/dto/product_dto.dart';
import 'package:nexxpharma/services/dto/insurance_dto.dart';
import 'package:nexxpharma/services/stock_service.dart';
import 'package:nexxpharma/services/sale_service.dart';
import 'package:nexxpharma/services/product_service.dart';
import 'package:nexxpharma/services/insurance_service.dart';

/// Example demonstrating the service layer usage
void main() async {
  final database = AppDatabase();
  final stockService = StockService(database);
  final saleService = SaleService(database);
  final productService = ProductService(database);
  final insuranceService = InsuranceService(database);

  print('=== Service Layer Example ===\n');

  try {
    // ==================== Insurance Service Example ====================
    print('--- Insurance Service Operations ---');
    final insuranceCreateDTO = InsuranceCreateDTO(
      name: 'RSSB RAMA',
      acronym: 'RAMA',
      clientPercentage: 10.0,
    );
    final insuranceDTO = await insuranceService.createInsurance(
      insuranceCreateDTO,
    );
    print('Created insurance: ${insuranceDTO.name} (${insuranceDTO.id})');

    // Search insurance
    final searchInsurance = await insuranceService.searchByName('RAMA');
    print('Search "RAMA": Found ${searchInsurance.length} items');

    // ==================== Product Service Example ====================
    print('\n--- Product Service Operations ---');
    final productCreateDTO = ProductCreateDTO(
      name: 'Paracetamol 500mg',
      type: ItemType.DRUG,
      description: 'Pain reliever',
      sellingUnit: 'Box of 20',
    );
    final productDTO = await productService.createProduct(productCreateDTO);
    print('Created product: ${productDTO.name} (${productDTO.id})');

    // Link product to insurance (using database for setup)
    await database.linkProductInsurance(
      productId: productDTO.id,
      insuranceId: insuranceDTO.id,
      code: 'PARA-001',
      unit: Unit.BOX,
      cost: 2500.0,
      authorisedLevel: AuthorisedLevel.All,
      mustPrescribedBy: MustPrescribedBy.All,
    );

    // Get enriched product (with insurance links)
    final enrichedProduct = await productService.getProductById(productDTO.id);
    print('Enriched product: ${enrichedProduct.name}');
    print('  Linked insurances: ${enrichedProduct.insurances.length}');
    for (var link in enrichedProduct.insurances) {
      print(
        '    - ${link.insurance.name} (Code: ${link.code}, Cost: ${link.cost})',
      );
    }

    // Search products
    final searchProduct = await productService.searchByName('Para');
    print('Search "Para": Found ${searchProduct.length} items\n');

    // ==================== Setup: Create Stock for Sales Example ====================
    print('--- Setting up test data ---');

    final product = await database.createProduct(
      name: 'Paracetamol 500mg',
      type: ItemType.DRUG,
      description: 'Pain reliever and fever reducer',
      sellingUnit: 'Box of 20 tablets',
    );
    print('Created product: ${product.name}');

    final insurance = await database.createInsurance(
      name: 'RSSB RAMA',
      acronym: 'RAMA',
      clientPercentage: 10.0, // Client pays 10%, insurance pays 90%
    );
    print(
      'Created insurance: ${insurance.name} (Client pays ${insurance.clientPercentage}%)',
    );

    // Link product to insurance
    await database.linkProductInsurance(
      productId: product.id,
      insuranceId: insurance.id,
      code: 'PARA-500-RAMA',
      unit: Unit.BOX,
      cost: 2500.0,
      authorisedLevel: AuthorisedLevel.All,
      mustPrescribedBy: MustPrescribedBy.All,
      utilizationCount: 1,
    );
    print('Linked product to insurance\n');

    // ==================== Stock Service Example ====================
    print('--- Stock Service Operations ---');

    // Create stock using service
    final stockCreateDTO = StockCreateDTO(
      productId: product.id,
      quantity: 100,
      location: 'Warehouse A',
      pricePerUnit: 2500.0,
      batchNumber: 'BATCH-2024-001',
      expiryDate: DateTime(2025, 12, 31),
      reorderLevel: 20,
    );

    final stockDTO = await stockService.createStock(stockCreateDTO);
    print('Created stock: ${stockDTO.productName}');
    print('  Quantity: ${stockDTO.quantity}');
    print('  Location: ${stockDTO.location}');
    print('  Batch: ${stockDTO.batchNumber}');
    print('  Price per unit: ${stockDTO.pricePerUnit}');

    // Get low stock items
    print('\n--- Checking Low Stock Items ---');
    final lowStockItems = await stockService.getLowStockItems();
    print('Low stock items: ${lowStockItems.length}');

    // Get expiring items
    print('\n--- Checking Expiring Items (within 365 days) ---');
    final expiringItems = await stockService.getExpiringItems(365);
    print('Expiring items: ${expiringItems.length}');
    for (final item in expiringItems) {
      print('  ${item.productName} - Expires: ${item.expiryDate}');
    }

    // ==================== Sale Service Example - Private Sale ====================
    print('\n--- Creating Private Sale (No Insurance) ---');

    final privateSaleDTO = SaleCreateDTO(
      patientName: 'John Doe',
      items: [
        SaleItemCreateDTO(
          stockId: stockDTO.id,
          quantitySold: 2,
          pricePerUnit: 2500.0,
        ),
      ],
    );

    final privateSale = await saleService.createSale(privateSaleDTO);
    print('Private sale created for: ${privateSale.patientName}');
    print('  Total price: ${privateSale.totalPrice}');
    print('  Items:');
    for (final item in privateSale.saleItems) {
      print('    ${item.productName} x${item.quantitySold}');
      print('      Item total: ${item.itemTotal}');
      print('      Patient pays: ${item.patientPays}');
      print('      Insurance pays: ${item.insurancePays}');
    }

    // Verify stock was reduced
    final updatedStock1 = await stockService.getStockById(stockDTO.id);
    print('  Stock after sale: ${updatedStock1.quantity} (was 100, sold 2)\n');

    // ==================== Sale Service Example - Insurance Sale ====================
    print('--- Creating Insurance Sale ---');

    final insuranceSaleDTO = SaleCreateDTO(
      patientName: 'Jane Smith',
      insuranceCardNumber: 'INS-12345',
      issuingCompany: 'RSSB',
      prescriberName: 'Dr. John Smith',
      prescriberLicenseId: 'LIC-98765',
      prescribingOrganization: 'City Hospital',
      items: [
        SaleItemCreateDTO(
          stockId: stockDTO.id,
          quantitySold: 3,
          pricePerUnit: 2500.0,
          insuranceId: insurance.id,
        ),
      ],
    );

    final insuranceSale = await saleService.createSale(insuranceSaleDTO);
    print('Insurance sale created for: ${insuranceSale.patientName}');
    print('  Insurance: ${insuranceSale.issuingCompany}');
    print('  Card number: ${insuranceSale.insuranceCardNumber}');
    print('  Prescriber: ${insuranceSale.prescriberName}');
    print('  Total price: ${insuranceSale.totalPrice}');
    print('  Items:');
    for (final item in insuranceSale.saleItems) {
      print('    ${item.productName} x${item.quantitySold}');
      print('      Insurance: ${item.insuranceName}');
      print('      Item total: ${item.itemTotal}');
      print('      Patient pays (10%): ${item.patientPays}');
      print('      Insurance pays (90%): ${item.insurancePays}');
    }

    // Verify stock was reduced again
    final updatedStock2 = await stockService.getStockById(stockDTO.id);
    print('  Stock after sale: ${updatedStock2.quantity} (was 98, sold 3)\n');

    // ==================== Query Sales ====================
    print('--- Querying Sales ---');

    final allSales = await saleService.getAllSales();
    print('Total sales: ${allSales.length}');

    final patientSales = await saleService.getSalesByPatient('John');
    print('Sales for patients named "John": ${patientSales.length}');

    // Sales report
    final report = await saleService.getSalesReport(
      DateTime.now().subtract(Duration(days: 1)),
      DateTime.now().add(Duration(days: 1)),
    );
    print('\nSales Report:');
    print('  Total sales: ${report['totalSales']}');
    print('  Total revenue: ${report['totalRevenue']}');

    // ==================== Error Handling Example ====================
    print('\n--- Testing Error Handling ---');

    try {
      // Try to create sale with insufficient stock
      final insufficientSaleDTO = SaleCreateDTO(
        patientName: 'Test Patient',
        items: [
          SaleItemCreateDTO(
            stockId: stockDTO.id,
            quantitySold: 200, // More than available (95)
            pricePerUnit: 2500.0,
          ),
        ],
      );
      await saleService.createSale(insufficientSaleDTO);
    } catch (e) {
      print('✓ Caught expected error: $e');
    }

    try {
      // Try to create sale with insurance but missing prescriber info
      final invalidSaleDTO = SaleCreateDTO(
        patientName: 'Test Patient',
        items: [
          SaleItemCreateDTO(
            stockId: stockDTO.id,
            quantitySold: 1,
            pricePerUnit: 2500.0,
            insuranceId: insurance.id, // Using insurance
          ),
        ],
        // Missing insurance details - should fail validation
      );
      await saleService.createSale(invalidSaleDTO);
    } catch (e) {
      print('✓ Caught expected validation error: $e');
    }

    print('\n=== Service layer operations completed successfully! ===');
  } catch (e, stackTrace) {
    print('Error: $e');
    print('Stack trace: $stackTrace');
  } finally {
    await database.close();
  }
}
