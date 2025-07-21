import 'package:equatable/equatable.dart';

class QueuedActionEntity extends Equatable {
  final int? id;
  final String repository;
  final String method;
  final String param;
  final bool isCritical;
  final String? createdAt;

  const QueuedActionEntity({
    this.id,
    required this.repository,
    required this.method,
    required this.param,
    required this.isCritical,
    this.createdAt,
  });

  QueuedActionEntity copyWith({
    int? id,
    String? repository,
    String? method,
    String? param,
    bool? isCritical,
    String? createdAt,
  }) {
    return QueuedActionEntity(
      id: id ?? this.id,
      repository: repository ?? this.repository,
      method: method ?? this.method,
      param: param ?? this.param,
      isCritical: isCritical ?? this.isCritical,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    repository,
    method,
    param,
    isCritical,
    createdAt,
  ];
}
