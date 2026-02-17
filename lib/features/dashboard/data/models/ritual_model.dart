import 'package:flutter/material.dart';

/// Modelo de datos para un Micro-Ritual
class RitualModel {
  final String id;
  final String title;
  final String description;
  final int durationMinutes;
  final IconData icon;
  final Color color;
  final double progress;
  final bool isCompleted;
  final DateTime? completedAt;
  final RitualCategory category;
  final int streak;

  const RitualModel({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.icon,
    required this.color,
    this.progress = 0.0,
    this.isCompleted = false,
    this.completedAt,
    this.category = RitualCategory.mindfulness,
    this.streak = 0,
  });

  RitualModel copyWith({
    String? id,
    String? title,
    String? description,
    int? durationMinutes,
    IconData? icon,
    Color? color,
    double? progress,
    bool? isCompleted,
    DateTime? completedAt,
    RitualCategory? category,
    int? streak,
  }) {
    return RitualModel(
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
      streak: streak ?? this.streak,
    );
  }
}

/// Categorías de rituales
enum RitualCategory {
  breathing,
  movement,
  mindfulness,
  hydration,
  gratitude,
  custom,
}

extension RitualCategoryExtension on RitualCategory {
  String get displayName {
    switch (this) {
      case RitualCategory.breathing:
        return 'Respiración';
      case RitualCategory.movement:
        return 'Movimiento';
      case RitualCategory.mindfulness:
        return 'Mindfulness';
      case RitualCategory.hydration:
        return 'Hidratación';
      case RitualCategory.gratitude:
        return 'Gratitud';
      case RitualCategory.custom:
        return 'Personalizado';
    }
  }
}
