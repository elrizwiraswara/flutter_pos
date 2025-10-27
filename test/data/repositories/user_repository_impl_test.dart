import 'package:flutter_pos/app/services/connectivity/ping_service.dart';
import 'package:flutter_pos/core/common/result.dart';
import 'package:flutter_pos/data/datasources/local/queued_action_local_datasource_impl.dart';
import 'package:flutter_pos/data/datasources/local/user_local_datasource_impl.dart';
import 'package:flutter_pos/data/datasources/remote/user_remote_datasource_impl.dart';
import 'package:flutter_pos/data/models/queued_action_model.dart';
import 'package:flutter_pos/data/models/user_model.dart';
import 'package:flutter_pos/data/repositories/user_repository_impl.dart';
import 'package:flutter_pos/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'user_repository_impl_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  PingService,
  UserLocalDatasourceImpl,
  UserRemoteDatasourceImpl,
  QueuedActionLocalDatasourceImpl,
])
void main() {
  late UserRepositoryImpl repository;
  late MockPingService mockPingService;
  late MockUserLocalDatasourceImpl mockLocalDatasource;
  late MockUserRemoteDatasourceImpl mockRemoteDatasource;
  late MockQueuedActionLocalDatasourceImpl mockQueuedActionDatasource;

  setUp(() {
    mockPingService = MockPingService();
    mockLocalDatasource = MockUserLocalDatasourceImpl();
    mockRemoteDatasource = MockUserRemoteDatasourceImpl();
    mockQueuedActionDatasource = MockQueuedActionLocalDatasourceImpl();

    // Provide dummy values for Mockito
    provideDummy<Result<UserModel?>>(
      Result.success(
        data: UserModel(
          id: '',
          name: '',
          email: '',
          phone: '',
        ),
      ),
    );
    provideDummy<Result<String>>(
      Result.success(data: ''),
    );
    provideDummy<Result<int>>(
      Result.success(data: 0),
    );
    provideDummy<Result<void>>(
      Result.success(data: null),
    );

    repository = UserRepositoryImpl(
      pingService: mockPingService,
      userLocalDatasource: mockLocalDatasource,
      userRemoteDatasource: mockRemoteDatasource,
      queuedActionLocalDatasource: mockQueuedActionDatasource,
    );
  });

  group('getUser', () {
    const userId = 'user123';
    final localUser = UserModel(
      id: userId,
      name: 'Local User',
      email: 'local@example.com',
      phone: '1234567890',
      imageUrl: 'https://example.com/local.jpg',
      createdAt: '2025-01-01T10:00:00Z',
      updatedAt: '2025-01-01T10:00:00Z',
    );
    final remoteUser = UserModel(
      id: userId,
      name: 'Remote User',
      email: 'remote@example.com',
      phone: '0987654321',
      imageUrl: 'https://example.com/remote.jpg',
      createdAt: '2025-01-01T10:00:00Z',
      updatedAt: '2025-01-01T12:00:00Z',
    );

    test('returns local user when not connected', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: localUser));

      final result = await repository.getUser(userId);

      expect(result.isSuccess, true);
      expect(result.data!.name, 'Local User');
      expect(result.data!.email, 'local@example.com');
      verify(mockLocalDatasource.getUser(userId)).called(1);
      verifyNever(mockRemoteDatasource.getUser(any));
    });

    test('syncs and returns remote user when remote is newer', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: localUser));
      when(mockRemoteDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: remoteUser));
      when(mockLocalDatasource.updateUser(any)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.getUser(userId);

      expect(result.isSuccess, true);
      expect(result.data!.name, 'Remote User');
      expect(result.data!.email, 'remote@example.com');
      verify(mockLocalDatasource.updateUser(remoteUser)).called(1);
    });

    test('syncs and returns local user when local is newer', () async {
      final newerLocalUser = UserModel(
        id: userId,
        name: 'Newer Local User',
        email: 'newer@example.com',
        phone: '1234567890',
        imageUrl: 'https://example.com/newer.jpg',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T14:00:00Z',
      );

      final olderRemoteUser = UserModel(
        id: userId,
        name: 'Older Remote User',
        email: 'older@example.com',
        phone: '0987654321',
        imageUrl: 'https://example.com/older.jpg',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      );

      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: newerLocalUser));
      when(mockRemoteDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: olderRemoteUser));
      when(mockRemoteDatasource.updateUser(any)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.getUser(userId);

      expect(result.isSuccess, true);
      expect(result.data!.name, 'Newer Local User');
      verify(mockRemoteDatasource.updateUser(newerLocalUser)).called(1);
    });

    test('returns failure when local datasource fails', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.getUser(userId)).thenAnswer((_) async => Result.failure(error: 'User not found'));

      final result = await repository.getUser(userId);

      expect(result.isFailure, true);
      expect(result.error, 'User not found');
    });

    test('returns failure when remote datasource fails', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: localUser));
      when(mockRemoteDatasource.getUser(userId)).thenAnswer((_) async => Result.failure(error: 'Network error'));

      final result = await repository.getUser(userId);

      expect(result.isFailure, true);
      expect(result.error, 'Network error');
    });

    test('handles exception', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.getUser(userId)).thenThrow(Exception('Unexpected error'));

      final result = await repository.getUser(userId);

      expect(result.isFailure, true);
    });
  });

  group('createUser', () {
    final user = UserEntity(
      id: 'user123',
      name: 'New User',
      email: 'new@example.com',
      phone: '1234567890',
      imageUrl: 'https://example.com/photo.jpg',
      createdAt: '2025-01-01T10:00:00Z',
      updatedAt: '2025-01-01T10:00:00Z',
    );

    test('creates user locally and remotely when connected', () async {
      const generatedId = 'generated123';

      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.createUser(any)).thenAnswer((_) async => Result.success(data: generatedId));
      when(mockRemoteDatasource.createUser(any)).thenAnswer((_) async => Result.success(data: generatedId));

      final result = await repository.createUser(user);

      expect(result.isSuccess, true);
      expect(result.data, generatedId);
      verify(mockLocalDatasource.createUser(any)).called(1);
      verify(mockRemoteDatasource.createUser(any)).called(1);
      verifyNever(mockQueuedActionDatasource.createQueuedAction(any));
    });

    test('creates user locally and queues action when not connected', () async {
      const generatedId = 'generated456';

      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.createUser(any)).thenAnswer((_) async => Result.success(data: generatedId));
      when(mockQueuedActionDatasource.createQueuedAction(any)).thenAnswer((_) async => Result.success(data: 1));

      final result = await repository.createUser(user);

      expect(result.isSuccess, true);
      expect(result.data, generatedId);
      verify(mockLocalDatasource.createUser(any)).called(1);
      verify(mockQueuedActionDatasource.createQueuedAction(any)).called(1);
      verifyNever(mockRemoteDatasource.createUser(any));
    });

    test('returns failure when local creation fails', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.createUser(any)).thenAnswer((_) async => Result.failure(error: 'Database error'));

      final result = await repository.createUser(user);

      expect(result.isFailure, true);
      expect(result.error, 'Database error');
    });

    test('returns failure when remote creation fails', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.createUser(any)).thenAnswer((_) async => Result.success(data: 'user123'));
      when(mockRemoteDatasource.createUser(any)).thenAnswer((_) async => Result.failure(error: 'Server error'));

      final result = await repository.createUser(user);

      expect(result.isFailure, true);
      expect(result.error, 'Server error');
    });

    test('returns failure when queued action fails', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.createUser(any)).thenAnswer((_) async => Result.success(data: 'user123'));
      when(
        mockQueuedActionDatasource.createQueuedAction(any),
      ).thenAnswer((_) async => Result.failure(error: 'Queue error'));

      final result = await repository.createUser(user);

      expect(result.isFailure, true);
      expect(result.error, 'Queue error');
    });

    test('sets generated ID before creating remotely', () async {
      const generatedId = 'generated789';

      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.createUser(any)).thenAnswer((_) async => Result.success(data: generatedId));
      when(mockRemoteDatasource.createUser(any)).thenAnswer(
        (_) async => Result.success(data: generatedId),
      );

      await repository.createUser(user);

      final captured = verify(mockRemoteDatasource.createUser(captureAny)).captured.single as UserModel;
      expect(captured.id, generatedId);
    });
  });

  group('updateUser', () {
    final user = UserEntity(
      id: 'user123',
      name: 'Updated User',
      email: 'updated@example.com',
      phone: '9876543210',
      imageUrl: 'https://example.com/updated.jpg',
      createdAt: '2025-01-01T10:00:00Z',
      updatedAt: '2025-01-01T12:00:00Z',
    );

    test('updates user locally and remotely when connected', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.updateUser(any)).thenAnswer((_) async => Result.success(data: null));
      when(mockRemoteDatasource.updateUser(any)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.updateUser(user);

      expect(result.isSuccess, true);
      verify(mockLocalDatasource.updateUser(any)).called(1);
      verify(mockRemoteDatasource.updateUser(any)).called(1);
      verifyNever(mockQueuedActionDatasource.createQueuedAction(any));
    });

    test('updates user locally and queues action when not connected', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.updateUser(any)).thenAnswer((_) async => Result.success(data: null));
      when(mockQueuedActionDatasource.createQueuedAction(any)).thenAnswer((_) async => Result.success(data: 1));

      final result = await repository.updateUser(user);

      expect(result.isSuccess, true);
      verify(mockLocalDatasource.updateUser(any)).called(1);
      verify(mockQueuedActionDatasource.createQueuedAction(any)).called(1);
      verifyNever(mockRemoteDatasource.updateUser(any));
    });

    test('returns failure when local update fails', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.updateUser(any)).thenAnswer((_) async => Result.failure(error: 'Update failed'));

      final result = await repository.updateUser(user);

      expect(result.isFailure, true);
      expect(result.error, 'Update failed');
    });

    test('returns failure when remote update fails', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.updateUser(any)).thenAnswer((_) async => Result.success(data: null));
      when(mockRemoteDatasource.updateUser(any)).thenAnswer((_) async => Result.failure(error: 'Network error'));

      final result = await repository.updateUser(user);

      expect(result.isFailure, true);
      expect(result.error, 'Network error');
    });

    test('handles exception', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.updateUser(any)).thenThrow(Exception('Unexpected error'));

      final result = await repository.updateUser(user);

      expect(result.isFailure, true);
    });
  });

  group('deleteUser', () {
    const userId = 'user123';

    test('deletes user locally and remotely when connected', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.deleteUser(userId)).thenAnswer((_) async => Result.success(data: null));
      when(mockRemoteDatasource.deleteUser(userId)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.deleteUser(userId);

      expect(result.isSuccess, true);
      verify(mockLocalDatasource.deleteUser(userId)).called(1);
      verify(mockRemoteDatasource.deleteUser(userId)).called(1);
      verifyNever(mockQueuedActionDatasource.createQueuedAction(any));
    });

    test('deletes user locally and queues action when not connected', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.deleteUser(userId)).thenAnswer((_) async => Result.success(data: null));
      when(mockQueuedActionDatasource.createQueuedAction(any)).thenAnswer((_) async => Result.success(data: 1));

      final result = await repository.deleteUser(userId);

      expect(result.isSuccess, true);
      verify(mockLocalDatasource.deleteUser(userId)).called(1);
      verify(mockQueuedActionDatasource.createQueuedAction(any)).called(1);
      verifyNever(mockRemoteDatasource.deleteUser(userId));
    });

    test('returns failure when local deletion fails', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.deleteUser(userId)).thenAnswer((_) async => Result.failure(error: 'Delete failed'));

      final result = await repository.deleteUser(userId);

      expect(result.isFailure, true);
      expect(result.error, 'Delete failed');
    });

    test('returns failure when remote deletion fails', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.deleteUser(userId)).thenAnswer((_) async => Result.success(data: null));
      when(mockRemoteDatasource.deleteUser(userId)).thenAnswer((_) async => Result.failure(error: 'User not found'));

      final result = await repository.deleteUser(userId);

      expect(result.isFailure, true);
      expect(result.error, 'User not found');
    });

    test('handles exception', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.deleteUser(userId)).thenThrow(Exception('Unexpected error'));

      final result = await repository.deleteUser(userId);

      expect(result.isFailure, true);
    });
  });

  group('_syncUser - sync logic', () {
    test('creates remote user when local exists but remote does not', () async {
      const userId = 'user123';
      final localUser = UserModel(
        id: userId,
        name: 'Local User',
        email: 'local@example.com',
        phone: '1234567890',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      );

      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: localUser));
      when(mockRemoteDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: null));
      when(mockRemoteDatasource.createUser(localUser)).thenAnswer((_) async => Result.success(data: userId));

      await repository.getUser(userId);

      verify(mockRemoteDatasource.createUser(localUser)).called(1);
    });

    test('creates local user when remote exists but local does not', () async {
      const userId = 'user456';
      final remoteUser = UserModel(
        id: userId,
        name: 'Remote User',
        email: 'remote@example.com',
        phone: '0987654321',
        createdAt: '2025-01-01T11:00:00Z',
        updatedAt: '2025-01-01T11:00:00Z',
      );

      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: null));
      when(mockRemoteDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: remoteUser));
      when(mockLocalDatasource.createUser(remoteUser)).thenAnswer((_) async => Result.success(data: userId));

      await repository.getUser(userId);

      verify(mockLocalDatasource.createUser(remoteUser)).called(1);
    });

    test('updates local when remote is significantly newer', () async {
      const userId = 'user789';
      final localUser = UserModel(
        id: userId,
        name: 'Old Local User',
        email: 'old@example.com',
        phone: '1111111111',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      );

      final remoteUser = UserModel(
        id: userId,
        name: 'New Remote User',
        email: 'new@example.com',
        phone: '2222222222',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T18:00:00Z', // 8 hours later
      );

      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: localUser));
      when(mockRemoteDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: remoteUser));
      when(mockLocalDatasource.updateUser(any)).thenAnswer((_) async => Result.success(data: null));

      await repository.getUser(userId);

      verify(mockLocalDatasource.updateUser(remoteUser)).called(1);
    });

    test('updates remote when local is significantly newer', () async {
      const userId = 'user999';
      final localUser = UserModel(
        id: userId,
        name: 'New Local User',
        email: 'new@example.com',
        phone: '3333333333',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T20:00:00Z', // 10 hours later
      );

      final remoteUser = UserModel(
        id: userId,
        name: 'Old Remote User',
        email: 'old@example.com',
        phone: '4444444444',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      );

      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: localUser));
      when(mockRemoteDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: remoteUser));
      when(mockRemoteDatasource.updateUser(any)).thenAnswer((_) async => Result.success(data: null));

      await repository.getUser(userId);

      verify(mockRemoteDatasource.updateUser(localUser)).called(1);
    });

    test('does not sync when timestamps are within tolerance', () async {
      const userId = 'user111';
      final localUser = UserModel(
        id: userId,
        name: 'User',
        email: 'user@example.com',
        phone: '5555555555',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      );

      final remoteUser = UserModel(
        id: userId,
        name: 'User',
        email: 'user@example.com',
        phone: '5555555555',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:30:00Z', // 30 minutes difference (within tolerance)
      );

      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: localUser));
      when(mockRemoteDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: remoteUser));

      await repository.getUser(userId);

      verifyNever(mockLocalDatasource.updateUser(any));
      verifyNever(mockRemoteDatasource.updateUser(any));
    });

    test('skips sync when local timestamp is invalid', () async {
      const userId = 'user222';
      final localUser = UserModel(
        id: userId,
        name: 'Local User',
        email: 'local@example.com',
        phone: '6666666666',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: 'invalid-timestamp',
      );

      final remoteUser = UserModel(
        id: userId,
        name: 'Remote User',
        email: 'remote@example.com',
        phone: '7777777777',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      );

      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: localUser));
      when(mockRemoteDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: remoteUser));

      await repository.getUser(userId);

      verifyNever(mockLocalDatasource.updateUser(any));
      verifyNever(mockRemoteDatasource.updateUser(any));
    });

    test('skips sync when remote timestamp is invalid', () async {
      const userId = 'user333';
      final localUser = UserModel(
        id: userId,
        name: 'Local User',
        email: 'local@example.com',
        phone: '8888888888',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      );

      final remoteUser = UserModel(
        id: userId,
        name: 'Remote User',
        email: 'remote@example.com',
        phone: '9999999999',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: null,
      );

      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: localUser));
      when(mockRemoteDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: remoteUser));

      await repository.getUser(userId);

      verifyNever(mockLocalDatasource.updateUser(any));
      verifyNever(mockRemoteDatasource.updateUser(any));
    });

    test('handles sync failure gracefully', () async {
      const userId = 'user444';
      final localUser = UserModel(
        id: userId,
        name: 'Local User',
        email: 'local@example.com',
        phone: '1010101010',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      );

      final remoteUser = UserModel(
        id: userId,
        name: 'Remote User',
        email: 'remote@example.com',
        phone: '2020202020',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T15:00:00Z',
      );

      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: localUser));
      when(mockRemoteDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: remoteUser));
      when(mockLocalDatasource.updateUser(any)).thenAnswer((_) async => Result.failure(error: 'Update failed'));

      // Should still return result even if sync fails
      final result = await repository.getUser(userId);

      expect(result.isSuccess, true);
      verify(mockLocalDatasource.updateUser(remoteUser)).called(1);
    });
  });

  group('Integration scenarios', () {
    test('full workflow: create, get, update, delete', () async {
      final user = UserEntity(
        id: 'user123',
        name: 'Test User',
        email: 'test@example.com',
        phone: '1234567890',
        imageUrl: 'https://example.com/photo.jpg',
      );

      // Create
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.createUser(any)).thenAnswer((_) async => Result.success(data: 'user123'));
      when(mockRemoteDatasource.createUser(any)).thenAnswer((_) async => Result.success(data: 'user123'));

      final createResult = await repository.createUser(user);
      expect(createResult.isSuccess, true);

      // Get
      final createdUser = UserModel(
        id: 'user123',
        name: 'Test User',
        email: 'test@example.com',
        phone: '1234567890',
        imageUrl: 'https://example.com/photo.jpg',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      );

      when(mockLocalDatasource.getUser('user123')).thenAnswer((_) async => Result.success(data: createdUser));
      when(mockRemoteDatasource.getUser('user123')).thenAnswer((_) async => Result.success(data: createdUser));

      final getResult = await repository.getUser('user123');
      expect(getResult.isSuccess, true);
      expect(getResult.data!.id, 'user123');

      // Update
      final updatedUser = user.copyWith(
        id: 'user123',
        name: 'Updated User',
        email: 'updated@example.com',
      );

      when(mockLocalDatasource.updateUser(any)).thenAnswer((_) async => Result.success(data: null));
      when(mockRemoteDatasource.updateUser(any)).thenAnswer((_) async => Result.success(data: null));

      final updateResult = await repository.updateUser(updatedUser);
      expect(updateResult.isSuccess, true);

      // Delete
      when(mockLocalDatasource.deleteUser('user123')).thenAnswer((_) async => Result.success(data: null));
      when(mockRemoteDatasource.deleteUser('user123')).thenAnswer((_) async => Result.success(data: null));

      final deleteResult = await repository.deleteUser('user123');
      expect(deleteResult.isSuccess, true);
    });

    test('offline workflow with queued actions', () async {
      final user = UserEntity(
        id: 'user123',
        name: 'Offline User',
        email: 'offline@example.com',
        phone: '9876543210',
        imageUrl: 'https://example.com/offline.jpg',
      );

      // Create offline
      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.createUser(any)).thenAnswer((_) async => Result.success(data: 'user456'));
      when(mockQueuedActionDatasource.createQueuedAction(any)).thenAnswer((_) async => Result.success(data: 1));

      final createResult = await repository.createUser(user);
      expect(createResult.isSuccess, true);
      verify(mockQueuedActionDatasource.createQueuedAction(any)).called(1);

      // Update offline
      final updatedUser = user.copyWith(
        id: 'user456',
        name: 'Updated Offline User',
      );
      when(mockLocalDatasource.updateUser(any)).thenAnswer((_) async => Result.success(data: null));

      final updateResult = await repository.updateUser(updatedUser);
      expect(updateResult.isSuccess, true);
      verify(mockQueuedActionDatasource.createQueuedAction(any)).called(1);

      // Delete offline
      when(mockLocalDatasource.deleteUser('user456')).thenAnswer((_) async => Result.success(data: null));

      final deleteResult = await repository.deleteUser('user456');
      expect(deleteResult.isSuccess, true);
      verify(mockQueuedActionDatasource.createQueuedAction(any)).called(1);
    });

    test('transition from offline to online', () async {
      final user = UserEntity(
        id: 'user123',
        name: 'Transition User',
        email: 'transition@example.com',
        phone: '5555555555',
      );

      // Create offline
      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.createUser(any)).thenAnswer((_) async => Result.success(data: 'user789'));
      when(mockQueuedActionDatasource.createQueuedAction(any)).thenAnswer((_) async => Result.success(data: 1));

      final offlineResult = await repository.createUser(user);
      expect(offlineResult.isSuccess, true);
      verify(mockQueuedActionDatasource.createQueuedAction(any)).called(1);

      // Now online - update should sync remotely
      when(mockPingService.isConnected).thenReturn(true);
      final updatedUser = user.copyWith(
        id: 'user789',
        name: 'Updated Online User',
      );

      when(mockLocalDatasource.updateUser(any)).thenAnswer((_) async => Result.success(data: null));
      when(mockRemoteDatasource.updateUser(any)).thenAnswer((_) async => Result.success(data: null));

      final onlineResult = await repository.updateUser(updatedUser);
      expect(onlineResult.isSuccess, true);
      verify(mockRemoteDatasource.updateUser(any)).called(1);
      verifyNever(
        mockQueuedActionDatasource.createQueuedAction(
          argThat(predicate<QueuedActionModel>((m) => m.method == 'updateUser')),
        ),
      );
    });
  });

  group('Edge cases', () {
    test('handles user with null optional fields', () async {
      final user = UserEntity(
        id: 'user999',
        name: 'Minimal User',
        email: 'minimal@example.com',
        phone: '1111111111',
        imageUrl: null,
        createdAt: null,
        updatedAt: null,
      );

      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.createUser(any)).thenAnswer((_) async => Result.success(data: 'user999'));
      when(mockRemoteDatasource.createUser(any)).thenAnswer((_) async => Result.success(data: 'user999'));

      final result = await repository.createUser(user);

      expect(result.isSuccess, true);
      expect(result.data, 'user999');
    });

    test('handles empty user ID for deletion', () async {
      const emptyId = '';

      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.deleteUser(emptyId)).thenAnswer((_) async => Result.failure(error: 'Invalid ID'));

      final result = await repository.deleteUser(emptyId);

      expect(result.isFailure, true);
      expect(result.error, 'Invalid ID');
    });

    test('handles concurrent operations', () async {
      const userId = 'concurrent123';
      final user1 = UserModel(
        id: userId,
        name: 'User 1',
        email: 'user1@example.com',
        phone: '1111111111',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      );

      final user2 = UserModel(
        id: userId,
        name: 'User 2',
        email: 'user2@example.com',
        phone: '2222222222',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T12:00:00Z',
      );

      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: user1));
      when(mockRemoteDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: user2));
      when(mockLocalDatasource.updateUser(any)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.getUser(userId);

      expect(result.isSuccess, true);
      expect(result.data!.name, 'User 2'); // Remote is newer
    });

    test('handles special characters in user data', () async {
      final user = UserEntity(
        id: 'user_special',
        name: "O'Brien",
        email: 'test+user@example.com',
        phone: '+1-234-567-8900',
        imageUrl: 'https://example.com/photo?size=large&format=jpg',
      );

      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.createUser(any)).thenAnswer((_) async => Result.success(data: 'user_special'));
      when(mockRemoteDatasource.createUser(any)).thenAnswer((_) async => Result.success(data: 'user_special'));

      final result = await repository.createUser(user);

      expect(result.isSuccess, true);
    });

    test('verifies queued action has correct structure', () async {
      final user = UserEntity(
        id: 'queue_user',
        name: 'Queue Test',
        email: 'queue@example.com',
        phone: '9999999999',
      );

      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.createUser(any)).thenAnswer((_) async => Result.success(data: 'queue_user'));
      when(mockQueuedActionDatasource.createQueuedAction(any)).thenAnswer((_) async => Result.success(data: 1));

      await repository.createUser(user);

      final captured =
          verify(mockQueuedActionDatasource.createQueuedAction(captureAny)).captured.single as QueuedActionModel;

      expect(captured.repository, 'UserRepositoryImpl');
      expect(captured.method, 'createUser');
      expect(captured.isCritical, false);
      expect(captured.param, isNotEmpty);
    });
  });

  group('Performance and reliability', () {
    test('handles rapid successive calls', () async {
      const userId = 'rapid123';
      final user = UserModel(
        id: userId,
        name: 'Rapid User',
        email: 'rapid@example.com',
        phone: '3333333333',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      );

      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.getUser(userId)).thenAnswer((_) async => Result.success(data: user));

      // Simulate rapid calls
      final results = await Future.wait([
        repository.getUser(userId),
        repository.getUser(userId),
        repository.getUser(userId),
      ]);

      expect(results.every((r) => r.isSuccess), true);
      expect(results.every((r) => r.data?.id == userId), true);
    });

    test('maintains data consistency across operations', () async {
      const userId = 'consistent123';
      final initialUser = UserEntity(
        id: userId,
        name: 'Initial',
        email: 'initial@example.com',
        phone: '4444444444',
      );

      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.createUser(any)).thenAnswer((_) async => Result.success(data: userId));
      when(mockRemoteDatasource.createUser(any)).thenAnswer((_) async => Result.success(data: userId));

      // Create
      final createResult = await repository.createUser(initialUser);
      expect(createResult.isSuccess, true);

      // Verify the ID is used in subsequent operations
      final updatedUser = initialUser.copyWith(
        id: userId,
        name: 'Updated',
      );

      when(mockLocalDatasource.updateUser(any)).thenAnswer((_) async => Result.success(data: null));
      when(mockRemoteDatasource.updateUser(any)).thenAnswer((_) async => Result.success(data: null));

      await repository.updateUser(updatedUser);

      final captured = verify(mockRemoteDatasource.updateUser(captureAny)).captured.single as UserModel;
      expect(captured.id, userId);
      expect(captured.name, 'Updated');
    });
  });
}
