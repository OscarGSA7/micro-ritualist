import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Modelo de racha para la base de datos
class StreakDbModel {
  final String id;
  final String userId;
  final String ritualId;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedDate;
  final DateTime? streakStartedAt;
  final DateTime updatedAt;

  const StreakDbModel({
    required this.id,
    required this.userId,
    required this.ritualId,
    required this.currentStreak,
    required this.longestStreak,
    this.lastCompletedDate,
    this.streakStartedAt,
    required this.updatedAt,
  });

  factory StreakDbModel.fromJson(Map<String, dynamic> json) {
    return StreakDbModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      ritualId: json['ritual_id'] as String,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastCompletedDate: json['last_completed_date'] != null
          ? DateTime.parse(json['last_completed_date'] as String)
          : null,
      streakStartedAt: json['streak_started_at'] != null
          ? DateTime.parse(json['streak_started_at'] as String)
          : null,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Verificar si la racha sigue activa (no se ha roto)
  bool get isActive {
    if (lastCompletedDate == null) return false;
    
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final lastDate = DateTime(
      lastCompletedDate!.year, 
      lastCompletedDate!.month, 
      lastCompletedDate!.day,
    );
    
    // La racha está activa si se completó hoy o ayer
    final difference = todayDate.difference(lastDate).inDays;
    return difference <= 1;
  }

  /// Obtener la racha efectiva (considerando si está rota)
  int get effectiveStreak => isActive ? currentStreak : 0;
}

/// Servicio de rachas con Supabase
class StreakService {
  static StreakService? _instance;
  final SupabaseClient _client;
  
  StreakService._() : _client = SupabaseService.instance.client;
  
  static StreakService get instance {
    _instance ??= StreakService._();
    return _instance!;
  }

  String? get _userId => SupabaseService.instance.currentUserId;

  /// Obtener racha de un ritual específico
  Future<StreakDbModel?> getStreakForRitual(String ritualId) async {
    if (_userId == null) return null;

    final response = await _client
        .from('streaks')
        .select()
        .eq('user_id', _userId!)
        .eq('ritual_id', ritualId)
        .maybeSingle();
    
    if (response == null) return null;
    return StreakDbModel.fromJson(response);
  }

  /// Obtener todas las rachas del usuario
  Future<List<StreakDbModel>> getAllStreaks() async {
    if (_userId == null) return [];

    final response = await _client
        .from('streaks')
        .select()
        .eq('user_id', _userId!);
    
    return (response as List)
        .map((json) => StreakDbModel.fromJson(json))
        .toList();
  }

  /// Obtener la mejor racha actual del usuario
  Future<StreakDbModel?> getBestCurrentStreak() async {
    if (_userId == null) return null;

    final response = await _client
        .from('streaks')
        .select()
        .eq('user_id', _userId!)
        .order('current_streak', ascending: false)
        .limit(1)
        .maybeSingle();
    
    if (response == null) return null;
    return StreakDbModel.fromJson(response);
  }

  /// Obtener la mejor racha histórica del usuario
  Future<StreakDbModel?> getBestAllTimeStreak() async {
    if (_userId == null) return null;

    final response = await _client
        .from('streaks')
        .select()
        .eq('user_id', _userId!)
        .order('longest_streak', ascending: false)
        .limit(1)
        .maybeSingle();
    
    if (response == null) return null;
    return StreakDbModel.fromJson(response);
  }

  /// Obtener estadísticas de rachas
  Future<StreakStats> getStreakStats() async {
    if (_userId == null) {
      return const StreakStats(
        totalActiveStreaks: 0,
        bestCurrentStreak: 0,
        bestAllTimeStreak: 0,
        averageStreak: 0,
      );
    }

    final streaks = await getAllStreaks();
    
    if (streaks.isEmpty) {
      return const StreakStats(
        totalActiveStreaks: 0,
        bestCurrentStreak: 0,
        bestAllTimeStreak: 0,
        averageStreak: 0,
      );
    }

    final activeStreaks = streaks.where((s) => s.isActive).toList();
    final bestCurrent = streaks.fold<int>(0, (max, s) => 
        s.effectiveStreak > max ? s.effectiveStreak : max);
    final bestAllTime = streaks.fold<int>(0, (max, s) => 
        s.longestStreak > max ? s.longestStreak : max);
    final averageStreak = activeStreaks.isEmpty 
        ? 0.0 
        : activeStreaks.fold<int>(0, (sum, s) => sum + s.currentStreak) / activeStreaks.length;

    return StreakStats(
      totalActiveStreaks: activeStreaks.length,
      bestCurrentStreak: bestCurrent,
      bestAllTimeStreak: bestAllTime,
      averageStreak: averageStreak,
    );
  }

  /// Obtener rachas que necesitan atención (están por romperse)
  Future<List<StreakDbModel>> getStreaksAtRisk() async {
    if (_userId == null) return [];

    final streaks = await getAllStreaks();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    return streaks.where((streak) {
      if (streak.lastCompletedDate == null || streak.currentStreak == 0) {
        return false;
      }
      
      final lastDate = DateTime(
        streak.lastCompletedDate!.year,
        streak.lastCompletedDate!.month,
        streak.lastCompletedDate!.day,
      );
      
      // En riesgo si no se ha completado hoy y tiene racha activa
      final daysSinceCompletion = todayDate.difference(lastDate).inDays;
      return daysSinceCompletion == 1 && streak.currentStreak >= 3;
    }).toList();
  }

  /// Obtener calendario de actividad (últimos N días)
  Future<Map<DateTime, int>> getActivityCalendar({int days = 30}) async {
    if (_userId == null) return {};

    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    final response = await _client
        .from('ritual_completions')
        .select('completed_at')
        .eq('user_id', _userId!)
        .gte('completed_at', startDate.toUtc().toIso8601String())
        .lte('completed_at', endDate.toUtc().toIso8601String());
    
    final completions = response as List;
    final Map<DateTime, int> calendar = {};

    for (final completion in completions) {
      final date = DateTime.parse(completion['completed_at'] as String).toLocal();
      final dayKey = DateTime(date.year, date.month, date.day);
      calendar[dayKey] = (calendar[dayKey] ?? 0) + 1;
    }

    return calendar;
  }
}

/// Modelo de estadísticas de rachas
class StreakStats {
  final int totalActiveStreaks;
  final int bestCurrentStreak;
  final int bestAllTimeStreak;
  final double averageStreak;

  const StreakStats({
    required this.totalActiveStreaks,
    required this.bestCurrentStreak,
    required this.bestAllTimeStreak,
    required this.averageStreak,
  });
}
