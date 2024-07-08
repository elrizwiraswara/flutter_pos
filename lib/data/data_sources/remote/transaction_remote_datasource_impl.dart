import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pos/data/data_sources/interfaces/transaction_datasource.dart';
import 'package:flutter_pos/data/models/ordered_product_model.dart';
import 'package:flutter_pos/data/models/product_model.dart';
import 'package:flutter_pos/data/models/transaction_model.dart';
import 'package:flutter_pos/data/models/user_model.dart';

class TransactionRemoteDatasourceImpl extends TransactionDatasource {
  final FirebaseFirestore _firebaseFirestore;

  TransactionRemoteDatasourceImpl(this._firebaseFirestore);

  @override
  Future<int> createTransaction(TransactionModel transaction) async {
    transaction.id ??= DateTime.now().millisecondsSinceEpoch;
    return await _firebaseFirestore.runTransaction((trx) async {
      // Create transaction
      var tarnsactionDocRef = _firebaseFirestore.collection('Transaction').doc('${transaction.id}');
      var transactionId = await trx
          .set(
              tarnsactionDocRef,
              transaction.toJson()
                ..remove('orderedProducts')
                ..remove('createdBy'))
          .get(tarnsactionDocRef);

      if (transaction.orderedProducts?.isNotEmpty ?? false) {
        for (var order in transaction.orderedProducts!) {
          // Create ordered product
          order.id ??= DateTime.now().millisecondsSinceEpoch;
          order.transactionId = transactionId.data()?['id'];
          var orderedProductDocRef = _firebaseFirestore.collection('OrderedProduct').doc('${order.id}');

          trx.set(
            orderedProductDocRef,
            order.toJson()..remove('product'),
          );

          // Update product stock and sold
          int stock = (order.product?.stock ?? 0) - order.quantity;
          int sold = (order.product?.sold ?? 0) + order.quantity;
          var productDocRef = _firebaseFirestore.collection('Product').doc('${order.id}');

          trx.update(
            productDocRef,
            {'stock': stock, 'sold': sold},
          );
        }
      }

      return transactionId.data()?['id'];
    });
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    return await _firebaseFirestore.runTransaction((trx) async {
      // Update transaction
      var tarnsactionDocRef = _firebaseFirestore.collection('Transaction').doc('${transaction.id}');
      trx.set(
        tarnsactionDocRef,
        transaction.toJson()
          ..remove('orderedProducts')
          ..remove('createdBy'),
      );

      if (transaction.orderedProducts?.isNotEmpty ?? false) {
        for (var order in transaction.orderedProducts!) {
          // Update ordered product
          var orderedProductDocRef = _firebaseFirestore.collection('OrderedProduct').doc('${order.id}');

          trx.set(
            orderedProductDocRef,
            order.toJson()..remove('product'),
          );

          // Update product stock and sold
          int stock = (order.product?.stock ?? 0) - order.quantity;
          int sold = (order.product?.sold ?? 0) + order.quantity;
          var productDocRef = _firebaseFirestore.collection('Product').doc('${order.id}');

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
    await _firebaseFirestore.collection('Transaction').doc('$id').delete();
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
      var rawOrderedProducts =
          await _firebaseFirestore.collection('OrderedProduct').where('transactionId', isEqualTo: id).get();

      var orderedProducts = rawOrderedProducts.docs.map((e) => OrderedProductModel.fromJson(e.data())).toList();

      // Get created by
      var rawCreatedBy = await _firebaseFirestore.collection('User').doc(transaction.createdById).get();

      if (rawCreatedBy.data() != null) {
        transaction.createdBy = UserModel.fromJson(rawCreatedBy.data()!);
      }

      // Get products of ordered products
      if (orderedProducts.isNotEmpty) {
        for (var order in orderedProducts) {
          var rawProducts = await _firebaseFirestore.collection('Product').doc('${order.productId}').get();

          if (rawProducts.data() == null) continue;

          // Set product to ordered product
          order.product = ProductModel.fromJson(rawProducts.data()!);
        }
      }

      // Set ordered products to transaction
      transaction.orderedProducts = orderedProducts;

      return transaction;
    });
  }

  @override
  Future<List<TransactionModel>> getAllUserTransactions(String userId) async {
    var rawTransactions =
        await _firebaseFirestore.collection('Transaction').where('createdById', isEqualTo: userId).get();

    if (rawTransactions.docs.isEmpty) {
      return [];
    }

    List<TransactionModel> transactions = [];

    for (var transaction in rawTransactions.docs) {
      var data = await getTransaction(transaction.data()['id'] as int);

      if (data == null) continue;

      transactions.add(data);
    }

    return transactions;
  }
}
