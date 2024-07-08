import 'package:flutter/material.dart';
import 'package:flutter_pos/app/themes/app_sizes.dart';
import 'package:flutter_pos/presentation/providers/transactions/transactions_provider.dart';
import 'package:flutter_pos/presentation/screens/transactions/components/transaction_card.dart';
import 'package:flutter_pos/presentation/widgets/app_empty_state.dart';
import 'package:flutter_pos/presentation/widgets/app_progress_indicator.dart';
import 'package:flutter_pos/service_locator.dart';
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
