import 'package:flutter_pos/domain/entities/product_entity.dart';
import 'package:flutter_pos/domain/entities/user_entity.dart';
import 'package:flutter_pos/presentation/widgets/app_image.dart';

var productDummy = ProductEntity(
  id: 1,
  name: "Product Name" * 4,
  imageUrl: randomImage,
  sold: 100,
  stock: 100,
  price: 100,
  description: "asdasd",
  createdById: "1",
  createdAt: DateTime.now().toIso8601String(),
  updatedAt: DateTime.now().toIso8601String(),
);

var userDummy = UserEntity(
  id: "1",
  name: "User name",
  imageUrl: randomImage,
  birthdate: DateTime.now().toIso8601String(),
  gender: "male",
  phone: "123123",
  createdAt: DateTime.now().toIso8601String(),
  updatedAt: DateTime.now().toIso8601String(),
);
