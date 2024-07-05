import 'package:flutter_pos/presentation/providers/account/account_provider.dart';
import 'package:flutter_pos/presentation/providers/auth/auth_provider.dart';
import 'package:flutter_pos/presentation/providers/home/home_provider.dart';
import 'package:flutter_pos/presentation/providers/main/main_provider.dart';
import 'package:flutter_pos/presentation/providers/products/products_provider.dart';
import 'package:flutter_pos/presentation/providers/transactions/transactions_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

final GetIt sl = GetIt.instance;

// Service Locator
void setupServiceLocator() {
  // // Services
  // sl.registerLazySingleton(() => Client());
  // sl.registerLazySingleton(() => RestFulApi());

  // // Datasources
  // sl.registerLazySingleton(() => UserDatasourceImpl(sl<Client>(), sl<RestFulApi>()));

  // // Repositories
  // sl.registerLazySingleton(() => UserRepositoryImpl(sl<UserDatasourceImpl>()));

  // // Providers
  sl.registerLazySingleton(() => AuthProvider());
  sl.registerLazySingleton(() => MainProvider());
  sl.registerLazySingleton(() => HomeProvider());
  sl.registerLazySingleton(() => ProductsProvider());
  sl.registerLazySingleton(() => TransactionsProvider());
  sl.registerLazySingleton(() => AccountProvider());
}

// All providers
final List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => sl<AuthProvider>()),
  ChangeNotifierProvider(create: (_) => sl<MainProvider>()),
  ChangeNotifierProvider(create: (_) => sl<HomeProvider>()),
  ChangeNotifierProvider(create: (_) => sl<ProductsProvider>()),
  ChangeNotifierProvider(create: (_) => sl<TransactionsProvider>()),
  ChangeNotifierProvider(create: (_) => sl<AccountProvider>()),
];
