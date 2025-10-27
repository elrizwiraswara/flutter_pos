import 'package:flutter_pos/core/common/result.dart';
import 'package:flutter_pos/domain/entities/queued_action_entity.dart';
import 'package:flutter_pos/domain/repositories/queued_action_repository.dart';
import 'package:flutter_pos/domain/usecases/params/no_param.dart';
import 'package:flutter_pos/domain/usecases/queued_action_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'queued_action_usecases_test.mocks.dart';

// This will generate the mock class
@GenerateMocks([QueuedActionRepository])
void main() {
  late MockQueuedActionRepository mockQueuedActionRepository;

  setUpAll(() {
    // Provide dummy values for complex types
    provideDummy<Result<List<QueuedActionEntity>>>(
      Result<List<QueuedActionEntity>>.success(data: []),
    );
    provideDummy<Result<List<bool>>>(
      Result<List<bool>>.success(data: []),
    );
  });

  setUp(() {
    mockQueuedActionRepository = MockQueuedActionRepository();
  });

  group('GetAllQueuedActionUsecase', () {
    late GetAllQueuedActionUsecase usecase;

    setUp(() {
      usecase = GetAllQueuedActionUsecase(mockQueuedActionRepository);
    });

    test('should return list of queued actions from repository', () async {
      // arrange
      final queuedActions = [
        QueuedActionEntity(
          id: 1,
          repository: '',
          method: '',
          param: '',
          isCritical: true,
        ),
        QueuedActionEntity(
          id: 2,
          repository: '',
          method: '',
          param: '',
          isCritical: true,
        ),
      ];
      final result = Result<List<QueuedActionEntity>>.success(data: queuedActions);

      when(mockQueuedActionRepository.getAllQueuedAction()).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(NoParam());

      // assert
      expect(response, result);
      verify(mockQueuedActionRepository.getAllQueuedAction());
      verifyNoMoreInteractions(mockQueuedActionRepository);
    });

    test('should return failure from repository', () async {
      // arrange
      final result = Result<List<QueuedActionEntity>>.failure(error: 'Error');

      when(mockQueuedActionRepository.getAllQueuedAction()).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(NoParam());

      // assert
      expect(response, result);
      verify(mockQueuedActionRepository.getAllQueuedAction());
      verifyNoMoreInteractions(mockQueuedActionRepository);
    });
  });

  group('ExecuteAllQueuedActionUsecase', () {
    late ExecuteAllQueuedActionUsecase usecase;

    setUp(() {
      usecase = ExecuteAllQueuedActionUsecase(mockQueuedActionRepository);
    });

    test('should execute queued actions and return results from repository', () async {
      // arrange
      final queuedActions = [
        QueuedActionEntity(
          id: 1,
          repository: '',
          method: '',
          param: '',
          isCritical: true,
        ),
        QueuedActionEntity(
          id: 2,
          repository: '',
          method: '',
          param: '',
          isCritical: true,
        ),
      ];
      final result = Result<List<bool>>.success(data: [true, true]);

      when(mockQueuedActionRepository.executeAllQueuedActions(queuedActions)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(queuedActions);

      // assert
      expect(response, result);
      verify(mockQueuedActionRepository.executeAllQueuedActions(queuedActions));
      verifyNoMoreInteractions(mockQueuedActionRepository);
    });

    test('should return failure from repository', () async {
      // arrange
      final queuedActions = [
        QueuedActionEntity(
          id: 1,
          repository: '',
          method: '',
          param: '',
          isCritical: true,
        ),
      ];
      final result = Result<List<bool>>.failure(error: 'Execution failed');

      when(mockQueuedActionRepository.executeAllQueuedActions(queuedActions)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(queuedActions);

      // assert
      expect(response, result);
      verify(mockQueuedActionRepository.executeAllQueuedActions(queuedActions));
      verifyNoMoreInteractions(mockQueuedActionRepository);
    });
  });
}
