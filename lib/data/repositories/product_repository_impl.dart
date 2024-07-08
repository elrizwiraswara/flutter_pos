import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/data/data_sources/local/product_datasource.dart';
import 'package:flutter_pos/data/models/product_model.dart';
import 'package:flutter_pos/domain/entities/product_entity.dart';
import 'package:flutter_pos/domain/repositories/product_repository.dart';

class ProductRepositoryImpl extends ProductRepository {
  final ProductDatasource _productDatasource;

  ProductRepositoryImpl(this._productDatasource);

  @override
  Future<Result<List<ProductEntity>>> getAllUserProducts(String userId) async {
    var res = await _productDatasource.getAllUserProduct(userId);
    return Result.success(res.map((e) => e.toEntity()).toList());
  }

  @override
  Future<Result<ProductEntity>> getProduct(int productId) async {
    var res = await _productDatasource.getProduct(productId);
    return Result.success(res?.toEntity());
  }

  @override
  Future<Result<int>> createProduct(ProductEntity product) async {
    var productId = await _productDatasource.insertProduct(ProductModel.fromEntity(product));
    return Result.success(productId);
  }

  @override
  Future<void> deleteProduct(int productId) async {
    return await _productDatasource.deleteProduct(productId);
  }

  @override
  Future<void> updateProduct(ProductEntity product) async {
    return await _productDatasource.updateProduct(ProductModel.fromEntity(product));
  }
}
