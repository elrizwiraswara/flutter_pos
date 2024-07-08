import 'package:flutter_pos/core/database/app_database.dart';
import 'package:flutter_pos/data/models/ordered_product_model.dart';
import 'package:flutter_pos/data/models/product_model.dart';
import 'package:flutter_pos/data/models/transaction_model.dart';
import 'package:flutter_pos/data/models/user_model.dart';
import 'package:sqflite/sqflite.dart';

class TransactionDatasource {
  final AppDatabase _appDatabase;

  TransactionDatasource(this._appDatabase);

  Future<int> insertTransaction(TransactionModel transaction) async {
    transaction.id ??= DateTime.now().millisecondsSinceEpoch;
    return await _appDatabase.database.transaction((trx) async {
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
          int stock = (order.product?.stock ?? 0) - order.quantity;
          int sold = (order.product?.sold ?? 0) + order.quantity;

          await trx.update(
            AppDatabaseConfig.productTableName,
            {'stock': stock, 'sold': sold},
            where: 'id = ?',
            whereArgs: [order.id],
          );
        }
      }

      return transactionId;
    });
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    return await _appDatabase.database.transaction((trx) async {
      await trx.update(
        AppDatabaseConfig.transactionTableName,
        transaction.toJson()
          ..remove('orderedProducts')
          ..remove('createdBy'),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (transaction.orderedProducts?.isNotEmpty ?? false) {
        for (var order in transaction.orderedProducts!) {
          // Create ordered product
          await trx.update(
            AppDatabaseConfig.orderedProductTableName,
            order.toJson()..remove('product'),
          );

          // Update product stock and sold
          int stock = (order.product?.stock ?? 0) - order.quantity;
          int sold = (order.product?.sold ?? 0) + order.quantity;

          await trx.update(
            AppDatabaseConfig.productTableName,
            {'stock': stock, 'sold': sold},
            where: 'id = ?',
            whereArgs: [order.id],
          );
        }
      }
    });
  }

  Future<void> deleteTransaction(int id) async {
    await _appDatabase.database.delete(
      AppDatabaseConfig.transactionTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

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

      // Get created by
      var rawCreatedBy = await trx.query(
        AppDatabaseConfig.userTableName,
        where: 'id = ?',
        whereArgs: [transaction.createdById],
      );

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

      // Set ordered products to transaction
      transaction.orderedProducts = orderedProducts;

      return transaction;
    });
  }

  Future<List<TransactionModel>> getAllUserTransactions(String userId) async {
    var rawTransactions = await _appDatabase.database.query(
      AppDatabaseConfig.transactionTableName,
      where: 'createdById = ?',
      whereArgs: [userId],
    );

    if (rawTransactions.isEmpty) {
      return [];
    }

    List<TransactionModel> transactions = [];

    for (var transaction in rawTransactions) {
      var data = await getTransaction(transaction['id'] as int);

      if (data == null) continue;

      transactions.add(data);
    }

    return transactions;
  }
}
