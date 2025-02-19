import 'package:flutter_pos/app/services/connectivity/connectivity_service.dart';
import 'package:flutter_pos/data/datasources/local/queued_action_local_datasource_impl.dart';
import 'package:flutter_pos/data/datasources/local/user_local_datasource_impl.dart';
import 'package:flutter_pos/data/datasources/remote/user_remote_datasource_impl.dart';
import 'package:flutter_pos/data/models/user_model.dart';
import 'package:flutter_pos/data/repositories/user_repository_impl.dart';
import 'package:flutter_pos/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'user_repository_impl_test.mocks.dart';

@GenerateMocks([
  ConnectivityService,
  UserLocalDatasourceImpl,
  UserRemoteDatasourceImpl,
  QueuedActionLocalDatasourceImpl,
])
void main() {
  late UserRepositoryImpl userRepository;
  late MockUserLocalDatasourceImpl mockUserLocalDatasource;
  late MockUserRemoteDatasourceImpl mockUserRemoteDatasource;
  late MockQueuedActionLocalDatasourceImpl mockQueuedActionLocalDatasource;

  setUp(() {
    mockUserLocalDatasource = MockUserLocalDatasourceImpl();
    mockUserRemoteDatasource = MockUserRemoteDatasourceImpl();
    mockQueuedActionLocalDatasource = MockQueuedActionLocalDatasourceImpl();

    userRepository = UserRepositoryImpl(
      userLocalDatasource: mockUserLocalDatasource,
      userRemoteDatasource: mockUserRemoteDatasource,
      queuedActionLocalDatasource: mockQueuedActionLocalDatasource,
    );
  });

  group('getUser', () {
    const userId = '123';
    final userModel = UserModel(id: userId, name: 'Test User');
    final userEntity = userModel.toEntity();

    test('should return local user when there is no connectivity', () async {
      ConnectivityService.setTestIsConnected(false);

      when(mockUserLocalDatasource.getUser(userId)).thenAnswer((_) async => userModel);

      final result = await userRepository.getUser(userId);

      expect(result.isSuccess, true);
      expect(result.data, equals(userEntity));
    });

    test('should return remote user when connectivity is available', () async {
      ConnectivityService.setTestIsConnected(true);

      when(mockUserLocalDatasource.getUser(userId)).thenAnswer((_) async => userModel);
      when(mockUserRemoteDatasource.getUser(userId)).thenAnswer((_) async => userModel);

      final result = await userRepository.getUser(userId);

      expect(result.isSuccess, true);
      expect(result.data, equals(userEntity));
    });

    test('should return an error when an exception occurs', () async {
      when(userRepository.getUser(userId)).thenThrow(Exception('Database error'));

      final result = await userRepository.getUser(userId);

      expect(result.isHasError, true);
      expect(result.error?.message, 'Exception: Database error');
    });
  });

  group('createUser', () {
    const userEntity = UserEntity(id: '123', name: 'Test User');

    test('should create user locally and remotely when connected', () async {
      ConnectivityService.setTestIsConnected(true);

      when(mockUserLocalDatasource.createUser(any)).thenAnswer((_) async => '123');
      when(mockUserRemoteDatasource.createUser(any)).thenAnswer((_) async => '123');

      final result = await userRepository.createUser(userEntity);

      expect(result.isSuccess, true);
      expect(result.data, '123');
    });

    test('should queue action when no connectivity', () async {
      ConnectivityService.setTestIsConnected(false);

      when(mockUserLocalDatasource.createUser(any)).thenAnswer((_) async => '123');
      when(mockQueuedActionLocalDatasource.createQueuedAction(any)).thenAnswer((_) async => 1);

      final result = await userRepository.createUser(userEntity);

      expect(result.isSuccess, true);
      expect(result.data, '123');
      verify(mockQueuedActionLocalDatasource.createQueuedAction(any)).called(1);
    });

    test('should return an error when an exception occurs', () async {
      when(mockUserLocalDatasource.createUser(any)).thenThrow(Exception('Database error'));

      final result = await userRepository.createUser(userEntity);

      expect(result.isHasError, true);
      expect(result.error?.message, 'Exception: Database error');
    });
  });
}
