import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/glassmorphic_container.dart';
import '../../../notifications/presentation/screens/notification_settings_screen.dart';
import '../../../notifications/data/models/notification_settings.dart';
import '../../../notifications/services/notification_service.dart';

/// Pantalla de Configuración
/// 
/// Permite al usuario personalizar la aplicación y acceder
/// a diferentes opciones de configuración
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  NotificationSettings _notificationSettings = const NotificationSettings();

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final settings = await _notificationService.loadSettings();
    setState(() {
      _notificationSettings = settings;
    });
  }

  Future<void> _updateNotificationSound(NotificationSound sound) async {
    final newSettings = _notificationSettings.copyWith(notificationSound: sound);
    await _notificationService.saveSettings(newSettings);
    if (newSettings.isEnabled) {
      await _notificationService.scheduleNotifications(newSettings);
    }
    setState(() {
      _notificationSettings = newSettings;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentTheme = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Text(
                  'Configuración',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
              ),
            ),

            // Sección: Apariencia
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                child: _buildSection(
                  context,
                  isDark,
                  'Apariencia',
                  Icons.palette_rounded,
                  [
                    _buildThemeSelector(context, isDark, currentTheme),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingL)),

            // Sección: Notificaciones
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                child: _buildSection(
                  context,
                  isDark,
                  'Notificaciones',
                  Icons.notifications_rounded,
                  [
                    _buildSettingsItem(
                      context,
                      isDark,
                      'Recordatorios de movimiento',
                      'Configura alertas para pausas activas',
                      Icons.directions_walk_rounded,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const NotificationSettingsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildSettingsItem(
                      context,
                      isDark,
                      'Sonido de notificación',
                      _notificationSettings.notificationSound.displayName,
                      Icons.music_note_rounded,
                      onTap: () {
                        _showSoundPicker(context, isDark);
                      },
                    ),
                    _buildSettingsItem(
                      context,
                      isDark,
                      'Vibración',
                      'Retroalimentación háptica',
                      Icons.vibration_rounded,
                      trailing: Switch.adaptive(
                        value: true,
                        onChanged: (value) {
                          // TODO: Implementar
                        },
                        activeColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingL)),

            // Sección: Bienestar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                child: _buildSection(
                  context,
                  isDark,
                  'Bienestar',
                  Icons.favorite_rounded,
                  [
                    _buildSettingsItem(
                      context,
                      isDark,
                      'Restablecer check-in',
                      'Volver a hacer el check-in de hoy',
                      Icons.refresh_rounded,
                      onTap: () {
                        _showResetCheckInDialog(context, isDark);
                      },
                    ),
                    _buildSettingsItem(
                      context,
                      isDark,
                      'Historial de bienestar',
                      'Ver tu progreso',
                      Icons.timeline_rounded,
                      onTap: () {
                        // TODO: Implementar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Próximamente'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    _buildSettingsItem(
                      context,
                      isDark,
                      'Metas personales',
                      'Configura tus objetivos',
                      Icons.flag_rounded,
                      onTap: () {
                        // TODO: Implementar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Próximamente'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingL)),

            // Sección: Datos y Privacidad
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                child: _buildSection(
                  context,
                  isDark,
                  'Datos y Privacidad',
                  Icons.security_rounded,
                  [
                    _buildSettingsItem(
                      context,
                      isDark,
                      'Exportar datos',
                      'Descarga una copia de tus datos',
                      Icons.download_rounded,
                      onTap: () {
                        // TODO: Implementar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Próximamente'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    _buildSettingsItem(
                      context,
                      isDark,
                      'Borrar todos los datos',
                      'Elimina toda tu información',
                      Icons.delete_forever_rounded,
                      isDestructive: true,
                      onTap: () {
                        _showDeleteDataDialog(context, isDark);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingL)),

            // Sección: Soporte
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                child: _buildSection(
                  context,
                  isDark,
                  'Soporte',
                  Icons.help_rounded,
                  [
                    _buildSettingsItem(
                      context,
                      isDark,
                      'Ayuda y tutoriales',
                      'Aprende a usar la app',
                      Icons.school_rounded,
                      onTap: () {
                        // TODO: Implementar
                      },
                    ),
                    _buildSettingsItem(
                      context,
                      isDark,
                      'Contactar soporte',
                      'Envíanos tus dudas',
                      Icons.mail_rounded,
                      onTap: () {
                        // TODO: Implementar
                      },
                    ),
                    _buildSettingsItem(
                      context,
                      isDark,
                      'Valorar la app',
                      'Déjanos tu opinión',
                      Icons.star_rounded,
                      onTap: () {
                        // TODO: Implementar
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spacingL)),

            // Versión de la app
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                child: Center(
                  child: Text(
                    'Micro-Ritualist v1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
              ),
            ),

            // Espacio inferior para el bottom nav
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    bool isDark,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingM),
        GlassmorphicContainer(
          child: Column(
            children: children,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildThemeSelector(BuildContext context, bool isDark, ThemeMode currentTheme) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tema',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              _ThemeOption(
                icon: Icons.light_mode_rounded,
                label: 'Claro',
                isSelected: currentTheme == ThemeMode.light,
                onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
                isDark: isDark,
              ),
              const SizedBox(width: AppTheme.spacingM),
              _ThemeOption(
                icon: Icons.dark_mode_rounded,
                label: 'Oscuro',
                isSelected: currentTheme == ThemeMode.dark,
                onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
                isDark: isDark,
              ),
              const SizedBox(width: AppTheme.spacingM),
              _ThemeOption(
                icon: Icons.settings_suggest_rounded,
                label: 'Sistema',
                isSelected: currentTheme == ThemeMode.system,
                onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    bool isDark,
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    final color = isDestructive 
        ? Colors.red 
        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDestructive ? Colors.red : (isDark ? AppColors.darkPrimary : AppColors.lightPrimary))
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isDestructive 
                      ? Colors.red 
                      : (isDark ? AppColors.darkPrimary : AppColors.lightPrimary),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) 
                trailing
              else if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSoundPicker(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppTheme.spacingM),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              Text(
                'Sonido de notificación',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'Elige un tono relajante',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              ...NotificationSound.values.map((sound) => _buildSoundOption(
                context,
                isDark,
                sound,
                _notificationSettings.notificationSound == sound,
              )),
              const SizedBox(height: AppTheme.spacingL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoundOption(
    BuildContext context,
    bool isDark,
    NotificationSound sound,
    bool isSelected,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _updateNotificationSound(sound);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sonido cambiado a: ${sound.displayName}'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingL,
            vertical: AppTheme.spacingM,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                      : (isDark ? AppColors.darkBackground : AppColors.lightBackground),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Icon(
                  _getSoundIcon(sound),
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sound.displayName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    Text(
                      sound.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSoundIcon(NotificationSound sound) {
    return switch (sound) {
      NotificationSound.defaultSound => Icons.notifications_rounded,
      NotificationSound.gentle => Icons.spa_rounded,
      NotificationSound.chime => Icons.notifications_active_rounded,
      NotificationSound.zen => Icons.self_improvement_rounded,
      NotificationSound.nature => Icons.water_drop_rounded,
      NotificationSound.soft => Icons.music_note_rounded,
    };
  }

  void _showResetCheckInDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        title: const Text('Restablecer check-in'),
        content: const Text(
          '¿Quieres volver a hacer el check-in de bienestar de hoy? Esto te permitirá actualizar tu estado actual.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar reset del check-in
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Check-in restablecido'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            ),
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDataDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Borrar datos'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que quieres borrar todos tus datos? Esta acción no se puede deshacer y perderás:\n\n'
          '• Todas tus rutinas personalizadas\n'
          '• Tu historial de bienestar\n'
          '• Tus estadísticas y rachas\n'
          '• Configuraciones personalizadas',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar borrado de datos
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Todos los datos han sido eliminados'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Borrar todo'),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacingM,
            horizontal: AppTheme.spacingS,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                : (isDark ? AppColors.darkBackground : AppColors.lightBackground),
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
