import 'package:flutter/material.dart';
import 'package:flutter_pos/app/assets/app_assets.dart';
import 'package:flutter_pos/app/utilities/currency_formatter.dart';
import 'package:flutter_pos/domain/entities/product_entity.dart';
import 'package:flutter_pos/presentation/widgets/app_button.dart';
import 'package:flutter_pos/presentation/widgets/app_image.dart';

class ProductsCard extends StatelessWidget {
  final ProductEntity product;
  final Function()? onTap;

  const ProductsCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.black.withOpacity(0.06),
        splashFactory: InkRipple.splashFactory,
        highlightColor: Colors.black12,
        borderRadius: BorderRadius.circular(4),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              width: 0.5,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 146, maxHeight: 226),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: product.imageUrl.isNotEmpty
                          ? AppImage(
                              image: product.imageUrl,
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                              borderRadius: 4,
                            )
                          : const AppImage(
                              image: AppAssets.emptyPlaceholder,
                              imgProvider: ImgProvider.assetImage,
                            ),
                    ),
                    product.stock == 0
                        ? AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: AppButton(
                                height: 22,
                                width: 54,
                                padding: EdgeInsets.zero,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.remove_circle,
                                      color: Theme.of(context).colorScheme.outline,
                                      size: 10,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Habis',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            color: Theme.of(context).colorScheme.outline,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: 8,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Stock ${product.stock}  |  Terjual ${product.sold}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 8),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.format(product.price),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
