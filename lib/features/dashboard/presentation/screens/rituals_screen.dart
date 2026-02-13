import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/ritual_model.dart';
import '../widgets/ritual_card.dart';
import '../screens/ritual_timer_screen.dart';

/// Pantalla de todos los rituales
/// Muestra una lista completa de rituales con filtros por categoría
class RitualsScreen extends StatefulWidget {
  const RitualsScreen({super.key});

  @override
  State<RitualsScreen> createState() => _RitualsScreenState();
}

class _RitualsScreenState extends State<RitualsScreen> {
  RitualCategory? _selectedCategory;

  // Datos de ejemplo - En producción vendrán del estado
  final List<RitualModel> _allRituals = [
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
    const RitualModel(
      id: '4',
      title: 'Respiración box',
      description: 'Inhala, sostén, exhala, sostén - 4 segundos cada uno',
      durationMinutes: 4,
      icon: Icons.air_rounded,
      color: AppColors.lightPrimary,
      progress: 0.5,
      category: RitualCategory.breathing,
    ),
    const RitualModel(
      id: '5',
      title: 'Hidratación consciente',
      description: 'Bebe un vaso de agua con atención plena',
      durationMinutes: 1,
      icon: Icons.water_drop_rounded,
      color: Color(0xFF38BDF8),
      progress: 1.0,
      isCompleted: true,
      category: RitualCategory.hydration,
    ),
    const RitualModel(
      id: '6',
      title: 'Caminata mindful',
      description: 'Camina prestando atención a cada paso',
      durationMinutes: 10,
      icon: Icons.directions_walk_rounded,
      color: AppColors.lightSecondary,
      progress: 0.0,
      category: RitualCategory.movement,
    ),
    const RitualModel(
      id: '7',
      title: 'Diario de gratitud',
      description: 'Escribe 3 cosas por las que estás agradecido',
      durationMinutes: 5,
      icon: Icons.edit_note_rounded,
      color: AppColors.lightAccent,
      progress: 0.0,
      category: RitualCategory.gratitude,
    ),
  ];

  List<RitualModel> get _filteredRituals {
    if (_selectedCategory == null) {
      return _allRituals;
    }
    return _allRituals.where((r) => r.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    Text(
                      'Mis Rutinas',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      '${_filteredRituals.length} rutinas disponibles',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
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

            // Lista de rituales
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= _filteredRituals.length) return null;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                      child: RitualCard(
                        ritual: _filteredRituals[index],
                        animationIndex: index,
                        onTap: () => _onRitualTap(_filteredRituals[index]),
                        onStart: () => _onRitualStart(_filteredRituals[index]),
                        onComplete: () => _onRitualComplete(_filteredRituals[index]),
                      ),
                    );
                  },
                  childCount: _filteredRituals.length,
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
      // TODO: Actualizar estado del ritual
    }
  }

  void _onRitualComplete(RitualModel ritual) {
    debugPrint('Ritual marked complete: ${ritual.title}');
    // TODO: Marcar como completado
  }
}
