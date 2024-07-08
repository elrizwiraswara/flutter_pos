import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/domain/entities/transaction_entity.dart';
import 'package:flutter_pos/domain/repositories/transaction_repository.dart';

class GetAllTransactions extends UseCase<Result, String> {
  GetAllTransactions(this._transactionRepository);

  final TransactionRepository _transactionRepository;

  @override
  Future<Result<List<TransactionEntity>>> call(String params) async =>
      _transactionRepository.getAllUserTransactions(params);
}

class GetTransaction extends UseCase<Result, int> {
  GetTransaction(this._transactionRepository);

  final TransactionRepository _transactionRepository;

  @override
  Future<Result<TransactionEntity>> call(int params) async => _transactionRepository.getTransaction(params);
}

class CreateTransaction extends UseCase<Result, TransactionEntity> {
  CreateTransaction(this._transactionRepository);

  final TransactionRepository _transactionRepository;

  @override
  Future<Result<int>> call(TransactionEntity params) async => _transactionRepository.createTransaction(params);
}

class UpateTransaction extends UseCase<void, TransactionEntity> {
  UpateTransaction(this._transactionRepository);

  final TransactionRepository _transactionRepository;

  @override
  Future<void> call(TransactionEntity params) async => _transactionRepository.updateTransaction(params);
}

class DeleteTransaction extends UseCase<void, int> {
  DeleteTransaction(this._transactionRepository);

  final TransactionRepository _transactionRepository;

  @override
  Future<void> call(int params) async => _transactionRepository.deleteTransaction(params);
}
