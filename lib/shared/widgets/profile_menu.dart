import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

/// Menú de perfil con opciones de usuario y configuración
/// Diseño glassmorphism con estética premium
class ProfileMenu extends ConsumerWidget {
  final VoidCallback? onClose;

  const ProfileMenu({
    super.key,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentTheme = ref.watch(themeModeProvider);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: isDark 
              ? AppColors.darkSurface.withOpacity(0.95) 
              : AppColors.lightSurface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(
            color: isDark 
                ? Colors.white.withOpacity(0.1) 
                : Colors.black.withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del perfil
            _buildProfileHeader(context, isDark),
            
            const SizedBox(height: AppTheme.spacingM),
            
            Divider(
              color: isDark 
                  ? Colors.white.withOpacity(0.1) 
                  : Colors.black.withOpacity(0.05),
              height: 1,
            ),
            
            const SizedBox(height: AppTheme.spacingM),
            
            // Sección de tema
            _buildThemeSection(context, ref, isDark, currentTheme),
            
            const SizedBox(height: AppTheme.spacingM),
            
            Divider(
              color: isDark 
                  ? Colors.white.withOpacity(0.1) 
                  : Colors.black.withOpacity(0.05),
              height: 1,
            ),
            
            const SizedBox(height: AppTheme.spacingS),
            
            // Opciones adicionales
            _buildMenuItem(
              context,
              isDark,
              icon: Icons.settings_rounded,
              label: AppStrings.menuSettings,
              onTap: () {
                onClose?.call();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            
            _buildMenuItem(
              context,
              isDark,
              icon: Icons.history_rounded,
              label: AppStrings.menuHistory,
              onTap: () {
                onClose?.call();
                // TODO: Navegar a historial
              },
            ),
            
            _buildMenuItem(
              context,
              isDark,
              icon: Icons.help_outline_rounded,
              label: AppStrings.menuHelp,
              onTap: () {
                onClose?.call();
                // TODO: Mostrar ayuda
              },
            ),
            
            const SizedBox(height: AppTheme.spacingS),
            
            Divider(
              color: isDark 
                  ? Colors.white.withOpacity(0.1) 
                  : Colors.black.withOpacity(0.05),
              height: 1,
            ),
            
            const SizedBox(height: AppTheme.spacingS),
            
            _buildMenuItem(
              context,
              isDark,
              icon: Icons.info_outline_rounded,
              label: AppStrings.menuAbout,
              onTap: () {
                onClose?.call();
                _showAboutDialog(context, isDark);
              },
            ),
          ],
        ),
      ),
    ).animate()
        .fadeIn(duration: 200.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildProfileHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
              ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        
        const SizedBox(width: AppTheme.spacingM),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Usuario',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppStrings.menuEditProfile,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark 
                      ? AppColors.darkPrimary 
                      : AppColors.lightPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSection(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    ThemeMode currentTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingS),
          child: Text(
            AppStrings.menuTheme,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isDark 
                  ? AppColors.darkTextTertiary 
                  : AppColors.lightTextTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        const SizedBox(height: AppTheme.spacingS),
        
        // Opciones de tema
        Row(
          children: [
            _buildThemeOption(
              context,
              ref,
              isDark,
              mode: ThemeMode.light,
              isSelected: currentTheme == ThemeMode.light,
            ),
            const SizedBox(width: AppTheme.spacingS),
            _buildThemeOption(
              context,
              ref,
              isDark,
              mode: ThemeMode.dark,
              isSelected: currentTheme == ThemeMode.dark,
            ),
            const SizedBox(width: AppTheme.spacingS),
            _buildThemeOption(
              context,
              ref,
              isDark,
              mode: ThemeMode.system,
              isSelected: currentTheme == ThemeMode.system,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    bool isDark, {
    required ThemeMode mode,
    required bool isSelected,
  }) {
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(themeModeProvider.notifier).setThemeMode(mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacingM,
            horizontal: AppTheme.spacingS,
          ),
          decoration: BoxDecoration(
            color: isSelected 
                ? primaryColor.withOpacity(0.15) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            border: Border.all(
              color: isSelected 
                  ? primaryColor 
                  : (isDark 
                      ? Colors.white.withOpacity(0.1) 
                      : Colors.black.withOpacity(0.05)),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                mode.icon,
                size: 22,
                color: isSelected 
                    ? primaryColor 
                    : (isDark 
                        ? AppColors.darkTextSecondary 
                        : AppColors.lightTextSecondary),
              ),
              const SizedBox(height: AppTheme.spacingXS),
              Text(
                mode.displayName,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSelected 
                      ? primaryColor 
                      : (isDark 
                          ? AppColors.darkTextSecondary 
                          : AppColors.lightTextSecondary),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingS,
          vertical: AppTheme.spacingM,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark 
                  ? AppColors.darkTextSecondary 
                  : AppColors.lightTextSecondary,
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: isDark 
                  ? AppColors.darkTextTertiary 
                  : AppColors.lightTextTertiary,
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: const Icon(
                Icons.spa_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            const Text(AppStrings.appName),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.appTagline,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark 
                    ? AppColors.darkTextSecondary 
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              'Versión 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark 
                    ? AppColors.darkTextTertiary 
                    : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.actionDone,
              style: TextStyle(
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Muestra el menú de perfil como un popup
void showProfileMenu(BuildContext context, GlobalKey avatarKey) {
  final RenderBox renderBox = 
      avatarKey.currentContext!.findRenderObject() as RenderBox;
  final position = renderBox.localToGlobal(Offset.zero);
  final size = renderBox.size;

  showDialog(
    context: context,
    barrierColor: Colors.black26,
    builder: (context) => Stack(
      children: [
        // Tap para cerrar
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: Colors.transparent),
          ),
        ),
        // Menú posicionado
        Positioned(
          top: position.dy + size.height + 8,
          right: MediaQuery.of(context).size.width - position.dx - size.width,
          child: ProfileMenu(
            onClose: () => Navigator.pop(context),
          ),
        ),
      ],
    ),
  );
}
