import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/data/data_sources/local/product_local_datasource_impl.dart';
import 'package:flutter_pos/data/data_sources/remote/product_remote_datasource_impl.dart';
import 'package:flutter_pos/data/models/product_model.dart';
import 'package:flutter_pos/domain/entities/product_entity.dart';
import 'package:flutter_pos/domain/repositories/product_repository.dart';

class ProductRepositoryImpl extends ProductRepository {
  final ProductLocalDatasourceImpl productLocalDatasource;
  final ProductRemoteDatasourceImpl productRemoteDatasource;

  ProductRepositoryImpl({required this.productLocalDatasource, required this.productRemoteDatasource});

  @override
  Future<Result<List<ProductEntity>>> getAllUserProducts(String userId) async {
    var res = await productRemoteDatasource.getAllUserProduct(userId);
    return Result.success(res.map((e) => e.toEntity()).toList());
  }

  @override
  Future<Result<ProductEntity>> getProduct(int productId) async {
    var res = await productRemoteDatasource.getProduct(productId);
    return Result.success(res?.toEntity());
  }

  @override
  Future<Result<int>> createProduct(ProductEntity product) async {
    var productId = await productRemoteDatasource.createProduct(ProductModel.fromEntity(product));
    return Result.success(productId);
  }

  @override
  Future<void> deleteProduct(int productId) async {
    return await productRemoteDatasource.deleteProduct(productId);
  }

  @override
  Future<void> updateProduct(ProductEntity product) async {
    return await productRemoteDatasource.updateProduct(ProductModel.fromEntity(product));
  }
}
