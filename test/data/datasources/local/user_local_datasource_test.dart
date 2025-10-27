import 'package:flutter_pos/app/database/app_database.dart';
import 'package:flutter_pos/data/datasources/local/user_local_datasource_impl.dart';
import 'package:flutter_pos/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late AppDatabase appDatabase;
  late UserLocalDatasourceImpl datasource;
  late Database testDatabase;

  setUpAll(() async {
    // Initialize FFI for SQFlite
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Open an in-memory database for testing
    testDatabase = await openDatabase(inMemoryDatabasePath, version: 1);

    appDatabase = AppDatabase.instance;
    await appDatabase.initTestDatabase(testDatabase: testDatabase);

    datasource = UserLocalDatasourceImpl(appDatabase);
  });

  UserModel createSampleUser({
    String id = 'user123',
    String name = 'Sample User',
    String imageUrl = '',
  }) {
    return UserModel(
      id: id,
      name: name,
      imageUrl: imageUrl,
    );
  }

  group('UserLocalDatasourceImpl', () {
    group('createUser', () {
      test('should insert user into the database and return user id', () async {
        final user = createSampleUser();

        final result = await datasource.createUser(user);

        expect(result.data, equals(user.id));
      });

      test('should create multiple users successfully', () async {
        final user1 = createSampleUser(id: 'user1');
        final user2 = createSampleUser(id: 'user2');

        final result1 = await datasource.createUser(user1);
        final result2 = await datasource.createUser(user2);

        expect(result1.data, equals('user1'));
        expect(result2.data, equals('user2'));
      });

      test('should store user with all fields correctly', () async {
        final user = createSampleUser(
          id: 'user123',
          name: 'John Doe',
          imageUrl: 'https://example.com/image.jpg',
        );

        await datasource.createUser(user);
        final retrieved = await datasource.getUser(user.id);

        expect(retrieved.data?.name, equals('John Doe'));
        expect(retrieved.data?.imageUrl, equals('https://example.com/image.jpg'));
      });
    });

    group('updateUser', () {
      test('should update existing user in the database', () async {
        final user = createSampleUser();
        await datasource.createUser(user);

        final updatedUser = createSampleUser(
          id: user.id,
          name: 'Updated User',
          imageUrl: 'https://example.com/new-image.jpg',
        );

        await expectLater(
          datasource.updateUser(updatedUser),
          completes,
        );

        final retrieved = await datasource.getUser(user.id);
        expect(retrieved.data?.name, equals('Updated User'));
        expect(retrieved.data?.imageUrl, equals('https://example.com/new-image.jpg'));
      });

      test('should complete even if user does not exist', () async {
        final user = createSampleUser();

        await expectLater(
          datasource.updateUser(user),
          completes,
        );
      });

      test('should update only specific fields', () async {
        final user = createSampleUser(name: 'Original Name');
        await datasource.createUser(user);

        final updatedUser = createSampleUser(
          id: user.id,
          name: 'New Name',
          imageUrl: user.imageUrl ?? '',
        );

        await datasource.updateUser(updatedUser);
        final retrieved = await datasource.getUser(user.id);

        expect(retrieved.data?.name, equals('New Name'));
        expect(retrieved.data?.id, equals(user.id));
      });
    });

    group('getUser', () {
      test('should retrieve existing user from the database', () async {
        final user = createSampleUser();
        await datasource.createUser(user);

        final result = await datasource.getUser(user.id);

        expect(result.data, isNotNull);
        expect(result.data?.id, equals(user.id));
        expect(result.data?.name, equals(user.name));
        expect(result.data?.imageUrl, equals(user.imageUrl));
      });

      test('should return null when user does not exist', () async {
        final result = await datasource.getUser('nonexistent_user');

        expect(result.data, isNull);
      });

      test('should retrieve correct user among multiple users', () async {
        final user1 = createSampleUser(id: 'user1', name: 'User One');
        final user2 = createSampleUser(id: 'user2', name: 'User Two');

        await datasource.createUser(user1);
        await datasource.createUser(user2);

        final result = await datasource.getUser('user2');

        expect(result.data?.id, equals('user2'));
        expect(result.data?.name, equals('User Two'));
      });
    });

    group('deleteUser', () {
      test('should delete existing user from the database', () async {
        final user = createSampleUser();
        await datasource.createUser(user);

        await expectLater(
          datasource.deleteUser(user.id),
          completes,
        );

        final retrieved = await datasource.getUser(user.id);
        expect(retrieved.data, isNull);
      });

      test('should complete even if user does not exist', () async {
        await expectLater(
          datasource.deleteUser('nonexistent_user'),
          completes,
        );
      });

      test('should only delete specified user', () async {
        final user1 = createSampleUser(id: 'user1');
        final user2 = createSampleUser(id: 'user2');

        await datasource.createUser(user1);
        await datasource.createUser(user2);

        await datasource.deleteUser('user1');

        final retrieved1 = await datasource.getUser('user1');
        final retrieved2 = await datasource.getUser('user2');

        expect(retrieved1.data, isNull);
        expect(retrieved2.data, isNotNull);
        expect(retrieved2.data?.id, equals('user2'));
      });
    });
  });
}
