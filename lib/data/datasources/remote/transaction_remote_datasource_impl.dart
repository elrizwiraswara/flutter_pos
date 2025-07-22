import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/ordered_product_model.dart';
import '../../models/product_model.dart';
import '../../models/transaction_model.dart';
import '../../models/user_model.dart';
import '../interfaces/transaction_datasource.dart';

class TransactionRemoteDatasourceImpl extends TransactionDatasource {
  final FirebaseFirestore _firebaseFirestore;

  TransactionRemoteDatasourceImpl(this._firebaseFirestore);

  @override
  Future<int> createTransaction(TransactionModel transaction) async {
    return await _firebaseFirestore.runTransaction((trx) async {
      // Create transaction
      var tarnsactionDocRef = _firebaseFirestore.collection('Transaction').doc('${transaction.id}');
      trx.set(
        tarnsactionDocRef,
        transaction.toJson()
          ..remove('orderedProducts')
          ..remove('createdBy'),
      );

      if (transaction.orderedProducts?.isNotEmpty ?? false) {
        for (var orderedProduct in transaction.orderedProducts!) {
          // Create ordered product
          orderedProduct.transactionId = transaction.id;
          var orderedProductDocRef = _firebaseFirestore.collection('OrderedProduct').doc('${orderedProduct.id}');

          trx.set(
            orderedProductDocRef,
            orderedProduct.toJson(),
          );

          // Get product
          var rawProduct = await _firebaseFirestore.collection('Product').doc('${orderedProduct.productId}').get();
          if (rawProduct.data() == null) continue;

          var product = ProductModel.fromJson(rawProduct.data()!);

          // Update product stock and sold
          int stock = product.stock - orderedProduct.quantity;
          int sold = product.sold + orderedProduct.quantity;
          var productDocRef = _firebaseFirestore.collection('Product').doc('${product.id}');

          trx.update(
            productDocRef,
            {'stock': stock, 'sold': sold},
          );
        }
      }

      // The id has been generated in models
      return transaction.id;
    });
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    return await _firebaseFirestore.runTransaction((trx) async {
      // Update transaction
      var tarnsactionDocRef = _firebaseFirestore.collection('Transaction').doc('${transaction.id}');
      trx.update(
        tarnsactionDocRef,
        transaction.toJson()
          ..remove('orderedProducts')
          ..remove('createdBy'),
      );

      if (transaction.orderedProducts?.isNotEmpty ?? false) {
        for (var orderedProduct in transaction.orderedProducts!) {
          // Update ordered product
          var orderedProductDocRef = _firebaseFirestore.collection('OrderedProduct').doc('${orderedProduct.id}');

          trx.update(
            orderedProductDocRef,
            orderedProduct.toJson(),
          );

          // Get product
          var rawProduct = await _firebaseFirestore.collection('Product').doc('${orderedProduct.productId}').get();

          if (rawProduct.data() == null) continue;

          var product = ProductModel.fromJson(rawProduct.data()!);

          // Update product stock and sold
          int stock = product.stock - orderedProduct.quantity;
          int sold = product.sold + orderedProduct.quantity;
          var productDocRef = _firebaseFirestore.collection('Product').doc('${product.id}');

          trx.update(
            productDocRef,
            {'stock': stock, 'sold': sold},
          );
        }
      }
    });
  }

  @override
  Future<void> deleteTransaction(int id) async {
    return await _firebaseFirestore.runTransaction((trx) async {
      try {
        // Get ordered products to revert stock
        var orderedProductsQuery = await _firebaseFirestore
            .collection('OrderedProduct')
            .where('transactionId', isEqualTo: id)
            .get();

        // Revert stock for each ordered product
        for (var doc in orderedProductsQuery.docs) {
          var orderedProduct = OrderedProductModel.fromJson(doc.data());
          var productDocRef = _firebaseFirestore.collection('Product').doc('${orderedProduct.productId}');
          var productDoc = await trx.get(productDocRef);

          if (productDoc.exists && productDoc.data() != null) {
            var product = ProductModel.fromJson(productDoc.data() as Map<String, dynamic>);

            int revertedStock = product.stock + orderedProduct.quantity;
            int revertedSold = product.sold - orderedProduct.quantity;

            trx.update(productDocRef, {
              'stock': revertedStock,
              'sold': revertedSold,
            });
          }

          // Delete ordered product
          trx.delete(doc.reference);
        }

        // Delete transaction
        var transactionDocRef = _firebaseFirestore.collection('Transaction').doc('$id');
        trx.delete(transactionDocRef);
      } catch (e) {
        rethrow;
      }
    });
  }

  @override
  Future<TransactionModel?> getTransaction(int id) async {
    return await _firebaseFirestore.runTransaction((trx) async {
      // Get transaction
      var tarnsactionDocRef = _firebaseFirestore.collection('Transaction').doc('$id');
      var rawTransactions = await trx.get(tarnsactionDocRef);

      if (rawTransactions.data() == null) {
        return null;
      }

      var transaction = TransactionModel.fromJson(rawTransactions.data()!);

      // Get transaction ordered products
      var rawOrderedProducts = await _firebaseFirestore
          .collection('OrderedProduct')
          .where('transactionId', isEqualTo: transaction.id)
          .get();

      var orderedProducts = rawOrderedProducts.docs.map((e) => OrderedProductModel.fromJson(e.data())).toList();

      // Set ordered products to transaction
      transaction.orderedProducts = orderedProducts;

      // Get created by
      var rawCreatedByDocRef = _firebaseFirestore.collection('User').doc(transaction.createdById);
      var rawCreatedBy = await trx.get(rawCreatedByDocRef);

      // Set created by to transaction
      if (rawCreatedBy.data() != null) {
        transaction.createdBy = UserModel.fromJson(rawCreatedBy.data()!);
      }

      return transaction;
    });
  }

  @override
  Future<List<TransactionModel>> getAllUserTransactions(String userId) async {
    return await _firebaseFirestore.runTransaction((trx) async {
      var rawTransactions = await _firebaseFirestore
          .collection('Transaction')
          .where('createdById', isEqualTo: userId)
          .get();

      var transactions = rawTransactions.docs.map((e) => TransactionModel.fromJson(e.data())).toList();

      for (var transaction in transactions) {
        // Get transaction ordered products
        var rawOrderedProducts = await _firebaseFirestore
            .collection('OrderedProduct')
            .where('transactionId', isEqualTo: transaction.id)
            .get();

        var orderedProducts = rawOrderedProducts.docs.map((e) => OrderedProductModel.fromJson(e.data())).toList();

        // Set ordered products to transaction
        transaction.orderedProducts = orderedProducts;

        // Get created by
        var rawCreatedByDocRef = _firebaseFirestore.collection('User').doc(transaction.createdById);
        var rawCreatedBy = await trx.get(rawCreatedByDocRef);

        // Set created by to transaction
        if (rawCreatedBy.data() != null) {
          transaction.createdBy = UserModel.fromJson(rawCreatedBy.data()!);
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
    // Because firestore doesn't suppport numeric offset
    // Instead, use query cursors. Get last document snapshot then pass it to startAfterDocument
    // https://firebase.google.com/docs/firestore/query-data/query-cursors

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
        return [];
      }
    }

    var rawTransactions = await query.get();

    var transactions = rawTransactions.docs.map((e) => TransactionModel.fromJson(e.data())).toList();

    for (var transaction in transactions) {
      // Get transaction ordered products
      var rawOrderedProducts = await _firebaseFirestore
          .collection('OrderedProduct')
          .where('transactionId', isEqualTo: transaction.id)
          .get();

      var orderedProducts = rawOrderedProducts.docs.map((e) => OrderedProductModel.fromJson(e.data())).toList();

      // Set ordered products to transaction
      transaction.orderedProducts = orderedProducts;

      // Get created by
      var rawCreatedBy = await _firebaseFirestore.collection('User').doc(transaction.createdById).get();

      // Set created by to transaction
      if (rawCreatedBy.data() != null) {
        transaction.createdBy = UserModel.fromJson(rawCreatedBy.data()!);
      }
    }

    return transactions;
  }
}
