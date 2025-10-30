import 'package:flutter_pos/core/database/app_database.dart';
import 'package:flutter_pos/data/datasources/local/product_local_datasource_impl.dart';
import 'package:flutter_pos/data/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late AppDatabase appDatabase;
  late ProductLocalDatasourceImpl datasource;
  late Database testDatabase;

  setUpAll(() async {
    // Initialize FFI (Foreign Function Interface) for SQFlite
    sqfliteFfiInit();
    // Change the default factory for unit testing calls to use FFI
    databaseFactory = databaseFactoryFfi;

    // Open an in-memory database for testing
    testDatabase = await openDatabase(inMemoryDatabasePath, version: 1);

    appDatabase = AppDatabase.instance;
    await appDatabase.initTestDatabase(testDatabase: testDatabase);

    datasource = ProductLocalDatasourceImpl(appDatabase);
  });

  const userId = "user123";

  ProductModel createSampleProduct({int id = 1}) {
    return ProductModel(
      id: id,
      name: 'Sample Product',
      createdById: userId,
      imageUrl: '',
      price: 42,
      sold: 10,
      stock: 50,
    );
  }

  group('ProductLocalDatasourceImpl', () {
    group('createProduct', () {
      test('should insert product into the database and return product id', () async {
        final product = createSampleProduct();
        final result = await datasource.createProduct(product);

        expect(result.data, equals(product.id));
      });

      test('should create multiple products successfully', () async {
        final product1 = createSampleProduct(id: 1);
        final product2 = createSampleProduct(id: 2);

        final result1 = await datasource.createProduct(product1);
        final result2 = await datasource.createProduct(product2);

        expect(result1.data, equals(1));
        expect(result2.data, equals(2));
      });
    });

    group('updateProduct', () {
      test('should update existing product in the database', () async {
        final product = createSampleProduct();
        await datasource.createProduct(product);

        final updatedProduct = product
          ..name = 'Updated Product'
          ..price = 100;

        await expectLater(
          datasource.updateProduct(updatedProduct),
          completes,
        );

        final retrieved = await datasource.getProduct(product.id);
        expect(retrieved.data?.name, equals('Updated Product'));
        expect(retrieved.data?.price, equals(100));
      });

      test('should complete even if product does not exist', () async {
        final product = createSampleProduct();

        await expectLater(
          datasource.updateProduct(product),
          completes,
        );
      });
    });

    group('getProduct', () {
      test('should retrieve existing product from the database', () async {
        final product = createSampleProduct();
        await datasource.createProduct(product);

        final result = await datasource.getProduct(product.id);

        expect(result, isNotNull);
        expect(result.data?.id, equals(product.id));
        expect(result.data?.name, equals(product.name));
        expect(result.data?.price, equals(product.price));
      });

      test('should return null when product does not exist', () async {
        final result = await datasource.getProduct(999);

        expect(result.data, isNull);
      });
    });

    group('getAllUserProducts', () {
      test('should retrieve all products for a given user', () async {
        final product1 = createSampleProduct(id: 1);
        final product2 = createSampleProduct(id: 2);

        await datasource.createProduct(product1);
        await datasource.createProduct(product2);

        final result = await datasource.getAllUserProducts(userId);

        expect(result.data, isNotEmpty);
        expect(result.data?.length, equals(2));
        expect(result.data?.any((p) => p.id == 1), isTrue);
        expect(result.data?.any((p) => p.id == 2), isTrue);
      });

      test('should return empty list when user has no products', () async {
        final result = await datasource.getAllUserProducts('nonexistent_user');

        expect(result.data, isEmpty);
      });

      test('should not return products from other users', () async {
        final product = createSampleProduct();
        await datasource.createProduct(product);

        final result = await datasource.getAllUserProducts('different_user');

        expect(result.data, isEmpty);
      });
    });

    group('deleteProduct', () {
      test('should delete existing product from the database', () async {
        final product = createSampleProduct();
        await datasource.createProduct(product);

        await expectLater(
          datasource.deleteProduct(product.id),
          completes,
        );

        final retrieved = await datasource.getProduct(product.id);
        expect(retrieved.data, isNull);
      });

      test('should complete even if product does not exist', () async {
        await expectLater(
          datasource.deleteProduct(999),
          completes,
        );
      });
    });
  });
}
