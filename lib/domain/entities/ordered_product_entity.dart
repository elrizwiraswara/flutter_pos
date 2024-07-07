import 'package:flutter_pos/domain/entities/product_entity.dart';

class OrderedProductEntity {
  int quantity;
  ProductEntity product;

  OrderedProductEntity({
    required this.quantity,
    required this.product,
  });
}
