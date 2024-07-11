import '../../domain/entities/transaction_entity.dart';
import 'ordered_product_model.dart';
import 'user_model.dart';

class TransactionModel {
  int id;
  String paymentMethod;
  String? customerName;
  String? description;
  String createdById;
  UserModel? createdBy;
  List<OrderedProductModel>? orderedProducts;
  int receivedAmount;
  int returnAmount;
  int totalAmount;
  int totalOrderedProduct;
  String? createdAt;
  String? updatedAt;

  TransactionModel({
    required this.id,
    required this.paymentMethod,
    this.customerName,
    this.description,
    required this.createdById,
    this.createdBy,
    this.orderedProducts,
    required this.receivedAmount,
    required this.returnAmount,
    required this.totalAmount,
    required this.totalOrderedProduct,
    this.createdAt,
    this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      paymentMethod: json['paymentMethod'],
      customerName: json['customerName'],
      description: json['description'],
      createdById: json['createdById'],
      createdBy: json['createdBy'],
      orderedProducts: json['orderedProducts'] != null
          ? (json['orderedProducts'] as List).map((e) => OrderedProductModel.fromJson(e)).toList()
          : null,
      receivedAmount: json['receivedAmount'],
      returnAmount: json['returnAmount'],
      totalAmount: json['totalAmount'],
      totalOrderedProduct: json['totalOrderedProduct'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentMethod': paymentMethod,
      'customerName': customerName,
      'description': description,
      'createdById': createdById,
      'createdBy': createdBy,
      'orderedProducts': orderedProducts?.map((e) => e.toJson()).toList(),
      'receivedAmount': receivedAmount,
      'returnAmount': returnAmount,
      'totalAmount': totalAmount,
      'totalOrderedProduct': totalOrderedProduct,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id ?? DateTime.now().millisecondsSinceEpoch,
      paymentMethod: entity.paymentMethod,
      customerName: entity.customerName,
      description: entity.description,
      createdById: entity.createdById,
      createdBy: entity.createdBy != null ? UserModel.fromEntity(entity.createdBy!) : null,
      orderedProducts: entity.orderedProducts?.map((e) => OrderedProductModel.fromEntity(e)).toList(),
      receivedAmount: entity.receivedAmount,
      returnAmount: entity.returnAmount,
      totalAmount: entity.totalAmount,
      totalOrderedProduct: entity.totalOrderedProduct,
      createdAt: entity.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: entity.updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      paymentMethod: paymentMethod,
      customerName: customerName,
      description: description,
      createdBy: createdBy?.toEntity(),
      createdById: createdById,
      orderedProducts: orderedProducts?.map((e) => e.toEntity()).toList(),
      receivedAmount: receivedAmount,
      returnAmount: returnAmount,
      totalAmount: totalAmount,
      totalOrderedProduct: totalOrderedProduct,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
