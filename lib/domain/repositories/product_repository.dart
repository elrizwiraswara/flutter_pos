import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<Result<List<ProductEntity>>> getAllUserProducts(String userId);
  Future<Result<ProductEntity>> getProduct(int productId);
  Future<Result<int>> createProduct(ProductEntity product);
  Future<void> updateProduct(ProductEntity product);
  Future<void> deleteProduct(int productId);
}
