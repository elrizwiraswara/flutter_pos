import '../../domain/entities/queued_action_entity.dart';

class QueuedActionModel {
  int? id;
  String repository;
  String method;
  String param;
  bool isCritical;
  String? createdAt;

  QueuedActionModel({
    this.id,
    required this.repository,
    required this.method,
    required this.param,
    required this.isCritical,
    this.createdAt,
  });

  factory QueuedActionModel.fromJson(Map<String, dynamic> json) {
    return QueuedActionModel(
      id: json['id'],
      repository: json['repository'],
      method: json['method'],
      param: json['param'],
      isCritical: json['isCritical'] == 1 ? true : false,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'repository': repository,
      'method': method,
      'param': param,
      'isCritical': isCritical ? 1 : 0,
      'createdAt': createdAt,
    };
  }

  factory QueuedActionModel.fromEntity(QueuedActionEntity entity) {
    return QueuedActionModel(
      id: entity.id,
      repository: entity.repository,
      method: entity.method,
      param: entity.param,
      isCritical: entity.isCritical,
      createdAt: entity.createdAt,
    );
  }

  QueuedActionEntity toEntity() {
    return QueuedActionEntity(
      id: id,
      repository: repository,
      method: method,
      param: param,
      isCritical: isCritical,
      createdAt: createdAt,
    );
  }
}
