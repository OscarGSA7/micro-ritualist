import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'ritual_service.dart';

/// Servicio de almacenamiento local para modo offline
/// 
/// Guarda rituales, completaciones y acciones pendientes de sincronizar
class LocalStorageService {
  static LocalStorageService? _instance;
  static const String _ritualsKey = 'local_rituals';
  static const String _completionsKey = 'local_completions';
  static const String _syncQueueKey = 'sync_queue';
  static const String _lastSyncKey = 'last_sync_timestamp';
  
  LocalStorageService._();
  
  static LocalStorageService get instance {
    _instance ??= LocalStorageService._();
    return _instance!;
  }

  // ═══════════════════════════════════════════════════════════════════
  // RITUALES LOCALES
  // ═══════════════════════════════════════════════════════════════════

  /// Guardar rituales localmente
  Future<void> saveRituals(List<RitualDbModel> rituals) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = rituals.map((r) => _ritualToJson(r)).toList();
    await prefs.setString(_ritualsKey, jsonEncode(jsonList));
  }

  /// Obtener rituales guardados localmente
  Future<List<RitualDbModel>> getRituals() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_ritualsKey);
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => _ritualFromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Agregar un ritual localmente
  Future<void> addRitual(RitualDbModel ritual) async {
    final rituals = await getRituals();
    rituals.add(ritual);
    await saveRituals(rituals);
  }

  /// Actualizar un ritual localmente
  Future<void> updateRitual(String ritualId, Map<String, dynamic> updates) async {
    final rituals = await getRituals();
    final index = rituals.indexWhere((r) => r.id == ritualId);
    if (index != -1) {
      // Crear nuevo ritual con los updates
      final oldRitual = rituals[index];
      final updatedRitual = _applyUpdates(oldRitual, updates);
      rituals[index] = updatedRitual;
      await saveRituals(rituals);
    }
  }

  /// Eliminar un ritual localmente
  Future<void> deleteRitual(String ritualId) async {
    final rituals = await getRituals();
    rituals.removeWhere((r) => r.id == ritualId);
    await saveRituals(rituals);
  }

  // ═══════════════════════════════════════════════════════════════════
  // COMPLETACIONES LOCALES
  // ═══════════════════════════════════════════════════════════════════

  /// Guardar completaciones localmente
  Future<void> saveCompletions(List<RitualCompletionDbModel> completions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = completions.map((c) => _completionToJson(c)).toList();
    await prefs.setString(_completionsKey, jsonEncode(jsonList));
  }

  /// Obtener completaciones guardadas localmente
  Future<List<RitualCompletionDbModel>> getCompletions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_completionsKey);
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => _completionFromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Obtener completaciones de hoy
  Future<List<RitualCompletionDbModel>> getTodayCompletions() async {
    final completions = await getCompletions();
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return completions.where((c) {
      return c.completedAt.isAfter(startOfDay) && c.completedAt.isBefore(endOfDay);
    }).toList();
  }

  /// Agregar una completación localmente
  Future<void> addCompletion(RitualCompletionDbModel completion) async {
    final completions = await getCompletions();
    completions.add(completion);
    await saveCompletions(completions);
  }

  // ═══════════════════════════════════════════════════════════════════
  // COLA DE SINCRONIZACIÓN
  // ═══════════════════════════════════════════════════════════════════

  /// Agregar acción a la cola de sincronización
  Future<void> addToSyncQueue(SyncAction action) async {
    final queue = await getSyncQueue();
    queue.add(action);
    await _saveSyncQueue(queue);
  }

  /// Obtener cola de sincronización
  Future<List<SyncAction>> getSyncQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_syncQueueKey);
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => SyncAction.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Guardar cola de sincronización
  Future<void> _saveSyncQueue(List<SyncAction> queue) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = queue.map((a) => a.toJson()).toList();
    await prefs.setString(_syncQueueKey, jsonEncode(jsonList));
  }

  /// Remover acciones sincronizadas
  Future<void> removeFromSyncQueue(List<String> actionIds) async {
    final queue = await getSyncQueue();
    queue.removeWhere((a) => actionIds.contains(a.id));
    await _saveSyncQueue(queue);
  }

  /// Limpiar cola de sincronización
  Future<void> clearSyncQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_syncQueueKey);
  }

  /// Verificar si hay acciones pendientes
  Future<bool> hasPendingSync() async {
    final queue = await getSyncQueue();
    return queue.isNotEmpty;
  }

  // ═══════════════════════════════════════════════════════════════════
  // TIMESTAMP DE ÚLTIMA SINCRONIZACIÓN
  // ═══════════════════════════════════════════════════════════════════

  /// Guardar timestamp de última sincronización
  Future<void> setLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, time.toIso8601String());
  }

  /// Obtener timestamp de última sincronización
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString(_lastSyncKey);
    if (timeString == null) return null;
    return DateTime.tryParse(timeString);
  }

  // ═══════════════════════════════════════════════════════════════════
  // LIMPIAR DATOS LOCALES
  // ═══════════════════════════════════════════════════════════════════

  /// Limpiar todos los datos locales
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ritualsKey);
    await prefs.remove(_completionsKey);
    await prefs.remove(_syncQueueKey);
    await prefs.remove(_lastSyncKey);
  }

  // ═══════════════════════════════════════════════════════════════════
  // HELPERS DE SERIALIZACIÓN
  // ═══════════════════════════════════════════════════════════════════

  Map<String, dynamic> _ritualToJson(RitualDbModel r) => {
    'id': r.id,
    'user_id': r.userId,
    'title': r.title,
    'description': r.description,
    'duration_minutes': r.durationMinutes,
    'category': r.category,
    'icon_name': r.iconName,
    'color_hex': r.colorHex,
    'is_active': r.isActive,
    'repeat_days': r.repeatDays,
    'preferred_time': r.preferredTime,
    'is_default': r.isDefault,
    'sort_order': r.sortOrder,
    'created_at': r.createdAt.toIso8601String(),
    'updated_at': r.updatedAt.toIso8601String(),
  };

  RitualDbModel _ritualFromJson(Map<String, dynamic> json) => RitualDbModel(
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

  RitualDbModel _applyUpdates(RitualDbModel ritual, Map<String, dynamic> updates) {
    return RitualDbModel(
      id: ritual.id,
      userId: ritual.userId,
      title: updates['title'] as String? ?? ritual.title,
      description: updates['description'] as String? ?? ritual.description,
      durationMinutes: updates['duration_minutes'] as int? ?? ritual.durationMinutes,
      category: updates['category'] as String? ?? ritual.category,
      iconName: updates['icon_name'] as String? ?? ritual.iconName,
      colorHex: updates['color_hex'] as String? ?? ritual.colorHex,
      isActive: updates['is_active'] as bool? ?? ritual.isActive,
      repeatDays: (updates['repeat_days'] as List<int>?) ?? ritual.repeatDays,
      preferredTime: updates['preferred_time'] as String? ?? ritual.preferredTime,
      isDefault: ritual.isDefault,
      sortOrder: updates['sort_order'] as int? ?? ritual.sortOrder,
      createdAt: ritual.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> _completionToJson(RitualCompletionDbModel c) => {
    'id': c.id,
    'user_id': c.userId,
    'ritual_id': c.ritualId,
    'completed_at': c.completedAt.toIso8601String(),
    'duration_seconds': c.durationSeconds,
    'mood_before': c.moodBefore,
    'mood_after': c.moodAfter,
    'notes': c.notes,
  };

  RitualCompletionDbModel _completionFromJson(Map<String, dynamic> json) => RitualCompletionDbModel(
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

/// Tipos de acciones de sincronización
enum SyncActionType {
  createRitual,
  updateRitual,
  deleteRitual,
  completeRitual,
}

/// Modelo para acciones pendientes de sincronización
class SyncAction {
  final String id;
  final SyncActionType type;
  final String? entityId;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;

  const SyncAction({
    required this.id,
    required this.type,
    this.entityId,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  factory SyncAction.fromJson(Map<String, dynamic> json) {
    return SyncAction(
      id: json['id'] as String,
      type: SyncActionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SyncActionType.createRitual,
      ),
      entityId: json['entity_id'] as String?,
      data: json['data'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['created_at'] as String),
      retryCount: json['retry_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'entity_id': entityId,
    'data': data,
    'created_at': createdAt.toIso8601String(),
    'retry_count': retryCount,
  };

  SyncAction copyWith({int? retryCount}) {
    return SyncAction(
      id: id,
      type: type,
      entityId: entityId,
      data: data,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}
