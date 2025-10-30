import 'package:flutter/foundation.dart';

import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../domain/usecases/params/base_params.dart';
import '../../../domain/usecases/product_usecases.dart';
import '../auth/auth_provider.dart';

class ProductsProvider extends ChangeNotifier {
  final AuthProvider authProvider;
  final ProductRepository productRepository;

  ProductsProvider({
    required this.authProvider,
    required this.productRepository,
  });

  List<ProductEntity>? allProducts;

  bool isLoadingMore = false;

  Future<void> getAllProducts({int? offset, String? contains}) async {
    var userId = authProvider.user?.id;
    if (userId == null) throw 'Unathenticated!';

    if (offset != null) {
      isLoadingMore = true;
      notifyListeners();
    }

    var params = BaseParams(
      param: userId,
      offset: offset,
      contains: contains,
    );

    var res = await GetUserProductsUsecase(productRepository).call(params);

    if (res.isSuccess) {
      if (offset == null) {
        allProducts = res.data ?? [];
      } else {
        allProducts?.addAll(res.data ?? []);
      }

      isLoadingMore = false;
      notifyListeners();
    } else {
      throw Exception(res.error?.toString() ?? 'Failed to load data');
    }
  }
}
