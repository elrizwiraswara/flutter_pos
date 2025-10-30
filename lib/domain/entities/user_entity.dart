import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? phone;
  final String? name;
  final String? gender;
  final String? birthdate;
  final String? imageUrl;
  final AuthProvider? authProvider;
  final String? createdAt;
  final String? updatedAt;

  const UserEntity({
    required this.id,
    this.phone,
    this.email,
    this.name,
    this.gender,
    this.birthdate,
    this.imageUrl,
    this.authProvider,
    this.createdAt,
    this.updatedAt,
  });

  UserEntity copyWith({
    String? id,
    String? phone,
    String? email,
    String? name,
    String? gender,
    String? birthdate,
    String? imageUrl,
    AuthProvider? authProvider,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthdate: birthdate ?? this.birthdate,
      imageUrl: imageUrl ?? this.imageUrl,
      authProvider: authProvider ?? this.authProvider,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    phone,
    name,
    gender,
    birthdate,
    imageUrl,
    authProvider,
    createdAt,
    updatedAt,
  ];
}

enum AuthProvider {
  google('google');
  // add other if needed

  final String value;
  const AuthProvider(this.value);

  static AuthProvider? fromValue(String? value) {
    return AuthProvider.values.where((e) => e.value == value).firstOrNull;
  }
}
