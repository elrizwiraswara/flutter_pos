import 'package:flutter_pos/data/data_sources/local/app_database.dart';
import 'package:flutter_pos/data/repositories/transaction_repository_impl.dart';
import 'package:flutter_pos/presentation/providers/account/account_provider.dart';
import 'package:flutter_pos/presentation/providers/auth/auth_provider.dart';
import 'package:flutter_pos/presentation/providers/home/home_provider.dart';
import 'package:flutter_pos/presentation/providers/main/main_provider.dart';
import 'package:flutter_pos/presentation/providers/products/product_detail_provider.dart';
import 'package:flutter_pos/presentation/providers/products/product_form_provider.dart';
import 'package:flutter_pos/presentation/providers/products/products_provider.dart';
import 'package:flutter_pos/presentation/providers/transactions/transactions_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

final GetIt sl = GetIt.instance;

// Service Locator
void setupServiceLocator() async {
  sl.registerSingleton<AppDatabase>(AppDatabaseConfig.database);

  // Services
  // sl.registerLazySingleton(() => Client());
  // sl.registerLazySingleton(() => RestFulApi());

  // Datasources
  // sl.registerLazySingleton(() => TransactionDatasourceImpl(sl<Client>(), sl<RestFulApi>()));

  // Repositories
  sl.registerLazySingleton(() => TransactionRepositoryImpl(sl<AppDatabase>()));

  // Providers
  sl.registerLazySingleton(() => AuthProvider());
  sl.registerLazySingleton(() => MainProvider());
  sl.registerLazySingleton(() => HomeProvider(transactionRepository: sl<TransactionRepositoryImpl>()));
  sl.registerLazySingleton(() => ProductsProvider());
  sl.registerLazySingleton(() => TransactionsProvider());
  sl.registerLazySingleton(() => AccountProvider());
  sl.registerLazySingleton(() => ProductFormProvider());
  sl.registerLazySingleton(() => ProductDetailProvider());
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
];
