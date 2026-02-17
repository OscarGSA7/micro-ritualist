import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Servicio centralizado para Supabase
/// 
/// Maneja la inicialización y proporciona acceso al cliente
class SupabaseService {
  static SupabaseService? _instance;
  static bool _isInitialized = false;
  
  SupabaseService._();
  
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// Verificar si Supabase está inicializado
  static bool get isInitialized => _isInitialized;
  
  /// Cliente de Supabase (null si no está inicializado)
  SupabaseClient? get clientOrNull => _isInitialized ? Supabase.instance.client : null;
  
  /// Cliente de Supabase (lanza error si no está inicializado)
  SupabaseClient get client {
    if (!_isInitialized) {
      throw Exception('Supabase no está inicializado. Usa clientOrNull para acceso seguro.');
    }
    return Supabase.instance.client;
  }
  
  /// Usuario actual autenticado
  User? get currentUser => clientOrNull?.auth.currentUser;
  
  /// ID del usuario actual
  String? get currentUserId => currentUser?.id;
  
  /// Verificar si hay un usuario autenticado
  bool get isAuthenticated => currentUser != null;
  
  /// Inicializar Supabase
  static Future<void> initialize() async {
    if (_isInitialized) return; // Ya inicializado
    
    if (!SupabaseConfig.isConfigured) {
      throw Exception(
        'Supabase no está configurado. '
        'Por favor actualiza lib/core/config/supabase_config.dart con tu anon key.',
      );
    }
    
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );
    
    _isInitialized = true;
  }
  
  /// Stream de cambios en el estado de autenticación
  Stream<AuthState>? get authStateChanges => clientOrNull?.auth.onAuthStateChange;
}
