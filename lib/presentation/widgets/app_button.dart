import 'package:flutter/material.dart';

import '../../app/themes/app_sizes.dart';

class AppButton extends StatelessWidget {
  final double? width;
  final double? height;
  final double? fontSize;
  final BorderRadius? borderRadius;
  final EdgeInsets padding;
  final bool enabled;
  final String? text;
  final Color? buttonColor;
  final Color? disabledButtonColor;
  final Color? borderColor;
  final Color? textColor;
  final Widget? child;
  final Alignment? alignment;
  final Function()? onTap;

  const AppButton({
    super.key,
    this.width,
    this.height,
    this.fontSize,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    this.enabled = true,
    this.buttonColor,
    this.disabledButtonColor,
    this.borderColor,
    this.textColor,
    this.child,
    this.alignment = Alignment.center,
    this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Material(
        borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.radius),
        child: InkWell(
          onTap: enabled ? onTap : null,
          splashFactory: InkRipple.splashFactory,
          borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.radius),
          child: Ink(
            width: width,
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              color: enabled
                  ? buttonColor ?? Theme.of(context).colorScheme.primary
                  : disabledButtonColor ?? Theme.of(context).colorScheme.surfaceDim,
              borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.radius),
              border: Border.all(
                width: 1,
                color: enabled
                    ? borderColor ?? buttonColor ?? Theme.of(context).colorScheme.primary
                    : disabledButtonColor ?? Theme.of(context).colorScheme.surfaceDim,
              ),
            ),
            child: alignment != null
                ? Align(
                    alignment: alignment!,
                    child: buttonChild(context),
                  )
                : buttonChild(context),
          ),
        ),
      ),
    );
  }

  Widget buttonChild(BuildContext context) {
    return child ??
        Text(
          text ?? '',
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            color: enabled
                ? textColor ?? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.outline,
          ),
        );
  }
}
