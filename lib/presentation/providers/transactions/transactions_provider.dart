import 'package:flutter/foundation.dart';
import 'package:flutter_pos/app/services/auth/auth_service.dart';
import 'package:flutter_pos/domain/entities/transaction_entity.dart';
import 'package:flutter_pos/domain/repositories/transaction_repository.dart';
import 'package:flutter_pos/domain/usecases/transaction_usecases.dart';

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
      throw res.error?.error ?? 'Failed to load data';
    }
  }
}
