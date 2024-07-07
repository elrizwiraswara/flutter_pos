import 'package:floor/floor.dart';
import 'package:flutter_pos/data/models/user_model.dart';
import 'package:flutter_pos/domain/entities/transaction_entity.dart';

@Entity(
  tableName: 'transaction',
  primaryKeys: ['id'],
  foreignKeys: [
    ForeignKey(
      childColumns: ['id'],
      parentColumns: ['createdById'],
      entity: UserModel,
    )
  ],
)
class TransactionModel {
  final int id;
  final String paymentMethod;
  final String? customerName;
  final String? description;
  final String? createdById;
  final int receivedAmount;
  final int returnAmount;
  final int totalAmount;
  final String createdAt;
  final String updatedAt;

  const TransactionModel({
    required this.id,
    required this.paymentMethod,
    this.customerName,
    this.description,
    required this.createdById,
    required this.receivedAmount,
    required this.returnAmount,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      paymentMethod: json['paymentMethod'],
      customerName: json['customerName'],
      description: json['description'],
      createdById: json['createdById'],
      receivedAmount: json['receivedAmount'],
      returnAmount: json['returnAmount'],
      totalAmount: json['totalAmount'],
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
      'receivedAmount': receivedAmount,
      'returnAmount': returnAmount,
      'totalAmount': totalAmount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      paymentMethod: entity.paymentMethod,
      customerName: entity.customerName,
      description: entity.description,
      createdById: entity.createdById,
      receivedAmount: entity.receivedAmount,
      returnAmount: entity.returnAmount,
      totalAmount: entity.totalAmount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      paymentMethod: paymentMethod,
      customerName: customerName,
      description: description,
      createdBy: null,
      createdById: createdById,
      products: const [],
      receivedAmount: receivedAmount,
      returnAmount: returnAmount,
      totalAmount: totalAmount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
