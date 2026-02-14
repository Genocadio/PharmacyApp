import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service to monitor internet connectivity and notify listeners
class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  bool _isConnected = false;
  bool _isChecking = false;
  Timer? _checkTimer;
  DateTime? _lastCheckTime;
  DateTime? _lastConnectedTime;
  DateTime? _lastDisconnectedTime;

  bool get isConnected => _isConnected;
  bool get isChecking => _isChecking;
  DateTime? get lastCheckTime => _lastCheckTime;
  DateTime? get lastConnectedTime => _lastConnectedTime;
  DateTime? get lastDisconnectedTime => _lastDisconnectedTime;

  /// Initialize the connectivity service with periodic checks
  void initialize() {
    // Check immediately
    checkConnectivity();
    
    // Then check every 30 seconds
    _checkTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      checkConnectivity();
    });
  }

  /// Check internet connectivity by making a simple HTTP request
  Future<void> checkConnectivity() async {
    if (_isChecking) return;

    _isChecking = true;
    _lastCheckTime = DateTime.now();
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));

      final wasConnected = _isConnected;
      _isConnected = response.statusCode == 200;

      if (_isConnected) {
        _lastConnectedTime = DateTime.now();
        
        // Fire connectivity restored event if was previously disconnected
        if (!wasConnected) {
          _onConnectivityRestored();
        }
      } else {
        if (wasConnected) {
          _lastDisconnectedTime = DateTime.now();
        }
      }
    } catch (e) {
      final wasConnected = _isConnected;
      _isConnected = false;
      
      if (wasConnected) {
        _lastDisconnectedTime = DateTime.now();
      }
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  /// Called when connectivity is restored
  void _onConnectivityRestored() {
    if (kDebugMode) {
      print('Internet connectivity restored at ${DateTime.now()}');
    }
  }

  /// Force a connectivity check (useful after network operations fail)
  Future<bool> forceCheck() async {
    await checkConnectivity();
    return _isConnected;
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }
}
