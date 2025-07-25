// Mocks generated by Mockito 5.4.6 from annotations
// in flutter_pos/test/presentation/screens/auth/sign_in/sign_in_screen_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;
import 'dart:ui' as _i6;

import 'package:flutter_pos/core/usecase/usecase.dart' as _i3;
import 'package:flutter_pos/domain/repositories/user_repository.dart' as _i2;
import 'package:flutter_pos/presentation/providers/auth/auth_provider.dart'
    as _i4;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeUserRepository_0 extends _i1.SmartFake
    implements _i2.UserRepository {
  _FakeUserRepository_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeResult_1<T> extends _i1.SmartFake implements _i3.Result<T> {
  _FakeResult_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [AuthProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthProvider extends _i1.Mock implements _i4.AuthProvider {
  MockAuthProvider() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.UserRepository get userRepository =>
      (super.noSuchMethod(
            Invocation.getter(#userRepository),
            returnValue: _FakeUserRepository_0(
              this,
              Invocation.getter(#userRepository),
            ),
          )
          as _i2.UserRepository);

  @override
  bool get hasListeners =>
      (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false)
          as bool);

  @override
  _i5.Future<_i3.Result<String>> signIn() =>
      (super.noSuchMethod(
            Invocation.method(#signIn, []),
            returnValue: _i5.Future<_i3.Result<String>>.value(
              _FakeResult_1<String>(this, Invocation.method(#signIn, [])),
            ),
          )
          as _i5.Future<_i3.Result<String>>);

  @override
  _i5.Future<_i3.Result<String>> saveUser() =>
      (super.noSuchMethod(
            Invocation.method(#saveUser, []),
            returnValue: _i5.Future<_i3.Result<String>>.value(
              _FakeResult_1<String>(this, Invocation.method(#saveUser, [])),
            ),
          )
          as _i5.Future<_i3.Result<String>>);

  @override
  void addListener(_i6.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#addListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void removeListener(_i6.VoidCallback? listener) => super.noSuchMethod(
    Invocation.method(#removeListener, [listener]),
    returnValueForMissingStub: null,
  );

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );

  @override
  void notifyListeners() => super.noSuchMethod(
    Invocation.method(#notifyListeners, []),
    returnValueForMissingStub: null,
  );
}
