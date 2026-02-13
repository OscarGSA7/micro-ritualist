import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';

/// Niveles de energía del usuario
enum EnergyLevel {
  low,
  medium,
  high,
}

extension EnergyLevelExtension on EnergyLevel {
  String get displayName {
    switch (this) {
      case EnergyLevel.low:
        return AppStrings.energyLow;
      case EnergyLevel.medium:
        return AppStrings.energyMedium;
      case EnergyLevel.high:
        return AppStrings.energyHigh;
    }
  }

  Color get color {
    switch (this) {
      case EnergyLevel.low:
        return AppColors.energyLow;
      case EnergyLevel.medium:
        return AppColors.energyMedium;
      case EnergyLevel.high:
        return AppColors.energyHigh;
    }
  }

  double get value {
    switch (this) {
      case EnergyLevel.low:
        return 0.33;
      case EnergyLevel.medium:
        return 0.66;
      case EnergyLevel.high:
        return 1.0;
    }
  }

  String get tip {
    switch (this) {
      case EnergyLevel.low:
        return AppStrings.energyTipLow;
      case EnergyLevel.medium:
        return AppStrings.energyTipMedium;
      case EnergyLevel.high:
        return AppStrings.energyTipHigh;
    }
  }

  IconData get icon {
    switch (this) {
      case EnergyLevel.low:
        return Icons.battery_2_bar_rounded;
      case EnergyLevel.medium:
        return Icons.battery_4_bar_rounded;
      case EnergyLevel.high:
        return Icons.battery_full_rounded;
    }
  }
}

/// Widget visual para mostrar el nivel de energía del usuario
/// Diseño premium con gradientes y animaciones sutiles
class EnergyTrackerCard extends StatelessWidget {
  final EnergyLevel energyLevel;
  final VoidCallback? onTap;

  const EnergyTrackerCard({
    super.key,
    required this.energyLevel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDark ? AppColors.darkSurface : AppColors.lightSurface,
              isDark 
                  ? AppColors.darkSurfaceVariant.withOpacity(0.5) 
                  : AppColors.lightSurfaceVariant.withOpacity(0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          boxShadow: [
            BoxShadow(
              color: energyLevel.color.withOpacity(isDark ? 0.25 : 0.2),
              blurRadius: 32,
              offset: const Offset(0, 12),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: (isDark ? Colors.black : energyLevel.color).withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Icono animado de energía
                _buildEnergyIcon(isDark),
                
                const SizedBox(width: AppTheme.spacingM),
                
                // Título
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.dashboardEnergyTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.energyStatus,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark 
                              ? AppColors.darkTextTertiary 
                              : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Badge de nivel
                _buildLevelBadge(isDark),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Barra visual de energía
            _buildEnergyBar(isDark),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Consejo del día
            _buildTipSection(isDark, context),
          ],
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 500.ms)
    .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildEnergyIcon(bool isDark) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            energyLevel.color.withOpacity(0.2),
            energyLevel.color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: energyLevel.color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Icon(
        energyLevel.icon,
        color: energyLevel.color,
        size: 28,
      ),
    )
    .animate(onPlay: (controller) => controller.repeat(reverse: true))
    .scale(
      begin: const Offset(1, 1),
      end: const Offset(1.05, 1.05),
      duration: 2000.ms,
      curve: Curves.easeInOut,
    );
  }

  Widget _buildLevelBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: energyLevel.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(
          color: energyLevel.color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Text(
        energyLevel.displayName,
        style: TextStyle(
          color: energyLevel.color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEnergyBar(bool isDark) {
    return Column(
      children: [
        // Indicadores de nivel
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLevelIndicator(
              EnergyLevel.low,
              energyLevel == EnergyLevel.low,
              isDark,
            ),
            _buildLevelIndicator(
              EnergyLevel.medium,
              energyLevel == EnergyLevel.medium,
              isDark,
            ),
            _buildLevelIndicator(
              EnergyLevel.high,
              energyLevel == EnergyLevel.high,
              isDark,
            ),
          ],
        ),
        
        const SizedBox(height: AppTheme.spacingS),
        
        // Barra de progreso
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.darkSurfaceVariant 
                : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * energyLevel.value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          energyLevel.color,
                          energyLevel.color.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      boxShadow: [
                        BoxShadow(
                          color: energyLevel.color.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLevelIndicator(EnergyLevel level, bool isActive, bool isDark) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive 
                ? level.color 
                : (isDark 
                    ? AppColors.darkSurfaceVariant 
                    : AppColors.lightSurfaceVariant),
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: level.color.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTipSection(bool isDark, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: energyLevel.color.withOpacity(isDark ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: energyLevel.color.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: energyLevel.color,
            size: 20,
          ),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.energyTip,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: energyLevel.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  energyLevel.tip,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark 
                        ? AppColors.darkTextSecondary 
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Versión compacta del energy tracker para Bento layout
class EnergyTrackerMini extends StatelessWidget {
  final EnergyLevel energyLevel;
  final VoidCallback? onTap;

  const EnergyTrackerMini({
    super.key,
    required this.energyLevel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          boxShadow: [
            BoxShadow(
              color: energyLevel.color.withOpacity(isDark ? 0.2 : 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icono
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: energyLevel.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Icon(
                energyLevel.icon,
                color: energyLevel.color,
                size: 22,
              ),
            ),
            
            const Spacer(),
            
            // Label
            Text(
              AppStrings.dashboardEnergyTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingXS),
            
            // Nivel
            Text(
              energyLevel.displayName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: energyLevel.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
