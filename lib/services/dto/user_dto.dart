import 'package:nexxpharma/data/tables.dart';

/// DTO for returning user information
class UserDTO {
  final String id;
  final String names;
  final String phoneNumber;
  final String? email;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserDTO({
    required this.id,
    required this.names,
    required this.phoneNumber,
    this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'names': names,
      'phoneNumber': phoneNumber,
      'email': email,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// DTO for user registration
class UserCreateDTO {
  final String names;
  final String phoneNumber;
  final String? email;
  final String password;
  final UserRole role;

  UserCreateDTO({
    required this.names,
    required this.phoneNumber,
    this.email,
    required this.password,
    required this.role,
  });

  void validate() {
    if (names.trim().isEmpty) {
      throw ArgumentError('Names are mandatory');
    }
    if (phoneNumber.trim().isEmpty) {
      throw ArgumentError('Phone number is mandatory');
    }
    if (password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters long');
    }
    // email is optional as per requirements
  }
}

/// DTO for updating user details
class UserUpdateDTO {
  final String? names;
  final String? phoneNumber;
  final String? email;
  final String? password;
  final UserRole? role;

  UserUpdateDTO({
    this.names,
    this.phoneNumber,
    this.email,
    this.password,
    this.role,
  });
}

/// DTO for login
class LoginDTO {
  final String identifier; // can be phone number or email
  final String password;

  LoginDTO({required this.identifier, required this.password});

  void validate() {
    if (identifier.trim().isEmpty) {
      throw ArgumentError('Identifier (phone/email) is mandatory');
    }
    if (password.trim().isEmpty) {
      throw ArgumentError('Password is mandatory');
    }
  }
}
