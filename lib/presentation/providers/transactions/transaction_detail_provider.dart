import 'package:flutter/foundation.dart';

import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../../domain/usecases/transaction_usecases.dart';

class TransactionDetailProvider extends ChangeNotifier {
  final TransactionRepository transactionRepository;

  TransactionDetailProvider({required this.transactionRepository});

  Future<TransactionEntity?> getTransactionDetail(int id) async {
    var res = await GetTransactionUsecase(transactionRepository).call(id);

    if (res.isSuccess) {
      return res.data;
    } else {
      throw res.error ?? 'Failed to load data';
    }
  }
}
