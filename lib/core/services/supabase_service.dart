import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Servicio centralizado para Supabase
/// 
/// Maneja la inicialización y proporciona acceso al cliente
class SupabaseService {
  static SupabaseService? _instance;
  
  SupabaseService._();
  
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }
  
  /// Cliente de Supabase
  SupabaseClient get client => Supabase.instance.client;
  
  /// Usuario actual autenticado
  User? get currentUser => client.auth.currentUser;
  
  /// ID del usuario actual
  String? get currentUserId => currentUser?.id;
  
  /// Verificar si hay un usuario autenticado
  bool get isAuthenticated => currentUser != null;
  
  /// Inicializar Supabase
  static Future<void> initialize() async {
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
  }
  
  /// Stream de cambios en el estado de autenticación
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
