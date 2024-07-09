import 'package:flutter/foundation.dart';

import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../domain/usecases/product_usecases.dart';

class ProductDetailProvider extends ChangeNotifier {
  final ProductRepository productRepository;

  ProductDetailProvider({required this.productRepository});

  Future<ProductEntity?> getProductDetail(int id) async {
    var res = await GetProductUsecase(productRepository).call(id);

    if (res.isSuccess) {
      return res.data;
    } else {
      throw res.error ?? 'Failed to load data';
    }
  }
}
