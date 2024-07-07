import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<Result<List<ProductEntity>>> getAllProducts(String userId);
  Future<Result<ProductEntity>> createProduct(ProductEntity product);
  Future<Result<ProductEntity>> getProduct(int productId);
  Future<void> updateProduct(ProductEntity product);
  Future<void> deleteProduct(ProductEntity product);
}
