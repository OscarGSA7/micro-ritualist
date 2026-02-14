import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/widgets/glassmorphic_container.dart';

/// Pantalla de Login
/// 
/// Permite al usuario iniciar sesión con email, Google o como invitado
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true; // true = login, false = registro
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: size.height * 0.05),
                
                // Logo y título
                _buildHeader(context, isDark),
                
                SizedBox(height: size.height * 0.05),
                
                // Formulario
                _buildForm(context, isDark, authState),
                
                const SizedBox(height: AppTheme.spacingXL),
                
                // Divisor
                _buildDivider(isDark),
                
                const SizedBox(height: AppTheme.spacingL),
                
                // Botones sociales
                _buildSocialButtons(context, isDark, authState),
                
                const SizedBox(height: AppTheme.spacingXL),
                
                // Botón de invitado
                _buildGuestButton(context, isDark, authState),
                
                const SizedBox(height: AppTheme.spacingL),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Icono de la app
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                    .withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.self_improvement_rounded,
            size: 50,
            color: Colors.white,
          ),
        ).animate().scale(
          duration: 600.ms,
          curve: Curves.elasticOut,
        ),
        
        const SizedBox(height: AppTheme.spacingL),
        
        Text(
          'Micro Ritualist',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ).animate().fadeIn(delay: 200.ms),
        
        const SizedBox(height: AppTheme.spacingS),
        
        Text(
          'Tu bienestar en pequeños momentos',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildForm(BuildContext context, bool isDark, AuthState authState) {
    return GlassmorphicContainer(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tabs Login/Registro
              Container(
                decoration: BoxDecoration(
                  color: isDark 
                      ? AppColors.darkBackground.withOpacity(0.5)
                      : AppColors.lightBackground.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _isLogin
                                ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppTheme.radiusM),
                          ),
                          child: Text(
                            'Iniciar sesión',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _isLogin
                                  ? Colors.white
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isLogin
                                ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppTheme.radiusM),
                          ),
                          child: Text(
                            'Registrarse',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: !_isLogin
                                  ? Colors.white
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingL),
              
              // Campo nombre (solo para registro)
              if (!_isLogin) ...[
                _buildTextField(
                  controller: _nameController,
                  label: 'Nombre',
                  hint: 'Tu nombre',
                  icon: Icons.person_outline_rounded,
                  isDark: isDark,
                ),
                const SizedBox(height: AppTheme.spacingM),
              ],
              
              // Campo email
              _buildTextField(
                controller: _emailController,
                label: 'Correo electrónico',
                hint: 'tu@email.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                isDark: isDark,
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              // Campo contraseña
              _buildTextField(
                controller: _passwordController,
                label: 'Contraseña',
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                isDark: isDark,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              
              const SizedBox(height: AppTheme.spacingL),
              
              // Error message
              if (authState.error != null)
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          authState.error!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (authState.error != null)
                const SizedBox(height: AppTheme.spacingM),
              
              // Botón principal
              FilledButton(
                onPressed: authState.isLoading ? null : _handleSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                ),
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isLogin ? 'Iniciar sesión' : 'Crear cuenta',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ),
            prefixIcon: Icon(
              icon,
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isDark 
                ? AppColors.darkBackground.withOpacity(0.5)
                : AppColors.lightBackground.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: BorderSide(
                color: isDark 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
          child: Text(
            'o continúa con',
            style: TextStyle(
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildSocialButtons(BuildContext context, bool isDark, AuthState authState) {
    return OutlinedButton.icon(
      onPressed: authState.isLoading ? null : _handleGoogleSignIn,
      icon: Image.network(
        'https://www.google.com/favicon.ico',
        width: 20,
        height: 20,
        errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 24),
      ),
      label: const Text('Continuar con Google'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(
          color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildGuestButton(BuildContext context, bool isDark, AuthState authState) {
    return Column(
      children: [
        TextButton.icon(
          onPressed: authState.isLoading ? null : _handleGuestMode,
          icon: Icon(
            Icons.person_outline_rounded,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          label: Text(
            'Continuar como invitado',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Podrás crear una cuenta más tarde',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 700.ms);
  }

  void _handleSubmit() async {
    final authNotifier = ref.read(authProvider.notifier);
    
    final success = await authNotifier.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
    );
    
    if (success && mounted) {
      // La navegación se maneja automáticamente en main.dart
    }
  }

  void _handleGoogleSignIn() async {
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.signInWithGoogle();
  }

  void _handleGuestMode() async {
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.continueAsGuest();
  }
}
