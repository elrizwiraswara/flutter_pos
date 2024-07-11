import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/themes/app_sizes.dart';
import '../../../service_locator.dart';
import '../../providers/transactions/transactions_provider.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_progress_indicator.dart';
import 'components/transaction_card.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final transactionProvider = sl<TransactionsProvider>();

  final scrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      transactionProvider.getAllTransactions();
    });
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
      transactionProvider.getAllTransactions(offset: transactionProvider.allTransactions?.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: Consumer<TransactionsProvider>(builder: (context, provider, _) {
        if (provider.allTransactions == null) {
          return const AppProgressIndicator();
        }

        if (provider.allTransactions!.isEmpty) {
          return const AppEmptyState(subtitle: 'No transactions available');
        }

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(AppSizes.padding),
          itemCount: provider.allTransactions!.length,
          itemBuilder: (context, i) {
            return TransactionCard(transaction: provider.allTransactions![i]);
          },
        );
      }),
    );
  }
}
