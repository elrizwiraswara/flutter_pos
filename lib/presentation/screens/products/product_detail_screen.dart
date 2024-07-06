import 'package:flutter/material.dart';
import 'package:flutter_pos/app/themes/app_sizes.dart';
import 'package:flutter_pos/app/utilities/currency_formatter.dart';
import 'package:flutter_pos/app/utilities/date_formatter.dart';
import 'package:flutter_pos/presentation/providers/products/product_form_provider.dart';
import 'package:flutter_pos/presentation/widgets/app_image.dart';
import 'package:flutter_pos/service_locator.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final int id;

  const ProductDetailScreen({
    super.key,
    required this.id,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _productDetailProvider = sl<ProductFormProvider>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _productDetailProvider.getProductDetail(widget.id);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        titleSpacing: 0,
      ),
      body: Consumer<ProductFormProvider>(builder: (context, provider, _) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              image(imageUrl: provider.product.imageUrl),
              Padding(
                padding: const EdgeInsets.all(AppSizes.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    name(
                      productName: provider.product.name,
                      createdAt: provider.product.dateCreated,
                      updatedAt: provider.product.dateUpdated,
                    ),
                    price(provider.product.price),
                    stock(provider.product.stock),
                    sold(provider.product.stock),
                    description(provider.product.description),
                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget image({
    String? imageUrl,
    String? productName,
    String? createdAt,
    String? updatedAt,
  }) {
    return AspectRatio(
      aspectRatio: 2,
      child: AppImage(
        image: imageUrl ?? '',
        borderRadius: AppSizes.radius,
        backgroundColor: Theme.of(context).colorScheme.surface,
        borderWidth: 1,
        borderColor: Theme.of(context).colorScheme.primaryContainer,
        enableFullScreenView: true,
        errorWidget: Icon(
          Icons.image,
          color: Theme.of(context).colorScheme.surfaceDim,
          size: 32,
        ),
      ),
    );
  }

  Widget name({
    String? productName,
    String? createdAt,
    String? updatedAt,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          productName ?? '(No name)',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
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

  Widget price(int? price) {
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

  Widget stock(int? stock) {
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

  Widget sold(int? sold) {
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

  Widget description(String? description) {
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
