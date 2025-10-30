import '../../../core/common/result.dart';
import '../../models/transaction_model.dart';

abstract class TransactionDatasource {
  Future<Result<int>> createTransaction(TransactionModel transaction);

  Future<Result<void>> updateTransaction(TransactionModel transaction);

  Future<Result<void>> deleteTransaction(int id);

  Future<Result<TransactionModel?>> getTransaction(int id);

  Future<Result<List<TransactionModel>>> getAllUserTransactions(String userId);

  Future<Result<List<TransactionModel>>> getUserTransactions(
    String userId, {
    String orderBy,
    String sortBy,
    int limit,
    int? offset,
    String? contains,
  });
}
