import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/models/ritual_model.dart';

/// RitualCard - Widget premium para micro-rituales
/// Diseño Apple-style con sombras suaves, bordes redondeados y animaciones sutiles
class RitualCard extends StatefulWidget {
  final RitualModel ritual;
  final VoidCallback? onTap;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;
  final int animationIndex;
  final bool showDeleteAction;

  const RitualCard({
    super.key,
    required this.ritual,
    this.onTap,
    this.onStart,
    this.onComplete,
    this.onDelete,
    this.animationIndex = 0,
    this.showDeleteAction = true,
  });

  @override
  State<RitualCard> createState() => _RitualCardState();
}

class _RitualCardState extends State<RitualCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ritual = widget.ritual;
    
    Widget card = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            boxShadow: [
              BoxShadow(
                color: ritual.color.withOpacity(isDark ? 0.2 : 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: (isDark ? Colors.black : ritual.color).withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icono + Duración + Estado
              Row(
                children: [
                  // Icono con fondo de color
                  _buildIconContainer(isDark, ritual),
                  
                  const SizedBox(width: AppTheme.spacingM),
                  
                  // Título y duración
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ritual.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppTheme.spacingXS),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: isDark 
                                  ? AppColors.darkTextTertiary 
                                  : AppColors.lightTextTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${ritual.durationMinutes} ${AppStrings.ritualMinutes}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark 
                                    ? AppColors.darkTextTertiary 
                                    : AppColors.lightTextTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Estado de completado
                  if (ritual.isCompleted)
                    _buildCompletedBadge(isDark),
                ],
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              // Descripción
              Text(
                ritual.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark 
                      ? AppColors.darkTextSecondary 
                      : AppColors.lightTextSecondary,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: AppTheme.spacingL),
              
              // Barra de progreso + Botón
              Row(
                children: [
                  // Barra de progreso
                  Expanded(
                    child: _buildProgressBar(isDark, ritual),
                  ),
                  
                  const SizedBox(width: AppTheme.spacingM),
                  
                  // Botón de acción
                  _buildActionButton(isDark, ritual),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // Envolver en Dismissible si se permite eliminar
    if (widget.showDeleteAction && widget.onDelete != null) {
      card = Dismissible(
        key: Key(ritual.id),
        direction: DismissDirection.endToStart,
        background: _buildDeleteBackground(isDark),
        confirmDismiss: (_) async {
          final confirmed = await _confirmDelete(context);
          if (confirmed) {
            // Llamar a onDelete y esperar a que se complete
            widget.onDelete?.call();
          }
          // Siempre devolver false para evitar el error del Dismissible
          // El widget se removerá cuando el estado se actualice
          return false;
        },
        child: card,
      );
    }

    return card
    .animate()
    .fadeIn(
      duration: 400.ms,
      delay: Duration(milliseconds: 100 * widget.animationIndex),
    )
    .slideY(
      begin: 0.1,
      end: 0,
      duration: 400.ms,
      delay: Duration(milliseconds: 100 * widget.animationIndex),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildDeleteBackground(bool isDark) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Icon(
            Icons.delete_rounded,
            color: Colors.red,
            size: 24,
          ),
          const SizedBox(width: AppTheme.spacingS),
          Text(
            'Eliminar',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        title: Text(
          'Eliminar ritual',
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${widget.ritual.title}"? Esta acción no se puede deshacer.',
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
            ),
            child: const Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildIconContainer(bool isDark, RitualModel ritual) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: ritual.color.withOpacity(isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Icon(
        ritual.icon,
        color: ritual.color,
        size: 26,
      ),
    );
  }

  Widget _buildCompletedBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: AppTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 14,
          ),
          SizedBox(width: 4),
          Text(
            AppStrings.ritualCompleted,
            style: TextStyle(
              color: AppColors.success,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(bool isDark, RitualModel ritual) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.ritualProgress,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark 
                    ? AppColors.darkTextTertiary 
                    : AppColors.lightTextTertiary,
              ),
            ),
            Text(
              '${(ritual.progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: ritual.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.darkSurfaceVariant 
                : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: ritual.progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ritual.color,
                    ritual.color.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(bool isDark, RitualModel ritual) {
    final isCompleted = ritual.isCompleted;
    final buttonColor = isCompleted ? AppColors.success : ritual.color;
    
    return GestureDetector(
      onTap: isCompleted ? null : (widget.onStart ?? widget.onComplete),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        decoration: BoxDecoration(
          color: buttonColor.withOpacity(isCompleted ? 0.15 : 1.0),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          boxShadow: isCompleted
              ? null
              : [
                  BoxShadow(
                    color: buttonColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Text(
          isCompleted ? AppStrings.ritualCompleted : AppStrings.ritualStart,
          style: TextStyle(
            color: isCompleted ? buttonColor : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Mini versión del RitualCard para layouts compactos (Bento Box)
class RitualCardMini extends StatelessWidget {
  final RitualModel ritual;
  final VoidCallback? onTap;

  const RitualCardMini({
    super.key,
    required this.ritual,
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
              color: ritual.color.withOpacity(isDark ? 0.15 : 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ritual.color.withOpacity(isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Icon(
                ritual.icon,
                color: ritual.color,
                size: 20,
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingS),
            
            // Título
            Text(
              ritual.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark 
                    ? AppColors.darkTextPrimary 
                    : AppColors.lightTextPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: AppTheme.spacingXS),
            
            // Duración
            Text(
              '${ritual.durationMinutes} ${AppStrings.ritualMinutes}',
              style: TextStyle(
                fontSize: 11,
                color: isDark 
                    ? AppColors.darkTextTertiary 
                    : AppColors.lightTextTertiary,
              ),
            ),
            
            const Spacer(),
            
            // Mini progreso
            if (ritual.progress > 0)
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: isDark 
                      ? AppColors.darkSurfaceVariant 
                      : AppColors.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: ritual.progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: ritual.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
