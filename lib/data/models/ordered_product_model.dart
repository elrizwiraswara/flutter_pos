import 'package:flutter_pos/data/models/product_model.dart';
import 'package:flutter_pos/domain/entities/ordered_product_entity.dart';

class OrderedProductModel {
  int? id;
  int? transactionId;
  int quantity;
  int productId;
  ProductModel? product;
  String? createdAt;
  String? updatedAt;

  OrderedProductModel({
    this.id,
    this.transactionId,
    required this.quantity,
    required this.productId,
    this.product,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderedProductModel.fromJson(Map<String, dynamic> json) {
    return OrderedProductModel(
      id: json['id'],
      transactionId: json['transactionId'],
      quantity: json['quantity'],
      productId: json['productId'],
      product: json['product'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'quantity': quantity,
      'productId': productId,
      'product': product,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory OrderedProductModel.fromEntity(OrderedProductEntity entity) {
    return OrderedProductModel(
      id: entity.id,
      transactionId: entity.transactionId,
      quantity: entity.quantity,
      productId: entity.productId,
      product: entity.product != null ? ProductModel.fromEntity(entity.product!) : null,
      createdAt: entity.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: entity.updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  OrderedProductEntity toEntity() {
    return OrderedProductEntity(
      id: id,
      transactionId: transactionId,
      quantity: quantity,
      productId: productId,
      product: product?.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
