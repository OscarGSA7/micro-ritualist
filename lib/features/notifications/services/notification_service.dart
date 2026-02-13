import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../data/models/notification_settings.dart';

/// Servicio de notificaciones para recordatorios de movimiento
/// Maneja la programación y cancelación de notificaciones periódicas
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static const String _settingsKey = 'movement_notification_settings';
  static const int _baseNotificationId = 1000;
  
  bool _isInitialized = false;

  /// Mensajes motivacionales para las notificaciones
  static const List<String> _defaultMessages = [
    '¡Es hora de moverse! 🚶‍♂️ Una pausa activa mejora tu concentración.',
    '¿Llevas mucho tiempo sentado? Levántate y estira un poco. 🧘',
    '¡Pausa de movimiento! Camina unos minutos para reactivar la circulación. 💪',
    'Tu cuerpo te lo agradecerá: haz una micro-rutina de 2 minutos. ✨',
    '¡Hora de la micro-rutina! Estira cuello y hombros. 🙆‍♀️',
    'Recuerda: cada movimiento cuenta. ¡Levántate y muévete! 🎯',
    'Pausa activa: respira profundo y estira los brazos. 🌟',
    '¿Tensión en los hombros? Es momento de una pausa. 💆‍♂️',
    '¡Activa tu cuerpo! Una caminata corta mejora tu ánimo. 😊',
    'Tu bienestar importa: toma 2 minutos para moverte. 🌈',
  ];

  /// Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Inicializar timezone
    tz_data.initializeTimeZones();
    
    // Configuración de Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Configuración de iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    debugPrint('NotificationService inicializado');
  }

  /// Callback cuando se toca una notificación
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notificación tocada: ${response.payload}');
    // Aquí puedes navegar a una pantalla específica
  }

  /// Solicitar permisos de notificación
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
    } else if (Platform.isIOS) {
      final iosPlugin = _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }
    return false;
  }

  /// Verificar si los permisos están concedidos
  Future<bool> hasPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        return await androidPlugin.areNotificationsEnabled() ?? false;
      }
    }
    // En iOS asumimos que sí si llegamos aquí
    return true;
  }

  /// Guardar configuración de notificaciones
  Future<void> saveSettings(NotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, settings.toJsonString());
    debugPrint('Configuración guardada: $settings');
  }

  /// Cargar configuración de notificaciones
  Future<NotificationSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_settingsKey);
    
    if (jsonString != null) {
      return NotificationSettings.fromJsonString(jsonString);
    }
    
    return const NotificationSettings();
  }

  /// Programar notificaciones según la configuración
  Future<void> scheduleNotifications(NotificationSettings settings) async {
    // Primero cancelar todas las notificaciones programadas
    await cancelAllNotifications();
    
    if (!settings.isEnabled) {
      debugPrint('Notificaciones deshabilitadas');
      return;
    }

    // Verificar permisos
    final hasPermission = await hasPermissions();
    if (!hasPermission) {
      debugPrint('No hay permisos para notificaciones');
      return;
    }

    // Programar notificaciones para cada día habilitado
    int notificationId = _baseNotificationId;
    
    for (int dayIndex = 0; dayIndex < settings.enabledDays.length; dayIndex++) {
      if (!settings.enabledDays[dayIndex]) continue;
      
      // dayIndex: 0 = Monday, 6 = Sunday
      // DateTime.weekday: 1 = Monday, 7 = Sunday
      final weekday = dayIndex + 1;
      
      // Calcular las horas de notificación para este día
      int currentMinutes = settings.startHour * 60 + settings.startMinute;
      final endMinutes = settings.endHour * 60 + settings.endMinute;
      
      while (currentMinutes < endMinutes) {
        final hour = currentMinutes ~/ 60;
        final minute = currentMinutes % 60;
        
        await _scheduleWeeklyNotification(
          id: notificationId++,
          weekday: weekday,
          hour: hour,
          minute: minute,
          settings: settings,
        );
        
        currentMinutes += settings.intervalMinutes;
      }
    }

    debugPrint('Notificaciones programadas: ${notificationId - _baseNotificationId}');
  }

  /// Programar una notificación semanal específica
  Future<void> _scheduleWeeklyNotification({
    required int id,
    required int weekday,
    required int hour,
    required int minute,
    required NotificationSettings settings,
  }) async {
    // Obtener mensaje aleatorio
    final messages = settings.customMessages.isNotEmpty 
        ? settings.customMessages 
        : _defaultMessages;
    final message = messages[Random().nextInt(messages.length)];

    // Calcular la próxima fecha para este día/hora
    final scheduledDate = _nextInstanceOfWeekdayTime(weekday, hour, minute);

    // Determinar el sonido a usar
    AndroidNotificationSound? androidSound;
    if (settings.notificationSound != NotificationSound.defaultSound) {
      androidSound = RawResourceAndroidNotificationSound(settings.notificationSound.id);
    }

    // Configuración de la notificación
    final androidDetails = AndroidNotificationDetails(
      'movement_reminders',
      'Recordatorios de Movimiento',
      channelDescription: 'Notificaciones para recordarte moverte y hacer pausas activas',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
      sound: androidSound,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      '¡Hora de moverse!',
      message,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'movement_reminder',
    );
  }

  /// Calcular la próxima instancia de un día/hora específicos
  tz.TZDateTime _nextInstanceOfWeekdayTime(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Ajustar al día de la semana correcto
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Si ya pasó esta semana, ir a la siguiente
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }

  /// Cancelar todas las notificaciones programadas
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('Todas las notificaciones canceladas');
  }

  /// Enviar una notificación inmediata (para pruebas)
  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'movement_reminders',
      'Recordatorios de Movimiento',
      channelDescription: 'Notificaciones para recordarte moverte',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final message = _defaultMessages[Random().nextInt(_defaultMessages.length)];

    await _notifications.show(
      0,
      '¡Hora de moverse!',
      message,
      notificationDetails,
      payload: 'test_notification',
    );
  }

  /// Obtener las notificaciones pendientes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
