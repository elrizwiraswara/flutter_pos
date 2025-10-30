import 'package:sqflite/sqflite.dart';

import '../../../core/common/result.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_config.dart';
import '../../models/queued_action_model.dart';
import '../interfaces/queued_action_datasource.dart';

class QueuedActionLocalDatasourceImpl extends QueuedActionDatasource {
  final AppDatabase _appDatabase;

  QueuedActionLocalDatasourceImpl(this._appDatabase);

  @override
  Future<Result<int>> createQueuedAction(QueuedActionModel queue) async {
    try {
      await _appDatabase.database.insert(
        DatabaseConfig.queuedActionTableName,
        queue.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // The id has been generated in models
      return Result.success(data: queue.id);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteQueuedAction(int id) async {
    try {
      await _appDatabase.database.delete(
        DatabaseConfig.queuedActionTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<QueuedActionModel?>> getQueuedAction(int id) async {
    try {
      var res = await _appDatabase.database.query(
        DatabaseConfig.queuedActionTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (res.isEmpty) return Result.success(data: null);

      return Result.success(data: QueuedActionModel.fromJson(res.first));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<QueuedActionModel>>> getAllUserQueuedAction() async {
    try {
      var res = await _appDatabase.database.query(
        DatabaseConfig.queuedActionTableName,
      );

      return Result.success(
        data: res.map((e) => QueuedActionModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
