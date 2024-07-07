import 'package:equatable/equatable.dart';
import 'package:flutter_pos/domain/entities/product_entity.dart';
import 'package:flutter_pos/domain/entities/user_entity.dart';

class TransactionEntity extends Equatable {
  final int id;
  final String paymentMethod;
  final String? customerName;
  final String? description;
  final String? createdById;
  final UserEntity? createdBy;
  final List<ProductEntity>? products;
  final int receivedAmount;
  final int returnAmount;
  final int totalAmount;
  final String createdAt;
  final String updatedAt;

  const TransactionEntity({
    required this.id,
    required this.paymentMethod,
    this.customerName,
    this.description,
    required this.createdById,
    this.createdBy,
    this.products,
    required this.receivedAmount,
    required this.returnAmount,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  TransactionEntity copyWith({
    int? id,
    String? paymentMethod,
    String? customerName,
    String? description,
    String? createdById,
    UserEntity? createdBy,
    List<ProductEntity>? products,
    int? receivedAmount,
    int? returnAmount,
    int? totalAmount,
    String? createdAt,
    String? updatedAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      customerName: customerName ?? this.customerName,
      description: description ?? this.description,
      createdById: createdById ?? this.createdById,
      createdBy: createdBy ?? this.createdBy,
      products: products ?? this.products,
      receivedAmount: receivedAmount ?? this.receivedAmount,
      returnAmount: returnAmount ?? this.returnAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        paymentMethod,
        customerName,
        description,
        createdById,
        createdBy,
        products,
        receivedAmount,
        returnAmount,
        totalAmount,
        createdAt,
        updatedAt
      ];
}
