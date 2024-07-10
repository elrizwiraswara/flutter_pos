import 'package:flutter/foundation.dart';

import '../../../app/services/auth/auth_service.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../../domain/usecases/transaction_usecases.dart';

class TransactionsProvider extends ChangeNotifier {
  final TransactionRepository transactionRepository;

  TransactionsProvider({required this.transactionRepository});

  List<TransactionEntity>? allTransactions;

  Future<void> getAllTransactions() async {
    var res = await GetAllTransactionsUsecase(transactionRepository).call(AuthService().getAuthData()!.uid);

    if (res.isSuccess) {
      allTransactions = res.data ?? [];
      notifyListeners();
    } else {
      throw res.error?.message ?? 'Failed to load data';
    }
  }
}
