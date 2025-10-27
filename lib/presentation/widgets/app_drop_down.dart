import 'package:flutter/material.dart';

import '../../app/themes/app_sizes.dart';

class AppDropDown<T> extends StatelessWidget {
  final T? selectedValue;
  final List<DropdownMenuItem<T>> dropdownItems;
  final Function(T?) onChanged;
  final bool enabled;
  final String? labelText;
  final String? hintText;
  final double fontSize;
  final EdgeInsets contentPadding;

  const AppDropDown({
    super.key,
    this.selectedValue,
    required this.dropdownItems,
    required this.onChanged,
    this.enabled = true,
    this.labelText,
    this.hintText,
    this.fontSize = 14,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
          DropdownButtonFormField<T>(
            initialValue: selectedValue,
            onChanged: onChanged,
            items: dropdownItems,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Theme.of(context).colorScheme.outline,
              size: 22,
            ),
            dropdownColor: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radius)),
            decoration: InputDecoration(
              enabled: enabled,
              isDense: true,
              filled: true,
              fillColor: enabled ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surfaceDim,
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: fontSize,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              contentPadding: contentPadding,
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppSizes.radius),
                ),
                borderSide: BorderSide(
                  width: 0.5,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppSizes.radius),
                ),
                borderSide: BorderSide(
                  width: 0.5,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppSizes.radius),
                ),
                borderSide: BorderSide(
                  width: 0.5,
                  color: Theme.of(context).colorScheme.surfaceDim,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
