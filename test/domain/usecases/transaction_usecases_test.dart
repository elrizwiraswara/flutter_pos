import 'package:flutter_pos/core/common/result.dart';
import 'package:flutter_pos/domain/entities/transaction_entity.dart';
import 'package:flutter_pos/domain/repositories/transaction_repository.dart';
import 'package:flutter_pos/domain/usecases/params/base_params.dart';
import 'package:flutter_pos/domain/usecases/transaction_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'transaction_usecases_test.mocks.dart';

// This will generate the mock class
@GenerateMocks([TransactionRepository])
void main() {
  late MockTransactionRepository mockTransactionRepository;

  setUpAll(() {
    // Provide dummy values for complex types
    provideDummy<Result<int>>(Result<int>.success(data: 0));
    provideDummy<Result<void>>(Result<void>.success(data: null));
    provideDummy<Result<List<TransactionEntity>>>(Result<List<TransactionEntity>>.success(data: []));
    provideDummy<Result<TransactionEntity?>>(Result<TransactionEntity?>.success(data: null));
  });

  setUp(() {
    mockTransactionRepository = MockTransactionRepository();
  });

  group('SyncAllUserTransactionsUsecase', () {
    late SyncAllUserTransactionsUsecase usecase;

    setUp(() {
      usecase = SyncAllUserTransactionsUsecase(mockTransactionRepository);
    });

    test('should sync all user transactions successfully', () async {
      // arrange
      const userId = 'user123';
      const syncedCount = 15;
      final result = Result<int>.success(data: syncedCount);

      when(mockTransactionRepository.syncAllUserTransactions(userId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(userId);

      // assert
      expect(response, result);
      expect(response.data, syncedCount);
      verify(mockTransactionRepository.syncAllUserTransactions(userId));
      verifyNoMoreInteractions(mockTransactionRepository);
    });

    test('should return failure when sync fails', () async {
      // arrange
      const userId = 'user123';
      final result = Result<int>.failure(error: 'Sync failed');

      when(mockTransactionRepository.syncAllUserTransactions(userId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(userId);

      // assert
      expect(response.isFailure, true);
      verify(mockTransactionRepository.syncAllUserTransactions(userId));
    });

    test('should handle network error during sync', () async {
      // arrange
      const userId = 'user123';
      final result = Result<int>.failure(error: 'Network error');

      when(mockTransactionRepository.syncAllUserTransactions(userId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(userId);

      // assert
      expect(response.isFailure, true);
      verify(mockTransactionRepository.syncAllUserTransactions(userId));
    });
  });

  group('GetUserTransactionsUsecase', () {
    late GetUserTransactionsUsecase usecase;

    setUp(() {
      usecase = GetUserTransactionsUsecase(mockTransactionRepository);
    });

    test('should get user transactions with all parameters', () async {
      // arrange
      final params = BaseParams(
        param: 'user123',
        orderBy: 'date',
        sortBy: 'desc',
        limit: 20,
        offset: 0,
        contains: 'payment',
      );
      final transactions = [
        TransactionEntity(
          id: 1,
          description: 'Payment 1',
          paymentMethod: '',
          createdById: '',
          receivedAmount: 100,
          returnAmount: 0,
          totalAmount: 100,
          totalOrderedProduct: 1,
        ),
        TransactionEntity(
          id: 2,
          description: 'Payment 2',
          paymentMethod: '',
          createdById: '',
          receivedAmount: 100,
          returnAmount: 0,
          totalAmount: 100,
          totalOrderedProduct: 1,
        ),
      ];
      final result = Result<List<TransactionEntity>>.success(data: transactions);

      when(
        mockTransactionRepository.getUserTransactions(
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
      expect(response.data?.length, 2);
      verify(
        mockTransactionRepository.getUserTransactions(
          params.param,
          orderBy: params.orderBy,
          sortBy: params.sortBy,
          limit: params.limit,
          offset: params.offset,
          contains: params.contains,
        ),
      );
      verifyNoMoreInteractions(mockTransactionRepository);
    });

    test('should return empty list when no transactions found', () async {
      // arrange
      final params = BaseParams(param: 'user123');
      final result = Result<List<TransactionEntity>>.success(data: []);

      when(
        mockTransactionRepository.getUserTransactions(
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
        mockTransactionRepository.getUserTransactions(
          params.param,
          orderBy: params.orderBy,
          sortBy: params.sortBy,
          limit: params.limit,
          offset: params.offset,
          contains: params.contains,
        ),
      );
    });

    test('should handle pagination correctly', () async {
      // arrange
      final params = BaseParams(
        param: 'user123',
        limit: 10,
        offset: 20,
      );
      final transactions = [
        TransactionEntity(
          id: 21,
          paymentMethod: '',
          createdById: '',
          receivedAmount: 100,
          returnAmount: 0,
          totalAmount: 100,
          totalOrderedProduct: 1,
        ),
        TransactionEntity(
          id: 22,
          paymentMethod: '',
          createdById: '',
          receivedAmount: 100,
          returnAmount: 0,
          totalAmount: 100,
          totalOrderedProduct: 1,
        ),
      ];
      final result = Result<List<TransactionEntity>>.success(data: transactions);

      when(
        mockTransactionRepository.getUserTransactions(
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
      expect(response.data?.length, 2);
      verify(
        mockTransactionRepository.getUserTransactions(
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

  group('GetTransactionUsecase', () {
    late GetTransactionUsecase usecase;

    setUp(() {
      usecase = GetTransactionUsecase(mockTransactionRepository);
    });

    test('should get transaction by id successfully', () async {
      // arrange
      const transactionId = 1;
      final transaction = TransactionEntity(
        id: transactionId,
        description: 'Test Transaction',
        paymentMethod: '',
        createdById: '',
        receivedAmount: 100,
        returnAmount: 0,
        totalAmount: 100,
        totalOrderedProduct: 1,
      );
      final result = Result<TransactionEntity?>.success(data: transaction);

      when(mockTransactionRepository.getTransaction(transactionId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(transactionId);

      // assert
      expect(response, result);
      expect(response.data?.id, transactionId);
      verify(mockTransactionRepository.getTransaction(transactionId));
      verifyNoMoreInteractions(mockTransactionRepository);
    });

    test('should return null when transaction not found', () async {
      // arrange
      const transactionId = 999;
      final result = Result<TransactionEntity?>.success(data: null);

      when(mockTransactionRepository.getTransaction(transactionId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(transactionId);

      // assert
      expect(response.data, isNull);
      verify(mockTransactionRepository.getTransaction(transactionId));
    });

    test('should return failure when getting transaction fails', () async {
      // arrange
      const transactionId = 1;
      final result = Result<TransactionEntity?>.failure(error: 'Database error');

      when(mockTransactionRepository.getTransaction(transactionId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(transactionId);

      // assert
      expect(response.isFailure, true);
      verify(mockTransactionRepository.getTransaction(transactionId));
    });
  });

  group('CreateTransactionUsecase', () {
    late CreateTransactionUsecase usecase;

    setUp(() {
      usecase = CreateTransactionUsecase(mockTransactionRepository);
    });

    test('should create transaction successfully', () async {
      // arrange
      final transaction = TransactionEntity(
        description: 'New Transaction',
        paymentMethod: '',
        createdById: '',
        receivedAmount: 100,
        returnAmount: 0,
        totalAmount: 100,
        totalOrderedProduct: 1,
      );
      const createdId = 1;
      final result = Result<int>.success(data: createdId);

      when(mockTransactionRepository.createTransaction(transaction)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(transaction);

      // assert
      expect(response, result);
      expect(response.data, createdId);
      verify(mockTransactionRepository.createTransaction(transaction));
      verifyNoMoreInteractions(mockTransactionRepository);
    });

    test('should return failure when creation fails', () async {
      // arrange
      final transaction = TransactionEntity(
        description: 'New Transaction',
        paymentMethod: '',
        createdById: '',
        receivedAmount: 100,
        returnAmount: 0,
        totalAmount: 100,
        totalOrderedProduct: 1,
      );
      final result = Result<int>.failure(error: 'Creation failed');

      when(mockTransactionRepository.createTransaction(transaction)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(transaction);

      // assert
      expect(response.isFailure, true);
      verify(mockTransactionRepository.createTransaction(transaction));
    });

    test('should handle validation error during creation', () async {
      // arrange
      final transaction = TransactionEntity(
        description: 'Invalid Transaction',
        paymentMethod: '',
        createdById: '',
        receivedAmount: 100,
        returnAmount: 0,
        totalAmount: 100,
        totalOrderedProduct: 1,
      );
      final result = Result<int>.failure(error: 'Invalid amount');

      when(mockTransactionRepository.createTransaction(transaction)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(transaction);

      // assert
      expect(response.isFailure, true);
      verify(mockTransactionRepository.createTransaction(transaction));
    });
  });

  group('UpateTransactionUsecase', () {
    late UpateTransactionUsecase usecase;

    setUp(() {
      usecase = UpateTransactionUsecase(mockTransactionRepository);
    });

    test('should update transaction successfully', () async {
      // arrange
      final transaction = TransactionEntity(
        id: 1,
        description: 'Updated Transaction',
        paymentMethod: '',
        createdById: '',
        receivedAmount: 100,
        returnAmount: 0,
        totalAmount: 100,
        totalOrderedProduct: 1,
      );
      final result = Result<void>.success(data: null);

      when(mockTransactionRepository.updateTransaction(transaction)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(transaction);

      // assert
      expect(response, result);
      expect(response.isSuccess, true);
      verify(mockTransactionRepository.updateTransaction(transaction));
      verifyNoMoreInteractions(mockTransactionRepository);
    });

    test('should return failure when update fails', () async {
      // arrange
      final transaction = TransactionEntity(
        id: 1,
        description: 'Updated Transaction',
        paymentMethod: '',
        createdById: '',
        receivedAmount: 100,
        returnAmount: 0,
        totalAmount: 100,
        totalOrderedProduct: 1,
      );
      final result = Result<void>.failure(error: 'Update failed');

      when(mockTransactionRepository.updateTransaction(transaction)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(transaction);

      // assert
      expect(response.isFailure, true);
      verify(mockTransactionRepository.updateTransaction(transaction));
    });

    test('should handle transaction not found during update', () async {
      // arrange
      final transaction = TransactionEntity(
        id: 999,
        description: 'Non-existent Transaction',
        paymentMethod: '',
        createdById: '',
        receivedAmount: 100,
        returnAmount: 0,
        totalAmount: 100,
        totalOrderedProduct: 1,
      );
      final result = Result<void>.failure(error: 'Transaction not found');

      when(mockTransactionRepository.updateTransaction(transaction)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(transaction);

      // assert
      expect(response.isFailure, true);
      verify(mockTransactionRepository.updateTransaction(transaction));
    });
  });

  group('DeleteTransactionUsecase', () {
    late DeleteTransactionUsecase usecase;

    setUp(() {
      usecase = DeleteTransactionUsecase(mockTransactionRepository);
    });

    test('should delete transaction successfully', () async {
      // arrange
      const transactionId = 1;
      final result = Result<void>.success(data: null);

      when(mockTransactionRepository.deleteTransaction(transactionId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(transactionId);

      // assert
      expect(response, result);
      expect(response.isSuccess, true);
      verify(mockTransactionRepository.deleteTransaction(transactionId));
      verifyNoMoreInteractions(mockTransactionRepository);
    });

    test('should return failure when deletion fails', () async {
      // arrange
      const transactionId = 1;
      final result = Result<void>.failure(error: 'Deletion failed');

      when(mockTransactionRepository.deleteTransaction(transactionId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(transactionId);

      // assert
      expect(response.isFailure, true);
      verify(mockTransactionRepository.deleteTransaction(transactionId));
    });

    test('should handle transaction not found scenario', () async {
      // arrange
      const transactionId = 999;
      final result = Result<void>.failure(error: 'Transaction not found');

      when(mockTransactionRepository.deleteTransaction(transactionId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(transactionId);

      // assert
      expect(response.isFailure, true);
      verify(mockTransactionRepository.deleteTransaction(transactionId));
    });

    test('should handle database error during deletion', () async {
      // arrange
      const transactionId = 1;
      final result = Result<void>.failure(error: 'Database error');

      when(mockTransactionRepository.deleteTransaction(transactionId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(transactionId);

      // assert
      expect(response.isFailure, true);
      verify(mockTransactionRepository.deleteTransaction(transactionId));
    });
  });
}
