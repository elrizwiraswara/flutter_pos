import 'package:flutter/material.dart';
import 'package:flutter_pos/app/themes/app_sizes.dart';
import 'package:flutter_pos/app/themes/app_theme.dart';

class AppButton extends StatelessWidget {
  final double? width;
  final double? height;
  final double? fontSize;
  final BorderRadius? borderRadius;
  final EdgeInsets padding;
  final bool enabled;
  final String text;
  final Function() onTap;

  const AppButton({
    super.key,
    this.width,
    this.height,
    this.fontSize,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    this.enabled = true,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(AppSizes.radius),
      child: InkWell(
        onTap: enabled ? onTap : null,
        splashFactory: InkRipple.splashFactory,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
        child: Ink(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: enabled ? AppTheme().colorScheme.primary : AppTheme().colorScheme.surfaceDim,
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: Center(
            child: Text(
              text,
              style: AppTheme().textTheme.bodyMedium?.copyWith(
                    fontSize: fontSize,
                    color: enabled ? AppTheme().colorScheme.onPrimary : AppTheme().colorScheme.outline,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
