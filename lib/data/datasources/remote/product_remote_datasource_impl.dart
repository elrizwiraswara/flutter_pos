import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/common/result.dart';
import '../../models/product_model.dart';
import '../interfaces/product_datasource.dart';

class ProductRemoteDatasourceImpl extends ProductDatasource {
  final FirebaseFirestore _firebaseFirestore;

  ProductRemoteDatasourceImpl(this._firebaseFirestore);

  @override
  Future<Result<int>> createProduct(ProductModel product) async {
    try {
      await _firebaseFirestore.collection('Product').doc("${product.id}").set(product.toJson());
      // The id has been generated in models
      return Result.success(data: product.id);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateProduct(ProductModel product) async {
    try {
      await _firebaseFirestore
          .collection('Product')
          .doc("${product.id}")
          .set(product.toJson(), SetOptions(merge: true));

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteProduct(int id) async {
    try {
      await _firebaseFirestore.collection('Product').doc("$id").delete();
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<ProductModel?>> getProduct(int id) async {
    try {
      var res = await _firebaseFirestore.collection('Product').doc("$id").get();
      if (res.data() == null) return Result.success(data: null);
      return Result.success(data: ProductModel.fromJson(res.data()!));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ProductModel>>> getAllUserProducts(String userId) async {
    try {
      var res = await _firebaseFirestore.collection('Product').where('createdById', isEqualTo: userId).get();
      var products = res.docs.map((e) => ProductModel.fromJson(e.data())).toList();
      return Result.success(data: products);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ProductModel>>> getUserProducts(
    String userId, {
    String orderBy = 'createdAt',
    String sortBy = 'DESC',
    int limit = 10,
    int? offset,
    String? contains,
  }) async {
    try {
      // Because firestore doesn't support numeric offset
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
          return Result.success(data: []);
        }
      }

      var rawProducts = await query.get();
      var products = rawProducts.docs.map((e) => ProductModel.fromJson(e.data())).toList();
      return Result.success(data: products);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
