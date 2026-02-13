import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Widget contenedor con efecto Glassmorphism premium
/// Diseñado para crear el efecto de vidrio esmerilado característico
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? backgroundColor;
  final double opacity;
  final bool showBorder;
  final VoidCallback? onTap;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 24.0,
    this.blur = 10.0,
    this.backgroundColor,
    this.opacity = 0.1,
    this.showBorder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? 
        (isDark ? Colors.white : AppColors.lightPrimary);

    Widget container = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            color: bgColor.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: showBorder
                ? Border.all(
                    color: isDark 
                        ? AppColors.glassBorder 
                        : Colors.white.withOpacity(0.5),
                    width: 1.5,
                  )
                : null,
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      container = Padding(
        padding: margin!,
        child: container,
      );
    }

    if (onTap != null) {
      container = GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}

/// Contenedor con efecto Neumorphism suave
class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool isPressed;
  final VoidCallback? onTap;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 24.0,
    this.isPressed = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget container = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingM),
      margin: margin,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isPressed
            ? [
                BoxShadow(
                  color: isDark ? Colors.black38 : AppColors.lightShadow,
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ]
            : isDark
                ? AppTheme.neumorphismDark
                : AppTheme.neumorphismLight,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: container,
      );
    }

    return container;
  }
}

/// Contenedor premium con sombras suaves
class PremiumCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? accentColor;
  final VoidCallback? onTap;
  final bool showAccentBorder;

  const PremiumCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 24.0,
    this.backgroundColor,
    this.accentColor,
    this.onTap,
    this.showAccentBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? AppColors.darkSurface : AppColors.lightSurface);

    Widget container = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingL),
      margin: margin,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showAccentBorder && accentColor != null
            ? Border.all(
                color: accentColor!.withOpacity(0.3),
                width: 2,
              )
            : null,
        boxShadow: isDark ? AppTheme.softShadowDark : AppTheme.softShadowLight,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: container,
      );
    }

    return container;
  }
}
