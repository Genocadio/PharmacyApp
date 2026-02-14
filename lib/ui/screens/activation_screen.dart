import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:nexxpharma/services/activation_service.dart';
import 'package:nexxpharma/services/auth_service.dart';
import 'package:nexxpharma/services/dto/user_dto.dart';
import 'package:nexxpharma/data/tables.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nexxpharma/ui/widgets/toast.dart';

class ActivationScreen extends StatefulWidget {
  final ActivationService activationService;
  final AuthService authService;
  final VoidCallback onActivated;

  const ActivationScreen({
    super.key,
    required this.activationService,
    required this.authService,
    required this.onActivated,
  });

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController(); // email or phone
  final _codeController = TextEditingController();
  final _urlController = TextEditingController();

  // Manager creation controllers
  final _managerFormKey = GlobalKey<FormState>();
  final _managerNamesController = TextEditingController();
  final _managerPhoneController = TextEditingController();
  final _managerEmailController = TextEditingController();
  final _managerPasswordController = TextEditingController();

  ActivationStatus? _currentStatus;
  bool _initializing = true;
  bool _isActivated = false;
  bool _needsInitialSetup = false;
  LocationPermission _locationPermission = LocationPermission.denied;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _urlController.text = widget.activationService.settingsService.backendUrl;
    }
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final status = await widget.activationService.getStatus();
    final permission = await widget.activationService.checkLocationPermission();
    final activated = await widget.activationService.isActivated();

    // Check if initial setup (Manager creation) is needed
    bool needsSetup = false;
    if (activated) {
      final userCount = await widget.authService.userService.getUsersCount();
      needsSetup = userCount == 0;
    }

    setState(() {
      _currentStatus = status;
      _locationPermission = permission;
      _isActivated = activated;
      _needsInitialSetup = needsSetup;
      _initializing = false;
    });
    
    // If already activated and has users, navigation will be handled by main.dart
    // But trigger a refresh to ensure navigation happens
    if (activated && !needsSetup) {
      widget.onActivated();
    }
  }

  Future<void> _requestPermission() async {
    final permission = await widget.activationService
        .requestLocationPermission();
    setState(() {
      _locationPermission = permission;
    });
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _codeController.dispose();
    _urlController.dispose();
    _managerNamesController.dispose();
    _managerPhoneController.dispose();
    _managerEmailController.dispose();
    _managerPasswordController.dispose();
    super.dispose();
  }

  void _handleActivation() async {
    if (_formKey.currentState!.validate()) {
      // Update Backend URL first
      await widget.activationService.updateBackendUrl(
        _urlController.text.trim(),
      );

      final identifier = _identifierController.text.trim();
      String? email;
      String? phone;

      if (identifier.contains('@')) {
        email = identifier;
      } else {
        phone = identifier;
      }

      final success = await widget.activationService.registerDevice(
        email: email,
        phone: phone,
        code: _codeController.text.trim(),
      );

      if (success) {
        await _checkStatus();
      } else {
        await _checkStatus();
        Toast.error(
          widget.activationService.error ?? 'Activation failed',
        );
      }
    }
  }

  void _handleCreateManager() async {
    if (_managerFormKey.currentState!.validate()) {
      final createDTO = UserCreateDTO(
        names: _managerNamesController.text.trim(),
        phoneNumber: _managerPhoneController.text.trim(),
        email: _managerEmailController.text.trim(),
        password: _managerPasswordController.text.trim(),
        role: UserRole.Manager, // Automatically set as Manager
      );

      final success = await widget.authService.register(createDTO);
      if (success) {
        // Now fully activated and has a manager
        widget.onActivated();
      } else {
        Toast.error(
          widget.authService.error ?? 'Failed to create manager',
        );
      }
    }
  }

  void _handleReset() async {
    await widget.activationService.resetActivation();
    await _checkStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If already activated and has users, show loading while navigation happens
    if (_isActivated && !_needsInitialSetup) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isActivated && _needsInitialSetup) {
      return _buildInitialSetupForm();
    }

    if (_isActivated &&
        (_currentStatus == ActivationStatus.PENDING ||
            _currentStatus == ActivationStatus.INACTIVE)) {
      return _buildPendingUI();
    }

    return _buildActivationForm();
  }

  Widget _buildActivationForm() {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_person_outlined,
                        size: 80,
                        color: accentColor,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'App Activation',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please enter your branch details to activate the app.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      if (kDebugMode)
                        TextFormField(
                          controller: _urlController,
                          decoration: InputDecoration(
                            labelText: 'API Base URL',
                            prefixIcon: const Icon(Icons.link_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: 'http://localhost:8080',
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      if (kDebugMode) const SizedBox(height: 20),
                      TextFormField(
                        controller: _identifierController,
                        decoration: InputDecoration(
                          labelText: 'Email or Phone',
                          prefixIcon: const Icon(Icons.contact_mail_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          labelText: 'Activation Code',
                          prefixIcon: const Icon(Icons.vpn_key_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      _buildPermissionStatus(),
                      const SizedBox(height: 40),
                      widget.activationService.isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _handleActivation,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Activate Now',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingUI() {
    final theme = Theme.of(context);
    final isPending = _currentStatus == ActivationStatus.PENDING;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPending ? Icons.hourglass_empty : Icons.error_outline,
                size: 100,
                color: isPending ? Colors.orange : Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                isPending ? 'Activation Pending' : 'App Inactive',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your branch registration is being processed. Please wait for an administrator to activate your branch.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _checkStatus,
                child: const Text('Check Status'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _handleReset,
                child: const Text('Reset & Try Another Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialSetupForm() {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Form(
                  key: _managerFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.admin_panel_settings_outlined,
                        size: 80,
                        color: accentColor,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Initial Setup',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Creation of the first Manager account is required to continue.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      TextFormField(
                        controller: _managerNamesController,
                        decoration: InputDecoration(
                          labelText: 'Full Names',
                          prefixIcon: const Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _managerPhoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _managerEmailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _managerPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) =>
                            (value == null || value.length < 6)
                            ? 'Minimum 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 40),
                      widget.authService.isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _handleCreateManager,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Create Manager',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionStatus() {
    final theme = Theme.of(context);
    final isGranted =
        _locationPermission == LocationPermission.always ||
        _locationPermission == LocationPermission.whileInUse;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isGranted
            ? Colors.green.withValues(alpha: 25)
            : Colors.orange.withValues(alpha: 25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGranted ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isGranted
                ? Icons.check_circle_outline
                : Icons.location_off_outlined,
            color: isGranted ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGranted
                      ? 'Location Access Granted'
                      : 'Location Access Needed',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (!isGranted)
                  Text(
                    'Location is optional. Grant access to include coordinates.',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          if (!isGranted)
            TextButton(
              onPressed: _requestPermission,
              child: const Text('Grant'),
            ),
        ],
      ),
    );
  }
}
