import 'package:flutter_pos/app/services/connectivity/ping_service.dart';
import 'package:flutter_pos/core/common/result.dart';
import 'package:flutter_pos/data/datasources/local/product_local_datasource_impl.dart';
import 'package:flutter_pos/data/datasources/local/queued_action_local_datasource_impl.dart';
import 'package:flutter_pos/data/datasources/remote/product_remote_datasource_impl.dart';
import 'package:flutter_pos/data/models/product_model.dart';
import 'package:flutter_pos/data/repositories/product_repository_impl.dart';
import 'package:flutter_pos/domain/entities/product_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'product_repository_impl_test.mocks.dart';

@GenerateMocks([
  PingService,
  ProductLocalDatasourceImpl,
  ProductRemoteDatasourceImpl,
  QueuedActionLocalDatasourceImpl,
])
void main() {
  late ProductRepositoryImpl repository;
  late MockPingService mockPingService;
  late MockProductLocalDatasourceImpl mockLocalDatasource;
  late MockProductRemoteDatasourceImpl mockRemoteDatasource;
  late MockQueuedActionLocalDatasourceImpl mockQueuedActionDatasource;

  setUp(() {
    mockPingService = MockPingService();
    mockLocalDatasource = MockProductLocalDatasourceImpl();
    mockRemoteDatasource = MockProductRemoteDatasourceImpl();
    mockQueuedActionDatasource = MockQueuedActionLocalDatasourceImpl();

    // Provide dummy values for Mockito
    provideDummy<Result<List<ProductModel>>>(
      Result.success(data: <ProductModel>[]),
    );
    provideDummy<Result<ProductModel?>>(
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
    provideDummy<Result<int>>(
      Result.success(data: 0),
    );
    provideDummy<Result<void>>(
      Result.success(data: null),
    );

    repository = ProductRepositoryImpl(
      pingService: mockPingService,
      productLocalDatasource: mockLocalDatasource,
      productRemoteDatasource: mockRemoteDatasource,
      queuedActionLocalDatasource: mockQueuedActionDatasource,
    );
  });

  group('syncAllUserProducts', () {
    const userId = 'user123';
    final localProducts = [
      ProductModel(
        id: 1,
        createdById: userId,
        name: 'Product 1',
        imageUrl: 'https://example.com/image1.jpg',
        stock: 10,
        sold: 5,
        price: 10000,
        description: 'Local product 1',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      ),
    ];
    final remoteProducts = [
      ProductModel(
        id: 2,
        createdById: userId,
        name: 'Product 2',
        imageUrl: 'https://example.com/image2.jpg',
        stock: 20,
        sold: 10,
        price: 20000,
        description: 'Remote product 2',
        createdAt: '2025-01-01T11:00:00Z',
        updatedAt: '2025-01-01T11:00:00Z',
      ),
    ];

    test('returns 0 when not connected', () async {
      when(mockPingService.isConnected).thenReturn(false);

      final result = await repository.syncAllUserProducts(userId);

      expect(result.isSuccess, true);
      expect(result.data, 0);
      verifyNever(mockLocalDatasource.getAllUserProducts(any));
      verifyNever(mockRemoteDatasource.getAllUserProducts(any));
    });

    test('syncs all products when connected', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.getAllUserProducts(userId)).thenAnswer((_) async => Result.success(data: localProducts));
      when(
        mockRemoteDatasource.getAllUserProducts(userId),
      ).thenAnswer((_) async => Result.success(data: remoteProducts));
      when(mockRemoteDatasource.createProduct(any)).thenAnswer((_) async => Result.success(data: 1));
      when(mockLocalDatasource.createProduct(any)).thenAnswer((_) async => Result.success(data: 1));

      final result = await repository.syncAllUserProducts(userId);

      expect(result.isSuccess, true);
      expect(result.data, 2); // Both products synced
      verify(mockLocalDatasource.getAllUserProducts(userId)).called(1);
      verify(mockRemoteDatasource.getAllUserProducts(userId)).called(1);
    });

    test('returns failure when local datasource fails', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(
        mockLocalDatasource.getAllUserProducts(userId),
      ).thenAnswer((_) async => Result.failure(error: 'Local error'));

      final result = await repository.syncAllUserProducts(userId);

      expect(result.isFailure, true);
      expect(result.error, 'Local error');
    });

    test('returns failure when remote datasource fails', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.getAllUserProducts(userId)).thenAnswer((_) async => Result.success(data: localProducts));
      when(
        mockRemoteDatasource.getAllUserProducts(userId),
      ).thenAnswer((_) async => Result.failure(error: 'Remote error'));

      final result = await repository.syncAllUserProducts(userId);

      expect(result.isFailure, true);
      expect(result.error, 'Remote error');
    });
  });

  group('getUserProducts', () {
    const userId = 'user123';
    final localProducts = [
      ProductModel(
        id: 1,
        createdById: userId,
        name: 'Local Product',
        imageUrl: 'https://example.com/local.jpg',
        stock: 15,
        sold: 3,
        price: 15000,
        description: 'Local product description',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T10:00:00Z',
      ),
    ];
    final remoteProducts = [
      ProductModel(
        id: 1,
        createdById: userId,
        name: 'Remote Product',
        imageUrl: 'https://example.com/remote.jpg',
        stock: 20,
        sold: 5,
        price: 15000,
        description: 'Remote product description',
        createdAt: '2025-01-01T10:00:00Z',
        updatedAt: '2025-01-01T11:00:00Z',
      ),
    ];

    test('returns local products when not connected', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(
        mockLocalDatasource.getUserProducts(
          userId,
          orderBy: anyNamed('orderBy'),
          sortBy: anyNamed('sortBy'),
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
          contains: anyNamed('contains'),
        ),
      ).thenAnswer((_) async => Result.success(data: localProducts));

      final result = await repository.getUserProducts(userId);

      expect(result.isSuccess, true);
      expect(result.data!.length, 1);
      expect(result.data!.first.name, 'Local Product');
      verifyNever(
        mockRemoteDatasource.getUserProducts(
          any,
          orderBy: anyNamed('orderBy'),
          sortBy: anyNamed('sortBy'),
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
          contains: anyNamed('contains'),
        ),
      );
    });

    test('returns remote products when synced to local', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(
        mockLocalDatasource.getUserProducts(
          userId,
          orderBy: anyNamed('orderBy'),
          sortBy: anyNamed('sortBy'),
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
          contains: anyNamed('contains'),
        ),
      ).thenAnswer((_) async => Result.success(data: localProducts));
      when(
        mockRemoteDatasource.getUserProducts(
          userId,
          orderBy: anyNamed('orderBy'),
          sortBy: anyNamed('sortBy'),
          limit: anyNamed('limit'),
          offset: anyNamed('offset'),
          contains: anyNamed('contains'),
        ),
      ).thenAnswer((_) async => Result.success(data: remoteProducts));
      when(mockLocalDatasource.updateProduct(any)).thenAnswer((_) async => Result.success(data: null));
      when(mockRemoteDatasource.updateProduct(any)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.getUserProducts(userId);

      expect(result.isSuccess, true);
      expect(result.data!.length, 1);
      expect(result.data!.first.name, 'Remote Product');
    });

    test('passes query parameters correctly', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(
        mockLocalDatasource.getUserProducts(
          userId,
          orderBy: 'name',
          sortBy: 'ASC',
          limit: 20,
          offset: 10,
          contains: 'test',
        ),
      ).thenAnswer((_) async => Result.success(data: []));

      await repository.getUserProducts(
        userId,
        orderBy: 'name',
        sortBy: 'ASC',
        limit: 20,
        offset: 10,
        contains: 'test',
      );

      verify(
        mockLocalDatasource.getUserProducts(
          userId,
          orderBy: 'name',
          sortBy: 'ASC',
          limit: 20,
          offset: 10,
          contains: 'test',
        ),
      ).called(1);
    });
  });

  group('getProduct', () {
    const productId = 1;
    final localProduct = ProductModel(
      id: productId,
      createdById: 'user123',
      name: 'Local Product',
      imageUrl: 'https://example.com/local.jpg',
      stock: 10,
      sold: 2,
      price: 10000,
      description: 'Local description',
      createdAt: '2025-01-01T10:00:00Z',
      updatedAt: '2025-01-01T10:00:00Z',
    );
    final remoteProduct = ProductModel(
      id: productId,
      createdById: 'user123',
      name: 'Remote Product',
      imageUrl: 'https://example.com/remote.jpg',
      stock: 15,
      sold: 5,
      price: 12000,
      description: 'Remote description',
      createdAt: '2025-01-01T10:00:00Z',
      updatedAt: '2025-01-01T12:00:00Z',
    );

    test('returns local product when not connected', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.getProduct(productId)).thenAnswer((_) async => Result.success(data: localProduct));

      final result = await repository.getProduct(productId);

      expect(result.isSuccess, true);
      expect(result.data!.name, 'Local Product');
    });

    test('syncs and returns remote product when remote is newer', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.getProduct(productId)).thenAnswer((_) async => Result.success(data: localProduct));
      when(mockRemoteDatasource.getProduct(productId)).thenAnswer((_) async => Result.success(data: remoteProduct));
      when(mockLocalDatasource.updateProduct(any)).thenAnswer((_) async => Result.success(data: null));
      when(mockRemoteDatasource.updateProduct(any)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.getProduct(productId);

      expect(result.isSuccess, true);
      expect(result.data!.name, 'Remote Product');
      verify(mockLocalDatasource.updateProduct(remoteProduct)).called(1);
    });
  });

  group('createProduct', () {
    final product = ProductEntity(
      id: null,
      createdById: 'user123',
      name: 'New Product',
      imageUrl: 'https://example.com/new.jpg',
      stock: 25,
      sold: 0,
      price: 25000,
      description: 'New product description',
      createdAt: '2025-01-01T10:00:00Z',
      updatedAt: '2025-01-01T10:00:00Z',
    );

    test('creates product locally and remotely when connected', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.createProduct(any)).thenAnswer((_) async => Result.success(data: 1));
      when(mockRemoteDatasource.createProduct(any)).thenAnswer((_) async => Result.success(data: 1));

      final result = await repository.createProduct(product);

      expect(result.isSuccess, true);
      expect(result.data, 1);
      verify(mockLocalDatasource.createProduct(any)).called(1);
      verify(mockRemoteDatasource.createProduct(any)).called(1);
      verifyNever(mockQueuedActionDatasource.createQueuedAction(any));
    });

    test('creates product locally and queues action when not connected', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.createProduct(any)).thenAnswer((_) async => Result.success(data: 1));
      when(mockQueuedActionDatasource.createQueuedAction(any)).thenAnswer((_) async => Result.success(data: 1));

      final result = await repository.createProduct(product);

      expect(result.isSuccess, true);
      verify(mockLocalDatasource.createProduct(any)).called(1);
      verify(mockQueuedActionDatasource.createQueuedAction(any)).called(1);
      verifyNever(mockRemoteDatasource.createProduct(any));
    });

    test('returns failure when local creation fails', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.createProduct(any)).thenAnswer((_) async => Result.failure(error: 'Local error'));

      final result = await repository.createProduct(product);

      expect(result.isFailure, true);
      expect(result.error, 'Local error');
    });
  });

  group('updateProduct', () {
    final product = ProductEntity(
      id: 1,
      createdById: 'user123',
      name: 'Updated Product',
      imageUrl: 'https://example.com/updated.jpg',
      stock: 30,
      sold: 8,
      price: 30000,
      description: 'Updated product description',
      createdAt: '2025-01-01T10:00:00Z',
      updatedAt: '2025-01-01T12:00:00Z',
    );

    test('updates product locally and remotely when connected', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.updateProduct(any)).thenAnswer((_) async => Result.success(data: null));
      when(mockRemoteDatasource.updateProduct(any)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.updateProduct(product);

      expect(result.isSuccess, true);
      verify(mockLocalDatasource.updateProduct(any)).called(1);
      verify(mockRemoteDatasource.updateProduct(any)).called(1);
      verifyNever(mockQueuedActionDatasource.createQueuedAction(any));
    });

    test('updates product locally and queues action when not connected', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.updateProduct(any)).thenAnswer((_) async => Result.success(data: null));
      when(mockQueuedActionDatasource.createQueuedAction(any)).thenAnswer((_) async => Result.success(data: 1));

      final result = await repository.updateProduct(product);

      expect(result.isSuccess, true);
      verify(mockLocalDatasource.updateProduct(any)).called(1);
      verify(mockQueuedActionDatasource.createQueuedAction(any)).called(1);
      verifyNever(mockRemoteDatasource.updateProduct(any));
    });
  });

  group('deleteProduct', () {
    const productId = 1;

    test('deletes product locally and remotely when connected', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.deleteProduct(productId)).thenAnswer((_) async => Result.success(data: null));
      when(mockRemoteDatasource.deleteProduct(productId)).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.deleteProduct(productId);

      expect(result.isSuccess, true);
      verify(mockLocalDatasource.deleteProduct(productId)).called(1);
      verify(mockRemoteDatasource.deleteProduct(productId)).called(1);
      verifyNever(mockQueuedActionDatasource.createQueuedAction(any));
    });

    test('deletes product locally and queues action when not connected', () async {
      when(mockPingService.isConnected).thenReturn(false);
      when(mockLocalDatasource.deleteProduct(productId)).thenAnswer((_) async => Result.success(data: null));
      when(mockQueuedActionDatasource.createQueuedAction(any)).thenAnswer((_) async => Result.success(data: 1));

      final result = await repository.deleteProduct(productId);

      expect(result.isSuccess, true);
      verify(mockLocalDatasource.deleteProduct(productId)).called(1);
      verify(mockQueuedActionDatasource.createQueuedAction(any)).called(1);
      verifyNever(mockRemoteDatasource.deleteProduct(productId));
    });

    test('returns failure when remote deletion fails', () async {
      when(mockPingService.isConnected).thenReturn(true);
      when(mockLocalDatasource.deleteProduct(productId)).thenAnswer((_) async => Result.success(data: null));
      when(
        mockRemoteDatasource.deleteProduct(productId),
      ).thenAnswer((_) async => Result.failure(error: 'Remote error'));

      final result = await repository.deleteProduct(productId);

      expect(result.isFailure, true);
      expect(result.error, 'Remote error');
    });
  });
}
