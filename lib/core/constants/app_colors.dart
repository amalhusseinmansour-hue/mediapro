import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Inspired by the neon logo
  static const Color neonCyan = Color(0xFF00E5FF); // Bright cyan
  static const Color neonBlue = Color(0xFF00BCD4); // Cyan blue
  static const Color neonPurple = Color(0xFF7C4DFF); // Purple
  static const Color neonMagenta = Color(0xFFD500F9); // Magenta
  static const Color neonPink = Color(0xFFE91E63); // Pink

  // Dark Theme Colors
  static const Color darkBg = Color(0xFF0A0A0A); // Pure dark
  static const Color darkCard = Color(0xFF1A1A1A); // Card background
  static const Color darkCardLight = Color(0xFF252525); // Lighter card
  static const Color darkBorder = Color(0xFF333333); // Border color

  // Gradient Colors
  static const LinearGradient neonGradient = LinearGradient(
    colors: [neonCyan, neonPurple, neonMagenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanPurpleGradient = LinearGradient(
    colors: [neonCyan, neonPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleMagentaGradient = LinearGradient(
    colors: [neonPurple, neonMagenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanMagentaGradient = LinearGradient(
    colors: [neonCyan, neonMagenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // White
  static const Color textSecondary = Color(0xFFB0B0B0); // Gray
  static const Color textLight = Color(0xFF808080); // Light gray
  static const Color textOnNeon = Color(
    0xFF000000,
  ); // Black for neon backgrounds

  // Status Colors
  static const Color success = Color(0xFF00E676); // Neon green
  static const Color warning = Color(0xFFFFC107); // Amber
  static const Color error = Color(0xFFFF1744); // Neon red
  static const Color info = Color(0xFF00E5FF); // Cyan

  // Shadow Colors
  static const Color neonCyanShadow = Color(0x8000E5FF);
  static const Color neonPurpleShadow = Color(0x807C4DFF);
  static const Color neonMagentaShadow = Color(0x80D500F9);

  // Legacy colors (kept for compatibility)
  static const Color primaryPurple = neonPurple;
  static const Color lightPurple = Color(0xFFA78BFA);
  static const Color darkPurple = Color(0xFF6D28D9);
  static const Color primaryPink = neonPink;
  static const Color lightPink = Color(0xFFF9A8D4);
  static const Color darkPink = Color(0xFFDB2777);
  static const Color offWhite = Color(0xFFFAFAFA);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color cardBackground = darkCard;
  static const LinearGradient primaryGradient = neonGradient;
  static const LinearGradient lightGradient = cyanPurpleGradient;
  static const Color textOnPurple = textPrimary;
  static const Color border = darkBorder;
  static const Color divider = darkBorder;
  static const Color shadow = Color(0x4A000000);
  static const Color purpleShadow = neonPurpleShadow;

  // Additional aliases for compatibility
  static const Color purple = neonPurple;
  static const Color darkBackground = darkBg;

  // Missing colors for ayrshare_post_screen and other screens
  static const Color cardDark = darkCard;
  static const Color backgroundDark = darkBg;
  static const Color accentCyan = neonCyan;
}
