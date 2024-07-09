import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/domain/entities/queued_action_entity.dart';
import 'package:flutter_pos/domain/repositories/queued_action_repository.dart';

class GetAllQueuedActionUsecase extends UseCase<Result, NoParams> {
  GetAllQueuedActionUsecase(this._queuedActionRepository);

  final QueuedActionRepository _queuedActionRepository;

  @override
  Future<Result<List<QueuedActionEntity>>> call(NoParams params) async => _queuedActionRepository.getAllQueuedAction();
}

class ExecuteAllQueuedActionUsecase extends UseCase<Result, List<QueuedActionEntity>> {
  ExecuteAllQueuedActionUsecase(this._queuedActionRepository);

  final QueuedActionRepository _queuedActionRepository;

  @override
  Future<Result<List<bool>>> call(List<QueuedActionEntity> params) async =>
      _queuedActionRepository.executeAllQueuedActions(params);
}
