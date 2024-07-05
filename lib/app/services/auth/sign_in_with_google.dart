import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_pos/core/auth/auth_base.dart';
import 'package:flutter_pos/core/errors/errors.dart';
import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService implements AuthBase {
  AuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  @override
  Future<bool> isAuthenticated() async {
    return _firebaseAuth.currentUser != null;
  }

  @override
  Future<Result<User?>> getAuthData() async {
    var result = _firebaseAuth.currentUser;
    return Result.success(result);
  }

  @override
  Future<Result<UserCredential>> signIn() async {
    try {
      final googleUser = await _googleSignIn.signIn();

      final googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      var result = await _firebaseAuth.signInWithCredential(credential);

      return Result.success(result);
    } catch (e) {
      return Result.error(ServiceError(error: e.toString()));
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }
}
