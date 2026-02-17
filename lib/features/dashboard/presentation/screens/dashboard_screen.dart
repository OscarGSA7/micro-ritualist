import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/rituals_provider.dart';
import '../../../../shared/widgets/profile_menu.dart';
import '../../../wellness/presentation/widgets/wellness_check_card.dart';
import '../../../wellness/services/wellness_analysis_service.dart';
import '../../../notifications/presentation/screens/notification_settings_screen.dart';
import '../../data/models/ritual_model.dart';
import '../widgets/ritual_card.dart';
import '../widgets/energy_tracker_card.dart';
import 'ritual_timer_screen.dart';
import 'rituals_screen.dart';

/// Dashboard Principal - Pantalla principal de Micro-Ritualist
/// Diseño Bento Box con estética minimalista Apple-style
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // Key para posicionar el menú de perfil
  final GlobalKey _avatarKey = GlobalKey();

  // Estado temporal - En producción usar Riverpod/Bloc
  EnergyLevel _currentEnergy = EnergyLevel.medium;

  // Si el usuario ya completó el check-in de hoy
  bool _hasCompletedCheckIn = false;

  // Último resultado de análisis de bienestar
  WellnessAnalysisResult? _lastAnalysisResult;

  // Lista de consejos generales del día
  static const List<String> _generalTips = [
    'Haz una micro-rutina para mejorar tu bienestar.',
    'Recuerda tomar agua regularmente durante el día.',
    'Una pausa de 2 minutos puede hacer la diferencia.',
    'Respira profundo y relájate un momento.',
    'El movimiento es medicina para el cuerpo y la mente.',
    'Pequeños hábitos, grandes resultados.',
    'Tómate un momento para agradecer algo hoy.',
    'Estira tu cuerpo, libera la tensión acumulada.',
    'Cada rutina completada es un paso hacia tu bienestar.',
    'La constancia es más importante que la perfección.',
  ];

  // Consejo del día (seleccionado aleatoriamente)
  late String _dailyTip;

  // Convertir rituales del provider a RitualModel para la UI
  List<RitualModel> _getRitualsFromState(RitualsState state) {
    if (state.rituals.isEmpty) return [];
    return state.rituals.map((r) => RitualModel(
      id: r.id,
      title: r.title,
      description: r.description,
      durationMinutes: r.durationMinutes,
      icon: _getCategoryIcon(r.category),
      color: _getCategoryColor(r.colorHex),
      progress: 0.0,
      category: _parseCategory(r.category),
    )).toList();
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'breathing': return Icons.air_rounded;
      case 'movement': return Icons.directions_walk_rounded;
      case 'mindfulness': return Icons.self_improvement_rounded;
      case 'hydration': return Icons.local_drink_rounded;
      case 'gratitude': return Icons.favorite_rounded;
      default: return Icons.spa_rounded;
    }
  }

  Color _getCategoryColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return AppColors.lightPrimary;
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.lightPrimary;
    }
  }

  RitualCategory _parseCategory(String category) {
    switch (category) {
      case 'breathing': return RitualCategory.breathing;
      case 'movement': return RitualCategory.movement;
      case 'mindfulness': return RitualCategory.mindfulness;
      case 'hydration': return RitualCategory.hydration;
      case 'gratitude': return RitualCategory.gratitude;
      default: return RitualCategory.custom;
    }
  }

  @override
  void initState() {
    super.initState();
    // Seleccionar consejo aleatorio del día
    _dailyTip = _generalTips[Random().nextInt(_generalTips.length)];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ritualsState = ref.watch(ritualsProvider);
    final rituals = _getRitualsFromState(ritualsState);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ═══════════════════════════════════════════════════════════
            // HEADER - Saludo personalizado
            // ═══════════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingL,
                  AppTheme.spacingL,
                  AppTheme.spacingL,
                  AppTheme.spacingM,
                ),
                child: _buildHeader(context, isDark),
              ),
            ),

            // ═══════════════════════════════════════════════════════════            // RECORDATORIOS DE MOVIMIENTO
            // ═════════════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                child: _buildNotificationPromptCard(context, isDark),
              ),
            ),

            // ═════════════════════════════════════════════════════════════            // ENERGÍA Y CONSEJO DEL DÍA
            // ═══════════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                child: _buildEnergyAndAdviceCard(isDark),
              ),
            ),

            // ═══════════════════════════════════════════════════════════
            // BENTO BOX LAYOUT
            // ═══════════════════════════════════════════════════════════
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Wellness Check + Energy Tracker (lado a lado)
                    _buildTopBentoRow(isDark),

                    const SizedBox(height: AppTheme.spacingL),
                    // Título de sección
                    _buildSectionTitle(
                      context,
                      AppStrings.dashboardRitualsTitle,
                      isDark,
                    ),

                    const SizedBox(height: AppTheme.spacingM),
                  ],
                ),
              ),
            ),

            // ═══════════════════════════════════════════════════════════
            // LISTA DE RITUALES
            // ═══════════════════════════════════════════════════════════
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
              sliver: rituals.isEmpty
                ? SliverToBoxAdapter(
                    child: _buildEmptyRitualsCard(context, isDark),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= rituals.length) return null;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                          child: RitualCard(
                            ritual: rituals[index],
                            animationIndex: index,
                            onTap: () => _onRitualTap(rituals[index]),
                            onStart: () => _onRitualStart(rituals[index]),
                            onComplete: () => _onRitualComplete(rituals[index]),
                          ),
                        );
                      },
                      childCount: rituals.length,
                    ),
                  ),
            ),

            // Espacio inferior para el bottom nav
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
    );
  }

  /// Tarjeta de acceso rápido a recordatorios de movimiento
  Widget _buildNotificationPromptCard(BuildContext context, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const NotificationSettingsScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.darkPrimary.withOpacity(0.15),
                      AppColors.darkSecondary.withOpacity(0.1),
                    ]
                  : [
                      AppColors.lightPrimary.withOpacity(0.1),
                      AppColors.lightSecondary.withOpacity(0.05),
                    ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            border: Border.all(
              color: isDark
                  ? AppColors.darkPrimary.withOpacity(0.3)
                  : AppColors.lightPrimary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkPrimary.withOpacity(0.2)
                      : AppColors.lightPrimary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recordatorios de movimiento',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Configura alertas para pausas activas',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? AppColors.darkPrimary.withOpacity(0.7)
                    : AppColors.lightPrimary.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideY(begin: 0.05, end: 0);
  }

  /// Widget para mostrar el consejo del día
  Widget _buildEnergyAndAdviceCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingL),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.darkShadow.withOpacity(0.12)
                : AppColors.lightShadow.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono de consejo
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkAccent : AppColors.lightAccent).withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Consejo del día
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consejo del día',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _dailyTip,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Header con saludo personalizado según la hora del día
  Widget _buildHeader(BuildContext context, bool isDark) {
    final greeting = _getGreetingByTime();
    final authState = ref.watch(authProvider);
    final userName = authState.user?.name ?? 'Usuario';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.displaySmall,
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -0.1, end: 0),
                ],
              ),
            ),

            // Avatar/Perfil
            _buildProfileAvatar(isDark),
          ],
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          AppStrings.dashboardSubtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isDark
                ? AppColors.darkTextTertiary
                : AppColors.lightTextTertiary,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
      ],
    );
  }

  /// Botón de menú hamburguesa
  Widget _buildProfileAvatar(bool isDark) {
    return GestureDetector(
      key: _avatarKey,
      onTap: () {
        showProfileMenu(context, _avatarKey);
      },
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingS),
        child: Icon(
          Icons.menu_rounded,
          color: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
          size: 28,
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  /// Fila superior del Bento Box con Wellness Check y Energy
  Widget _buildTopBentoRow(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // En pantallas pequeñas, apilar verticalmente
        if (constraints.maxWidth < 500) {
          return Column(
            children: [
              WellnessCheckCard(
                onAnalysisComplete: _onWellnessAnalysisComplete,
              ).animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),

              // Solo mostrar EnergyTracker si ya se hizo check-in
              if (_hasCompletedCheckIn) ...[
                const SizedBox(height: AppTheme.spacingM),

                EnergyTrackerCard(
                  energyLevel: _currentEnergy,
                ).animate()
                    .fadeIn(duration: 500.ms, delay: 300.ms)
                    .slideY(begin: 0.1, end: 0),
              ],
            ],
          );
        }

        // En pantallas grandes, lado a lado
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wellness Check Card
            Expanded(
              flex: _hasCompletedCheckIn ? 3 : 1,
              child: WellnessCheckCard(
                onAnalysisComplete: _onWellnessAnalysisComplete,
              ).animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),
            ),

            // Solo mostrar EnergyTracker si ya se hizo check-in
            if (_hasCompletedCheckIn) ...[
              const SizedBox(width: AppTheme.spacingM),

              // Energy Tracker (más estrecho)
              Expanded(
                flex: 2,
                child: EnergyTrackerCard(
                  energyLevel: _currentEnergy,
                ).animate()
                    .fadeIn(duration: 500.ms, delay: 300.ms)
                    .slideY(begin: 0.1, end: 0),
              ),
            ],
          ],
        );
      },
    );
  }

  /// Título de sección con estilo premium
  Widget _buildSectionTitle(BuildContext context, String title, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        TextButton(
          onPressed: () {
            // Navegar a la pantalla de rituales
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const RitualsScreen(),
              ),
            );
          },
          child: Text(
            'Ver todos',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  /// Tarjeta cuando no hay rituales creados
  Widget _buildEmptyRitualsCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkSurface.withOpacity(0.5) 
            : AppColors.lightSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.1) 
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.spa_outlined,
            size: 48,
            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'No tienes rituales aún',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Crea tu primer ritual para comenzar tu viaje de bienestar',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RitualsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Crear ritual'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingL,
                vertical: AppTheme.spacingM,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
  }

  /// Obtener saludo según la hora del día
  String _getGreetingByTime() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return AppStrings.greetingMorning;
    } else if (hour >= 12 && hour < 19) {
      return AppStrings.greetingAfternoon;
    } else {
      return AppStrings.greetingEvening;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // CALLBACKS
  // ═══════════════════════════════════════════════════════════════

  void _onWellnessAnalysisComplete(WellnessAnalysisResult result) {
    debugPrint('Wellness analysis complete: Score ${result.wellnessScore}');
    setState(() {
      _lastAnalysisResult = result;
      _hasCompletedCheckIn = true;
      // Mapear EnergyLevel del modelo al widget
      switch (result.assessment.energyLevel.name) {
        case 'veryLow':
        case 'low':
          _currentEnergy = EnergyLevel.low;
          break;
        case 'medium':
          _currentEnergy = EnergyLevel.medium;
          break;
        case 'high':
        case 'veryHigh':
          _currentEnergy = EnergyLevel.high;
          break;
        default:
          _currentEnergy = EnergyLevel.medium;
      }
    });
    // Mostrar feedback con opción de iniciar rutina recomendada
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasRecommendation = result.recommendations.isNotEmpty;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              result.wellnessScore >= 60
                  ? Icons.sentiment_satisfied_rounded
                  : Icons.sentiment_neutral_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hasRecommendation
                    ? 'Rutina recomendada: ${result.recommendations.first.ritualName}'
                    : result.headline,
              ),
            ),
          ],
        ),
        action: hasRecommendation
            ? SnackBarAction(
                label: 'Iniciar',
                textColor: Colors.white,
                onPressed: () {
                  _startRecommendedRitual(result.recommendations.first);
                },
              )
            : null,
        backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  /// Inicia la rutina recomendada basada en el análisis de bienestar
  void _startRecommendedRitual(WellnessRecommendation recommendation) {
    // Crear un RitualModel temporal basado en la recomendación
    final ritual = RitualModel(
      id: 'recommended_${DateTime.now().millisecondsSinceEpoch}',
      title: recommendation.ritualName,
      description: recommendation.description,
      durationMinutes: recommendation.durationMinutes,
      icon: _getIconForRecommendation(recommendation),
      color: _getColorForRecommendation(recommendation),
      progress: 0.0,
      category: _getCategoryForRecommendation(recommendation),
    );
    
    _onRitualStart(ritual);
  }

  /// Obtiene el icono adecuado según la recomendación
  IconData _getIconForRecommendation(WellnessRecommendation recommendation) {
    final title = recommendation.title.toLowerCase();
    if (title.contains('respiración') || title.contains('respira')) {
      return Icons.air_rounded;
    } else if (title.contains('estira') || title.contains('movimiento') || title.contains('camina')) {
      return Icons.self_improvement_rounded;
    } else if (title.contains('gratitud') || title.contains('emoci')) {
      return Icons.favorite_rounded;
    } else if (title.contains('agua') || title.contains('hidrata')) {
      return Icons.water_drop_rounded;
    } else if (title.contains('descanso') || title.contains('pausa')) {
      return Icons.pause_circle_rounded;
    }
    return Icons.spa_rounded;
  }

  /// Obtiene el color adecuado según la recomendación
  Color _getColorForRecommendation(WellnessRecommendation recommendation) {
    final title = recommendation.title.toLowerCase();
    if (title.contains('respiración') || title.contains('respira')) {
      return AppColors.lightPrimary;
    } else if (title.contains('estira') || title.contains('movimiento')) {
      return AppColors.lightSecondary;
    } else if (title.contains('gratitud') || title.contains('emoci')) {
      return AppColors.lightAccent;
    }
    return AppColors.lightPrimary;
  }

  /// Obtiene la categoría adecuada según la recomendación
  RitualCategory _getCategoryForRecommendation(WellnessRecommendation recommendation) {
    final title = recommendation.title.toLowerCase();
    if (title.contains('respiración') || title.contains('respira')) {
      return RitualCategory.breathing;
    } else if (title.contains('estira') || title.contains('movimiento') || title.contains('camina')) {
      return RitualCategory.movement;
    } else if (title.contains('gratitud') || title.contains('emoci')) {
      return RitualCategory.mindfulness;
    }
    return RitualCategory.mindfulness;
  }

  void _onRitualTap(RitualModel ritual) {
    debugPrint('Ritual tapped: ${ritual.title}');
    // TODO: Navegar a detalle del ritual
  }

  void _onRitualStart(RitualModel ritual) async {
    debugPrint('Ritual started: ${ritual.title}');
    // Navegar a la pantalla de timer
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => RitualTimerScreen(ritual: ritual),
      ),
    );
    
    if (result != null && result['completed'] == true) {
      // El ritual fue completado - registrar en el provider
      debugPrint('Ritual completed successfully: ${ritual.title}');
      await ref.read(ritualsProvider.notifier).completeRitual(ritual.id);
    } else if (result != null) {
      // El ritual fue interrumpido - guardar progreso parcial
      final progress = result['progress'] as double? ?? 0.0;
      debugPrint('Ritual interrupted at ${(progress * 100).toInt()}%: ${ritual.title}');
      ref.read(ritualsProvider.notifier).updateRitualProgress(ritual.id, progress);
    }
  }

  void _onRitualComplete(RitualModel ritual) async {
    debugPrint('Ritual completed: ${ritual.title}');
    await ref.read(ritualsProvider.notifier).completeRitual(ritual.id);
  }
}
