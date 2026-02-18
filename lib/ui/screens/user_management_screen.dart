import 'package:flutter/material.dart';
import 'package:nexxpharma/services/auth_service.dart';
import 'package:nexxpharma/services/dto/user_dto.dart';
import 'package:nexxpharma/data/tables.dart';
import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/ui/widgets/toast.dart';

class UserManagementScreen extends StatefulWidget {
  final AuthService authService;
  final AppDatabase database;

  const UserManagementScreen({
    super.key,
    required this.authService,
    required this.database,
  });

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<UserDTO> _users = [];
  bool _isLoading = true;
  bool _supportMultiUsers = true; // Default to true for safety

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadDeviceSettings();
    widget.authService.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (mounted && !widget.authService.isAuthenticated) {
      // Session expired, return to root (which will show login screen)
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    widget.authService.removeListener(_onAuthChanged);
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await widget.authService.userService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load users: $e')));
      }
    }
  }

  Future<void> _loadDeviceSettings() async {
    final device = await widget.database.getDevice();
    if (device != null && mounted) {
      setState(() {
        _supportMultiUsers = device.supportMultiUsers;
      });
    }
  }

  void _showAddUserDialog() {
    // Check if multi-user is supported
    if (!_supportMultiUsers) {
      Toast.warning('Multi-user support is disabled for this device');
      return;
    }
    final formKey = GlobalKey<FormState>();
    final namesController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    UserRole selectedRole = UserRole.Assistant;
    bool obscurePassword = true;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 600,
              constraints: const BoxConstraints(maxHeight: 700),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person_add,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Add New User',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: StatefulBuilder(
                        builder: (context, setDialogState) => Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: namesController,
                                decoration: InputDecoration(
                                  labelText: 'Full Names',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                ),
                                validator: (value) =>
                                    (value == null || value.trim().isEmpty)
                                    ? 'Full names are required'
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: phoneController,
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  prefixIcon: const Icon(Icons.phone_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                ),
                                validator: (value) =>
                                    (value == null || value.trim().isEmpty)
                                    ? 'Phone number is required'
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                ),
                                validator: (value) =>
                                    (value == null || value.trim().isEmpty)
                                    ? 'Email is required'
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: passwordController,
                                obscureText: obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () {
                                      setDialogState(() {
                                        obscurePassword = !obscurePassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                ),
                                validator: (value) =>
                                    (value == null || value.length < 6)
                                    ? 'Password must be at least 6 characters'
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              DropdownButtonFormField<UserRole>(
                                value: selectedRole,
                                decoration: InputDecoration(
                                  labelText: 'Role',
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                ),
                                items: UserRole.values
                                    .map(
                                      (role) => DropdownMenuItem(
                                        value: role,
                                        child: Text(role.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setDialogState(() => selectedRole = value);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  // Footer
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final createDTO = UserCreateDTO(
                                names: namesController.text.trim(),
                                phoneNumber: phoneController.text.trim(),
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                                role: selectedRole,
                              );
                              try {
                                await widget.authService.userService.register(
                                  createDTO,
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  _loadUsers();
                                  Toast.success('User added successfully');
                                }
                              } catch (e) {
                                Toast.error('Failed to add user: $e');
                              }
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add User'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: anim1.drive(CurveTween(curve: Curves.easeOutBack)),
            child: child,
          ),
        );
      },
    );
  }

  void _showEditUserDialog(UserDTO user) {
    final formKey = GlobalKey<FormState>();
    final namesController = TextEditingController(text: user.names);
    final phoneController = TextEditingController(text: user.phoneNumber);
    final emailController = TextEditingController(text: user.email ?? '');
    UserRole selectedRole = user.role;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 600,
              constraints: const BoxConstraints(maxHeight: 700),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.orange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Edit User',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: StatefulBuilder(
                        builder: (context, setDialogState) => Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: namesController,
                                decoration: InputDecoration(
                                  labelText: 'Full Names',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                ),
                                validator: (value) =>
                                    (value == null || value.trim().isEmpty)
                                    ? 'Full names are required'
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: phoneController,
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  prefixIcon: const Icon(Icons.phone_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                ),
                                validator: (value) =>
                                    (value == null || value.trim().isEmpty)
                                    ? 'Phone number is required'
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                ),
                                validator: (value) =>
                                    (value == null || value.trim().isEmpty)
                                    ? 'Email is required'
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              DropdownButtonFormField<UserRole>(
                                value: selectedRole,
                                decoration: InputDecoration(
                                  labelText: 'Role',
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                ),
                                items: UserRole.values
                                    .map(
                                      (role) => DropdownMenuItem(
                                        value: role,
                                        child: Text(role.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setDialogState(() => selectedRole = value);
                                  }
                                },
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Password cannot be changed here. Users must change their own passwords.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  // Footer
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final updateDTO = UserUpdateDTO(
                                names: namesController.text.trim(),
                                phoneNumber: phoneController.text.trim(),
                                email: emailController.text.trim().isEmpty
                                    ? null
                                    : emailController.text.trim(),
                                role: selectedRole,
                              );
                              try {
                                await widget.authService.userService.updateUser(
                                  user.id,
                                  updateDTO,
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  _loadUsers();
                                  Toast.success('User updated successfully');
                                }
                              } catch (e) {
                                Toast.error('Failed to update user: $e');
                              }
                            }
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Save Changes'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: anim1.drive(CurveTween(curve: Curves.easeOutBack)),
            child: child,
          ),
        );
      },
    );
  }

  void _handleDeactivate(UserDTO user) async {
    // Show confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm'),
        content: Text('Are you sure you want to deactivate ${user.names}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Deactivate',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await widget.authService.userService.deactivateUser(user.id);
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update activity to keep session alive
    widget.authService.updateActivity();
    
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                final isSelf = user.id == widget.authService.currentUser?.id;

                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(user.names),
                  subtitle: Text('${user.role.name} • ${user.phoneNumber}'),
                  trailing: isSelf
                      ? const Chip(label: Text('You'))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.blue,
                              ),
                              tooltip: 'Edit User',
                              onPressed: () => _showEditUserDialog(user),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.person_off_outlined,
                                color: Colors.red,
                              ),
                              tooltip: 'Deactivate User',
                              onPressed: () => _handleDeactivate(user),
                            ),
                          ],
                        ),
                );
              },
            ),
      floatingActionButton: _supportMultiUsers
          ? FloatingActionButton(
              onPressed: _showAddUserDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
