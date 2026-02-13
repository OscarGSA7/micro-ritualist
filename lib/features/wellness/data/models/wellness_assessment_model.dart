/// Modelo de evaluación de bienestar basado en psicología positiva
/// y ciencia de hábitos saludables
/// 
/// Referencias científicas:
/// - Psicología Positiva (Seligman, 2011)
/// - Ciencia del sueño (Walker, 2017)
/// - Regulación emocional (Gross, 2014)
/// - Hábitos atómicos (Clear, 2018)
library;

/// Evaluación de bienestar del usuario
class WellnessAssessment {
  final EmotionalState emotionalState;
  final EnergyLevel energyLevel;
  final SleepQuality sleepQuality;
  final HydrationLevel hydrationLevel;
  final PhysicalActivity physicalActivity;
  final List<StressFactor> stressFactors;
  final DateTime assessedAt;

  const WellnessAssessment({
    required this.emotionalState,
    required this.energyLevel,
    required this.sleepQuality,
    this.hydrationLevel = HydrationLevel.unknown,
    this.physicalActivity = PhysicalActivity.unknown,
    this.stressFactors = const [],
    required this.assessedAt,
  });

  /// Calcula el puntaje general de bienestar (0-100)
  int get wellnessScore {
    int score = 0;
    
    // Estado emocional (40% del puntaje)
    score += (emotionalState.positivityScore * 40).round();
    
    // Energía (20% del puntaje)
    score += (energyLevel.score * 20).round();
    
    // Sueño (25% del puntaje)
    score += (sleepQuality.score * 25).round();
    
    // Hidratación (10% del puntaje)
    if (hydrationLevel != HydrationLevel.unknown) {
      score += (hydrationLevel.score * 10).round();
    } else {
      score += 5; // Puntaje neutral si no se conoce
    }
    
    // Actividad física (5% del puntaje)
    if (physicalActivity != PhysicalActivity.unknown) {
      score += (physicalActivity.score * 5).round();
    } else {
      score += 2; // Puntaje neutral si no se conoce
    }
    
    // Penalización por factores de estrés
    final stressPenalty = stressFactors.length * 3;
    score = (score - stressPenalty).clamp(0, 100);
    
    return score;
  }

  Map<String, dynamic> toJson() => {
    'emotionalState': emotionalState.name,
    'energyLevel': energyLevel.name,
    'sleepQuality': sleepQuality.name,
    'hydrationLevel': hydrationLevel.name,
    'physicalActivity': physicalActivity.name,
    'stressFactors': stressFactors.map((e) => e.name).toList(),
    'assessedAt': assessedAt.toIso8601String(),
    'wellnessScore': wellnessScore,
  };
}

/// Estados emocionales basados en el modelo circunflejo de Russell
enum EmotionalState {
  // Alta energía positiva
  excited,      // Emocionado
  happy,        // Feliz
  grateful,     // Agradecido
  
  // Baja energía positiva
  calm,         // Calmado
  relaxed,      // Relajado
  peaceful,     // En paz
  
  // Alta energía negativa
  anxious,      // Ansioso
  stressed,     // Estresado
  frustrated,   // Frustrado
  angry,        // Enojado
  
  // Baja energía negativa
  sad,          // Triste
  tired,        // Cansado
  bored,        // Aburrido
  lonely,       // Solo
  
  // Neutral
  neutral,      // Neutral
}

extension EmotionalStateExtension on EmotionalState {
  String get displayName {
    switch (this) {
      case EmotionalState.excited: return 'Emocionado';
      case EmotionalState.happy: return 'Feliz';
      case EmotionalState.grateful: return 'Agradecido';
      case EmotionalState.calm: return 'Calmado';
      case EmotionalState.relaxed: return 'Relajado';
      case EmotionalState.peaceful: return 'En paz';
      case EmotionalState.anxious: return 'Ansioso';
      case EmotionalState.stressed: return 'Estresado';
      case EmotionalState.frustrated: return 'Frustrado';
      case EmotionalState.angry: return 'Enojado';
      case EmotionalState.sad: return 'Triste';
      case EmotionalState.tired: return 'Cansado';
      case EmotionalState.bored: return 'Aburrido';
      case EmotionalState.lonely: return 'Solo';
      case EmotionalState.neutral: return 'Neutral';
    }
  }

  String get emoji {
    switch (this) {
      case EmotionalState.excited: return '🤩';
      case EmotionalState.happy: return '😊';
      case EmotionalState.grateful: return '🙏';
      case EmotionalState.calm: return '😌';
      case EmotionalState.relaxed: return '😎';
      case EmotionalState.peaceful: return '☮️';
      case EmotionalState.anxious: return '😰';
      case EmotionalState.stressed: return '😫';
      case EmotionalState.frustrated: return '😤';
      case EmotionalState.angry: return '😠';
      case EmotionalState.sad: return '😢';
      case EmotionalState.tired: return '😴';
      case EmotionalState.bored: return '😑';
      case EmotionalState.lonely: return '🥺';
      case EmotionalState.neutral: return '😐';
    }
  }

  /// Puntaje de positividad (0.0 - 1.0)
  double get positivityScore {
    switch (this) {
      case EmotionalState.excited: return 1.0;
      case EmotionalState.happy: return 0.95;
      case EmotionalState.grateful: return 0.9;
      case EmotionalState.calm: return 0.85;
      case EmotionalState.relaxed: return 0.8;
      case EmotionalState.peaceful: return 0.85;
      case EmotionalState.neutral: return 0.5;
      case EmotionalState.bored: return 0.4;
      case EmotionalState.tired: return 0.35;
      case EmotionalState.lonely: return 0.25;
      case EmotionalState.sad: return 0.2;
      case EmotionalState.frustrated: return 0.2;
      case EmotionalState.anxious: return 0.15;
      case EmotionalState.stressed: return 0.1;
      case EmotionalState.angry: return 0.05;
    }
  }

  /// Categoría del estado emocional
  EmotionalCategory get category {
    switch (this) {
      case EmotionalState.excited:
      case EmotionalState.happy:
      case EmotionalState.grateful:
        return EmotionalCategory.highPositive;
      case EmotionalState.calm:
      case EmotionalState.relaxed:
      case EmotionalState.peaceful:
        return EmotionalCategory.lowPositive;
      case EmotionalState.anxious:
      case EmotionalState.stressed:
      case EmotionalState.frustrated:
      case EmotionalState.angry:
        return EmotionalCategory.highNegative;
      case EmotionalState.sad:
      case EmotionalState.tired:
      case EmotionalState.bored:
      case EmotionalState.lonely:
        return EmotionalCategory.lowNegative;
      case EmotionalState.neutral:
        return EmotionalCategory.neutral;
    }
  }
}

enum EmotionalCategory {
  highPositive,   // Alta energía, emociones positivas
  lowPositive,    // Baja energía, emociones positivas
  highNegative,   // Alta energía, emociones negativas
  lowNegative,    // Baja energía, emociones negativas
  neutral,        // Estado neutral
}

/// Nivel de energía física
enum EnergyLevel {
  veryLow,    // Muy baja - Agotado
  low,        // Baja - Cansado
  medium,     // Media - Normal
  high,       // Alta - Energizado
  veryHigh,   // Muy alta - Hiperactivo
}

extension EnergyLevelExtension on EnergyLevel {
  String get displayName {
    switch (this) {
      case EnergyLevel.veryLow: return 'Muy baja';
      case EnergyLevel.low: return 'Baja';
      case EnergyLevel.medium: return 'Normal';
      case EnergyLevel.high: return 'Alta';
      case EnergyLevel.veryHigh: return 'Muy alta';
    }
  }

  String get emoji {
    switch (this) {
      case EnergyLevel.veryLow: return '🪫';
      case EnergyLevel.low: return '🔋';
      case EnergyLevel.medium: return '⚡';
      case EnergyLevel.high: return '💪';
      case EnergyLevel.veryHigh: return '🚀';
    }
  }

  double get score {
    switch (this) {
      case EnergyLevel.veryLow: return 0.1;
      case EnergyLevel.low: return 0.35;
      case EnergyLevel.medium: return 0.6;
      case EnergyLevel.high: return 0.85;
      case EnergyLevel.veryHigh: return 1.0;
    }
  }
}

/// Calidad de sueño la noche anterior
enum SleepQuality {
  terrible,   // Muy mal - menos de 4 horas
  poor,       // Mal - 4-5 horas
  fair,       // Regular - 5-6 horas
  good,       // Bien - 6-7 horas
  excellent,  // Excelente - 7-9 horas
}

extension SleepQualityExtension on SleepQuality {
  String get displayName {
    switch (this) {
      case SleepQuality.terrible: return 'Muy mal';
      case SleepQuality.poor: return 'Mal';
      case SleepQuality.fair: return 'Regular';
      case SleepQuality.good: return 'Bien';
      case SleepQuality.excellent: return 'Excelente';
    }
  }

  String get description {
    switch (this) {
      case SleepQuality.terrible: return 'Menos de 4 horas';
      case SleepQuality.poor: return '4-5 horas';
      case SleepQuality.fair: return '5-6 horas';
      case SleepQuality.good: return '6-7 horas';
      case SleepQuality.excellent: return '7-9 horas';
    }
  }

  String get emoji {
    switch (this) {
      case SleepQuality.terrible: return '😵';
      case SleepQuality.poor: return '😪';
      case SleepQuality.fair: return '🥱';
      case SleepQuality.good: return '😊';
      case SleepQuality.excellent: return '😴✨';
    }
  }

  double get score {
    switch (this) {
      case SleepQuality.terrible: return 0.1;
      case SleepQuality.poor: return 0.3;
      case SleepQuality.fair: return 0.5;
      case SleepQuality.good: return 0.8;
      case SleepQuality.excellent: return 1.0;
    }
  }
}

/// Nivel de hidratación
enum HydrationLevel {
  unknown,
  dehydrated,   // Deshidratado
  low,          // Poca agua
  adequate,     // Adecuada
  wellHydrated, // Bien hidratado
}

extension HydrationLevelExtension on HydrationLevel {
  String get displayName {
    switch (this) {
      case HydrationLevel.unknown: return 'No sé';
      case HydrationLevel.dehydrated: return 'Deshidratado';
      case HydrationLevel.low: return 'Poca agua';
      case HydrationLevel.adequate: return 'Adecuada';
      case HydrationLevel.wellHydrated: return 'Bien hidratado';
    }
  }

  String get emoji {
    switch (this) {
      case HydrationLevel.unknown: return '❓';
      case HydrationLevel.dehydrated: return '🏜️';
      case HydrationLevel.low: return '💧';
      case HydrationLevel.adequate: return '💦';
      case HydrationLevel.wellHydrated: return '🌊';
    }
  }

  double get score {
    switch (this) {
      case HydrationLevel.unknown: return 0.5;
      case HydrationLevel.dehydrated: return 0.1;
      case HydrationLevel.low: return 0.4;
      case HydrationLevel.adequate: return 0.75;
      case HydrationLevel.wellHydrated: return 1.0;
    }
  }
}

/// Actividad física reciente
enum PhysicalActivity {
  unknown,
  none,         // Sin actividad
  light,        // Ligera (caminar)
  moderate,     // Moderada (ejercicio suave)
  intense,      // Intensa (ejercicio fuerte)
}

extension PhysicalActivityExtension on PhysicalActivity {
  String get displayName {
    switch (this) {
      case PhysicalActivity.unknown: return 'No recuerdo';
      case PhysicalActivity.none: return 'Sin actividad';
      case PhysicalActivity.light: return 'Ligera';
      case PhysicalActivity.moderate: return 'Moderada';
      case PhysicalActivity.intense: return 'Intensa';
    }
  }

  String get emoji {
    switch (this) {
      case PhysicalActivity.unknown: return '❓';
      case PhysicalActivity.none: return '🛋️';
      case PhysicalActivity.light: return '🚶';
      case PhysicalActivity.moderate: return '🏃';
      case PhysicalActivity.intense: return '💪';
    }
  }

  double get score {
    switch (this) {
      case PhysicalActivity.unknown: return 0.5;
      case PhysicalActivity.none: return 0.2;
      case PhysicalActivity.light: return 0.5;
      case PhysicalActivity.moderate: return 0.8;
      case PhysicalActivity.intense: return 1.0;
    }
  }
}

/// Factores de estrés que pueden afectar el bienestar
enum StressFactor {
  work,           // Trabajo
  relationships,  // Relaciones
  health,         // Salud
  finances,       // Finanzas
  future,         // Preocupación por el futuro
  family,         // Familia
  studies,        // Estudios
}

extension StressFactorExtension on StressFactor {
  String get displayName {
    switch (this) {
      case StressFactor.work: return 'Trabajo';
      case StressFactor.relationships: return 'Relaciones';
      case StressFactor.health: return 'Salud';
      case StressFactor.finances: return 'Finanzas';
      case StressFactor.future: return 'Futuro';
      case StressFactor.family: return 'Familia';
      case StressFactor.studies: return 'Estudios';
    }
  }

  String get emoji {
    switch (this) {
      case StressFactor.work: return '💼';
      case StressFactor.relationships: return '💔';
      case StressFactor.health: return '🏥';
      case StressFactor.finances: return '💰';
      case StressFactor.future: return '🔮';
      case StressFactor.family: return '👨‍👩‍👧';
      case StressFactor.studies: return '📚';
    }
  }
}
