import 'package:sqflite/sqflite.dart';

import '../../../app/database/app_database.dart';
import '../../models/ordered_product_model.dart';
import '../../models/product_model.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';
import '../interfaces/transaction_datasource.dart';

class TransactionLocalDatasourceImpl extends TransactionDatasource {
  final AppDatabase _appDatabase;

  TransactionLocalDatasourceImpl(this._appDatabase);

  @override
  Future<int> createTransaction(TransactionModel transaction) async {
    return await _appDatabase.database.transaction((trx) async {
      // Create transaction
      await trx.insert(
        AppDatabaseConfig.transactionTableName,
        transaction.toJson()
          ..remove('orderedProducts')
          ..remove('createdBy'),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (transaction.orderedProducts?.isNotEmpty ?? false) {
        for (var orderedProduct in transaction.orderedProducts!) {
          // Create ordered product
          orderedProduct.transactionId = transaction.id;

          await trx.insert(
            AppDatabaseConfig.orderedProductTableName,
            orderedProduct.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          // Get product
          var rawProduct = await trx.query(
            AppDatabaseConfig.productTableName,
            where: 'id = ?',
            whereArgs: [orderedProduct.productId],
          );

          if (rawProduct.isEmpty) continue;

          var product = ProductModel.fromJson(rawProduct.first);

          // Update product stock and sold
          int stock = product.stock - orderedProduct.quantity;
          int sold = product.sold + orderedProduct.quantity;

          await trx.update(
            AppDatabaseConfig.productTableName,
            {'stock': stock, 'sold': sold},
            where: 'id = ?',
            whereArgs: [product.id],
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }

      // The id has been generated in models
      return transaction.id;
    });
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    return await _appDatabase.database.transaction((trx) async {
      // Update transaction
      await trx.update(
        AppDatabaseConfig.transactionTableName,
        transaction.toJson()
          ..remove('orderedProducts')
          ..remove('createdBy'),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (transaction.orderedProducts?.isNotEmpty ?? false) {
        for (var orderedProduct in transaction.orderedProducts!) {
          // Update ordered product
          await trx.update(
            AppDatabaseConfig.orderedProductTableName,
            orderedProduct.toJson(),
          );

          // Get product
          var rawProduct = await trx.query(
            AppDatabaseConfig.productTableName,
            where: 'id = ?',
            whereArgs: [orderedProduct.productId],
          );

          if (rawProduct.isEmpty) continue;

          var product = ProductModel.fromJson(rawProduct.first);

          // Update product stock and sold
          int stock = product.stock - orderedProduct.quantity;
          int sold = product.sold + orderedProduct.quantity;

          await trx.update(
            AppDatabaseConfig.productTableName,
            {'stock': stock, 'sold': sold},
            where: 'id = ?',
            whereArgs: [product.id],
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
    });
  }

  @override
  Future<void> deleteTransaction(int id) async {
    await _appDatabase.database.delete(
      AppDatabaseConfig.transactionTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<TransactionModel?> getTransaction(int id) async {
    return await _appDatabase.database.transaction((trx) async {
      // Get transaction
      var rawTransactions = await trx.query(
        AppDatabaseConfig.transactionTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rawTransactions.isEmpty) {
        return null;
      }

      var transaction = TransactionModel.fromJson(rawTransactions.first);

      // Get transaction ordered products
      var rawOrderedProducts = await trx.query(
        AppDatabaseConfig.orderedProductTableName,
        where: 'transactionId = ?',
        whereArgs: [id],
      );

      var orderedProducts = (rawOrderedProducts as List).map((e) => OrderedProductModel.fromJson(e)).toList();

      // Set ordered products to transaction
      transaction.orderedProducts = orderedProducts;

      // Get created by
      var rawCreatedBy = await trx.query(
        AppDatabaseConfig.userTableName,
        where: 'id = ?',
        whereArgs: [transaction.createdById],
      );

      // Set created by to transaction
      if (rawCreatedBy.isNotEmpty) {
        transaction.createdBy = UserModel.fromJson(rawCreatedBy.first);
      }

      return transaction;
    });
  }

  @override
  Future<List<TransactionModel>> getAllUserTransactions(String userId) async {
    return await _appDatabase.database.transaction((trx) async {
      var rawTransactions = await trx.query(
        AppDatabaseConfig.transactionTableName,
        where: 'createdById = ?',
        whereArgs: [userId],
      );

      var transactions = rawTransactions.map((e) => TransactionModel.fromJson(e)).toList();

      for (var transaction in transactions) {
        // Get transaction ordered products
        var rawOrderedProducts = await trx.query(
          AppDatabaseConfig.orderedProductTableName,
          where: 'transactionId = ?',
          whereArgs: [transaction.id],
        );

        var orderedProducts = (rawOrderedProducts as List).map((e) => OrderedProductModel.fromJson(e)).toList();

        // Set ordered products to transaction
        transaction.orderedProducts = orderedProducts;

        // Get created by
        var rawCreatedBy = await trx.query(
          AppDatabaseConfig.userTableName,
          where: 'id = ?',
          whereArgs: [transaction.createdById],
        );

        // Set created by to transaction
        if (rawCreatedBy.isNotEmpty) {
          transaction.createdBy = UserModel.fromJson(rawCreatedBy.first);
        }
      }

      return transactions;
    });
  }

  @override
  Future<List<TransactionModel>> getUserTransactions(
    String userId, {
    String orderBy = 'createdAt',
    String sortBy = 'DESC',
    int limit = 10,
    int? offset,
    String? contains,
  }) async {
    return await _appDatabase.database.transaction((trx) async {
      // Get transaction
      var rawTransactions = await _appDatabase.database.query(
        AppDatabaseConfig.transactionTableName,
        where: 'createdById = ? AND id LIKE ?',
        whereArgs: [userId, "%${contains ?? ''}%"],
        orderBy: '$orderBy $sortBy',
        limit: limit,
        offset: offset,
      );

      var transactions = rawTransactions.map((e) => TransactionModel.fromJson(e)).toList();

      for (var transaction in transactions) {
        // Get transaction ordered products
        var rawOrderedProducts = await trx.query(
          AppDatabaseConfig.orderedProductTableName,
          where: 'transactionId = ?',
          whereArgs: [transaction.id],
        );

        var orderedProducts = (rawOrderedProducts as List).map((e) => OrderedProductModel.fromJson(e)).toList();

        // Set ordered products to transaction
        transaction.orderedProducts = orderedProducts;

        // Get created by
        var rawCreatedBy = await trx.query(
          AppDatabaseConfig.userTableName,
          where: 'id = ?',
          whereArgs: [transaction.createdById],
        );

        // Set created by to transaction
        if (rawCreatedBy.isNotEmpty) {
          transaction.createdBy = UserModel.fromJson(rawCreatedBy.first);
        }
      }

      return transactions;
    });
  }
}
