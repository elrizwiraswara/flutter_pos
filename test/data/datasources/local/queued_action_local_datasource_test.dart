import 'package:flutter_pos/core/database/app_database.dart';
import 'package:flutter_pos/data/datasources/local/queued_action_local_datasource_impl.dart';
import 'package:flutter_pos/data/models/queued_action_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late AppDatabase appDatabase;
  late QueuedActionLocalDatasourceImpl datasource;
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

    datasource = QueuedActionLocalDatasourceImpl(appDatabase);
  });

  final queuedAction = QueuedActionModel(
    id: 1,
    isCritical: true,
    method: '',
    repository: '',
    param: '',
    createdAt: '',
  );

  group('QueuedActionLocalDatasourceImpl', () {
    // Test: createQueuedAction inserts the queued action into the database
    test('createQueuedAction inserts queued action into the database', () async {
      // Call the createQueuedAction method
      final res = await datasource.createQueuedAction(queuedAction);

      // Verify that the ID returned matches the queued action's ID
      expect(res.data, equals(queuedAction.id));
    });

    // Test: getQueuedAction retrieves the queued action from the database
    test('getQueuedAction retrieves queued action from the database', () async {
      final res = await datasource.getQueuedAction(queuedAction.id);

      // Verify that the retrieved queued action's ID matches the expected ID
      expect(res.data?.id, equals(queuedAction.id));
    });

    // Test: getAllUserQueuedAction retrieves all queued actions for a given user
    test('getAllUserQueuedAction retrieves all queued action from the database', () async {
      final res = await datasource.getAllUserQueuedAction();

      // Expect that the result is not empty
      expect(res.data, isNotEmpty);
    });

    // Test: deleteQueuedAction deletes the queued action from the database
    test('deleteQueuedAction deletes queued action from the database', () async {
      final deleteQueuedAction = await datasource.deleteQueuedAction(queuedAction.id);

      // Expect that the deletion completes successfully
      expect(deleteQueuedAction.isSuccess, true);
    });
  });
}
