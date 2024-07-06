import 'package:flutter/material.dart';
import 'package:flutter_pos/app/const/dummy.dart';
import 'package:flutter_pos/app/themes/app_sizes.dart';
import 'package:flutter_pos/app/utilities/currency_formatter.dart';
import 'package:flutter_pos/presentation/providers/home/home_provider.dart';
import 'package:flutter_pos/presentation/screens/home/components/order_card.dart';
import 'package:flutter_pos/presentation/widgets/app_button.dart';
import 'package:provider/provider.dart';

class HomeBottomsheet extends StatefulWidget {
  const HomeBottomsheet({super.key});

  @override
  State<HomeBottomsheet> createState() => _HomeBottomsheetState();
}

class _HomeBottomsheetState extends State<HomeBottomsheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border(
          top: BorderSide(
            width: 1,
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          divider(),
          const SizedBox(height: AppSizes.padding / 2),
          cart(),
          const SizedBox(height: AppSizes.padding / 2),
          receipt()
        ],
      ),
    );
  }

  Widget divider() {
    return Container(
      height: 4,
      width: 52,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }

  Widget cart() {
    return Consumer<HomeProvider>(builder: (context, provider, _) {
      return AnimatedContainer(
        height: provider.isBottomExpanded ? AppSizes.screenHeight(context) - 250 : 0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(vertical: provider.isBottomExpanded ? AppSizes.padding / 2 : 0),
        decoration: BoxDecoration(
          border: provider.isBottomExpanded
              ? Border(
                  top: BorderSide(
                    width: 0.5,
                    color: Theme.of(context).colorScheme.surfaceDim,
                  ),
                  bottom: BorderSide(
                    width: 0.5,
                    color: Theme.of(context).colorScheme.surfaceDim,
                  ),
                )
              : null,
        ),
        child: ListView.builder(
          itemCount: 10,
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: AppSizes.padding),
          itemBuilder: (context, i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.padding / 2),
              child: OrderCard(
                product: productDummy,
              ),
            );
          },
        ),
      );
    });
  }

  Widget receipt() {
    return Consumer<HomeProvider>(builder: (context, provider, _) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dipilih 2 Produk',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                CurrencyFormatter.format(1000),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.padding),
          Row(
            children: [
              AnimatedContainer(
                width: provider.isBottomExpanded ? AppSizes.screenWidth(context) / 3 : 0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: AppSizes.screenWidth(context) / 3 - AppSizes.padding / 2,
                    child: backButton(provider),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: receiptButton(provider),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget backButton(HomeProvider provider) {
    return AppButton(
      text: 'Kembali',
      buttonColor: Theme.of(context).colorScheme.surface,
      borderColor: Theme.of(context).colorScheme.primary,
      textColor: Theme.of(context).colorScheme.primary,
      onTap: () {
        provider.onChangedIsBottomExpanded(!provider.isBottomExpanded);
      },
    );
  }

  Widget receiptButton(HomeProvider provider) {
    return AppButton(
      text: 'Tagih',
      onTap: () {
        provider.onChangedIsBottomExpanded(!provider.isBottomExpanded);
      },
    );
  }
}
