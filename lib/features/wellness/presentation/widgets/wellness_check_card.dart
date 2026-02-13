import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/wellness_assessment_model.dart';
import '../../services/wellness_analysis_service.dart';

/// Widget de check-in de bienestar con selecciones
/// Diseño paso a paso para evaluar el estado del usuario
class WellnessCheckCard extends StatefulWidget {
  final Function(WellnessAnalysisResult)? onAnalysisComplete;

  const WellnessCheckCard({
    super.key,
    this.onAnalysisComplete,
  });

  @override
  State<WellnessCheckCard> createState() => _WellnessCheckCardState();
}

class _WellnessCheckCardState extends State<WellnessCheckCard> {
  // Paso actual del check-in (0 = inicio, 1 = emociones, 2 = energía, 3 = sueño, 4 = resultado)
  int _currentStep = 0;
  
  // Selecciones del usuario
  EmotionalState? _selectedEmotion;
  EnergyLevel? _selectedEnergy;
  SleepQuality? _selectedSleep;
  
  // Resultado del análisis
  WellnessAnalysisResult? _analysisResult;
  
  final _analysisService = WellnessAnalysisService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark 
                ? AppColors.darkPrimary.withOpacity(0.15) 
                : AppColors.lightPrimary.withOpacity(0.1),
            isDark 
                ? AppColors.darkSecondary.withOpacity(0.1) 
                : AppColors.lightSecondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: isDark 
              ? AppColors.darkPrimary.withOpacity(0.2) 
              : AppColors.lightPrimary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildCurrentStep(isDark),
      ),
    );
  }

  Widget _buildCurrentStep(bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildStartStep(isDark);
      case 1:
        return _buildEmotionStep(isDark);
      case 2:
        return _buildEnergyStep(isDark);
      case 3:
        return _buildSleepStep(isDark);
      case 4:
        return _buildResultStep(isDark);
      default:
        return _buildStartStep(isDark);
    }
  }

  /// Paso inicial - Invitación a hacer check-in
  Widget _buildStartStep(bool isDark) {
    return Column(
      key: const ValueKey('start'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(
          context,
          isDark,
          '¿Cómo te sientes?',
          'Check-in de bienestar',
          Icons.favorite_rounded,
        ),
        const SizedBox(height: AppTheme.spacingL),
        Text(
          'Toma un momento para conectar contigo. Te haré algunas preguntas '
          'para darte recomendaciones personalizadas.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDark 
                ? AppColors.darkTextSecondary 
                : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingL),
        _buildPrimaryButton(
          isDark,
          'Empezar check-in',
          Icons.play_arrow_rounded,
          () => setState(() => _currentStep = 1),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  /// Paso 1 - Selección de estado emocional
  Widget _buildEmotionStep(bool isDark) {
    // Emociones comunes organizadas por categoría
    final emotions = [
      EmotionalState.happy,
      EmotionalState.calm,
      EmotionalState.grateful,
      EmotionalState.neutral,
      EmotionalState.tired,
      EmotionalState.anxious,
      EmotionalState.stressed,
      EmotionalState.sad,
    ];

    return Column(
      key: const ValueKey('emotion'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStepHeader(isDark, 1, 3, '¿Cómo te sientes ahora?'),
        const SizedBox(height: AppTheme.spacingM),
        
        Wrap(
          spacing: AppTheme.spacingS,
          runSpacing: AppTheme.spacingS,
          children: emotions.map((emotion) {
            final isSelected = _selectedEmotion == emotion;
            return _EmotionChip(
              emotion: emotion,
              isSelected: isSelected,
              isDark: isDark,
              onTap: () => setState(() => _selectedEmotion = emotion),
            );
          }).toList(),
        ),
        
        const SizedBox(height: AppTheme.spacingL),
        
        _buildNavigationButtons(
          isDark,
          onBack: () => setState(() => _currentStep = 0),
          onNext: _selectedEmotion != null 
              ? () => setState(() => _currentStep = 2)
              : null,
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }

  /// Paso 2 - Selección de nivel de energía
  Widget _buildEnergyStep(bool isDark) {
    final energyLevels = [
      EnergyLevel.veryLow,
      EnergyLevel.low,
      EnergyLevel.medium,
      EnergyLevel.high,
      EnergyLevel.veryHigh,
    ];

    return Column(
      key: const ValueKey('energy'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStepHeader(isDark, 2, 3, '¿Cómo está tu energía?'),
        const SizedBox(height: AppTheme.spacingM),
        
        ...energyLevels.map((energy) {
          final isSelected = _selectedEnergy == energy;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
            child: _SelectableOption(
              emoji: energy.emoji,
              label: energy.displayName,
              isSelected: isSelected,
              isDark: isDark,
              onTap: () => setState(() => _selectedEnergy = energy),
            ),
          );
        }),
        
        const SizedBox(height: AppTheme.spacingM),
        
        _buildNavigationButtons(
          isDark,
          onBack: () => setState(() => _currentStep = 1),
          onNext: _selectedEnergy != null 
              ? () => setState(() => _currentStep = 3)
              : null,
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }

  /// Paso 3 - Selección de calidad de sueño
  Widget _buildSleepStep(bool isDark) {
    final sleepQualities = [
      SleepQuality.excellent,
      SleepQuality.good,
      SleepQuality.fair,
      SleepQuality.poor,
      SleepQuality.terrible,
    ];

    return Column(
      key: const ValueKey('sleep'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStepHeader(isDark, 3, 3, '¿Cómo dormiste anoche?'),
        const SizedBox(height: AppTheme.spacingM),
        
        ...sleepQualities.map((sleep) {
          final isSelected = _selectedSleep == sleep;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
            child: _SelectableOption(
              emoji: sleep.emoji,
              label: sleep.displayName,
              subtitle: sleep.description,
              isSelected: isSelected,
              isDark: isDark,
              onTap: () => setState(() => _selectedSleep = sleep),
            ),
          );
        }),
        
        const SizedBox(height: AppTheme.spacingM),
        
        _buildNavigationButtons(
          isDark,
          onBack: () => setState(() => _currentStep = 2),
          onNext: _selectedSleep != null ? _runAnalysis : null,
          nextLabel: 'Ver análisis',
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }

  /// Paso 4 - Resultado del análisis
  Widget _buildResultStep(bool isDark) {
    if (_analysisResult == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final result = _analysisResult!;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    
    return Column(
      key: const ValueKey('result'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Score y headline
        Row(
          children: [
            _buildScoreIndicator(result.wellnessScore, isDark),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.headline,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Puntaje de bienestar',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark 
                          ? AppColors.darkTextTertiary 
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppTheme.spacingL),
        
        // Insight
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.darkSurfaceVariant.withOpacity(0.5) 
                : AppColors.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 18,
                    color: primaryColor,
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  Text(
                    'Insight',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                result.insight,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark 
                      ? AppColors.darkTextSecondary 
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppTheme.spacingM),
        
        // Recomendación principal
        if (result.recommendations.isNotEmpty) ...[
          Text(
            'Rutina recomendada',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          _RecommendationCard(
            recommendation: result.recommendations.first,
            isDark: isDark,
          ),
        ],
        
        const SizedBox(height: AppTheme.spacingM),
        
        // Mensaje de ánimo
        Text(
          result.encouragement,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
            color: isDark 
                ? AppColors.darkTextSecondary 
                : AppColors.lightTextSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: AppTheme.spacingL),
        
        // Botón para hacer otro check-in
        _buildSecondaryButton(
          isDark,
          'Nuevo check-in',
          Icons.refresh_rounded,
          _resetCheckin,
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingS),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
              ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: AppTheme.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark 
                      ? AppColors.darkTextTertiary 
                      : AppColors.lightTextTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepHeader(bool isDark, int current, int total, String question) {
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicador de progreso
        Row(
          children: List.generate(total, (index) {
            final isCompleted = index < current;
            final isCurrent = index == current - 1;
            return Expanded(
              child: Container(
                height: 3,
                margin: EdgeInsets.only(right: index < total - 1 ? 4 : 0),
                decoration: BoxDecoration(
                  color: isCompleted || isCurrent
                      ? primaryColor
                      : (isDark 
                          ? Colors.white.withOpacity(0.1) 
                          : Colors.black.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          'Paso $current de $total',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDark 
                ? AppColors.darkTextTertiary 
                : AppColors.lightTextTertiary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          question,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(
    bool isDark, {
    VoidCallback? onBack,
    VoidCallback? onNext,
    String nextLabel = 'Siguiente',
  }) {
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    
    return Row(
      children: [
        if (onBack != null)
          TextButton(
            onPressed: onBack,
            child: Text(
              'Atrás',
              style: TextStyle(
                color: isDark 
                    ? AppColors.darkTextSecondary 
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
        const Spacer(),
        ElevatedButton(
          onPressed: onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: primaryColor.withOpacity(0.3),
            disabledForegroundColor: Colors.white.withOpacity(0.5),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingL,
              vertical: AppTheme.spacingM,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
          ),
          child: Text(nextLabel),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(
    bool isDark,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    bool isDark,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark 
              ? AppColors.darkTextSecondary 
              : AppColors.lightTextSecondary,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
          side: BorderSide(
            color: isDark 
                ? Colors.white.withOpacity(0.2) 
                : Colors.black.withOpacity(0.1),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreIndicator(int score, bool isDark) {
    Color scoreColor;
    if (score >= 70) {
      scoreColor = AppColors.success;
    } else if (score >= 40) {
      scoreColor = AppColors.warning;
    } else {
      scoreColor = AppColors.error;
    }
    
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scoreColor.withOpacity(0.2),
            scoreColor.withOpacity(0.1),
          ],
        ),
        border: Border.all(color: scoreColor, width: 3),
      ),
      child: Center(
        child: Text(
          '$score',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: scoreColor,
          ),
        ),
      ),
    );
  }

  void _runAnalysis() {
    final assessment = WellnessAssessment(
      emotionalState: _selectedEmotion!,
      energyLevel: _selectedEnergy!,
      sleepQuality: _selectedSleep!,
      assessedAt: DateTime.now(),
    );
    
    final result = _analysisService.analyze(assessment);
    
    setState(() {
      _analysisResult = result;
      _currentStep = 4;
    });
    
    widget.onAnalysisComplete?.call(result);
  }

  void _resetCheckin() {
    setState(() {
      _currentStep = 0;
      _selectedEmotion = null;
      _selectedEnergy = null;
      _selectedSleep = null;
      _analysisResult = null;
    });
  }
}

/// Chip de emoción seleccionable
class _EmotionChip extends StatelessWidget {
  final EmotionalState emotion;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _EmotionChip({
    required this.emotion,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
              ? primaryColor.withOpacity(0.2)
              : (isDark 
                  ? AppColors.darkSurfaceVariant.withOpacity(0.5) 
                  : Colors.white.withOpacity(0.8)),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: isSelected 
                ? primaryColor 
                : (isDark 
                    ? Colors.white.withOpacity(0.1) 
                    : Colors.black.withOpacity(0.05)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emotion.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: AppTheme.spacingXS),
            Text(
              emotion.displayName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected 
                    ? primaryColor 
                    : (isDark 
                        ? AppColors.darkTextPrimary 
                        : AppColors.lightTextPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opción seleccionable genérica
class _SelectableOption extends StatelessWidget {
  final String emoji;
  final String label;
  final String? subtitle;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _SelectableOption({
    required this.emoji,
    required this.label,
    this.subtitle,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: isSelected 
              ? primaryColor.withOpacity(0.15)
              : (isDark 
                  ? AppColors.darkSurfaceVariant.withOpacity(0.3) 
                  : Colors.white.withOpacity(0.7)),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: isSelected 
                ? primaryColor 
                : (isDark 
                    ? Colors.white.withOpacity(0.05) 
                    : Colors.black.withOpacity(0.03)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected 
                          ? primaryColor 
                          : (isDark 
                              ? AppColors.darkTextPrimary 
                              : AppColors.lightTextPrimary),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark 
                            ? AppColors.darkTextTertiary 
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de recomendación
class _RecommendationCard extends StatelessWidget {
  final WellnessRecommendation recommendation;
  final bool isDark;

  const _RecommendationCard({
    required this.recommendation,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.15),
            primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  recommendation.ritualName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Text(
                  '${recommendation.durationMinutes} min',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            recommendation.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark 
                  ? AppColors.darkTextSecondary 
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
