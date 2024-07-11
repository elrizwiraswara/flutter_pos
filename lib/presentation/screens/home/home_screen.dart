import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../app/const/const.dart';
import '../../../app/themes/app_sizes.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../service_locator.dart';
import '../../providers/home/home_provider.dart';
import '../../providers/main/main_provider.dart';
import '../../providers/products/products_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_image.dart';
import '../../widgets/app_progress_indicator.dart';
import '../products/components/products_card.dart';
import 'components/cart_panel_body.dart';
import 'components/cart_panel_footer.dart';
import 'components/cart_panel_header.dart';
import 'components/order_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final mainProvider = sl<MainProvider>();
  final homeProvider = sl<HomeProvider>();
  final productProvider = sl<ProductsProvider>();

  final scrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => onRefresh());
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  void scrollListener() {
    // Automatically load more data on end of scroll position
    if (scrollController.offset == scrollController.position.maxScrollExtent) {
      productProvider.getAllProducts(offset: productProvider.allProducts?.length);
    }
  }

  Future<void> onRefresh() async {
    await productProvider.getAllProducts();
    await mainProvider.checkIsHasQueuedActions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        controller: homeProvider.panelController,
        minHeight: 88,
        maxHeight: AppSizes.screenHeight(context) - AppSizes.appBarHeight() - AppSizes.viewPadding(context).top,
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.04),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radius * 2),
          topRight: Radius.circular(AppSizes.radius * 2),
        ),
        body: body(),
        header: const CartPanelHeader(),
        panel: const CartPanelBody(),
        footer: const CartPanelFooter(),
        onPanelOpened: () => homeProvider.onChangedIsPanelExpanded(true),
        onPanelClosed: () => homeProvider.onChangedIsPanelExpanded(false),
      ),
    );
  }

  Widget title() {
    return Consumer<MainProvider>(
      builder: (context, provider, _) {
        return Row(
          children: [
            AppImage(
              image: provider.user?.imageUrl ?? '',
              borderRadius: 100,
              width: 34,
              height: 34,
              backgroundColor: Theme.of(context).colorScheme.surface,
              errorWidget: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(width: AppSizes.padding / 2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.user?.name ?? '',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 0,
                      ),
                ),
                Text(
                  provider.user?.email ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  Widget syncButton() {
    return Consumer<MainProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.only(right: AppSizes.padding / 4),
          child: AppButton(
            height: 26,
            borderRadius: BorderRadius.circular(4),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding / 2),
            buttonColor: provider.isHasQueuedActions && !provider.isSyncronizing
                ? Theme.of(context).colorScheme.surfaceContainer
                : Theme.of(context).colorScheme.shadow.withOpacity(0.06),
            child: Row(
              children: [
                Icon(
                  provider.isSyncronizing
                      ? Icons.sync
                      : provider.isHasQueuedActions
                          ? Icons.cloud_done_sharp
                          : Icons.sync_problem_sharp,
                  size: 12,
                  color: provider.isHasQueuedActions && !provider.isSyncronizing
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: AppSizes.padding / 4),
                Text(
                  provider.isSyncronizing
                      ? 'Syncronizing'
                      : provider.isHasQueuedActions
                          ? 'Synced'
                          : 'Pending',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: provider.isHasQueuedActions && !provider.isSyncronizing
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
            onTap: () {
              provider.checkAndSyncAllData(context);
            },
          ),
        );
      },
    );
  }

  Widget networkInfo() {
    return Selector<MainProvider, bool>(
      selector: (a, b) => b.isHasInternet,
      builder: (context, isHasInternet, _) {
        return Padding(
          padding: const EdgeInsets.only(right: AppSizes.padding),
          child: AppButton(
            height: 26,
            borderRadius: BorderRadius.circular(4),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding / 2),
            buttonColor: isHasInternet
                ? Theme.of(context).colorScheme.surfaceContainer
                : Theme.of(context).colorScheme.shadow.withOpacity(0.06),
            child: Icon(
              isHasInternet ? Icons.wifi_rounded : Icons.wifi_off_rounded,
              size: 12,
              color: isHasInternet ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isHasInternet ? ONLINE_MESSAGE : OFFLINE_MESSAGE)),
              );
            },
          ),
        );
      },
    );
  }

  Widget body() {
    return Scaffold(
      appBar: AppBar(
        title: title(),
        actions: [
          syncButton(),
          networkInfo(),
        ],
      ),
      body: Consumer<ProductsProvider>(builder: (context, provider, _) {
        if (provider.allProducts == null) {
          return const AppProgressIndicator();
        }

        if (provider.allProducts!.isEmpty) {
          return AppEmptyState(
            subtitle: 'No products available, add product to continue',
            buttonText: 'Add Product',
            onTapButton: () => context.push('/products/product-create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => onRefresh(),
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(AppSizes.padding, AppSizes.padding, AppSizes.padding, 200),
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
        if (product.stock == 0) return;

        int currentQty = homeProvider.orderedProducts.where((e) => e.id == product.id).firstOrNull?.quantity ?? 0;

        AppDialog.show(
          title: 'Enter Amount',
          child: OrderCard(
            name: product.name,
            imageUrl: product.imageUrl,
            stock: product.stock,
            price: product.price,
            initialQuantity: currentQty,
            onChangedQuantity: (val) {
              currentQty = val;
            },
          ),
          rightButtonText: 'Add To Cart',
          leftButtonText: 'Cancel',
          onTapLeftButton: () {
            GoRouter.of(context).pop();
          },
          onTapRightButton: () {
            homeProvider.onAddOrderedProduct(product, currentQty == 0 ? 1 : currentQty);
            GoRouter.of(context).pop();
          },
        );
      },
    );
  }
}
