import 'package:flutter/material.dart';
import 'package:flutter_pos/app/themes/app_theme.dart';

class AppIconButton extends StatelessWidget {
  final double? width;
  final double? height;
  final double? iconSize;
  final EdgeInsets padding;
  final bool enabled;
  final double borderRadius;
  final IconData icon;
  final Function() onTap;

  const AppIconButton({
    super.key,
    this.width,
    this.height,
    this.iconSize,
    this.padding = const EdgeInsets.all(12),
    this.enabled = true,
    this.borderRadius = 100,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(4),
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        splashFactory: InkRipple.splashFactory,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: enabled ? AppTheme().colorScheme.primaryContainer : AppTheme().colorScheme.surfaceDim,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: enabled ? AppTheme().colorScheme.primary : AppTheme().colorScheme.outline,
          ),
        ),
      ),
    );
  }
}
