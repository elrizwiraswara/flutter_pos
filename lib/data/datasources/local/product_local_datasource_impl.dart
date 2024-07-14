import 'package:sqflite/sqflite.dart';

import '../../../app/database/app_database.dart';
import '../../models/product_model.dart';
import '../interfaces/product_datasource.dart';

class ProductLocalDatasourceImpl extends ProductDatasource {
  final AppDatabase _appDatabase;

  ProductLocalDatasourceImpl(this._appDatabase);

  @override
  Future<int> createProduct(ProductModel product) async {
    await _appDatabase.database.insert(
      AppDatabaseConfig.productTableName,
      product.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // The id has been generated in models
    return product.id;
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await _appDatabase.database.update(
      AppDatabaseConfig.productTableName,
      product.toJson(),
      where: 'id = ?',
      whereArgs: [product.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteProduct(int id) async {
    await _appDatabase.database.delete(
      AppDatabaseConfig.productTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<ProductModel?> getProduct(int id) async {
    var res = await _appDatabase.database.query(
      AppDatabaseConfig.productTableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (res.isEmpty) return null;

    return ProductModel.fromJson(res.first);
  }

  @override
  Future<List<ProductModel>> getAllUserProducts(String userId) async {
    var res = await _appDatabase.database.query(
      AppDatabaseConfig.productTableName,
      where: 'createdById = ?',
      whereArgs: [userId],
    );

    return res.map((e) => ProductModel.fromJson(e)).toList();
  }

  @override
  Future<List<ProductModel>> getUserProducts(
    String userId, {
    String orderBy = 'createdAt',
    String sortBy = 'DESC',
    int limit = 10,
    int? offset,
    String? contains,
  }) async {
    var res = await _appDatabase.database.query(
      AppDatabaseConfig.productTableName,
      where: 'createdById = ? AND name LIKE ?',
      whereArgs: [userId, "%${contains ?? ''}%"],
      orderBy: '$orderBy $sortBy',
      limit: limit,
      offset: offset,
    );

    return res.map((e) => ProductModel.fromJson(e)).toList();
  }
}
