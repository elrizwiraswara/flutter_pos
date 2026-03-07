import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../../core/utilities/currency_formatter.dart';
import '../../../providers/home/home_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dialog.dart';
import '../../../widgets/app_drop_down.dart';
import '../../../widgets/app_text_field.dart';

class CartPanelFooter extends ConsumerWidget {
  const CartPanelFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPanelExpanded = ref.watch(homeControllerProvider.select((provider) => provider.isPanelExpanded));

    return Container(
      width: AppSizes.screenWidth(context),
      padding: const EdgeInsets.fromLTRB(AppSizes.padding, 0, AppSizes.padding, AppSizes.padding),
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Row(
        children: [
          AnimatedContainer(
            width: isPanelExpanded ? AppSizes.screenWidth(context) / 3 : 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: AppSizes.screenWidth(context) / 3 - AppSizes.padding / 2,
                child: const _BackButton(),
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: _PayButton(),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends ConsumerWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeProvider = ref.read(homeControllerProvider);

    return AppButton(
      text: 'Back',
      buttonColor: Theme.of(context).colorScheme.surface,
      borderColor: Theme.of(context).colorScheme.primary,
      textColor: Theme.of(context).colorScheme.primary,
      onTap: () {
        homeProvider.onChangedIsPanelExpanded(false);
        homeProvider.panelController.close();
      },
    );
  }
}

class _PayButton extends ConsumerWidget {
  const _PayButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(homeControllerProvider);

    return AppButton(
      text: !provider.isPanelExpanded
          ? provider.orderedProducts.isNotEmpty
                ? "${provider.orderedProducts.length} Products = ${CurrencyFormatter.format(provider.getTotalAmount())}"
                : 'Transaction'
          : 'Pay',
      enabled: provider.orderedProducts.isNotEmpty,
      onTap: () {
        if (provider.isPanelExpanded) {
          AppDialog.show(
            child: const _AdditionalInfoDialog(),
            showButtons: false,
          );
        } else {
          /// Expands cart panel
          provider.onChangedIsPanelExpanded(!provider.isPanelExpanded);

          if (!provider.isPanelExpanded) {
            provider.panelController.close();
          } else {
            provider.panelController.open();
          }
        }
      },
    );
  }
}

class _AdditionalInfoDialog extends ConsumerStatefulWidget {
  const _AdditionalInfoDialog();

  @override
  ConsumerState<_AdditionalInfoDialog> createState() => _AdditionalInfoDialogState();
}

class _AdditionalInfoDialogState extends ConsumerState<_AdditionalInfoDialog> {
  final _amountController = TextEditingController();
  final _customerController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _customerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> onPay({
    required GoRouter router,
    required HomeProvider homeProvider,
  }) async {
    var res = await AppDialog.showProgress(() {
      return homeProvider.createTransaction();
    });

    if (res.isSuccess) {
      router.go('/transactions/transaction-detail/${res.data}');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(homeControllerProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppTextField(
          autofocus: true,
          keyboardType: TextInputType.number,
          controller: _amountController,
          labelText: 'Received Amount',
          hintText: 'Received amount...',
          onChanged: (val) {
            provider.onChangedReceivedAmount(int.tryParse(val) ?? 0);
          },
        ),
        const SizedBox(height: AppSizes.padding),
        AppDropDown(
          labelText: 'Payment Method',
          selectedValue: provider.selectedPaymentMethod,
          dropdownItems: const [
            DropdownMenuItem(
              value: 'bank',
              child: Text('Bank'),
            ),
            DropdownMenuItem(
              value: 'cash',
              child: Text('Cash'),
            ),
          ],
          onChanged: (v) => provider.onChangedPaymentMethod(v),
        ),
        const SizedBox(height: AppSizes.padding),
        AppTextField(
          controller: _customerController,
          labelText: 'Customer Name (Optional)',
          hintText: 'e.g. Jhone Doe',
          onChanged: (v) => provider.onChangedCustomerName(v),
        ),
        const SizedBox(height: AppSizes.padding),
        AppTextField(
          controller: _descriptionController,
          labelText: 'Description (Optional)',
          hintText: 'Description...',
          onChanged: (v) => provider.onChangedDescription(v),
        ),
        const SizedBox(height: AppSizes.padding * 1.5),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'Cancel',
                buttonColor: Theme.of(context).colorScheme.surface,
                borderColor: Theme.of(context).colorScheme.primary,
                textColor: Theme.of(context).colorScheme.primary,
                onTap: () {
                  context.pop();
                },
              ),
            ),
            const SizedBox(width: AppSizes.padding / 2),
            Expanded(
              flex: 2,
              child: AppButton(
                text: 'Pay',
                enabled: (int.tryParse(_amountController.text) ?? 0) >= provider.getTotalAmount(),
                onTap: () {
                  final homeProvider = ref.read(homeControllerProvider);
                  final router = ref.read(appRoutesProvider).router;

                  context.pop();
                  onPay(
                    homeProvider: homeProvider,
                    router: router,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
