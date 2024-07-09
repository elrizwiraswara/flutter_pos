import 'package:flutter/foundation.dart';
import '../../../app/services/auth/auth_service.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../domain/usecases/product_usecases.dart';

class ProductsProvider extends ChangeNotifier {
  final ProductRepository productRepository;

  ProductsProvider({required this.productRepository});

  List<ProductEntity>? allProducts;

  Future<void> getAllProducts() async {
    var res = await GetAllProductsUsecase(productRepository).call(AuthService().getAuthData()!.uid);

    if (res.isSuccess) {
      allProducts = res.data ?? [];
      notifyListeners();
    } else {
      throw res.error?.error ?? 'Failed to load data';
    }
  }
}
