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
    transaction.id ??= DateTime.now().millisecondsSinceEpoch;
    return await _firebaseFirestore.runTransaction((trx) async {
      // Create transaction
      var tarnsactionDocRef = _firebaseFirestore.collection('Transaction').doc('${transaction.id}');
      trx.set(
          tarnsactionDocRef,
          transaction.toJson()
            ..remove('orderedProducts')
            ..remove('createdBy'));

      if (transaction.orderedProducts?.isNotEmpty ?? false) {
        for (var order in transaction.orderedProducts!) {
          // Create ordered product
          order.id ??= DateTime.now().millisecondsSinceEpoch;
          order.transactionId = transaction.id!;
          var orderedProductDocRef = _firebaseFirestore.collection('OrderedProduct').doc('${order.id}');

          trx.set(
            orderedProductDocRef,
            order.toJson()..remove('product'),
          );

          // Update product stock and sold
          order.product?.stock -= order.quantity;
          order.product?.sold += order.quantity;
          var productDocRef = _firebaseFirestore.collection('Product').doc('${order.productId}');

          trx.set(
            productDocRef,
            order.product?.toJson(),
            SetOptions(merge: true),
          );
        }
      }

      return transaction.id!;
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
        SetOptions(merge: true),
      );

      if (transaction.orderedProducts?.isNotEmpty ?? false) {
        for (var order in transaction.orderedProducts!) {
          // Update ordered product
          var orderedProductDocRef = _firebaseFirestore.collection('OrderedProduct').doc('${order.id}');

          trx.set(
            orderedProductDocRef,
            order.toJson()..remove('product'),
            SetOptions(merge: true),
          );

          // Update product stock and sold
          order.product?.stock -= order.quantity;
          order.product?.sold += order.quantity;
          var productDocRef = _firebaseFirestore.collection('Product').doc('${order.productId}');

          trx.set(
            productDocRef,
            order.product?.toJson(),
            SetOptions(merge: true),
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
          await _firebaseFirestore.collection('OrderedProduct').where('transactionId', isEqualTo: transaction.id).get();

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

      // Get products of ordered products
      if (orderedProducts.isNotEmpty) {
        for (var order in orderedProducts) {
          var rawProductDocRef = _firebaseFirestore.collection('Product').doc('${order.productId}');
          var rawProducts = await trx.get(rawProductDocRef);

          if (rawProducts.data() == null) continue;

          // Set product to ordered product
          order.product = ProductModel.fromJson(rawProducts.data()!);
        }
      }

      return transaction;
    });
  }

  @override
  Future<List<TransactionModel>> getAllUserTransactions(String userId) async {
    var rawTransactions =
        await _firebaseFirestore.collection('Transaction').where('createdById', isEqualTo: userId).get();

    return rawTransactions.docs.map((e) => TransactionModel.fromJson(e.data())).toList();
  }
}
