import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_pos/data/datasources/remote/user_remote_datasource_impl.dart';
import 'package:flutter_pos/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserRemoteDatasourceImpl', () {
    // Declare a late variable for the datasource
    late UserRemoteDatasourceImpl datasource;

    setUp(() async {
      final instance = FakeFirebaseFirestore();

      // Initialize the datasource with the Firebase Firestore instance
      datasource = UserRemoteDatasourceImpl(instance);
    });

    // Create a sample user
    final user = UserModel(
      id: "user123",
      name: 'Sample User',
      imageUrl: 'https://example.com/product.jpg',
    );

    // Test: createUser inserts the transaction into the database
    test('createUser inserts transaction into the database', () async {
      // Call the createUser method
      final res = await datasource.createUser(user);

      // Verify that the ID returned matches the transaction's ID
      expect(res, equals(user.id));
    });

    // Test: updateUser updates the transaction in the database
    test('updateUser updates transaction in the database', () async {
      // Call the createUser method
      await datasource.createUser(user);

      final updateUser = datasource.updateUser(user);

      // Expect that the update completes successfully
      expectLater(updateUser, completes);
    });

    // Test: getUser retrieves the transaction from the database
    test('getUser retrieves transaction from the database', () async {
      // Call the createUser method
      await datasource.createUser(user);

      final res = await datasource.getUser(user.id);

      // Verify that the retrieved transaction's ID matches the expected ID
      expect(res?.id, equals(user.id));
    });

    // Test: deleteUser deletes the transaction from the database
    test('deleteUser deletes transaction from the database', () async {
      final deleteUser = datasource.deleteUser(user.id);

      // Expect that the deletion completes successfully
      expectLater(deleteUser, completes);
    });
  });
}
