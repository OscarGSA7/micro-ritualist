import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../../../features/dashboard/data/models/ritual_model.dart';

/// Modelo de ritual para la base de datos
class RitualDbModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final int durationMinutes;
  final String category;
  final String iconName;
  final String colorHex;
  final bool isActive;
  final List<int> repeatDays;
  final String? preferredTime;
  final bool isDefault;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RitualDbModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.category,
    required this.iconName,
    required this.colorHex,
    required this.isActive,
    required this.repeatDays,
    this.preferredTime,
    required this.isDefault,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RitualDbModel.fromJson(Map<String, dynamic> json) {
    return RitualDbModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      durationMinutes: json['duration_minutes'] as int,
      category: json['category'] as String,
      iconName: json['icon_name'] as String? ?? 'self_improvement_rounded',
      colorHex: json['color_hex'] as String? ?? '#6366F1',
      isActive: json['is_active'] as bool? ?? true,
      repeatDays: (json['repeat_days'] as List<dynamic>?)?.cast<int>() ?? [1,2,3,4,5,6,7],
      preferredTime: json['preferred_time'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'duration_minutes': durationMinutes,
      'category': category,
      'icon_name': iconName,
      'color_hex': colorHex,
      'is_active': isActive,
      'repeat_days': repeatDays,
      'preferred_time': preferredTime,
      'is_default': isDefault,
      'sort_order': sortOrder,
    };
  }

  /// Convertir a RitualModel para la UI
  RitualModel toRitualModel() {
    return RitualModel(
      id: id,
      title: title,
      description: description,
      durationMinutes: durationMinutes,
      icon: _getIconFromName(iconName),
      color: _getColorFromHex(colorHex),
      category: _getCategoryFromString(category),
    );
  }

  static IconData _getIconFromName(String name) {
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
    };
    return iconMap[name] ?? Icons.self_improvement_rounded;
  }

  static Color _getColorFromHex(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF6366F1);
    }
  }

  static RitualCategory _getCategoryFromString(String category) {
    const categoryMap = {
      'breathing': RitualCategory.breathing,
      'movement': RitualCategory.movement,
      'mindfulness': RitualCategory.mindfulness,
      'hydration': RitualCategory.hydration,
      'gratitude': RitualCategory.gratitude,
      'custom': RitualCategory.custom,
    };
    return categoryMap[category] ?? RitualCategory.custom;
  }
}

/// Modelo de completación de ritual
class RitualCompletionDbModel {
  final String id;
  final String userId;
  final String ritualId;
  final DateTime completedAt;
  final int? durationSeconds;
  final String? moodBefore;
  final String? moodAfter;
  final String? notes;

  const RitualCompletionDbModel({
    required this.id,
    required this.userId,
    required this.ritualId,
    required this.completedAt,
    this.durationSeconds,
    this.moodBefore,
    this.moodAfter,
    this.notes,
  });

  factory RitualCompletionDbModel.fromJson(Map<String, dynamic> json) {
    return RitualCompletionDbModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      ritualId: json['ritual_id'] as String,
      completedAt: DateTime.parse(json['completed_at'] as String),
      durationSeconds: json['duration_seconds'] as int?,
      moodBefore: json['mood_before'] as String?,
      moodAfter: json['mood_after'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'ritual_id': ritualId,
      'completed_at': completedAt.toIso8601String(),
      'duration_seconds': durationSeconds,
      'mood_before': moodBefore,
      'mood_after': moodAfter,
      'notes': notes,
    };
  }
}

/// Servicio de rituales con Supabase
class RitualService {
  static RitualService? _instance;
  final SupabaseClient _client;
  
  RitualService._() : _client = SupabaseService.instance.client;
  
  static RitualService get instance {
    _instance ??= RitualService._();
    return _instance!;
  }

  String? get _userId => SupabaseService.instance.currentUserId;

  // ═══════════════════════════════════════════════════════════════════
  // RITUALES
  // ═══════════════════════════════════════════════════════════════════

  /// Obtener todos los rituales del usuario
  Future<List<RitualDbModel>> getRituals() async {
    if (_userId == null) return [];
    
    final response = await _client
        .from('rituals')
        .select()
        .eq('user_id', _userId!)
        .eq('is_active', true)
        .order('sort_order', ascending: true);
    
    return (response as List)
        .map((json) => RitualDbModel.fromJson(json))
        .toList();
  }

  /// Obtener un ritual por ID
  Future<RitualDbModel?> getRitualById(String ritualId) async {
    if (_userId == null) return null;
    
    final response = await _client
        .from('rituals')
        .select()
        .eq('id', ritualId)
        .eq('user_id', _userId!)
        .maybeSingle();
    
    if (response == null) return null;
    return RitualDbModel.fromJson(response);
  }

  /// Crear un nuevo ritual
  Future<RitualDbModel?> createRitual({
    required String title,
    required String description,
    required int durationMinutes,
    required String category,
    required String iconName,
    required String colorHex,
    List<int>? repeatDays,
    String? preferredTime,
  }) async {
    if (_userId == null) return null;

    final response = await _client
        .from('rituals')
        .insert({
          'user_id': _userId,
          'title': title,
          'description': description,
          'duration_minutes': durationMinutes,
          'category': category,
          'icon_name': iconName,
          'color_hex': colorHex,
          'repeat_days': repeatDays ?? [1,2,3,4,5,6,7],
          'preferred_time': preferredTime,
          'is_default': false,
        })
        .select()
        .single();
    
    return RitualDbModel.fromJson(response);
  }

  /// Actualizar un ritual
  Future<RitualDbModel?> updateRitual(String ritualId, Map<String, dynamic> updates) async {
    if (_userId == null) return null;

    final response = await _client
        .from('rituals')
        .update(updates)
        .eq('id', ritualId)
        .eq('user_id', _userId!)
        .select()
        .single();
    
    return RitualDbModel.fromJson(response);
  }

  /// Desactivar un ritual (soft delete)
  Future<bool> deactivateRitual(String ritualId) async {
    if (_userId == null) return false;

    await _client
        .from('rituals')
        .update({'is_active': false})
        .eq('id', ritualId)
        .eq('user_id', _userId!);
    
    return true;
  }

  /// Eliminar un ritual permanentemente
  Future<bool> deleteRitual(String ritualId) async {
    if (_userId == null) return false;

    await _client
        .from('rituals')
        .delete()
        .eq('id', ritualId)
        .eq('user_id', _userId!);
    
    return true;
  }

  /// Reordenar rituales
  Future<void> reorderRituals(List<String> ritualIds) async {
    if (_userId == null) return;

    for (int i = 0; i < ritualIds.length; i++) {
      await _client
          .from('rituals')
          .update({'sort_order': i})
          .eq('id', ritualIds[i])
          .eq('user_id', _userId!);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // COMPLETACIONES
  // ═══════════════════════════════════════════════════════════════════

  /// Registrar completación de ritual
  Future<RitualCompletionDbModel?> completeRitual({
    required String ritualId,
    int? durationSeconds,
    String? moodBefore,
    String? moodAfter,
    String? notes,
  }) async {
    if (_userId == null) return null;

    final response = await _client
        .from('ritual_completions')
        .insert({
          'user_id': _userId,
          'ritual_id': ritualId,
          'completed_at': DateTime.now().toUtc().toIso8601String(),
          'duration_seconds': durationSeconds,
          'mood_before': moodBefore,
          'mood_after': moodAfter,
          'notes': notes,
        })
        .select()
        .single();
    
    return RitualCompletionDbModel.fromJson(response);
  }

  /// Obtener completaciones de hoy
  Future<List<RitualCompletionDbModel>> getTodayCompletions() async {
    if (_userId == null) return [];
    
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await _client
        .from('ritual_completions')
        .select()
        .eq('user_id', _userId!)
        .gte('completed_at', startOfDay.toUtc().toIso8601String())
        .lt('completed_at', endOfDay.toUtc().toIso8601String());
    
    return (response as List)
        .map((json) => RitualCompletionDbModel.fromJson(json))
        .toList();
  }

  /// Obtener completaciones por rango de fechas
  Future<List<RitualCompletionDbModel>> getCompletionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (_userId == null) return [];

    final response = await _client
        .from('ritual_completions')
        .select()
        .eq('user_id', _userId!)
        .gte('completed_at', startDate.toUtc().toIso8601String())
        .lte('completed_at', endDate.toUtc().toIso8601String())
        .order('completed_at', ascending: false);
    
    return (response as List)
        .map((json) => RitualCompletionDbModel.fromJson(json))
        .toList();
  }

  /// Verificar si un ritual ya fue completado hoy
  Future<bool> isRitualCompletedToday(String ritualId) async {
    if (_userId == null) return false;
    
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await _client
        .from('ritual_completions')
        .select('id')
        .eq('user_id', _userId!)
        .eq('ritual_id', ritualId)
        .gte('completed_at', startOfDay.toUtc().toIso8601String())
        .lt('completed_at', endOfDay.toUtc().toIso8601String())
        .limit(1);  
    
    return (response as List).isNotEmpty;
  }

  /// Obtener estadísticas de completación
  Future<Map<String, dynamic>> getCompletionStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_userId == null) {
      return {
        'total_completions': 0,
        'total_minutes': 0,
        'unique_days': 0,
        'most_completed_ritual': null,
      };
    }

    var query = _client
        .from('ritual_completions')
        .select('id, duration_seconds, completed_at, ritual_id')
        .eq('user_id', _userId!);
    
    if (startDate != null) {
      query = query.gte('completed_at', startDate.toUtc().toIso8601String());
    }
    if (endDate != null) {
      query = query.lte('completed_at', endDate.toUtc().toIso8601String());
    }

    final response = await query;
    final completions = response as List;

    if (completions.isEmpty) {
      return {
        'total_completions': 0,
        'total_minutes': 0,
        'unique_days': 0,
        'most_completed_ritual': null,
      };
    }

    // Calcular estadísticas
    int totalSeconds = 0;
    Set<String> uniqueDays = {};
    Map<String, int> ritualCounts = {};

    for (final c in completions) {
      totalSeconds += (c['duration_seconds'] as int?) ?? 0;
      final date = DateTime.parse(c['completed_at']).toLocal();
      uniqueDays.add('${date.year}-${date.month}-${date.day}');
      final ritualId = c['ritual_id'] as String;
      ritualCounts[ritualId] = (ritualCounts[ritualId] ?? 0) + 1;
    }

    String? mostCompletedRitual;
    int maxCount = 0;
    ritualCounts.forEach((key, value) {
      if (value > maxCount) {
        maxCount = value;
        mostCompletedRitual = key;
      }
    });

    return {
      'total_completions': completions.length,
      'total_minutes': totalSeconds ~/ 60,
      'unique_days': uniqueDays.length,
      'most_completed_ritual': mostCompletedRitual,
    };
  }
}
