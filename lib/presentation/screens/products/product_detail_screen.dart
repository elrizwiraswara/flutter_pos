import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/dependency_injection.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/currency_formatter.dart';
import '../../../core/utilities/date_time_formatter.dart';
import '../../providers/products/product_detail_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_progress_indicator.dart';

class ProductDetailScreen extends StatelessWidget {
  final int id;

  const ProductDetailScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        titleSpacing: 0,
        actions: [_EditButton(id: id)],
      ),
      body: FutureBuilder(
        future: di<ProductDetailProvider>().getProductDetail(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppProgressIndicator();
          }

          if (snapshot.hasError) {
            throw snapshot.error.toString();
          }

          if (snapshot.data == null) {
            return const AppEmptyState(title: 'Not Found');
          }

          final product = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductImage(imageUrl: product.imageUrl),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProductName(
                        productName: product.name,
                        createdAt: product.createdAt,
                        updatedAt: product.updatedAt,
                      ),
                      _ProductPrice(price: product.price),
                      _ProductStock(stock: product.stock),
                      _ProductSold(sold: product.sold),
                      _ProductDescription(description: product.description),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  final int id;

  const _EditButton({required this.id});

  @override
  Widget build(BuildContext context) {
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
              Icons.edit_note_rounded,
              size: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppSizes.padding / 4),
            Text(
              'Edit Product',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        onTap: () {
          context.push('/products/product-edit/$id');
        },
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String? imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: AppSizes.screenWidth(context),
        minHeight: AppSizes.screenHeight(context) / 3,
        maxHeight: AppSizes.screenHeight(context) / 3,
      ),
      child: AppImage(
        image: imageUrl ?? '',
        backgroundColor: Theme.of(context).colorScheme.surface,
        border: Border.all(
          width: 0.5,
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        enableFullScreenView: true,
        errorWidget: Icon(
          Icons.image,
          color: Theme.of(context).colorScheme.surfaceDim,
          size: 32,
        ),
      ),
    );
  }
}

class _ProductName extends StatelessWidget {
  final String? productName;
  final String? createdAt;
  final String? updatedAt;

  const _ProductName({
    required this.productName,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          productName ?? '(No name)',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.padding / 2),
        Text(
          "Added at ${DateTimeFormatter.stripDateWithClock(createdAt ?? '')}",
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        Text(
          "Last updated at ${DateTimeFormatter.stripDateWithClock(updatedAt ?? '')}",
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

class _ProductPrice extends StatelessWidget {
  final int? price;

  const _ProductPrice({required this.price});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Price",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            CurrencyFormatter.format(price ?? 0),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductStock extends StatelessWidget {
  final int? stock;

  const _ProductStock({required this.stock});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Stock",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            "$stock",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductSold extends StatelessWidget {
  final int? sold;

  const _ProductSold({required this.sold});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sold",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            "$sold",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductDescription extends StatelessWidget {
  final String? description;

  const _ProductDescription({required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Description",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            description ?? '(No description)',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
