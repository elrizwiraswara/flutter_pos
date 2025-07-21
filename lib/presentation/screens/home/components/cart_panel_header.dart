import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_sizes.dart';
import '../../../providers/home/home_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dialog.dart';

class CartPanelHeader extends StatefulWidget {
  const CartPanelHeader({super.key});

  @override
  State<CartPanelHeader> createState() => _CartPanelHeaderState();
}

class _CartPanelHeaderState extends State<CartPanelHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.screenWidth(context),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.padding,
        AppSizes.padding / 2,
        AppSizes.padding,
        AppSizes.padding / 1.5,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radius * 2),
          topRight: Radius.circular(AppSizes.radius * 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          slideIndicator(),
          const SizedBox(height: AppSizes.padding / 1.5),
          header(),
        ],
      ),
    );
  }

  Widget slideIndicator() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.54),
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }

  Widget header() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${provider.orderedProducts.length} Products',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AppButton(
              height: 26,
              borderRadius: BorderRadius.circular(4),
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding / 2),
              buttonColor: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.32),
              enabled: provider.orderedProducts.isNotEmpty,
              onTap: () {
                AppDialog.show(
                  title: 'Confirm',
                  text: 'Are you sure want to remove all product?',
                  rightButtonText: 'Remove',
                  leftButtonText: 'Cancel',
                  onTapRightButton: () {
                    provider.onRemoveAllOrderedProduct();
                    AppRoutes.router.pop();
                  },
                );
              },
              child: Row(
                children: [
                  Icon(
                    Icons.clear_rounded,
                    size: 12,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: AppSizes.padding / 4),
                  Text(
                    'Remove All',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
