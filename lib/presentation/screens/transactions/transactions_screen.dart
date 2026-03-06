import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/themes/app_sizes.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_loading_more_indicator.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_text_field.dart';
import 'components/transaction_card.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final scrollController = ScrollController();
  final searchFieldController = TextEditingController();

  @override
  void initState() {
    scrollController.addListener(scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionsControllerProvider).getAllTransactions();
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    searchFieldController.dispose();
    super.dispose();
  }

  void scrollListener() async {
    final transactionProvider = ref.read(transactionsControllerProvider);

    // Automatically load more data on end of scroll position
    if (scrollController.offset == scrollController.position.maxScrollExtent) {
      await transactionProvider.getAllTransactions(offset: transactionProvider.allTransactions?.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allTransactions = ref.watch(transactionsControllerProvider.select((p) => p.allTransactions));
    final isLoadingMore = ref.watch(transactionsControllerProvider.select((p) => p.isLoadingMore));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(transactionsControllerProvider).getAllTransactions(),
        displacement: 60,
        child: Scrollbar(
          child: CustomScrollView(
            controller: scrollController,
            // Disable scroll when data is null or empty
            physics: (allTransactions?.isEmpty ?? true) ? const NeverScrollableScrollPhysics() : null,
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                automaticallyImplyLeading: false,
                collapsedHeight: 70,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
                  child: _SearchField(controller: searchFieldController),
                ),
              ),
              SliverLayoutBuilder(
                builder: (context, constraint) {
                  if (allTransactions == null) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: AppProgressIndicator(),
                    );
                  }

                  if (allTransactions.isEmpty) {
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
                      itemCount: allTransactions.length,
                      itemBuilder: (context, i) {
                        return TransactionCard(transaction: allTransactions[i]);
                      },
                    ),
                  );
                },
              ),
              SliverToBoxAdapter(
                child: AppLoadingMoreIndicator(isLoading: isLoadingMore),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends ConsumerWidget {
  final TextEditingController controller;

  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionProvider = ref.read(transactionsControllerProvider);

    return AppTextField(
      controller: controller,
      hintText: 'Search Transaction ID...',
      type: AppTextFieldType.search,
      textInputAction: TextInputAction.search,
      onEditingComplete: () {
        FocusScope.of(context).unfocus();
        transactionProvider.resetTransactions();
        transactionProvider.getAllTransactions(contains: controller.text);
      },
      onTapClearButton: () {
        transactionProvider.getAllTransactions(contains: controller.text);
      },
    );
  }
}
