import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/notification_settings.dart';
import '../../services/notification_service.dart';

/// Pantalla de configuración de notificaciones para recordatorios de movimiento
/// Permite personalizar horarios, frecuencia y días activos
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  
  late NotificationSettings _settings;
  bool _isLoading = true;
  bool _hasPermissions = false;
  bool _isSaving = false;
  bool _isCustomInterval = false;

  // Opciones de intervalo disponibles
  final List<int> _intervalOptions = [30, 45, 60, 90, 120, 180];
  
  // Nombres de días
  final List<String> _dayNames = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  final List<String> _dayFullNames = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _notificationService.initialize();
    final settings = await _notificationService.loadSettings();
    final hasPermissions = await _notificationService.hasPermissions();
    
    // Verificar si el intervalo es personalizado (no está en las opciones predefinidas)
    final isCustom = !_intervalOptions.contains(settings.intervalMinutes);
    
    setState(() {
      _settings = settings;
      _hasPermissions = hasPermissions;
      _isCustomInterval = isCustom;
      _isLoading = false;
    });
  }

  Future<void> _requestPermissions() async {
    final granted = await _notificationService.requestPermissions();
    setState(() {
      _hasPermissions = granted;
    });
    
    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Necesitas habilitar las notificaciones en la configuración del dispositivo'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    
    await _notificationService.saveSettings(_settings);
    await _notificationService.scheduleNotifications(_settings);
    
    setState(() => _isSaving = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(_settings.isEnabled 
                  ? 'Recordatorios activados: ${_settings.notificationsPerDay} por día'
                  : 'Recordatorios desactivados'),
            ],
          ),
          backgroundColor: _settings.isEnabled ? Colors.green : Colors.grey,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final currentHour = isStart ? _settings.startHour : _settings.endHour;
    final currentMinute = isStart ? _settings.startMinute : _settings.endMinute;
    
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (time != null) {
      setState(() {
        if (isStart) {
          _settings = _settings.copyWith(
            startHour: time.hour,
            startMinute: time.minute,
          );
        } else {
          _settings = _settings.copyWith(
            endHour: time.hour,
            endMinute: time.minute,
          );
        }
      });
    }
  }

  Future<void> _testNotification() async {
    await _notificationService.showTestNotification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notificación de prueba enviada'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _applyPreset(NotificationSettings preset) {
    setState(() {
      _settings = preset;
      _isCustomInterval = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Recordatorios')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Recordatorios de Movimiento'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_hasPermissions)
            IconButton(
              icon: const Icon(Icons.notifications_active_outlined),
              onPressed: _testNotification,
              tooltip: 'Probar notificación',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header informativo
            _buildInfoCard(isDark),
            const SizedBox(height: AppTheme.spacingXL),

            // Permisos
            if (!_hasPermissions) ...[
              _buildPermissionCard(isDark),
              const SizedBox(height: AppTheme.spacingXL),
            ],

            // Switch principal
            _buildMainSwitch(isDark),
            const SizedBox(height: AppTheme.spacingXL),

            // Presets rápidos
            _buildPresetsSection(isDark),
            const SizedBox(height: AppTheme.spacingXL),

            // Configuración de horario
            AnimatedOpacity(
              opacity: _settings.isEnabled ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 200),
              child: AbsorbPointer(
                absorbing: !_settings.isEnabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimeRangeSection(isDark),
                    const SizedBox(height: AppTheme.spacingXL),
                    
                    _buildIntervalSection(isDark),
                    const SizedBox(height: AppTheme.spacingXL),
                    
                    _buildDaysSection(isDark),
                    const SizedBox(height: AppTheme.spacingXL),
                    
                    _buildSummaryCard(isDark),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingXL),
            
            // Botón guardar
            _buildSaveButton(isDark),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [AppColors.darkPrimary.withOpacity(0.2), AppColors.darkSecondary.withOpacity(0.1)]
              : [AppColors.lightPrimary.withOpacity(0.1), AppColors.lightSecondary.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: isDark 
              ? AppColors.darkPrimary.withOpacity(0.3)
              : AppColors.lightPrimary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: const Icon(
              Icons.directions_walk_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pausas Activas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Recibe recordatorios para moverte y reducir el sedentarismo',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildPermissionCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Permisos necesarios',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Permite las notificaciones para recibir recordatorios',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),
          ElevatedButton(
            onPressed: _requestPermissions,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Permitir'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildMainSwitch(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? AppColors.darkShadow.withOpacity(0.1)
                : AppColors.lightShadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _settings.isEnabled ? Icons.notifications_active : Icons.notifications_off,
            color: _settings.isEnabled 
                ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
            size: 28,
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recordatorios activos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _settings.isEnabled 
                      ? 'Recibirás notificaciones según tu configuración'
                      : 'No recibirás recordatorios',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _settings.isEnabled,
            onChanged: _hasPermissions 
                ? (value) => setState(() => _settings = _settings.copyWith(isEnabled: value))
                : null,
            activeColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildPresetsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuraciones rápidas',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Row(
          children: [
            Expanded(
              child: _buildPresetButton(
                isDark,
                'Oficina',
                '9-18h, cada 1h',
                Icons.business_rounded,
                () => _applyPreset(NotificationSettings.officeWorker()),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _buildPresetButton(
                isDark,
                'Intensivo',
                '8-20h, cada 45min',
                Icons.fitness_center_rounded,
                () => _applyPreset(NotificationSettings.intensive()),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _buildPresetButton(bool isDark, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            border: Border.all(
              color: isDark 
                  ? AppColors.darkSurfaceVariant.withOpacity(0.5)
                  : AppColors.lightSurfaceVariant.withOpacity(0.5),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRangeSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horario activo',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          'Las notificaciones solo llegarán dentro de este horario',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Row(
          children: [
            Expanded(
              child: _buildTimeSelector(
                isDark,
                'Desde',
                _settings.startTimeFormatted,
                () => _selectTime(true),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ),
            Expanded(
              child: _buildTimeSelector(
                isDark,
                'Hasta',
                _settings.endTimeFormatted,
                () => _selectTime(false),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  Widget _buildTimeSelector(bool isDark, String label, String time, VoidCallback onTap) {
    return Material(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            border: Border.all(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntervalSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frecuencia',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          'Cada cuánto tiempo recibirás un recordatorio',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Wrap(
          spacing: AppTheme.spacingS,
          runSpacing: AppTheme.spacingS,
          children: [
            // Opciones predefinidas
            ..._intervalOptions.map((minutes) {
              final isSelected = !_isCustomInterval && _settings.intervalMinutes == minutes;
              final label = _formatInterval(minutes);
              
              return ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _isCustomInterval = false;
                      _settings = _settings.copyWith(intervalMinutes: minutes);
                    });
                  }
                },
                selectedColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                labelStyle: TextStyle(
                  color: isSelected 
                      ? Colors.white 
                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                ),
              );
            }),
            // Opción personalizar
            ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 16,
                    color: _isCustomInterval 
                        ? Colors.white 
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  ),
                  const SizedBox(width: 4),
                  Text(_isCustomInterval 
                      ? _formatInterval(_settings.intervalMinutes) 
                      : 'Personalizar'),
                ],
              ),
              selected: _isCustomInterval,
              onSelected: (selected) {
                if (selected) {
                  _showCustomIntervalDialog(isDark);
                }
              },
              selectedColor: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
              labelStyle: TextStyle(
                color: _isCustomInterval 
                    ? Colors.white 
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                fontWeight: _isCustomInterval ? FontWeight.w600 : FontWeight.normal,
              ),
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              side: BorderSide(
                color: _isCustomInterval
                    ? Colors.transparent
                    : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
  }

  Future<void> _showCustomIntervalDialog(bool isDark) async {
    int hours = _settings.intervalMinutes ~/ 60;
    int minutes = _settings.intervalMinutes % 60;

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  ),
                  const SizedBox(width: 8),
                  const Text('Intervalo personalizado'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Configura cada cuánto tiempo quieres recibir recordatorios',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Horas
                      Column(
                        children: [
                          Text(
                            'Horas',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                              borderRadius: BorderRadius.circular(AppTheme.radiusM),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: hours > 0 
                                      ? () => setDialogState(() => hours--) 
                                      : null,
                                  icon: const Icon(Icons.remove_rounded),
                                  iconSize: 20,
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    '$hours',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: hours < 8 
                                      ? () => setDialogState(() => hours++) 
                                      : null,
                                  icon: const Icon(Icons.add_rounded),
                                  iconSize: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          ':',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                      // Minutos
                      Column(
                        children: [
                          Text(
                            'Minutos',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                              borderRadius: BorderRadius.circular(AppTheme.radiusM),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: (hours > 0 || minutes > 15) 
                                      ? () => setDialogState(() {
                                          minutes -= 15;
                                          if (minutes < 0) {
                                            minutes = 45;
                                            if (hours > 0) hours--;
                                          }
                                        }) 
                                      : null,
                                  icon: const Icon(Icons.remove_rounded),
                                  iconSize: 20,
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    minutes.toString().padLeft(2, '0'),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => setDialogState(() {
                                    minutes += 15;
                                    if (minutes >= 60) {
                                      minutes = 0;
                                      if (hours < 8) hours++;
                                    }
                                  }),
                                  icon: const Icon(Icons.add_rounded),
                                  iconSize: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_active_rounded,
                          size: 18,
                          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cada ${_formatIntervalFromMinutes(hours * 60 + minutes)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                  onPressed: (hours * 60 + minutes) >= 15 
                      ? () => Navigator.pop(context, hours * 60 + minutes)
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  ),
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _isCustomInterval = true;
        _settings = _settings.copyWith(intervalMinutes: result);
      });
    }
  }

  String _formatIntervalFromMinutes(int totalMinutes) {
    if (totalMinutes < 60) return '$totalMinutes minutos';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (minutes == 0) {
      return hours == 1 ? '1 hora' : '$hours horas';
    }
    return '${hours}h ${minutes}min';
  }

  String _formatInterval(int minutes) {
    if (minutes < 60) return '$minutes min';
    if (minutes == 60) return '1 hora';
    if (minutes == 90) return '1h 30min';
    if (minutes == 120) return '2 horas';
    if (minutes == 180) return '3 horas';
    return '${minutes ~/ 60}h';
  }

  Widget _buildDaysSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Días activos',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          'Selecciona los días en que quieres recibir recordatorios',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            final isEnabled = _settings.enabledDays[index];
            
            return GestureDetector(
              onTap: () {
                final newDays = List<bool>.from(_settings.enabledDays);
                newDays[index] = !newDays[index];
                setState(() => _settings = _settings.copyWith(enabledDays: newDays));
              },
              child: Tooltip(
                message: _dayFullNames[index],
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                        : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    border: Border.all(
                      color: isEnabled
                          ? Colors.transparent
                          : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _dayNames[index],
                      style: TextStyle(
                        color: isEnabled
                            ? Colors.white
                            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 600.ms);
  }

  Widget _buildSummaryCard(bool isDark) {
    final enabledDaysCount = _settings.enabledDays.where((d) => d).length;
    final totalNotifications = _settings.notificationsPerDay * enabledDaysCount;
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkPrimary.withOpacity(0.1)
            : AppColors.lightPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: isDark 
              ? AppColors.darkPrimary.withOpacity(0.2)
              : AppColors.lightPrimary.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.summarize_rounded,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Resumen',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          _buildSummaryRow(isDark, 'Horario', '${_settings.startTimeFormatted} - ${_settings.endTimeFormatted}'),
          _buildSummaryRow(isDark, 'Frecuencia', 'Cada ${_settings.intervalFormatted}'),
          _buildSummaryRow(isDark, 'Notificaciones/día', '${_settings.notificationsPerDay}'),
          _buildSummaryRow(isDark, 'Días activos', '$enabledDaysCount días'),
          const Divider(height: 24),
          _buildSummaryRow(
            isDark, 
            'Total semanal', 
            '$totalNotifications recordatorios',
            isHighlight: true,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 700.ms);
  }

  Widget _buildSummaryRow(bool isDark, String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              color: isHighlight
                  ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                  : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save_rounded),
                  const SizedBox(width: 8),
                  Text(
                    'Guardar configuración',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 800.ms).slideY(begin: 0.2, end: 0);
  }
}
