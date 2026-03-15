import '../../../domain/entities/product_entity.dart';

class ProductsState {
  final List<ProductEntity>? allProducts;
  final bool isLoadingMore;

  const ProductsState({this.allProducts, this.isLoadingMore = false});

  ProductsState copyWith({
    List<ProductEntity>? allProducts,
    bool? isLoadingMore,
  }) {
    return ProductsState(
      allProducts: allProducts ?? this.allProducts,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
