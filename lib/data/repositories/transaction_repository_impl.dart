import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/data/data_sources/local/transaction_datasource.dart';
import 'package:flutter_pos/data/models/transaction_model.dart';
import 'package:flutter_pos/domain/entities/transaction_entity.dart';
import 'package:flutter_pos/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl extends TransactionRepository {
  final TransactionDatasource _transactionDatasource;

  TransactionRepositoryImpl(this._transactionDatasource);

  @override
  Future<Result<List<TransactionEntity>>> getAllUserTransactions(String userId) async {
    var res = await _transactionDatasource.getAllUserTransactions(userId);
    return Result.success(res.map((e) => e.toEntity()).toList());
  }

  @override
  Future<Result<TransactionEntity>> getTransaction(int transactionId) async {
    var res = await _transactionDatasource.getTransaction(transactionId);
    return Result.success(res?.toEntity());
  }

  @override
  Future<Result<int>> createTransaction(TransactionEntity transaction) async {
    var id = await _transactionDatasource.insertTransaction(TransactionModel.fromEntity(transaction));
    return Result.success(id);
  }

  @override
  Future<void> deleteTransaction(int transactionId) async {
    return await _transactionDatasource.deleteTransaction(transactionId);
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) async {
    return await _transactionDatasource.updateTransaction(TransactionModel.fromEntity(transaction));
  }
}
