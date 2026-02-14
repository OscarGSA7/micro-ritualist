import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modelo de usuario
class UserModel {
  final String id;
  final String name;
  final String email;
  final bool isGuest;
  final String? photoUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.isGuest = false,
    this.photoUrl,
  });

  factory UserModel.guest() {
    return const UserModel(
      id: 'guest',
      name: 'Invitado',
      email: '',
      isGuest: true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'isGuest': isGuest,
    'photoUrl': photoUrl,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    isGuest: json['isGuest'] ?? false,
    photoUrl: json['photoUrl'],
  );
}

/// Estado de autenticación
enum AuthStatus { initial, authenticated, unauthenticated }

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
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
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
    _checkAuthStatus();
  }

  static const String _userKey = 'logged_in_user';
  static const String _isLoggedInKey = 'is_logged_in';

  /// Verificar si el usuario ya está logueado
  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    
    if (isLoggedIn) {
      final userName = prefs.getString('user_name') ?? 'Usuario';
      final userEmail = prefs.getString('user_email') ?? '';
      final isGuest = prefs.getBool('is_guest') ?? false;
      
      state = AuthState(
        status: AuthStatus.authenticated,
        user: UserModel(
          id: isGuest ? 'guest' : userEmail,
          name: userName,
          email: userEmail,
          isGuest: isGuest,
        ),
      );
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Iniciar sesión con email y contraseña
  Future<bool> signInWithEmail(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Simulación de autenticación (en producción usar Firebase)
      await Future.delayed(const Duration(seconds: 1));
      
      // Validación básica
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

      final user = UserModel(
        id: email,
        name: name.isNotEmpty ? name : email.split('@').first,
        email: email,
        isGuest: false,
      );

      await _saveUserLocally(user);
      
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al iniciar sesión: $e',
      );
      return false;
    }
  }

  /// Iniciar sesión con Google (placeholder)
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // TODO: Implementar Google Sign-In con Firebase
      await Future.delayed(const Duration(seconds: 1));
      
      // Por ahora simula un usuario de Google
      final user = UserModel(
        id: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Usuario Google',
        email: 'usuario@gmail.com',
        isGuest: false,
        photoUrl: null,
      );

      await _saveUserLocally(user);
      
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al iniciar con Google: $e',
      );
      return false;
    }
  }

  /// Continuar como invitado
  Future<bool> continueAsGuest() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final user = UserModel.guest();
      await _saveUserLocally(user);
      
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('is_guest');
    
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Guardar usuario localmente
  Future<void> _saveUserLocally(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
    await prefs.setBool('is_guest', user.isGuest);
  }
}
