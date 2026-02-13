import '../data/models/wellness_assessment_model.dart';

/// Resultado del análisis de bienestar
class WellnessAnalysisResult {
  final int wellnessScore;
  final String headline;
  final String insight;
  final List<WellnessRecommendation> recommendations;
  final String encouragement;
  final WellnessAssessment assessment;

  const WellnessAnalysisResult({
    required this.wellnessScore,
    required this.headline,
    required this.insight,
    required this.recommendations,
    required this.encouragement,
    required this.assessment,
  });
}

/// Recomendación de bienestar con ritual sugerido
class WellnessRecommendation {
  final String title;
  final String description;
  final String ritualName;
  final int durationMinutes;
  final RecommendationPriority priority;
  final String scientificBasis;

  const WellnessRecommendation({
    required this.title,
    required this.description,
    required this.ritualName,
    required this.durationMinutes,
    required this.priority,
    required this.scientificBasis,
  });
}

enum RecommendationPriority { high, medium, low }

/// Servicio de análisis de bienestar basado en psicología y ciencia de hábitos
/// 
/// Este servicio analiza el estado del usuario y proporciona recomendaciones
/// personalizadas basadas en evidencia científica:
/// 
/// - Psicología positiva (Seligman): gratitud, flow, relaciones
/// - Neurociencia del sueño (Walker): recuperación, memoria, estado de ánimo
/// - Regulación emocional (Gross): estrategias adaptativas
/// - Ciencia de hábitos (Clear): micro-rituales, adherencia
/// - Fisiología básica: hidratación, movimiento, respiración
class WellnessAnalysisService {
  
  /// Analiza el estado de bienestar del usuario y genera recomendaciones
  WellnessAnalysisResult analyze(WellnessAssessment assessment) {
    final recommendations = <WellnessRecommendation>[];
    
    // Generar recomendaciones basadas en cada factor
    recommendations.addAll(_getEmotionalRecommendations(assessment));
    recommendations.addAll(_getEnergyRecommendations(assessment));
    recommendations.addAll(_getSleepRecommendations(assessment));
    recommendations.addAll(_getHydrationRecommendations(assessment));
    recommendations.addAll(_getActivityRecommendations(assessment));
    recommendations.addAll(_getStressRecommendations(assessment));
    
    // Ordenar por prioridad y limitar a 3 recomendaciones principales
    recommendations.sort((a, b) => a.priority.index.compareTo(b.priority.index));
    final topRecommendations = recommendations.take(3).toList();
    
    return WellnessAnalysisResult(
      wellnessScore: assessment.wellnessScore,
      headline: _generateHeadline(assessment),
      insight: _generateInsight(assessment),
      recommendations: topRecommendations,
      encouragement: _generateEncouragement(assessment),
      assessment: assessment,
    );
  }

  /// Genera titular basado en el estado general
  String _generateHeadline(WellnessAssessment assessment) {
    final score = assessment.wellnessScore;
    final emotion = assessment.emotionalState;
    
    if (score >= 80) {
      return '¡Excelente estado de bienestar! ${emotion.emoji}';
    } else if (score >= 60) {
      return 'Tu bienestar está en buen camino ${emotion.emoji}';
    } else if (score >= 40) {
      return 'Hay espacio para mejorar tu bienestar ${emotion.emoji}';
    } else {
      return 'Tu cuerpo y mente necesitan atención ${emotion.emoji}';
    }
  }

  /// Genera insight personalizado basado en psicología
  String _generateInsight(WellnessAssessment assessment) {
    final category = assessment.emotionalState.category;
    final sleep = assessment.sleepQuality;
    final energy = assessment.energyLevel;
    
    // Insights basados en la investigación
    if (sleep.score < 0.4 && energy.score < 0.4) {
      return 'La falta de sueño está afectando directamente tu energía y estado emocional. '
             'Los estudios muestran que el sueño es el pilar fundamental del bienestar.';
    }
    
    switch (category) {
      case EmotionalCategory.highNegative:
        return 'Cuando experimentamos emociones intensas negativas, nuestro sistema nervioso '
               'está en modo "lucha o huida". La respiración consciente activa el nervio vago '
               'y ayuda a restablecer la calma.';
      
      case EmotionalCategory.lowNegative:
        return 'Los estados de baja energía emocional pueden indicar necesidad de conexión, '
               'descanso o un cambio de perspectiva. Pequeñas acciones pueden generar un '
               'efecto dominó positivo.';
      
      case EmotionalCategory.highPositive:
        return '¡Estás en un estado óptimo! La psicología positiva sugiere aprovechar estos '
               'momentos para fortalecer relaciones y practicar la gratitud, creando reservas '
               'emocionales para momentos difíciles.';
      
      case EmotionalCategory.lowPositive:
        return 'La calma y la relajación son estados valiosos que favorecen la recuperación '
               'y la introspección. Es un buen momento para mindfulness y actividades creativas.';
      
      case EmotionalCategory.neutral:
        return 'Un estado neutral es una oportunidad perfecta para establecer hábitos positivos. '
               'Las micro-rutinas son más efectivas cuando no estamos en estados emocionales extremos.';
    }
  }

  /// Genera mensaje de ánimo personalizado
  String _generateEncouragement(WellnessAssessment assessment) {
    final score = assessment.wellnessScore;
    final category = assessment.emotionalState.category;
    
    final encouragements = <String>[];
    
    if (score >= 70) {
      encouragements.addAll([
        '¡Sigue así! Cada pequeña rutina suma.',
        'Tu constancia está dando frutos. ¡Bien hecho!',
        'Mantener el bienestar es un logro diario.',
      ]);
    } else if (score >= 40) {
      encouragements.addAll([
        'Cada paso cuenta, por pequeño que sea.',
        'Reconocer cómo te sientes ya es un gran avance.',
        'Hoy es un buen día para una micro-rutina.',
      ]);
    } else {
      encouragements.addAll([
        'Está bien no estar bien. Sé amable contigo.',
        'Una pequeña rutina puede marcar la diferencia.',
        'Tu bienestar merece atención. Empecemos juntos.',
      ]);
    }
    
    // Seleccionar basado en categoría emocional
    if (category == EmotionalCategory.highNegative) {
      encouragements.addAll([
        'Las emociones intensas son temporales. Esto también pasará.',
        'Respirar profundo es el primer paso hacia la calma.',
      ]);
    } else if (category == EmotionalCategory.lowNegative) {
      encouragements.addAll([
        'A veces necesitamos ir más despacio. Está bien.',
        'La tristeza también es parte de la experiencia humana.',
      ]);
    }
    
    // Seleccionar aleatoriamente para variedad
    final index = DateTime.now().millisecond % encouragements.length;
    return encouragements[index];
  }

  /// Recomendaciones basadas en estado emocional
  List<WellnessRecommendation> _getEmotionalRecommendations(WellnessAssessment assessment) {
    final recommendations = <WellnessRecommendation>[];
    final state = assessment.emotionalState;
    
    switch (state.category) {
      case EmotionalCategory.highNegative:
        // Alta energía negativa: necesita regulación inmediata
        recommendations.add(const WellnessRecommendation(
          title: 'Calma tu sistema nervioso',
          description: 'La técnica 4-7-8 activa el sistema nervioso parasimpático, '
                      'reduciendo la respuesta de estrés en minutos.',
          ritualName: 'Respiración 4-7-8',
          durationMinutes: 3,
          priority: RecommendationPriority.high,
          scientificBasis: 'La respiración diafragmática lenta estimula el nervio vago, '
                          'reduciendo cortisol y frecuencia cardíaca.',
        ));
        
        if (state == EmotionalState.anxious || state == EmotionalState.stressed) {
          recommendations.add(const WellnessRecommendation(
            title: 'Ancla tu atención',
            description: 'La técnica 5-4-3-2-1 usa los sentidos para traerte al presente, '
                        'interrumpiendo pensamientos ansiosos.',
            ritualName: 'Grounding sensorial',
            durationMinutes: 5,
            priority: RecommendationPriority.high,
            scientificBasis: 'El mindfulness sensorial reduce la actividad de la amígdala, '
                            'centro cerebral del miedo.',
          ));
        }
        break;
        
      case EmotionalCategory.lowNegative:
        // Baja energía negativa: necesita activación suave
        recommendations.add(const WellnessRecommendation(
          title: 'Activa tu cuerpo suavemente',
          description: 'El movimiento libera endorfinas y mejora el estado de ánimo '
                      'incluso cuando no tenemos ganas.',
          ritualName: 'Estiramientos suaves',
          durationMinutes: 5,
          priority: RecommendationPriority.high,
          scientificBasis: 'El ejercicio de baja intensidad aumenta serotonina y dopamina, '
                          'neurotransmisores asociados al bienestar.',
        ));
        
        recommendations.add(const WellnessRecommendation(
          title: 'Practica la gratitud',
          description: 'Pensar en 3 cosas positivas rewire el cerebro hacia lo positivo.',
          ritualName: 'Gratitud consciente',
          durationMinutes: 3,
          priority: RecommendationPriority.medium,
          scientificBasis: 'La gratitud activa regiones cerebrales asociadas con dopamina '
                          'y reduce marcadores inflamatorios.',
        ));
        break;
        
      case EmotionalCategory.highPositive:
        // Alta energía positiva: capitalizar el momento
        recommendations.add(const WellnessRecommendation(
          title: 'Ancla este momento',
          description: 'Cuando te sientes bien, es el mejor momento para fortalecer '
                      'conexiones y crear memorias positivas.',
          ritualName: 'Gratitud consciente',
          durationMinutes: 2,
          priority: RecommendationPriority.medium,
          scientificBasis: 'El "savoring" (saborear momentos positivos) amplifica '
                          'emociones positivas y construye resiliencia.',
        ));
        break;
        
      case EmotionalCategory.lowPositive:
        // Baja energía positiva: mantener y profundizar
        recommendations.add(const WellnessRecommendation(
          title: 'Profundiza la calma',
          description: 'La meditación en estados de calma es más efectiva y '
                      'fortalece la práctica.',
          ritualName: 'Pausa de observación',
          durationMinutes: 5,
          priority: RecommendationPriority.low,
          scientificBasis: 'La meditación regular aumenta la densidad de materia gris '
                          'en áreas de autorregulación.',
        ));
        break;
        
      case EmotionalCategory.neutral:
        // Estado neutral: buen momento para establecer hábitos
        recommendations.add(const WellnessRecommendation(
          title: 'Establece tu intención',
          description: 'Un estado neutral es ideal para crear nuevos hábitos positivos.',
          ritualName: 'Respiración consciente',
          durationMinutes: 3,
          priority: RecommendationPriority.low,
          scientificBasis: 'Los hábitos se forman más fácilmente en estados '
                          'emocionales neutros o ligeramente positivos.',
        ));
        break;
    }
    
    return recommendations;
  }

  /// Recomendaciones basadas en nivel de energía
  List<WellnessRecommendation> _getEnergyRecommendations(WellnessAssessment assessment) {
    final recommendations = <WellnessRecommendation>[];
    final energy = assessment.energyLevel;
    
    if (energy == EnergyLevel.veryLow || energy == EnergyLevel.low) {
      recommendations.add(const WellnessRecommendation(
        title: 'Reactiva tu energía',
        description: 'El movimiento suave puede ser más efectivo que el descanso '
                    'para combatir la fatiga mental.',
        ritualName: 'Estiramientos energizantes',
        durationMinutes: 5,
        priority: RecommendationPriority.high,
        scientificBasis: 'Estudios muestran que 10 minutos de caminata aumentan '
                        'la energía más que una taza de café.',
      ));
    } else if (energy == EnergyLevel.veryHigh) {
      recommendations.add(const WellnessRecommendation(
        title: 'Canaliza tu energía',
        description: 'La alta energía es valiosa, pero necesita dirección. '
                    'Un momento de enfoque puede potenciar tu productividad.',
        ritualName: 'Respiración enfocada',
        durationMinutes: 2,
        priority: RecommendationPriority.low,
        scientificBasis: 'La activación controlada mejora el rendimiento cognitivo '
                        'comparado con estados de sobre-estimulación.',
      ));
    }
    
    return recommendations;
  }

  /// Recomendaciones basadas en calidad de sueño
  List<WellnessRecommendation> _getSleepRecommendations(WellnessAssessment assessment) {
    final recommendations = <WellnessRecommendation>[];
    final sleep = assessment.sleepQuality;
    
    if (sleep == SleepQuality.terrible || sleep == SleepQuality.poor) {
      recommendations.add(const WellnessRecommendation(
        title: 'Compensa la falta de sueño',
        description: 'Aunque nada reemplaza el sueño, la respiración profunda '
                    'puede reducir algunos efectos negativos.',
        ritualName: 'Respiración restauradora',
        durationMinutes: 5,
        priority: RecommendationPriority.high,
        scientificBasis: 'La privación de sueño aumenta el cortisol. '
                        'La respiración diafragmática ayuda a contrarrestarlo.',
      ));
      
      recommendations.add(const WellnessRecommendation(
        title: 'Evita la espiral negativa',
        description: 'El mal sueño afecta el juicio emocional. Hoy sé extra '
                    'compasivo contigo mismo.',
        ritualName: 'Autocompasión mindful',
        durationMinutes: 3,
        priority: RecommendationPriority.medium,
        scientificBasis: 'La falta de sueño reduce la actividad prefrontal, '
                        'dificultando la regulación emocional.',
      ));
    }
    
    return recommendations;
  }

  /// Recomendaciones basadas en hidratación
  List<WellnessRecommendation> _getHydrationRecommendations(WellnessAssessment assessment) {
    final recommendations = <WellnessRecommendation>[];
    final hydration = assessment.hydrationLevel;
    
    if (hydration == HydrationLevel.dehydrated || hydration == HydrationLevel.low) {
      recommendations.add(const WellnessRecommendation(
        title: 'Hidrátate conscientemente',
        description: 'La deshidratación leve afecta el estado de ánimo y la cognición '
                    'antes de que notes sed.',
        ritualName: 'Hidratación mindful',
        durationMinutes: 2,
        priority: RecommendationPriority.high,
        scientificBasis: 'Solo 1-2% de deshidratación reduce la concentración y '
                        'aumenta ansiedad y fatiga.',
      ));
    }
    
    return recommendations;
  }

  /// Recomendaciones basadas en actividad física
  List<WellnessRecommendation> _getActivityRecommendations(WellnessAssessment assessment) {
    final recommendations = <WellnessRecommendation>[];
    final activity = assessment.physicalActivity;
    
    if (activity == PhysicalActivity.none) {
      recommendations.add(const WellnessRecommendation(
        title: 'Rompe el sedentarismo',
        description: 'Incluso pequeños movimientos cuentan. Tu cuerpo necesita '
                    'moverse para funcionar óptimamente.',
        ritualName: 'Micro-movimientos',
        durationMinutes: 3,
        priority: RecommendationPriority.medium,
        scientificBasis: 'Sentarse más de 8 horas aumenta riesgo de depresión. '
                        'Pausas activas de 3 min cada hora mitigan el efecto.',
      ));
    } else if (activity == PhysicalActivity.intense) {
      recommendations.add(const WellnessRecommendation(
        title: 'Recupera tu cuerpo',
        description: 'Después de ejercicio intenso, el cuerpo necesita recuperación '
                    'activa para optimizar los beneficios.',
        ritualName: 'Estiramientos de recuperación',
        durationMinutes: 5,
        priority: RecommendationPriority.medium,
        scientificBasis: 'La recuperación activa reduce DOMS (dolor muscular) '
                        'y mejora la adaptación al entrenamiento.',
      ));
    }
    
    return recommendations;
  }

  /// Recomendaciones basadas en factores de estrés
  List<WellnessRecommendation> _getStressRecommendations(WellnessAssessment assessment) {
    final recommendations = <WellnessRecommendation>[];
    final stressors = assessment.stressFactors;
    
    if (stressors.length >= 2) {
      recommendations.add(const WellnessRecommendation(
        title: 'Gestiona múltiples estresores',
        description: 'Cuando hay varios factores de estrés, es crucial tener '
                    'una práctica diaria de regulación.',
        ritualName: 'Pausa de descarga',
        durationMinutes: 5,
        priority: RecommendationPriority.high,
        scientificBasis: 'El estrés crónico acumulativo tiene efectos exponenciales. '
                        'Rutinas diarias actúan como "válvula de escape".',
      ));
    } else if (stressors.isNotEmpty) {
      final stressor = stressors.first;
      recommendations.add(WellnessRecommendation(
        title: 'Atiende tu preocupación',
        description: 'El estrés por ${stressor.displayName.toLowerCase()} es común. '
                    'Reconocerlo es el primer paso para manejarlo.',
        ritualName: 'Mindfulness focalizado',
        durationMinutes: 3,
        priority: RecommendationPriority.medium,
        scientificBasis: 'Nombrar las preocupaciones reduce la activación de '
                        'la amígdala (efecto "name it to tame it").',
      ));
    }
    
    return recommendations;
  }
}
