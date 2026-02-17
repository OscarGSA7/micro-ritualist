import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/wellness_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

/// Pantalla de historial de bienestar
/// Muestra el historial de check-ins del usuario
class WellnessHistoryScreen extends ConsumerWidget {
  const WellnessHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wellnessState = ref.watch(wellnessProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Bienestar'),
        centerTitle: true,
      ),
      body: wellnessState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : wellnessState.history.isEmpty
              ? _buildEmptyState(context, isDark)
              : _buildHistoryList(context, wellnessState.history, isDark),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 64,
            color: isDark 
                ? AppColors.darkTextTertiary 
                : AppColors.lightTextTertiary,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Sin historial aún',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isDark 
                  ? AppColors.darkTextSecondary 
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Tus check-ins de bienestar aparecerán aquí',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark 
                  ? AppColors.darkTextTertiary 
                  : AppColors.lightTextTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context, 
    List<WellnessHistoryItem> history, 
    bool isDark,
  ) {
    // Agrupar por fecha
    final groupedHistory = <String, List<WellnessHistoryItem>>{};
    for (final item in history) {
      final dateKey = DateFormat('yyyy-MM-dd').format(item.date);
      groupedHistory.putIfAbsent(dateKey, () => []).add(item);
    }
    
    final sortedKeys = groupedHistory.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Ordenar de más reciente a más antiguo

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedKeys[index];
        final items = groupedHistory[dateKey]!;
        final date = DateTime.parse(dateKey);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(context, date, isDark),
            const SizedBox(height: AppTheme.spacingS),
            ...items.map((item) => _WellnessHistoryCard(
              item: item,
              isDark: isDark,
            )).toList(),
            const SizedBox(height: AppTheme.spacingM),
          ],
        ).animate().fadeIn(delay: (index * 50).ms);
      },
    );
  }

  Widget _buildDateHeader(BuildContext context, DateTime date, bool isDark) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    String dateText;
    if (dateOnly == today) {
      dateText = 'Hoy';
    } else if (dateOnly == yesterday) {
      dateText = 'Ayer';
    } else {
      dateText = DateFormat('EEEE, d MMM', 'es_ES').format(date);
    }

    return Padding(
      padding: const EdgeInsets.only(left: AppTheme.spacingS),
      child: Text(
        dateText,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark 
              ? AppColors.darkTextSecondary 
              : AppColors.lightTextSecondary,
        ),
      ),
    );
  }
}

class _WellnessHistoryCard extends StatelessWidget {
  final WellnessHistoryItem item;
  final bool isDark;

  const _WellnessHistoryCard({
    required this.item,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final scoreColor = _getScoreColor(item.wellnessScore, isDark);
    final emotionEmoji = _getEmotionEmoji(item.emotionalState);
    final energyEmoji = _getEnergyEmoji(item.energyLevel);
    final sleepEmoji = _getSleepEmoji(item.sleepQuality);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkSurface 
            : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: isDark 
              ? AppColors.darkSurfaceVariant 
              : AppColors.lightSurfaceVariant,
        ),
      ),
      child: Row(
        children: [
          // Score circular
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scoreColor.withOpacity(0.1),
              border: Border.all(
                color: scoreColor,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                '${item.wellnessScore}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          
          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.headline != null)
                  Text(
                    item.headline!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(item.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark 
                        ? AppColors.darkTextTertiary 
                        : AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),
          ),
          
          // Emojis de estado
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEmojiChip(emotionEmoji, 'Emoción', context),
              const SizedBox(width: 4),
              _buildEmojiChip(energyEmoji, 'Energía', context),
              const SizedBox(width: 4),
              _buildEmojiChip(sleepEmoji, 'Sueño', context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiChip(String emoji, String tooltip, BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark 
              ? AppColors.darkSurfaceVariant 
              : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Color _getScoreColor(int score, bool isDark) {
    if (score >= 80) {
      return AppColors.success;
    } else if (score >= 60) {
      return isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    } else if (score >= 40) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  String _getEmotionEmoji(String state) {
    const emojis = {
      'happy': '😊',
      'calm': '😌',
      'grateful': '🙏',
      'neutral': '😐',
      'tired': '😴',
      'anxious': '😰',
      'stressed': '😤',
      'sad': '😢',
      'excited': '🤩',
      'frustrated': '😤',
      'hopeful': '🌟',
      'overwhelmed': '😵',
    };
    return emojis[state.toLowerCase()] ?? '😐';
  }

  String _getEnergyEmoji(String level) {
    const emojis = {
      'veryLow': '🪫',
      'low': '😪',
      'medium': '💪',
      'high': '⚡',
      'veryHigh': '🔥',
    };
    return emojis[level] ?? '💪';
  }

  String _getSleepEmoji(String quality) {
    const emojis = {
      'excellent': '😴✨',
      'good': '😴',
      'fair': '😐',
      'poor': '😫',
      'terrible': '😵',
    };
    return emojis[quality] ?? '😴';
  }
}
