import 'package:flutter/material.dart';
import 'package:flutter_pos/app/themes/app_sizes.dart';
import 'package:flutter_pos/app/utilities/currency_formatter.dart';
import 'package:flutter_pos/presentation/providers/home/home_provider.dart';
import 'package:flutter_pos/presentation/screens/home/components/order_card.dart';
import 'package:flutter_pos/presentation/widgets/app_empty_state.dart';
import 'package:provider/provider.dart';

class CartPanelBody extends StatefulWidget {
  const CartPanelBody({super.key});

  @override
  State<CartPanelBody> createState() => _CartPanelBodyState();
}

class _CartPanelBodyState extends State<CartPanelBody> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 62),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          orderList(),
          orderTotal(),
        ],
      ),
    );
  }

  Widget orderList() {
    return Consumer<HomeProvider>(builder: (context, provider, _) {
      if (provider.orderedProducts.isEmpty) {
        return const Expanded(
          child: AppEmptyState(
            title: 'Empty',
            subtitle: 'No products added to cart',
          ),
        );
      }

      return ListView.builder(
        itemCount: provider.orderedProducts.length,
        shrinkWrap: true,
        padding: const EdgeInsets.all(AppSizes.padding),
        itemBuilder: (context, i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.padding),
            child: OrderCard(
              product: provider.orderedProducts[i].product!,
              initialQuantity: provider.orderedProducts[i].quantity,
              onChangedQuantity: (val) {
                provider.onChangedOrderedProductQuantity(i, val);
              },
              onTapRemove: () {
                provider.onRemoveOrderedProduct(provider.orderedProducts[i]);
              },
            ),
          );
        },
      );
    });
  }

  Widget orderTotal() {
    return Consumer<HomeProvider>(builder: (context, provider, _) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.padding),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              width: 1,
              color: Theme.of(context).colorScheme.surfaceContainer,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total (${provider.orderedProducts.length})',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              CurrencyFormatter.format(provider.getTotalAmount()),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    });
  }
}
