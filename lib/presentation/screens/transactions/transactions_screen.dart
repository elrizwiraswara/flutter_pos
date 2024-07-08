import 'package:flutter/material.dart';
import 'package:flutter_pos/app/themes/app_sizes.dart';
import 'package:flutter_pos/domain/entities/transaction_entity.dart';
import 'package:flutter_pos/presentation/providers/transactions/transactions_provider.dart';
import 'package:flutter_pos/presentation/widgets/app_empty_state.dart';
import 'package:flutter_pos/presentation/widgets/app_progress_indicator.dart';
import 'package:flutter_pos/service_locator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _transactionProvider = sl<TransactionsProvider>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _transactionProvider.getAllTransactions();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Product'),
      ),
      body: Consumer<TransactionsProvider>(builder: (context, provider, _) {
        if (provider.allTransactions == null) {
          return const AppProgressIndicator();
        }

        if (provider.allTransactions!.isEmpty) {
          return AppEmptyState(
            subtitle: 'No products available, add product to continue',
            buttonText: 'Add Product',
            onTapButton: () => context.go('/products/product-create'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSizes.padding),
          itemCount: provider.allTransactions!.length,
          itemBuilder: (context, i) {
            return transactionCard(provider.allTransactions![i]);
          },
        );
      }),
    );
  }

  Widget transactionCard(TransactionEntity transaction) {
    return Container();
  }
}
