import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/themes/app_sizes.dart';
import '../../../service_locator.dart';
import '../../providers/transactions/transactions_provider.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_loading_more_indicator.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_text_field.dart';
import 'components/transaction_card.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final transactionProvider = sl<TransactionsProvider>();

  final scrollController = ScrollController();

  final searchFieldController = TextEditingController();

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

  void scrollListener() async {
    // Automatically load more data on end of scroll position
    if (scrollController.offset == scrollController.position.maxScrollExtent) {
      await transactionProvider.getAllTransactions(offset: transactionProvider.allTransactions?.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      body: Consumer<TransactionsProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: () => provider.getAllTransactions(),
            displacement: 60,
            child: Scrollbar(
              child: CustomScrollView(
                controller: scrollController,
                // Disable scroll when data is null or empty
                physics: (provider.allTransactions?.isEmpty ?? true) ? const NeverScrollableScrollPhysics() : null,
                slivers: [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    automaticallyImplyLeading: false,
                    collapsedHeight: 70,
                    titleSpacing: 0,
                    title: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
                      child: searchField(),
                    ),
                  ),
                  SliverLayoutBuilder(
                    builder: (context, constraint) {
                      if (provider.allTransactions == null) {
                        return const SliverFillRemaining(
                          hasScrollBody: false,
                          fillOverscroll: true,
                          child: AppProgressIndicator(),
                        );
                      }

                      if (provider.allTransactions!.isEmpty) {
                        return const SliverFillRemaining(
                          hasScrollBody: false,
                          fillOverscroll: true,
                          child: AppEmptyState(
                            subtitle: 'No transaction available',
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(AppSizes.padding, 2, AppSizes.padding, AppSizes.padding),
                        sliver: SliverList.builder(
                          itemCount: provider.allTransactions!.length,
                          itemBuilder: (context, i) {
                            return TransactionCard(transaction: provider.allTransactions![i]);
                          },
                        ),
                      );
                    },
                  ),
                  SliverToBoxAdapter(
                    child: AppLoadingMoreIndicator(isLoading: provider.isLoadingMore),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget searchField() {
    return AppTextField(
      controller: searchFieldController,
      hintText: 'Search Transaction ID...',
      type: AppTextFieldType.search,
      textInputAction: TextInputAction.search,
      onEditingComplete: () {
        FocusScope.of(context).unfocus();
        transactionProvider.allTransactions = null;
        transactionProvider.getAllTransactions(contains: searchFieldController.text);
      },
      onTapClearButton: () {
        transactionProvider.getAllTransactions(contains: searchFieldController.text);
      },
    );
  }
}
