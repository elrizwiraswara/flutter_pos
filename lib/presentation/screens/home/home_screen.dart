import 'package:flutter/material.dart';
import 'package:flutter_pos/app/themes/app_sizes.dart';
import 'package:flutter_pos/app/utilities/console_log.dart';
import 'package:flutter_pos/domain/entities/product_entity.dart';
import 'package:flutter_pos/presentation/providers/home/home_provider.dart';
import 'package:flutter_pos/presentation/screens/home/components/cart_panel_body.dart';
import 'package:flutter_pos/presentation/screens/home/components/cart_panel_footer.dart';
import 'package:flutter_pos/presentation/screens/home/components/cart_panel_header.dart';
import 'package:flutter_pos/presentation/screens/home/components/order_card.dart';
import 'package:flutter_pos/presentation/widgets/app_button.dart';
import 'package:flutter_pos/presentation/widgets/app_dialog.dart';
import 'package:flutter_pos/presentation/widgets/app_empty_state.dart';
import 'package:flutter_pos/presentation/widgets/app_image.dart';
import 'package:flutter_pos/presentation/widgets/app_progress_indicator.dart';
import 'package:flutter_pos/presentation/widgets/products_card.dart';
import 'package:flutter_pos/service_locator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _homeProvider = sl<HomeProvider>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeProvider.getAllProducts();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title(),
        actions: [
          syncButton(),
          networkInfo(),
        ],
      ),
      body: SlidingUpPanel(
        controller: _homeProvider.panelController,
        minHeight: 86,
        maxHeight: AppSizes.screenHeight(context),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.06),
            offset: const Offset(0, -2),
            blurRadius: 6,
          ),
        ],
        body: body(),
        header: const CartPanelHeader(),
        panel: const CartPanelBody(),
        footer: const CartPanelFooter(),
        onPanelOpened: () => _homeProvider.onChangedIsPanelExpanded(true),
        onPanelClosed: () => _homeProvider.onChangedIsPanelExpanded(false),
      ),
    );
  }

  Widget title() {
    return Row(
      children: [
        AppImage(
          image: randomImage,
          borderRadius: 100,
          width: 34,
          height: 34,
          backgroundColor: Theme.of(context).colorScheme.surfaceDim,
        ),
        const SizedBox(width: AppSizes.padding / 2),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Elriz Wiraswara',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 0,
                  ),
            ),
            Text(
              'elrizwiraswara@gmail.com',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        )
      ],
    );
  }

  Widget syncButton() {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.padding / 4),
      child: AppButton(
        height: 26,
        borderRadius: BorderRadius.circular(4),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding / 2),
        buttonColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          children: [
            Icon(
              Icons.sync,
              size: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppSizes.padding / 4),
            Text(
              'Synced',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        onTap: () {
          throw 'asdasdas';
        },
      ),
    );
  }

  Widget networkInfo() {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.padding),
      child: AppButton(
        height: 26,
        borderRadius: BorderRadius.circular(4),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding / 2),
        buttonColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Icon(
          Icons.wifi,
          size: 12,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget body() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 232),
      child: Consumer<HomeProvider>(builder: (context, provider, _) {
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
          child: GridView.builder(
            padding: const EdgeInsets.all(AppSizes.padding),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 1 / 1.5,
              crossAxisSpacing: AppSizes.padding / 2,
              mainAxisSpacing: AppSizes.padding / 2,
            ),
            physics: const BouncingScrollPhysics(),
            itemCount: provider.allProducts!.length,
            itemBuilder: (context, i) {
              return productCard(provider.allProducts![i]);
            },
          ),
        );
      }),
    );
  }

  Widget productCard(ProductEntity product) {
    return ProductsCard(
      product: product,
      onTap: () {
        cl('========== ${product.id}');
        cl('========== ${product.name}');
        if (product.stock == 0) return;

        int qty = _homeProvider.orderedProducts.where((e) => e.productId == product.id).firstOrNull?.quantity ?? 0;

        AppDialog.show(
          title: 'Enter Amount',
          child: OrderCard(
            product: product,
            initialQuantity: qty,
            onChangedQuantity: (val) {
              qty = val;
            },
          ),
          rightButtonText: 'Add To Cart',
          leftButtonText: 'Cancel',
          onTapLeftButton: () {
            GoRouter.of(context).pop();
          },
          onTapRightButton: () {
            _homeProvider.onAddOrderedProduct(product, qty == 0 ? 1 : qty);
            GoRouter.of(context).pop();
          },
        );
      },
    );
  }
}
