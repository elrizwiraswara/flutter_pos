import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_pos/core/database/app_database.dart';
import 'package:flutter_pos/data/data_sources/local/product_local_datasource_impl.dart';
import 'package:flutter_pos/data/data_sources/local/transaction_local_datasource_impl.dart';
import 'package:flutter_pos/data/data_sources/local/user_local_datasource_impl.dart';
import 'package:flutter_pos/data/data_sources/remote/product_remote_datasource_impl.dart';
import 'package:flutter_pos/data/data_sources/remote/transaction_remote_datasource_impl.dart';
import 'package:flutter_pos/data/data_sources/remote/user_remote_datasource_impl.dart';
import 'package:flutter_pos/data/repositories/product_repository_impl.dart';
import 'package:flutter_pos/data/repositories/transaction_repository_impl.dart';
import 'package:flutter_pos/data/repositories/user_repository_impl.dart';
import 'package:flutter_pos/presentation/providers/account/account_provider.dart';
import 'package:flutter_pos/presentation/providers/auth/auth_provider.dart';
import 'package:flutter_pos/presentation/providers/home/home_provider.dart';
import 'package:flutter_pos/presentation/providers/main/main_provider.dart';
import 'package:flutter_pos/presentation/providers/products/product_detail_provider.dart';
import 'package:flutter_pos/presentation/providers/products/product_form_provider.dart';
import 'package:flutter_pos/presentation/providers/products/products_provider.dart';
import 'package:flutter_pos/presentation/providers/transactions/transaction_detail_provider.dart';
import 'package:flutter_pos/presentation/providers/transactions/transactions_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

final GetIt sl = GetIt.instance;

// Service Locator
void setupServiceLocator() async {
  sl.registerSingleton<AppDatabase>(AppDatabase());
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

  // Datasources
  // Local Datasources
  sl.registerLazySingleton(() => ProductLocalDatasourceImpl(sl<AppDatabase>()));
  sl.registerLazySingleton(() => TransactionLocalDatasourceImpl(sl<AppDatabase>()));
  sl.registerLazySingleton(() => UserLocalDatasourceImpl(sl<AppDatabase>()));
  // Remote Datasources
  sl.registerLazySingleton(() => ProductRemoteDatasourceImpl(sl<FirebaseFirestore>()));
  sl.registerLazySingleton(() => TransactionRemoteDatasourceImpl(sl<FirebaseFirestore>()));
  sl.registerLazySingleton(() => UserRemoteDatasourceImpl(sl<FirebaseFirestore>()));

  // Repositories
  sl.registerLazySingleton(
    () => ProductRepositoryImpl(
      productLocalDatasource: sl<ProductLocalDatasourceImpl>(),
      productRemoteDatasource: sl<ProductRemoteDatasourceImpl>(),
    ),
  );
  sl.registerLazySingleton(
    () => TransactionRepositoryImpl(
      transactionLocalDatasource: sl<TransactionLocalDatasourceImpl>(),
      transactionRemoteDatasource: sl<TransactionRemoteDatasourceImpl>(),
    ),
  );
  sl.registerLazySingleton(
    () => UserRepositoryImpl(
      userLocalDatasource: sl<UserLocalDatasourceImpl>(),
      userRemoteDatasource: sl<UserRemoteDatasourceImpl>(),
    ),
  );

  // Providers
  sl.registerLazySingleton(
    () => MainProvider(
      userRepository: sl<UserRepositoryImpl>(),
      productRepository: sl<ProductRepositoryImpl>(),
      transactionRepository: sl<TransactionRepositoryImpl>(),
    ),
  );
  sl.registerLazySingleton(() => AuthProvider(userRepository: sl<UserRepositoryImpl>()));
  sl.registerLazySingleton(() => HomeProvider(transactionRepository: sl<TransactionRepositoryImpl>()));
  sl.registerLazySingleton(() => ProductsProvider(productRepository: sl<ProductRepositoryImpl>()));
  sl.registerLazySingleton(() => TransactionsProvider(transactionRepository: sl<TransactionRepositoryImpl>()));
  sl.registerLazySingleton(() => AccountProvider(userRepository: sl<UserRepositoryImpl>()));
  sl.registerLazySingleton(() => ProductFormProvider(productRepository: sl<ProductRepositoryImpl>()));
  sl.registerLazySingleton(() => ProductDetailProvider(productRepository: sl<ProductRepositoryImpl>()));
  sl.registerLazySingleton(() => TransactionDetailProvider(transactionRepository: sl<TransactionRepositoryImpl>()));
}

// All providers
final List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => sl<AuthProvider>()),
  ChangeNotifierProvider(create: (_) => sl<MainProvider>()),
  ChangeNotifierProvider(create: (_) => sl<HomeProvider>()),
  ChangeNotifierProvider(create: (_) => sl<ProductsProvider>()),
  ChangeNotifierProvider(create: (_) => sl<TransactionsProvider>()),
  ChangeNotifierProvider(create: (_) => sl<AccountProvider>()),
  ChangeNotifierProvider(create: (_) => sl<ProductFormProvider>()),
  ChangeNotifierProvider(create: (_) => sl<ProductDetailProvider>()),
  ChangeNotifierProvider(create: (_) => sl<TransactionDetailProvider>()),
];
