import 'package:flutter/material.dart';
import 'package:flutter_pos/app/themes/app_sizes.dart';
import 'package:flutter_pos/app/utilities/currency_formatter.dart';
import 'package:flutter_pos/domain/entities/product_entity.dart';
import 'package:flutter_pos/presentation/widgets/app_button.dart';
import 'package:flutter_pos/presentation/widgets/app_dialog.dart';
import 'package:flutter_pos/presentation/widgets/app_image.dart';

class OrderCard extends StatelessWidget {
  final ProductEntity product;
  final bool showDeleteButton;
  final Function()? onTap;

  const OrderCard({
    super.key,
    required this.product,
    this.showDeleteButton = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(AppSizes.radius),
      child: InkWell(
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(AppSizes.padding),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.surfaceContainer,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radius),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              CurrencyFormatter.format(product.price ?? 0),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '/barang',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Stock: ${product.stock! - 1}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                        ),
                        const SizedBox(height: 6),
                        qtyButtons(context),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppImage(
                    width: 70,
                    height: 70,
                    image: product.imageUrl ?? '',
                    borderRadius: AppSizes.radius,
                    backgroundColor: Theme.of(context).colorScheme.surfaceDim,
                  ),
                  const SizedBox(height: 12),
                  if (showDeleteButton)
                    AppButton(
                      text: 'Hapus',
                      width: 70,
                      padding: const EdgeInsets.all(2),
                      buttonColor: Theme.of(context).colorScheme.errorContainer,
                      textColor: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                      onTap: () {
                        AppDialog.show(
                          title: 'Konfirmasi',
                          text: 'Apakah anda yakin ingin menghapus produk ${product.name} ini?',
                          rightButtonText: 'Hapus',
                          leftButtonText: 'Batal',
                          onTapRightButton: () {
                            //
                          },
                        );
                      },
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget qtyButtons(BuildContext context) {
    return Container(
      height: 36,
      constraints: const BoxConstraints(maxWidth: 112),
      child: Stack(
        children: [
          AppButton(
            enabled: false,
            width: double.infinity,
            height: 30,
            padding: EdgeInsets.zero,
            disabledButtonColor: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderColor: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(6),
            child: Text(
              '${product.stock}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          AppButton(
            width: 30,
            height: 30,
            padding: EdgeInsets.zero,
            buttonColor: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(6),
            child: Text(
              '-',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            onTap: () {
              //
            },
          ),
          Positioned(
            right: 0,
            child: AppButton(
              width: 30,
              height: 30,
              padding: EdgeInsets.zero,
              buttonColor: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(6),
              child: Text(
                '+',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              onTap: () {
                //
              },
            ),
          ),
        ],
      ),
    );
  }
}
