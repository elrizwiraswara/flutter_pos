import 'package:flutter_pos/core/database/app_database.dart';
import 'package:flutter_pos/data/data_sources/local/product_datasource.dart';
import 'package:flutter_pos/data/data_sources/local/transaction_datasource.dart';
import 'package:flutter_pos/data/data_sources/local/user_datasource.dart';
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

  // Services
  // sl.registerLazySingleton(() => Client());
  // sl.registerLazySingleton(() => RestFulApi());

  // Datasources
  sl.registerLazySingleton(() => ProductDatasource(sl<AppDatabase>()));
  sl.registerLazySingleton(() => TransactionDatasource(sl<AppDatabase>()));
  sl.registerLazySingleton(() => UserDatasource(sl<AppDatabase>()));

  // Repositories
  sl.registerLazySingleton(() => ProductRepositoryImpl(sl<ProductDatasource>()));
  sl.registerLazySingleton(() => TransactionRepositoryImpl(sl<TransactionDatasource>()));
  sl.registerLazySingleton(() => UserRepositoryImpl(sl<UserDatasource>()));

  // Providers
  sl.registerLazySingleton(() => AuthProvider(userRepository: sl<UserRepositoryImpl>()));
  sl.registerLazySingleton(() => MainProvider());
  sl.registerLazySingleton(() => HomeProvider(
      transactionRepository: sl<TransactionRepositoryImpl>(), productRepository: sl<ProductRepositoryImpl>()));
  sl.registerLazySingleton(() => ProductsProvider(productRepository: sl<ProductRepositoryImpl>()));
  sl.registerLazySingleton(() => TransactionsProvider(transactionRepository: sl<TransactionRepositoryImpl>()));
  sl.registerLazySingleton(() => AccountProvider());
  sl.registerLazySingleton(() => ProductFormProvider(productRepository: sl<ProductRepositoryImpl>()));
  sl.registerLazySingleton(() => ProductDetailProvider());
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
