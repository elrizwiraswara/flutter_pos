import 'dart:convert';

import 'package:flutter_pos/core/services/connectivity/ping_service.dart';
import 'package:flutter_pos/core/common/result.dart';
import 'package:flutter_pos/data/datasources/local/queued_action_local_datasource_impl.dart';
import 'package:flutter_pos/data/datasources/remote/product_remote_datasource_impl.dart';
import 'package:flutter_pos/data/datasources/remote/transaction_remote_datasource_impl.dart';
import 'package:flutter_pos/data/datasources/remote/user_remote_datasource_impl.dart';
import 'package:flutter_pos/data/models/product_model.dart';
import 'package:flutter_pos/data/models/queued_action_model.dart';
import 'package:flutter_pos/data/models/transaction_model.dart';
import 'package:flutter_pos/data/models/user_model.dart';
import 'package:flutter_pos/data/repositories/queued_action_repository_impl.dart';
import 'package:flutter_pos/domain/entities/queued_action_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'queued_action_repository_impl_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  PingService,
  QueuedActionLocalDatasourceImpl,
  UserRemoteDatasourceImpl,
  TransactionRemoteDatasourceImpl,
  ProductRemoteDatasourceImpl,
])
void main() {
  late QueuedActionRepositoryImpl repository;
  late MockPingService mockPingService;
  late MockQueuedActionLocalDatasourceImpl mockQueuedActionDatasource;
  late MockUserRemoteDatasourceImpl mockUserRemoteDatasource;
  late MockTransactionRemoteDatasourceImpl mockTransactionRemoteDatasource;
  late MockProductRemoteDatasourceImpl mockProductRemoteDatasource;

  setUp(() {
    mockPingService = MockPingService();
    mockQueuedActionDatasource = MockQueuedActionLocalDatasourceImpl();
    mockUserRemoteDatasource = MockUserRemoteDatasourceImpl();
    mockTransactionRemoteDatasource = MockTransactionRemoteDatasourceImpl();
    mockProductRemoteDatasource = MockProductRemoteDatasourceImpl();

    // Provide dummy values for Mockito
    provideDummy<Result<List<QueuedActionModel>>>(
      Result.success(data: <QueuedActionModel>[]),
    );
    provideDummy<Result<void>>(
      Result.success(data: null),
    );
    provideDummy<Result<int>>(
      Result.success(data: 0),
    );
    provideDummy<Result<String>>(
      Result.success(data: ''),
    );
    provideDummy<Result<UserModel>>(
      Result.success(
        data: UserModel(
          id: '',
          name: '',
          email: '',
          phone: '',
        ),
      ),
    );
    provideDummy<Result<TransactionModel>>(
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
    provideDummy<Result<ProductModel>>(
      Result.success(
        data: ProductModel(
          id: 0,
          createdById: '',
          name: '',
          imageUrl: '',
          stock: 0,
          sold: 0,
          price: 0,
        ),
      ),
    );

    repository = QueuedActionRepositoryImpl(
      pingService: mockPingService,
      queuedActionLocalDatasource: mockQueuedActionDatasource,
      userRemoteDatasource: mockUserRemoteDatasource,
      transactionRemoteDatasource: mockTransactionRemoteDatasource,
      productRemoteDatasource: mockProductRemoteDatasource,
    );
  });

  group('getAllQueuedAction', () {
    test('returns list of queued actions successfully', () async {
      final queuedActions = [
        QueuedActionModel(
          id: 1,
          repository: 'ProductRepositoryImpl',
          method: 'createProduct',
          param: '{"id":1,"name":"Product"}',
          isCritical: true,
          createdAt: '2025-01-01T10:00:00Z',
        ),
      ];

      when(
        mockQueuedActionDatasource.getAllUserQueuedAction(),
      ).thenAnswer((_) async => Result.success(data: queuedActions));

      final result = await repository.getAllQueuedAction();

      expect(result.isSuccess, true);
      expect(result.data!.length, 1);
      expect(result.data!.first.repository, 'ProductRepositoryImpl');
    });

    test('returns failure when datasource fails', () async {
      when(
        mockQueuedActionDatasource.getAllUserQueuedAction(),
      ).thenAnswer((_) async => Result.failure(error: 'Database error'));

      final result = await repository.getAllQueuedAction();

      expect(result.isFailure, true);
      expect(result.error, 'Database error');
    });

    test('handles exception', () async {
      when(mockQueuedActionDatasource.getAllUserQueuedAction()).thenThrow(Exception('Unexpected error'));

      final result = await repository.getAllQueuedAction();

      expect(result.isFailure, true);
    });
  });

  group('executeAllQueuedActions', () {
    test('returns empty list when queue is empty', () async {
      final result = await repository.executeAllQueuedActions([]);

      expect(result.isSuccess, true);
      expect(result.data, []);
    });

    test('executes all queued actions when connected', () async {
      when(mockPingService.isConnected).thenReturn(true);

      final productData = ProductModel(
        id: 1,
        createdById: 'user123',
        name: 'Product 1',
        imageUrl: 'https://example.com/image.jpg',
        stock: 10,
        sold: 0,
        price: 10000,
      );

      final queues = [
        QueuedActionEntity(
          id: 1,
          repository: 'ProductRepositoryImpl',
          method: 'createProduct',
          param: jsonEncode(productData.toJson()),
          isCritical: true,
          createdAt: '2025-01-01T10:00:00Z',
        ),
      ];

      when(mockProductRemoteDatasource.createProduct(any)).thenAnswer((_) async => Result.success(data: 1));
      when(mockQueuedActionDatasource.deleteQueuedAction(1)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.executeAllQueuedActions(queues);

      expect(result.isSuccess, true);
      expect(result.data!.length, 1);
      expect(result.data!.first, true);
    });

    test('skips execution when connection is lost during process', () async {
      when(mockPingService.isConnected).thenReturn(false);

      final queues = [
        QueuedActionEntity(
          id: 1,
          repository: 'ProductRepositoryImpl',
          method: 'createProduct',
          param: '{"id":1}',
          isCritical: true,
          createdAt: '2025-01-01T10:00:00Z',
        ),
      ];

      final result = await repository.executeAllQueuedActions(queues);

      expect(result.isSuccess, true);
      expect(result.data, []);
      verifyNever(mockProductRemoteDatasource.createProduct(any));
    });

    test('returns mixed results when some actions fail', () async {
      when(mockPingService.isConnected).thenReturn(true);

      final productData = ProductModel(
        id: 1,
        createdById: 'user123',
        name: 'Product 1',
        imageUrl: 'https://example.com/image.jpg',
        stock: 10,
        sold: 0,
        price: 10000,
      );

      final queues = [
        QueuedActionEntity(
          id: 1,
          repository: 'ProductRepositoryImpl',
          method: 'createProduct',
          param: jsonEncode(productData.toJson()),
          isCritical: true,
          createdAt: '2025-01-01T10:00:00Z',
        ),
        QueuedActionEntity(
          id: 2,
          repository: 'ProductRepositoryImpl',
          method: 'deleteProduct',
          param: '99',
          isCritical: true,
          createdAt: '2025-01-01T10:00:00Z',
        ),
      ];

      when(mockProductRemoteDatasource.createProduct(any)).thenAnswer((_) async => Result.success(data: 1));
      when(mockQueuedActionDatasource.deleteQueuedAction(1)).thenAnswer((_) async => Result.success(data: null));
      when(
        mockProductRemoteDatasource.deleteProduct(99),
      ).thenAnswer((_) async => Result.failure(error: 'Product not found'));

      final result = await repository.executeAllQueuedActions(queues);

      expect(result.isSuccess, true);
      expect(result.data!.length, 2);
      expect(result.data!.first, true);
      expect(result.data!.last, false);
    });
  });

  group('executeQueuedAction - ProductRepositoryImpl', () {
    test('executes createProduct successfully', () async {
      final productData = ProductModel(
        id: 1,
        createdById: 'user123',
        name: 'Product 1',
        imageUrl: 'https://example.com/image.jpg',
        stock: 10,
        sold: 0,
        price: 10000,
      );

      final queue = QueuedActionEntity(
        id: 1,
        repository: 'ProductRepositoryImpl',
        method: 'createProduct',
        param: jsonEncode(productData.toJson()),
        isCritical: true,
        createdAt: '2025-01-01T10:00:00Z',
      );

      when(mockProductRemoteDatasource.createProduct(any)).thenAnswer((_) async => Result.success(data: 1));
      when(mockQueuedActionDatasource.deleteQueuedAction(1)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.executeQueuedAction(queue);

      expect(result.isSuccess, true);
      expect(result.data, true);
      verify(mockProductRemoteDatasource.createProduct(any)).called(1);
      verify(mockQueuedActionDatasource.deleteQueuedAction(1)).called(1);
    });

    test('executes updateProduct successfully', () async {
      final productData = ProductModel(
        id: 1,
        createdById: 'user123',
        name: 'Updated Product',
        imageUrl: 'https://example.com/image.jpg',
        stock: 15,
        sold: 5,
        price: 15000,
      );

      final queue = QueuedActionEntity(
        id: 2,
        repository: 'ProductRepositoryImpl',
        method: 'updateProduct',
        param: jsonEncode(productData.toJson()),
        isCritical: true,
        createdAt: '2025-01-01T10:00:00Z',
      );

      when(mockProductRemoteDatasource.updateProduct(any)).thenAnswer((_) async => Result.success(data: null));
      when(mockQueuedActionDatasource.deleteQueuedAction(2)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.executeQueuedAction(queue);

      expect(result.isSuccess, true);
      verify(mockProductRemoteDatasource.updateProduct(any)).called(1);
      verify(mockQueuedActionDatasource.deleteQueuedAction(2)).called(1);
    });

    test('executes deleteProduct successfully', () async {
      final queue = QueuedActionEntity(
        id: 3,
        repository: 'ProductRepositoryImpl',
        method: 'deleteProduct',
        param: '1',
        isCritical: true,
        createdAt: '2025-01-01T10:00:00Z',
      );

      when(mockProductRemoteDatasource.deleteProduct(1)).thenAnswer((_) async => Result.success(data: null));
      when(mockQueuedActionDatasource.deleteQueuedAction(3)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.executeQueuedAction(queue);

      expect(result.isSuccess, true);
      verify(mockProductRemoteDatasource.deleteProduct(1)).called(1);
      verify(mockQueuedActionDatasource.deleteQueuedAction(3)).called(1);
    });

    test('returns failure when remote datasource fails', () async {
      final productData = ProductModel(
        id: 1,
        createdById: 'user123',
        name: 'Product 1',
        imageUrl: 'https://example.com/image.jpg',
        stock: 10,
        sold: 0,
        price: 10000,
      );

      final queue = QueuedActionEntity(
        id: 1,
        repository: 'ProductRepositoryImpl',
        method: 'createProduct',
        param: jsonEncode(productData.toJson()),
        isCritical: true,
        createdAt: '2025-01-01T10:00:00Z',
      );

      when(
        mockProductRemoteDatasource.createProduct(any),
      ).thenAnswer((_) async => Result.failure(error: 'Network error'));

      final result = await repository.executeQueuedAction(queue);

      expect(result.isFailure, true);
      expect(result.error, 'Network error');
      verifyNever(mockQueuedActionDatasource.deleteQueuedAction(any));
    });

    test('returns failure when delete queue fails', () async {
      final productData = ProductModel(
        id: 1,
        createdById: 'user123',
        name: 'Product 1',
        imageUrl: 'https://example.com/image.jpg',
        stock: 10,
        sold: 0,
        price: 10000,
      );

      final queue = QueuedActionEntity(
        id: 1,
        repository: 'ProductRepositoryImpl',
        method: 'createProduct',
        param: jsonEncode(productData.toJson()),
        isCritical: true,
        createdAt: '2025-01-01T10:00:00Z',
      );

      when(mockProductRemoteDatasource.createProduct(any)).thenAnswer((_) async => Result.success(data: 1));
      when(
        mockQueuedActionDatasource.deleteQueuedAction(1),
      ).thenAnswer((_) async => Result.failure(error: 'Delete failed'));

      final result = await repository.executeQueuedAction(queue);

      expect(result.isFailure, true);
    });
  });

  group('executeQueuedAction - UserRepositoryImpl', () {
    test('executes createUser successfully', () async {
      final userData = UserModel(
        id: 'user123',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '1234567890',
      );

      final queue = QueuedActionEntity(
        id: 1,
        repository: 'UserRepositoryImpl',
        method: 'createUser',
        param: jsonEncode(userData.toJson()),
        isCritical: true,
        createdAt: '2025-01-01T10:00:00Z',
      );

      when(mockUserRemoteDatasource.createUser(any)).thenAnswer((_) async => Result.success(data: userData.id));
      when(mockQueuedActionDatasource.deleteQueuedAction(1)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.executeQueuedAction(queue);

      expect(result.isSuccess, true);
      verify(mockUserRemoteDatasource.createUser(any)).called(1);
      verify(mockQueuedActionDatasource.deleteQueuedAction(1)).called(1);
    });

    test('executes updateUser successfully', () async {
      final userData = UserModel(
        id: 'user123',
        name: 'John Updated',
        email: 'john@example.com',
        phone: '1234567890',
      );

      final queue = QueuedActionEntity(
        id: 2,
        repository: 'UserRepositoryImpl',
        method: 'updateUser',
        param: jsonEncode(userData.toJson()),
        isCritical: true,
        createdAt: '2025-01-01T10:00:00Z',
      );

      when(mockUserRemoteDatasource.updateUser(any)).thenAnswer((_) async => Result.success(data: null));
      when(mockQueuedActionDatasource.deleteQueuedAction(2)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.executeQueuedAction(queue);

      expect(result.isSuccess, true);
      verify(mockUserRemoteDatasource.updateUser(any)).called(1);
    });

    test('executes deleteUser successfully', () async {
      final queue = QueuedActionEntity(
        id: 3,
        repository: 'UserRepositoryImpl',
        method: 'deleteUser',
        param: 'user123',
        isCritical: true,
        createdAt: '2025-01-01T10:00:00Z',
      );

      when(mockUserRemoteDatasource.deleteUser('user123')).thenAnswer((_) async => Result.success(data: null));
      when(mockQueuedActionDatasource.deleteQueuedAction(3)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.executeQueuedAction(queue);

      expect(result.isSuccess, true);
      verify(mockUserRemoteDatasource.deleteUser('user123')).called(1);
    });
  });

  group('executeQueuedAction - TransactionRepositoryImpl', () {
    test('executes createTransaction successfully', () async {
      final transactionData = TransactionModel(
        id: 1,
        paymentMethod: 'cash',
        customerName: 'John Doe',
        description: 'Purchase products',
        createdById: 'user123',
        receivedAmount: 100000,
        returnAmount: 10000,
        totalAmount: 90000,
        totalOrderedProduct: 3,
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      );

      final queue = QueuedActionEntity(
        id: 1,
        repository: 'TransactionRepositoryImpl',
        method: 'createTransaction',
        param: jsonEncode(transactionData.toJson()),
        isCritical: true,
        createdAt: '2025-01-01T10:00:00Z',
      );

      when(mockTransactionRemoteDatasource.createTransaction(any)).thenAnswer((_) async => Result.success(data: 1));
      when(mockQueuedActionDatasource.deleteQueuedAction(1)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.executeQueuedAction(queue);

      expect(result.isSuccess, true);
      verify(mockTransactionRemoteDatasource.createTransaction(any)).called(1);
    });

    test('executes updateTransaction successfully', () async {
      final transactionData = TransactionModel(
        id: 1,
        paymentMethod: 'credit_card',
        customerName: 'Jane Doe',
        description: 'Updated purchase',
        createdById: 'user123',
        receivedAmount: 150000,
        returnAmount: 5000,
        totalAmount: 145000,
        totalOrderedProduct: 5,
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T12:00:00Z',
      );

      final queue = QueuedActionEntity(
        id: 2,
        repository: 'TransactionRepositoryImpl',
        method: 'updateTransaction',
        param: jsonEncode(transactionData.toJson()),
        isCritical: true,
        createdAt: '2025-01-01T10:00:00Z',
      );

      when(mockTransactionRemoteDatasource.updateTransaction(any)).thenAnswer((_) async => Result.success(data: null));
      when(mockQueuedActionDatasource.deleteQueuedAction(2)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.executeQueuedAction(queue);

      expect(result.isSuccess, true);
      verify(mockTransactionRemoteDatasource.updateTransaction(any)).called(1);
    });

    test('executes deleteTransaction successfully', () async {
      final queue = QueuedActionEntity(
        id: 3,
        repository: 'TransactionRepositoryImpl',
        method: 'deleteTransaction',
        param: '1',
        isCritical: true,
        createdAt: '2025-01-01T10:00:00Z',
      );

      when(mockTransactionRemoteDatasource.deleteTransaction(1)).thenAnswer((_) async => Result.success(data: null));
      when(mockQueuedActionDatasource.deleteQueuedAction(3)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.executeQueuedAction(queue);

      expect(result.isSuccess, true);
      verify(mockTransactionRemoteDatasource.deleteTransaction(1)).called(1);
    });
  });

  group('executeQueuedAction - Unknown repository/method', () {
    test('returns success for unknown repository', () async {
      final queue = QueuedActionEntity(
        id: 1,
        repository: 'UnknownRepository',
        method: 'someMethod',
        param: '{}',
        isCritical: true,
        createdAt: '2025-01-01T10:00:00Z',
      );

      when(mockQueuedActionDatasource.deleteQueuedAction(1)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.executeQueuedAction(queue);

      expect(result.isSuccess, true);
      verify(mockQueuedActionDatasource.deleteQueuedAction(1)).called(1);
    });

    test('returns success for unknown method', () async {
      final queue = QueuedActionEntity(
        id: 1,
        repository: 'ProductRepositoryImpl',
        method: 'unknownMethod',
        param: '{}',
        isCritical: true,
        createdAt: '2025-01-01T10:00:00Z',
      );

      when(mockQueuedActionDatasource.deleteQueuedAction(1)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.executeQueuedAction(queue);

      expect(result.isSuccess, true);
      verify(mockQueuedActionDatasource.deleteQueuedAction(1)).called(1);
    });
  });

  group('executeQueuedAction - Error handling', () {
    test('handles JSON decode exception', () async {
      final queue = QueuedActionEntity(
        id: 1,
        repository: 'ProductRepositoryImpl',
        method: 'createProduct',
        param: 'invalid json',
        isCritical: true,
        createdAt: '2025-01-01T10:00:00Z',
      );

      final result = await repository.executeQueuedAction(queue);

      expect(result.isFailure, true);
      verifyNever(mockQueuedActionDatasource.deleteQueuedAction(any));
    });

    test('handles number parse exception for delete methods', () async {
      final queue = QueuedActionEntity(
        id: 1,
        repository: 'ProductRepositoryImpl',
        method: 'deleteProduct',
        param: 'not_a_number',
        isCritical: true,
        createdAt: '2025-01-01T10:00:00Z',
      );

      final result = await repository.executeQueuedAction(queue);

      expect(result.isFailure, true);
      verifyNever(mockQueuedActionDatasource.deleteQueuedAction(any));
    });
  });
}
