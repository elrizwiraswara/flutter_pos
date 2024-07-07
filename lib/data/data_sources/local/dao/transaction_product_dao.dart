import 'package:floor/floor.dart';
import 'package:flutter_pos/data/models/transaction_product_model.dart';

@dao
abstract class TransactionProductDao {
  @Query('SELECT * FROM transaction_product')
  Future<List<TransactionProductModel>> findAllTransactionProducts();

  @insert
  Future<void> insertTransactionProduct(TransactionProductModel transactionProduct);
}
