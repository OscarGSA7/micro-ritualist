import 'dart:convert';

/// Opciones de sonido de notificación disponibles
enum NotificationSound {
  defaultSound('default', 'Por defecto', 'Sonido predeterminado del sistema'),
  gentle('gentle', 'Suave', 'Un tono suave y calmado'),
  chime('chime', 'Campanilla', 'Campana relajante'),
  zen('zen', 'Zen', 'Sonido de cuenco tibetano'),
  nature('nature', 'Naturaleza', 'Sonido de agua corriente'),
  soft('soft', 'Delicado', 'Tono minimalista y discreto');

  final String id;
  final String displayName;
  final String description;

  const NotificationSound(this.id, this.displayName, this.description);

  static NotificationSound fromId(String id) {
    return NotificationSound.values.firstWhere(
      (sound) => sound.id == id,
      orElse: () => NotificationSound.defaultSound,
    );
  }
}

/// Configuración de notificaciones para recordatorios de movimiento
/// Permite personalizar horarios y frecuencia de alertas
class NotificationSettings {
  /// Si las notificaciones están habilitadas
  final bool isEnabled;
  
  /// Hora de inicio del rango de notificaciones (ej: 9:00)
  final int startHour;
  final int startMinute;
  
  /// Hora de fin del rango de notificaciones (ej: 18:00)
  final int endHour;
  final int endMinute;
  
  /// Intervalo entre notificaciones en minutos
  final int intervalMinutes;
  
  /// Días de la semana habilitados (0 = Lunes, 6 = Domingo)
  final List<bool> enabledDays;
  
  /// Mensajes personalizados para las notificaciones
  final List<String> customMessages;

  /// Sonido de notificación seleccionado
  final NotificationSound notificationSound;

  const NotificationSettings({
    this.isEnabled = false,
    this.startHour = 9,
    this.startMinute = 0,
    this.endHour = 18,
    this.endMinute = 0,
    this.intervalMinutes = 60,
    this.enabledDays = const [true, true, true, true, true, false, false], // L-V
    this.customMessages = const [],
    this.notificationSound = NotificationSound.defaultSound,
  });

  /// Configuración por defecto para trabajadores de oficina
  factory NotificationSettings.officeWorker() {
    return const NotificationSettings(
      isEnabled: true,
      startHour: 9,
      startMinute: 0,
      endHour: 18,
      endMinute: 0,
      intervalMinutes: 60, // Cada hora
      enabledDays: [true, true, true, true, true, false, false],
    );
  }

  /// Configuración intensiva para muy sedentarios
  factory NotificationSettings.intensive() {
    return const NotificationSettings(
      isEnabled: true,
      startHour: 8,
      startMinute: 0,
      endHour: 20,
      endMinute: 0,
      intervalMinutes: 45, // Cada 45 minutos
      enabledDays: [true, true, true, true, true, true, true],
    );
  }

  /// Obtener hora de inicio como TimeOfDay string
  String get startTimeFormatted {
    return '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
  }

  /// Obtener hora de fin como TimeOfDay string
  String get endTimeFormatted {
    return '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
  }

  /// Obtener intervalo formateado
  String get intervalFormatted {
    if (intervalMinutes >= 60) {
      final hours = intervalMinutes ~/ 60;
      final minutes = intervalMinutes % 60;
      if (minutes == 0) {
        return hours == 1 ? '1 hora' : '$hours horas';
      }
      return '$hours h $minutes min';
    }
    return '$intervalMinutes minutos';
  }

  /// Verificar si una hora específica está dentro del rango
  bool isWithinActiveHours(DateTime dateTime) {
    final currentMinutes = dateTime.hour * 60 + dateTime.minute;
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;
    
    return currentMinutes >= startMinutes && currentMinutes < endMinutes;
  }

  /// Verificar si un día específico está habilitado
  bool isDayEnabled(int weekday) {
    // DateTime.weekday: 1 = Monday, 7 = Sunday
    // enabledDays: 0 = Monday, 6 = Sunday
    final index = weekday - 1;
    if (index >= 0 && index < enabledDays.length) {
      return enabledDays[index];
    }
    return false;
  }

  /// Calcular cuántas notificaciones se enviarán por día
  int get notificationsPerDay {
    if (!isEnabled) return 0;
    
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;
    final totalMinutes = endMinutes - startMinutes;
    
    if (totalMinutes <= 0 || intervalMinutes <= 0) return 0;
    
    return (totalMinutes / intervalMinutes).floor();
  }

  NotificationSettings copyWith({
    bool? isEnabled,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    int? intervalMinutes,
    List<bool>? enabledDays,
    List<String>? customMessages,
    NotificationSound? notificationSound,
  }) {
    return NotificationSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      enabledDays: enabledDays ?? this.enabledDays,
      customMessages: customMessages ?? this.customMessages,
      notificationSound: notificationSound ?? this.notificationSound,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
      'intervalMinutes': intervalMinutes,
      'enabledDays': enabledDays,
      'customMessages': customMessages,
      'notificationSound': notificationSound.id,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      isEnabled: json['isEnabled'] ?? false,
      startHour: json['startHour'] ?? 9,
      startMinute: json['startMinute'] ?? 0,
      endHour: json['endHour'] ?? 18,
      endMinute: json['endMinute'] ?? 0,
      intervalMinutes: json['intervalMinutes'] ?? 60,
      enabledDays: (json['enabledDays'] as List<dynamic>?)
          ?.map((e) => e as bool)
          .toList() ?? [true, true, true, true, true, false, false],
      customMessages: (json['customMessages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      notificationSound: NotificationSound.fromId(json['notificationSound'] ?? 'default'),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory NotificationSettings.fromJsonString(String jsonString) {
    return NotificationSettings.fromJson(jsonDecode(jsonString));
  }

  @override
  String toString() {
    return 'NotificationSettings(isEnabled: $isEnabled, range: $startTimeFormatted-$endTimeFormatted, interval: $intervalFormatted)';
  }
}
