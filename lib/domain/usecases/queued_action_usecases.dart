import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../entities/queued_action_entity.dart';
import '../repositories/queued_action_repository.dart';
import 'params/no_param.dart';

class GetAllQueuedActionUsecase extends Usecase<Result, NoParam> {
  GetAllQueuedActionUsecase(this._queuedActionRepository);

  final QueuedActionRepository _queuedActionRepository;

  @override
  Future<Result<List<QueuedActionEntity>>> call(NoParam params) async => _queuedActionRepository.getAllQueuedAction();
}

class ExecuteAllQueuedActionUsecase extends Usecase<Result, List<QueuedActionEntity>> {
  ExecuteAllQueuedActionUsecase(this._queuedActionRepository);

  final QueuedActionRepository _queuedActionRepository;

  @override
  Future<Result<List<bool>>> call(List<QueuedActionEntity> params) async =>
      _queuedActionRepository.executeAllQueuedActions(params);
}
