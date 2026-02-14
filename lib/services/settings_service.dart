import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexxpharma/data/tables.dart';

enum InvoicePaperSize { a4, mm80, mm57 }

class SettingsService extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _backendUrlKey = 'backend_url';
  static const String _productionApiUrl = 'https://api.nexxserve.tech/nexxmed';
  static const String _devApiUrl = 'http://localhost:8080';
  static const String _lastSyncCursorKey = 'last_sync_cursor';
  static const String _lastSyncTimeKey = 'last_sync_time';
  static const String _invoicePaperSizeKey = 'invoice_paper_size';
  static const String _hasCompletedInitialSyncKey =
      'has_completed_initial_sync';
  static const String _syncTokenKey = 'sync_token';
  static const String _syncTokenExpiryKey = 'sync_token_expiry';
  static const String _deviceTypeKey = 'device_type';
  static const String _deviceRoleKey = 'device_role';
  static const String _lastDeviceStatusAtKey = 'last_device_status_at';
  static const String _lastPublicKeyRotationAtKey =
      'last_public_key_rotation_at';
  static const String _lastDeviceDetailsAtKey = 'last_device_details_at';

  final SharedPreferences _prefs;

  ThemeMode _themeMode;
  String _backendUrl;
  int _lastSyncCursor;
  DateTime? _lastSyncTime;
  InvoicePaperSize? _invoicePaperSize;
  bool _hasCompletedInitialSync;
  String? _syncToken;
  DateTime? _syncTokenExpiry;
  DeviceType _deviceType;
  DeviceRole _deviceRole;
  DateTime? _lastDeviceStatusAt;
  DateTime? _lastPublicKeyRotationAt;
  DateTime? _lastDeviceDetailsAt;

  SettingsService(this._prefs)
    : _themeMode = _loadThemeMode(_prefs),
      _backendUrl = _loadBackendUrl(_prefs),
      _lastSyncCursor = _prefs.getInt(_lastSyncCursorKey) ?? 0,
      _lastSyncTime = _prefs.getString(_lastSyncTimeKey) != null
          ? DateTime.parse(_prefs.getString(_lastSyncTimeKey)!)
          : null,
      _invoicePaperSize = _loadInvoicePaperSize(_prefs),
      _hasCompletedInitialSync =
          _prefs.getBool(_hasCompletedInitialSyncKey) ?? false,
      _syncToken = _prefs.getString(_syncTokenKey),
      _syncTokenExpiry = _prefs.getString(_syncTokenExpiryKey) != null
          ? DateTime.parse(_prefs.getString(_syncTokenExpiryKey)!)
          : null,
        _deviceType = _loadDeviceType(_prefs),
        _deviceRole = _loadDeviceRole(_prefs),
        _lastDeviceStatusAt = _prefs.getString(_lastDeviceStatusAtKey) != null
          ? DateTime.parse(_prefs.getString(_lastDeviceStatusAtKey)!)
          : null,
        _lastPublicKeyRotationAt =
          _prefs.getString(_lastPublicKeyRotationAtKey) != null
            ? DateTime.parse(_prefs.getString(_lastPublicKeyRotationAtKey)!)
            : null,
        _lastDeviceDetailsAt = _prefs.getString(_lastDeviceDetailsAtKey) != null
          ? DateTime.parse(_prefs.getString(_lastDeviceDetailsAtKey)!)
          : null;

  SharedPreferences get prefs => _prefs;

  ThemeMode get themeMode => _themeMode;
  String get backendUrl => _backendUrl;
  int get lastSyncCursor => _lastSyncCursor;
  DateTime? get lastSyncTime => _lastSyncTime;
  InvoicePaperSize get invoicePaperSize =>
      _invoicePaperSize ?? InvoicePaperSize.a4;
  bool get hasCompletedInitialSync => _hasCompletedInitialSync;
  String? get syncToken => _syncToken;
  DateTime? get syncTokenExpiry => _syncTokenExpiry;
  DeviceType get deviceType => _deviceType;
  DeviceRole get deviceRole => _deviceRole;
  DateTime? get lastDeviceStatusAt => _lastDeviceStatusAt;
  DateTime? get lastPublicKeyRotationAt => _lastPublicKeyRotationAt;
  DateTime? get lastDeviceDetailsAt => _lastDeviceDetailsAt;

  static String _loadBackendUrl(SharedPreferences prefs) {
    if (kDebugMode) {
      // In debug mode, allow custom URLs from storage
      return prefs.getString(_backendUrlKey) ?? _devApiUrl;
    } else {
      // In production, always use the production API URL
      return _productionApiUrl;
    }
  }

  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final mode = prefs.getString(_themeModeKey);
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static InvoicePaperSize? _loadInvoicePaperSize(SharedPreferences prefs) {
    final size = prefs.getString(_invoicePaperSizeKey);
    switch (size) {
      case 'a4':
        return InvoicePaperSize.a4;
      case 'mm80':
        return InvoicePaperSize.mm80;
      case 'mm57':
        return InvoicePaperSize.mm57;
      default:
        return null;
    }
  }

  static DeviceType _loadDeviceType(SharedPreferences prefs) {
    final deviceType = prefs.getString(_deviceTypeKey);
    switch (deviceType) {
      case 'PHARMACY_WHOLESALE':
        return DeviceType.PHARMACY_WHOLESALE;
      case 'CLINIC_INVENTORY':
        return DeviceType.CLINIC_INVENTORY;
      default:
        return DeviceType.PHARMACY_RETAIL;
    }
  }

  static DeviceRole _loadDeviceRole(SharedPreferences prefs) {
    final role = prefs.getString(_deviceRoleKey);
    switch (role) {
      case 'ADMIN':
        return DeviceRole.ADMIN;
      default:
        return DeviceRole.NORMAL;
    }
  }

  Future<void> updateDeviceType(DeviceType type) async {
    if (type == _deviceType) return;

    _deviceType = type;
    notifyListeners();

    String typeStr;
    switch (type) {
      case DeviceType.PHARMACY_RETAIL:
        typeStr = 'PHARMACY_RETAIL';
        break;
      case DeviceType.PHARMACY_WHOLESALE:
        typeStr = 'PHARMACY_WHOLESALE';
        break;
      case DeviceType.CLINIC_INVENTORY:
        typeStr = 'CLINIC_INVENTORY';
        break;
    }
    await _prefs.setString(_deviceTypeKey, typeStr);
  }

  Future<void> updateDeviceRole(DeviceRole role) async {
    if (role == _deviceRole) return;

    _deviceRole = role;
    notifyListeners();

    final roleStr = role == DeviceRole.ADMIN ? 'ADMIN' : 'NORMAL';
    await _prefs.setString(_deviceRoleKey, roleStr);
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;

    _themeMode = mode;
    notifyListeners();

    String modeStr;
    switch (mode) {
      case ThemeMode.light:
        modeStr = 'light';
        break;
      case ThemeMode.dark:
        modeStr = 'dark';
        break;
      case ThemeMode.system:
        modeStr = 'system';
        break;
    }
    await _prefs.setString(_themeModeKey, modeStr);
  }

  Future<void> updateInvoicePaperSize(InvoicePaperSize size) async {
    if (size == _invoicePaperSize) return;

    _invoicePaperSize = size;
    notifyListeners();

    String sizeStr;
    switch (size) {
      case InvoicePaperSize.a4:
        sizeStr = 'a4';
        break;
      case InvoicePaperSize.mm80:
        sizeStr = 'mm80';
        break;
      case InvoicePaperSize.mm57:
        sizeStr = 'mm57';
        break;
    }
    await _prefs.setString(_invoicePaperSizeKey, sizeStr);
  }

  Future<void> updateBackendUrl(String url) async {
    // Only allow updating backend URL in debug mode
    if (!kDebugMode) return;
    if (url == _backendUrl) return;
    _backendUrl = url;
    notifyListeners();
    await _prefs.setString(_backendUrlKey, url);
  }

  Future<void> updateSyncState(int cursor, DateTime time) async {
    _lastSyncCursor = cursor;
    _lastSyncTime = time;
    notifyListeners();
    await _prefs.setInt(_lastSyncCursorKey, cursor);
    await _prefs.setString(_lastSyncTimeKey, time.toIso8601String());
  }

  Future<void> setInitialSyncCompleted(bool value) async {
    _hasCompletedInitialSync = value;
    notifyListeners();
    await _prefs.setBool(_hasCompletedInitialSyncKey, value);
  }

  Future<void> setSyncToken(String? token, DateTime? expiry) async {
    _syncToken = token;
    _syncTokenExpiry = expiry;
    // We don't necessarily need to notifyListeners for token updates as it's internal
    // but it doesn't hurt.
    notifyListeners();
    if (token != null) {
      await _prefs.setString(_syncTokenKey, token);
    } else {
      await _prefs.remove(_syncTokenKey);
    }
    if (expiry != null) {
      await _prefs.setString(_syncTokenExpiryKey, expiry.toIso8601String());
    } else {
      await _prefs.remove(_syncTokenExpiryKey);
    }
  }

  Future<void> updateLastDeviceStatusAt(DateTime time) async {
    _lastDeviceStatusAt = time;
    notifyListeners();
    await _prefs.setString(_lastDeviceStatusAtKey, time.toIso8601String());
  }

  Future<void> updateLastPublicKeyRotationAt(DateTime time) async {
    _lastPublicKeyRotationAt = time;
    notifyListeners();
    await _prefs.setString(
      _lastPublicKeyRotationAtKey,
      time.toIso8601String(),
    );
  }

  Future<void> updateLastDeviceDetailsAt(DateTime time) async {
    _lastDeviceDetailsAt = time;
    notifyListeners();
    await _prefs.setString(_lastDeviceDetailsAtKey, time.toIso8601String());
  }

  Future<void> resetDeviceTracking() async {
    _lastDeviceStatusAt = null;
    _lastPublicKeyRotationAt = null;
    _lastDeviceDetailsAt = null;
    notifyListeners();
    await _prefs.remove(_lastDeviceStatusAtKey);
    await _prefs.remove(_lastPublicKeyRotationAtKey);
    await _prefs.remove(_lastDeviceDetailsAtKey);
  }

  Future<void> resetSync() async {
    _lastSyncCursor = 0;
    _lastSyncTime = null;
    _hasCompletedInitialSync = false;
    _syncToken = null;
    _syncTokenExpiry = null;
    notifyListeners();
    await _prefs.remove(_lastSyncCursorKey);
    await _prefs.remove(_lastSyncTimeKey);
    await _prefs.remove(_hasCompletedInitialSyncKey);
    await _prefs.remove(_syncTokenKey);
    await _prefs.remove(_syncTokenExpiryKey);
  }
}
