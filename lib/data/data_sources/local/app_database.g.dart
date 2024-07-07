// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  UserDao? _userDaoInstance;

  ProductDao? _productDaoInstance;

  TransactionDao? _transactionDaoInstance;

  TransactionProductDao? _transactionProductDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `user` (`id` TEXT NOT NULL, `phone` TEXT NOT NULL, `name` TEXT NOT NULL, `gender` TEXT, `birthdate` TEXT, `imageUrl` TEXT, `createdAt` TEXT NOT NULL, `updatedAt` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `product` (`id` INTEGER NOT NULL, `createdById` TEXT NOT NULL, `name` TEXT NOT NULL, `imageUrl` TEXT NOT NULL, `stock` INTEGER NOT NULL, `sold` INTEGER NOT NULL, `price` INTEGER NOT NULL, `description` TEXT NOT NULL, `createdAt` TEXT NOT NULL, `updatedAt` TEXT NOT NULL, FOREIGN KEY (`id`) REFERENCES `user` (`createdById`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `transaction` (`id` INTEGER NOT NULL, `paymentMethod` TEXT NOT NULL, `customerName` TEXT, `description` TEXT, `createdById` TEXT, `receivedAmount` INTEGER NOT NULL, `returnAmount` INTEGER NOT NULL, `totalAmount` INTEGER NOT NULL, `createdAt` TEXT NOT NULL, `updatedAt` TEXT NOT NULL, FOREIGN KEY (`id`) REFERENCES `user` (`createdById`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `TransactionProductModel` (`transactionId` INTEGER NOT NULL, `productId` INTEGER NOT NULL, PRIMARY KEY (`transactionId`, `productId`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  UserDao get userDao {
    return _userDaoInstance ??= _$UserDao(database, changeListener);
  }

  @override
  ProductDao get productDao {
    return _productDaoInstance ??= _$ProductDao(database, changeListener);
  }

  @override
  TransactionDao get transactionDao {
    return _transactionDaoInstance ??=
        _$TransactionDao(database, changeListener);
  }

  @override
  TransactionProductDao get transactionProductDao {
    return _transactionProductDaoInstance ??=
        _$TransactionProductDao(database, changeListener);
  }
}

class _$UserDao extends UserDao {
  _$UserDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _userModelInsertionAdapter = InsertionAdapter(
            database,
            'user',
            (UserModel item) => <String, Object?>{
                  'id': item.id,
                  'phone': item.phone,
                  'name': item.name,
                  'gender': item.gender,
                  'birthdate': item.birthdate,
                  'imageUrl': item.imageUrl,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                }),
        _userModelUpdateAdapter = UpdateAdapter(
            database,
            'user',
            ['id'],
            (UserModel item) => <String, Object?>{
                  'id': item.id,
                  'phone': item.phone,
                  'name': item.name,
                  'gender': item.gender,
                  'birthdate': item.birthdate,
                  'imageUrl': item.imageUrl,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                }),
        _userModelDeletionAdapter = DeletionAdapter(
            database,
            'user',
            ['id'],
            (UserModel item) => <String, Object?>{
                  'id': item.id,
                  'phone': item.phone,
                  'name': item.name,
                  'gender': item.gender,
                  'birthdate': item.birthdate,
                  'imageUrl': item.imageUrl,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<UserModel> _userModelInsertionAdapter;

  final UpdateAdapter<UserModel> _userModelUpdateAdapter;

  final DeletionAdapter<UserModel> _userModelDeletionAdapter;

  @override
  Future<UserModel?> findUserById(String id) async {
    return _queryAdapter.query('SELECT * FROM user WHERE id = ?1',
        mapper: (Map<String, Object?> row) => UserModel(
            id: row['id'] as String,
            phone: row['phone'] as String,
            name: row['name'] as String,
            gender: row['gender'] as String?,
            birthdate: row['birthdate'] as String?,
            imageUrl: row['imageUrl'] as String?,
            createdAt: row['createdAt'] as String,
            updatedAt: row['updatedAt'] as String),
        arguments: [id]);
  }

  @override
  Future<void> insertUser(UserModel user) async {
    await _userModelInsertionAdapter.insert(user, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await _userModelUpdateAdapter.update(user, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteUser(UserModel user) async {
    await _userModelDeletionAdapter.delete(user);
  }
}

class _$ProductDao extends ProductDao {
  _$ProductDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _productModelInsertionAdapter = InsertionAdapter(
            database,
            'product',
            (ProductModel item) => <String, Object?>{
                  'id': item.id,
                  'createdById': item.createdById,
                  'name': item.name,
                  'imageUrl': item.imageUrl,
                  'stock': item.stock,
                  'sold': item.sold,
                  'price': item.price,
                  'description': item.description,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                }),
        _productModelUpdateAdapter = UpdateAdapter(
            database,
            'product',
            ['id'],
            (ProductModel item) => <String, Object?>{
                  'id': item.id,
                  'createdById': item.createdById,
                  'name': item.name,
                  'imageUrl': item.imageUrl,
                  'stock': item.stock,
                  'sold': item.sold,
                  'price': item.price,
                  'description': item.description,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                }),
        _productModelDeletionAdapter = DeletionAdapter(
            database,
            'product',
            ['id'],
            (ProductModel item) => <String, Object?>{
                  'id': item.id,
                  'createdById': item.createdById,
                  'name': item.name,
                  'imageUrl': item.imageUrl,
                  'stock': item.stock,
                  'sold': item.sold,
                  'price': item.price,
                  'description': item.description,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ProductModel> _productModelInsertionAdapter;

  final UpdateAdapter<ProductModel> _productModelUpdateAdapter;

  final DeletionAdapter<ProductModel> _productModelDeletionAdapter;

  @override
  Future<List<ProductModel>> findAllUserProducts(String id) async {
    return _queryAdapter.queryList(
        'SELECT * FROM product WHERE created_by_id = ?1',
        mapper: (Map<String, Object?> row) => ProductModel(
            id: row['id'] as int,
            createdById: row['createdById'] as String,
            name: row['name'] as String,
            imageUrl: row['imageUrl'] as String,
            stock: row['stock'] as int,
            sold: row['sold'] as int,
            price: row['price'] as int,
            description: row['description'] as String,
            createdAt: row['createdAt'] as String,
            updatedAt: row['updatedAt'] as String),
        arguments: [id]);
  }

  @override
  Future<List<ProductModel>> findProductsForTransaction(
      int transactionId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM product WHERE id IN (SELECT product_id FROM transaction_product WHERE transaction_id = ?1)',
        mapper: (Map<String, Object?> row) => ProductModel(id: row['id'] as int, createdById: row['createdById'] as String, name: row['name'] as String, imageUrl: row['imageUrl'] as String, stock: row['stock'] as int, sold: row['sold'] as int, price: row['price'] as int, description: row['description'] as String, createdAt: row['createdAt'] as String, updatedAt: row['updatedAt'] as String),
        arguments: [transactionId]);
  }

  @override
  Future<void> insertProduct(ProductModel product) async {
    await _productModelInsertionAdapter.insert(
        product, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await _productModelUpdateAdapter.update(product, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteProduct(ProductModel product) async {
    await _productModelDeletionAdapter.delete(product);
  }
}

class _$TransactionDao extends TransactionDao {
  _$TransactionDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _transactionModelInsertionAdapter = InsertionAdapter(
            database,
            'transaction',
            (TransactionModel item) => <String, Object?>{
                  'id': item.id,
                  'paymentMethod': item.paymentMethod,
                  'customerName': item.customerName,
                  'description': item.description,
                  'createdById': item.createdById,
                  'receivedAmount': item.receivedAmount,
                  'returnAmount': item.returnAmount,
                  'totalAmount': item.totalAmount,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                }),
        _transactionModelUpdateAdapter = UpdateAdapter(
            database,
            'transaction',
            ['id'],
            (TransactionModel item) => <String, Object?>{
                  'id': item.id,
                  'paymentMethod': item.paymentMethod,
                  'customerName': item.customerName,
                  'description': item.description,
                  'createdById': item.createdById,
                  'receivedAmount': item.receivedAmount,
                  'returnAmount': item.returnAmount,
                  'totalAmount': item.totalAmount,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                }),
        _transactionModelDeletionAdapter = DeletionAdapter(
            database,
            'transaction',
            ['id'],
            (TransactionModel item) => <String, Object?>{
                  'id': item.id,
                  'paymentMethod': item.paymentMethod,
                  'customerName': item.customerName,
                  'description': item.description,
                  'createdById': item.createdById,
                  'receivedAmount': item.receivedAmount,
                  'returnAmount': item.returnAmount,
                  'totalAmount': item.totalAmount,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<TransactionModel> _transactionModelInsertionAdapter;

  final UpdateAdapter<TransactionModel> _transactionModelUpdateAdapter;

  final DeletionAdapter<TransactionModel> _transactionModelDeletionAdapter;

  @override
  Future<List<TransactionModel>> findAllUserTransactions(String id) async {
    return _queryAdapter.queryList(
        'SELECT * FROM transaction WHERE created_by_id = ?1',
        mapper: (Map<String, Object?> row) => TransactionModel(
            id: row['id'] as int,
            paymentMethod: row['paymentMethod'] as String,
            customerName: row['customerName'] as String?,
            description: row['description'] as String?,
            createdById: row['createdById'] as String?,
            receivedAmount: row['receivedAmount'] as int,
            returnAmount: row['returnAmount'] as int,
            totalAmount: row['totalAmount'] as int,
            createdAt: row['createdAt'] as String,
            updatedAt: row['updatedAt'] as String),
        arguments: [id]);
  }

  @override
  Future<TransactionModel?> findTransactionById(int id) async {
    return _queryAdapter.query('SELECT * FROM transaction WHERE id = ?1',
        mapper: (Map<String, Object?> row) => TransactionModel(
            id: row['id'] as int,
            paymentMethod: row['paymentMethod'] as String,
            customerName: row['customerName'] as String?,
            description: row['description'] as String?,
            createdById: row['createdById'] as String?,
            receivedAmount: row['receivedAmount'] as int,
            returnAmount: row['returnAmount'] as int,
            totalAmount: row['totalAmount'] as int,
            createdAt: row['createdAt'] as String,
            updatedAt: row['updatedAt'] as String),
        arguments: [id]);
  }

  @override
  Future<void> insertTransaction(TransactionModel transaction) async {
    await _transactionModelInsertionAdapter.insert(
        transaction, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _transactionModelUpdateAdapter.update(
        transaction, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteTransaction(TransactionModel transaction) async {
    await _transactionModelDeletionAdapter.delete(transaction);
  }
}

class _$TransactionProductDao extends TransactionProductDao {
  _$TransactionProductDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _transactionProductModelInsertionAdapter = InsertionAdapter(
            database,
            'TransactionProductModel',
            (TransactionProductModel item) => <String, Object?>{
                  'transactionId': item.transactionId,
                  'productId': item.productId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<TransactionProductModel>
      _transactionProductModelInsertionAdapter;

  @override
  Future<List<TransactionProductModel>> findAllTransactionProducts() async {
    return _queryAdapter.queryList('SELECT * FROM transaction_product',
        mapper: (Map<String, Object?> row) => TransactionProductModel(
            row['transactionId'] as int, row['productId'] as int));
  }

  @override
  Future<void> insertTransactionProduct(
      TransactionProductModel transactionProduct) async {
    await _transactionProductModelInsertionAdapter.insert(
        transactionProduct, OnConflictStrategy.abort);
  }
}
