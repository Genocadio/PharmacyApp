import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/services/dto/product_dto.dart';
import 'package:nexxpharma/services/dto/insurance_dto.dart';
import 'package:nexxpharma/services/exceptions/service_exceptions.dart';

/// Service layer for Product management
class ProductService {
  final AppDatabase _database;

  ProductService(this._database);

  /// Get product by ID with enriched insurance data
  Future<ProductDTO> getProductById(String id) async {
    try {
      final product = await _database.getProductById(id);
      return await _convertToEnrichedDTO(product);
    } catch (e) {
      throw ResourceNotFoundException('Product', 'id', id);
    }
  }

  /// Get all products (excluding soft-deleted)
  Future<List<ProductDTO>> getAllProducts() async {
    final products = await _database.getAllProducts();
    return Future.wait(products.map(_convertToEnrichedDTO));
  }

  /// Search products by name (efficient search)
  Future<List<ProductDTO>> searchByName(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      return getAllProducts();
    }
    final products = await _database.searchProductsByName(searchTerm);
    return Future.wait(products.map(_convertToEnrichedDTO));
  }

  /// Create a new product
  Future<ProductDTO> createProduct(ProductCreateDTO createDTO) async {
    createDTO.validate();
    final product = await _database.createProduct(
      name: createDTO.name,
      type: createDTO.type,
      description: createDTO.description,
      sellingUnit: createDTO.sellingUnit,
    );
    return await _convertToEnrichedDTO(product);
  }

  /// Update an existing product
  Future<ProductDTO> updateProduct(
    String id,
    ProductCreateDTO updateDTO,
  ) async {
    updateDTO.validate();
    final success = await _database.updateProduct(
      id: id,
      name: updateDTO.name,
      type: updateDTO.type,
      description: updateDTO.description,
      sellingUnit: updateDTO.sellingUnit,
    );
    if (!success) {
      throw ResourceNotFoundException('Product', 'id', id);
    }
    return getProductById(id);
  }

  /// Delete a product (soft delete)
  Future<void> deleteProduct(String id) async {
    final success = await _database.deleteProduct(id);
    if (!success) {
      throw ResourceNotFoundException('Product', 'id', id);
    }
  }

  /// Convert database entity to enriched DTO
  Future<ProductDTO> _convertToEnrichedDTO(product) async {
    // Fetch linked insurances for this product
    final piLinks = await _database.getInsurancesForProduct(product.id);

    // Build InsuranceDataDTOs
    final insuranceDataList = await Future.wait(
      piLinks.map((link) async {
        final insurance = await _database.getInsuranceById(link.insuranceId);
        return InsuranceDataDTO(
          code: link.code,
          utilizationCount: link.utilizationCount,
          unit: link.unit.name,
          cost: link.cost,
          authorisedLevel: link.authorisedLevel.name,
          mustPrescribedBy: link.mustPrescribedBy.name,
          insurance: InsuranceDTO(
            id: insurance.id,
            name: insurance.name,
            acronym: insurance.acronym,
            clientPercentage: insurance.clientPercentage,
            createdAt: insurance.createdAt,
            updatedAt: insurance.updatedAt,
          ),
        );
      }),
    );

    return ProductDTO(
      id: product.id,
      name: product.name,
      type: product.type,
      description: product.description,
      metadata: product.sellingUnit != null
          ? ProductMetadataDTO(sellingUnit: product.sellingUnit)
          : null,
      insurances: insuranceDataList,
    );
  }
}
