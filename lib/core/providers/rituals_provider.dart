import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ritual_service.dart';
import '../services/streak_service.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';
import '../config/supabase_config.dart';
import '../../features/dashboard/data/models/ritual_model.dart';

/// Estado de los rituales
class RitualsState {
  final List<RitualDbModel> rituals;
  final List<RitualCompletionDbModel> todayCompletions;
  final Map<String, StreakDbModel> streaks;
  final bool isLoading;
  final String? error;
  final DateTime lastUpdated;
  final bool isOffline;
  final int pendingSyncCount;

  const RitualsState({
    this.rituals = const [],
    this.todayCompletions = const [],
    this.streaks = const {},
    this.isLoading = false,
    this.error,
    required this.lastUpdated,
    this.isOffline = false,
    this.pendingSyncCount = 0,
  });

  RitualsState copyWith({
    List<RitualDbModel>? rituals,
    List<RitualCompletionDbModel>? todayCompletions,
    Map<String, StreakDbModel>? streaks,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
    bool clearError = false,
    bool? isOffline,
    int? pendingSyncCount,
  }) {
    return RitualsState(
      rituals: rituals ?? this.rituals,
      todayCompletions: todayCompletions ?? this.todayCompletions,
      streaks: streaks ?? this.streaks,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isOffline: isOffline ?? this.isOffline,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
    );
  }

  /// Obtener rituales como modelos para la UI
  List<RitualModel> get ritualModels {
    return rituals.map((r) {
      final completion = todayCompletions.firstWhere(
        (c) => c.ritualId == r.id,
        orElse: () => RitualCompletionDbModel(
          id: '', userId: '', ritualId: '', completedAt: DateTime.now(),
        ),
      );
      final isCompleted = completion.id.isNotEmpty;
      
      return r.toRitualModel().copyWith(
        isCompleted: isCompleted,
        completedAt: isCompleted ? completion.completedAt : null,
      );
    }).toList();
  }

  /// Obtener progreso del día
  double get todayProgress {
    if (rituals.isEmpty) return 0;
    final completedCount = todayCompletions.map((c) => c.ritualId).toSet().length;
    return completedCount / rituals.length;
  }

  /// Obtener conteo de rituales completados hoy
  int get completedToday => todayCompletions.map((c) => c.ritualId).toSet().length;

  /// Verificar si un ritual fue completado hoy
  bool isCompletedToday(String ritualId) {
    return todayCompletions.any((c) => c.ritualId == ritualId);
  }

  /// Obtener racha de un ritual
  int getStreak(String ritualId) {
    final streak = streaks[ritualId];
    if (streak == null) return 0;
    return streak.effectiveStreak;
  }
}

/// Provider de rituales
final ritualsProvider = StateNotifierProvider<RitualsNotifier, RitualsState>((ref) {
  return RitualsNotifier();
});

class RitualsNotifier extends StateNotifier<RitualsState> {
  RitualsNotifier() : super(RitualsState(lastUpdated: DateTime.now())) {
    _init();
  }

  final RitualService _ritualService = RitualService.instance;
  final StreakService _streakService = StreakService.instance;
  final LocalStorageService _localStorage = LocalStorageService.instance;
  final SyncService _syncService = SyncService.instance;

  /// Inicializar servicios y cargar datos
  Future<void> _init() async {
    // Inicializar servicio de sincronización
    _syncService.initialize();
    
    // Escuchar cambios de sincronización
    _syncService.addSyncListener(_onSyncChanged);
    
    // Cargar datos
    await loadRituals();
  }

  void _onSyncChanged() {
    // Recargar datos cuando hay cambios de sincronización
    _updatePendingCount();
    loadRituals();
  }

  Future<void> _updatePendingCount() async {
    final count = await _syncService.getPendingCount();
    state = state.copyWith(pendingSyncCount: count);
  }

  /// Cargar todos los rituales del usuario
  Future<void> loadRituals() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final hasConnection = await _syncService.hasConnection();
      
      if (SupabaseConfig.isConfigured && hasConnection) {
        // Modo online - cargar del servidor
        await _loadFromServer();
        state = state.copyWith(isOffline: false);
      } else {
        // Modo offline - cargar de almacenamiento local
        await _loadFromLocal();
        state = state.copyWith(isOffline: true);
      }

      await _updatePendingCount();
      state = state.copyWith(isLoading: false, lastUpdated: DateTime.now());
    } catch (e) {
      // Si falla, intentar cargar de local
      try {
        await _loadFromLocal();
        state = state.copyWith(
          isLoading: false,
          isOffline: true,
          error: 'Modo offline: $e',
        );
      } catch (localError) {
        state = state.copyWith(
          isLoading: false,
          error: 'Error al cargar rituales: $e',
        );
      }
    }
  }

  Future<void> _loadFromServer() async {
    final results = await Future.wait([
      _ritualService.getRituals(),
      _ritualService.getTodayCompletions(),
      _streakService.getAllStreaks(),
    ]);

    final rituals = results[0] as List<RitualDbModel>;
    final completions = results[1] as List<RitualCompletionDbModel>;
    final streaksList = results[2] as List<StreakDbModel>;

    // Guardar en local para uso offline
    await _localStorage.saveRituals(rituals);
    await _localStorage.saveCompletions(completions);

    // Convertir lista de streaks a mapa por ritual_id
    final streaksMap = <String, StreakDbModel>{};
    for (final streak in streaksList) {
      streaksMap[streak.ritualId] = streak;
    }

    state = state.copyWith(
      rituals: rituals,
      todayCompletions: completions,
      streaks: streaksMap,
    );
  }

  Future<void> _loadFromLocal() async {
    final rituals = await _localStorage.getRituals();
    final completions = await _localStorage.getTodayCompletions();

    state = state.copyWith(
      rituals: rituals,
      todayCompletions: completions,
      streaks: {}, // No tenemos streaks en modo offline
    );
  }

  /// Crear un nuevo ritual (funciona offline)
  Future<bool> createRitual({
    required String title,
    required String description,
    required int durationMinutes,
    required RitualCategory category,
    required IconData icon,
    required Color color,
    List<int>? repeatDays,
  }) async {
    try {
      final iconName = _getIconName(icon);
      final colorHex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
      
      final hasConnection = await _syncService.hasConnection();
      
      if (SupabaseConfig.isConfigured && hasConnection) {
        // Modo online - crear en servidor
        final ritual = await _ritualService.createRitual(
          title: title,
          description: description,
          durationMinutes: durationMinutes,
          category: category.name,
          iconName: iconName,
          colorHex: colorHex,
          repeatDays: repeatDays,
        );

        if (ritual != null) {
          state = state.copyWith(
            rituals: [...state.rituals, ritual],
            lastUpdated: DateTime.now(),
          );
          // Guardar en local
          await _localStorage.saveRituals(state.rituals);
          return true;
        }
        return false;
      } else {
        // Modo offline - encolar para sincronización
        final localId = await _syncService.queueCreateRitual(
          title: title,
          description: description,
          durationMinutes: durationMinutes,
          category: category.name,
          iconName: iconName,
          colorHex: colorHex,
          repeatDays: repeatDays,
        );
        
        // Recargar rituales locales
        final rituals = await _localStorage.getRituals();
        state = state.copyWith(
          rituals: rituals,
          lastUpdated: DateTime.now(),
        );
        await _updatePendingCount();
        return localId.isNotEmpty;
      }
    } catch (e) {
      state = state.copyWith(error: 'Error al crear ritual: $e');
      return false;
    }
  }

  /// Completar un ritual (funciona offline)
  Future<bool> completeRitual(
    String ritualId, {
    int? durationSeconds,
    String? moodBefore,
    String? moodAfter,
    String? notes,
  }) async {
    try {
      final hasConnection = await _syncService.hasConnection();
      
      if (SupabaseConfig.isConfigured && hasConnection && !ritualId.startsWith('local_')) {
        // Modo online
        final completion = await _ritualService.completeRitual(
          ritualId: ritualId,
          durationSeconds: durationSeconds,
          moodBefore: moodBefore,
          moodAfter: moodAfter,
          notes: notes,
        );

        if (completion != null) {
          final updatedCompletions = [...state.todayCompletions, completion];
          
          // Recargar streak del ritual
          final streak = await _streakService.getStreakForRitual(ritualId);
          final updatedStreaks = Map<String, StreakDbModel>.from(state.streaks);
          if (streak != null) {
            updatedStreaks[ritualId] = streak;
          }

          state = state.copyWith(
            todayCompletions: updatedCompletions,
            streaks: updatedStreaks,
            lastUpdated: DateTime.now(),
          );
          
          // Guardar en local
          await _localStorage.saveCompletions(updatedCompletions);
          return true;
        }
        return false;
      } else {
        // Modo offline - encolar para sincronización
        await _syncService.queueCompleteRitual(
          ritualId: ritualId,
          durationSeconds: durationSeconds,
          moodBefore: moodBefore,
          moodAfter: moodAfter,
          notes: notes,
        );
        
        // Recargar completaciones locales
        final completions = await _localStorage.getTodayCompletions();
        state = state.copyWith(
          todayCompletions: completions,
          lastUpdated: DateTime.now(),
        );
        await _updatePendingCount();
        return true;
      }
    } catch (e) {
      state = state.copyWith(error: 'Error al completar ritual: $e');
      return false;
    }
  }

  /// Actualizar un ritual (funciona offline)
  Future<bool> updateRitual(String ritualId, {
    String? title,
    String? description,
    int? durationMinutes,
    RitualCategory? category,
    IconData? icon,
    Color? color,
    List<int>? repeatDays,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (durationMinutes != null) updates['duration_minutes'] = durationMinutes;
      if (category != null) updates['category'] = category.name;
      if (icon != null) updates['icon_name'] = _getIconName(icon);
      if (color != null) {
        updates['color_hex'] = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
      }
      if (repeatDays != null) updates['repeat_days'] = repeatDays;

      if (updates.isEmpty) return true;

      final hasConnection = await _syncService.hasConnection();
      
      if (SupabaseConfig.isConfigured && hasConnection && !ritualId.startsWith('local_')) {
        // Modo online
        final updated = await _ritualService.updateRitual(ritualId, updates);
        
        if (updated != null) {
          final updatedList = state.rituals.map((r) {
            return r.id == ritualId ? updated : r;
          }).toList();
          
          state = state.copyWith(
            rituals: updatedList,
            lastUpdated: DateTime.now(),
          );
          
          // Guardar en local
          await _localStorage.saveRituals(updatedList);
          return true;
        }
        return false;
      } else {
        // Modo offline - encolar para sincronización
        await _syncService.queueUpdateRitual(ritualId, updates);
        
        // Recargar rituales locales
        final rituals = await _localStorage.getRituals();
        state = state.copyWith(
          rituals: rituals,
          lastUpdated: DateTime.now(),
        );
        await _updatePendingCount();
        return true;
      }
    } catch (e) {
      state = state.copyWith(error: 'Error al actualizar ritual: $e');
      return false;
    }
  }

  /// Eliminar un ritual (funciona offline)
  Future<bool> deleteRitual(String ritualId) async {
    try {
      final hasConnection = await _syncService.hasConnection();
      
      if (SupabaseConfig.isConfigured && hasConnection && !ritualId.startsWith('local_')) {
        // Modo online
        final success = await _ritualService.deactivateRitual(ritualId);
        
        if (success) {
          final updatedList = state.rituals.where((r) => r.id != ritualId).toList();
          final updatedStreaks = Map<String, StreakDbModel>.from(state.streaks)
            ..remove(ritualId);
          
          state = state.copyWith(
            rituals: updatedList,
            streaks: updatedStreaks,
            lastUpdated: DateTime.now(),
          );
          
          // Guardar en local
          await _localStorage.saveRituals(updatedList);
          return true;
        }
        return false;
      } else {
        // Modo offline - encolar para sincronización
        await _syncService.queueDeleteRitual(ritualId);
        
        // Actualizar estado local inmediatamente
        final updatedList = state.rituals.where((r) => r.id != ritualId).toList();
        state = state.copyWith(
          rituals: updatedList,
          lastUpdated: DateTime.now(),
        );
        await _updatePendingCount();
        return true;
      }
    } catch (e) {
      state = state.copyWith(error: 'Error al eliminar ritual: $e');
      return false;
    }
  }

  /// Reordenar rituales
  Future<void> reorderRituals(List<String> newOrder) async {
    try {
      // Reordenar localmente primero
      final reorderedRituals = <RitualDbModel>[];
      for (final id in newOrder) {
        final ritual = state.rituals.firstWhere((r) => r.id == id);
        reorderedRituals.add(ritual);
      }
      
      state = state.copyWith(rituals: reorderedRituals);
      await _localStorage.saveRituals(reorderedRituals);
      
      // Sincronizar con servidor si hay conexión
      if (SupabaseConfig.isConfigured && await _syncService.hasConnection()) {
        await _ritualService.reorderRituals(newOrder);
      }
    } catch (e) {
      // Revertir en caso de error
      await loadRituals();
    }
  }

  /// Forzar sincronización
  Future<SyncResult> forceSync() async {
    return await _syncService.syncPendingActions();
  }

  /// Refrescar datos
  Future<void> refresh() async {
    await loadRituals();
  }

  /// Helper para obtener nombre de ícono
  String _getIconName(IconData icon) {
    final iconMap = {
      Icons.self_improvement_rounded: 'self_improvement_rounded',
      Icons.air_rounded: 'air_rounded',
      Icons.favorite_rounded: 'favorite_rounded',
      Icons.local_drink_rounded: 'local_drink_rounded',
      Icons.spa_rounded: 'spa_rounded',
      Icons.directions_walk_rounded: 'directions_walk_rounded',
      Icons.music_note_rounded: 'music_note_rounded',
      Icons.wb_sunny_rounded: 'wb_sunny_rounded',
      Icons.bedtime_rounded: 'bedtime_rounded',
      Icons.emoji_nature_rounded: 'emoji_nature_rounded',
    };
    return iconMap[icon] ?? 'self_improvement_rounded';
  }

  @override
  void dispose() {
    _syncService.removeSyncListener(_onSyncChanged);
    super.dispose();
  }
}

/// Provider para estadísticas de rachas
final streakStatsProvider = FutureProvider<StreakStats>((ref) async {
  if (!SupabaseConfig.isConfigured) {
    return const StreakStats(
      totalActiveStreaks: 0,
      bestCurrentStreak: 0,
      bestAllTimeStreak: 0,
      averageStreak: 0,
    );
  }
  return StreakService.instance.getStreakStats();
});

/// Provider para rachas en riesgo
final streaksAtRiskProvider = FutureProvider<List<StreakDbModel>>((ref) async {
  if (!SupabaseConfig.isConfigured) return [];
  return StreakService.instance.getStreaksAtRisk();
});

/// Provider para calendario de actividad
final activityCalendarProvider = FutureProvider.family<Map<DateTime, int>, int>((ref, days) async {
  if (!SupabaseConfig.isConfigured) return {};
  return StreakService.instance.getActivityCalendar(days: days);
});
