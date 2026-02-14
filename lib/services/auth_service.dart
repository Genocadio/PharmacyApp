import 'package:flutter/foundation.dart';
import 'package:nexxpharma/services/dto/user_dto.dart';
import 'package:nexxpharma/services/user_service.dart';
import 'package:nexxpharma/services/exceptions/service_exceptions.dart';

/// Service to manage authentication state across the application
class AuthService extends ChangeNotifier {
  final UserService _userService;
  UserDTO? _currentUser;
  DateTime? _lastActivityTime;
  static const _sessionTimeout = Duration(minutes: 20);

  UserService get userService => _userService;
  bool _isLoading = false;
  String? _error;
  bool? _hasUsers;

  AuthService(this._userService) {
    _init();
  }

  Future<void> _init() async {
    final count = await _userService.getUsersCount();
    _hasUsers = count > 0;
    notifyListeners();
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
    }
  }
  
  /// Check session validity when app resumes
  bool checkSessionValidity() {
    if (isSessionExpired) {
      logout();
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
  void logout() {
    _currentUser = null;
    _lastActivityTime = null;
    _error = null;
    notifyListeners();
  }
}
