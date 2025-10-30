import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/user_entity.dart';

class UserModel {
  String id;
  String? email;
  String? phone;
  String? name;
  String? gender;
  String? birthdate;
  String? imageUrl;
  String? authProvider;
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
    this.authProvider,
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
      authProvider: json['authProvider'],
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
      'authProvider': authProvider,
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
      authProvider: entity.authProvider?.value,
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
      authProvider: AuthProvider.fromValue(authProvider),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert Firebase User to UserModel
  factory UserModel.fromFirebaseUser(
    firebase_auth.User firebaseUser, {
    AuthProvider authProvider = AuthProvider.google,
  }) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      phone: firebaseUser.phoneNumber,
      name: firebaseUser.displayName,
      gender: null,
      birthdate: null,
      imageUrl: firebaseUser.photoURL,
      authProvider: authProvider.value,
      createdAt: null,
      updatedAt: null,
    );
  }
}
