import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';
import 'params/base_params.dart';

class SyncAllUserProductsUsecase extends Usecase<Result, String> {
  SyncAllUserProductsUsecase(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<Result<int>> call(String params) async => _productRepository.syncAllUserProducts(params);
}

class GetUserProductsUsecase extends Usecase<Result, BaseParams> {
  GetUserProductsUsecase(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<Result<List<ProductEntity>>> call(BaseParams params) async => _productRepository.getUserProducts(
    params.param,
    orderBy: params.orderBy,
    sortBy: params.sortBy,
    limit: params.limit,
    offset: params.offset,
    contains: params.contains,
  );
}

class GetProductUsecase extends Usecase<Result, int> {
  GetProductUsecase(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<Result<ProductEntity?>> call(int params) async => _productRepository.getProduct(params);
}

class CreateProductUsecase extends Usecase<Result, ProductEntity> {
  CreateProductUsecase(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<Result<int>> call(ProductEntity params) async => _productRepository.createProduct(params);
}

class UpdateProductUsecase extends Usecase<Result<void>, ProductEntity> {
  UpdateProductUsecase(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<Result<void>> call(ProductEntity params) async => _productRepository.updateProduct(params);
}

class DeleteProductUsecase extends Usecase<Result<void>, int> {
  DeleteProductUsecase(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<Result<void>> call(int params) async => _productRepository.deleteProduct(params);
}
