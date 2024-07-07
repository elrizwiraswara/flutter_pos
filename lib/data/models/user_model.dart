import 'package:floor/floor.dart';
import 'package:flutter_pos/domain/entities/user_entity.dart';

@Entity(tableName: 'user', primaryKeys: ['id'])
class UserModel {
  final String id;
  final String phone;
  final String name;
  final String? gender;
  final String? birthdate;
  final String? imageUrl;
  final String createdAt;
  final String updatedAt;

  const UserModel({
    required this.id,
    required this.phone,
    required this.name,
    this.gender,
    this.birthdate,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phone: json['phone'],
      name: json['name'],
      gender: json['gender'],
      birthdate: json['birthdate'],
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'gender': gender,
      'birthdate': birthdate,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      phone: entity.phone,
      name: entity.name,
      gender: entity.gender,
      birthdate: entity.birthdate,
      imageUrl: entity.imageUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      phone: phone,
      name: name,
      gender: gender,
      birthdate: birthdate,
      imageUrl: imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
