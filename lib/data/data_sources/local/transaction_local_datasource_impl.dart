import 'package:flutter_pos/app/database/app_database.dart';
import 'package:flutter_pos/data/data_sources/interfaces/transaction_datasource.dart';
import 'package:flutter_pos/data/models/ordered_product_model.dart';
import 'package:flutter_pos/data/models/product_model.dart';
import 'package:flutter_pos/data/models/transaction_model.dart';
import 'package:flutter_pos/data/models/user_model.dart';
import 'package:sqflite/sqflite.dart';

class TransactionLocalDatasourceImpl extends TransactionDatasource {
  final AppDatabase _appDatabase;

  TransactionLocalDatasourceImpl(this._appDatabase);

  @override
  Future<int> createTransaction(TransactionModel transaction) async {
    transaction.id ??= DateTime.now().millisecondsSinceEpoch;
    return await _appDatabase.database.transaction((trx) async {
      // Create transaction
      var transactionId = await trx.insert(
        AppDatabaseConfig.transactionTableName,
        transaction.toJson()
          ..remove('orderedProducts')
          ..remove('createdBy'),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (transaction.orderedProducts?.isNotEmpty ?? false) {
        for (var order in transaction.orderedProducts!) {
          // Create ordered product
          order.id ??= DateTime.now().millisecondsSinceEpoch;
          order.transactionId = transactionId;
          await trx.insert(
            AppDatabaseConfig.orderedProductTableName,
            order.toJson()..remove('product'),
          );

          // Update product stock and sold
          order.product?.stock -= order.quantity;
          order.product?.sold += order.quantity;

          await trx.update(
            AppDatabaseConfig.productTableName,
            order.product?.toJson() ?? {},
            where: 'id = ?',
            whereArgs: [order.productId],
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }

      return transactionId;
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
        for (var order in transaction.orderedProducts!) {
          // Update ordered product
          await trx.update(
            AppDatabaseConfig.orderedProductTableName,
            order.toJson()..remove('product'),
          );

          // Update product stock and sold
          order.product?.stock -= order.quantity;
          order.product?.sold += order.quantity;

          await trx.update(
            AppDatabaseConfig.productTableName,
            order.product?.toJson() ?? {},
            where: 'id = ?',
            whereArgs: [order.productId],
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

      // Get products of ordered products
      if (orderedProducts.isNotEmpty) {
        for (var order in orderedProducts) {
          var rawProducts = await trx.query(
            AppDatabaseConfig.productTableName,
            where: 'id = ?',
            whereArgs: [order.productId],
          );

          if (rawProducts.isEmpty) continue;

          // Set product to ordered product
          order.product = ProductModel.fromJson(rawProducts.first);
        }
      }

      return transaction;
    });
  }

  @override
  Future<List<TransactionModel>> getAllUserTransactions(String userId) async {
    var rawTransactions = await _appDatabase.database.query(
      AppDatabaseConfig.transactionTableName,
      where: 'createdById = ?',
      whereArgs: [userId],
    );

    return rawTransactions.map((e) => TransactionModel.fromJson(e)).toList();
  }
}
