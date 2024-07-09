import 'product_entity.dart';

class OrderedProductEntity {
  int? id;
  int? transactionId;
  int quantity;
  int productId;
  ProductEntity? product;
  String? createdAt;
  String? updatedAt;

  OrderedProductEntity({
    this.id,
    this.transactionId,
    required this.quantity,
    required this.productId,
    this.product,
    this.createdAt,
    this.updatedAt,
  });
}
