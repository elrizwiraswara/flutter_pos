import '../../models/queued_action_model.dart';

abstract class QueuedActionDatasource {
  Future<int> createQueuedAction(QueuedActionModel queue);

  Future<QueuedActionModel?> getQueuedAction(int id);

  Future<List<QueuedActionModel>> getAllUserQueuedAction();

  Future<void> deleteQueuedAction(int id);
}
