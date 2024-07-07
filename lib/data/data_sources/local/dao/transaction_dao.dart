import 'package:floor/floor.dart';
import 'package:flutter_pos/data/models/transaction_model.dart';

@dao
abstract class TransactionDao {
  @insert
  Future<void> insertTransaction(TransactionModel transaction);

  @update
  Future<void> updateTransaction(TransactionModel transaction);

  @delete
  Future<void> deleteTransaction(TransactionModel transaction);

  @Query('SELECT * FROM transaction WHERE created_by_id = :id')
  Future<List<TransactionModel>> findAllUserTransactions(String id);

  @Query('SELECT * FROM transaction WHERE id = :id')
  Future<TransactionModel?> findTransactionById(int id);
}
