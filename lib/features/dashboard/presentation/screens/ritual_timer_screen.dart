import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/ritual_model.dart';

/// Pantalla de temporizador para rituales
/// Muestra cuenta regresiva con controles de pausa e interrupción
class RitualTimerScreen extends StatefulWidget {
  final RitualModel ritual;

  const RitualTimerScreen({
    super.key,
    required this.ritual,
  });

  @override
  State<RitualTimerScreen> createState() => _RitualTimerScreenState();
}

class _RitualTimerScreenState extends State<RitualTimerScreen>
    with TickerProviderStateMixin {
  // Timer state
  late int _remainingSeconds;
  late int _totalSeconds;
  Timer? _timer;
  bool _isPaused = false;
  bool _isCompleted = false;

  // Animation controller para el círculo de progreso
  late AnimationController _progressController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.ritual.durationMinutes * 60;
    _remainingSeconds = _totalSeconds;

    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _totalSeconds),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Iniciar automáticamente
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _progressController.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _completeRitual();
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
    });
    _timer?.cancel();
    _progressController.stop();
  }

  void _resumeTimer() {
    setState(() {
      _isPaused = false;
    });
    _progressController.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _completeRitual();
      }
    });
  }

  void _completeRitual() {
    _timer?.cancel();
    setState(() {
      _isCompleted = true;
    });
    _pulseController.stop();

    // Mostrar diálogo de completado después de una pequeña pausa
    Future.delayed(const Duration(milliseconds: 500), () {
      _showCompletionDialog();
    });
  }

  void _interruptRitual() {
    _timer?.cancel();
    _progressController.stop();

    showDialog(
      context: context,
      builder: (context) => _buildInterruptDialog(),
    );
  }

  void _showCompletionDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: widget.ritual.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: widget.ritual.color,
                size: 48,
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              '¡Ritual completado!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              'Has completado "${widget.ritual.title}"',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar diálogo
                  Navigator.of(context).pop(true); // Volver al dashboard con resultado
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.ritual.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  ),
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterruptDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
      ),
      title: Text(
        '¿Interrumpir ritual?',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        'Puedes retomarlo más tarde desde donde lo dejaste.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _resumeTimer();
          },
          child: Text(
            'Continuar',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Cerrar diálogo
            Navigator.of(context).pop(false); // Volver al dashboard sin completar
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: const Text('Interrumpir'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = 1 - (_remainingSeconds / _totalSeconds);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header con botón de cerrar
            _buildHeader(isDark),

            // Contenido principal con scroll
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Título del ritual
                      _buildRitualInfo(isDark),

                      const SizedBox(height: AppTheme.spacingXL),

                      // Círculo de progreso con timer
                      _buildTimerCircle(isDark, progress),

                      const SizedBox(height: AppTheme.spacingXL),

                      // Controles
                      _buildControls(isDark),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón de volver/interrumpir
          GestureDetector(
            onTap: _interruptRitual,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Icon(
                Icons.close_rounded,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),

          // Categoría del ritual
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: widget.ritual.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.ritual.icon,
                  size: 16,
                  color: widget.ritual.color,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.ritual.category.displayName,
                  style: TextStyle(
                    color: widget.ritual.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Espacio para balancear
          const SizedBox(width: 44),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildRitualInfo(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
      child: Column(
        children: [
          Text(
            widget.ritual.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            widget.ritual.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms);
  }

  Widget _buildTimerCircle(bool isDark, double progress) {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseScale = _isPaused ? 1.0 : 1.0 + (_pulseController.value * 0.02);

        return Transform.scale(
          scale: pulseScale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Círculo de fondo
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightSurfaceVariant,
                ),
              ),

              // Círculo de progreso
              SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.ritual.color),
                  strokeCap: StrokeCap.round,
                ),
              ),

              // Tiempo restante
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeString,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w300,
                      fontSize: 42,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isPaused ? 'En pausa' : 'Restante',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),

              // Icono de pausa superpuesto
              if (_isPaused)
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isDark ? Colors.black : Colors.white).withOpacity(0.7),
                  ),
                  child: Icon(
                    Icons.pause_rounded,
                    size: 60,
                    color: widget.ritual.color,
                  ),
                ),
            ],
          ),
        );
      },
    ).animate().scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1, 1),
      duration: 600.ms,
      delay: 200.ms,
      curve: Curves.easeOutBack,
    );
  }

  Widget _buildControls(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botón de interrumpir
          _buildControlButton(
            icon: Icons.stop_rounded,
            label: 'Interrumpir',
            color: AppColors.error,
            onTap: _interruptRitual,
            isDark: isDark,
          ),

          const SizedBox(width: AppTheme.spacingXL),

          // Botón de pausa/reanudar
          _buildControlButton(
            icon: _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            label: _isPaused ? 'Reanudar' : 'Pausar',
            color: widget.ritual.color,
            onTap: _isPaused ? _resumeTimer : _pauseTimer,
            isDark: isDark,
            isPrimary: true,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isPrimary ? 80 : 64,
            height: isPrimary ? 80 : 64,
            decoration: BoxDecoration(
              color: isPrimary ? color : color.withOpacity(0.15),
              shape: BoxShape.circle,
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isPrimary ? Colors.white : color,
              size: isPrimary ? 40 : 32,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
