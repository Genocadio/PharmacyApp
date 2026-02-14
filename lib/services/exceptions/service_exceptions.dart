/// Custom exceptions for service layer operations

/// Thrown when a requested resource is not found
class ResourceNotFoundException implements Exception {
  final String resourceType;
  final String field;
  final dynamic value;

  ResourceNotFoundException(this.resourceType, this.field, this.value);

  @override
  String toString() => '$resourceType not found with $field: $value';
}

/// Thrown when there is insufficient stock for a sale
class InsufficientStockException implements Exception {
  final String message;

  InsufficientStockException(this.message);

  @override
  String toString() => 'Insufficient Stock: $message';
}

/// Thrown when business validation rules are violated
class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => 'Validation Error: $message';
}

/// Base class for general service-related errors
class ServiceException implements Exception {
  final String message;

  ServiceException(this.message);

  @override
  String toString() => 'Service Error: $message';
}
