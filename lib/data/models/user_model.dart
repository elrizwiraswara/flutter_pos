import '../../domain/entities/user_entity.dart';

class UserModel {
  String id;
  String? email;
  String? phone;
  String? name;
  String? gender;
  String? birthdate;
  String? imageUrl;
  String? createdAt;
  String? updatedAt;

  UserModel({
    required this.id,
    this.email,
    this.phone,
    this.name,
    this.gender,
    this.birthdate,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
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
      'email': email,
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
      email: entity.email,
      phone: entity.phone,
      name: entity.name,
      gender: entity.gender,
      birthdate: entity.birthdate,
      imageUrl: entity.imageUrl,
      createdAt: entity.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: entity.updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
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
