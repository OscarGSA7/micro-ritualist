import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/services/supabase_service.dart';
import 'core/services/sync_service.dart';
import 'shared/widgets/main_shell.dart';
import 'features/notifications/services/notification_service.dart';
import 'features/auth/presentation/screens/login_screen.dart';

/// Punto de entrada de Micro-Ritualist
/// App de bienestar basada en micro-rutinas de 2-5 minutos
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar orientación preferida
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar para pantalla completa edge-to-edge
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
  );

  // Hacer transparentes las barras de sistema
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // Inicializar Supabase
  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('⚠️ Supabase no inicializado: $e');
    // La app puede funcionar en modo offline/invitado
  }

  // Inicializar servicio de sincronización
  SyncService.instance.initialize();

  // Inicializar servicio de notificaciones
  await NotificationService().initialize();

  runApp(
    const ProviderScope(
      child: MicroRitualistApp(),
    ),
  );
}

/// Widget principal de la aplicación
class MicroRitualistApp extends ConsumerWidget {
  const MicroRitualistApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchar cambios en el tema
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      // ═══════════════════════════════════════════════════════════════
      // CONFIGURACIÓN GENERAL
      // ═══════════════════════════════════════════════════════════════
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      
      // ═══════════════════════════════════════════════════════════════
      // TEMAS - Light & Dark Mode
      // ═══════════════════════════════════════════════════════════════
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode, // Controlado por el provider
      
      // ═══════════════════════════════════════════════════════════════
      // PANTALLA INICIAL - Basada en estado de autenticación
      // ═══════════════════════════════════════════════════════════════
      home: const AuthWrapper(),
      
      // ═══════════════════════════════════════════════════════════════
      // RUTAS (para navegación futura)
      // ═══════════════════════════════════════════════════════════════
      // routes: {
      //   '/': (context) => const DashboardScreen(),
      //   '/ritual-detail': (context) => const RitualDetailScreen(),
      //   '/settings': (context) => const SettingsScreen(),
      //   '/onboarding': (context) => const OnboardingScreen(),
      // },
      
      // ═══════════════════════════════════════════════════════════════
      // CONSTRUCTORES DE TEMA PERSONALIZADOS
      // ═══════════════════════════════════════════════════════════════
      builder: (context, child) {
        // Actualizar colores de barra de sistema según el tema
        final isDark = Theme.of(context).brightness == Brightness.dark;
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarDividerColor: Colors.transparent,
          ),
        );
        
        // Aplicar escala de texto máxima para accesibilidad
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.3),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}

/// Widget que decide qué pantalla mostrar según el estado de autenticación
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Mientras se verifica el estado inicial
    if (authState.status == AuthStatus.initial) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Si está autenticado, mostrar la app principal
    if (authState.status == AuthStatus.authenticated) {
      return const MainShell();
    }

    // Si no está autenticado, mostrar login
    return const LoginScreen();
  }
}
