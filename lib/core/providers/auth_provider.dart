import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../services/auth_service.dart';
import '../config/supabase_config.dart';

/// Modelo de usuario
class UserModel {
  final String id;
  final String name;
  final String email;
  final bool isGuest;
  final String? photoUrl;
  final bool isAnonymous;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.isGuest = false,
    this.photoUrl,
    this.isAnonymous = false,
  });

  factory UserModel.guest() {
    return const UserModel(
      id: 'guest',
      name: 'Invitado',
      email: '',
      isGuest: true,
      isAnonymous: false,
    );
  }

  factory UserModel.fromSupabaseUser(supabase.User user) {
    final metadata = user.userMetadata ?? {};
    return UserModel(
      id: user.id,
      name: metadata['name'] ?? metadata['full_name'] ?? user.email?.split('@').first ?? 'Usuario',
      email: user.email ?? '',
      isGuest: false,
      photoUrl: metadata['avatar_url'] ?? metadata['picture'],
      isAnonymous: user.isAnonymous,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'isGuest': isGuest,
    'photoUrl': photoUrl,
    'isAnonymous': isAnonymous,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    isGuest: json['isGuest'] ?? false,
    photoUrl: json['photoUrl'],
    isAnonymous: json['isAnonymous'] ?? false,
  );

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    bool? isGuest,
    String? photoUrl,
    bool? isAnonymous,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isGuest: isGuest ?? this.isGuest,
      photoUrl: photoUrl ?? this.photoUrl,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }
}

/// Estado de autenticación
enum AuthStatus { initial, authenticated, unauthenticated, loading }

/// Estado del provider de autenticación
class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
    bool? isLoading,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Provider de autenticación
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _init();
  }

  StreamSubscription<supabase.AuthState>? _authSubscription;
  static const String _guestKey = 'is_guest_user';

  /// Inicializar y escuchar cambios de autenticación
  Future<void> _init() async {
    state = state.copyWith(status: AuthStatus.loading);
    
    // Verificar si Supabase está configurado
    if (!SupabaseConfig.isConfigured) {
      // Modo offline - verificar si hay usuario invitado guardado
      await _checkLocalGuestUser();
      return;
    }

    // Escuchar cambios de autenticación de Supabase
    _authSubscription = AuthService.instance.authStateChanges.listen(
      (authState) {
        final user = authState.session?.user;
        if (user != null) {
          state = AuthState(
            status: AuthStatus.authenticated,
            user: UserModel.fromSupabaseUser(user),
          );
        } else {
          // Verificar si hay usuario invitado local
          _checkLocalGuestUser();
        }
      },
      onError: (error) {
        state = AuthState(
          status: AuthStatus.unauthenticated,
          error: error.toString(),
        );
      },
    );

    // Verificar sesión actual
    final currentUser = AuthService.instance.currentUser;
    if (currentUser != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: UserModel.fromSupabaseUser(currentUser),
      );
    } else {
      await _checkLocalGuestUser();
    }
  }

  /// Verificar si hay un usuario invitado guardado localmente
  Future<void> _checkLocalGuestUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isGuest = prefs.getBool(_guestKey) ?? false;
    
    if (isGuest) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: UserModel.guest(),
      );
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Registrar nuevo usuario
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      // Validaciones
      if (email.isEmpty || !email.contains('@')) {
        state = state.copyWith(
          isLoading: false,
          error: 'Por favor ingresa un email válido',
        );
        return false;
      }
      
      if (password.length < 6) {
        state = state.copyWith(
          isLoading: false,
          error: 'La contraseña debe tener al menos 6 caracteres',
        );
        return false;
      }

      if (!SupabaseConfig.isConfigured) {
        state = state.copyWith(
          isLoading: false,
          error: 'El servidor no está configurado. Continúa como invitado.',
        );
        return false;
      }

      final response = await AuthService.instance.signUp(
        email: email,
        password: password,
        name: name,
      );

      if (response.user != null) {
        // Limpiar estado de invitado
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_guestKey);
        
        state = AuthState(
          status: AuthStatus.authenticated,
          user: UserModel.fromSupabaseUser(response.user!),
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Error al crear la cuenta. Verifica tu email.',
        );
        return false;
      }
    } on supabase.AuthException catch (e) {
      String errorMessage = 'Error al registrarse';
      if (e.message.contains('already registered')) {
        errorMessage = 'Este email ya está registrado';
      } else if (e.message.contains('invalid')) {
        errorMessage = 'Email o contraseña inválidos';
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error de conexión. Intenta de nuevo.',
      );
      return false;
    }
  }

  /// Iniciar sesión con email y contraseña
  Future<bool> signInWithEmail(String email, String password, [String? name]) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      // Validaciones
      if (email.isEmpty || !email.contains('@')) {
        state = state.copyWith(
          isLoading: false,
          error: 'Por favor ingresa un email válido',
        );
        return false;
      }
      
      if (password.length < 6) {
        state = state.copyWith(
          isLoading: false,
          error: 'La contraseña debe tener al menos 6 caracteres',
        );
        return false;
      }

      if (!SupabaseConfig.isConfigured) {
        state = state.copyWith(
          isLoading: false,
          error: 'El servidor no está configurado. Continúa como invitado.',
        );
        return false;
      }

      final response = await AuthService.instance.signInWithEmail(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Limpiar estado de invitado
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_guestKey);
        
        state = AuthState(
          status: AuthStatus.authenticated,
          user: UserModel.fromSupabaseUser(response.user!),
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Credenciales incorrectas',
        );
        return false;
      }
    } on supabase.AuthException catch (e) {
      String errorMessage = 'Error al iniciar sesión';
      if (e.message.contains('Invalid login')) {
        errorMessage = 'Email o contraseña incorrectos';
      } else if (e.message.contains('Email not confirmed')) {
        errorMessage = 'Por favor confirma tu email primero';
      }
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error de conexión. Intenta de nuevo.',
      );
      return false;
    }
  }

  /// Iniciar sesión con Google
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      if (!SupabaseConfig.isConfigured) {
        state = state.copyWith(
          isLoading: false,
          error: 'El servidor no está configurado.',
        );
        return false;
      }

      final success = await AuthService.instance.signInWithGoogle();
      
      if (!success) {
        state = state.copyWith(
          isLoading: false,
          error: 'No se pudo iniciar sesión con Google',
        );
      }
      // El listener de auth manejará el estado si es exitoso
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al iniciar con Google',
      );
      return false;
    }
  }

  /// Continuar como invitado (modo offline)
  Future<bool> continueAsGuest() async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Guardar estado de invitado localmente
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_guestKey, true);
      
      state = AuthState(
        status: AuthStatus.authenticated,
        user: UserModel.guest(),
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al continuar como invitado',
      );
      return false;
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      // Limpiar sesión de Supabase si está configurado
      if (SupabaseConfig.isConfigured) {
        await AuthService.instance.signOut();
      }
      
      // Limpiar estado local de invitado
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_guestKey);
      
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      // Forzar logout local aunque falle Supabase
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_guestKey);
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Enviar email de recuperación de contraseña
  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    try {
      if (!SupabaseConfig.isConfigured) {
        state = state.copyWith(
          isLoading: false,
          error: 'El servidor no está configurado.',
        );
        return false;
      }

      await AuthService.instance.resetPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al enviar email de recuperación',
      );
      return false;
    }
  }

  /// Actualizar nombre del usuario
  Future<bool> updateUserName(String name) async {
    if (state.user == null) return false;
    
    try {
      if (SupabaseConfig.isConfigured && !state.user!.isGuest) {
        await AuthService.instance.updateUserMetadata({'name': name});
      }
      
      state = state.copyWith(
        user: state.user!.copyWith(name: name),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Convertir cuenta de invitado a cuenta real
  Future<bool> convertGuestAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    if (state.user?.isGuest != true) return false;
    
    // Primero intentar registrarse
    final success = await signUp(
      email: email,
      password: password,
      name: name,
    );
    
    return success;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
