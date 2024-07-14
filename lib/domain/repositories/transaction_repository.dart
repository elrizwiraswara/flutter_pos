import '../../core/usecase/usecase.dart';
import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<Result<int>> syncAllUserTransactions(String userId);

  Future<Result<TransactionEntity>> getTransaction(int transactionId);

  Future<Result<int>> createTransaction(TransactionEntity transaction);

  Future<Result<void>> updateTransaction(TransactionEntity transaction);

  Future<Result<void>> deleteTransaction(int transactionId);

  Future<Result<List<TransactionEntity>>> getUserTransactions(
    String userId, {
    String orderBy,
    String sortBy,
    int limit,
    int? offset,
    String? contains,
  });
}
