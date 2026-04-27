import 'package:flutter/material.dart';

/// GraceMatch Brand Color System
/// Inspired by luxury matrimony aesthetics — deep charcoals, warm golds, Telugu cultural warmth
class AppColors {
  AppColors._();

  // ─── Background Palette ───────────────────────────────────────
  static const Color background = Color(0xFF0A0A0F);       // Near-black charcoal
  static const Color surface = Color(0xFF13131A);          // Elevated surface
  static const Color surfaceElevated = Color(0xFF1C1C26);  // Cards/panels
  static const Color surfaceHighest = Color(0xFF252535);   // Modals/sheets

  // ─── Brand Accent — Warm Gold ─────────────────────────────────
  static const Color gold = Color(0xFFC9A96E);             // Primary gold
  static const Color goldLight = Color(0xFFDFC08A);        // Light gold (hover/glow)
  static const Color goldDark = Color(0xFF9E7A47);         // Dark gold (pressed)
  static const Color goldSubtle = Color(0x33C9A96E);       // Gold with 20% opacity (backgrounds)
  static const Color goldMild = Color(0x66C9A96E);         // Gold with 40% opacity (borders)

  // ─── Text Colors ──────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF5EDD8);      // Warm cream white
  static const Color textSecondary = Color(0xFFB8A99A);    // Muted warm gray
  static const Color textTertiary = Color(0xFF6B5E52);     // Very muted, hints
  static const Color textOnGold = Color(0xFF0A0A0F);       // Dark text on gold buttons

  // ─── Accent Colors ────────────────────────────────────────────
  static const Color rose = Color(0xFFE8B4A0);             // Dusty rose (female accents)
  static const Color roseDark = Color(0xFFD4876B);         // Deeper rose
  static const Color roseSubtle = Color(0x33E8B4A0);       // Rose subtle bg

  static const Color blessing = Color(0xFF7FB69A);         // Trust badge / verified green
  static const Color blessingSubtle = Color(0x337FB69A);   // Verified bg

  static const Color cross = Color(0xFF6B8FBD);            // Christian cross accent blue
  static const Color crossSubtle = Color(0x336B8FBD);      // Cross bg

  // ─── System Colors ────────────────────────────────────────────
  static const Color success = Color(0xFF5DBB8A);
  static const Color error = Color(0xFFE05A5A);
  static const Color warning = Color(0xFFE0A24E);
  static const Color info = Color(0xFF5A8AE0);

  // ─── Gradient Definitions ─────────────────────────────────────
  static const LinearGradient goldenGradient = LinearGradient(
    colors: [Color(0xFFC9A96E), Color(0xFFE8C98A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0A0F), Color(0xFF13131A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient profileCardGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC0A0A0F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.3, 1.0],
  );

  static const LinearGradient roseGradient = LinearGradient(
    colors: [Color(0xFFE8B4A0), Color(0xFFD4876B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const RadialGradient goldGlow = RadialGradient(
    colors: [Color(0x40C9A96E), Colors.transparent],
    radius: 0.8,
  );

  // ─── Card border gradients ─────────────────────────────────────
  static const LinearGradient cardBorderGradient = LinearGradient(
    colors: [Color(0x80C9A96E), Color(0x20C9A96E), Color(0x00C9A96E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
