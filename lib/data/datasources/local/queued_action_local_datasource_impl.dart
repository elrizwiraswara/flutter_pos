import 'package:sqflite/sqflite.dart';

import '../../../app/database/app_database.dart';
import '../../models/queued_action_model.dart';
import '../interfaces/queued_action_datasource.dart';

class QueuedActionLocalDatasourceImpl extends QueuedActionDatasource {
  final AppDatabase _appDatabase;

  QueuedActionLocalDatasourceImpl(this._appDatabase);

  @override
  Future<int> createQueuedAction(QueuedActionModel queue) async {
    await _appDatabase.database.insert(
      AppDatabaseConfig.queuedActionTableName,
      queue.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // The id has been generated in models
    return queue.id;
  }

  @override
  Future<void> deleteQueuedAction(int id) async {
    await _appDatabase.database.delete(
      AppDatabaseConfig.queuedActionTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<QueuedActionModel?> getQueuedAction(int id) async {
    var res = await _appDatabase.database.query(
      AppDatabaseConfig.queuedActionTableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (res.isEmpty) return null;

    return QueuedActionModel.fromJson(res.first);
  }

  @override
  Future<List<QueuedActionModel>> getAllUserQueuedAction() async {
    var res = await _appDatabase.database.query(
      AppDatabaseConfig.queuedActionTableName,
    );

    return res.map((e) => QueuedActionModel.fromJson(e)).toList();
  }
}
