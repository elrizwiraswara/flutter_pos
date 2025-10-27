import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'app/database/app_database.dart';
import 'app/routes/app_routes.dart';
import 'app/services/connectivity/ping_service.dart';
import 'app/services/info/device_info_service.dart';
import 'app/services/logger/error_logger_service.dart';
import 'data/datasources/local/product_local_datasource_impl.dart';
import 'data/datasources/local/queued_action_local_datasource_impl.dart';
import 'data/datasources/local/transaction_local_datasource_impl.dart';
import 'data/datasources/local/user_local_datasource_impl.dart';
import 'data/datasources/remote/auth_remote_datasource_impl.dart';
import 'data/datasources/remote/product_remote_datasource_impl.dart';
import 'data/datasources/remote/storage_remote_datasource_impl.dart';
import 'data/datasources/remote/transaction_remote_datasource_impl.dart';
import 'data/datasources/remote/user_remote_datasource_impl.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';
import 'data/repositories/queued_action_repository_impl.dart';
import 'data/repositories/storage_repository_impl.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'presentation/providers/account/account_provider.dart';
import 'presentation/providers/auth/auth_provider.dart';
import 'presentation/providers/home/home_provider.dart';
import 'presentation/providers/main/main_provider.dart';
import 'presentation/providers/products/product_detail_provider.dart';
import 'presentation/providers/products/product_form_provider.dart';
import 'presentation/providers/products/products_provider.dart';
import 'presentation/providers/theme/theme_provider.dart';
import 'presentation/providers/transactions/transaction_detail_provider.dart';
import 'presentation/providers/transactions/transactions_provider.dart';

final GetIt sl = GetIt.instance;

// Service Locator
void setupServiceLocator() async {
  // Third parties
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);
  sl.registerSingleton<FirebaseCrashlytics>(FirebaseCrashlytics.instance);
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<GoogleSignIn>(GoogleSignIn.instance);
  sl.registerSingleton<DeviceInfoPlugin>(DeviceInfoPlugin());

  // Database
  sl.registerSingleton<AppDatabase>(AppDatabase.instance);

  // Services
  sl.registerSingleton<PingService>(PingService());
  sl.registerSingleton<DeviceInfoService>(DeviceInfoService(sl<DeviceInfoPlugin>()));
  sl.registerSingleton<ErrorLoggerService>(ErrorLoggerService(sl<FirebaseCrashlytics>()));

  // Datasources
  // Local Datasources
  sl.registerLazySingleton<ProductLocalDatasourceImpl>(
    () => ProductLocalDatasourceImpl(sl<AppDatabase>()),
  );
  sl.registerLazySingleton<TransactionLocalDatasourceImpl>(
    () => TransactionLocalDatasourceImpl(sl<AppDatabase>()),
  );
  sl.registerLazySingleton<UserLocalDatasourceImpl>(
    () => UserLocalDatasourceImpl(sl<AppDatabase>()),
  );
  sl.registerLazySingleton<QueuedActionLocalDatasourceImpl>(
    () => QueuedActionLocalDatasourceImpl(sl<AppDatabase>()),
  );

  // Remote Datasources
  sl.registerLazySingleton<AuthRemoteDataSourceImpl>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl<FirebaseAuth>(),
      googleSignIn: sl<GoogleSignIn>(),
    ),
  );
  sl.registerLazySingleton<StorageRemoteDataSourceImpl>(
    () => StorageRemoteDataSourceImpl(sl<FirebaseStorage>()),
  );
  sl.registerLazySingleton<ProductRemoteDatasourceImpl>(
    () => ProductRemoteDatasourceImpl(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<TransactionRemoteDatasourceImpl>(
    () => TransactionRemoteDatasourceImpl(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<UserRemoteDatasourceImpl>(
    () => UserRemoteDatasourceImpl(sl<FirebaseFirestore>()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepositoryImpl>(
    () => AuthRepositoryImpl(
      authRemoteDataSource: sl<AuthRemoteDataSourceImpl>(),
    ),
  );
  sl.registerLazySingleton<StorageRepositoryImpl>(
    () => StorageRepositoryImpl(
      pingService: sl<PingService>(),
      storageRemoteDataSource: sl<StorageRemoteDataSourceImpl>(),
    ),
  );
  sl.registerLazySingleton<ProductRepositoryImpl>(
    () => ProductRepositoryImpl(
      pingService: sl<PingService>(),
      productLocalDatasource: sl<ProductLocalDatasourceImpl>(),
      productRemoteDatasource: sl<ProductRemoteDatasourceImpl>(),
      queuedActionLocalDatasource: sl<QueuedActionLocalDatasourceImpl>(),
    ),
  );
  sl.registerLazySingleton<TransactionRepositoryImpl>(
    () => TransactionRepositoryImpl(
      pingService: sl<PingService>(),
      transactionLocalDatasource: sl<TransactionLocalDatasourceImpl>(),
      transactionRemoteDatasource: sl<TransactionRemoteDatasourceImpl>(),
      queuedActionLocalDatasource: sl<QueuedActionLocalDatasourceImpl>(),
    ),
  );
  sl.registerLazySingleton<UserRepositoryImpl>(
    () => UserRepositoryImpl(
      pingService: sl<PingService>(),
      userLocalDatasource: sl<UserLocalDatasourceImpl>(),
      userRemoteDatasource: sl<UserRemoteDatasourceImpl>(),
      queuedActionLocalDatasource: sl<QueuedActionLocalDatasourceImpl>(),
    ),
  );
  sl.registerLazySingleton<QueuedActionRepositoryImpl>(
    () => QueuedActionRepositoryImpl(
      pingService: sl<PingService>(),
      queuedActionLocalDatasource: sl<QueuedActionLocalDatasourceImpl>(),
      userRemoteDatasource: sl<UserRemoteDatasourceImpl>(),
      transactionRemoteDatasource: sl<TransactionRemoteDatasourceImpl>(),
      productRemoteDatasource: sl<ProductRemoteDatasourceImpl>(),
    ),
  );

  // Providers
  sl.registerLazySingleton<MainProvider>(
    () => MainProvider(
      deviceInforService: sl<DeviceInfoService>(),
      pingService: sl<PingService>(),
      authProvider: sl<AuthProvider>(),
      userRepository: sl<UserRepositoryImpl>(),
      productRepository: sl<ProductRepositoryImpl>(),
      transactionRepository: sl<TransactionRepositoryImpl>(),
      queuedActionRepository: sl<QueuedActionRepositoryImpl>(),
    ),
  );
  sl.registerLazySingleton<AuthProvider>(
    () => AuthProvider(
      userRepository: sl<UserRepositoryImpl>(),
      authRepository: sl<AuthRepositoryImpl>(),
    ),
  );
  sl.registerLazySingleton<HomeProvider>(
    () => HomeProvider(
      authProvider: sl<AuthProvider>(),
      transactionRepository: sl<TransactionRepositoryImpl>(),
    ),
  );
  sl.registerLazySingleton<ProductsProvider>(
    () => ProductsProvider(
      authProvider: sl<AuthProvider>(),
      productRepository: sl<ProductRepositoryImpl>(),
    ),
  );
  sl.registerLazySingleton<TransactionsProvider>(
    () => TransactionsProvider(
      authProvider: sl<AuthProvider>(),
      transactionRepository: sl<TransactionRepositoryImpl>(),
    ),
  );
  sl.registerLazySingleton<AccountProvider>(
    () => AccountProvider(
      authProvider: sl<AuthProvider>(),
      authRepository: sl<AuthRepositoryImpl>(),
      userRepository: sl<UserRepositoryImpl>(),
      storageRepository: sl<StorageRepositoryImpl>(),
    ),
  );
  sl.registerLazySingleton<ProductFormProvider>(
    () => ProductFormProvider(
      authProvider: sl<AuthProvider>(),
      productRepository: sl<ProductRepositoryImpl>(),
      storageRepository: sl<StorageRepositoryImpl>(),
    ),
  );
  sl.registerLazySingleton<ProductDetailProvider>(
    () => ProductDetailProvider(productRepository: sl<ProductRepositoryImpl>()),
  );
  sl.registerLazySingleton<TransactionDetailProvider>(
    () => TransactionDetailProvider(transactionRepository: sl<TransactionRepositoryImpl>()),
  );
  sl.registerLazySingleton<ThemeProvider>(
    () => ThemeProvider(),
  );

  // Routes
  sl.registerSingleton<AppRoutes>(AppRoutes(sl<AuthProvider>()));
}

// All providers
List<SingleChildWidget> get providers => [
  ChangeNotifierProvider(create: (_) => sl<AuthProvider>()),
  ChangeNotifierProvider(create: (_) => sl<MainProvider>()),
  ChangeNotifierProvider(create: (_) => sl<HomeProvider>()),
  ChangeNotifierProvider(create: (_) => sl<ProductsProvider>()),
  ChangeNotifierProvider(create: (_) => sl<TransactionsProvider>()),
  ChangeNotifierProvider(create: (_) => sl<AccountProvider>()),
  ChangeNotifierProvider(create: (_) => sl<ProductFormProvider>()),
  ChangeNotifierProvider(create: (_) => sl<ProductDetailProvider>()),
  ChangeNotifierProvider(create: (_) => sl<ThemeProvider>()),
];
