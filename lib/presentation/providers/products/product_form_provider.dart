import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../app/utilities/console_logger.dart';
import '../../../core/common/result.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../domain/repositories/storage_repository.dart';
import '../../../domain/usecases/product_usecases.dart';
import '../../../domain/usecases/storage_usecases.dart';
import '../../../service_locator.dart';
import '../auth/auth_provider.dart';
import 'products_provider.dart';

class ProductFormProvider extends ChangeNotifier {
  final AuthProvider authProvider;
  final ProductRepository productRepository;
  final StorageRepository storageRepository;

  ProductFormProvider({
    required this.authProvider,
    required this.productRepository,
    required this.storageRepository,
  });

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
      throw res.error ?? 'Failed to load data';
    }
  }

  Future<Result<int>> createProduct() async {
    try {
      var userId = authProvider.user?.id;
      if (userId == null) throw 'Unathenticated!';

      if (imageFile != null) {
        final res = await UploadProductImageUsecase(storageRepository).call(imageFile!.path);
        imageUrl = res.data;
      }

      cl('[createProduct].imageUrl $imageUrl');

      var product = ProductEntity(
        createdById: userId,
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
      return Result.failure(error: e);
    }
  }

  Future<Result<void>> updatedProduct(int id) async {
    try {
      var userId = authProvider.user?.id;
      if (userId == null) throw 'Unathenticated!';

      if (imageFile != null) {
        final res = await UploadProductImageUsecase(storageRepository).call(imageFile!.path);
        imageUrl = res.data;
      }

      cl('[updatedProduct].imageUrl $imageUrl');

      var product = ProductEntity(
        id: id,
        createdById: userId,
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
      return Result.failure(error: e);
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
      return Result.failure(error: e);
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
      name?.isNotEmpty,
      (price ?? 0) > 0,
      (stock ?? 0) > 0,
    ];

    return !validator.contains(false);
  }
}
