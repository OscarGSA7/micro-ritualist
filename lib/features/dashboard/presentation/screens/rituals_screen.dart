import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/rituals_provider.dart';
import '../../data/models/ritual_model.dart';
import '../widgets/ritual_card.dart';
import '../screens/ritual_timer_screen.dart';

/// Pantalla de todos los rituales
/// Muestra una lista completa de rituales con filtros por categoría
class RitualsScreen extends ConsumerStatefulWidget {
  const RitualsScreen({super.key});

  @override
  ConsumerState<RitualsScreen> createState() => _RitualsScreenState();
}

class _RitualsScreenState extends ConsumerState<RitualsScreen> {
  RitualCategory? _selectedCategory;

  // Datos de ejemplo para cuando no hay conexión al backend
  List<RitualModel> get _sampleRituals => [
    const RitualModel(
      id: '1',
      title: 'Respiración 4-7-8',
      description: 'Técnica de respiración para calmar la mente',
      durationMinutes: 3,
      icon: Icons.air_rounded,
      color: AppColors.lightPrimary,
      progress: 0.7,
      category: RitualCategory.breathing,
    ),
    const RitualModel(
      id: '2',
      title: 'Estiramientos suaves',
      description: 'Micro-movimientos para activar el cuerpo',
      durationMinutes: 5,
      icon: Icons.self_improvement_rounded,
      color: AppColors.lightSecondary,
      progress: 0.3,
      category: RitualCategory.movement,
    ),
    const RitualModel(
      id: '3',
      title: 'Gratitud consciente',
      description: 'Reflexiona sobre 3 cosas positivas del día',
      durationMinutes: 2,
      icon: Icons.favorite_rounded,
      color: AppColors.lightAccent,
      progress: 0.0,
      category: RitualCategory.mindfulness,
    ),
  ];

  List<RitualModel> _getRituals(RitualsState state) {
    // Convertir rituales del backend a RitualModel para la UI
    final List<RitualModel> rituals;
    
    if (state.rituals.isEmpty) {
      rituals = _sampleRituals;
    } else {
      rituals = state.rituals.map((r) {
        final todayCompletion = state.todayCompletions.any((c) => c.ritualId == r.id);
        final streak = state.streaks[r.id];
        
        return RitualModel(
          id: r.id,
          title: r.title,
          description: r.description ?? '',
          durationMinutes: r.durationMinutes,
          icon: _getIconFromName(r.iconName),
          color: _getColorFromHex(r.colorHex),
          progress: todayCompletion ? 1.0 : 0.0,
          isCompleted: todayCompletion,
          category: _getCategoryFromString(r.category),
          streak: streak?.currentStreak ?? 0,
        );
      }).toList();
    }
    
    if (_selectedCategory == null) {
      return rituals;
    }
    return rituals.where((r) => r.category == _selectedCategory).toList();
  }

  IconData _getIconFromName(String iconName) {
    const iconMap = {
      'self_improvement_rounded': Icons.self_improvement_rounded,
      'air_rounded': Icons.air_rounded,
      'favorite_rounded': Icons.favorite_rounded,
      'local_drink_rounded': Icons.local_drink_rounded,
      'spa_rounded': Icons.spa_rounded,
      'directions_walk_rounded': Icons.directions_walk_rounded,
      'music_note_rounded': Icons.music_note_rounded,
      'wb_sunny_rounded': Icons.wb_sunny_rounded,
      'bedtime_rounded': Icons.bedtime_rounded,
      'emoji_nature_rounded': Icons.emoji_nature_rounded,
      'water_drop_rounded': Icons.water_drop_rounded,
      'edit_note_rounded': Icons.edit_note_rounded,
    };
    return iconMap[iconName] ?? Icons.self_improvement_rounded;
  }

  Color _getColorFromHex(String? hexColor) {
    if (hexColor == null || !hexColor.startsWith('#')) {
      return AppColors.lightPrimary;
    }
    try {
      return Color(int.parse('FF${hexColor.substring(1)}', radix: 16));
    } catch (e) {
      return AppColors.lightPrimary;
    }
  }

  RitualCategory _getCategoryFromString(String? category) {
    if (category == null) return RitualCategory.mindfulness;
    return RitualCategory.values.firstWhere(
      (c) => c.name.toLowerCase() == category.toLowerCase(),
      orElse: () => RitualCategory.mindfulness,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ritualsState = ref.watch(ritualsProvider);
    final filteredRituals = _getRituals(ritualsState);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Mis Rutinas',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().fadeIn(duration: 400.ms),
                        ),
                        // Indicador de modo offline
                        if (ritualsState.isOffline)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingS,
                              vertical: AppTheme.spacingXS,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.cloud_off_rounded,
                                  size: 14,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Offline',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Indicador de sincronización pendiente
                        if (ritualsState.pendingSyncCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: AppTheme.spacingXS),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingS,
                                vertical: AppTheme.spacingXS,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightPrimary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.sync_rounded,
                                    size: 14,
                                    color: AppColors.lightPrimary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${ritualsState.pendingSyncCount}',
                                    style: TextStyle(
                                      color: AppColors.lightPrimary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${filteredRituals.length} rutinas disponibles',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                        ),
                        // Hint de deslizar para eliminar
                        Text(
                          'Desliza para eliminar',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Filtros por categoría
            SliverToBoxAdapter(
              child: _buildCategoryFilters(isDark),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppTheme.spacingM),
            ),

            // Loading indicator
            if (ritualsState.isLoading)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingXL),
                    child: CircularProgressIndicator(
                      color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    ),
                  ),
                ),
              ),

            // Error message
            if (ritualsState.error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: AppTheme.spacingS),
                        Expanded(
                          child: Text(
                            ritualsState.error!,
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Lista de rituales
            if (!ritualsState.isLoading)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= filteredRituals.length) return null;
                      final ritual = filteredRituals[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                        child: RitualCard(
                          ritual: ritual,
                          animationIndex: index,
                          onTap: () => _onRitualTap(ritual),
                          onStart: () => _onRitualStart(ritual),
                          onComplete: () => _onRitualComplete(ritual),
                          onDelete: () => _onRitualDelete(ritual),
                        ),
                      );
                    },
                    childCount: filteredRituals.length,
                  ),
                ),
              ),

            // Espacio inferior para el bottom nav
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(bool isDark) {
    final categories = [null, ...RitualCategory.values];

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          final label = category?.displayName ?? 'Todos';

          return Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingS),
            child: _buildFilterChip(
              label: label,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              isDark: isDark,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms);
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: isSelected
              ? null
              : Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _onRitualTap(RitualModel ritual) {
    debugPrint('Ritual tapped: ${ritual.title}');
    // TODO: Mostrar detalle del ritual
  }

  void _onRitualStart(RitualModel ritual) async {
    debugPrint('Ritual started: ${ritual.title}');
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => RitualTimerScreen(ritual: ritual),
      ),
    );

    if (completed == true) {
      debugPrint('Ritual completed: ${ritual.title}');
      // Marcar como completado en el provider
      ref.read(ritualsProvider.notifier).completeRitual(ritual.id);
    }
  }

  void _onRitualComplete(RitualModel ritual) {
    debugPrint('Ritual marked complete: ${ritual.title}');
    ref.read(ritualsProvider.notifier).completeRitual(ritual.id);
  }

  void _onRitualDelete(RitualModel ritual) async {
    debugPrint('Ritual deleted: ${ritual.title}');
    final success = await ref.read(ritualsProvider.notifier).deleteRitual(ritual.id);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
                ? 'Ritual "${ritual.title}" eliminado'
                : 'Error al eliminar el ritual',
          ),
          backgroundColor: success ? AppColors.success : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
      );
    }
  }
}
