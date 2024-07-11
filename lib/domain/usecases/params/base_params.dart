import 'package:equatable/equatable.dart';

class BaseParams<T> extends Equatable {
  final T? param;
  final String orderBy;
  final String sortBy;
  final int limit;
  final int? offset;

  const BaseParams({
    this.param,
    this.orderBy = 'createdAt',
    this.sortBy = 'DESC',
    this.limit = 10,
    this.offset,
  });

  @override
  List<Object> get props => [];
}
