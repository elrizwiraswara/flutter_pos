import 'package:flutter_pos/app/database/app_database.dart';
import 'package:flutter_pos/data/datasources/local/user_local_datasource_impl.dart';
import 'package:flutter_pos/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('UserLocalDatasourceImpl', () {
    // Create an instance of the AppDatabase
    AppDatabase appDatabase = AppDatabase();

    // Declare a late variable for the datasource
    late UserLocalDatasourceImpl datasource;

    setUp(() async {
      // Initialize FFI (Foreign Function Interface) for SQFlite
      sqfliteFfiInit();
      // Change the default factory for unit testing calls to use FFI
      databaseFactory = databaseFactoryFfi;

      // Open an in-memory database for testing
      var testDatabase = await openDatabase(inMemoryDatabasePath, version: 1);

      // Initialize the AppDatabase with the test database
      await appDatabase.initTestDatabase(testDatabase: testDatabase);

      // Initialize the datasource with the AppDatabase
      datasource = UserLocalDatasourceImpl(appDatabase);
    });

    // Create a sample user
    final user = UserModel(
      id: "user123",
      name: 'Sample User',
      imageUrl: '',
    );

    // Test: createUser inserts the user into the database
    test('createUser inserts user into the database', () async {
      // Call the createUser method
      final res = await datasource.createUser(user);

      // Verify that the ID returned matches the user's ID
      expect(res, equals(user.id));
    });

    // Test: updateUser updates the user in the database
    test('updateUser updates user in the database', () async {
      final updateUser = datasource.updateUser(user);

      // Expect that the update completes successfully
      expectLater(updateUser, completes);
    });

    // Test: getUser retrieves the user from the database
    test('getUser retrieves user from the database', () async {
      final res = await datasource.getUser(user.id);

      // Verify that the retrieved user's ID matches the expected ID
      expect(res?.id, equals(user.id));
    });

    // Test: deleteUser deletes the user from the database
    test('deleteUser deletes user from the database', () async {
      final deleteUser = datasource.deleteUser(user.id);

      // Expect that the deletion completes successfully
      expectLater(deleteUser, completes);
    });
  });
}
