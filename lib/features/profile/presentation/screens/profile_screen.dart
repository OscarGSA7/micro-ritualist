import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/glassmorphic_container.dart';
import '../../../notifications/presentation/screens/notification_settings_screen.dart';

/// Pantalla de Perfil del Usuario
/// 
/// Muestra información del usuario, estadísticas de hábitos,
/// registro de actividad y configuraciones personales
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Datos de ejemplo - En producción vendrán del estado
  final _userData = _UserData(
    name: 'Usuario',
    email: 'usuario@ejemplo.com',
    joinDate: DateTime(2024, 1, 15),
    totalRitualsCompleted: 127,
    currentStreak: 7,
    longestStreak: 14,
    favoriteRitual: 'Respiración 4-7-8',
  );

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
                child: _buildHeader(context, isDark),
              ),
            ),

            // Tarjeta de perfil
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                child: _buildProfileCard(context, isDark),
              ),
            ),

            // Estadísticas
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: _buildStatsSection(context, isDark),
              ),
            ),

            // Racha actual
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                child: _buildStreakCard(context, isDark),
              ),
            ),

            // Historial de hábitos
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: _buildHabitsHistorySection(context, isDark),
              ),
            ),

            // Configuración de tema
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                child: _buildThemeSection(context, ref, isDark, currentTheme),
              ),
            ),

            // Recordatorios de movimiento
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: _buildNotificationsSection(context, isDark),
              ),
            ),

            // Espacio inferior para el bottom nav
            const SliverToBoxAdapter(
              child: SizedBox(height: 80),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Text(
      'Mi Perfil',
      style: Theme.of(context).textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildProfileCard(BuildContext context, bool isDark) {
    return GlassmorphicContainer(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                        .withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            
            const SizedBox(width: AppTheme.spacingL),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userData.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userData.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark 
                          ? AppColors.darkTextSecondary 
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Miembro desde ${_formatDate(_userData.joinDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark 
                          ? AppColors.darkTextTertiary 
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Botón editar
            IconButton(
              onPressed: () {
                // TODO: Navegar a editar perfil
              },
              icon: Icon(
                Icons.edit_rounded,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas',
          style: Theme.of(context).textTheme.headlineMedium,
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
        
        const SizedBox(height: AppTheme.spacingM),
        
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Rutinas\nCompletadas',
                value: _userData.totalRitualsCompleted.toString(),
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _StatCard(
                title: 'Mejor\nRacha',
                value: '${_userData.longestStreak} días',
                icon: Icons.local_fire_department_rounded,
                color: AppColors.warning,
                isDark: isDark,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildStreakCard(BuildContext context, bool isDark) {
    return GlassmorphicContainer(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: const Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.warning,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Racha Actual',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_userData.currentStreak} días consecutivos',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark 
                            ? AppColors.darkTextSecondary 
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Calendario de la semana
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final isCompleted = index < _userData.currentStreak;
                final isToday = index == _userData.currentStreak - 1;
                final dayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                
                return Column(
                  children: [
                    Text(
                      dayLabels[index],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark 
                            ? AppColors.darkTextTertiary 
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted 
                            ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                            : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                        shape: BoxShape.circle,
                        border: isToday 
                            ? Border.all(
                                color: AppColors.warning,
                                width: 2,
                              )
                            : null,
                      ),
                      child: isCompleted 
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildHabitsHistorySection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Registro de Hábitos',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: () {
                // TODO: Ver historial completo
              },
              child: Text(
                'Ver todo',
                style: TextStyle(
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppTheme.spacingM),
        
        // Lista de rituales recientes
        ...List.generate(3, (index) {
          final rituals = [
            _RecentRitual('Respiración 4-7-8', 'Hoy, 08:30', true),
            _RecentRitual('Estiramientos suaves', 'Hoy, 12:15', true),
            _RecentRitual('Gratitud consciente', 'Ayer, 21:00', true),
          ];
          
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
            child: _RitualHistoryItem(
              ritual: rituals[index],
              isDark: isDark,
            ),
          );
        }),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildThemeSection(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    ThemeMode currentTheme,
  ) {
    return GlassmorphicContainer(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apariencia',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                const SizedBox(width: AppTheme.spacingS),
                _ThemeOption(
                  icon: Icons.dark_mode_rounded,
                  label: 'Oscuro',
                  isSelected: currentTheme == ThemeMode.dark,
                  onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
                  isDark: isDark,
                ),
                const SizedBox(width: AppTheme.spacingS),
                _ThemeOption(
                  icon: Icons.settings_brightness_rounded,
                  label: 'Sistema',
                  isSelected: currentTheme == ThemeMode.system,
                  onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildNotificationsSection(BuildContext context, bool isDark) {
    return GlassmorphicContainer(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const NotificationSettingsScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? AppColors.darkPrimary.withOpacity(0.2)
                        : AppColors.lightPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: Icon(
                    Icons.notifications_active_rounded,
                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recordatorios de movimiento',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Configura alertas para pausas activas',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark 
                              ? AppColors.darkTextSecondary 
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark 
                      ? AppColors.darkTextTertiary 
                      : AppColors.lightTextTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 700.ms).slideY(begin: 0.1, end: 0);
  }

  String _formatDate(DateTime date) {
    final months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

/// Datos del usuario
class _UserData {
  final String name;
  final String email;
  final DateTime joinDate;
  final int totalRitualsCompleted;
  final int currentStreak;
  final int longestStreak;
  final String favoriteRitual;

  _UserData({
    required this.name,
    required this.email,
    required this.joinDate,
    required this.totalRitualsCompleted,
    required this.currentStreak,
    required this.longestStreak,
    required this.favoriteRitual,
  });
}

/// Tarjeta de estadística
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark 
                    ? AppColors.darkTextSecondary 
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Registro de ritual reciente
class _RecentRitual {
  final String name;
  final String time;
  final bool completed;

  _RecentRitual(this.name, this.time, this.completed);
}

/// Item del historial de rituales
class _RitualHistoryItem extends StatelessWidget {
  final _RecentRitual ritual;
  final bool isDark;

  const _RitualHistoryItem({
    required this.ritual,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkSurfaceVariant.withOpacity(0.5) 
            : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ritual.completed 
                  ? AppColors.success.withOpacity(0.2)
                  : AppColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: Icon(
              ritual.completed 
                  ? Icons.check_circle_rounded 
                  : Icons.radio_button_unchecked_rounded,
              color: ritual.completed ? AppColors.success : AppColors.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ritual.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ritual.time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark 
                        ? AppColors.darkTextTertiary 
                        : AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Opción de tema
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
    final selectedColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingS,
            vertical: AppTheme.spacingM,
          ),
          decoration: BoxDecoration(
            color: isSelected 
                ? selectedColor.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            border: Border.all(
              color: isSelected 
                  ? selectedColor 
                  : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected 
                    ? selectedColor 
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected 
                      ? selectedColor 
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
