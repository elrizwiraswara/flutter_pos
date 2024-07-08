import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_pos/app/services/auth/auth_service.dart';
import 'package:flutter_pos/app/services/firebase_storage/firebase_storage_service.dart';
import 'package:flutter_pos/app/utilities/console_log.dart';
import 'package:flutter_pos/domain/entities/product_entity.dart';
import 'package:flutter_pos/domain/repositories/product_repository.dart';
import 'package:flutter_pos/domain/usecases/product_usecases.dart';
import 'package:flutter_pos/presentation/providers/products/products_provider.dart';
import 'package:flutter_pos/service_locator.dart';

class ProductFormProvider extends ChangeNotifier {
  final ProductRepository productRepository;

  ProductFormProvider({required this.productRepository});

  File? imageFile;
  String? imageUrl;
  String? name;
  int? price;
  int? stock;
  String? description;

  void clearStates() {
    imageFile = null;
    imageUrl = null;
    name = null;
    price = null;
    stock = null;
    description = null;
  }

  Future<void> getProductDetail(int id) async {
    var res = await GetProductUsecase(productRepository).call(id);

    if (res.isSuccess) {
      var product = res.data;

      imageUrl = product?.imageUrl;
      name = product?.name;
      price = product?.price;
      stock = product?.stock;
      description = product?.description;

      notifyListeners();
    } else {
      throw res.error?.error ?? 'Failed to load data';
    }
  }

  Future<String?> createProduct() async {
    try {
      if (imageFile != null) {
        imageUrl = await FirebaseStorageService().uploadProductImage(imageFile!.path);
      }

      cl('[createProduct].imageUrl $imageUrl');

      var product = ProductEntity(
        createdById: AuthService().getAuthData()!.uid,
        name: name!,
        imageUrl: imageUrl ?? '',
        stock: stock ?? 0,
        sold: 0,
        price: price ?? 0,
        description: description ?? '',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      await CreateProductUsecase(productRepository).call(product);

      // Refresh products
      sl<ProductsProvider>().getAllProducts();

      return null;
    } catch (e) {
      cl("[createProduct].error $e");
      return e.toString();
    }
  }

  Future<String?> updatedProduct(int id) async {
    try {
      if (imageFile != null) {
        imageUrl = await FirebaseStorageService().uploadProductImage(imageFile!.path);
      }

      cl('[updatedProduct].imageUrl $imageUrl');

      var product = ProductEntity(
        id: id,
        createdById: AuthService().getAuthData()!.uid,
        name: name!,
        imageUrl: imageUrl ?? '',
        stock: stock ?? 0,
        sold: 0,
        price: price ?? 0,
        description: description ?? '',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      await UpdateProductUsecase(productRepository).call(product);

      // Refresh products
      sl<ProductsProvider>().getAllProducts();

      return null;
    } catch (e) {
      cl("[updatedProduct].error $e");
      return e.toString();
    }
  }

  void onChangedImage(File value) {
    imageFile = value;
    notifyListeners();
  }

  void onChangedName(String value) {
    name = value;
    notifyListeners();
  }

  void onChangedPrice(String value) {
    price = int.tryParse(value);
    notifyListeners();
  }

  void onChangedStock(String value) {
    stock = int.tryParse(value);
    notifyListeners();
  }

  void onChangedDesc(String value) {
    description = value;
    notifyListeners();
  }
}
