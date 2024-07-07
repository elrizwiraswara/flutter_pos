import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/data/data_sources/local/app_database.dart';
import 'package:flutter_pos/data/models/transaction_model.dart';
import 'package:flutter_pos/data/models/transaction_product_model.dart';
import 'package:flutter_pos/domain/entities/transaction_entity.dart';
import 'package:flutter_pos/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl extends TransactionRepository {
  final AppDatabase _appDatabase;
  TransactionRepositoryImpl(this._appDatabase);

  @override
  Future<void> createTransaction(TransactionEntity transaction) async {
    await _appDatabase.transactionDao.insertTransaction(TransactionModel.fromEntity(transaction));

    if (transaction.products == null) return;

    for (var product in transaction.products!) {
      await _appDatabase.transactionProductDao.insertTransactionProduct(
        TransactionProductModel(transaction.id, product.id),
      );
    }

    return;
  }

  @override
  Future<void> deleteTransaction(TransactionEntity transaction) async {
    return await _appDatabase.transactionDao.deleteTransaction(TransactionModel.fromEntity(transaction));
  }

  @override
  Future<Result<List<TransactionEntity>>> getAllTransactions(String userId) async {
    final user = await _appDatabase.userDao.findUserById(userId);
    final transactions = await _appDatabase.transactionDao.findAllUserTransactions(userId);

    final List<TransactionEntity> result = [];

    for (var transaction in transactions) {
      final products = await _appDatabase.productDao.findProductsForTransaction(transaction.id);

      final productEntities = products.map((e) => e.toEntity()).toList();

      var transactionEntity = TransactionEntity(
        id: transaction.id,
        paymentMethod: transaction.paymentMethod,
        products: productEntities,
        createdBy: user?.toEntity(),
        createdById: user?.id,
        receivedAmount: transaction.receivedAmount,
        returnAmount: transaction.returnAmount,
        totalAmount: transaction.totalAmount,
        createdAt: transaction.createdAt,
        updatedAt: transaction.updatedAt,
      );

      result.add(transactionEntity);
    }

    return Result.success(result);
  }

  @override
  Future<Result<TransactionEntity>> getTransaction(int transactionId) async {
    var res = await _appDatabase.transactionDao.findTransactionById(transactionId);

    return Result.success(res?.toEntity());
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) async {
    return await _appDatabase.transactionDao.updateTransaction(TransactionModel.fromEntity(transaction));
  }
}
