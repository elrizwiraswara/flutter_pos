import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/product_model.dart';
import '../interfaces/product_datasource.dart';

class ProductRemoteDatasourceImpl extends ProductDatasource {
  final FirebaseFirestore _firebaseFirestore;

  ProductRemoteDatasourceImpl(this._firebaseFirestore);

  @override
  Future<int> createProduct(ProductModel product) async {
    product.id ??= DateTime.now().millisecondsSinceEpoch;
    await _firebaseFirestore.collection('Product').doc("${product.id}").set(product.toJson());
    return product.id!;
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await _firebaseFirestore.collection('Product').doc("${product.id}").set(
          product.toJson(),
          SetOptions(merge: true),
        );
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
  Future<List<ProductModel>> getAllUserProduct(String id) async {
    var res = await _firebaseFirestore.collection('Product').where('createdById', isEqualTo: id).get();
    return res.docs.map((e) => ProductModel.fromJson(e.data())).toList();
  }
}
