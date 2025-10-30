import 'package:flutter_pos/core/common/result.dart';
import 'package:flutter_pos/domain/entities/product_entity.dart';
import 'package:flutter_pos/domain/repositories/product_repository.dart';
import 'package:flutter_pos/domain/usecases/params/base_params.dart';
import 'package:flutter_pos/domain/usecases/product_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'product_usecases_test.mocks.dart';

// This will generate the mock class
@GenerateMocks([ProductRepository])
void main() {
  late MockProductRepository mockProductRepository;

  setUpAll(() {
    // Provide dummy values for complex types
    provideDummy<Result<int>>(Result<int>.success(data: 0));
    provideDummy<Result<void>>(Result<void>.success(data: null));
    provideDummy<Result<List<ProductEntity>>>(Result<List<ProductEntity>>.success(data: []));
    provideDummy<Result<ProductEntity?>>(Result<ProductEntity?>.success(data: null));
  });

  setUp(() {
    mockProductRepository = MockProductRepository();
  });

  group('SyncAllUserProductsUsecase', () {
    late SyncAllUserProductsUsecase usecase;

    setUp(() {
      usecase = SyncAllUserProductsUsecase(mockProductRepository);
    });

    test('should sync all user products successfully', () async {
      // arrange
      const userId = 'user123';
      const syncedCount = 10;
      final result = Result<int>.success(data: syncedCount);

      when(mockProductRepository.syncAllUserProducts(userId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(userId);

      // assert
      expect(response, result);
      verify(mockProductRepository.syncAllUserProducts(userId));
      verifyNoMoreInteractions(mockProductRepository);
    });

    test('should return failure when sync fails', () async {
      // arrange
      const userId = 'user123';
      final result = Result<int>.failure(error: 'Sync failed');

      when(mockProductRepository.syncAllUserProducts(userId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(userId);

      // assert
      expect(response, result);
      verify(mockProductRepository.syncAllUserProducts(userId));
    });
  });

  group('GetUserProductsUsecase', () {
    late GetUserProductsUsecase usecase;

    setUp(() {
      usecase = GetUserProductsUsecase(mockProductRepository);
    });

    test('should get user products with all parameters', () async {
      // arrange
      final params = BaseParams(
        param: 'user123',
        orderBy: 'name',
        sortBy: 'asc',
        limit: 10,
        offset: 0,
        contains: 'search',
      );
      final products = [
        ProductEntity(id: 1, name: 'Product 1', createdById: '', imageUrl: '', stock: 1, price: 100),
        ProductEntity(id: 2, name: 'Product 2', createdById: '', imageUrl: '', stock: 1, price: 100),
      ];
      final result = Result<List<ProductEntity>>.success(data: products);

      when(
        mockProductRepository.getUserProducts(
          params.param,
          orderBy: params.orderBy,
          sortBy: params.sortBy,
          limit: params.limit,
          offset: params.offset,
          contains: params.contains,
        ),
      ).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(params);

      // assert
      expect(response, result);
      verify(
        mockProductRepository.getUserProducts(
          params.param,
          orderBy: params.orderBy,
          sortBy: params.sortBy,
          limit: params.limit,
          offset: params.offset,
          contains: params.contains,
        ),
      );
      verifyNoMoreInteractions(mockProductRepository);
    });

    test('should return empty list when no products found', () async {
      // arrange
      final params = BaseParams(param: 'user123');
      final result = Result<List<ProductEntity>>.success(data: []);

      when(
        mockProductRepository.getUserProducts(
          params.param,
          orderBy: params.orderBy,
          sortBy: params.sortBy,
          limit: params.limit,
          offset: params.offset,
          contains: params.contains,
        ),
      ).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(params);

      // assert
      expect(response.data, isEmpty);
      verify(
        mockProductRepository.getUserProducts(
          params.param,
          orderBy: params.orderBy,
          sortBy: params.sortBy,
          limit: params.limit,
          offset: params.offset,
          contains: params.contains,
        ),
      );
    });
  });

  group('GetProductUsecase', () {
    late GetProductUsecase usecase;

    setUp(() {
      usecase = GetProductUsecase(mockProductRepository);
    });

    test('should get product by id successfully', () async {
      // arrange
      const productId = 1;
      final product = ProductEntity(
        id: productId,
        name: 'Product 1',
        createdById: '',
        imageUrl: '',
        stock: 1,
        price: 100,
      );
      final result = Result<ProductEntity?>.success(data: product);

      when(mockProductRepository.getProduct(productId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(productId);

      // assert
      expect(response, result);
      expect(response.data?.id, productId);
      verify(mockProductRepository.getProduct(productId));
      verifyNoMoreInteractions(mockProductRepository);
    });

    test('should return null when product not found', () async {
      // arrange
      const productId = 999;
      final result = Result<ProductEntity?>.success(data: null);

      when(mockProductRepository.getProduct(productId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(productId);

      // assert
      expect(response.data, isNull);
      verify(mockProductRepository.getProduct(productId));
    });
  });

  group('CreateProductUsecase', () {
    late CreateProductUsecase usecase;

    setUp(() {
      usecase = CreateProductUsecase(mockProductRepository);
    });

    test('should create product successfully', () async {
      // arrange
      final product = ProductEntity(name: 'New Product', createdById: '', imageUrl: '', stock: 1, price: 100);
      const createdId = 1;
      final result = Result<int>.success(data: createdId);

      when(mockProductRepository.createProduct(product)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(product);

      // assert
      expect(response, result);
      expect(response.data, createdId);
      verify(mockProductRepository.createProduct(product));
      verifyNoMoreInteractions(mockProductRepository);
    });

    test('should return failure when creation fails', () async {
      // arrange
      final product = ProductEntity(name: 'New Product', createdById: '', imageUrl: '', stock: 1, price: 100);
      final result = Result<int>.failure(error: 'Creation failed');

      when(mockProductRepository.createProduct(product)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(product);

      // assert
      expect(response.isFailure, true);
      verify(mockProductRepository.createProduct(product));
    });
  });

  group('UpdateProductUsecase', () {
    late UpdateProductUsecase usecase;

    setUp(() {
      usecase = UpdateProductUsecase(mockProductRepository);
    });

    test('should update product successfully', () async {
      // arrange
      final product = ProductEntity(
        id: 1,
        name: 'Updated Product',
        createdById: '',
        imageUrl: '',
        stock: 1,
        price: 100,
      );

      final result = Result<void>.success(data: null);

      when(mockProductRepository.updateProduct(product)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(product);

      // assert
      expect(response, result);
      expect(response.isSuccess, true);
      verify(mockProductRepository.updateProduct(product));
      verifyNoMoreInteractions(mockProductRepository);
    });

    test('should return failure when update fails', () async {
      // arrange
      final product = ProductEntity(
        id: 1,
        name: 'Updated Product',
        createdById: '',
        imageUrl: '',
        stock: 1,
        price: 100,
      );

      final result = Result<void>.failure(error: 'Update failed');

      when(mockProductRepository.updateProduct(product)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(product);

      // assert
      expect(response.isFailure, true);
      verify(mockProductRepository.updateProduct(product));
    });
  });

  group('DeleteProductUsecase', () {
    late DeleteProductUsecase usecase;

    setUp(() {
      usecase = DeleteProductUsecase(mockProductRepository);
    });

    test('should delete product successfully', () async {
      // arrange
      const productId = 1;
      final result = Result<void>.success(data: null);

      when(mockProductRepository.deleteProduct(productId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(productId);

      // assert
      expect(response, result);
      expect(response.isSuccess, true);
      verify(mockProductRepository.deleteProduct(productId));
      verifyNoMoreInteractions(mockProductRepository);
    });

    test('should return failure when deletion fails', () async {
      // arrange
      const productId = 1;
      final result = Result<void>.failure(error: 'Deletion failed');

      when(mockProductRepository.deleteProduct(productId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(productId);

      // assert
      expect(response.isFailure, true);
      verify(mockProductRepository.deleteProduct(productId));
    });

    test('should handle product not found scenario', () async {
      // arrange
      const productId = 999;
      final result = Result<void>.failure(error: 'Product not found');

      when(mockProductRepository.deleteProduct(productId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(productId);

      // assert
      expect(response.isFailure, true);
      verify(mockProductRepository.deleteProduct(productId));
    });
  });
}
