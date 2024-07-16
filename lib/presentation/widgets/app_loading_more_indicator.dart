import 'package:flutter/material.dart';

import '../../app/themes/app_sizes.dart';
import 'app_progress_indicator.dart';

class AppLoadingMoreIndicator extends StatelessWidget {
  final bool isLoading;
  final EdgeInsets? padding;

  const AppLoadingMoreIndicator({super.key, required this.isLoading, this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: AppSizes.padding),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        height: isLoading ? 112 : 0,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: isLoading ? const AppProgressIndicator() : null,
          ),
        ),
      ),
    );
  }
}
