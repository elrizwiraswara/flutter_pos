import 'package:flutter_pos/app/services/connectivity/ping_service.dart';
import 'package:flutter_pos/core/common/result.dart';
import 'package:flutter_pos/data/datasources/local/queued_action_local_datasource_impl.dart';
import 'package:flutter_pos/data/datasources/local/transaction_local_datasource_impl.dart';
import 'package:flutter_pos/data/datasources/remote/transaction_remote_datasource_impl.dart';
import 'package:flutter_pos/data/models/transaction_model.dart';
import 'package:flutter_pos/data/repositories/transaction_repository_impl.dart';
import 'package:flutter_pos/domain/entities/transaction_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'transaction_repository_impl_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  PingService,
  TransactionLocalDatasourceImpl,
  TransactionRemoteDatasourceImpl,
  QueuedActionLocalDatasourceImpl,
])
void main() {
  late TransactionRepositoryImpl repository;
  late MockPingService mockPingService;
  late MockTransactionLocalDatasourceImpl mockLocalDatasource;
  late MockTransactionRemoteDatasourceImpl mockRemoteDatasource;
  late MockQueuedActionLocalDatasourceImpl mockQueuedActionDatasource;

  setUp(() {
    mockPingService = MockPingService();
    mockLocalDatasource = MockTransactionLocalDatasourceImpl();
    mockRemoteDatasource = MockTransactionRemoteDatasourceImpl();
    mockQueuedActionDatasource = MockQueuedActionLocalDatasourceImpl();

    // Provide dummy values for Mockito
    provideDummy<Result<List<TransactionModel>>>(
      Result.success(data: <TransactionModel>[]),
    );
    provideDummy<Result<TransactionModel?>>(
      Result.success(
        data: TransactionModel(
          id: 0,
          paymentMethod: '',
          createdById: '',
          receivedAmount: 0,
          returnAmount: 0,
          totalAmount: 0,
          totalOrderedProduct: 0,
        ),
      ),
    );
    provideDummy<Result<int>>(
      Result.success(data: 0),
    );
    provideDummy<Result<void>>(
      Result.success(data: null),
    );

    repository = TransactionRepositoryImpl(
      pingService: mockPingService,
      transactionLocalDatasource: mockLocalDatasource,
      transactionRemoteDatasource: mockRemoteDatasource,
      queuedActionLocalDatasource: mockQueuedActionDatasource,
    );
  });

  group('syncAllUserTransactions', () {
    const userId = 'user123';
    final localTransactions = [
      TransactionModel(
        id: 1,
        paymentMethod: 'cash',
        createdById: userId,
        customerName: 'John Doe',
        receivedAmount: 100000,
        returnAmount: 0,
        totalAmount: 100000,
        totalOrderedProduct: 2,
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      ),
    ];
    final remoteTransactions = [
      TransactionModel(
        id: 2,
        paymentMethod: 'credit_card',
        createdById: userId,
        customerName: 'Jane Smith',
        receivedAmount: 200000,
        returnAmount: 10000,
        totalAmount: 190000,
        totalOrderedProduct: 3,
        createdAt: '2025-01-01T11:00:00Z',
        updatedAt: '2025-01-01T11:00:00Z',
      ),
    ];

    test('returns 0 when not connected', () async {
      when(mockPingService.isConnected).thenReturn(false);

      final result = await repository.syncAllUserTransactions(userId);

      expect(result.isSuccess, true);
      expect(result.data, 0);
      verifyNever(mockLocalDatasource.getAllUserTransactions(any));
      verifyNever(mockRemoteDatasource.getAllUserTransactions(any));
    });

    test('syncs all transactions when connected', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(
        mockLocalDatasource.getAllUserTransactions(userId),
      ).thenAnswer((_) async => Result.success(data: localTransactions));
      when(
        mockRemoteDatasource.getAllUserTransactions(userId),
      ).thenAnswer((_) async => Result.success(data: remoteTransactions));
      when(mockRemoteDatasource.createTransaction(any)).thenAnswer((_) async => Result.success(data: 1));
      when(mockLocalDatasource.createTransaction(any)).thenAnswer((_) async => Result.success(data: 1));

      final result = await repository.syncAllUserTransactions(userId);

      expect(result.isSuccess, true);
      expect(result.data, 2); // Both transactions synced
      verify(mockLocalDatasource.getAllUserTransactions(userId)).called(1);
      verify(mockRemoteDatasource.getAllUserTransactions(userId)).called(1);
    });

    test('returns failure when local datasource fails', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(
        mockLocalDatasource.getAllUserTransactions(userId),
      ).thenAnswer((_) async => Result.failure(error: 'Local error'));

      final result = await repository.syncAllUserTransactions(userId);

      expect(result.isFailure, true);
      expect(result.error, 'Local error');
    });

    test('returns failure when remote datasource fails', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(
        mockLocalDatasource.getAllUserTransactions(userId),
      ).thenAnswer((_) async => Result.success(data: localTransactions));
      when(
        mockRemoteDatasource.getAllUserTransactions(userId),
      ).thenAnswer((_) async => Result.failure(error: 'Remote error'));

      final result = await repository.syncAllUserTransactions(userId);

      expect(result.isFailure, true);
      expect(result.error, 'Remote error');
    });

    test('handles exception', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.getAllUserTransactions(userId)).thenThrow(Exception('Unexpected error'));

      final result = await repository.syncAllUserTransactions(userId);

      expect(result.isFailure, true);
    });
  });

  group('getUserTransactions', () {
    const userId = 'user123';
    final localTransactions = [
      TransactionModel(
        id: 1,
        paymentMethod: 'cash',
        createdById: userId,
        customerName: 'Local Customer',
        receivedAmount: 50000,
        returnAmount: 0,
        totalAmount: 50000,
        totalOrderedProduct: 1,
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      ),
    ];
    final remoteTransactions = [
      TransactionModel(
        id: 1,
        paymentMethod: 'credit_card',
        createdById: userId,
        customerName: 'Remote Customer',
        receivedAmount: 60000,
        returnAmount: 5000,
        totalAmount: 55000,
        totalOrderedProduct: 2,
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T12:00:00Z',
      ),
    ];

    test('returns local transactions when not connected', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(
        mockLocalDatasource.getUserTransactions(
          userId,
          orderBy: anyNamed('orderBy'),
          sortBy: anyNamed('sortBy'),
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
          contains: anyNamed('contains'),
        ),
      ).thenAnswer((_) async => Result.success(data: localTransactions));

      final result = await repository.getUserTransactions(userId);

      expect(result.isSuccess, true);
      expect(result.data!.length, 1);
      expect(result.data!.first.customerName, 'Local Customer');
      verifyNever(
        mockRemoteDatasource.getUserTransactions(
          any,
          orderBy: anyNamed('orderBy'),
          sortBy: anyNamed('sortBy'),
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
          contains: anyNamed('contains'),
        ),
      );
    });

    test('returns remote transactions when synced to local', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(
        mockLocalDatasource.getUserTransactions(
          userId,
          orderBy: anyNamed('orderBy'),
          sortBy: anyNamed('sortBy'),
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
          contains: anyNamed('contains'),
        ),
      ).thenAnswer((_) async => Result.success(data: localTransactions));
      when(
        mockRemoteDatasource.getUserTransactions(
          userId,
          orderBy: anyNamed('orderBy'),
          sortBy: anyNamed('sortBy'),
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
          contains: anyNamed('contains'),
        ),
      ).thenAnswer((_) async => Result.success(data: remoteTransactions));
      when(mockLocalDatasource.updateTransaction(any)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.getUserTransactions(userId);

      expect(result.isSuccess, true);
      expect(result.data!.length, 1);
      expect(result.data!.first.customerName, 'Remote Customer');
    });

    test('passes query parameters correctly', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(
        mockLocalDatasource.getUserTransactions(
          userId,
          orderBy: 'totalAmount',
          sortBy: 'ASC',
          limit: 20,
          offset: 10,
          contains: 'test',
        ),
      ).thenAnswer((_) async => Result.success(data: []));

      await repository.getUserTransactions(
        userId,
        orderBy: 'totalAmount',
        sortBy: 'ASC',
        limit: 20,
        offset: 10,
        contains: 'test',
      );

      verify(
        mockLocalDatasource.getUserTransactions(
          userId,
          orderBy: 'totalAmount',
          sortBy: 'ASC',
          limit: 20,
          offset: 10,
          contains: 'test',
        ),
      ).called(1);
    });

    test('returns failure when local datasource fails', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(
        mockLocalDatasource.getUserTransactions(
          userId,
          orderBy: anyNamed('orderBy'),
          sortBy: anyNamed('sortBy'),
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
          contains: anyNamed('contains'),
        ),
      ).thenAnswer((_) async => Result.failure(error: 'Database error'));

      final result = await repository.getUserTransactions(userId);

      expect(result.isFailure, true);
      expect(result.error, 'Database error');
    });
  });

  group('getTransaction', () {
    const transactionId = 1;
    final localTransaction = TransactionModel(
      id: transactionId,
      paymentMethod: 'cash',
      createdById: 'user123',
      customerName: 'Local Customer',
      receivedAmount: 100000,
      returnAmount: 0,
      totalAmount: 100000,
      totalOrderedProduct: 2,
      createdAt: '2025-01-01T10:00:00Z',
      updatedAt: '2025-01-01T10:00:00Z',
    );
    final remoteTransaction = TransactionModel(
      id: transactionId,
      paymentMethod: 'credit_card',
      createdById: 'user123',
      customerName: 'Remote Customer',
      receivedAmount: 120000,
      returnAmount: 10000,
      totalAmount: 110000,
      totalOrderedProduct: 3,
      createdAt: '2025-01-01T10:00:00Z',
      updatedAt: '2025-01-01T12:00:00Z',
    );

    test('returns local transaction when not connected', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(
        mockLocalDatasource.getTransaction(transactionId),
      ).thenAnswer((_) async => Result.success(data: localTransaction));

      final result = await repository.getTransaction(transactionId);

      expect(result.isSuccess, true);
      expect(result.data!.customerName, 'Local Customer');
    });

    test('syncs and returns remote transaction when remote is newer', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(
        mockLocalDatasource.getTransaction(transactionId),
      ).thenAnswer((_) async => Result.success(data: localTransaction));
      when(
        mockRemoteDatasource.getTransaction(transactionId),
      ).thenAnswer((_) async => Result.success(data: remoteTransaction));
      when(mockLocalDatasource.updateTransaction(any)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.getTransaction(transactionId);

      expect(result.isSuccess, true);
      expect(result.data!.customerName, 'Remote Customer');
      verify(mockLocalDatasource.updateTransaction(remoteTransaction)).called(1);
    });

    test('returns failure when local datasource fails', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(
        mockLocalDatasource.getTransaction(transactionId),
      ).thenAnswer((_) async => Result.failure(error: 'Not found'));

      final result = await repository.getTransaction(transactionId);

      expect(result.isFailure, true);
      expect(result.error, 'Not found');
    });
  });

  group('createTransaction', () {
    final transaction = TransactionEntity(
      id: null,
      paymentMethod: 'cash',
      createdById: 'user123',
      customerName: 'New Customer',
      receivedAmount: 75000,
      returnAmount: 0,
      totalAmount: 75000,
      totalOrderedProduct: 2,
      createdAt: '2025-01-01T10:00:00Z',
      updatedAt: '2025-01-01T10:00:00Z',
    );

    test('creates transaction locally and remotely when connected', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.createTransaction(any)).thenAnswer((_) async => Result.success(data: 1));
      when(mockRemoteDatasource.createTransaction(any)).thenAnswer((_) async => Result.success(data: 1));

      final result = await repository.createTransaction(transaction);

      expect(result.isSuccess, true);
      expect(result.data, 1);
      verify(mockLocalDatasource.createTransaction(any)).called(1);
      verify(mockRemoteDatasource.createTransaction(any)).called(1);
      verifyNever(mockQueuedActionDatasource.createQueuedAction(any));
    });

    test('creates transaction locally and queues action when not connected', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.createTransaction(any)).thenAnswer((_) async => Result.success(data: 1));
      when(mockQueuedActionDatasource.createQueuedAction(any)).thenAnswer((_) async => Result.success(data: 1));

      final result = await repository.createTransaction(transaction);

      expect(result.isSuccess, true);
      verify(mockLocalDatasource.createTransaction(any)).called(1);
      verify(mockQueuedActionDatasource.createQueuedAction(any)).called(1);
      verifyNever(mockRemoteDatasource.createTransaction(any));
    });

    test('returns failure when local creation fails', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.createTransaction(any)).thenAnswer((_) async => Result.failure(error: 'Database full'));

      final result = await repository.createTransaction(transaction);

      expect(result.isFailure, true);
      expect(result.error, 'Database full');
    });

    test('returns failure when remote creation fails', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.createTransaction(any)).thenAnswer((_) async => Result.success(data: 1));
      when(mockRemoteDatasource.createTransaction(any)).thenAnswer((_) async => Result.failure(error: 'Server error'));

      final result = await repository.createTransaction(transaction);

      expect(result.isFailure, true);
      expect(result.error, 'Server error');
    });

    test('returns failure when queued action fails', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.createTransaction(any)).thenAnswer((_) async => Result.success(data: 1));
      when(
        mockQueuedActionDatasource.createQueuedAction(any),
      ).thenAnswer((_) async => Result.failure(error: 'Queue error'));

      final result = await repository.createTransaction(transaction);

      expect(result.isFailure, true);
      expect(result.error, 'Queue error');
    });
  });

  group('updateTransaction', () {
    final transaction = TransactionEntity(
      id: 1,
      paymentMethod: 'credit_card',
      createdById: 'user123',
      customerName: 'Updated Customer',
      receivedAmount: 150000,
      returnAmount: 5000,
      totalAmount: 145000,
      totalOrderedProduct: 4,
      createdAt: '2025-01-01T10:00:00Z',
      updatedAt: '2025-01-01T12:00:00Z',
    );

    test('updates transaction locally and remotely when connected', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.updateTransaction(any)).thenAnswer((_) async => Result.success(data: null));
      when(mockRemoteDatasource.updateTransaction(any)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.updateTransaction(transaction);

      expect(result.isSuccess, true);
      verify(mockLocalDatasource.updateTransaction(any)).called(1);
      verify(mockRemoteDatasource.updateTransaction(any)).called(1);
      verifyNever(mockQueuedActionDatasource.createQueuedAction(any));
    });

    test('updates transaction locally and queues action when not connected', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.updateTransaction(any)).thenAnswer((_) async => Result.success(data: null));
      when(mockQueuedActionDatasource.createQueuedAction(any)).thenAnswer((_) async => Result.success(data: 1));

      final result = await repository.updateTransaction(transaction);

      expect(result.isSuccess, true);
      verify(mockLocalDatasource.updateTransaction(any)).called(1);
      verify(mockQueuedActionDatasource.createQueuedAction(any)).called(1);
      verifyNever(mockRemoteDatasource.updateTransaction(any));
    });

    test('returns failure when local update fails', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.updateTransaction(any)).thenAnswer((_) async => Result.failure(error: 'Update failed'));

      final result = await repository.updateTransaction(transaction);

      expect(result.isFailure, true);
      expect(result.error, 'Update failed');
    });
  });

  group('deleteTransaction', () {
    const transactionId = 1;

    test('deletes transaction locally and remotely when connected', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.deleteTransaction(transactionId)).thenAnswer((_) async => Result.success(data: null));
      when(mockRemoteDatasource.deleteTransaction(transactionId)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.deleteTransaction(transactionId);

      expect(result.isSuccess, true);
      verify(mockLocalDatasource.deleteTransaction(transactionId)).called(1);
      verify(mockRemoteDatasource.deleteTransaction(transactionId)).called(1);
      verifyNever(mockQueuedActionDatasource.createQueuedAction(any));
    });

    test('deletes transaction locally and queues action when not connected', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.deleteTransaction(transactionId)).thenAnswer((_) async => Result.success(data: null));
      when(mockQueuedActionDatasource.createQueuedAction(any)).thenAnswer((_) async => Result.success(data: 1));

      final result = await repository.deleteTransaction(transactionId);

      expect(result.isSuccess, true);
      verify(mockLocalDatasource.deleteTransaction(transactionId)).called(1);
      verify(mockQueuedActionDatasource.createQueuedAction(any)).called(1);
      verifyNever(mockRemoteDatasource.deleteTransaction(transactionId));
    });

    test('returns failure when remote deletion fails', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.deleteTransaction(transactionId)).thenAnswer((_) async => Result.success(data: null));
      when(
        mockRemoteDatasource.deleteTransaction(transactionId),
      ).thenAnswer((_) async => Result.failure(error: 'Not found'));

      final result = await repository.deleteTransaction(transactionId);

      expect(result.isFailure, true);
      expect(result.error, 'Not found');
    });
  });

  group('syncTransactions - sync logic', () {
    test('syncs local transaction to remote when not exists remotely', () async {
      final localTxn = TransactionModel(
        id: 1,
        paymentMethod: 'cash',
        createdById: 'user123',
        receivedAmount: 100000,
        returnAmount: 0,
        totalAmount: 100000,
        totalOrderedProduct: 2,
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      );

      when(mockRemoteDatasource.createTransaction(any)).thenAnswer((_) async => Result.success(data: 1));

      final result = await repository.syncTransactions([localTxn], []);

      expect(result.$1, 0); // syncedToLocalCount
      expect(result.$2, 1); // syncedToRemoteCount
      verify(mockRemoteDatasource.createTransaction(any)).called(1);
    });

    test('syncs remote transaction to local when not exists locally', () async {
      final remoteTxn = TransactionModel(
        id: 2,
        paymentMethod: 'credit_card',
        createdById: 'user123',
        receivedAmount: 200000,
        returnAmount: 10000,
        totalAmount: 190000,
        totalOrderedProduct: 3,
        createdAt: '2025-01-01T11:00:00Z',
        updatedAt: '2025-01-01T11:00:00Z',
      );

      when(mockLocalDatasource.createTransaction(any)).thenAnswer((_) async => Result.success(data: 2));

      final result = await repository.syncTransactions([], [remoteTxn]);

      expect(result.$1, 1); // syncedToLocalCount
      expect(result.$2, 0); // syncedToRemoteCount
      verify(mockLocalDatasource.createTransaction(any)).called(1);
    });

    test('updates local when remote is newer', () async {
      final localTxn = TransactionModel(
        id: 1,
        paymentMethod: 'cash',
        createdById: 'user123',
        receivedAmount: 100000,
        returnAmount: 0,
        totalAmount: 100000,
        totalOrderedProduct: 2,
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      );

      final remoteTxn = TransactionModel(
        id: 1,
        paymentMethod: 'credit_card',
        createdById: 'user123',
        receivedAmount: 120000,
        returnAmount: 5000,
        totalAmount: 115000,
        totalOrderedProduct: 3,
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T13:00:00Z', // 3 hours later
      );

      when(mockLocalDatasource.updateTransaction(any)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.syncTransactions([localTxn], [remoteTxn]);

      expect(result.$1, 1); // syncedToLocalCount
      expect(result.$2, 0); // syncedToRemoteCount
      verify(mockLocalDatasource.updateTransaction(remoteTxn)).called(1);
    });

    test('updates remote when local is newer', () async {
      final localTxn = TransactionModel(
        id: 1,
        paymentMethod: 'credit_card',
        createdById: 'user123',
        receivedAmount: 150000,
        returnAmount: 10000,
        totalAmount: 140000,
        totalOrderedProduct: 4,
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T14:00:00Z', // 4 hours later
      );

      final remoteTxn = TransactionModel(
        id: 1,
        paymentMethod: 'cash',
        createdById: 'user123',
        receivedAmount: 100000,
        returnAmount: 0,
        totalAmount: 100000,
        totalOrderedProduct: 2,
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      );

      when(mockRemoteDatasource.updateTransaction(any)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.syncTransactions([localTxn], [remoteTxn]);

      expect(result.$1, 0); // syncedToLocalCount
      expect(result.$2, 1); // syncedToRemoteCount
      verify(mockRemoteDatasource.updateTransaction(localTxn)).called(1);
    });

    test('does not sync when timestamps are within tolerance', () async {
      final localTxn = TransactionModel(
        id: 1,
        paymentMethod: 'cash',
        createdById: 'user123',
        receivedAmount: 100000,
        returnAmount: 0,
        totalAmount: 100000,
        totalOrderedProduct: 2,
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      );

      final remoteTxn = TransactionModel(
        id: 1,
        paymentMethod: 'cash',
        createdById: 'user123',
        receivedAmount: 100000,
        returnAmount: 0,
        totalAmount: 100000,
        totalOrderedProduct: 2,
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:01:00Z', // Only 1 minute difference
      );

      final result = await repository.syncTransactions([localTxn], [remoteTxn]);

      expect(result.$1, 0); // syncedToLocalCount
      expect(result.$2, 0); // syncedToRemoteCount
      verifyNever(mockLocalDatasource.updateTransaction(any));
      verifyNever(mockRemoteDatasource.updateTransaction(any));
    });

    test('skips sync when timestamp is invalid', () async {
      final localTxn = TransactionModel(
        id: 1,
        paymentMethod: 'cash',
        createdById: 'user123',
        receivedAmount: 100000,
        returnAmount: 0,
        totalAmount: 100000,
        totalOrderedProduct: 2,
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: 'invalid-date',
      );

      final remoteTxn = TransactionModel(
        id: 1,
        paymentMethod: 'cash',
        createdById: 'user123',
        receivedAmount: 100000,
        returnAmount: 0,
        totalAmount: 100000,
        totalOrderedProduct: 2,
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      );

      final result = await repository.syncTransactions([localTxn], [remoteTxn]);

      expect(result.$1, 0);
      expect(result.$2, 0);
      verifyNever(mockLocalDatasource.updateTransaction(any));
      verifyNever(mockRemoteDatasource.updateTransaction(any));
    });

    test('handles multiple transactions with mixed scenarios', () async {
      final localOnly = TransactionModel(
        id: 1,
        paymentMethod: 'cash',
        createdById: 'user123',
        receivedAmount: 100000,
        returnAmount: 0,
        totalAmount: 100000,
        totalOrderedProduct: 2,
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      );

      final remoteOnly = TransactionModel(
        id: 2,
        paymentMethod: 'credit_card',
        createdById: 'user123',
        receivedAmount: 200000,
        returnAmount: 10000,
        totalAmount: 190000,
        totalOrderedProduct: 3,
        createdAt: '2025-01-01T11:00:00Z',
        updatedAt: '2025-01-01T11:00:00Z',
      );

      final localNewer = TransactionModel(
        id: 3,
        paymentMethod: 'cash',
        createdById: 'user123',
        receivedAmount: 150000,
        returnAmount: 0,
        totalAmount: 150000,
        totalOrderedProduct: 4,
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T14:00:00Z',
      );

      final remoteNewer = TransactionModel(
        id: 3,
        paymentMethod: 'credit_card',
        createdById: 'user123',
        receivedAmount: 160000,
        returnAmount: 5000,
        totalAmount: 155000,
        totalOrderedProduct: 5,
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      );

      when(mockRemoteDatasource.createTransaction(any)).thenAnswer((_) async => Result.success(data: 1));
      when(mockLocalDatasource.createTransaction(any)).thenAnswer((_) async => Result.success(data: 1));
      when(mockRemoteDatasource.updateTransaction(any)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.syncTransactions(
        [localOnly, localNewer],
        [remoteOnly, remoteNewer],
      );

      // localOnly created remotely, remoteOnly created locally, localNewer updated to remote
      expect(result.$1, 1); // remoteOnly synced to local
      expect(result.$2, 2); // localOnly created + localNewer updated
      verify(mockRemoteDatasource.createTransaction(localOnly)).called(1);
      verify(mockLocalDatasource.createTransaction(remoteOnly)).called(1);
      verify(mockRemoteDatasource.updateTransaction(localNewer)).called(1);
    });

    test('avoids duplicate processing of same transaction ID', () async {
      final localTxn = TransactionModel(
        id: 1,
        paymentMethod: 'cash',
        createdById: 'user123',
        receivedAmount: 100000,
        returnAmount: 0,
        totalAmount: 100000,
        totalOrderedProduct: 2,
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      );

      final remoteTxn = TransactionModel(
        id: 1,
        paymentMethod: 'cash',
        createdById: 'user123',
        receivedAmount: 100000,
        returnAmount: 0,
        totalAmount: 100000,
        totalOrderedProduct: 2,
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:05:00Z',
      );

      await repository.syncTransactions([localTxn], [remoteTxn]);

      // Should only process once, not create duplicate
      verifyNever(mockLocalDatasource.createTransaction(remoteTxn));
      verifyNever(mockRemoteDatasource.createTransaction(localTxn));
    });

    test('handles sync failures gracefully', () async {
      final localTxn = TransactionModel(
        id: 1,
        paymentMethod: 'cash',
        createdById: 'user123',
        receivedAmount: 100000,
        returnAmount: 0,
        totalAmount: 100000,
        totalOrderedProduct: 2,
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      );

      final remoteTxn = TransactionModel(
        id: 2,
        paymentMethod: 'credit_card',
        createdById: 'user123',
        receivedAmount: 200000,
        returnAmount: 10000,
        totalAmount: 190000,
        totalOrderedProduct: 3,
        createdAt: '2025-01-01T11:00:00Z',
        updatedAt: '2025-01-01T11:00:00Z',
      );

      when(mockRemoteDatasource.createTransaction(any)).thenAnswer((_) async => Result.failure(error: 'Network error'));
      when(mockLocalDatasource.createTransaction(any)).thenAnswer((_) async => Result.failure(error: 'Database error'));

      final result = await repository.syncTransactions([localTxn], [remoteTxn]);

      // Should return 0 counts when sync fails
      expect(result.$1, 0);
      expect(result.$2, 0);
    });
  });

  group('Edge cases', () {
    test('handles empty lists', () async {
      final result = await repository.syncTransactions([], []);

      expect(result.$1, 0);
      expect(result.$2, 0);
      verifyNever(mockLocalDatasource.createTransaction(any));
      verifyNever(mockRemoteDatasource.createTransaction(any));
    });

    test('handles null updatedAt timestamps', () async {
      final localTxn = TransactionModel(
        id: 1,
        paymentMethod: 'cash',
        createdById: 'user123',
        receivedAmount: 100000,
        returnAmount: 0,
        totalAmount: 100000,
        totalOrderedProduct: 2,
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: null,
      );

      final remoteTxn = TransactionModel(
        id: 1,
        paymentMethod: 'cash',
        createdById: 'user123',
        receivedAmount: 100000,
        returnAmount: 0,
        totalAmount: 100000,
        totalOrderedProduct: 2,
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: null,
      );

      final result = await repository.syncTransactions([localTxn], [remoteTxn]);

      // Should skip sync when timestamps are null/invalid
      expect(result.$1, 0);
      expect(result.$2, 0);
    });

    test('handles exception in syncTransactions', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.getAllUserTransactions(any)).thenAnswer((_) async => Result.success(data: []));
      when(mockRemoteDatasource.getAllUserTransactions(any)).thenAnswer((_) async => Result.success(data: []));

      final result = await repository.syncAllUserTransactions('user123');

      expect(result.isSuccess, true);
      expect(result.data, 0);
    });
  });

  group('Integration scenarios', () {
    test('full workflow: create, sync, update, delete', () async {
      final transaction = TransactionEntity(
        id: null,
        paymentMethod: 'cash',
        createdById: 'user123',
        customerName: 'Test Customer',
        receivedAmount: 100000,
        returnAmount: 0,
        totalAmount: 100000,
        totalOrderedProduct: 2,
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      );

      // Create
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.createTransaction(any)).thenAnswer((_) async => Result.success(data: 1));
      when(mockRemoteDatasource.createTransaction(any)).thenAnswer((_) async => Result.success(data: 1));

      final createResult = await repository.createTransaction(transaction);
      expect(createResult.isSuccess, true);

      // Update
      final updatedTransaction = transaction.copyWith(
        id: 1,
        totalAmount: 120000,
      );

      when(mockLocalDatasource.updateTransaction(any)).thenAnswer((_) async => Result.success(data: null));
      when(mockRemoteDatasource.updateTransaction(any)).thenAnswer((_) async => Result.success(data: null));

      final updateResult = await repository.updateTransaction(updatedTransaction);
      expect(updateResult.isSuccess, true);

      // Delete
      when(mockLocalDatasource.deleteTransaction(1)).thenAnswer((_) async => Result.success(data: null));
      when(mockRemoteDatasource.deleteTransaction(1)).thenAnswer((_) async => Result.success(data: null));

      final deleteResult = await repository.deleteTransaction(1);
      expect(deleteResult.isSuccess, true);
    });

    test('offline workflow with queued actions', () async {
      final transaction = TransactionEntity(
        id: null,
        paymentMethod: 'cash',
        createdById: 'user123',
        customerName: 'Offline Customer',
        receivedAmount: 50000,
        returnAmount: 0,
        totalAmount: 50000,
        totalOrderedProduct: 1,
      );

      // Create offline
      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.createTransaction(any)).thenAnswer((_) async => Result.success(data: 1));
      when(mockQueuedActionDatasource.createQueuedAction(any)).thenAnswer((_) async => Result.success(data: 1));

      final createResult = await repository.createTransaction(transaction);
      expect(createResult.isSuccess, true);
      verify(mockQueuedActionDatasource.createQueuedAction(any)).called(1);

      // Update offline
      final updatedTransaction = transaction.copyWith(id: 1, totalAmount: 60000);
      when(mockLocalDatasource.updateTransaction(any)).thenAnswer((_) async => Result.success(data: null));

      final updateResult = await repository.updateTransaction(updatedTransaction);
      expect(updateResult.isSuccess, true);
      verify(mockQueuedActionDatasource.createQueuedAction(any)).called(1);

      // Delete offline
      when(mockLocalDatasource.deleteTransaction(1)).thenAnswer((_) async => Result.success(data: null));

      final deleteResult = await repository.deleteTransaction(1);
      expect(deleteResult.isSuccess, true);
      verify(mockQueuedActionDatasource.createQueuedAction(any)).called(1);
    });
  });
}
