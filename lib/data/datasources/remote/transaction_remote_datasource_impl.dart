import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/common/result.dart';
import '../../models/ordered_product_model.dart';
import '../../models/product_model.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';
import '../interfaces/transaction_datasource.dart';

class TransactionRemoteDatasourceImpl extends TransactionDatasource {
  final FirebaseFirestore _firebaseFirestore;

  TransactionRemoteDatasourceImpl(this._firebaseFirestore);

  @override
  Future<Result<int>> createTransaction(TransactionModel transaction) async {
    try {
      final transactionId = await _firebaseFirestore.runTransaction((trx) async {
        // Get products
        List<ProductModel> products = [];

        if (transaction.orderedProducts?.isNotEmpty ?? false) {
          for (var orderedProduct in transaction.orderedProducts!) {
            var productDocRef = _firebaseFirestore.collection('Product').doc('${orderedProduct.productId}');
            var rawProduct = await trx.get(productDocRef);

            if (rawProduct.data() != null) {
              products.add(ProductModel.fromJson(rawProduct.data()!));
            }
          }
        }

        // Create ordered products and update product stock and sold
        if (transaction.orderedProducts?.isNotEmpty ?? false) {
          for (var orderedProduct in transaction.orderedProducts!) {
            // Create ordered product
            orderedProduct.transactionId = transaction.id;
            var orderedProductDocRef = _firebaseFirestore.collection('OrderedProduct').doc('${orderedProduct.id}');
            trx.set(orderedProductDocRef, orderedProduct.toJson());

            // Check if product exists
            var product = products.where((p) => p.id == orderedProduct.productId).firstOrNull;
            if (product == null) continue;

            // Update product stock and sold
            int stock = product.stock - orderedProduct.quantity;
            int sold = product.sold + orderedProduct.quantity;

            var productDocRef = _firebaseFirestore.collection('Product').doc('${product.id}');
            trx.update(productDocRef, {'stock': stock, 'sold': sold});
          }
        }

        // Create transaction
        var transactionDocRef = _firebaseFirestore.collection('Transaction').doc('${transaction.id}');
        trx.set(
          transactionDocRef,
          transaction.toJson()
            ..remove('orderedProducts')
            ..remove('createdBy'),
        );

        // The id has been generated in models
        return transaction.id;
      });

      return Result.success(data: transactionId);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateTransaction(TransactionModel transaction) async {
    try {
      await _firebaseFirestore.runTransaction((trx) async {
        // Get products
        List<ProductModel> products = [];

        if (transaction.orderedProducts?.isNotEmpty ?? false) {
          for (var orderedProduct in transaction.orderedProducts!) {
            var productDocRef = _firebaseFirestore.collection('Product').doc('${orderedProduct.productId}');
            var rawProduct = await trx.get(productDocRef);

            if (rawProduct.data() != null) {
              products.add(ProductModel.fromJson(rawProduct.data()!));
            }
          }
        }

        // Update ordered product
        if (transaction.orderedProducts?.isNotEmpty ?? false) {
          for (var orderedProduct in transaction.orderedProducts!) {
            var orderedProductDocRef = _firebaseFirestore.collection('OrderedProduct').doc('${orderedProduct.id}');
            trx.update(orderedProductDocRef, orderedProduct.toJson());
          }
        }

        // Update transaction
        var transactionDocRef = _firebaseFirestore.collection('Transaction').doc('${transaction.id}');
        trx.update(
          transactionDocRef,
          transaction.toJson()
            ..remove('orderedProducts')
            ..remove('createdBy'),
        );
      });

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteTransaction(int id) async {
    try {
      // Get ordered products to revert stock
      var orderedProductsQuery = await _firebaseFirestore
          .collection('OrderedProduct')
          .where('transactionId', isEqualTo: id)
          .get();

      var orderedProducts = orderedProductsQuery.docs.map((e) => OrderedProductModel.fromJson(e.data()));

      await _firebaseFirestore.runTransaction((trx) async {
        // Get products
        List<ProductModel> products = [];

        for (var orderedProduct in orderedProducts) {
          var productDocRef = _firebaseFirestore.collection('Product').doc('${orderedProduct.productId}');
          var productDoc = await trx.get(productDocRef);

          if (productDoc.data() != null) {
            products.add(ProductModel.fromJson(productDoc.data()!));
          }
        }

        // Revert stock for each product
        for (var orderedProduct in orderedProducts) {
          var product = products.where((e) => e.id == orderedProduct.productId).firstOrNull;
          if (product == null) continue;

          int revertedStock = product.stock + orderedProduct.quantity;
          int revertedSold = product.sold - orderedProduct.quantity;

          var productDocRef = _firebaseFirestore.collection('Product').doc('${orderedProduct.productId}');
          trx.update(productDocRef, {
            'stock': revertedStock,
            'sold': revertedSold,
          });

          // Delete ordered product
          var orderedProductDocRef = _firebaseFirestore.collection('OrderedProduct').doc('${orderedProduct.id}');
          trx.delete(orderedProductDocRef);
        }

        // Delete transaction
        var transactionDocRef = _firebaseFirestore.collection('Transaction').doc('$id');
        trx.delete(transactionDocRef);
      });

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<TransactionModel?>> getTransaction(int id) async {
    try {
      // Get transactions
      var rawTransaction = await _firebaseFirestore.collection('Transaction').doc('$id').get();
      if (rawTransaction.data() == null) return Result.success(data: null);

      var transaction = TransactionModel.fromJson(rawTransaction.data()!);

      // Get transaction ordered products
      var rawOrderedProducts = await _firebaseFirestore
          .collection('OrderedProduct')
          .where('transactionId', isEqualTo: id)
          .get();

      var orderedProducts = rawOrderedProducts.docs.map((e) => OrderedProductModel.fromJson(e.data())).toList();

      // Get user
      var rawUser = await _firebaseFirestore.collection('User').doc(transaction.createdById).get();
      if (rawUser.data() == null) return Result.failure(error: 'User data not found');

      var user = UserModel.fromJson(rawUser.data()!);

      // Set ordered products and created by to transaction
      transaction.orderedProducts = orderedProducts;
      transaction.createdBy = user;

      return Result.success(data: transaction);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<TransactionModel>>> getAllUserTransactions(String userId) async {
    try {
      // Get transactions
      var rawTransactions = await _firebaseFirestore
          .collection('Transaction')
          .where('createdById', isEqualTo: userId)
          .get();

      var transactions = rawTransactions.docs.map((e) => TransactionModel.fromJson(e.data())).toList();

      // Get user
      var rawUser = await _firebaseFirestore.collection('User').doc(userId).get();
      if (rawUser.data() == null) return Result.failure(error: 'User data not found');

      var user = UserModel.fromJson(rawUser.data()!);

      for (var transaction in transactions) {
        // Get transaction ordered products
        var rawOrderedProducts = await _firebaseFirestore
            .collection('OrderedProduct')
            .where('transactionId', isEqualTo: transaction.id)
            .get();

        var orderedProducts = rawOrderedProducts.docs.map((e) => OrderedProductModel.fromJson(e.data())).toList();

        // Set ordered products and created by to each transaction
        transaction.orderedProducts = orderedProducts;
        transaction.createdBy = user;
      }

      return Result.success(data: transactions);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<TransactionModel>>> getUserTransactions(
    String userId, {
    String orderBy = 'createdAt',
    String sortBy = 'DESC',
    int limit = 10,
    int? offset,
    String? contains,
  }) async {
    try {
      var query = _firebaseFirestore
          .collection('Transaction')
          .where('createdById', isEqualTo: userId)
          .where('id', arrayContains: contains)
          .orderBy(orderBy, descending: sortBy == 'DESC')
          .limit(limit);

      if (offset != null) {
        DocumentSnapshot<Object?>? lastSnapshot;

        var temp = await _firebaseFirestore
            .collection('Transaction')
            .where('createdById', isEqualTo: userId)
            .orderBy(orderBy, descending: sortBy == 'DESC')
            .limit(offset)
            .get();

        lastSnapshot = temp.docs.lastOrNull;

        if (lastSnapshot != null) {
          query = query.startAfterDocument(lastSnapshot);
        } else {
          return Result.success(data: []);
        }
      }

      // Get transactions
      var rawTransactions = await query.get();
      var transactions = rawTransactions.docs.map((e) => TransactionModel.fromJson(e.data())).toList();

      // Get user
      var rawUser = await _firebaseFirestore.collection('User').doc(userId).get();
      if (rawUser.data() == null) return Result.failure(error: 'User data not found');

      var user = UserModel.fromJson(rawUser.data()!);

      for (var transaction in transactions) {
        // Get transaction ordered products
        var rawOrderedProducts = await _firebaseFirestore
            .collection('OrderedProduct')
            .where('transactionId', isEqualTo: transaction.id)
            .get();

        var orderedProducts = rawOrderedProducts.docs.map((e) => OrderedProductModel.fromJson(e.data())).toList();

        // Set ordered products and created by to each transaction
        transaction.orderedProducts = orderedProducts;
        transaction.createdBy = user;
      }

      return Result.success(data: transactions);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
