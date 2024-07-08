import 'package:flutter_pos/core/database/app_database.dart';
import 'package:flutter_pos/data/models/product_model.dart';
import 'package:sqflite/sqflite.dart';

class ProductDatasource {
  final AppDatabase _appDatabase;

  ProductDatasource(this._appDatabase);

  Future<int> insertProduct(ProductModel product) async {
    product.id ??= DateTime.now().millisecondsSinceEpoch;
    return await _appDatabase.database.insert(
      AppDatabaseConfig.productTableName,
      product.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateProduct(ProductModel product) async {
    await _appDatabase.database.update(
      AppDatabaseConfig.productTableName,
      product.toJson(),
      where: 'id = ?',
      whereArgs: [product.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteProduct(int id) async {
    await _appDatabase.database.delete(
      AppDatabaseConfig.productTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<ProductModel?> getProduct(int id) async {
    var res = await _appDatabase.database.query(
      AppDatabaseConfig.productTableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (res.isEmpty) {
      return null;
    }

    return ProductModel.fromJson(res.first);
  }

  Future<List<ProductModel>> getAllUserProduct(String id) async {
    var res = await _appDatabase.database.query(
      AppDatabaseConfig.productTableName,
      where: 'createdById = ?',
      whereArgs: [id],
    );

    return res.map((e) => ProductModel.fromJson(e)).toList();
  }
}
