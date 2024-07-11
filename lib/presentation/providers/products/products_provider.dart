import 'package:flutter/foundation.dart';
import 'package:flutter_pos/domain/usecases/params/base_params.dart';

import '../../../app/services/auth/auth_service.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../domain/usecases/product_usecases.dart';

class ProductsProvider extends ChangeNotifier {
  final ProductRepository productRepository;

  ProductsProvider({required this.productRepository});

  List<ProductEntity>? allProducts;

  Future<void> getAllProducts({int? offset}) async {
    var params = BaseParams(
      param: AuthService().getAuthData()!.uid,
      offset: offset,
    );

    var res = await GetUserProductsUsecase(productRepository).call(params);

    if (res.isSuccess) {
      allProducts = res.data ?? [];
      notifyListeners();
    } else {
      throw res.error?.message ?? 'Failed to load data';
    }
  }
}
