import 'package:flutter/foundation.dart';
import 'package:nexxpharma/services/dto/user_dto.dart';
import 'package:nexxpharma/services/user_service.dart';
import 'package:nexxpharma/services/exceptions/service_exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage authentication state across the application
class AuthService extends ChangeNotifier {
  final UserService _userService;
  final SharedPreferences _prefs;
  UserDTO? _currentUser;
  DateTime? _lastActivityTime;
  static const _sessionTimeout = Duration(minutes: 20);
  static const _keyUserId = 'auth_user_id';
  static const _keyLastActivity = 'auth_last_activity';

  UserService get userService => _userService;
  bool _isLoading = false;
  String? _error;
  bool? _hasUsers;

  AuthService(this._userService, this._prefs) {
    _init();
  }

  Future<void> _init() async {
    final count = await _userService.getUsersCount();
    _hasUsers = count > 0;
    
    // Restore session if exists
    await _restoreSession();
    
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

  UserDTO? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool? get hasUsers => _hasUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
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
      _saveSession(); // Persist activity timestamp
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
    notifyListeners();

    try {
      final loginDTO = LoginDTO(identifier: identifier, password: password);
      _currentUser = await _userService.login(loginDTO);
      _lastActivityTime = DateTime.now(); // Initialize session time
      await _saveSession(); // Persist session
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

  /// Register a new user
  Future<bool> register(UserCreateDTO createDTO) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _userService.register(createDTO);
      _lastActivityTime = DateTime.now(); // Initialize session time
      await _saveSession(); // Persist session
      _hasUsers = true;
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
    _currentUser = null;
    _lastActivityTime = null;
    _error = null;
    await _clearSessionData(); // Clear persisted session
    notifyListeners();
  }
}
