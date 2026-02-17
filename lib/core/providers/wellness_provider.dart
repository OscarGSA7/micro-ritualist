import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/wellness/data/models/wellness_assessment_model.dart';
import '../../features/wellness/services/wellness_analysis_service.dart';
import '../config/supabase_config.dart';
import '../services/supabase_service.dart';

/// Estado del wellness check-in
class WellnessState {
  final WellnessAnalysisResult? todayResult;
  final EmotionalState? todayEmotion;
  final EnergyLevel? todayEnergy;
  final SleepQuality? todaySleep;
  final List<WellnessHistoryItem> history;
  final bool isLoading;
  final String? error;
  final DateTime? lastCheckInDate;

  const WellnessState({
    this.todayResult,
    this.todayEmotion,
    this.todayEnergy,
    this.todaySleep,
    this.history = const [],
    this.isLoading = false,
    this.error,
    this.lastCheckInDate,
  });

  WellnessState copyWith({
    WellnessAnalysisResult? todayResult,
    EmotionalState? todayEmotion,
    EnergyLevel? todayEnergy,
    SleepQuality? todaySleep,
    List<WellnessHistoryItem>? history,
    bool? isLoading,
    String? error,
    DateTime? lastCheckInDate,
    bool clearTodayResult = false,
  }) {
    return WellnessState(
      todayResult: clearTodayResult ? null : (todayResult ?? this.todayResult),
      todayEmotion: clearTodayResult ? null : (todayEmotion ?? this.todayEmotion),
      todayEnergy: clearTodayResult ? null : (todayEnergy ?? this.todayEnergy),
      todaySleep: clearTodayResult ? null : (todaySleep ?? this.todaySleep),
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastCheckInDate: lastCheckInDate ?? this.lastCheckInDate,
    );
  }

  /// Verificar si ya se hizo check-in hoy
  bool get hasCheckedInToday {
    if (lastCheckInDate == null) return false;
    final now = DateTime.now();
    return lastCheckInDate!.year == now.year &&
           lastCheckInDate!.month == now.month &&
           lastCheckInDate!.day == now.day;
  }
}

/// Item del historial de wellness
class WellnessHistoryItem {
  final String id;
  final DateTime date;
  final int wellnessScore;
  final String emotionalState;
  final String energyLevel;
  final String sleepQuality;
  final String? headline;

  const WellnessHistoryItem({
    required this.id,
    required this.date,
    required this.wellnessScore,
    required this.emotionalState,
    required this.energyLevel,
    required this.sleepQuality,
    this.headline,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'wellnessScore': wellnessScore,
    'emotionalState': emotionalState,
    'energyLevel': energyLevel,
    'sleepQuality': sleepQuality,
    'headline': headline,
  };

  factory WellnessHistoryItem.fromJson(Map<String, dynamic> json) {
    return WellnessHistoryItem(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      wellnessScore: json['wellnessScore'] as int,
      emotionalState: json['emotionalState'] as String,
      energyLevel: json['energyLevel'] as String,
      sleepQuality: json['sleepQuality'] as String,
      headline: json['headline'] as String?,
    );
  }
}

/// Provider de wellness
final wellnessProvider = StateNotifierProvider<WellnessNotifier, WellnessState>((ref) {
  return WellnessNotifier();
});

class WellnessNotifier extends StateNotifier<WellnessState> {
  WellnessNotifier() : super(const WellnessState()) {
    _loadFromLocal();
  }

  static const String _todayDataKey = 'wellness_today_data';
  static const String _lastCheckInKey = 'wellness_last_checkin';
  static const String _historyKey = 'wellness_history';

  /// Cargar datos desde almacenamiento local
  Future<void> _loadFromLocal() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cargar última fecha de check-in
      final lastCheckInStr = prefs.getString(_lastCheckInKey);
      DateTime? lastCheckIn;
      if (lastCheckInStr != null) {
        lastCheckIn = DateTime.tryParse(lastCheckInStr);
      }
      
      // Cargar datos de hoy si existe y es del mismo día
      EmotionalState? emotion;
      EnergyLevel? energy;
      SleepQuality? sleep;
      WellnessAnalysisResult? todayResult;
      
      if (lastCheckIn != null) {
        final now = DateTime.now();
        final isToday = lastCheckIn.year == now.year &&
                        lastCheckIn.month == now.month &&
                        lastCheckIn.day == now.day;
        
        if (isToday) {
          final todayJson = prefs.getString(_todayDataKey);
          if (todayJson != null) {
            final data = jsonDecode(todayJson) as Map<String, dynamic>;
            emotion = _parseEmotionalState(data['emotion'] as String?);
            energy = _parseEnergyLevel(data['energy'] as String?);
            sleep = _parseSleepQuality(data['sleep'] as String?);
            
            // Recrear el resultado si tenemos todos los datos
            if (emotion != null && energy != null && sleep != null) {
              final assessment = WellnessAssessment(
                emotionalState: emotion,
                energyLevel: energy,
                sleepQuality: sleep,
                assessedAt: lastCheckIn,
              );
              todayResult = WellnessAnalysisService().analyze(assessment);
            }
          }
        }
      }
      
      // Cargar historial
      final historyJson = prefs.getString(_historyKey);
      List<WellnessHistoryItem> history = [];
      if (historyJson != null) {
        final List<dynamic> historyList = jsonDecode(historyJson);
        history = historyList
            .map((e) => WellnessHistoryItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      
      state = state.copyWith(
        todayResult: todayResult,
        todayEmotion: emotion,
        todayEnergy: energy,
        todaySleep: sleep,
        lastCheckInDate: lastCheckIn,
        history: history,
        isLoading: false,
      );
      
      // Si Supabase está configurado, sincronizar historial
      if (SupabaseConfig.isConfigured) {
        await _syncFromServer();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar datos: $e',
      );
    }
  }

  EmotionalState? _parseEmotionalState(String? name) {
    if (name == null) return null;
    try {
      return EmotionalState.values.firstWhere((e) => e.name == name);
    } catch (_) {
      return null;
    }
  }

  EnergyLevel? _parseEnergyLevel(String? name) {
    if (name == null) return null;
    try {
      return EnergyLevel.values.firstWhere((e) => e.name == name);
    } catch (_) {
      return null;
    }
  }

  SleepQuality? _parseSleepQuality(String? name) {
    if (name == null) return null;
    try {
      return SleepQuality.values.firstWhere((e) => e.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Sincronizar desde el servidor
  Future<void> _syncFromServer() async {
    try {
      final client = SupabaseService.instance.clientOrNull;
      final userId = SupabaseService.instance.currentUserId;
      
      if (client == null || userId == null) return;
      
      // Obtener historial de los últimos 30 días
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      final response = await client
          .from('wellness_assessments')
          .select()
          .eq('user_id', userId)
          .gte('assessed_at', thirtyDaysAgo.toUtc().toIso8601String())
          .order('assessed_at', ascending: false)
          .limit(30);
      
      if (response != null && response is List) {
        final serverHistory = response.map((e) => WellnessHistoryItem(
          id: e['id'] as String,
          date: DateTime.parse(e['assessed_at'] as String),
          wellnessScore: e['wellness_score'] as int? ?? 50,
          emotionalState: e['emotional_state'] as String,
          energyLevel: e['energy_level'] as String,
          sleepQuality: e['sleep_quality'] as String,
        )).toList();
        
        if (serverHistory.isNotEmpty) {
          state = state.copyWith(history: serverHistory);
          await _saveHistoryToLocal(serverHistory);
        }
      }
    } catch (e) {
      // Silenciar errores de sincronización
      _debugPrint('Error syncing wellness: $e');
    }
  }

  /// Guardar un nuevo check-in
  Future<void> saveCheckIn({
    required EmotionalState emotion,
    required EnergyLevel energy,
    required SleepQuality sleep,
    required WellnessAnalysisResult result,
  }) async {
    try {
      final now = DateTime.now();
      
      // Guardar resultado localmente
      state = state.copyWith(
        todayResult: result,
        todayEmotion: emotion,
        todayEnergy: energy,
        todaySleep: sleep,
        lastCheckInDate: now,
      );
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastCheckInKey, now.toIso8601String());
      await prefs.setString(_todayDataKey, jsonEncode({
        'emotion': emotion.name,
        'energy': energy.name,
        'sleep': sleep.name,
      }));
      
      // Crear item de historial
      final historyItem = WellnessHistoryItem(
        id: 'local_${now.millisecondsSinceEpoch}',
        date: now,
        wellnessScore: result.wellnessScore,
        emotionalState: emotion.name,
        energyLevel: energy.name,
        sleepQuality: sleep.name,
        headline: result.headline,
      );
      
      // Añadir al historial local (evitar duplicados de hoy)
      final newHistory = [
        historyItem,
        ...state.history.where((h) => 
          !(h.date.year == now.year && h.date.month == now.month && h.date.day == now.day)
        ),
      ];
      state = state.copyWith(history: newHistory);
      await _saveHistoryToLocal(newHistory);
      
      // Guardar en servidor si está disponible
      if (SupabaseConfig.isConfigured) {
        await _saveToServer(emotion, energy, sleep, result);
      }
    } catch (e) {
      state = state.copyWith(error: 'Error al guardar check-in: $e');
    }
  }

  /// Guardar en el servidor
  Future<void> _saveToServer(
    EmotionalState emotion,
    EnergyLevel energy,
    SleepQuality sleep,
    WellnessAnalysisResult result,
  ) async {
    try {
      final client = SupabaseService.instance.clientOrNull;
      final userId = SupabaseService.instance.currentUserId;
      
      if (client == null || userId == null) return;
      
      await client.from('wellness_assessments').insert({
        'user_id': userId,
        'emotional_state': emotion.name,
        'energy_level': _energyLevelToDb(energy),
        'sleep_quality': sleep.name,
        'wellness_score': result.wellnessScore,
        'assessed_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      _debugPrint('Error saving to server: $e');
    }
  }

  /// Convertir EnergyLevel de Flutter a valor de la DB
  String _energyLevelToDb(EnergyLevel level) {
    switch (level) {
      case EnergyLevel.veryLow:
        return 'very_low';
      case EnergyLevel.low:
        return 'low';
      case EnergyLevel.medium:
        return 'moderate';
      case EnergyLevel.high:
        return 'high';
      case EnergyLevel.veryHigh:
        return 'very_high';
    }
  }

  /// Resetear check-in de hoy (para hacer otro)
  Future<void> resetTodayCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_todayDataKey);
    state = state.copyWith(clearTodayResult: true);
  }

  /// Guardar historial localmente
  Future<void> _saveHistoryToLocal(List<WellnessHistoryItem> history) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = history.take(30).map((e) => e.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  void _debugPrint(String message) {
    // ignore: avoid_print
    print(message);
  }
}
