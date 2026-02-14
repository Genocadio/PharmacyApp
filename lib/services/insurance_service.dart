import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/services/dto/insurance_dto.dart';
import 'package:nexxpharma/services/exceptions/service_exceptions.dart';

/// Service layer for Insurance management
class InsuranceService {
  final AppDatabase _database;

  InsuranceService(this._database);

  /// Get insurance by ID
  Future<InsuranceDTO> getInsuranceById(String id) async {
    try {
      final insurance = await _database.getInsuranceById(id);
      return _convertToDTO(insurance);
    } catch (e) {
      throw ResourceNotFoundException('Insurance', 'id', id);
    }
  }

  /// Get all insurances
  Future<List<InsuranceDTO>> getAllInsurances() async {
    final insurances = await _database.getAllInsurances();
    return insurances.map(_convertToDTO).toList();
  }

  /// Search insurances by name
  Future<List<InsuranceDTO>> searchByName(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      return getAllInsurances();
    }
    final insurances = await _database.searchInsurancesByName(searchTerm);
    return insurances.map(_convertToDTO).toList();
  }

  /// Create a new insurance
  Future<InsuranceDTO> createInsurance(InsuranceCreateDTO createDTO) async {
    createDTO.validate();
    final insurance = await _database.createInsurance(
      name: createDTO.name,
      acronym: createDTO.acronym,
      clientPercentage: createDTO.clientPercentage,
    );
    return _convertToDTO(insurance);
  }

  /// Update an existing insurance
  Future<InsuranceDTO> updateInsurance(
    String id,
    InsuranceCreateDTO updateDTO,
  ) async {
    updateDTO.validate();
    final success = await _database.updateInsurance(
      id: id,
      name: updateDTO.name,
      acronym: updateDTO.acronym,
      clientPercentage: updateDTO.clientPercentage,
    );
    if (!success) {
      throw ResourceNotFoundException('Insurance', 'id', id);
    }
    return getInsuranceById(id);
  }

  /// Delete an insurance (soft delete)
  Future<void> deleteInsurance(String id) async {
    final success = await _database.deleteInsurance(id);
    if (!success) {
      throw ResourceNotFoundException('Insurance', 'id', id);
    }
  }

  /// Convert database entity to DTO
  InsuranceDTO _convertToDTO(insurance) {
    return InsuranceDTO(
      id: insurance.id,
      name: insurance.name,
      acronym: insurance.acronym,
      clientPercentage: insurance.clientPercentage,
      createdAt: insurance.createdAt,
      updatedAt: insurance.updatedAt,
    );
  }
}
