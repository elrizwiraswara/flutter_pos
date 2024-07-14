import '../../models/transaction_model.dart';

abstract class TransactionDatasource {
  Future<int> createTransaction(TransactionModel transaction);

  Future<void> updateTransaction(TransactionModel transaction);

  Future<void> deleteTransaction(int id);

  Future<TransactionModel?> getTransaction(int id);

  Future<List<TransactionModel>> getAllUserTransactions(String userId);

  Future<List<TransactionModel>> getUserTransactions(
    String userId, {
    String orderBy,
    String sortBy,
    int limit,
    int? offset,
    String? contains,
  });
}
