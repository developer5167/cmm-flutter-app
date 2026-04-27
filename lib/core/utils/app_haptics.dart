import 'package:flutter/services.dart';

/// Centralized haptic feedback utility for GraceMatch
/// Consistent tactile language across the whole app
class AppHaptics {
  AppHaptics._();

  /// Light tap — standard button tap, chip select
  static Future<void> light() => HapticFeedback.lightImpact();

  /// Medium tap — photo upload, card interaction
  static Future<void> medium() => HapticFeedback.mediumImpact();

  /// Heavy — match accepted, subscription unlocked, trust badge
  static Future<void> heavy() => HapticFeedback.heavyImpact();

  /// Selection changed — toggle, slider, picker
  static Future<void> selection() => HapticFeedback.selectionClick();

  /// Error — form error, rejected interest
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.heavyImpact();
  }

  /// Success burst — OTP verified, interest accepted, photo uploaded
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    await HapticFeedback.lightImpact();
  }

  /// Match celebration — the big moment!
  static Future<void> match() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    await HapticFeedback.lightImpact();
  }
}
