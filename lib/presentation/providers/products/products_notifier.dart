import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../domain/usecases/params/base_params.dart';
import '../../../domain/usecases/product_usecases.dart';
import '../auth/auth_notifier.dart';
import 'products_state.dart';

final productsNotifierProvider = NotifierProvider<ProductsNotifier, ProductsState>(
  ProductsNotifier.new,
);

class ProductsNotifier extends Notifier<ProductsState> {
  @override
  ProductsState build() {
    return const ProductsState();
  }

  String _requireUserId() {
    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated) return authState.user!.id;
    throw 'Unauthenticated!';
  }

  void resetProducts() {
    state = const ProductsState();
  }

  Future<void> getAllProducts({int? offset, String? contains}) async {
    final userId = _requireUserId();

    if (offset != null) {
      state = state.copyWith(isLoadingMore: true);
    }

    var params = BaseParams(
      param: userId,
      offset: offset,
      contains: contains,
    );

    final productRepository = ref.read(productRepositoryProvider);
    var res = await GetUserProductsUsecase(productRepository).call(params);

    if (res.isSuccess) {
      if (offset == null) {
        state = state.copyWith(allProducts: res.data ?? [], isLoadingMore: false);
      } else {
        final current = state.allProducts ?? [];
        state = state.copyWith(
          allProducts: [...current, ...res.data ?? []],
          isLoadingMore: false,
        );
      }
    } else {
      state = state.copyWith(isLoadingMore: false);
      throw Exception(res.error?.toString() ?? 'Failed to load data');
    }
  }
}
