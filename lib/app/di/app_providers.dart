import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/database/app_database.dart';
import '../../core/services/connectivity/ping_service.dart';
import '../../core/services/info/device_info_service.dart';
import '../../core/services/logger/error_logger_service.dart';
import '../../core/services/printer/printer_service.dart';
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
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/queued_action_repository.dart';
import '../../domain/repositories/storage_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../presentation/providers/account/account_provider.dart';
import '../../presentation/providers/account/printer_settings_provider.dart';
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

// Startup overrides
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden at app startup.'),
);

// Third parties
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) => FirebaseStorage.instance);
final firebaseCrashlyticsProvider = Provider<FirebaseCrashlytics>((ref) => FirebaseCrashlytics.instance);
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final googleSignInProvider = Provider<GoogleSignIn>((ref) => GoogleSignIn.instance);
final deviceInfoPluginProvider = Provider<DeviceInfoPlugin>((ref) => DeviceInfoPlugin());

// Database
final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase.instance);

// Services
final pingServiceProvider = Provider<PingService>((ref) => PingService());
final deviceInfoServiceProvider = Provider<DeviceInfoService>(
  (ref) => DeviceInfoService(ref.watch(deviceInfoPluginProvider)),
);
final errorLoggerServiceProvider = Provider<ErrorLoggerService>(
  (ref) => ErrorLoggerService(ref.watch(firebaseCrashlyticsProvider)),
);
final printerServiceProvider = Provider<PrinterService>(
  (ref) => PrinterService(ref.watch(sharedPreferencesProvider)),
);

// Datasources
// Local Datasources
final productLocalDatasourceProvider = Provider<ProductLocalDatasourceImpl>(
  (ref) => ProductLocalDatasourceImpl(ref.watch(appDatabaseProvider)),
);
final transactionLocalDatasourceProvider = Provider<TransactionLocalDatasourceImpl>(
  (ref) => TransactionLocalDatasourceImpl(ref.watch(appDatabaseProvider)),
);
final userLocalDatasourceProvider = Provider<UserLocalDatasourceImpl>(
  (ref) => UserLocalDatasourceImpl(ref.watch(appDatabaseProvider)),
);
final queuedActionLocalDatasourceProvider = Provider<QueuedActionLocalDatasourceImpl>(
  (ref) => QueuedActionLocalDatasourceImpl(ref.watch(appDatabaseProvider)),
);

// Remote Datasources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSourceImpl>(
  (ref) => AuthRemoteDataSourceImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  ),
);
final storageRemoteDataSourceProvider = Provider<StorageRemoteDataSourceImpl>(
  (ref) => StorageRemoteDataSourceImpl(ref.watch(firebaseStorageProvider)),
);
final productRemoteDatasourceProvider = Provider<ProductRemoteDatasourceImpl>(
  (ref) => ProductRemoteDatasourceImpl(ref.watch(firebaseFirestoreProvider)),
);
final transactionRemoteDatasourceProvider = Provider<TransactionRemoteDatasourceImpl>(
  (ref) => TransactionRemoteDatasourceImpl(ref.watch(firebaseFirestoreProvider)),
);
final userRemoteDatasourceProvider = Provider<UserRemoteDatasourceImpl>(
  (ref) => UserRemoteDatasourceImpl(ref.watch(firebaseFirestoreProvider)),
);

// Repositories
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    authRemoteDataSource: ref.watch(authRemoteDataSourceProvider),
  ),
);
final storageRepositoryProvider = Provider<StorageRepository>(
  (ref) => StorageRepositoryImpl(
    pingService: ref.watch(pingServiceProvider),
    storageRemoteDataSource: ref.watch(storageRemoteDataSourceProvider),
  ),
);
final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepositoryImpl(
    pingService: ref.watch(pingServiceProvider),
    productLocalDatasource: ref.watch(productLocalDatasourceProvider),
    productRemoteDatasource: ref.watch(productRemoteDatasourceProvider),
    queuedActionLocalDatasource: ref.watch(queuedActionLocalDatasourceProvider),
  ),
);
final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepositoryImpl(
    pingService: ref.watch(pingServiceProvider),
    transactionLocalDatasource: ref.watch(transactionLocalDatasourceProvider),
    transactionRemoteDatasource: ref.watch(transactionRemoteDatasourceProvider),
    queuedActionLocalDatasource: ref.watch(queuedActionLocalDatasourceProvider),
  ),
);
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepositoryImpl(
    pingService: ref.watch(pingServiceProvider),
    userLocalDatasource: ref.watch(userLocalDatasourceProvider),
    userRemoteDatasource: ref.watch(userRemoteDatasourceProvider),
    queuedActionLocalDatasource: ref.watch(queuedActionLocalDatasourceProvider),
  ),
);
final queuedActionRepositoryProvider = Provider<QueuedActionRepository>(
  (ref) => QueuedActionRepositoryImpl(
    pingService: ref.watch(pingServiceProvider),
    queuedActionLocalDatasource: ref.watch(queuedActionLocalDatasourceProvider),
    userRemoteDatasource: ref.watch(userRemoteDatasourceProvider),
    transactionRemoteDatasource: ref.watch(transactionRemoteDatasourceProvider),
    productRemoteDatasource: ref.watch(productRemoteDatasourceProvider),
  ),
);

// Providers
final authControllerProvider = ChangeNotifierProvider<AuthProvider>(
  (ref) => AuthProvider(
    userRepository: ref.watch(userRepositoryProvider),
    authRepository: ref.watch(authRepositoryProvider),
  ),
);
final productsControllerProvider = ChangeNotifierProvider<ProductsProvider>(
  (ref) => ProductsProvider(
    authProvider: ref.read(authControllerProvider),
    productRepository: ref.watch(productRepositoryProvider),
  ),
);
final transactionsControllerProvider = ChangeNotifierProvider<TransactionsProvider>(
  (ref) => TransactionsProvider(
    authProvider: ref.read(authControllerProvider),
    transactionRepository: ref.watch(transactionRepositoryProvider),
  ),
);
final mainControllerProvider = ChangeNotifierProvider<MainProvider>(
  (ref) => MainProvider(
    deviceInforService: ref.watch(deviceInfoServiceProvider),
    pingService: ref.watch(pingServiceProvider),
    authProvider: ref.read(authControllerProvider),
    userRepository: ref.watch(userRepositoryProvider),
    productRepository: ref.watch(productRepositoryProvider),
    transactionRepository: ref.watch(transactionRepositoryProvider),
    queuedActionRepository: ref.watch(queuedActionRepositoryProvider),
    productsProvider: ref.read(productsControllerProvider),
  ),
);
final homeControllerProvider = ChangeNotifierProvider.autoDispose<HomeProvider>(
  (ref) => HomeProvider(
    authProvider: ref.read(authControllerProvider),
    transactionRepository: ref.watch(transactionRepositoryProvider),
    printerService: ref.watch(printerServiceProvider),
    productsProvider: ref.read(productsControllerProvider),
  ),
);
final accountControllerProvider = ChangeNotifierProvider.autoDispose<AccountProvider>(
  (ref) => AccountProvider(
    authProvider: ref.read(authControllerProvider),
    authRepository: ref.watch(authRepositoryProvider),
    userRepository: ref.watch(userRepositoryProvider),
    storageRepository: ref.watch(storageRepositoryProvider),
  ),
);
final productFormControllerProvider = ChangeNotifierProvider.autoDispose<ProductFormProvider>(
  (ref) => ProductFormProvider(
    authProvider: ref.read(authControllerProvider),
    productRepository: ref.watch(productRepositoryProvider),
    storageRepository: ref.watch(storageRepositoryProvider),
    productsProvider: ref.read(productsControllerProvider),
  ),
);
final productDetailControllerProvider = ChangeNotifierProvider.autoDispose<ProductDetailProvider>(
  (ref) => ProductDetailProvider(
    productRepository: ref.watch(productRepositoryProvider),
  ),
);
final transactionDetailControllerProvider = ChangeNotifierProvider.autoDispose<TransactionDetailProvider>(
  (ref) => TransactionDetailProvider(
    transactionRepository: ref.watch(transactionRepositoryProvider),
  ),
);
final themeControllerProvider = ChangeNotifierProvider<ThemeProvider>(
  (ref) => ThemeProvider(ref.watch(sharedPreferencesProvider)),
);
final printerSettingsControllerProvider = ChangeNotifierProvider.autoDispose<PrinterSettingsProvider>(
  (ref) => PrinterSettingsProvider(
    printerService: ref.watch(printerServiceProvider),
    sharedPreferences: ref.watch(sharedPreferencesProvider),
  ),
);

// Routes
final appRoutesProvider = Provider<AppRoutes>(
  (ref) => AppRoutes(ref.read(authControllerProvider)),
);
