import 'package:flutter_pos/app/database/app_database.dart';
import 'package:flutter_pos/data/datasources/local/queued_action_local_datasource_impl.dart';
import 'package:flutter_pos/data/models/queued_action_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('QueuedActionLocalDatasourceImpl', () {
    // Create an instance of the AppDatabase
    AppDatabase appDatabase = AppDatabase();

    // Declare a late variable for the datasource
    late QueuedActionLocalDatasourceImpl datasource;

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
      datasource = QueuedActionLocalDatasourceImpl(appDatabase);
    });

    // Create a sample queued action
    final queuedAction = QueuedActionModel(
      id: 1,
      isCritical: true,
      method: '',
      repository: '',
      param: '',
      createdAt: '',
    );

    // Test: createQueuedAction inserts the queued action into the database
    test('createQueuedAction inserts queued action into the database', () async {
      // Call the createQueuedAction method
      final res = await datasource.createQueuedAction(queuedAction);

      // Verify that the ID returned matches the queued action's ID
      expect(res, equals(queuedAction.id));
    });

    // Test: getQueuedAction retrieves the queued action from the database
    test('getQueuedAction retrieves queued action from the database', () async {
      final res = await datasource.getQueuedAction(queuedAction.id);

      // Verify that the retrieved queued action's ID matches the expected ID
      expect(res?.id, equals(queuedAction.id));
    });

    // Test: getAllUserQueuedAction retrieves all queued actions for a given user
    test('getAllUserQueuedAction retrieves all queued action from the database', () async {
      final res = await datasource.getAllUserQueuedAction();

      // Expect that the result is not empty
      expect(res, isNotEmpty);
    });

    // Test: deleteQueuedAction deletes the queued action from the database
    test('deleteQueuedAction deletes queued action from the database', () async {
      final deleteQueuedAction = datasource.deleteQueuedAction(queuedAction.id);

      // Expect that the deletion completes successfully
      expectLater(deleteQueuedAction, completes);
    });
  });
}
