import 'package:flutter/material.dart';

/// Modelo de datos para una Micro-Rutina
class RoutineModel {
  final String id;
  final String title;
  final String description;
  final int durationMinutes;
  final IconData icon;
  final Color color;
  final double progress;
  final bool isCompleted;
  final DateTime? completedAt;
  final RoutineCategory category;

  const RoutineModel({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.icon,
    required this.color,
    this.progress = 0.0,
    this.isCompleted = false,
    this.completedAt,
    this.category = RoutineCategory.mindfulness,
  });

  RoutineModel copyWith({
    String? id,
    String? title,
    String? description,
    int? durationMinutes,
    IconData? icon,
    Color? color,
    double? progress,
    bool? isCompleted,
    DateTime? completedAt,
    RoutineCategory? category,
  }) {
    return RoutineModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      category: category ?? this.category,
    );
  }
}

/// Categorías de rutinas
enum RoutineCategory {
  breathing,
  movement,
  mindfulness,
  hydration,
  gratitude,
  custom,
}

extension RoutineCategoryExtension on RoutineCategory {
  String get displayName {
    switch (this) {
      case RoutineCategory.breathing:
        return 'Respiración';
      case RoutineCategory.movement:
        return 'Movimiento';
      case RoutineCategory.mindfulness:
        return 'Mindfulness';
      case RoutineCategory.hydration:
        return 'Hidratación';
      case RoutineCategory.gratitude:
        return 'Gratitud';
      case RoutineCategory.custom:
        return 'Personalizado';
    }
  }
}
