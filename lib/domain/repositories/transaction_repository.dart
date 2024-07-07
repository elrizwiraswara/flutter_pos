import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/domain/entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<Result<List<TransactionEntity>>> getAllTransactions(String userId);
  Future<void> createTransaction(TransactionEntity transaction);
  Future<Result<TransactionEntity>> getTransaction(int transactionId);
  Future<void> updateTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(TransactionEntity transaction);
}
