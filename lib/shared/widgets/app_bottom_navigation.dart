import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Índices de navegación para el BottomNavigationBar
enum NavIndex {
  home(0),
  rituals(1),
  addRitual(2),
  profile(3),
  settings(4);

  final int value;
  const NavIndex(this.value);
}

/// Bottom Navigation Bar personalizado con estética glassmorphism
/// 
/// Siempre visible en todas las pantallas de la aplicación
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark 
                ? Colors.white.withOpacity(0.08) 
                : Colors.black.withOpacity(0.05),
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: AppTheme.spacingM,
          right: AppTheme.spacingM,
          top: AppTheme.spacingXS,
          bottom: bottomPadding + AppTheme.spacingXS,
        ),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Botón Inicio
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Inicio',
                isSelected: currentIndex == NavIndex.home.value,
                onTap: () => onTap(NavIndex.home.value),
                isDark: isDark,
              ),
              
              // Botón Rituales
              _NavItem(
                icon: Icons.spa_rounded,
                label: 'Rituales',
                isSelected: currentIndex == NavIndex.rituals.value,
                onTap: () => onTap(NavIndex.rituals.value),
                isDark: isDark,
              ),
              
              // Botón Añadir (centro, destacado)
              _AddButton(
                isSelected: currentIndex == NavIndex.addRitual.value,
                onTap: () => onTap(NavIndex.addRitual.value),
                isDark: isDark,
              ),
              
              // Botón Perfil
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Perfil',
                isSelected: currentIndex == NavIndex.profile.value,
                onTap: () => onTap(NavIndex.profile.value),
                isDark: isDark,
              ),

              // Botón Ajustes
              _NavItem(
                icon: Icons.settings_rounded,
                label: 'Ajustes',
                isSelected: currentIndex == NavIndex.settings.value,
                onTap: () => onTap(NavIndex.settings.value),
                isDark: isDark,
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms);
  }
}

/// Item individual del navigation bar
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final unselectedColor = isDark 
        ? AppColors.darkTextTertiary 
        : AppColors.lightTextTertiary;
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingXS,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? selectedColor : unselectedColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? selectedColor : unselectedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón central de añadir con diseño destacado
class _AddButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _AddButton({
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
        ),
        child: AnimatedRotation(
          duration: const Duration(milliseconds: 200),
          turns: isSelected ? 0.125 : 0,
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
