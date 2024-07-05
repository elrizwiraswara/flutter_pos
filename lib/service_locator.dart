import 'package:get_it/get_it.dart';
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
  // sl.registerLazySingleton(() => MainProvider());
  // sl.registerLazySingleton(() => UserListProvider(userRepository: sl<UserRepositoryImpl>()));
  // sl.registerLazySingleton(() => UserDetailProvider(userRepository: sl<UserRepositoryImpl>()));
  // sl.registerLazySingleton(() => UserFormProvider(userRepository: sl<UserRepositoryImpl>()));
}

// All providers
final List<SingleChildWidget> providers = [
  // ChangeNotifierProvider(create: (_) => sl<MainProvider>()),
];
