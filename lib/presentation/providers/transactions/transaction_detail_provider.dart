import 'package:flutter/foundation.dart';
import 'package:flutter_pos/domain/entities/transaction_entity.dart';
import 'package:flutter_pos/domain/repositories/transaction_repository.dart';
import 'package:flutter_pos/domain/usecases/transaction_usecases.dart';

class TransactionDetailProvider extends ChangeNotifier {
  final TransactionRepository transactionRepository;

  TransactionDetailProvider({required this.transactionRepository});

  Future<TransactionEntity?> getTransactionDetail(int id) async {
    var res = await GetTransaction(transactionRepository).call(id);

    if (res.isSuccess) {
      return res.data;
    } else {
      throw res.error ?? 'Failed to load data';
    }
  }
}
