import 'package:flutter/material.dart';
import 'package:flutter_pos/presentation/widgets/app_loading_more_indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/themes/app_sizes.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../service_locator.dart';
import '../../providers/products/products_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_text_field.dart';
import 'components/products_card.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final productProvider = sl<ProductsProvider>();

  final scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productProvider.getAllProducts();
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  void scrollListener() async {
    // Automatically load more data on end of scroll position
    if (scrollController.offset == scrollController.position.maxScrollExtent) {
      await productProvider.getAllProducts(offset: productProvider.allProducts?.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          addButton(),
        ],
        // bottom: PreferredSize(
        //   preferredSize: Size(AppSizes.screenWidth(context), 75),
        //   child: searchField(),
        // ),
      ),
      body: Consumer<ProductsProvider>(
        builder: (context, provider, _) {
          if (provider.allProducts == null) {
            return const AppProgressIndicator();
          }

          if (provider.allProducts!.isEmpty) {
            return AppEmptyState(
              subtitle: 'No products available, add product to continue',
              buttonText: 'Add Product',
              onTapButton: () => context.go('/products/product-create'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.getAllProducts(),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  GridView.builder(
                    padding: const EdgeInsets.all(AppSizes.padding),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 1 / 1.5,
                      crossAxisSpacing: AppSizes.padding / 2,
                      mainAxisSpacing: AppSizes.padding / 2,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.allProducts!.length,
                    itemBuilder: (context, i) {
                      return productCard(provider.allProducts![i]);
                    },
                  ),
                  AppLoadingMoreIndicator(isLoading: provider.isLoadingMore),
                ],
              ),
            ),
          );
        },
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
        onTap: () {
          context.go('/products/product-create');
        },
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

  Widget productCard(ProductEntity product) {
    return ProductsCard(
      product: product,
      onTap: () {
        context.go('/products/product-detail/${product.id}');
      },
    );
  }
}
