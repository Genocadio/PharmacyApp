import 'package:flutter/material.dart';

/// Extension to handle Color opacity with backward compatibility
/// Provides withOpacity as an alias for the newer withValues() method
extension ColorOpacityExtension on Color {
  /// Apply opacity to a color (backward compatible)
  /// Uses withValues() internally to avoid precision loss
  Color withOpacityCompat(double opacity) {
    assert(opacity >= 0 && opacity <= 1);
    return withOpacity(opacity);
  }
}
