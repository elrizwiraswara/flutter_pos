import 'package:sqflite/sqflite.dart';

import '../../../app/database/app_database.dart';
import '../../../app/database/app_database_config.dart';
import '../../../core/common/result.dart';
import '../../models/product_model.dart';
import '../interfaces/product_datasource.dart';

class ProductLocalDatasourceImpl extends ProductDatasource {
  final AppDatabase _appDatabase;

  ProductLocalDatasourceImpl(this._appDatabase);

  @override
  Future<Result<int>> createProduct(ProductModel product) async {
    try {
      await _appDatabase.database.insert(
        AppDatabaseConfig.productTableName,
        product.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // The id has been generated in models
      return Result.success(data: product.id);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateProduct(ProductModel product) async {
    try {
      await _appDatabase.database.update(
        AppDatabaseConfig.productTableName,
        product.toJson(),
        where: 'id = ?',
        whereArgs: [product.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteProduct(int id) async {
    try {
      await _appDatabase.database.delete(
        AppDatabaseConfig.productTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<ProductModel?>> getProduct(int id) async {
    try {
      var res = await _appDatabase.database.query(
        AppDatabaseConfig.productTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (res.isEmpty) return Result.success(data: null);

      return Result.success(data: ProductModel.fromJson(res.first));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ProductModel>>> getAllUserProducts(String userId) async {
    try {
      var res = await _appDatabase.database.query(
        AppDatabaseConfig.productTableName,
        where: 'createdById = ?',
        whereArgs: [userId],
      );

      return Result.success(
        data: res.map((e) => ProductModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ProductModel>>> getUserProducts(
    String userId, {
    String orderBy = 'createdAt',
    String sortBy = 'DESC',
    int limit = 10,
    int? offset,
    String? contains,
  }) async {
    try {
      var res = await _appDatabase.database.query(
        AppDatabaseConfig.productTableName,
        where: 'createdById = ? AND name LIKE ?',
        whereArgs: [userId, "%${contains ?? ''}%"],
        orderBy: '$orderBy $sortBy',
        limit: limit,
        offset: offset,
      );

      return Result.success(
        data: res.map((e) => ProductModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
