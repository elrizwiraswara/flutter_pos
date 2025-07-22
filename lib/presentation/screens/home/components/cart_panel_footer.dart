import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/themes/app_sizes.dart';
import '../../../../app/utilities/console_log.dart';
import '../../../../app/utilities/currency_formatter.dart';
import '../../../../service_locator.dart';
import '../../../providers/home/home_provider.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dialog.dart';
import '../../../widgets/app_drop_down.dart';
import '../../../widgets/app_text_field.dart';

class CartPanelFooter extends StatefulWidget {
  const CartPanelFooter({super.key});

  @override
  State<CartPanelFooter> createState() => _CartPanelFooterState();
}

class _CartPanelFooterState extends State<CartPanelFooter> {
  final _homeProvider = sl<HomeProvider>();

  final _amountControlller = TextEditingController();
  final _customerControlller = TextEditingController();
  final _descriptionControlller = TextEditingController();

  @override
  void dispose() {
    _amountControlller.dispose();
    _customerControlller.dispose();
    _descriptionControlller.dispose();
    super.dispose();
  }

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
                    child: backButton(),
                  ),
                ),
              );
            },
          ),
          Expanded(
            flex: 2,
            child: receiptButton(),
          ),
        ],
      ),
    );
  }

  Widget backButton() {
    return AppButton(
      text: 'Back',
      buttonColor: Theme.of(context).colorScheme.surface,
      borderColor: Theme.of(context).colorScheme.primary,
      textColor: Theme.of(context).colorScheme.primary,
      onTap: () {
        _homeProvider.onChangedIsPanelExpanded(false);
        _homeProvider.panelController.close();
      },
    );
  }

  Widget receiptButton() {
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
            if (_homeProvider.isPanelExpanded) {
              AppDialog.show(child: additionalInfoDialog(), showButtons: false);
            } else {
              /// Expands cart panel
              _homeProvider.onChangedIsPanelExpanded(!_homeProvider.isPanelExpanded);

              if (!_homeProvider.isPanelExpanded) {
                _homeProvider.panelController.close();
              } else {
                _homeProvider.panelController.open();
              }
            }
          },
        );
      },
    );
  }

  Widget additionalInfoDialog() {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              autofocus: true,
              keyboardType: TextInputType.number,
              controller: _amountControlller,
              labelText: 'Received Amount',
              hintText: 'Received amount...',
              onChanged: (val) {
                provider.onChangedReceivedAmount(int.tryParse(val) ?? 0);
              },
            ),
            const SizedBox(height: AppSizes.padding),
            AppDropDown(
              labelText: 'Payment Method',
              selectedValue: _homeProvider.selectedPaymentMethod,
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
              controller: _customerControlller,
              labelText: 'Customer Name (Optional)',
              hintText: 'e.g. Jhone Doe',
              onChanged: provider.onChangedCustomerName,
            ),
            const SizedBox(height: AppSizes.padding),
            AppTextField(
              controller: _descriptionControlller,
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
                    enabled: (int.tryParse(_amountControlller.text) ?? 0) >= provider.getTotalAmount(),
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

  void onPay() async {
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);

    AppDialog.showDialogProgress();

    var res = await _homeProvider.createTransaction();

    AppDialog.closeDialog();

    if (res.isSuccess) {
      router.go('/transactions/transaction-detail/${res.data}');
      messenger.showSnackBar(const SnackBar(content: Text('Transaction created')));
    } else {
      cl('[createTransaction].error ${res.error}');
      AppDialog.showErrorDialog(error: res.error?.message);
    }
  }
}
