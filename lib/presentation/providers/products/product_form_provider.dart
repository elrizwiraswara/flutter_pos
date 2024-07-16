import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../app/services/auth/auth_service.dart';
import '../../../app/services/firebase_storage/firebase_storage_service.dart';
import '../../../app/utilities/console_log.dart';
import '../../../core/errors/errors.dart';
import '../../../core/usecase/usecase.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../domain/usecases/product_usecases.dart';
import '../../../service_locator.dart';
import 'products_provider.dart';

class ProductFormProvider extends ChangeNotifier {
  final ProductRepository productRepository;

  ProductFormProvider({required this.productRepository});

  File? imageFile;
  String? imageUrl;
  String? name;
  int? price;
  int? stock;
  String? description;

  bool isLoaded = false;

  void resetStates() {
    imageFile = null;
    imageUrl = null;
    name = null;
    price = null;
    stock = null;
    description = null;
    isLoaded = false;
  }

  Future<void> initProductForm(int? productId) async {
    if (productId == null) {
      isLoaded = true;
      notifyListeners();
      return;
    }

    var res = await GetProductUsecase(productRepository).call(productId);

    if (res.isSuccess) {
      var product = res.data;

      imageUrl = product?.imageUrl;
      name = product?.name;
      price = product?.price;
      stock = product?.stock;
      description = product?.description;

      isLoaded = true;
      notifyListeners();
    } else {
      throw res.error?.message ?? 'Failed to load data';
    }
  }

  Future<Result<int>> createProduct() async {
    try {
      if (imageFile != null) {
        imageUrl = await FirebaseStorageService().uploadProductImage(imageFile!.path);
      }

      cl('[createProduct].imageUrl $imageUrl');

      var product = ProductEntity(
        createdById: AuthService().getAuthData()!.uid,
        name: name ?? '',
        imageUrl: imageUrl ?? '',
        stock: stock ?? 0,
        price: price ?? 0,
        description: description ?? '',
      );

      var res = await CreateProductUsecase(productRepository).call(product);

      // Refresh products
      sl<ProductsProvider>().getAllProducts();

      return res;
    } catch (e) {
      cl("[createProduct].error $e");
      return Result.error(UnknownError(message: e.toString()));
    }
  }

  Future<Result<void>> updatedProduct(int id) async {
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
        price: price ?? 0,
        description: description ?? '',
      );

      var res = await UpdateProductUsecase(productRepository).call(product);

      // Refresh products
      sl<ProductsProvider>().getAllProducts();

      return res;
    } catch (e) {
      cl("[updatedProduct].error $e");
      return Result.error(UnknownError(message: e.toString()));
    }
  }

  Future<Result<void>> deleteProduct(int id) async {
    try {
      var res = await DeleteProductUsecase(productRepository).call(id);

      // Refresh products
      sl<ProductsProvider>().getAllProducts();

      return res;
    } catch (e) {
      cl("[deleteProduct].error $e");
      return Result.error(UnknownError(message: e.toString()));
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

  bool isFormValid() {
    List validator = [
      AuthService().getAuthData()?.uid != null,
      name?.isNotEmpty,
      (price ?? 0) > 0,
      (stock ?? 0) > 0,
    ];

    return !validator.contains(false);
  }
}
