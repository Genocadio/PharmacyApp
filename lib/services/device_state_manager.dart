import 'package:flutter/foundation.dart';
import 'package:nexxpharma/data/database.dart';
import 'package:nexxpharma/data/tables.dart';
import 'package:nexxpharma/services/settings_service.dart';
import 'package:nexxpharma/services/activation_service.dart';

/// Manages and notifies about device state changes (type, activation, subtype, etc)
/// This service consolidates all device configuration changes into a single notification source
class DeviceStateManager extends ChangeNotifier {
  final AppDatabase _database;
  final SettingsService _settingsService;
  final ActivationService _activationService;

  DeviceType? _deviceType;
  ActivationStatus? _activationStatus;
  ModuleSubtype? _moduleSubtype;
  bool? _isActivated;

  DeviceStateManager(
    this._database,
    this._settingsService,
    this._activationService,
  ) {
    _init();
  }

  /// Initialize by loading current device state and setting up listeners
  void _init() {
    _listenerSetup();
    _loadDeviceState();
  }

  void _listenerSetup() {
    // Listen to settings changes (device type, device role)
    _settingsService.addListener(_onSettingsChanged);

    // Listen to activation changes (status, module subtype)
    _activationService.addListener(_onActivationChanged);
  }

  /// Load current device state from database
  Future<void> _loadDeviceState() async {
    final device = await _database.getDevice();
    final module = await _database.getModule();

    _deviceType = device?.deviceType == null 
        ? null
        : _parseDeviceType(device!.deviceType);
    _activationStatus = device?.activationStatus ?? module?.activationStatus;
    _moduleSubtype = module?.subType;
    _isActivated = _activationService.activationState;

    notifyListeners();
  }

  /// Parse device type string from database
  DeviceType? _parseDeviceType(String? typeStr) {
    switch (typeStr) {
      case 'PHARMACY_RETAIL':
        return DeviceType.PHARMACY_RETAIL;
      case 'PHARMACY_WHOLESALE':
        return DeviceType.PHARMACY_WHOLESALE;
      case 'CLINIC_INVENTORY':
        return DeviceType.CLINIC_INVENTORY;
      default:
        return null;
    }
  }

  /// Called when settings change (device type, device role, etc.)
  void _onSettingsChanged() {
    final newDeviceType = _settingsService.deviceType;
    if (newDeviceType != _deviceType) {
      _deviceType = newDeviceType;
      notifyListeners();
    }
  }

  /// Called when activation status or module configuration changes
  Future<void> _onActivationChanged() async {
    final device = await _database.getDevice();
    final module = await _database.getModule();

    final newStatus = device?.activationStatus ?? module?.activationStatus;
    final newSubtype = module?.subType;
    final newActivated = _activationService.activationState;

    bool changed = false;

    if (newStatus != _activationStatus) {
      _activationStatus = newStatus;
      changed = true;
    }

    if (newSubtype != _moduleSubtype) {
      _moduleSubtype = newSubtype;
      changed = true;
    }

    if (newActivated != _isActivated) {
      _isActivated = newActivated;
      changed = true;
    }

    if (changed) {
      notifyListeners();
    }
  }

  // Getters for current state
  DeviceType? get deviceType => _deviceType;
  ActivationStatus? get activationStatus => _activationStatus;
  ModuleSubtype? get moduleSubtype => _moduleSubtype;
  bool? get isActivated => _isActivated;

  bool get isClinicInventory => _deviceType == DeviceType.CLINIC_INVENTORY;
  bool get isPharmacyRetail => _deviceType == DeviceType.PHARMACY_RETAIL;
  bool get isPharmacyWholesale => _deviceType == DeviceType.PHARMACY_WHOLESALE;
  bool get isDeviceActive => _activationStatus == ActivationStatus.ACTIVE;
  bool get isDeviceInactive => _activationStatus == ActivationStatus.INACTIVE;
  bool get isDevicePending => _activationStatus == ActivationStatus.PENDING;

  @override
  void dispose() {
    _settingsService.removeListener(_onSettingsChanged);
    _activationService.removeListener(_onActivationChanged);
    super.dispose();
  }
}
