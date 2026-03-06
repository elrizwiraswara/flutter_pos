import 'package:flutter/material.dart';

import '../../core/themes/app_sizes.dart';

class AppDropDown<T> extends StatelessWidget {
  final T? selectedValue;
  final Set<T>? selectedValues;
  final List<DropdownMenuItem<T>> dropdownItems;
  final ValueChanged<T?> onChanged;
  final bool enabled;
  final String? labelText;
  final String? hintText;
  final double fontSize;
  final EdgeInsets contentPadding;
  final bool isMultiSelect;
  final String Function(Set<T> values)? selectedValuesTextBuilder;
  final String Function(T value)? itemLabelBuilder;

  const AppDropDown({
    super.key,
    this.selectedValue,
    this.selectedValues,
    required this.dropdownItems,
    required this.onChanged,
    this.enabled = true,
    this.labelText,
    this.hintText,
    this.fontSize = 14,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    this.selectedValuesTextBuilder,
    this.itemLabelBuilder,
  }) : isMultiSelect = false;

  const AppDropDown.multi({
    super.key,
    this.selectedValues,
    required this.dropdownItems,
    required this.onChanged,
    this.enabled = true,
    this.labelText,
    this.hintText,
    this.fontSize = 14,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    this.selectedValuesTextBuilder,
    this.itemLabelBuilder,
  }) : selectedValue = null,
       isMultiSelect = true;

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
          if (isMultiSelect) _MultiSelectDropDown<T>(dropdown: this) else _SingleSelectDropDown<T>(dropdown: this),
        ],
      ),
    );
  }

  InputDecoration decoration(BuildContext context) {
    return InputDecoration(
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
          color: Theme.of(context).colorScheme.primaryContainer,
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
    );
  }

  TextStyle? textStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  String multiSelectLabel(Set<T> values) {
    if (selectedValuesTextBuilder != null) {
      return selectedValuesTextBuilder!(values);
    }

    return values.map(_itemLabel).join(', ');
  }

  String _itemLabel(T value) {
    if (itemLabelBuilder != null) {
      return itemLabelBuilder!(value);
    }

    return value.toString();
  }
}

class _SingleSelectDropDown<T> extends StatelessWidget {
  final AppDropDown<T> dropdown;

  const _SingleSelectDropDown({
    required this.dropdown,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: dropdown.selectedValue,
      onChanged: dropdown.onChanged,
      items: dropdown.dropdownItems,
      style: dropdown.textStyle(context),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Theme.of(context).colorScheme.outline,
        size: 22,
      ),

      dropdownColor: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: const BorderRadius.all(Radius.circular(AppSizes.radius)),
      decoration: dropdown.decoration(context),
    );
  }
}

class _MultiSelectDropDown<T> extends StatelessWidget {
  final AppDropDown<T> dropdown;

  const _MultiSelectDropDown({
    required this.dropdown,
  });

  @override
  Widget build(BuildContext context) {
    final selectedValues = dropdown.selectedValues ?? <T>{};
    final isEmpty = selectedValues.isEmpty;
    final label = isEmpty ? dropdown.hintText ?? 'Select options' : dropdown.multiSelectLabel(selectedValues);

    return PopupMenuButton<T>(
      enabled: dropdown.enabled,
      padding: EdgeInsets.zero,
      onSelected: dropdown.onChanged,
      color: Theme.of(context).colorScheme.secondaryContainer,
      surfaceTintColor: Theme.of(context).colorScheme.secondaryContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.radius)),
      ),
      position: PopupMenuPosition.under,
      itemBuilder: (context) {
        return dropdown.dropdownItems.where((item) => item.value != null).map((item) {
          final value = item.value as T;

          return CheckedPopupMenuItem<T>(
            value: value,
            checked: selectedValues.contains(value),
            child: item.child,
          );
        }).toList();
      },
      child: InputDecorator(
        isEmpty: isEmpty,
        decoration: dropdown.decoration(context),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isEmpty
                    ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: dropdown.fontSize,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      )
                    : dropdown.textStyle(context),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Theme.of(context).colorScheme.outline,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
