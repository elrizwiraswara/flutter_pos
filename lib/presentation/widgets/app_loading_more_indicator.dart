import 'package:flutter/material.dart';
import 'package:flutter_pos/app/themes/app_sizes.dart';
import 'package:flutter_pos/presentation/widgets/app_progress_indicator.dart';

class AppLoadingMoreIndicator extends StatelessWidget {
  final bool isLoading;
  final EdgeInsets? padding;

  const AppLoadingMoreIndicator({super.key, required this.isLoading, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: AppSizes.padding),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: isLoading ? const AppProgressIndicator() : null,
      ),
    );
  }
}
