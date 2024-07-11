import 'package:flutter/foundation.dart';
import 'package:flutter_pos/domain/usecases/params/base_params.dart';

import '../../../app/services/auth/auth_service.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../../domain/usecases/transaction_usecases.dart';

class TransactionsProvider extends ChangeNotifier {
  final TransactionRepository transactionRepository;

  TransactionsProvider({required this.transactionRepository});

  List<TransactionEntity>? allTransactions;

  Future<void> getAllTransactions({int? offset}) async {
    var params = BaseParams(
      param: AuthService().getAuthData()!.uid,
      offset: offset,
    );
    
    var res = await GetUserTransactionsUsecase(transactionRepository).call(params);

    if (res.isSuccess) {
      allTransactions = res.data ?? [];
      notifyListeners();
    } else {
      throw res.error?.message ?? 'Failed to load data';
    }
  }
}
