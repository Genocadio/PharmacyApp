import 'package:flutter/material.dart';
import 'package:nexxpharma/services/auth_service.dart';
import 'package:nexxpharma/ui/widgets/toast.dart';

class ProfileScreen extends StatefulWidget {
  final AuthService authService;

  const ProfileScreen({super.key, required this.authService});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namesController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final user = widget.authService.currentUser;
    _namesController = TextEditingController(text: user?.names);
    _emailController = TextEditingController(text: user?.email);
    _phoneController = TextEditingController(text: user?.phoneNumber);
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
    _namesController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      final success = await widget.authService.updateProfile(
        names: _namesController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        phoneNumber: _phoneController.text,
        password: _passwordController.text.isEmpty
            ? null
            : _passwordController.text,
      );

      if (success && mounted) {
        Toast.success('Profile updated successfully!');
        Navigator.pop(context);
      } else if (!success) {
        Toast.error(widget.authService.error ?? 'Update failed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update activity to keep session alive
    widget.authService.updateActivity();
    
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.brightness == Brightness.light
                        ? Colors.grey.shade200
                        : Colors.white.withOpacity(0.1),
                    child: Icon(Icons.person, size: 50, color: accentColor),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _namesController,
                    decoration: InputDecoration(
                      labelText: 'Full Names',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.badge_outlined),
                      filled: true,
                      fillColor: theme.brightness == Brightness.light
                          ? Colors.grey.shade50
                          : Colors.white.withOpacity(0.05),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your names';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.phone_outlined),
                      filled: true,
                      fillColor: theme.brightness == Brightness.light
                          ? Colors.grey.shade50
                          : Colors.white.withOpacity(0.05),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: theme.brightness == Brightness.light
                          ? Colors.grey.shade50
                          : Colors.white.withOpacity(0.05),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'New Password (leave blank to keep current)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: theme.brightness == Brightness.light
                          ? Colors.grey.shade50
                          : Colors.white.withOpacity(0.05),
                    ),
                  ),
                  const SizedBox(height: 40),
                  widget.authService.isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _handleUpdate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: theme.colorScheme.onPrimary,
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('Save Changes'),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
