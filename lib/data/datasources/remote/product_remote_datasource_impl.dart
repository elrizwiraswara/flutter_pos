import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/product_model.dart';
import '../interfaces/product_datasource.dart';

class ProductRemoteDatasourceImpl extends ProductDatasource {
  final FirebaseFirestore _firebaseFirestore;

  ProductRemoteDatasourceImpl(this._firebaseFirestore);

  @override
  Future<int> createProduct(ProductModel product) async {
    await _firebaseFirestore.collection('Product').doc("${product.id}").set(product.toJson());
    // The id has been generated in models
    return product.id;
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await _firebaseFirestore.collection('Product').doc("${product.id}").set(product.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteProduct(int id) async {
    await _firebaseFirestore.collection('Product').doc("$id").delete();
  }

  @override
  Future<ProductModel?> getProduct(int id) async {
    var res = await _firebaseFirestore.collection('Product').doc("$id").get();
    if (res.data() == null) return null;
    return ProductModel.fromJson(res.data()!);
  }

  @override
  Future<List<ProductModel>> getAllUserProducts(String userId) async {
    var res = await _firebaseFirestore.collection('Product').where('createdById', isEqualTo: userId).get();
    return res.docs.map((e) => ProductModel.fromJson(e.data())).toList();
  }

  @override
  Future<List<ProductModel>> getUserProducts(
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
        .collection('Product')
        .where('createdById', isEqualTo: userId)
        .where('name', arrayContains: contains)
        .orderBy(orderBy, descending: sortBy == 'DESC')
        .limit(limit);

    if (offset != null) {
      DocumentSnapshot<Object?>? lastSnapshot;

      var temp = await _firebaseFirestore
          .collection('Product')
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

    var rawProducts = await query.get();

    return rawProducts.docs.map((e) => ProductModel.fromJson(e.data())).toList();
  }
}
