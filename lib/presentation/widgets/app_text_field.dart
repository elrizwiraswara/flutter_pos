import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pos/app/themes/app_sizes.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final bool enabled;
  final bool autofocus;
  final bool obscureText;
  final double? fontSize;
  final int? minLines;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsets contentPadding;
  final Function(String text)? onChanged;
  final Function()? onEditingComplete;
  final List<TextInputFormatter>? inputFormatters;
  final bool showCounter;
  final bool showBorder;

  const AppTextField({
    super.key,
    this.controller,
    this.enabled = true,
    this.autofocus = false,
    this.obscureText = false,
    this.fontSize,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    this.onChanged,
    this.onEditingComplete,
    this.inputFormatters,
    this.showCounter = false,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (labelText != null && labelText != '')
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                labelText!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          TextField(
            controller: controller,
            onChanged: onChanged,
            onEditingComplete: onEditingComplete,
            enabled: enabled,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            cursorColor: Theme.of(context).colorScheme.primary,
            cursorWidth: 1.5,
            autofocus: autofocus,
            obscureText: obscureText,
            minLines: minLines,
            maxLines: maxLines,
            maxLength: maxLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              counterText: showCounter ? null : '',
              isDense: true,
              filled: true,
              fillColor: enabled ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surface,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: fontSize,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
              contentPadding: contentPadding,
              focusedBorder: showBorder
                  ? OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppSizes.radius),
                      ),
                      borderSide: BorderSide(
                        width: 1,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : InputBorder.none,
              enabledBorder: showBorder
                  ? OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppSizes.radius),
                      ),
                      borderSide: BorderSide(
                        width: 1,
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    )
                  : InputBorder.none,
              disabledBorder: showBorder
                  ? OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppSizes.radius),
                      ),
                      borderSide: BorderSide(
                        width: 1,
                        color: Theme.of(context).colorScheme.surfaceDim,
                      ),
                    )
                  : InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}
