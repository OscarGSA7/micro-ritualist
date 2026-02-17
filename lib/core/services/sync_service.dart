import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'local_storage_service.dart';
import 'ritual_service.dart';
import 'supabase_service.dart';
import '../config/supabase_config.dart';

/// Servicio de sincronización para modo offline
/// 
/// Maneja la cola de acciones pendientes y sincroniza cuando hay conexión
class SyncService {
  static SyncService? _instance;
  final LocalStorageService _localStorage = LocalStorageService.instance;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;
  final _uuid = const Uuid();
  
  // Callbacks para notificar cambios
  final List<VoidCallback> _syncListeners = [];
  
  SyncService._();
  
  static SyncService get instance {
    _instance ??= SyncService._();
    return _instance!;
  }

  /// Iniciar el servicio de sincronización
  void initialize() {
    // Escuchar cambios de conectividad
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        final hasConnection = results.any((r) => r != ConnectivityResult.none);
        if (hasConnection) {
          // Intentar sincronizar cuando hay conexión
          syncPendingActions();
        }
      },
    );
    
    // Verificar si hay acciones pendientes al iniciar
    _checkPendingSync();
  }

  /// Detener el servicio
  void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// Agregar listener para cambios de sincronización
  void addSyncListener(VoidCallback listener) {
    _syncListeners.add(listener);
  }

  /// Remover listener
  void removeSyncListener(VoidCallback listener) {
    _syncListeners.remove(listener);
  }

  /// Notificar a los listeners
  void _notifyListeners() {
    for (final listener in _syncListeners) {
      listener();
    }
  }

  /// Verificar conexión actual
  Future<bool> hasConnection() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Verificar si hay acciones pendientes
  Future<void> _checkPendingSync() async {
    final hasPending = await _localStorage.hasPendingSync();
    if (hasPending && await hasConnection()) {
      syncPendingActions();
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // ENCOLAR ACCIONES
  // ═══════════════════════════════════════════════════════════════════

  /// Encolar creación de ritual
  Future<String> queueCreateRitual({
    required String title,
    required String description,
    required int durationMinutes,
    required String category,
    required String iconName,
    required String colorHex,
    List<int>? repeatDays,
  }) async {
    final localId = 'local_${_uuid.v4()}';
    final userId = SupabaseService.instance.currentUserId ?? 'guest';
    
    // Crear ritual local
    final localRitual = RitualDbModel(
      id: localId,
      userId: userId,
      title: title,
      description: description,
      durationMinutes: durationMinutes,
      category: category,
      iconName: iconName,
      colorHex: colorHex,
      isActive: true,
      repeatDays: repeatDays ?? [1,2,3,4,5,6,7],
      preferredTime: null,
      isDefault: false,
      sortOrder: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Guardar localmente
    await _localStorage.addRitual(localRitual);
    
    // Agregar a cola de sincronización
    await _localStorage.addToSyncQueue(SyncAction(
      id: _uuid.v4(),
      type: SyncActionType.createRitual,
      entityId: localId,
      data: {
        'title': title,
        'description': description,
        'duration_minutes': durationMinutes,
        'category': category,
        'icon_name': iconName,
        'color_hex': colorHex,
        'repeat_days': repeatDays ?? [1,2,3,4,5,6,7],
      },
      createdAt: DateTime.now(),
    ));
    
    // Intentar sincronizar si hay conexión
    if (await hasConnection()) {
      syncPendingActions();
    }
    
    _notifyListeners();
    return localId;
  }

  /// Encolar actualización de ritual
  Future<void> queueUpdateRitual(String ritualId, Map<String, dynamic> updates) async {
    // Actualizar localmente
    await _localStorage.updateRitual(ritualId, updates);
    
    // Agregar a cola de sincronización
    await _localStorage.addToSyncQueue(SyncAction(
      id: _uuid.v4(),
      type: SyncActionType.updateRitual,
      entityId: ritualId,
      data: updates,
      createdAt: DateTime.now(),
    ));
    
    // Intentar sincronizar si hay conexión
    if (await hasConnection()) {
      syncPendingActions();
    }
    
    _notifyListeners();
  }

  /// Encolar eliminación de ritual
  Future<void> queueDeleteRitual(String ritualId) async {
    // Eliminar localmente
    await _localStorage.deleteRitual(ritualId);
    
    // Solo agregar a cola si no es un ritual local (que no existe en servidor)
    if (!ritualId.startsWith('local_')) {
      await _localStorage.addToSyncQueue(SyncAction(
        id: _uuid.v4(),
        type: SyncActionType.deleteRitual,
        entityId: ritualId,
        data: {},
        createdAt: DateTime.now(),
      ));
    }
    
    // Intentar sincronizar si hay conexión
    if (await hasConnection()) {
      syncPendingActions();
    }
    
    _notifyListeners();
  }

  /// Encolar completación de ritual
  Future<String> queueCompleteRitual({
    required String ritualId,
    int? durationSeconds,
    String? moodBefore,
    String? moodAfter,
    String? notes,
  }) async {
    final localId = 'local_${_uuid.v4()}';
    final userId = SupabaseService.instance.currentUserId ?? 'guest';
    
    // Crear completación local
    final localCompletion = RitualCompletionDbModel(
      id: localId,
      userId: userId,
      ritualId: ritualId,
      completedAt: DateTime.now(),
      durationSeconds: durationSeconds,
      moodBefore: moodBefore,
      moodAfter: moodAfter,
      notes: notes,
    );
    
    // Guardar localmente
    await _localStorage.addCompletion(localCompletion);
    
    // Solo agregar a cola si el ritual no es local
    if (!ritualId.startsWith('local_')) {
      await _localStorage.addToSyncQueue(SyncAction(
        id: _uuid.v4(),
        type: SyncActionType.completeRitual,
        entityId: localId,
        data: {
          'ritual_id': ritualId,
          'duration_seconds': durationSeconds,
          'mood_before': moodBefore,
          'mood_after': moodAfter,
          'notes': notes,
        },
        createdAt: DateTime.now(),
      ));
    }
    
    // Intentar sincronizar si hay conexión
    if (await hasConnection()) {
      syncPendingActions();
    }
    
    _notifyListeners();
    return localId;
  }

  // ═══════════════════════════════════════════════════════════════════
  // SINCRONIZACIÓN
  // ═══════════════════════════════════════════════════════════════════

  /// Sincronizar todas las acciones pendientes
  Future<SyncResult> syncPendingActions() async {
    if (_isSyncing) return SyncResult(success: false, message: 'Ya sincronizando');
    if (!SupabaseConfig.isConfigured) {
      return SyncResult(success: false, message: 'Supabase no configurado');
    }
    if (!await hasConnection()) {
      return SyncResult(success: false, message: 'Sin conexión');
    }
    
    _isSyncing = true;
    int synced = 0;
    int failed = 0;
    final syncedIds = <String>[];
    
    try {
      final queue = await _localStorage.getSyncQueue();
      
      if (queue.isEmpty) {
        _isSyncing = false;
        return SyncResult(success: true, message: 'Nada que sincronizar');
      }
      
      debugPrint('🔄 Sincronizando ${queue.length} acciones pendientes...');
      
      for (final action in queue) {
        try {
          final success = await _processAction(action);
          if (success) {
            synced++;
            syncedIds.add(action.id);
          } else {
            failed++;
          }
        } catch (e) {
          debugPrint('❌ Error procesando acción ${action.type}: $e');
          failed++;
        }
      }
      
      // Remover acciones sincronizadas
      if (syncedIds.isNotEmpty) {
        await _localStorage.removeFromSyncQueue(syncedIds);
      }
      
      // Actualizar timestamp
      await _localStorage.setLastSyncTime(DateTime.now());
      
      _notifyListeners();
      debugPrint('✅ Sincronización completada: $synced exitosas, $failed fallidas');
      
      return SyncResult(
        success: failed == 0,
        message: 'Sincronizado: $synced, Fallidos: $failed',
        syncedCount: synced,
        failedCount: failed,
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Procesar una acción de sincronización
  Future<bool> _processAction(SyncAction action) async {
    switch (action.type) {
      case SyncActionType.createRitual:
        return await _syncCreateRitual(action);
      case SyncActionType.updateRitual:
        return await _syncUpdateRitual(action);
      case SyncActionType.deleteRitual:
        return await _syncDeleteRitual(action);
      case SyncActionType.completeRitual:
        return await _syncCompleteRitual(action);
    }
  }

  Future<bool> _syncCreateRitual(SyncAction action) async {
    try {
      final ritual = await RitualService.instance.createRitual(
        title: action.data['title'] as String,
        description: action.data['description'] as String? ?? '',
        durationMinutes: action.data['duration_minutes'] as int,
        category: action.data['category'] as String,
        iconName: action.data['icon_name'] as String,
        colorHex: action.data['color_hex'] as String,
        repeatDays: (action.data['repeat_days'] as List<dynamic>?)?.cast<int>(),
      );
      
      if (ritual != null && action.entityId != null) {
        // Actualizar el ID local con el ID real del servidor
        await _updateLocalRitualId(action.entityId!, ritual.id);
      }
      
      return ritual != null;
    } catch (e) {
      debugPrint('Error sincronizando createRitual: $e');
      return false;
    }
  }

  Future<bool> _syncUpdateRitual(SyncAction action) async {
    if (action.entityId == null) return false;
    if (action.entityId!.startsWith('local_')) return false; // No sincronizar locales
    
    try {
      final result = await RitualService.instance.updateRitual(
        action.entityId!,
        action.data,
      );
      return result != null;
    } catch (e) {
      debugPrint('Error sincronizando updateRitual: $e');
      return false;
    }
  }

  Future<bool> _syncDeleteRitual(SyncAction action) async {
    if (action.entityId == null) return false;
    if (action.entityId!.startsWith('local_')) return true; // Ya está eliminado localmente
    
    try {
      return await RitualService.instance.deactivateRitual(action.entityId!);
    } catch (e) {
      debugPrint('Error sincronizando deleteRitual: $e');
      return false;
    }
  }

  Future<bool> _syncCompleteRitual(SyncAction action) async {
    final ritualId = action.data['ritual_id'] as String?;
    if (ritualId == null) return false;
    if (ritualId.startsWith('local_')) return false; // No sincronizar completaciones de rituales locales
    
    try {
      final result = await RitualService.instance.completeRitual(
        ritualId: ritualId,
        durationSeconds: action.data['duration_seconds'] as int?,
        moodBefore: action.data['mood_before'] as String?,
        moodAfter: action.data['mood_after'] as String?,
        notes: action.data['notes'] as String?,
      );
      return result != null;
    } catch (e) {
      debugPrint('Error sincronizando completeRitual: $e');
      return false;
    }
  }

  /// Actualizar ID local a ID de servidor en datos locales
  Future<void> _updateLocalRitualId(String localId, String serverId) async {
    final rituals = await _localStorage.getRituals();
    final index = rituals.indexWhere((r) => r.id == localId);
    
    if (index != -1) {
      // Crear nuevo ritual con el ID del servidor
      final oldRitual = rituals[index];
      final newRitual = RitualDbModel(
        id: serverId,
        userId: oldRitual.userId,
        title: oldRitual.title,
        description: oldRitual.description,
        durationMinutes: oldRitual.durationMinutes,
        category: oldRitual.category,
        iconName: oldRitual.iconName,
        colorHex: oldRitual.colorHex,
        isActive: oldRitual.isActive,
        repeatDays: oldRitual.repeatDays,
        preferredTime: oldRitual.preferredTime,
        isDefault: oldRitual.isDefault,
        sortOrder: oldRitual.sortOrder,
        createdAt: oldRitual.createdAt,
        updatedAt: oldRitual.updatedAt,
      );
      
      rituals[index] = newRitual;
      await _localStorage.saveRituals(rituals);
      
      // También actualizar completaciones que referencian el ID local
      final completions = await _localStorage.getCompletions();
      bool updated = false;
      final updatedCompletions = completions.map((c) {
        if (c.ritualId == localId) {
          updated = true;
          return RitualCompletionDbModel(
            id: c.id,
            userId: c.userId,
            ritualId: serverId,
            completedAt: c.completedAt,
            durationSeconds: c.durationSeconds,
            moodBefore: c.moodBefore,
            moodAfter: c.moodAfter,
            notes: c.notes,
          );
        }
        return c;
      }).toList();
      
      if (updated) {
        await _localStorage.saveCompletions(updatedCompletions);
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // SINCRONIZACIÓN COMPLETA CON SERVIDOR
  // ═══════════════════════════════════════════════════════════════════

  /// Sincronizar datos desde el servidor (pull)
  Future<void> pullFromServer() async {
    if (!SupabaseConfig.isConfigured) return;
    if (!await hasConnection()) return;
    
    try {
      // Obtener rituales del servidor
      final serverRituals = await RitualService.instance.getRituals();
      final serverCompletions = await RitualService.instance.getTodayCompletions();
      
      // Combinar con rituales locales que no se han sincronizado
      final localRituals = await _localStorage.getRituals();
      final localOnlyRituals = localRituals.where(
        (r) => r.id.startsWith('local_')
      ).toList();
      
      // Guardar todo localmente
      await _localStorage.saveRituals([...serverRituals, ...localOnlyRituals]);
      
      // Combinar completaciones
      final localCompletions = await _localStorage.getTodayCompletions();
      final localOnlyCompletions = localCompletions.where(
        (c) => c.id.startsWith('local_')
      ).toList();
      
      await _localStorage.saveCompletions([...serverCompletions, ...localOnlyCompletions]);
      await _localStorage.setLastSyncTime(DateTime.now());
      
      _notifyListeners();
    } catch (e) {
      debugPrint('Error pulling from server: $e');
    }
  }

  /// Obtener número de acciones pendientes
  Future<int> getPendingCount() async {
    final queue = await _localStorage.getSyncQueue();
    return queue.length;
  }
}

/// Resultado de sincronización
class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;
  final int failedCount;

  const SyncResult({
    required this.success,
    required this.message,
    this.syncedCount = 0,
    this.failedCount = 0,
  });
}
