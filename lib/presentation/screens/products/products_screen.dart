import 'package:flutter/material.dart';
import 'package:flutter_pos/app/const/dummy.dart';
import 'package:flutter_pos/app/themes/app_sizes.dart';
import 'package:flutter_pos/presentation/widgets/app_button.dart';
import 'package:flutter_pos/presentation/widgets/app_text_field.dart';
import 'package:flutter_pos/presentation/widgets/products_card.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Product'),
        actions: [
          addButton(),
        ],
        bottom: PreferredSize(
          preferredSize: Size(AppSizes.screenWidth(context), 75),
          child: searchField(),
        ),
      ),
      body: Column(
        children: [
          // searchField(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(AppSizes.padding),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 1 / 1.5,
                crossAxisSpacing: AppSizes.padding / 2,
                mainAxisSpacing: AppSizes.padding / 2,
              ),
              physics: const BouncingScrollPhysics(),
              itemCount: 10,
              itemBuilder: (context, i) {
                return productCard();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget addButton() {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.padding),
      child: AppButton(
        height: 26,
        borderRadius: BorderRadius.circular(4),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding / 2),
        buttonColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          children: [
            Icon(
              Icons.add,
              size: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppSizes.padding / 4),
            Text(
              'Add Product',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget searchField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSizes.padding, 0, AppSizes.padding, AppSizes.padding),
      child: AppTextField(
        hintText: 'Search Products...',
        prefixIcon: Icon(
          Icons.search,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget productCard() {
    return ProductsCard(
      product: productDummy,
      onTap: () {
        //
      },
    );
  }
}
