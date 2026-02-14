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

    final users = await _database.getAllUsers();

    // Search for user by email or phone number
    User? user;
    try {
      user = users.firstWhere(
        (u) =>
            (u.email == loginDTO.identifier ||
                u.phoneNumber == loginDTO.identifier) &&
            u.deletedAt == null,
      );
    } catch (e) {
      throw ValidationException('Invalid identifier or password');
    }

    // Verify password using bcrypt
    if (!PasswordHasher.verifyPassword(loginDTO.password, user.password)) {
      throw ValidationException('Invalid identifier or password');
    }

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
    return await _database.getUsersCount();
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
}
