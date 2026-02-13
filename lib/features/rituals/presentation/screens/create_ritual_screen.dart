import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../dashboard/data/models/ritual_model.dart';

/// Pantalla para crear un nuevo ritual personalizado
/// 
/// Se muestra como modal desde el bottom navigation
class CreateRitualScreen extends StatefulWidget {
  final ScrollController scrollController;
  final ValueChanged<RitualModel> onRitualCreated;
  final VoidCallback onCancel;

  const CreateRitualScreen({
    super.key,
    required this.scrollController,
    required this.onRitualCreated,
    required this.onCancel,
  });

  @override
  State<CreateRitualScreen> createState() => _CreateRitualScreenState();
}

class _CreateRitualScreenState extends State<CreateRitualScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  RitualCategory _selectedCategory = RitualCategory.mindfulness;
  int _selectedDuration = 3;
  Color _selectedColor = AppColors.lightPrimary;
  IconData _selectedIcon = Icons.self_improvement_rounded;

  // Opciones de duración
  final List<int> _durationOptions = [2, 3, 5, 10, 15];
  
  // Opciones de colores
  final List<Color> _colorOptions = [
    AppColors.lightPrimary,
    AppColors.lightSecondary,
    AppColors.lightAccent,
    AppColors.success,
    AppColors.info,
    AppColors.warning,
  ];
  
  // Opciones de íconos
  final List<IconData> _iconOptions = [
    Icons.self_improvement_rounded,
    Icons.air_rounded,
    Icons.favorite_rounded,
    Icons.local_drink_rounded,
    Icons.spa_rounded,
    Icons.directions_walk_rounded,
    Icons.music_note_rounded,
    Icons.wb_sunny_rounded,
    Icons.bedtime_rounded,
    Icons.emoji_nature_rounded,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Form(
      key: _formKey,
      child: ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(AppTheme.spacingL),
        children: [
          // Handle del modal
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppTheme.spacingL),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.white.withOpacity(0.3) 
                    : Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header
          _buildHeader(context, isDark),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          // Campo de título
          _buildTitleField(isDark),
          
          const SizedBox(height: AppTheme.spacingL),
          
          // Campo de descripción
          _buildDescriptionField(isDark),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          // Selector de categoría
          _buildCategorySelector(context, isDark),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          // Selector de duración
          _buildDurationSelector(context, isDark),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          // Selector de ícono
          _buildIconSelector(context, isDark),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          // Selector de color
          _buildColorSelector(context, isDark),
          
          const SizedBox(height: AppTheme.spacingXXL),
          
          // Botones de acción
          _buildActionButtons(isDark),
          
          const SizedBox(height: AppTheme.spacingL),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nueva Rutina',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Crea tu micro-rutina personalizada',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark 
                    ? AppColors.darkTextSecondary 
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: widget.onCancel,
          icon: Icon(
            Icons.close_rounded,
            color: isDark 
                ? AppColors.darkTextSecondary 
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildTitleField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nombre de la rutina',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark 
                ? AppColors.darkTextPrimary 
                : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Ej: Respiración profunda',
            filled: true,
            fillColor: isDark 
                ? AppColors.darkSurfaceVariant 
                : AppColors.lightSurfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor, ingresa un nombre';
            }
            return null;
          },
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDescriptionField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción (opcional)',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark 
                ? AppColors.darkTextPrimary 
                : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Describe brevemente tu rutina...',
            filled: true,
            fillColor: isDark 
                ? AppColors.darkSurfaceVariant 
                : AppColors.lightSurfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: BorderSide.none,
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
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildCategorySelector(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark 
                ? AppColors.darkTextPrimary 
                : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Wrap(
          spacing: AppTheme.spacingS,
          runSpacing: AppTheme.spacingS,
          children: RitualCategory.values.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                      : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  border: Border.all(
                    color: isSelected 
                        ? Colors.transparent
                        : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
                  ),
                ),
                child: Text(
                  category.displayName,
                  style: TextStyle(
                    color: isSelected 
                        ? Colors.white
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDurationSelector(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duración',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark 
                ? AppColors.darkTextPrimary 
                : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Row(
          children: _durationOptions.map((duration) {
            final isSelected = _selectedDuration == duration;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDuration = duration),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                        : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$duration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected 
                              ? Colors.white
                              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        ),
                      ),
                      Text(
                        'min',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected 
                              ? Colors.white.withOpacity(0.8)
                              : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 250.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildIconSelector(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ícono',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark 
                ? AppColors.darkTextPrimary 
                : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Wrap(
          spacing: AppTheme.spacingS,
          runSpacing: AppTheme.spacingS,
          children: _iconOptions.map((icon) {
            final isSelected = _selectedIcon == icon;
            return GestureDetector(
              onTap: () => setState(() => _selectedIcon = icon),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? _selectedColor.withOpacity(0.2)
                      : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  border: Border.all(
                    color: isSelected 
                        ? _selectedColor
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon,
                  color: isSelected 
                      ? _selectedColor
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  size: 24,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildColorSelector(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark 
                ? AppColors.darkTextPrimary 
                : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _colorOptions.map((color) {
            final isSelected = _selectedColor == color;
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected 
                        ? (isDark ? Colors.white : Colors.black.withOpacity(0.3))
                        : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected 
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: isSelected 
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 350.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildActionButtons(bool isDark) {
    return Row(
      children: [
        // Botón cancelar
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
              side: BorderSide(
                color: isDark 
                    ? Colors.white.withOpacity(0.2) 
                    : Colors.black.withOpacity(0.1),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark 
                    ? AppColors.darkTextSecondary 
                    : AppColors.lightTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: AppTheme.spacingM),
        
        // Botón crear
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _createRitual,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Crear Rutina',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  void _createRitual() {
    if (!_formKey.currentState!.validate()) return;
    
    final newRitual = RitualModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? 'Rutina personalizada de $_selectedDuration minutos'
          : _descriptionController.text.trim(),
      durationMinutes: _selectedDuration,
      icon: _selectedIcon,
      color: _selectedColor,
      category: _selectedCategory,
    );
    
    widget.onRitualCreated(newRitual);
  }
}
