import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/data/tables.dart';
import 'package:nexxpharma/services/dto/user_dto.dart';
import 'package:nexxpharma/services/user_service.dart';

/// Example function demonstrating how to use the UserService
void runUserManagementExample(AppDatabase database) async {
  final userService = UserService(database);

  print('--- User Management Example ---');

  // 1. Register a new user (Owner)
  print('Registering user...');
  try {
    final owner = await userService.register(
      UserCreateDTO(
        names: 'John Doe',
        phoneNumber: '0781234567',
        email: 'john.doe@example.com',
        password: 'password123',
        role: UserRole.Owner,
      ),
    );
    print('Owner registered: ${owner.names} (${owner.id})');
  } catch (e) {
    print('Failed to register owner: $e');
  }

  // 2. Register another user (Pharmacist)
  print('Registering pharmacist...');
  try {
    final pharmacist = await userService.register(
      UserCreateDTO(
        names: 'Jane Smith',
        phoneNumber: '0787654321',
        password: 'securePassword789',
        role: UserRole.Pharmacist,
      ),
    );
    print('Pharmacist registered: ${pharmacist.names} (${pharmacist.id})');
  } catch (e) {
    print('Failed to register pharmacist: $e');
  }

  // 3. Login
  print('Logging in...');
  try {
    final loggedInUser = await userService.login(
      LoginDTO(identifier: '0781234567', password: 'password123'),
    );
    print('Login successful: Welcome ${loggedInUser.names}!');
  } catch (e) {
    print('Login failed: $e');
  }

  // 4. Update Profile
  print('Updating profile...');
  try {
    // Get all users to find one
    final users = await userService.getAllUsers();
    if (users.isNotEmpty) {
      final userToUpdate = users.first;
      final updatedUser = await userService.updateUser(
        userToUpdate.id,
        UserUpdateDTO(names: 'John Updated Doe'),
      );
      print('Update successful: ${updatedUser.names}');
    }
  } catch (e) {
    print('Update failed: $e');
  }

  // 5. List all users
  print('Listing all users:');
  final allUsers = await userService.getAllUsers();
  for (final user in allUsers) {
    print('- ${user.names} [${user.role.name}]');
  }

  print('--- End of Example ---');
}
