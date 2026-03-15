import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/usecases/product_usecases.dart';

final productDetailNotifierProvider = NotifierProvider.autoDispose<ProductDetailNotifier, ProductEntity?>(
  ProductDetailNotifier.new,
);

class ProductDetailNotifier extends AutoDisposeNotifier<ProductEntity?> {
  @override
  ProductEntity? build() {
    return null;
  }

  Future<ProductEntity?> getProductDetail(int id) async {
    final productRepository = ref.read(productRepositoryProvider);
    var res = await GetProductUsecase(productRepository).call(id);

    if (res.isSuccess) {
      state = res.data;
      return res.data;
    } else {
      throw res.error ?? 'Failed to load data';
    }
  }
}
