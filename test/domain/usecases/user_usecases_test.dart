import 'package:flutter_pos/core/common/result.dart';
import 'package:flutter_pos/domain/entities/user_entity.dart';
import 'package:flutter_pos/domain/repositories/user_repository.dart';
import 'package:flutter_pos/domain/usecases/user_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'user_usecases_test.mocks.dart';

// This will generate the mock class
@GenerateMocks([UserRepository])
void main() {
  late MockUserRepository mockUserRepository;

  setUpAll(() {
    // Provide dummy values for complex types
    provideDummy<Result<String>>(Result<String>.success(data: ''));
    provideDummy<Result<void>>(Result<void>.success(data: null));
    provideDummy<Result<UserEntity?>>(Result<UserEntity?>.success(data: null));
  });

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  group('GetUserUsecase', () {
    late GetUserUsecase usecase;

    setUp(() {
      usecase = GetUserUsecase(mockUserRepository);
    });

    test('should get user by id successfully', () async {
      // arrange
      const userId = 'user123';
      final user = UserEntity(
        id: userId,
        name: 'John Doe',
        email: 'john@example.com',
      );
      final result = Result<UserEntity?>.success(data: user);

      when(mockUserRepository.getUser(userId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(userId);

      // assert
      expect(response, result);
      expect(response.data?.id, userId);
      expect(response.data?.name, 'John Doe');
      verify(mockUserRepository.getUser(userId));
      verifyNoMoreInteractions(mockUserRepository);
    });

    test('should return null when user not found', () async {
      // arrange
      const userId = 'nonexistent';
      final result = Result<UserEntity?>.success(data: null);

      when(mockUserRepository.getUser(userId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(userId);

      // assert
      expect(response.data, isNull);
      expect(response.isSuccess, true);
      verify(mockUserRepository.getUser(userId));
    });

    test('should return failure when getting user fails', () async {
      // arrange
      const userId = 'user123';
      final result = Result<UserEntity?>.failure(error: 'Database error');

      when(mockUserRepository.getUser(userId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(userId);

      // assert
      expect(response.isFailure, true);
      verify(mockUserRepository.getUser(userId));
    });
  });

  group('CreateUserUsecase', () {
    late CreateUserUsecase usecase;

    setUp(() {
      usecase = CreateUserUsecase(mockUserRepository);
    });

    test('should create new user when user does not exist', () async {
      // arrange
      final user = UserEntity(
        id: 'user123',
        name: 'John Doe',
        email: 'john@example.com',
      );
      final getUserResult = Result<UserEntity?>.success(data: null);
      final createUserResult = Result<String>.success(data: 'user123');

      when(mockUserRepository.getUser(user.id)).thenAnswer((_) async => getUserResult);
      when(mockUserRepository.createUser(user)).thenAnswer((_) async => createUserResult);

      // act
      final response = await usecase.call(user);

      // assert
      expect(response, createUserResult);
      expect(response.data, 'user123');
      verify(mockUserRepository.getUser(user.id));
      verify(mockUserRepository.createUser(user));
      verifyNoMoreInteractions(mockUserRepository);
    });

    test('should return existing user id when user already exists', () async {
      // arrange
      final user = UserEntity(
        id: 'user123',
        name: 'John Doe',
        email: 'john@example.com',
      );
      final existingUser = UserEntity(
        id: 'user123',
        name: 'John Doe',
        email: 'john@example.com',
      );
      final getUserResult = Result<UserEntity?>.success(data: existingUser);

      when(mockUserRepository.getUser(user.id)).thenAnswer((_) async => getUserResult);

      // act
      final response = await usecase.call(user);

      // assert
      expect(response.isSuccess, true);
      expect(response.data, 'user123');
      verify(mockUserRepository.getUser(user.id));
      verifyNever(mockUserRepository.createUser(any));
      verifyNoMoreInteractions(mockUserRepository);
    });

    test('should return failure when createUser fails', () async {
      // arrange
      final user = UserEntity(
        id: 'user123',
        name: 'John Doe',
        email: 'john@example.com',
      );
      final getUserResult = Result<UserEntity?>.success(data: null);
      final createUserResult = Result<String>.failure(error: 'Creation failed');

      when(mockUserRepository.getUser(user.id)).thenAnswer((_) async => getUserResult);
      when(mockUserRepository.createUser(user)).thenAnswer((_) async => createUserResult);

      // act
      final response = await usecase.call(user);

      // assert
      expect(response.isFailure, true);
      verify(mockUserRepository.getUser(user.id));
      verify(mockUserRepository.createUser(user));
    });

    test('should handle validation error during creation', () async {
      // arrange
      final user = UserEntity(
        id: 'user123',
        name: '',
        email: 'invalid-email',
      );
      final getUserResult = Result<UserEntity?>.success(data: null);
      final createUserResult = Result<String>.failure(error: 'Invalid user data');

      when(mockUserRepository.getUser(user.id)).thenAnswer((_) async => getUserResult);
      when(mockUserRepository.createUser(user)).thenAnswer((_) async => createUserResult);

      // act
      final response = await usecase.call(user);

      // assert
      expect(response.isFailure, true);
      verify(mockUserRepository.getUser(user.id));
      verify(mockUserRepository.createUser(user));
    });
  });

  group('UpateUserUsecase', () {
    late UpateUserUsecase usecase;

    setUp(() {
      usecase = UpateUserUsecase(mockUserRepository);
    });

    test('should update user successfully', () async {
      // arrange
      final user = UserEntity(
        id: 'user123',
        name: 'John Doe Updated',
        email: 'john.new@example.com',
      );
      final result = Result<void>.success(data: null);

      when(mockUserRepository.updateUser(user)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(user);

      // assert
      expect(response, result);
      expect(response.isSuccess, true);
      verify(mockUserRepository.updateUser(user));
      verifyNoMoreInteractions(mockUserRepository);
    });

    test('should return failure when update fails', () async {
      // arrange
      final user = UserEntity(
        id: 'user123',
        name: 'John Doe Updated',
        email: 'john.new@example.com',
      );
      final result = Result<void>.failure(error: 'Update failed');

      when(mockUserRepository.updateUser(user)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(user);

      // assert
      expect(response.isFailure, true);
      verify(mockUserRepository.updateUser(user));
    });

    test('should handle user not found during update', () async {
      // arrange
      final user = UserEntity(
        id: 'nonexistent',
        name: 'John Doe',
        email: 'john@example.com',
      );
      final result = Result<void>.failure(error: 'User not found');

      when(mockUserRepository.updateUser(user)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(user);

      // assert
      expect(response.isFailure, true);
      verify(mockUserRepository.updateUser(user));
    });

    test('should handle validation error during update', () async {
      // arrange
      final user = UserEntity(
        id: 'user123',
        name: '',
        email: 'invalid-email',
      );
      final result = Result<void>.failure(error: 'Invalid user data');

      when(mockUserRepository.updateUser(user)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(user);

      // assert
      expect(response.isFailure, true);
      verify(mockUserRepository.updateUser(user));
    });
  });

  group('DeleteUserUsecase', () {
    late DeleteUserUsecase usecase;

    setUp(() {
      usecase = DeleteUserUsecase(mockUserRepository);
    });

    test('should delete user successfully', () async {
      // arrange
      const userId = 'user123';
      final result = Result<void>.success(data: null);

      when(mockUserRepository.deleteUser(userId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(userId);

      // assert
      expect(response, result);
      expect(response.isSuccess, true);
      verify(mockUserRepository.deleteUser(userId));
      verifyNoMoreInteractions(mockUserRepository);
    });

    test('should return failure when deletion fails', () async {
      // arrange
      const userId = 'user123';
      final result = Result<void>.failure(error: 'Deletion failed');

      when(mockUserRepository.deleteUser(userId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(userId);

      // assert
      expect(response.isFailure, true);
      verify(mockUserRepository.deleteUser(userId));
    });

    test('should handle user not found scenario', () async {
      // arrange
      const userId = 'nonexistent';
      final result = Result<void>.failure(error: 'User not found');

      when(mockUserRepository.deleteUser(userId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(userId);

      // assert
      expect(response.isFailure, true);
      verify(mockUserRepository.deleteUser(userId));
    });

    test('should handle database error during deletion', () async {
      // arrange
      const userId = 'user123';
      final result = Result<void>.failure(error: 'Database error');

      when(mockUserRepository.deleteUser(userId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(userId);

      // assert
      expect(response.isFailure, true);
      verify(mockUserRepository.deleteUser(userId));
    });

    test('should handle cascade deletion constraints', () async {
      // arrange
      const userId = 'user123';
      final result = Result<void>.failure(error: 'Cannot delete user with existing data');

      when(mockUserRepository.deleteUser(userId)).thenAnswer((_) async => result);

      // act
      final response = await usecase.call(userId);

      // assert
      expect(response.isFailure, true);
      verify(mockUserRepository.deleteUser(userId));
    });
  });
}
