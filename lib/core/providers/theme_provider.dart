import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para manejar el modo de tema de la aplicación
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

/// Notifier para el estado del tema
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  /// Cambiar a tema claro
  void setLightMode() => state = ThemeMode.light;

  /// Cambiar a tema oscuro
  void setDarkMode() => state = ThemeMode.dark;

  /// Usar tema del sistema
  void setSystemMode() => state = ThemeMode.system;

  /// Cambiar el tema
  void setThemeMode(ThemeMode mode) => state = mode;

  /// Ciclar entre temas
  void toggleTheme() {
    switch (state) {
      case ThemeMode.system:
        state = ThemeMode.light;
        break;
      case ThemeMode.light:
        state = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        state = ThemeMode.system;
        break;
    }
  }
}

/// Extensión para obtener información del tema
extension ThemeModeExtension on ThemeMode {
  String get displayName {
    switch (this) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }

  IconData get icon {
    switch (this) {
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }
}
