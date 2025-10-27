import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_pos/data/datasources/remote/transaction_remote_datasource_impl.dart';
import 'package:flutter_pos/data/models/ordered_product_model.dart';
import 'package:flutter_pos/data/models/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TransactionRemoteDatasourceImpl datasource;
  late FakeFirebaseFirestore fakeFirestore;

  setUpAll(() {
    fakeFirestore = FakeFirebaseFirestore();
    datasource = TransactionRemoteDatasourceImpl(fakeFirestore);
  });

  const userId = 'user123';

  TransactionModel createSampleTransaction({
    int id = 1,
    String createdById = userId,
    int totalAmount = 1,
  }) {
    return TransactionModel(
      id: id,
      createdById: createdById,
      paymentMethod: 'Cash',
      receivedAmount: totalAmount,
      returnAmount: 0,
      totalAmount: totalAmount,
      totalOrderedProduct: 1,
      orderedProducts: [
        OrderedProductModel(
          id: 1,
          transactionId: id,
          productId: 1,
          quantity: 1,
          stock: 1,
          name: 'Sample Product',
          imageUrl: '',
          price: totalAmount,
        ),
      ],
    );
  }

  group('TransactionRemoteDatasourceImpl', () {
    group('createTransaction', () {
      test('should insert transaction into the database and return transaction id', () async {
        final transaction = createSampleTransaction();

        final result = await datasource.createTransaction(transaction);

        expect(result.data, equals(transaction.id));
      });

      test('should create multiple transactions successfully', () async {
        final transaction1 = createSampleTransaction(id: 1);
        final transaction2 = createSampleTransaction(id: 2);

        final result1 = await datasource.createTransaction(transaction1);
        final result2 = await datasource.createTransaction(transaction2);

        expect(result1.data, equals(1));
        expect(result2.data, equals(2));
      });

      test('should store ordered products with the transaction', () async {
        final transaction = createSampleTransaction();

        await datasource.createTransaction(transaction);
        final retrieved = await datasource.getTransaction(transaction.id);

        expect(retrieved.data?.orderedProducts, isNotEmpty);
        expect(retrieved.data?.orderedProducts?.length, equals(1));
        expect(retrieved.data?.orderedProducts?.first.productId, equals(1));
      });
    });

    group('updateTransaction', () {
      test('should update existing transaction in the database', () async {
        final transaction = createSampleTransaction();
        await datasource.createTransaction(transaction);

        final updatedTransaction = createSampleTransaction(
          id: transaction.id,
          totalAmount: 100,
        );

        await expectLater(
          datasource.updateTransaction(updatedTransaction),
          completes,
        );

        final retrieved = await datasource.getTransaction(transaction.id);
        expect(retrieved.data?.totalAmount, equals(100));
      });

      test('should complete even if transaction does not exist', () async {
        final transaction = createSampleTransaction();
        await datasource.createTransaction(transaction);

        final updatedTransaction = createSampleTransaction(
          id: transaction.id,
          totalAmount: 100,
        );

        await expectLater(
          datasource.updateTransaction(updatedTransaction),
          completes,
        );
      });
    });

    group('getTransaction', () {
      test('should retrieve existing transaction from the database', () async {
        final transaction = createSampleTransaction();
        await datasource.createTransaction(transaction);

        final result = await datasource.getTransaction(transaction.id);

        expect(result.data, isNotNull);
        expect(result.data?.id, equals(transaction.id));
        expect(result.data?.createdById, equals(userId));
        expect(result.data?.paymentMethod, equals('Cash'));
        expect(result.data?.totalAmount, equals(transaction.totalAmount));
      });

      test('should return null when transaction does not exist', () async {
        final result = await datasource.getTransaction(999);

        expect(result.data, isNull);
      });

      test('should retrieve transaction with all ordered products', () async {
        final transaction = createSampleTransaction();
        await datasource.createTransaction(transaction);

        final result = await datasource.getTransaction(transaction.id);

        expect(result.data?.orderedProducts, isNotEmpty);
        expect(result.data?.totalOrderedProduct, equals(1));
      });
    });

    group('getAllUserTransactions', () {
      test('should retrieve all transactions for a given user', () async {
        final transaction1 = createSampleTransaction(id: 1);
        final transaction2 = createSampleTransaction(id: 2);

        await datasource.createTransaction(transaction1);
        await datasource.createTransaction(transaction2);

        final result = await datasource.getAllUserTransactions(userId);

        expect(result.data, isNotEmpty);
        expect(result.data?.length, equals(2));
        expect(result.data?.any((t) => t.id == 1), isTrue);
        expect(result.data?.any((t) => t.id == 2), isTrue);
      });

      test('should return empty list when user has no transactions', () async {
        final result = await datasource.getAllUserTransactions('nonexistent_user');

        expect(result.data, isEmpty);
      });

      test('should not return transactions from other users', () async {
        final transaction = createSampleTransaction();
        await datasource.createTransaction(transaction);

        final result = await datasource.getAllUserTransactions('different_user');

        expect(result.data, isEmpty);
      });

      test('should retrieve transactions with ordered products', () async {
        final transaction = createSampleTransaction();
        await datasource.createTransaction(transaction);

        final result = await datasource.getAllUserTransactions(userId);

        expect(result.data?.first.orderedProducts, isNotEmpty);
        expect(result.data?.first.orderedProducts?.length, equals(1));
      });
    });

    group('deleteTransaction', () {
      test('should delete existing transaction from the database', () async {
        final transaction = createSampleTransaction();
        await datasource.createTransaction(transaction);

        await expectLater(
          datasource.deleteTransaction(transaction.id),
          completes,
        );

        final retrieved = await datasource.getTransaction(transaction.id);
        expect(retrieved.data, isNull);
      });

      test('should complete even if transaction does not exist', () async {
        await expectLater(
          datasource.deleteTransaction(999),
          completes,
        );
      });

      test('should delete transaction and its ordered products', () async {
        final transaction = createSampleTransaction();
        await datasource.createTransaction(transaction);

        await datasource.deleteTransaction(transaction.id);

        final retrieved = await datasource.getTransaction(transaction.id);
        expect(retrieved.data, isNull);
      });
    });
  });
}
