import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_spacing.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? borderRadius;
  final bool showBorder;
  final double elevation;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.showBorder = true,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? const Color(0xFF1E293B) : Colors.white),
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        border: showBorder
            ? Border.all(
                color: isDark ? const Color(0x1AFFFFFF) : const Color(0xFFE2E8F0),
                width: 1,
              )
            : null,
        boxShadow: isDark
            ? (elevation > 0
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(elevation * 0.1),
                      blurRadius: elevation * 4,
                      offset: Offset(0, elevation * 2),
                    ),
                  ]
                : null)
            : [
                BoxShadow(
                  color: const Color(0x0A0F172A),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );

    return Material(
      color: Colors.transparent,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius ?? 12),
              child: card,
            )
          : card,
    );
  }
}
