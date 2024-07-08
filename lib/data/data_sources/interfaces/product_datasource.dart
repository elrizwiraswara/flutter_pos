import 'package:flutter_pos/data/models/product_model.dart';

abstract class ProductDatasource {
  Future<int> createProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(int id);
  Future<ProductModel?> getProduct(int id);
  Future<List<ProductModel>> getAllUserProduct(String id);
}
