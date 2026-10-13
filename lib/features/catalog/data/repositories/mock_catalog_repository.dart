import '../../domain/catalog_repository.dart';
import '../../domain/category.dart';
import '../../domain/product.dart';
import '../datasources/mock_catalog_data_source.dart';

class MockCatalogRepository implements CatalogRepository {
  MockCatalogRepository(this._dataSource);

  final MockCatalogDataSource _dataSource;

  @override
  Future<List<Category>> getCategories() => _dataSource.getCategories();

  @override
  Future<List<Product>> getProducts() async =>
      (await _dataSource.getProducts()).map((dto) => dto.toEntity()).toList();

  @override
  Future<Product?> getProductById(String id) async {
    final products = await getProducts();
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }
}
