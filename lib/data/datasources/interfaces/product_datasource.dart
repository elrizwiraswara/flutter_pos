import '../../models/product_model.dart';

abstract class ProductDatasource {
  Future<int> createProduct(ProductModel product);

  Future<void> updateProduct(ProductModel product);

  Future<void> deleteProduct(int id);

  Future<ProductModel?> getProduct(int id);

  Future<List<ProductModel>> getAllUserProducts(String userId);

  Future<List<ProductModel>> getUserProducts(
    String userId, {
    String orderBy,
    String sortBy,
    int limit,
    int? offset,
    String? contains,
  });
}
