import 'package:flutter_pos/core/usecase/usecase.dart';

abstract class AuthBase {
  Future<bool> isAuthenticated();
  Future<Result> getAuthData();
  Future<Result> signIn();
  Future<bool> signOut();
}
