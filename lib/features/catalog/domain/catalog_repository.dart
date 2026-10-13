import 'category.dart';
import 'product.dart';

abstract class CatalogRepository {
  Future<List<Category>> getCategories();
  Future<List<Product>> getProducts();
  Future<Product?> getProductById(String id);
}
