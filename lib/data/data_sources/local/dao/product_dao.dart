import 'package:floor/floor.dart';
import 'package:flutter_pos/data/models/product_model.dart';

@dao
abstract class ProductDao {
  @insert
  Future<void> insertProduct(ProductModel product);

  @update
  Future<void> updateProduct(ProductModel product);

  @delete
  Future<void> deleteProduct(ProductModel product);

  @Query('SELECT * FROM product WHERE created_by_id = :id')
  Future<List<ProductModel>> findAllUserProducts(String id);

  @Query(
    'SELECT * FROM product WHERE id IN (SELECT product_id FROM transaction_product WHERE transaction_id = :transactionId)',
  )
  Future<List<ProductModel>> findProductsForTransaction(int transactionId);
}
