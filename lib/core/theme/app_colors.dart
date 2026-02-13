import 'package:flutter/material.dart';

/// Paleta de colores premium para Micro-Ritualist
/// Inspirada en diseño minimalista Apple-style con acentos de glassmorphism
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════
  // LIGHT MODE - Soft Pastels & Whites
  // ═══════════════════════════════════════════════════════════════
  
  static const Color lightBackground = Color(0xFFF8F9FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF2F4F8);
  
  // Primary - Soft Lavender
  static const Color lightPrimary = Color(0xFF8B7CF6);
  static const Color lightPrimaryLight = Color(0xFFB4A7FF);
  static const Color lightPrimaryDark = Color(0xFF6B5DD3);
  
  // Secondary - Soft Mint
  static const Color lightSecondary = Color(0xFF6DD5C7);
  static const Color lightSecondaryLight = Color(0xFFA8EFE5);
  static const Color lightSecondaryDark = Color(0xFF4BBFB0);
  
  // Accent - Soft Peach
  static const Color lightAccent = Color(0xFFFFB088);
  static const Color lightAccentLight = Color(0xFFFFD4BA);
  static const Color lightAccentDark = Color(0xFFE8956B);
  
  // Text Colors
  static const Color lightTextPrimary = Color(0xFF1A1D26);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);
  
  // Shadows
  static const Color lightShadow = Color(0x1A8B7CF6);
  static const Color lightShadowStrong = Color(0x338B7CF6);

  // ═══════════════════════════════════════════════════════════════
  // DARK MODE - Deep Greys & Soft Glows
  // ═══════════════════════════════════════════════════════════════
  
  static const Color darkBackground = Color(0xFF0D0F14);
  static const Color darkSurface = Color(0xFF1A1D26);
  static const Color darkSurfaceVariant = Color(0xFF252A36);
  
  // Primary - Vibrant Lavender
  static const Color darkPrimary = Color(0xFFA78BFA);
  static const Color darkPrimaryLight = Color(0xFFC4B5FD);
  static const Color darkPrimaryDark = Color(0xFF8B5CF6);
  
  // Secondary - Soft Teal
  static const Color darkSecondary = Color(0xFF5EEAD4);
  static const Color darkSecondaryLight = Color(0xFF99F6E4);
  static const Color darkSecondaryDark = Color(0xFF2DD4BF);
  
  // Accent - Warm Coral
  static const Color darkAccent = Color(0xFFFDA4AF);
  static const Color darkAccentLight = Color(0xFFFECDD3);
  static const Color darkAccentDark = Color(0xFFFB7185);
  
  // Text Colors
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextTertiary = Color(0xFF6B7280);
  
  // Shadows & Glows
  static const Color darkShadow = Color(0x40000000);
  static const Color darkGlow = Color(0x40A78BFA);

  // ═══════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════════════════════════
  
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);
  static const Color info = Color(0xFF60A5FA);

  // ═══════════════════════════════════════════════════════════════
  // ENERGY LEVEL COLORS
  // ═══════════════════════════════════════════════════════════════
  
  static const Color energyLow = Color(0xFFFFB088);
  static const Color energyMedium = Color(0xFFFBBF24);
  static const Color energyHigh = Color(0xFF34D399);

  // ═══════════════════════════════════════════════════════════════
  // GLASSMORPHISM
  // ═══════════════════════════════════════════════════════════════
  
  static const Color glassLight = Color(0x80FFFFFF);
  static const Color glassDark = Color(0x40FFFFFF);
  static const Color glassBorder = Color(0x20FFFFFF);
}

/// Extensión para acceder a colores según el tema actual
extension AppColorsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  Color get backgroundColor => isDarkMode 
      ? AppColors.darkBackground 
      : AppColors.lightBackground;
  
  Color get surfaceColor => isDarkMode 
      ? AppColors.darkSurface 
      : AppColors.lightSurface;
  
  Color get primaryColor => isDarkMode 
      ? AppColors.darkPrimary 
      : AppColors.lightPrimary;
  
  Color get secondaryColor => isDarkMode 
      ? AppColors.darkSecondary 
      : AppColors.lightSecondary;
  
  Color get textPrimary => isDarkMode 
      ? AppColors.darkTextPrimary 
      : AppColors.lightTextPrimary;
  
  Color get textSecondary => isDarkMode 
      ? AppColors.darkTextSecondary 
      : AppColors.lightTextSecondary;
}
