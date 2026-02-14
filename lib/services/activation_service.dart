import 'dart:async';
import 'dart:convert';
import 'package:crypton/crypton.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/services/dto/activation_dto.dart';
import 'package:nexxpharma/services/settings_service.dart';
import 'package:nexxpharma/services/notification_service.dart';
import 'package:nexxpharma/data/tables.dart';

class ActivationService extends ChangeNotifier {
  final AppDatabase _db;
  final SettingsService _settings;
  final NotificationService _notificationService;
  final _storage = const FlutterSecureStorage();

  SettingsService get settingsService => _settings;

  static const String _privateKeyStorageKey = 'app_private_key';
  // ignore: unused_field
  static const Duration _statusThrottleInterval = Duration(hours: 5);
  static const Duration _detailsThrottleInterval = Duration(hours: 24);
  static const Duration _statusCheckInterval = Duration(minutes: 5);
  static const Duration _activationTimeout = Duration(seconds: 25);

  Timer? _statusTimer;
  Timer? _keyRotationTimer;

  bool _isLoading = false;
  String? _error;
  bool? _isActivated;
  DateTime? _lastExpirationWarning;

  ActivationService(this._db, this._settings, this._notificationService) {
    _init();
  }

  Future<void> _init() async {
    await _refreshActivationState();
    _startMonitoring();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _keyRotationTimer?.cancel();
    super.dispose();
  }

  /// Check current location permission status
  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestLocationPermission() async {
    final permission = await Geolocator.requestPermission();
    notifyListeners();
    return permission;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool? get activationState => _isActivated;

  /// Check if the app is activated
  Future<bool> isActivated() async {
    if (_isActivated != null) return _isActivated!;
    await _refreshActivationState();
    return _isActivated ?? false;
  }

  /// Get the current activation status
  Future<ActivationStatus?> getStatus() async {
    final device = await _db.getDevice();
    if (device != null) return device.activationStatus;
    final module = await _db.getModule();
    return module?.activationStatus;
  }

  /// Register device (Activate app)
  Future<bool> registerDevice({
    String? email,
    String? phone,
    required String code,
    String? deviceName,
  }) async {
    if (email == null && phone == null) {
      _error = 'Email or phone is required';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Location is optional and fetched on app launch/status updates.
      // Avoid blocking activation on a location lookup.
      Position? position;

      // 2. Get app version
      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = packageInfo.version;

      // 3. Get or Generate RSA keys from Database
      final existingModule = await _db.getModule();
      String? privateKeyString = existingModule?.privateKey;

      late RSAPrivateKey privateKey;
      late RSAPublicKey publicKey;

      if (privateKeyString == null) {
        final keypair = RSAKeypair.fromRandom();
        privateKey = keypair.privateKey;
        publicKey = keypair.publicKey;
        privateKeyString = privateKey.toString();
        // We will save it to DB along with the module response below
      } else {
        privateKey = RSAPrivateKey.fromString(privateKeyString);
        publicKey = privateKey.publicKey;
      }

      // 4. Create request
      final request = DeviceRegistrationRequest(
        email: email,
        phone: phone,
        code: code,
        publicKey: publicKey.toString(),
        latitude: position?.latitude,
        longitude: position?.longitude,
        appVersion: appVersion,
        deviceName: deviceName,
      );

      // 5. Send request
      final url = Uri.parse(
        '${_settings.backendUrl}/api/devices/register-device',
      );
      
      debugPrint('=== Device Registration Request ===');
      debugPrint('Code: $code');
      debugPrint('Email: $email');
      debugPrint('Phone: $phone');
      debugPrint('DeviceName: $deviceName');
      debugPrint('Request Body: ${json.encode(request.toJson())}');
      
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(request.toJson()),
          )
          .timeout(_activationTimeout);

      debugPrint('=== Device Registration Response ===');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        final deviceResponse = DeviceApiResponse<DeviceDTO>.fromJson(
          body,
          parseData: (data) =>
              DeviceDTO.fromJson(data as Map<String, dynamic>),
        );

        await _handleDeviceApiResponse(
          deviceResponse,
          privateKeyOverride: privateKeyString,
        );

        _isLoading = false;
        notifyListeners();
        return _isActivated ?? false;
      } else {
        _error = 'Activation failed: ${response.body}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on TimeoutException catch (e) {
      _error = 'Activation timeout. Please check the API URL or network.';
      debugPrint('Activation request timed out: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Error during activation: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update backend URL
  Future<void> updateBackendUrl(String url) async {
    await _settings.updateBackendUrl(url);
    notifyListeners();
  }

  /// Update device status and heartbeat
  Future<DeviceApiResponse<void>?> updateDeviceStatus({
    String? lastAction,
  }) async {
    final signedContext = await _getSignedContext();
    if (signedContext == null) return null;

    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = packageInfo.version;

    final position = await _getCurrentLocationIfPermitted();

    final device = await _db.getDevice();
    final deviceStatus = device?.activationStatus ?? ActivationStatus.ACTIVE;
    final supportMultiUsers = device?.supportMultiUsers ?? false;

    final input = UpdateDeviceInput(
      appVersion: appVersion,
      activationStatus: deviceStatus,
      supportMultiUsers: supportMultiUsers,
      lastAction: lastAction,
      latitude: position?.latitude,
      longitude: position?.longitude,
    );

    final payload = input.toJson();
    final signaturePayload = _buildDeviceSignaturePayload(
      signedContext.deviceId,
      payload,
    );
    final signature = signedContext.privateKey.createSignature(
      signaturePayload,
    );

    final request = DeviceSignedRequest<UpdateDeviceInput>(
      deviceId: signedContext.deviceId,
      signature: signature,
      data: input,
    );

    debugPrint('=== Device Status Request ===');
    debugPrint('DeviceId: ${signedContext.deviceId}');
    debugPrint('Payload: ${json.encode(payload)}');
    debugPrint('Signature Payload: $signaturePayload');
    debugPrint('PrivateKey: ${signedContext.privateKey.toString()}');
    debugPrint('PublicKey: ${signedContext.privateKey.publicKey.toString()}');
    debugPrint('Signature: $signature');
    debugPrint('Request Body: ${json.encode(request.toJson((data) => data?.toJson()))}');

    final response = await http.post(
      Uri.parse('${_settings.backendUrl}/api/devices/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson((data) => data?.toJson())),
    );

    debugPrint('=== Device Status Response ===');
    debugPrint('Status: ${response.statusCode}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint('Error Body: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = DeviceApiResponse<void>.fromJson(body);
      await _handleDeviceApiResponse(apiResponse);
      await _db.updateDeviceLocal(
        appVersion: appVersion,
        latitude: position?.latitude,
        longitude: position?.longitude,
        lastAction: lastAction,
      );
      await _settings.updateLastDeviceStatusAt(DateTime.now());
      return apiResponse;
    }

    return null;
  }

  /// Acknowledge a device command
  Future<DeviceApiResponse<void>?> acknowledgeCommand(int commandId) async {
    final signedContext = await _getSignedContext();
    if (signedContext == null) return null;

    final payload = CommandAcknowledgmentPayload(commandId: commandId);
    final payloadJson = payload.toJson();
    final signaturePayload = _buildDeviceSignaturePayload(
      signedContext.deviceId,
      payloadJson,
    );
    final signature = signedContext.privateKey.createSignature(
      signaturePayload,
    );

    final request = DeviceSignedRequest<CommandAcknowledgmentPayload>(
      deviceId: signedContext.deviceId,
      signature: signature,
      data: payload,
    );

    debugPrint('=== Acknowledge Command Request ===');
    debugPrint('DeviceId: ${signedContext.deviceId}');
    debugPrint('CommandId: $commandId');
    debugPrint('Signature Payload: $signaturePayload');
    debugPrint('PrivateKey: ${signedContext.privateKey.toString()}');
    debugPrint('PublicKey: ${signedContext.privateKey.publicKey.toString()}');
    debugPrint('Signature: $signature');
    debugPrint('Request Body: ${json.encode(request.toJson((data) => data?.toJson()))}');

    final response = await http.post(
      Uri.parse('${_settings.backendUrl}/api/devices/acknowledge-command'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson((data) => data?.toJson())),
    );

    debugPrint('=== Acknowledge Command Response ===');
    debugPrint('Status: ${response.statusCode}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint('Error Body: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = DeviceApiResponse<void>.fromJson(body);
      await _handleDeviceApiResponse(apiResponse);
      return apiResponse;
    }

    return null;
  }

  /// Recycle module code (admin only)
  Future<String?> recycleModuleCode() async {
    final signedContext = await _getSignedContext();
    if (signedContext == null) return null;

    final signaturePayload = _buildDeviceSignaturePayload(
      signedContext.deviceId,
      <String, dynamic>{},
    );
    final signature = signedContext.privateKey.createSignature(
      signaturePayload,
    );

    final request = DeviceSignedRequest<void>(
      deviceId: signedContext.deviceId,
      signature: signature,
      data: null,
    );

    debugPrint('=== Recycle Module Code Request ===');
    debugPrint('DeviceId: ${signedContext.deviceId}');
    debugPrint('PrivateKey: ${signedContext.privateKey.toString()}');
    debugPrint('PublicKey: ${signedContext.privateKey.publicKey.toString()}');
    debugPrint('Signature: $signature');
    debugPrint('Request Body: ${json.encode(request.toJson((data) => data))}');

    final response = await http.post(
      Uri.parse('${_settings.backendUrl}/api/devices/recycle-code'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson((data) => data)),
    );

    debugPrint('=== Recycle Module Code Response ===');
    debugPrint('Status: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = DeviceApiResponse<String>.fromJson(
        body,
        parseData: (data) => data == null ? '' : data.toString(),
      );
      await _handleDeviceApiResponse(apiResponse);
      debugPrint('Module code recycled successfully: ${apiResponse.data}');
      return apiResponse.data;
    }

    debugPrint(
      'Failed to recycle module code: ${response.statusCode} ${response.body}',
    );

    return null;
  }

  Future<Position?> _getCurrentLocationIfPermitted() async {
    final permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      return null;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      debugPrint('Location tracking failed (optional): $e');
      return null;
    }
  }

  /// Reset activation (for re-activation)
  Future<void> resetActivation() async {
    await _db.deleteModule();
    await _db.deleteDevice();
    // We also clear any legacy storage if it exists
    try {
      await _storage.delete(key: _privateKeyStorageKey);
    } catch (e) {
      debugPrint('Secure storage delete failed: $e');
    }
    await _settings.prefs.remove(_privateKeyStorageKey);
    await _settings.resetDeviceTracking();
    _isActivated = false;
    notifyListeners();
  }

  bool _isModuleActive(Module? module) {
    if (module == null) return false;
    if (module.activationStatus != ActivationStatus.ACTIVE) return false;
    final expires = module.expirationDate;
    if (expires != null && DateTime.now().isAfter(expires)) {
      return false;
    }
    return true;
  }

  bool _isDeviceActive(Device? device) {
    if (device == null) return false;
    return device.activationStatus == ActivationStatus.ACTIVE;
  }

  Future<void> _refreshActivationState() async {
    final module = await _db.getModule();
    final device = await _db.getDevice();
    _isActivated = _isModuleActive(module) && _isDeviceActive(device);
    notifyListeners();
  }

  void _startMonitoring() {
    // Device status check every 5 minutes
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(_statusCheckInterval, (_) async {
      await _performScheduledChecks();
    });
    _performScheduledChecks();

    // Public key rotation check every hour (but throttled to 24 hours)
    _keyRotationTimer?.cancel();
    _keyRotationTimer = Timer.periodic(Duration(hours: 1), (_) async {
      await _rotatePublicKeyIfNeeded();
    });
    // Also check on startup
    _rotatePublicKeyIfNeeded();
  }

  Future<void> _performScheduledChecks() async {
    // Only check device status - SyncOut is user-triggered
    await _updateDeviceStatusIfNeeded();
  }

  /// Check if device status should be updated (throttled to 5 hours)
  Future<bool> _shouldUpdateDeviceStatus() async {
    final lastUpdate = _settings.lastDeviceStatusAt;
    if (lastUpdate == null) return true;
    final elapsed = DateTime.now().difference(lastUpdate);
    return elapsed.inHours >= 5;
  }

  /// Update device status only if throttle interval has elapsed (5 hours)
  Future<void> _updateDeviceStatusIfNeeded() async {
    if (await _shouldUpdateDeviceStatus()) {
      await updateDeviceStatus();
    }
  }



  Future<void> _rotatePublicKeyIfNeeded() async {
    final lastRotation = _settings.lastPublicKeyRotationAt;
    if (lastRotation != null &&
        DateTime.now().difference(lastRotation) < _detailsThrottleInterval) {
      return;
    }

    final response = await _rotatePublicKey();
    if (response != null) {
      await _settings.updateLastPublicKeyRotationAt(DateTime.now());
      await _settings.updateLastDeviceDetailsAt(DateTime.now());
    }
  }

  Future<DeviceApiResponse<void>?> _rotatePublicKey() async {
    final signedContext = await _getSignedContext();
    if (signedContext == null) return null;

    final keypair = RSAKeypair.fromRandom();
    final newPrivateKey = keypair.privateKey;
    final newPublicKey = keypair.publicKey;

    final payload = UpdatePublicKeyPayload(newPublicKey: newPublicKey.toString());
    final payloadJson = payload.toJson();
    final signaturePayload = _buildDeviceSignaturePayload(
      signedContext.deviceId,
      payloadJson,
    );
    // CRITICAL: Sign with CURRENT private key, not new one!
    // Server still has current public key and needs to verify this signature first
    final signature = signedContext.privateKey.createSignature(signaturePayload);

    final request = DeviceSignedRequest<UpdatePublicKeyPayload>(
      deviceId: signedContext.deviceId,
      signature: signature,
      data: payload,
    );

    debugPrint('=== Update Public Key Request ===');
    debugPrint('DeviceId: ${signedContext.deviceId}');
    debugPrint('Signature Payload: $signaturePayload');
    debugPrint('CURRENT PrivateKey (signing): ${signedContext.privateKey.toString()}');
    debugPrint('CURRENT PublicKey: ${signedContext.privateKey.publicKey.toString()}');
    debugPrint('NEW PrivateKey: ${newPrivateKey.toString()}');
    debugPrint('NEW PublicKey: ${newPublicKey.toString()}');
    debugPrint('Signature: $signature');
    debugPrint('Request Body: ${json.encode(request.toJson((data) => data?.toJson()))}');

    final response = await http.post(
      Uri.parse('${_settings.backendUrl}/api/devices/update-public-key'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson((data) => data?.toJson())),
    );

    debugPrint('=== Update Public Key Response ===');
    debugPrint('Status: ${response.statusCode}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint('Error Body: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = DeviceApiResponse<void>.fromJson(body);
      await _handleDeviceApiResponse(
        apiResponse,
        privateKeyOverride: newPrivateKey.toString(),
      );
      return apiResponse;
    }

    return null;
  }

  Future<_SignedContext?> _getSignedContext() async {
    final module = await _db.getModule();
    final device = await _db.getDevice();
    if (module == null || module.privateKey == null || device == null) {
      return null;
    }

    // Use moduleId from Module table (the source of truth)
    final moduleId = module.id.toString();
    if (moduleId.isEmpty || device.deviceId.isEmpty) {
      debugPrint(
        'Missing required IDs: moduleId=$moduleId, deviceId=${device.deviceId}',
      );
      return null;
    }

    final privateKey = RSAPrivateKey.fromPEM(module.privateKey!);
    return _SignedContext(
      moduleId: moduleId,
      deviceId: device.deviceId,
      privateKey: privateKey,
    );
  }

  /// Build standardized signature payload
  /// Format: deviceId|dataJson if data exists and is not empty
  /// Empty lists, objects, or null => just deviceId
  String _buildDeviceSignaturePayload(
    String deviceId,
    Map<String, dynamic> data,
  ) {
    // Treat null or empty maps as no data
    if (data.isEmpty) {
      return deviceId;
    }
    final dataJson = json.encode(data);
    return '$deviceId|$dataJson';
  }

  Future<void> _handleDeviceApiResponse<T>(
    DeviceApiResponse<T> response, {
    String? privateKeyOverride,
  }) async {
    // Track if we need to notify listeners (only for significant changes)
    bool shouldNotify = false;
    bool isFreshActivation = false;

    // Check if this is a fresh device registration (new deviceId)
    if (response.data is DeviceDTO) {
      final device = response.data as DeviceDTO;
      final existingDevice = await _db.getDevice();
      
      // If device exists but deviceId is different, this is a fresh activation
      if (existingDevice != null && existingDevice.deviceId != device.deviceId) {
        isFreshActivation = true;
        debugPrint('🔄 Fresh device activation detected. Clearing all data...');
        await _db.clearAllData();
        _notificationService.showInfo('Starting fresh activation...');
      }
    }

    // Process module information
    if (response.module != null) {
      await _db.saveModule(response.module!, privateKey: privateKeyOverride);
      await _applyModuleSubtype(response.module!.subType);
      shouldNotify = true;
      
      // Check for expiration warning (15 days or less)
      await _checkExpirationWarning(response.module!);
    } else if (privateKeyOverride != null) {
      await _db.updateModulePrivateKey(privateKeyOverride);
      shouldNotify = true;
    }

    // Process device data
    if (response.data is DeviceDTO) {
      final device = response.data as DeviceDTO;
      final moduleId = response.module?.id?.toString();
      
      if (moduleId == null || moduleId.isEmpty) {
        debugPrint(
          'Warning: Device registration response missing module.id. Using fallback from database.',
        );
        final existingModule = await _db.getModule();
        final fallbackModuleId = existingModule!.id.toString();
        await _db.saveDevice(device, moduleId: fallbackModuleId);
      } else {
        await _db.saveDevice(device, moduleId: moduleId);
      }
      await _settings.updateDeviceRole(_mapDeviceRole(device.deviceType));
      shouldNotify = true;
    }

    // Process device status
    if (response.status != null) {
      final currentDevice = await _db.getDevice();
      final currentStatus = currentDevice?.activationStatus;
      final currentMultiUser = currentDevice?.supportMultiUsers;
      
      final newStatus = response.status!.isActive
          ? ActivationStatus.ACTIVE
          : ActivationStatus.INACTIVE;
      final newMultiUser = response.status!.supportMultiUsers;
      
      // Update device status
      await _db.updateDeviceLocal(
        activationStatus: newStatus,
        supportMultiUsers: newMultiUser,
      );
      
      // Handle activation status change
      if (currentStatus != newStatus) {
        shouldNotify = true;
        if (!response.status!.isActive) {
          _notificationService.showError(
            'Device has been deactivated. Please contact support.',
          );
          debugPrint('⚠️ Device deactivated by server');
        } else {
          _notificationService.showSuccess('Device is now active');
          debugPrint('✅ Device activated by server');
        }
      }
      
      // Handle multi-user support change
      if (currentMultiUser != null && currentMultiUser != newMultiUser) {
        if (newMultiUser) {
          _notificationService.showInfo(
            'Multi-user support has been enabled',
          );
          debugPrint('👥 Multi-user support enabled');
        } else {
          _notificationService.showWarning(
            'Multi-user support has been disabled',
          );
          debugPrint('👤 Multi-user support disabled');
        }
      }
      
      // Show sync requirement message if needed
      if (response.status!.isSyncRequired) {
        debugPrint('🔄 Sync required by server');
      }
    }

    // Process commands (placeholder for future implementation)
    if (response.commands.isNotEmpty) {
      debugPrint('📋 Received ${response.commands.length} commands');
      // TODO: Process commands when command handling is implemented
    }

    // Only refresh and notify if there was a significant change
    if (shouldNotify || isFreshActivation) {
      await _refreshActivationState();
    }
  }

  /// Check if module expiration is close and show warning
  Future<void> _checkExpirationWarning(ModuleResponse module) async {
    if (module.expirationDate == null) return;
    
    final now = DateTime.now();
    final daysUntilExpiration = module.expirationDate!.difference(now).inDays;
    
    // Only warn if within 15 days and haven't warned in the last 24 hours
    if (daysUntilExpiration <= 15 && daysUntilExpiration > 0) {
      final lastWarning = _lastExpirationWarning;
      if (lastWarning == null || now.difference(lastWarning).inHours >= 24) {
        _lastExpirationWarning = now;
        
        final message = daysUntilExpiration == 1
            ? 'Your subscription expires tomorrow!'
            : 'Your subscription expires in $daysUntilExpiration days';
        
        _notificationService.showWarning(message);
        debugPrint('⚠️ Expiration warning: $daysUntilExpiration days remaining');
      }
    } else if (daysUntilExpiration <= 0) {
      _notificationService.showError('Your subscription has expired!');
      debugPrint('❌ Subscription expired');
    }
  }

  DeviceRole _mapDeviceRole(String? deviceType) {
    if (deviceType == 'ADMIN') return DeviceRole.ADMIN;
    return DeviceRole.NORMAL;
  }

  Future<void> _applyModuleSubtype(ModuleSubtype? subType) async {
    if (subType == null) return;

    switch (subType) {
      case ModuleSubtype.CLINIC_INVENTORY:
        await _settings.updateDeviceType(DeviceType.CLINIC_INVENTORY);
        break;
      case ModuleSubtype.PHARMACY_RETAIL:
        await _settings.updateDeviceType(DeviceType.PHARMACY_RETAIL);
        break;
      case ModuleSubtype.PHARMACY_WHOLESALE:
        await _settings.updateDeviceType(DeviceType.PHARMACY_WHOLESALE);
        break;
      case ModuleSubtype.CLINIC:
      case ModuleSubtype.HOSPITAL:
        break;
    }
  }
}

class _SignedContext {
  final String moduleId;
  final String deviceId;
  final RSAPrivateKey privateKey;

  _SignedContext({
    required this.moduleId,
    required this.deviceId,
    required this.privateKey,
  });
}
