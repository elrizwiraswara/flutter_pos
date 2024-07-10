import '../../core/usecase/usecase.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Result<List<ProductEntity>>> getAllUserProducts(String userId);
  Future<Result<ProductEntity>> getProduct(int productId);
  Future<Result<int>> createProduct(ProductEntity product);
  Future<Result<void>> updateProduct(ProductEntity product);
  Future<Result<void>> deleteProduct(int productId);
}
