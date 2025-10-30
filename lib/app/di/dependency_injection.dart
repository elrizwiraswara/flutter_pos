import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../core/database/app_database.dart';
import '../../core/services/connectivity/ping_service.dart';
import '../../core/services/info/device_info_service.dart';
import '../../core/services/logger/error_logger_service.dart';
import '../../data/datasources/local/product_local_datasource_impl.dart';
import '../../data/datasources/local/queued_action_local_datasource_impl.dart';
import '../../data/datasources/local/transaction_local_datasource_impl.dart';
import '../../data/datasources/local/user_local_datasource_impl.dart';
import '../../data/datasources/remote/auth_remote_datasource_impl.dart';
import '../../data/datasources/remote/product_remote_datasource_impl.dart';
import '../../data/datasources/remote/storage_remote_datasource_impl.dart';
import '../../data/datasources/remote/transaction_remote_datasource_impl.dart';
import '../../data/datasources/remote/user_remote_datasource_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/queued_action_repository_impl.dart';
import '../../data/repositories/storage_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../presentation/providers/account/account_provider.dart';
import '../../presentation/providers/auth/auth_provider.dart';
import '../../presentation/providers/home/home_provider.dart';
import '../../presentation/providers/main/main_provider.dart';
import '../../presentation/providers/products/product_detail_provider.dart';
import '../../presentation/providers/products/product_form_provider.dart';
import '../../presentation/providers/products/products_provider.dart';
import '../../presentation/providers/theme/theme_provider.dart';
import '../../presentation/providers/transactions/transaction_detail_provider.dart';
import '../../presentation/providers/transactions/transactions_provider.dart';
import '../routes/app_routes.dart';

final GetIt di = GetIt.instance;

/// Setup dependency injection
void setupDependencyInjection() async {
  // Third parties
  di.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  di.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);
  di.registerSingleton<FirebaseCrashlytics>(FirebaseCrashlytics.instance);
  di.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  di.registerSingleton<GoogleSignIn>(GoogleSignIn.instance);
  di.registerSingleton<DeviceInfoPlugin>(DeviceInfoPlugin());

  // Database
  di.registerSingleton<AppDatabase>(AppDatabase.instance);

  // Services
  di.registerSingleton<PingService>(PingService());
  di.registerSingleton<DeviceInfoService>(DeviceInfoService(di<DeviceInfoPlugin>()));
  di.registerSingleton<ErrorLoggerService>(ErrorLoggerService(di<FirebaseCrashlytics>()));

  // Datasources
  // Local Datasources
  di.registerLazySingleton<ProductLocalDatasourceImpl>(
    () => ProductLocalDatasourceImpl(di<AppDatabase>()),
  );
  di.registerLazySingleton<TransactionLocalDatasourceImpl>(
    () => TransactionLocalDatasourceImpl(di<AppDatabase>()),
  );
  di.registerLazySingleton<UserLocalDatasourceImpl>(
    () => UserLocalDatasourceImpl(di<AppDatabase>()),
  );
  di.registerLazySingleton<QueuedActionLocalDatasourceImpl>(
    () => QueuedActionLocalDatasourceImpl(di<AppDatabase>()),
  );

  // Remote Datasources
  di.registerLazySingleton<AuthRemoteDataSourceImpl>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: di<FirebaseAuth>(),
      googleSignIn: di<GoogleSignIn>(),
    ),
  );
  di.registerLazySingleton<StorageRemoteDataSourceImpl>(
    () => StorageRemoteDataSourceImpl(di<FirebaseStorage>()),
  );
  di.registerLazySingleton<ProductRemoteDatasourceImpl>(
    () => ProductRemoteDatasourceImpl(di<FirebaseFirestore>()),
  );
  di.registerLazySingleton<TransactionRemoteDatasourceImpl>(
    () => TransactionRemoteDatasourceImpl(di<FirebaseFirestore>()),
  );
  di.registerLazySingleton<UserRemoteDatasourceImpl>(
    () => UserRemoteDatasourceImpl(di<FirebaseFirestore>()),
  );

  // Repositories
  di.registerLazySingleton<AuthRepositoryImpl>(
    () => AuthRepositoryImpl(
      authRemoteDataSource: di<AuthRemoteDataSourceImpl>(),
    ),
  );
  di.registerLazySingleton<StorageRepositoryImpl>(
    () => StorageRepositoryImpl(
      pingService: di<PingService>(),
      storageRemoteDataSource: di<StorageRemoteDataSourceImpl>(),
    ),
  );
  di.registerLazySingleton<ProductRepositoryImpl>(
    () => ProductRepositoryImpl(
      pingService: di<PingService>(),
      productLocalDatasource: di<ProductLocalDatasourceImpl>(),
      productRemoteDatasource: di<ProductRemoteDatasourceImpl>(),
      queuedActionLocalDatasource: di<QueuedActionLocalDatasourceImpl>(),
    ),
  );
  di.registerLazySingleton<TransactionRepositoryImpl>(
    () => TransactionRepositoryImpl(
      pingService: di<PingService>(),
      transactionLocalDatasource: di<TransactionLocalDatasourceImpl>(),
      transactionRemoteDatasource: di<TransactionRemoteDatasourceImpl>(),
      queuedActionLocalDatasource: di<QueuedActionLocalDatasourceImpl>(),
    ),
  );
  di.registerLazySingleton<UserRepositoryImpl>(
    () => UserRepositoryImpl(
      pingService: di<PingService>(),
      userLocalDatasource: di<UserLocalDatasourceImpl>(),
      userRemoteDatasource: di<UserRemoteDatasourceImpl>(),
      queuedActionLocalDatasource: di<QueuedActionLocalDatasourceImpl>(),
    ),
  );
  di.registerLazySingleton<QueuedActionRepositoryImpl>(
    () => QueuedActionRepositoryImpl(
      pingService: di<PingService>(),
      queuedActionLocalDatasource: di<QueuedActionLocalDatasourceImpl>(),
      userRemoteDatasource: di<UserRemoteDatasourceImpl>(),
      transactionRemoteDatasource: di<TransactionRemoteDatasourceImpl>(),
      productRemoteDatasource: di<ProductRemoteDatasourceImpl>(),
    ),
  );

  // Providers
  di.registerLazySingleton<MainProvider>(
    () => MainProvider(
      deviceInforService: di<DeviceInfoService>(),
      pingService: di<PingService>(),
      authProvider: di<AuthProvider>(),
      userRepository: di<UserRepositoryImpl>(),
      productRepository: di<ProductRepositoryImpl>(),
      transactionRepository: di<TransactionRepositoryImpl>(),
      queuedActionRepository: di<QueuedActionRepositoryImpl>(),
    ),
  );
  di.registerLazySingleton<AuthProvider>(
    () => AuthProvider(
      userRepository: di<UserRepositoryImpl>(),
      authRepository: di<AuthRepositoryImpl>(),
    ),
  );
  di.registerLazySingleton<HomeProvider>(
    () => HomeProvider(
      authProvider: di<AuthProvider>(),
      transactionRepository: di<TransactionRepositoryImpl>(),
    ),
  );
  di.registerLazySingleton<ProductsProvider>(
    () => ProductsProvider(
      authProvider: di<AuthProvider>(),
      productRepository: di<ProductRepositoryImpl>(),
    ),
  );
  di.registerLazySingleton<TransactionsProvider>(
    () => TransactionsProvider(
      authProvider: di<AuthProvider>(),
      transactionRepository: di<TransactionRepositoryImpl>(),
    ),
  );
  di.registerLazySingleton<AccountProvider>(
    () => AccountProvider(
      authProvider: di<AuthProvider>(),
      authRepository: di<AuthRepositoryImpl>(),
      userRepository: di<UserRepositoryImpl>(),
      storageRepository: di<StorageRepositoryImpl>(),
    ),
  );
  di.registerLazySingleton<ProductFormProvider>(
    () => ProductFormProvider(
      authProvider: di<AuthProvider>(),
      productRepository: di<ProductRepositoryImpl>(),
      storageRepository: di<StorageRepositoryImpl>(),
    ),
  );
  di.registerLazySingleton<ProductDetailProvider>(
    () => ProductDetailProvider(productRepository: di<ProductRepositoryImpl>()),
  );
  di.registerLazySingleton<TransactionDetailProvider>(
    () => TransactionDetailProvider(transactionRepository: di<TransactionRepositoryImpl>()),
  );
  di.registerLazySingleton<ThemeProvider>(
    () => ThemeProvider(),
  );

  // Routes
  di.registerSingleton<AppRoutes>(AppRoutes(di<AuthProvider>()));
}

// All providers
List<SingleChildWidget> get providers => [
  ChangeNotifierProvider(create: (_) => di<AuthProvider>()),
  ChangeNotifierProvider(create: (_) => di<MainProvider>()),
  ChangeNotifierProvider(create: (_) => di<HomeProvider>()),
  ChangeNotifierProvider(create: (_) => di<ProductsProvider>()),
  ChangeNotifierProvider(create: (_) => di<TransactionsProvider>()),
  ChangeNotifierProvider(create: (_) => di<AccountProvider>()),
  ChangeNotifierProvider(create: (_) => di<ProductFormProvider>()),
  ChangeNotifierProvider(create: (_) => di<ProductDetailProvider>()),
  ChangeNotifierProvider(create: (_) => di<ThemeProvider>()),
];
