import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/themes/app_sizes.dart';
import '../../../app/utilities/currency_formatter.dart';
import '../../../app/utilities/date_formatter.dart';
import '../../../service_locator.dart';
import '../../providers/products/product_detail_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_progress_indicator.dart';
import '../error_handler_screen.dart';

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
        actions: [editButton(context)],
      ),
      body: FutureBuilder(
        future: sl<ProductDetailProvider>().getProductDetail(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppProgressIndicator();
          }

          if (snapshot.hasError) {
            return ErrorScreen(errorMessage: snapshot.error.toString());
          }

          if (snapshot.data == null) {
            return const AppEmptyState(title: 'Not Found');
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                image(context, imageUrl: snapshot.data!.imageUrl),
                Padding(
                  padding: const EdgeInsets.all(AppSizes.padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      name(
                        context,
                        productName: snapshot.data!.name,
                        createdAt: snapshot.data!.createdAt,
                        updatedAt: snapshot.data!.updatedAt,
                      ),
                      price(context, snapshot.data!.price),
                      stock(context, snapshot.data!.stock),
                      sold(context, snapshot.data!.sold),
                      description(context, snapshot.data!.description),
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

  Widget editButton(BuildContext context) {
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

  Widget image(
    BuildContext context, {
    String? imageUrl,
    String? productName,
    String? createdAt,
    String? updatedAt,
  }) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: AppImage(
        image: imageUrl ?? '',
        backgroundColor: Theme.of(context).colorScheme.surface,
        border: Border.all(width: 0.5, color: Theme.of(context).colorScheme.primaryContainer),
        enableFullScreenView: true,
        errorWidget: Icon(
          Icons.image,
          color: Theme.of(context).colorScheme.surfaceDim,
          size: 32,
        ),
      ),
    );
  }

  Widget name(
    BuildContext context, {
    String? productName,
    String? createdAt,
    String? updatedAt,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          productName ?? '(No name)',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSizes.padding / 2),
        Text(
          "Added at ${DateFormatter.stripDateWithClock(createdAt ?? '')}",
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        Text(
          "Last updated at ${DateFormatter.stripDateWithClock(updatedAt ?? '')}",
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 10,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }

  Widget price(BuildContext context, int? price) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Price",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
          ),
          Text(
            CurrencyFormatter.format(price ?? 0),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget stock(BuildContext context, int? stock) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Stock",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
          ),
          Text(
            "$stock",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget sold(BuildContext context, int? sold) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sold",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
          ),
          Text(
            "$sold",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget description(BuildContext context, String? description) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Description",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
          ),
          Text(
            description ?? '(No description)',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
