import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_sizes.dart';
import '../../../../app/utilities/currency_formatter.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dialog.dart';

class OrderCard extends StatefulWidget {
  final String name;
  final String imageUrl;
  final int stock;
  final int price;
  final int initialQuantity;
  final Function()? onTapCard;
  final Function()? onTapRemove;
  final Function(int) onChangedQuantity;

  const OrderCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.stock,
    required this.price,
    this.initialQuantity = 0,
    this.onTapCard,
    this.onTapRemove,
    required this.onChangedQuantity,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  int quantity = 1;

  @override
  void initState() {
    quantity = widget.initialQuantity == 0 ? 1 : widget.initialQuantity;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant OrderCard oldWidget) {
    quantity = widget.initialQuantity == 0 ? 1 : widget.initialQuantity;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(AppSizes.radius),
      child: InkWell(
        onTap: widget.onTapCard,
        child: Ink(
          padding: const EdgeInsets.all(AppSizes.padding),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
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
                      widget.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              CurrencyFormatter.format(widget.price),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '/pcs',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Stock: ${widget.stock}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                        ),
                        const SizedBox(height: 6),
                        qtyButtons(),
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
                    image: widget.imageUrl,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(width: 0.5, color: Theme.of(context).colorScheme.surfaceContainerHighest),
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                    errorWidget: Icon(
                      Icons.image,
                      color: Theme.of(context).colorScheme.surfaceDim,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (widget.onTapRemove != null)
                    AppButton(
                      text: 'Remove',
                      width: 70,
                      fontSize: 10,
                      borderRadius: BorderRadius.circular(4),
                      padding: const EdgeInsets.all(AppSizes.padding / 4),
                      buttonColor: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.32),
                      textColor: Theme.of(context).colorScheme.error,
                      onTap: () {
                        AppDialog.show(
                          title: 'Confirm',
                          text: 'Are you sure want to remove this product?',
                          rightButtonText: 'Remove',
                          leftButtonText: 'Cancel',
                          onTapRightButton: () {
                            widget.onTapRemove!();
                            AppRoutes.router.pop();
                          },
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget qtyButtons() {
    return Container(
      height: 36,
      constraints: const BoxConstraints(maxWidth: 112),
      child: Stack(
        children: [
          AppButton(
            width: double.infinity,
            height: 30,
            padding: EdgeInsets.zero,
            buttonColor: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderColor: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(4),
            child: Text(
              '$quantity',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          AppButton(
            width: 30,
            height: 30,
            padding: EdgeInsets.zero,
            buttonColor: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(4),
            child: Text(
              '-',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            onTap: () {
              if (quantity > 1) {
                quantity -= 1;
                setState(() {});

                widget.onChangedQuantity(quantity);
              }
            },
          ),
          Positioned(
            right: 0,
            child: AppButton(
              width: 30,
              height: 30,
              padding: EdgeInsets.zero,
              buttonColor: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(4),
              child: Text(
                '+',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              onTap: () {
                if (quantity < widget.stock) {
                  quantity += 1;
                  setState(() {});

                  widget.onChangedQuantity(quantity);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
