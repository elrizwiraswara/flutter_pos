import 'package:flutter_pos/core/errors/errors.dart';
import 'package:flutter_pos/core/usecase/usecase.dart';
import 'package:flutter_pos/domain/entities/product_entity.dart';
import 'package:flutter_pos/domain/repositories/product_repository.dart';
import 'package:flutter_pos/domain/usecases/params/base_params.dart';
import 'package:flutter_pos/domain/usecases/product_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'product_usecase_test.mocks.dart';

@GenerateMocks([ProductRepository])
void main() {
  late GetUserProductsUsecase getUserProductUsecase;
  late MockProductRepository mockProductRepository;

  setUp(() {
    mockProductRepository = MockProductRepository();
    getUserProductUsecase = GetUserProductsUsecase(mockProductRepository);
  });

  const testParams = BaseParams(
    param: "user123",
    orderBy: "name",
    sortBy: "asc",
    limit: 10,
    offset: 0,
    contains: "keyword",
  );

  final testProducts = [
    const ProductEntity(
      id: 1,
      name: "Product A",
      createdById: '1',
      imageUrl: '',
      stock: 1,
      price: 1,
    ),
    const ProductEntity(
      id: 2,
      name: "Product B",
      createdById: '1',
      imageUrl: '',
      stock: 1,
      price: 1,
    ),
  ];

  test('should return a list of ProductEntity when call is successful', () async {
    when(mockProductRepository.getUserProducts(
      any,
      orderBy: anyNamed('orderBy'),
      sortBy: anyNamed('sortBy'),
      limit: anyNamed('limit'),
      offset: anyNamed('offset'),
      contains: anyNamed('contains'),
    )).thenAnswer((_) async => Result.success(testProducts));

    final result = await getUserProductUsecase(testParams);

    expect(result.isSuccess, true);
    expect(result.data, testProducts);
  });

  test('should return an error when repository fails', () async {
    final error = Result<List<ProductEntity>>.error(const APIError());

    when(mockProductRepository.getUserProducts(
      any,
      orderBy: anyNamed('orderBy'),
      sortBy: anyNamed('sortBy'),
      limit: anyNamed('limit'),
      offset: anyNamed('offset'),
      contains: anyNamed('contains'),
    )).thenAnswer((_) async => error);

    final result = await getUserProductUsecase(testParams);

    expect(result.isHasError, true);
    expect(result.error, const APIError());
  });
}
