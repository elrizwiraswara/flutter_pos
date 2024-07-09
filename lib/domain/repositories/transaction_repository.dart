import '../../core/usecase/usecase.dart';
import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<Result<List<TransactionEntity>>> getAllUserTransactions(String userId);
  Future<Result<TransactionEntity>> getTransaction(int transactionId);
  Future<Result<int>> createTransaction(TransactionEntity transaction);
  Future<void> updateTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(int transactionId);
}
