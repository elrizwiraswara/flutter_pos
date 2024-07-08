import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/domain/entities/product_entity.dart';
import 'package:flutter_pos/domain/repositories/product_repository.dart';

class GetAllProductsUsecase extends UseCase<Result, String> {
  GetAllProductsUsecase(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<Result<List<ProductEntity>>> call(String params) async => _productRepository.getAllUserProducts(params);
}

class GetProductUsecase extends UseCase<Result, int> {
  GetProductUsecase(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<Result<ProductEntity>> call(int params) async => _productRepository.getProduct(params);
}

class CreateProductUsecase extends UseCase<Result, ProductEntity> {
  CreateProductUsecase(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<Result<int>> call(ProductEntity params) async => _productRepository.createProduct(params);
}

class UpdateProductUsecase extends UseCase<void, ProductEntity> {
  UpdateProductUsecase(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<void> call(ProductEntity params) async => _productRepository.updateProduct(params);
}

class DeleteProductUsecase extends UseCase<void, int> {
  DeleteProductUsecase(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<void> call(int params) async => _productRepository.deleteProduct(params);
}
