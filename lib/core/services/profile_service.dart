import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Modelo de perfil de usuario
class ProfileDbModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String timezone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileDbModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.timezone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileDbModel.fromJson(Map<String, dynamic> json) {
    return ProfileDbModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      timezone: json['timezone'] as String? ?? 'America/Mexico_City',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'timezone': timezone,
    };
  }
}

/// Modelo de configuración de usuario
class UserSettingsDbModel {
  final String id;
  final String userId;
  final bool notificationsEnabled;
  final String dailyReminderTime;
  final List<int> reminderDays;
  final String themeMode;
  final int defaultRitualDuration;
  final bool soundEnabled;
  final bool hapticFeedback;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSettingsDbModel({
    required this.id,
    required this.userId,
    required this.notificationsEnabled,
    required this.dailyReminderTime,
    required this.reminderDays,
    required this.themeMode,
    required this.defaultRitualDuration,
    required this.soundEnabled,
    required this.hapticFeedback,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserSettingsDbModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsDbModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      dailyReminderTime: json['daily_reminder_time'] as String? ?? '08:00:00',
      reminderDays: (json['reminder_days'] as List<dynamic>?)?.cast<int>() ?? [1,2,3,4,5,6,7],
      themeMode: json['theme_mode'] as String? ?? 'system',
      defaultRitualDuration: json['default_ritual_duration'] as int? ?? 3,
      soundEnabled: json['sound_enabled'] as bool? ?? true,
      hapticFeedback: json['haptic_feedback'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications_enabled': notificationsEnabled,
      'daily_reminder_time': dailyReminderTime,
      'reminder_days': reminderDays,
      'theme_mode': themeMode,
      'default_ritual_duration': defaultRitualDuration,
      'sound_enabled': soundEnabled,
      'haptic_feedback': hapticFeedback,
    };
  }
}

/// Servicio de perfil de usuario
class ProfileService {
  static ProfileService? _instance;
  final SupabaseClient _client;
  
  ProfileService._() : _client = SupabaseService.instance.client;
  
  static ProfileService get instance {
    _instance ??= ProfileService._();
    return _instance!;
  }

  String? get _userId => SupabaseService.instance.currentUserId;

  // ═══════════════════════════════════════════════════════════════════
  // PERFIL
  // ═══════════════════════════════════════════════════════════════════

  /// Obtener perfil del usuario actual
  Future<ProfileDbModel?> getProfile() async {
    if (_userId == null) return null;

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', _userId!)
        .maybeSingle();
    
    if (response == null) return null;
    return ProfileDbModel.fromJson(response);
  }

  /// Actualizar perfil
  Future<ProfileDbModel?> updateProfile({
    String? name,
    String? avatarUrl,
    String? timezone,
  }) async {
    if (_userId == null) return null;

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (timezone != null) updates['timezone'] = timezone;

    if (updates.isEmpty) return await getProfile();

    final response = await _client
        .from('profiles')
        .update(updates)
        .eq('id', _userId!)
        .select()
        .single();
    
    return ProfileDbModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // CONFIGURACIÓN
  // ═══════════════════════════════════════════════════════════════════

  /// Obtener configuración del usuario
  Future<UserSettingsDbModel?> getSettings() async {
    if (_userId == null) return null;

    final response = await _client
        .from('user_settings')
        .select()
        .eq('user_id', _userId!)
        .maybeSingle();
    
    if (response == null) return null;
    return UserSettingsDbModel.fromJson(response);
  }

  /// Actualizar configuración
  Future<UserSettingsDbModel?> updateSettings({
    bool? notificationsEnabled,
    String? dailyReminderTime,
    List<int>? reminderDays,
    String? themeMode,
    int? defaultRitualDuration,
    bool? soundEnabled,
    bool? hapticFeedback,
  }) async {
    if (_userId == null) return null;

    final updates = <String, dynamic>{};
    if (notificationsEnabled != null) updates['notifications_enabled'] = notificationsEnabled;
    if (dailyReminderTime != null) updates['daily_reminder_time'] = dailyReminderTime;
    if (reminderDays != null) updates['reminder_days'] = reminderDays;
    if (themeMode != null) updates['theme_mode'] = themeMode;
    if (defaultRitualDuration != null) updates['default_ritual_duration'] = defaultRitualDuration;
    if (soundEnabled != null) updates['sound_enabled'] = soundEnabled;
    if (hapticFeedback != null) updates['haptic_feedback'] = hapticFeedback;

    if (updates.isEmpty) return await getSettings();

    final response = await _client
        .from('user_settings')
        .update(updates)
        .eq('user_id', _userId!)
        .select()
        .single();
    
    return UserSettingsDbModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════════════════════════
  // ESTADÍSTICAS DE USUARIO
  // ═══════════════════════════════════════════════════════════════════

  /// Obtener estadísticas generales del usuario
  Future<Map<String, dynamic>> getUserStats() async {
    if (_userId == null) {
      return {
        'total_rituals': 0,
        'total_completions': 0,
        'total_minutes': 0,
        'best_streak': 0,
        'active_days': 0,
        'member_since': null,
      };
    }

    // Obtener perfil para fecha de registro
    final profile = await getProfile();
    
    // Obtener conteo de rituales
    final ritualsResponse = await _client
        .from('rituals')
        .select('id')
        .eq('user_id', _userId!)
        .eq('is_active', true);
    
    // Obtener completaciones
    final completionsResponse = await _client
        .from('ritual_completions')
        .select('id, duration_seconds, completed_at')
        .eq('user_id', _userId!);
    
    // Obtener mejor racha
    final streaksResponse = await _client
        .from('streaks')
        .select('longest_streak')
        .eq('user_id', _userId!)
        .order('longest_streak', ascending: false)
        .limit(1);

    final rituals = ritualsResponse as List;
    final completions = completionsResponse as List;
    final streaks = streaksResponse as List;

    // Calcular días activos
    Set<String> activeDays = {};
    int totalSeconds = 0;
    for (final c in completions) {
      totalSeconds += (c['duration_seconds'] as int?) ?? 0;
      final date = DateTime.parse(c['completed_at'] as String).toLocal();
      activeDays.add('${date.year}-${date.month}-${date.day}');
    }

    return {
      'total_rituals': rituals.length,
      'total_completions': completions.length,
      'total_minutes': totalSeconds ~/ 60,
      'best_streak': streaks.isNotEmpty ? (streaks[0]['longest_streak'] ?? 0) : 0,
      'active_days': activeDays.length,
      'member_since': profile?.createdAt,
    };
  }
}
