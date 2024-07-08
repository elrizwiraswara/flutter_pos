import 'dart:async';
import 'dart:io';

import 'package:flutter_pos/app/utilities/console_log.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  /// Make [AppDatabase] to be singleton
  static final AppDatabase _instance = AppDatabase._();

  factory AppDatabase() => _instance;

  AppDatabase._();

  late Database database;

  Future<void> init() async {
    // await dropDatabase();

    database = await openDatabase(
      join(await getDatabasesPath(), AppDatabaseConfig.dbPath),
      version: AppDatabaseConfig.version,
    );

    // Create tables
    await database.execute(AppDatabaseConfig.createUserTable);
    await database.execute(AppDatabaseConfig.createProductTable);
    await database.execute(AppDatabaseConfig.createTransactionTable);
    await database.execute(AppDatabaseConfig.createOrderedProductTable);
  }

  Future<void> dropDatabase() async {
    // Get the path to the database
    String path = join(await getDatabasesPath(), AppDatabaseConfig.dbPath);

    // Check if the database file exists
    File databaseFile = File(path);
    if (await databaseFile.exists()) {
      // Close the database if it is open
      Database db = await openDatabase(path);
      await db.close();

      // Delete the database file
      await databaseFile.delete();
      cl('[AppDatabase].dropDatabase = Database deleted successfully.');
    } else {
      cl('[AppDatabase].dropDatabase = Database does not exist.');
    }
  }
}

class AppDatabaseConfig {
  static const String dbPath = 'app_database.db';
  static const int version = 1;

  static const String userTableName = 'User';
  static const String productTableName = 'Product';
  static const String transactionTableName = 'Transaction';
  static const String orderedProductTableName = 'OrderedProduct';

  static String createUserTable = '''
CREATE TABLE IF NOT EXISTS '$userTableName' (
    'id' TEXT NOT NULL,
    'email' TEXT,
    'phone' TEXT,
    'name' TEXT,
    'gender' TEXT,
    'birthdate' TEXT,
    'imageUrl' TEXT,
    'createdAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    'updatedAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ('id')
);
''';

  static String createProductTable = '''
CREATE TABLE IF NOT EXISTS '$productTableName' (
    'id' INTEGER AUTO_INCREMENT NOT NULL,
    'createdById' TEXT,
    'name' TEXT,
    'imageUrl' TEXT,
    'stock' INTEGER,
    'sold' INTEGER,
    'price' INTEGER,
    'description' TEXT,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ('id'),
    FOREIGN KEY ('createdById') REFERENCES 'User' ('id')
);
''';

  static String createTransactionTable = '''
CREATE TABLE IF NOT EXISTS '$transactionTableName' (
    'id' INTEGER NOT NULL,
    'paymentMethod' TEXT,
    'customerName' TEXT,
    'description' TEXT,
    'createdById' TEXT,
    'receivedAmount' INTEGER,
    'returnAmount' INTEGER,
    'totalAmount' INTEGER,
    'createdAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    'updatedAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ('id'),
    FOREIGN KEY ('createdById') REFERENCES 'User' ('id')
);
''';

  static String createOrderedProductTable = '''
CREATE TABLE IF NOT EXISTS '$orderedProductTableName' (
    'id' INTEGER AUTO_INCREMENT NOT NULL,
    'transactionId' INTEGER,
    'quantity' INTEGER,
    'productId' INTEGER,
    'createdAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    'updatedAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ('transactionId') REFERENCES 'Transaction' ('id'),
    FOREIGN KEY ('productId') REFERENCES 'Product' ('id')
);
''';
}
