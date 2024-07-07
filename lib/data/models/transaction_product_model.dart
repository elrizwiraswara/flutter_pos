import 'package:floor/floor.dart';

@Entity(primaryKeys: ['transactionId', 'productId'])
class TransactionProductModel {
  final int transactionId;
  final int productId;

  TransactionProductModel(this.transactionId, this.productId);
}
