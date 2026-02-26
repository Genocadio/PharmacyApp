import 'package:flutter/foundation.dart';
import 'package:nexxpharma/services/dto/user_dto.dart';
import 'package:nexxpharma/services/user_service.dart';
import 'package:nexxpharma/services/exceptions/service_exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// Service to manage authentication state across the application
class AuthService extends ChangeNotifier {
  final UserService _userService;
  final SharedPreferences _prefs;
  UserDTO? _currentUser;
  DateTime? _lastActivityTime;
  Timer? _sessionCheckTimer;
  static const _sessionTimeout = Duration(minutes: 20);
  static const _sessionCheckInterval = Duration(seconds: 10); // Check every 10 seconds
  static const _sessionWarningThreshold = Duration(minutes: 2); // Warn 2 minutes before expiry
  static const _keyUserId = 'auth_user_id';
  static const _keyLastActivity = 'auth_last_activity';
  
  bool _sessionWarningShown = false; // Track if warning has been shown

  UserService get userService => _userService;
  bool _isLoading = false;
  String? _error;
  bool? _hasUsers;
  String? _pendingPasswordSetupIdentifier;

  AuthService(this._userService, this._prefs) {
    _init();
  }

  Future<void> _init() async {
    await refreshHasUsers();
    
    // Restore session if exists
    await _restoreSession();
    
    // Start session monitoring if user is authenticated
    if (_currentUser != null) {
      _startSessionMonitoring();
    }
    
    notifyListeners();
  }
  
  /// Restore session from persistent storage
  Future<void> _restoreSession() async {
    try {
      final userId = _prefs.getString(_keyUserId);
      final lastActivityMs = _prefs.getInt(_keyLastActivity);
      
      if (userId != null && lastActivityMs != null) {
        final lastActivity = DateTime.fromMillisecondsSinceEpoch(lastActivityMs);
        final timeSinceLastActivity = DateTime.now().difference(lastActivity);
        
        // Check if session is still valid (less than 20 minutes)
        if (timeSinceLastActivity <= _sessionTimeout) {
          // Restore user from database
          _currentUser = await _userService.getUserById(userId);
          _lastActivityTime = DateTime.now();
          debugPrint('Session restored for user: ${_currentUser?.names}');
        } else {
          // Session expired, clear saved data
          debugPrint('Session expired, clearing saved data');
          await _clearSessionData();
        }
      }
    } catch (e) {
      debugPrint('Error restoring session: $e');
      await _clearSessionData();
    }
  }
  
  /// Save session to persistent storage
  Future<void> _saveSession() async {
    if (_currentUser != null && _lastActivityTime != null) {
      await _prefs.setString(_keyUserId, _currentUser!.id);
      await _prefs.setInt(_keyLastActivity, _lastActivityTime!.millisecondsSinceEpoch);
    }
  }
  
  /// Clear session from persistent storage
  Future<void> _clearSessionData() async {
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyLastActivity);
  }

  /// Start monitoring session for expiration
  void _startSessionMonitoring() {
    // Cancel any existing timer first
    _sessionCheckTimer?.cancel();
    _sessionWarningShown = false; // Reset warning flag
    
    // Create a new periodic timer that checks session every 10 seconds
    _sessionCheckTimer = Timer.periodic(_sessionCheckInterval, (_) {
      if (_currentUser == null) return;
      
      final timeSinceLastActivity = DateTime.now().difference(_lastActivityTime!);
      
      // If completely expired, logout
      if (isSessionExpired) {
        debugPrint('Session expired during active monitoring - logging out');
        logout(); // This will also cancel the timer
      }
      // If approaching expiry (2 minutes left), show warning once
      else if (timeSinceLastActivity > (_sessionTimeout - _sessionWarningThreshold) && !_sessionWarningShown) {
        _sessionWarningShown = true;
        debugPrint('Session expiring soon - notifying user');
        notifyListeners(); // Notify UI that warning should be shown
      }
      // If activity was resumed, reset warning
      else if (timeSinceLastActivity < (_sessionTimeout - _sessionWarningThreshold)) {
        _sessionWarningShown = false;
      }
    });
  }

  /// Stop monitoring session (called on logout)
  void _stopSessionMonitoring() {
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer = null;
  }

  UserDTO? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool? get hasUsers => _hasUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get pendingPasswordSetupIdentifier => _pendingPasswordSetupIdentifier;
  bool get requiresPasswordSetup => _pendingPasswordSetupIdentifier != null;

  Future<void> refreshHasUsers() async {
    final count = await _userService.getUsersCount();
    _hasUsers = count > 0;
    notifyListeners();
  }
  
  /// Get time remaining before session expires (in seconds)
  int? get sessionTimeRemaining {
    if (_lastActivityTime == null || _currentUser == null) return null;
    final timeSinceLastActivity = DateTime.now().difference(_lastActivityTime!);
    final remainingTime = _sessionTimeout - timeSinceLastActivity;
    return remainingTime.inSeconds > 0 ? remainingTime.inSeconds : 0;
  }
  
  /// Check if session warning should be shown
  bool get shouldShowSessionWarning => _sessionWarningShown;
  
  /// Check if the session has expired (more than 20 minutes of inactivity)
  bool get isSessionExpired {
    if (_lastActivityTime == null || _currentUser == null) {
      return false;
    }
    final timeSinceLastActivity = DateTime.now().difference(_lastActivityTime!);
    return timeSinceLastActivity > _sessionTimeout;
  }
  
  /// Update the last activity time to keep session alive
  void updateActivity() {
    if (_currentUser != null) {
      _lastActivityTime = DateTime.now();
      _sessionWarningShown = false; // Reset warning when user is active
      _saveSession(); // Persist activity timestamp
      notifyListeners(); // Notify UI that session is refreshed
    }
  }
  
  /// Check session validity when app resumes
  Future<bool> checkSessionValidity() async {
    if (isSessionExpired) {
      await logout();
      return false;
    }
    updateActivity();
    return true;
  }

  /// Clear any existing error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Log in a user
  Future<bool> login(String identifier, String password) async {
    _isLoading = true;
    _error = null;
    _pendingPasswordSetupIdentifier = null;
    notifyListeners();

    try {
      final normalizedIdentifier = identifier.trim();
      final normalizedPassword = password.trim();

      if (normalizedPassword.isEmpty) {
        final needsSetup = await _userService.workerNeedsPasswordSetup(
          normalizedIdentifier,
        );

        if (needsSetup) {
          _pendingPasswordSetupIdentifier = normalizedIdentifier;
          _isLoading = false;
          notifyListeners();
          return false;
        }

        _error = 'Please enter your password';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final loginDTO = LoginDTO(identifier: identifier, password: password);
      _currentUser = await _userService.login(loginDTO);
      _lastActivityTime = DateTime.now(); // Initialize session time
      await _saveSession(); // Persist session
      _startSessionMonitoring(); // Start checking for expiration
      await refreshHasUsers();
      _isLoading = false;
      notifyListeners();
      return true;
    } on ValidationException catch (e) {
      if (e.message == 'PASSWORD_SETUP_REQUIRED') {
        _pendingPasswordSetupIdentifier = identifier.trim();
        _error = null;
      } else {
        _error = e.message;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createPasswordAndLogin(String password) async {
    final identifier = _pendingPasswordSetupIdentifier;
    if (identifier == null) {
      _error = 'No worker selected for password setup';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _userService.createPasswordForWorker(
        identifier: identifier,
        password: password,
      );
      _pendingPasswordSetupIdentifier = null;
      _lastActivityTime = DateTime.now();
      await _saveSession();
      _startSessionMonitoring();
      await refreshHasUsers();
      _isLoading = false;
      notifyListeners();
      return true;
    } on ValidationException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Failed to create password';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Register a new user
  Future<bool> register(UserCreateDTO createDTO) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _userService.register(createDTO);
      _lastActivityTime = DateTime.now(); // Initialize session time
      await _saveSession(); // Persist session
      _startSessionMonitoring(); // Start checking for expiration
      _hasUsers = true;
      _pendingPasswordSetupIdentifier = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ValidationException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update the current user's profile
  Future<bool> updateProfile({
    String? names,
    String? email,
    String? phoneNumber,
    String? password,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updateDTO = UserUpdateDTO(
        names: names,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );

      _currentUser = await _userService.updateUser(_currentUser!.id, updateDTO);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ValidationException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Log out the current user
  Future<void> logout() async {
    _stopSessionMonitoring(); // Stop the session check timer
    _currentUser = null;
    _lastActivityTime = null;
    _error = null;
    _pendingPasswordSetupIdentifier = null;
    await _clearSessionData(); // Clear persisted session
    notifyListeners();
  }
}
