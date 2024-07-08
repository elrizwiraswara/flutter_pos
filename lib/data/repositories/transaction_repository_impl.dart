import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/data/data_sources/local/transaction_local_datasource_impl.dart';
import 'package:flutter_pos/data/data_sources/remote/transaction_remote_datasource_impl.dart';
import 'package:flutter_pos/data/models/transaction_model.dart';
import 'package:flutter_pos/domain/entities/transaction_entity.dart';
import 'package:flutter_pos/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl extends TransactionRepository {
  final TransactionLocalDatasourceImpl transactionLocalDatasource;
  final TransactionRemoteDatasourceImpl transactionRemoteDatasource;

  TransactionRepositoryImpl({required this.transactionLocalDatasource, required this.transactionRemoteDatasource});

  @override
  Future<Result<List<TransactionEntity>>> getAllUserTransactions(String userId) async {
    var res = await transactionLocalDatasource.getAllUserTransactions(userId);
    return Result.success(res.map((e) => e.toEntity()).toList());
  }

  @override
  Future<Result<TransactionEntity>> getTransaction(int transactionId) async {
    var res = await transactionLocalDatasource.getTransaction(transactionId);
    return Result.success(res?.toEntity());
  }

  @override
  Future<Result<int>> createTransaction(TransactionEntity transaction) async {
    var id = await transactionLocalDatasource.createTransaction(TransactionModel.fromEntity(transaction));
    return Result.success(id);
  }

  @override
  Future<void> deleteTransaction(int transactionId) async {
    return await transactionLocalDatasource.deleteTransaction(transactionId);
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) async {
    return await transactionLocalDatasource.updateTransaction(TransactionModel.fromEntity(transaction));
  }
}
