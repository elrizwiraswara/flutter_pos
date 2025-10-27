import 'package:flutter/foundation.dart';

import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../../domain/usecases/params/base_params.dart';
import '../../../domain/usecases/transaction_usecases.dart';
import '../auth/auth_provider.dart';

class TransactionsProvider extends ChangeNotifier {
  final AuthProvider authProvider;
  final TransactionRepository transactionRepository;

  TransactionsProvider({
    required this.authProvider,
    required this.transactionRepository,
  });

  List<TransactionEntity>? allTransactions;

  bool isLoadingMore = false;

  Future<void> getAllTransactions({int? offset, String? contains}) async {
    var userId = authProvider.user?.id;
    if (userId == null) throw 'Unathenticated!';

    if (offset != null) {
      isLoadingMore = true;
      notifyListeners();
    }

    var params = BaseParams(
      param: userId,
      offset: offset,
      contains: contains,
    );

    var res = await GetUserTransactionsUsecase(transactionRepository).call(params);

    if (res.isSuccess) {
      if (offset == null) {
        allTransactions = res.data ?? [];
      } else {
        allTransactions?.addAll(res.data ?? []);
      }

      isLoadingMore = false;
      notifyListeners();
    } else {
      throw res.error ?? 'Failed to load data';
    }
  }
}
