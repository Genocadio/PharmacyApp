import 'package:bcrypt/bcrypt.dart';

/// Utility class for secure password hashing and verification using bcrypt.
///
/// Bcrypt is a password hashing function designed to be slow and computationally
/// expensive, making it resistant to brute-force attacks. It automatically
/// handles salting, so each hash is unique even for the same password.
class PasswordHasher {
  // Cost factor for bcrypt (higher = more secure but slower)
  // 12 is a good balance between security and performance
  static const int _costFactor = 12;

  /// Hash a plain text password using bcrypt.
  ///
  /// Returns a bcrypt hash string that can be safely stored in the database.
  /// The hash includes the salt and cost factor, so no separate salt storage is needed.
  ///
  /// Example:
  /// ```dart
  /// final hash = PasswordHasher.hashPassword('myPassword123');
  /// // Returns something like: $2b$12$KIXxLVq8Zq5Z8Z8Z8Z8Z8O...
  /// ```
  static String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt(logRounds: _costFactor));
  }

  /// Verify a plain text password against a bcrypt hash.
  ///
  /// Returns `true` if the password matches the hash, `false` otherwise.
  /// This comparison is timing-safe to prevent timing attacks.
  ///
  /// Example:
  /// ```dart
  /// final isValid = PasswordHasher.verifyPassword('myPassword123', storedHash);
  /// if (isValid) {
  ///   // Password is correct
  /// }
  /// ```
  static bool verifyPassword(String password, String hash) {
    try {
      return BCrypt.checkpw(password, hash);
    } catch (e) {
      // If hash is invalid or corrupted, return false
      return false;
    }
  }

  /// Check if a string is a valid bcrypt hash.
  ///
  /// Returns `true` if the string appears to be a bcrypt hash.
  /// Bcrypt hashes start with $2a$, $2b$, or $2y$.
  static bool isValidHash(String hash) {
    return hash.startsWith(RegExp(r'\$2[aby]\$\d{2}\$'));
  }
}
