import 'dart:async';

import 'package:floor/floor.dart';
import 'package:flutter_pos/data/data_sources/local/dao/product_dao.dart';
import 'package:flutter_pos/data/data_sources/local/dao/transaction_dao.dart';
import 'package:flutter_pos/data/data_sources/local/dao/transaction_product_dao.dart';
import 'package:flutter_pos/data/data_sources/local/dao/user_dao.dart';
import 'package:flutter_pos/data/models/product_model.dart';
import 'package:flutter_pos/data/models/transaction_model.dart';
import 'package:flutter_pos/data/models/transaction_product_model.dart';
import 'package:flutter_pos/data/models/user_model.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'app_database.g.dart';

@Database(version: 1, entities: [
  UserModel,
  ProductModel,
  TransactionModel,
  TransactionProductModel,
])
abstract class AppDatabase extends FloorDatabase {
  UserDao get userDao;
  ProductDao get productDao;
  TransactionDao get transactionDao;
  TransactionProductDao get transactionProductDao;
}

class AppDatabaseConfig {
  static late AppDatabase database;

  static Future<void> init() async {
    database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  }
}
