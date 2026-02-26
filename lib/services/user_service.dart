import 'package:flutter/foundation.dart';
import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/services/dto/user_dto.dart';
import 'package:nexxpharma/services/exceptions/service_exceptions.dart';
import 'package:nexxpharma/services/utils/password_hasher.dart';

/// Service layer for User management
class UserService {
  final AppDatabase _database;

  UserService(this._database);

  /// Register a new user
  Future<UserDTO> register(UserCreateDTO createDTO) async {
    createDTO.validate();

    // Check if phone number already exists
    final existingUsers = await _database.getAllUsers();
    if (existingUsers.any((u) => u.phoneNumber == createDTO.phoneNumber)) {
      throw ValidationException('Phone number already exists');
    }

    // Hash the password before storing
    final hashedPassword = PasswordHasher.hashPassword(createDTO.password);

    final user = await _database.createUser(
      names: createDTO.names,
      phoneNumber: createDTO.phoneNumber,
      password: hashedPassword,
      role: createDTO.role,
      email: createDTO.email,
    );
    return _convertToDTO(user);
  }

  /// Authenticate user
  Future<UserDTO> login(LoginDTO loginDTO) async {
    loginDTO.validate();

    final user = await _findUserByIdentifier(loginDTO.identifier);
    if (user != null) {
      if (!PasswordHasher.verifyPassword(loginDTO.password, user.password)) {
        throw ValidationException('Invalid identifier or password');
      }
      return _convertToDTO(user);
    }

    final worker = await _database.getWorkerByIdentifier(loginDTO.identifier);
    if (worker == null) {
      throw ValidationException('Invalid identifier or password');
    }

    if (worker.pinHash == null || worker.pinHash!.isEmpty) {
      throw ValidationException('PASSWORD_SETUP_REQUIRED');
    }

    if (!PasswordHasher.verifyPassword(loginDTO.password, worker.pinHash!)) {
      throw ValidationException('Invalid identifier or password');
    }

    await _database.upsertUserFromWorker(worker, worker.pinHash!);
    final syncedUser = await _database.getUserById(worker.id);
    return _convertToDTO(syncedUser);
  }

  Future<Worker?> findWorkerByIdentifier(String identifier) async {
    return _database.getWorkerByIdentifier(identifier);
  }

  Future<bool> workerNeedsPasswordSetup(String identifier) async {
    final worker = await _database.getWorkerByIdentifier(identifier);
    if (worker == null) return false;
    return worker.pinHash == null || worker.pinHash!.isEmpty;
  }

  Future<UserDTO> createPasswordForWorker({
    required String identifier,
    required String password,
  }) async {
    if (password.length < 6) {
      throw ValidationException('Password must be at least 6 characters');
    }

    final worker = await _database.getWorkerByIdentifier(identifier);
    if (worker == null) {
      throw ValidationException('Worker not found for this identifier');
    }

    if (worker.pinHash != null && worker.pinHash!.isNotEmpty) {
      throw ValidationException('Password already exists for this worker');
    }

    final hashedPassword = PasswordHasher.hashPassword(password);
    await _database.setWorkerPasswordHash(worker.id, hashedPassword);

    final updatedWorker = await _database.getWorker(worker.id);
    if (updatedWorker == null) {
      throw ServiceException('Failed to update worker password');
    }

    await _database.upsertUserFromWorker(updatedWorker, hashedPassword);
    final user = await _database.getUserById(updatedWorker.id);
    return _convertToDTO(user);
  }

  /// Update user details
  Future<UserDTO> updateUser(String id, UserUpdateDTO updateDTO) async {
    // Check if user exists
    try {
      await _database.getUserById(id);
    } catch (e) {
      throw ResourceNotFoundException('User', 'id', id);
    }

    // Hash password if provided
    String? hashedPassword;
    if (updateDTO.password != null && updateDTO.password!.isNotEmpty) {
      hashedPassword = PasswordHasher.hashPassword(updateDTO.password!);
    }

    // Perform update
    final success = await _database.updateUser(
      id: id,
      names: updateDTO.names,
      phoneNumber: updateDTO.phoneNumber,
      password: hashedPassword,
      role: updateDTO.role,
      email: updateDTO.email,
    );

    if (!success) {
      throw ServiceException('Failed to update user');
    }

    final updatedUser = await _database.getUserById(id);
    return _convertToDTO(updatedUser);
  }

  /// Soft delete a user
  Future<void> deleteUser(String id) async {
    // Check if user exists
    try {
      await _database.getUserById(id);
    } catch (e) {
      throw ResourceNotFoundException('User', 'id', id);
    }

    final success = await _database.deleteUser(id);
    if (!success) {
      throw ServiceException('Failed to delete user');
    }
  }

  /// Get user by ID
  Future<UserDTO> getUserById(String id) async {
    try {
      final user = await _database.getUserById(id);
      return _convertToDTO(user);
    } catch (e) {
      throw ResourceNotFoundException('User', 'id', id);
    }
  }

  /// List all active users
  Future<List<UserDTO>> getAllUsers() async {
    final users = await _database.getAllUsers();
    return users.map((u) => _convertToDTO(u)).toList();
  }

  /// Get total count of active users
  Future<int> getUsersCount() async {
    return await _database.getLoginAccountsCount();
  }

  /// Clear all users (for fresh manager creation after activation)
  Future<void> clearAllUsers() async {
    final users = await _database.getAllUsers();
    for (final user in users) {
      try {
        await _database.hardDeleteUser(user.id);
      } catch (e) {
        debugPrint('Error deleting user ${user.id}: $e');
      }
    }
  }

  /// Deactivate a user
  Future<void> deactivateUser(String id) async {
    await _database.updateUser(
      id: id,
      role: null, // Deactivation logic
    );
  }

  /// Helper to convert database entity to DTO
  UserDTO _convertToDTO(User user) {
    return UserDTO(
      id: user.id,
      names: user.names,
      phoneNumber: user.phoneNumber,
      email: user.email,
      role: user.role,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  Future<User?> _findUserByIdentifier(String identifier) async {
    final byEmail = await _database.getUserByEmail(identifier);
    if (byEmail != null && byEmail.deletedAt == null) {
      return byEmail;
    }

    final byPhone = await _database.getUserByPhone(identifier);
    if (byPhone != null && byPhone.deletedAt == null) {
      return byPhone;
    }

    return null;
  }
}
