import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/di/dependency_injection.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/themes/app_sizes.dart';
import '../../../../core/utilities/currency_formatter.dart';
import '../../../providers/home/home_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dialog.dart';
import '../../../widgets/app_drop_down.dart';
import '../../../widgets/app_text_field.dart';

class CartPanelFooter extends StatelessWidget {
  const CartPanelFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.screenWidth(context),
      padding: const EdgeInsets.fromLTRB(AppSizes.padding, 0, AppSizes.padding, AppSizes.padding),
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Row(
        children: [
          Consumer<HomeProvider>(
            builder: (context, provider, _) {
              return AnimatedContainer(
                width: provider.isPanelExpanded ? AppSizes.screenWidth(context) / 3 : 0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: AppSizes.screenWidth(context) / 3 - AppSizes.padding / 2,
                    child: _BackButton(),
                  ),
                ),
              );
            },
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

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    final homeProvider = di<HomeProvider>();

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

class _PayButton extends StatelessWidget {
  const _PayButton();

  @override
  Widget build(BuildContext context) {
    final homeProvider = di<HomeProvider>();

    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        return AppButton(
          text: !provider.isPanelExpanded
              ? provider.orderedProducts.isNotEmpty
                    ? "${provider.orderedProducts.length} Products = ${CurrencyFormatter.format(provider.getTotalAmount())}"
                    : 'Transaction'
              : 'Pay',
          enabled: provider.orderedProducts.isNotEmpty,
          onTap: () {
            if (homeProvider.isPanelExpanded) {
              AppDialog.show(
                child: const _AdditionalInfoDialog(),
                showButtons: false,
              );
            } else {
              /// Expands cart panel
              homeProvider.onChangedIsPanelExpanded(!homeProvider.isPanelExpanded);

              if (!homeProvider.isPanelExpanded) {
                homeProvider.panelController.close();
              } else {
                homeProvider.panelController.open();
              }
            }
          },
        );
      },
    );
  }
}

class _AdditionalInfoDialog extends StatefulWidget {
  const _AdditionalInfoDialog();

  @override
  State<_AdditionalInfoDialog> createState() => _AdditionalInfoDialogState();
}

class _AdditionalInfoDialogState extends State<_AdditionalInfoDialog> {
  final homeProvider = di<HomeProvider>();

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

  void onPay() async {
    var res = await AppDialog.showProgress(() {
      return homeProvider.createTransaction();
    });

    if (res.isSuccess) {
      AppRoutes.instance.router.go('/transactions/transaction-detail/${res.data}');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
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
              selectedValue: homeProvider.selectedPaymentMethod,
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
              onChanged: provider.onChangedPaymentMethod,
            ),
            const SizedBox(height: AppSizes.padding),
            AppTextField(
              controller: _customerController,
              labelText: 'Customer Name (Optional)',
              hintText: 'e.g. Jhone Doe',
              onChanged: provider.onChangedCustomerName,
            ),
            const SizedBox(height: AppSizes.padding),
            AppTextField(
              controller: _descriptionController,
              labelText: 'Description (Optional)',
              hintText: 'Description...',
              onChanged: provider.onChangedDescription,
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
                      context.pop();
                      onPay();
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
