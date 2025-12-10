import 'package:flutter/material.dart';

import '../../../app/di/dependency_injection.dart';
import '../../../core/extensions/string_casing_extension.dart';
import '../../../core/themes/app_colors.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/currency_formatter.dart';
import '../../../core/utilities/date_time_formatter.dart';
import '../../../domain/entities/ordered_product_entity.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../providers/transactions/transaction_detail_provider.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_progress_indicator.dart';

class TransactionDetailScreen extends StatelessWidget {
  final int id;

  const TransactionDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: FutureBuilder(
        future: di<TransactionDetailProvider>().getTransactionDetail(id),
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

          final transaction = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.padding),
            child: Column(
              children: [
                const _StatusSection(),
                const SizedBox(height: AppSizes.padding * 2),
                _TransactionDetail(transaction: transaction),
                const SizedBox(height: AppSizes.padding),
                _PaymentDetail(transaction: transaction),
                const SizedBox(height: AppSizes.padding),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.check_circle_outline_rounded,
          color: AppColors.green,
          size: 60,
        ),
        const SizedBox(height: AppSizes.padding / 2),
        Text(
          'Transaction Created',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _TransactionDetail extends StatelessWidget {
  final TransactionEntity transaction;

  const _TransactionDetail({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaction ID',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${transaction.id ?? '-'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.padding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Method',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                transaction.paymentMethod.toTitleCase(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.padding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Created By',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                transaction.createdBy?.name ?? '-',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.padding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Created At',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                DateTimeFormatter.normalWithClock(transaction.createdAt ?? ''),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.padding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer Name',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                transaction.customerName ?? '-',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.padding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Description',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                transaction.description ?? '-',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentDetail extends StatelessWidget {
  final TransactionEntity transaction;

  const _PaymentDetail({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ordered Products',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${transaction.orderedProducts?.length ?? '0'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: AppSizes.padding * 2),
          ...List.generate(transaction.orderedProducts?.length ?? 0, (i) {
            return Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : AppSizes.padding / 2),
              child: _ProductItem(order: transaction.orderedProducts![i]),
            );
          }),
          const Divider(height: AppSizes.padding * 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                CurrencyFormatter.format(transaction.totalAmount),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.padding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Received',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                CurrencyFormatter.format(transaction.receivedAmount),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.padding),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Change',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                CurrencyFormatter.format(transaction.receivedAmount - transaction.totalAmount),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductItem extends StatelessWidget {
  final OrderedProductEntity order;

  const _ProductItem({required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.name,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.padding / 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${CurrencyFormatter.format(order.price)} x ${order.quantity}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              CurrencyFormatter.format((order.price) * order.quantity),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}
