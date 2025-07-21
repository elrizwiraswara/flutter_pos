import 'package:flutter/material.dart';

import '../../app/themes/app_sizes.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? buttonText;
  final Function()? onTapButton;

  const AppEmptyState({
    super.key,
    this.title,
    this.subtitle,
    this.buttonText,
    this.onTapButton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.padding * 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.dashboard_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: AppSizes.padding / 2),
            Text(
              title ?? 'Nothing to show',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: AppSizes.padding / 2),
            Text(
              subtitle ?? '',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: AppSizes.padding),
            if (buttonText != null && onTapButton != null)
              AppButton(
                text: buttonText,
                onTap: onTapButton,
                buttonColor: Theme.of(context).colorScheme.surface,
                borderColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                textColor: Theme.of(context).colorScheme.primary,
                alignment: null,
              ),
          ],
        ),
      ),
    );
  }
}
