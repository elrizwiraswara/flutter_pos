import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_pos/data/datasources/remote/product_remote_datasource_impl.dart';
import 'package:flutter_pos/data/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductRemoteDatasourceImpl', () {
    // Declare a late variable for the datasource
    late ProductRemoteDatasourceImpl datasource;

    setUp(() async {
      final instance = FakeFirebaseFirestore();

      // Initialize the datasource with the Firebase Firestore instance
      datasource = ProductRemoteDatasourceImpl(instance);
    });

    // Create a sample userId
    const userId = "user123";

    // Create a sample product
    final product = ProductModel(
      id: 1,
      name: 'Sample Product',
      createdById: userId,
      imageUrl: '',
      price: 42,
      sold: 10,
      stock: 50,
    );

    // Test: createProduct inserts the product into the database
    test('createProduct inserts product into the database', () async {
      // Call the createProduct method
      final res = await datasource.createProduct(product);

      // Verify that the ID returned matches the product's ID
      expect(res, equals(product.id));
    });

    // Test: updateProduct updates the product in the database
    test('updateProduct updates product in the database', () async {
      final updateProduct = datasource.updateProduct(product);

      // Expect that the update completes successfully
      expectLater(updateProduct, completes);
    });

    // Test: getProduct retrieves the product from the database
    test('getProduct retrieves product from the database', () async {
      // Call the createProduct method
      await datasource.createProduct(product);

      final res = await datasource.getProduct(product.id);

      // Verify that the retrieved product's ID matches the expected ID
      expect(res?.id, equals(product.id));
    });

    // Test: getAllUserProducts retrieves all products for a given user
    test('getAllUserProducts retrieves all user products from the database', () async {
      // Call the createProduct method
      await datasource.createProduct(product);

      final res = await datasource.getAllUserProducts(userId);

      // Expect that the result is not empty
      expect(res, isNotEmpty);
    });

    // Test: deleteProduct deletes the product from the database
    test('deleteProduct deletes product from the database', () async {
      final deleteProduct = datasource.deleteProduct(product.id);

      // Expect that the deletion completes successfully
      expectLater(deleteProduct, completes);
    });
  });
}
