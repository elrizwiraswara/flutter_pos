import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/themes/app_sizes.dart';
import '../../../../core/utilities/currency_formatter.dart';
import '../../../providers/home/home_provider.dart';
import '../../../widgets/app_empty_state.dart';
import 'order_card.dart';

class CartPanelBody extends StatelessWidget {
  const CartPanelBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 62),
      physics: NeverScrollableScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _OrderList(),
          _OrderTotal(),
        ],
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        if (provider.orderedProducts.isEmpty) {
          return SizedBox(
            height: AppSizes.screenHeight(context) - 272,
            child: const AppEmptyState(
              title: 'Empty',
              subtitle: 'No products added to cart',
            ),
          );
        }

        return SizedBox(
          height: AppSizes.screenHeight(context) - 272,
          child: Scrollbar(
            child: ListView.builder(
              itemCount: provider.orderedProducts.length,
              padding: const EdgeInsets.all(AppSizes.padding),
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.padding),
                  child: OrderCard(
                    name: provider.orderedProducts[i].name,
                    imageUrl: provider.orderedProducts[i].imageUrl,
                    stock: provider.orderedProducts[i].stock,
                    price: provider.orderedProducts[i].price,
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
            ),
          ),
        );
      },
    );
  }
}

class _OrderTotal extends StatelessWidget {
  const _OrderTotal();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                CurrencyFormatter.format(provider.getTotalAmount()),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
