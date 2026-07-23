import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Accessible button with semantic labels and keyboard navigation
class AccessibleButton extends StatelessWidget {
  final String label;
  final String? semanticLabel;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isDangerous;
  final bool isSecondary;
  final bool isTonal;
  final bool isLoading;
  final bool isFullWidth;
  final Widget? child;

  const AccessibleButton({
    super.key,
    required this.label,
    this.semanticLabel,
    this.icon,
    required this.onPressed,
    this.isPrimary = true,
    this.isDangerous = false,
    this.isSecondary = false,
    this.isTonal = false,
    this.isLoading = false,
    this.isFullWidth = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Semantics(
      label: semanticLabel ?? label,
      button: true,
      enabled: onPressed != null && !isLoading,
      excludeSemantics: true,
      child: SizedBox(
        width: isFullWidth ? double.infinity : null,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: _getButtonStyle(theme),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : child ??
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18),
                        const SizedBox(width: 8),
                      ],
                      Text(label),
                    ],
                  ),
        ),
      ),
    );
  }

  ButtonStyle _getButtonStyle(ThemeData theme) {
    if (isDangerous) {
      return ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.error,
        foregroundColor: theme.colorScheme.onError,
      );
    }
    
    if (isSecondary) {
      return ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.primary,
        side: BorderSide(color: theme.colorScheme.primary),
      );
    }
    
    if (isTonal) {
      return ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.secondaryContainer,
        foregroundColor: theme.colorScheme.onSecondaryContainer,
      );
    }
    
    // Primary (default)
    return ElevatedButton.styleFrom(
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
    );
  }
}

/// Accessible text field with semantic labels and error handling
class AccessibleTextField extends StatelessWidget {
  final String label;
  final String? semanticLabel;
  final String? hintText;
  final String? errorText;
  final TextEditingController? controller;
  final bool obscureText;
  final bool isEnabled;
  final bool isRequired;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;

  const AccessibleTextField({
    super.key,
    required this.label,
    this.semanticLabel,
    this.hintText,
    this.errorText,
    this.controller,
    this.obscureText = false,
    this.isEnabled = true,
    this.isRequired = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? label,
      textField: true,
      enabled: isEnabled,
      value: controller?.text,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: obscureText,
            enabled: isEnabled,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            maxLines: maxLines,
            maxLength: maxLength,
            onChanged: onChanged,
            onSubmitted: onSubmitted != null ? (_) => onSubmitted!() : null,
            decoration: InputDecoration(
              hintText: hintText,
              errorText: errorText,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Accessible card with semantic label
class AccessibleCard extends StatelessWidget {
  final String? semanticLabel;
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final double? elevation;

  const AccessibleCard({
    super.key,
    this.semanticLabel,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.padding,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: backgroundColor,
      elevation: elevation ?? 4,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      return Semantics(
        label: semanticLabel,
        button: true,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          child: card,
        ),
      );
    }

    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: card,
    );
  }
}
