import '../../models/user_model.dart';

abstract class UserDatasource {
  Future<String> createUser(UserModel user);

  Future<void> updateUser(UserModel user);

  Future<void> deleteUser(String id);

  Future<UserModel?> getUser(String id);
}
