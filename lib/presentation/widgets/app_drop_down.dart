import 'package:flutter/material.dart';
import 'package:flutter_pos/app/themes/app_sizes.dart';

class AppDropDown<T> extends StatelessWidget {
  final T? selectedValue;
  final List<DropdownMenuItem<T>> dropdownItems;
  final Function(T?) onChanged;
  final bool enabled;
  final String? labelText;
  final String? hintText;
  final double fontSize;

  const AppDropDown({
    super.key,
    this.selectedValue,
    required this.dropdownItems,
    required this.onChanged,
    this.enabled = true,
    this.labelText,
    this.hintText,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null && labelText != '')
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              labelText!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: fontSize),
            ),
          ),
        DropdownButtonFormField<T>(
          value: selectedValue,
          onChanged: onChanged,
          items: dropdownItems,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: fontSize),
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
            fillColor:
                enabled ? Theme.of(context).colorScheme.secondaryContainer : Theme.of(context).colorScheme.surfaceDim,
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: fontSize,
                  color: Theme.of(context).colorScheme.outline,
                ),
            contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(AppSizes.radius),
              ),
              borderSide: BorderSide(
                width: 0.5,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(AppSizes.radius),
              ),
              borderSide: BorderSide(
                width: 0.5,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(AppSizes.radius),
              ),
              borderSide: BorderSide(
                width: 0.5,
                color: Theme.of(context).colorScheme.outlineVariant,
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
    );
  }
}
