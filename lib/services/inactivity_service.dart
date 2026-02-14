import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service to track user inactivity and trigger logout after a specified duration
class InactivityService extends ChangeNotifier {
  static const Duration defaultTimeout = Duration(minutes: 20);
  
  late Timer _inactivityTimer;
  final Duration _timeout;
  late VoidCallback _onTimeout;
  bool _isActive = false;

  InactivityService({Duration timeout = defaultTimeout}) : _timeout = timeout;

  bool get isActive => _isActive;
  Duration get timeout => _timeout;

  /// Initialize the inactivity tracking with a callback
  void initialize(VoidCallback onTimeout) {
    _onTimeout = onTimeout;
    _isActive = true;
    _resetTimer();
  }

  /// Reset the inactivity timer (call this on user activity)
  void recordActivity() {
    if (!_isActive) return;
    
    _inactivityTimer.cancel();
    _resetTimer();
  }

  /// Reset the inactivity timer
  void _resetTimer() {
    _inactivityTimer = Timer(_timeout, () {
      debugPrint('Inactivity timeout reached - logging out user');
      _onTimeout();
    });
  }

  /// Stop inactivity tracking
  void stop() {
    _isActive = false;
    _inactivityTimer.cancel();
  }

  /// Resume inactivity tracking
  void resume() {
    if (_isActive) return;
    _isActive = true;
    _resetTimer();
  }

  @override
  void dispose() {
    if (_inactivityTimer.isActive) {
      _inactivityTimer.cancel();
    }
    super.dispose();
  }
}
