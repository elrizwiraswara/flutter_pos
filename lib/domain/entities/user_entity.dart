import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String? email;
  final String? phone;
  final String? name;
  final String? gender;
  final String? birthdate;
  final String? imageUrl;
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
    createdAt,
    updatedAt,
  ];
}
