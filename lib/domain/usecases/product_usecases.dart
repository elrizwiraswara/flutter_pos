import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/domain/entities/product_entity.dart';
import 'package:flutter_pos/domain/repositories/product_repository.dart';

class GetAllProducts extends UseCase<Result, String> {
  GetAllProducts(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<Result<List<ProductEntity>>> call(String params) async => _productRepository.getAllProducts(params);
}

class CreateProduct extends UseCase<Result, ProductEntity> {
  CreateProduct(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<Result<ProductEntity>> call(ProductEntity params) async => _productRepository.createProduct(params);
}

class GetProduct extends UseCase<Result, int> {
  GetProduct(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<Result<ProductEntity>> call(int params) async => _productRepository.getProduct(params);
}

class UpateProduct extends UseCase<void, ProductEntity> {
  UpateProduct(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<void> call(ProductEntity params) async => _productRepository.updateProduct(params);
}

class DeleteProduct extends UseCase<void, ProductEntity> {
  DeleteProduct(this._productRepository);

  final ProductRepository _productRepository;

  @override
  Future<void> call(ProductEntity params) async => _productRepository.deleteProduct(params);
}
