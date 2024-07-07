import 'package:floor/floor.dart';
import 'package:flutter_pos/data/models/user_model.dart';
import 'package:flutter_pos/domain/entities/product_entity.dart';

@Entity(
  tableName: 'product',
  primaryKeys: ['id'],
  foreignKeys: [
    ForeignKey(
      childColumns: ['id'],
      parentColumns: ['createdById'],
      entity: UserModel,
    )
  ],
)
class ProductModel {
  final int id;
  final String createdById;
  final String name;
  final String imageUrl;
  final int stock;
  final int sold;
  final int price;
  final String description;
  final String createdAt;
  final String updatedAt;

  const ProductModel({
    required this.id,
    required this.createdById,
    required this.name,
    required this.imageUrl,
    required this.stock,
    required this.sold,
    required this.price,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      createdById: json['createdById'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      stock: json['stock'],
      sold: json['sold'],
      price: json['price'],
      description: json['description'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdById': createdById,
      'name': name,
      'imageUrl': imageUrl,
      'stock': stock,
      'sold': sold,
      'price': price,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      createdById: entity.createdById,
      name: entity.name,
      imageUrl: entity.imageUrl,
      stock: entity.stock,
      sold: entity.sold,
      price: entity.price,
      description: entity.description,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      createdById: createdById,
      name: name,
      imageUrl: imageUrl,
      stock: stock,
      sold: sold,
      price: price,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
