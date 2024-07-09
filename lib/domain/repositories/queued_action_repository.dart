import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/domain/entities/queued_action_entity.dart';

abstract class QueuedActionRepository {
  Future<Result<List<QueuedActionEntity>>> getAllQueuedAction();
  Future<Result<List<bool>>> executeAllQueuedActions(List<QueuedActionEntity> queues);
  Future<Result<bool>> executeQueuedAction(QueuedActionEntity queue);
}
