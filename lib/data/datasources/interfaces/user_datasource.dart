import '../../../core/common/result.dart';
import '../../models/user_model.dart';

abstract class UserDatasource {
  Future<Result<String>> createUser(UserModel user);

  Future<Result<void>> updateUser(UserModel user);

  Future<Result<void>> deleteUser(String id);

  Future<Result<UserModel?>> getUser(String id);
}
