import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/common/result.dart';
import '../../../core/constants/constants.dart';
import '../../../core/utilities/platform_wrapper.dart';
import '../../../firebase_options.dart';
import '../../models/user_model.dart';
import '../interfaces/auth_datasource.dart';

class AuthRemoteDataSourceImpl implements AuthDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  @override
  Future<Result<UserModel>> signInWithGoogle() async {
    try {
      await googleSignIn.initialize(
        clientId: PlatformWrapper().isIOS ? DefaultFirebaseOptions.ios.iosClientId : null,
        serverClientId: Constants.googleServerClientId.isNotEmpty ? Constants.googleServerClientId : null,
      );

      // Try lightweight (silent) auth first; if no previous session exists, fall back to interactive auth
      GoogleSignInAccount? googleSignInAccount = await googleSignIn.attemptLightweightAuthentication();
      googleSignInAccount ??= await googleSignIn.authenticate();

      final googleSignInAuthentication = googleSignInAccount.authentication;

      // Validate that we received an ID token from Google Sign-In.
      // If this is null, the serverClientId is likely misconfigured.
      if (googleSignInAuthentication.idToken == null || googleSignInAuthentication.idToken!.isEmpty) {
        return Result.failure(
          error:
              'Google Sign-In did not return an ID token. '
              'Ensure the serverClientId matches the Web OAuth client ID in Firebase Console.',
        );
      }

      final googleSignInAuthorization = await googleSignInAccount.authorizationClient.authorizationForScopes(
        Constants.authScopes,
      );

      final credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthorization?.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        return Result.failure(error: 'User data is null after sign-in.');
      }

      return Result.success(data: UserModel.fromFirebaseUser(userCredential.user!));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await firebaseAuth.signOut();
      await googleSignIn.signOut();
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<UserModel?>> getCurrentUser() async {
    try {
      final firebaseUser = firebaseAuth.currentUser;
      return Result.success(data: firebaseUser != null ? UserModel.fromFirebaseUser(firebaseUser) : null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
