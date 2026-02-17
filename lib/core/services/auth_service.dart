import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Servicio de autenticación con Supabase
/// 
/// Maneja login, registro, logout y gestión de sesión
class AuthService {
  static AuthService? _instance;
  final SupabaseClient _client;
  
  AuthService._() : _client = SupabaseService.instance.client;
  
  static AuthService get instance {
    _instance ??= AuthService._();
    return _instance!;
  }
  
  /// Usuario actual
  User? get currentUser => _client.auth.currentUser;
  
  /// Stream de cambios de autenticación
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  /// Registrar nuevo usuario con email y password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    return response;
  }
  
  /// Iniciar sesión con email y password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }
  
  /// Iniciar sesión con Google
  Future<bool> signInWithGoogle() async {
    final response = await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.microritualist://login-callback/',
    );
    return response;
  }
  
  /// Iniciar sesión con Apple
  Future<bool> signInWithApple() async {
    final response = await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'io.supabase.microritualist://login-callback/',
    );
    return response;
  }
  
  /// Iniciar sesión anónimo (invitado)
  Future<AuthResponse> signInAnonymously() async {
    final response = await _client.auth.signInAnonymously();
    return response;
  }
  
  /// Cerrar sesión
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  /// Enviar email para restablecer contraseña
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }
  
  /// Actualizar contraseña
  Future<UserResponse> updatePassword(String newPassword) async {
    final response = await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    return response;
  }
  
  /// Actualizar email
  Future<UserResponse> updateEmail(String newEmail) async {
    final response = await _client.auth.updateUser(
      UserAttributes(email: newEmail),
    );
    return response;
  }
  
  /// Actualizar metadatos del usuario
  Future<UserResponse> updateUserMetadata(Map<String, dynamic> data) async {
    final response = await _client.auth.updateUser(
      UserAttributes(data: data),
    );
    return response;
  }
  
  /// Verificar si el email ya está registrado
  /// Nota: Esto es una operación indirecta
  Future<bool> isEmailRegistered(String email) async {
    try {
      // Intentar enviar reset password - si no falla, el email existe
      await _client.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Refrescar sesión
  Future<AuthResponse> refreshSession() async {
    final response = await _client.auth.refreshSession();
    return response;
  }
  
  /// Obtener sesión actual
  Session? get currentSession => _client.auth.currentSession;
  
  /// Verificar si hay sesión válida
  bool get hasValidSession => currentSession != null && !currentSession!.isExpired;
}
