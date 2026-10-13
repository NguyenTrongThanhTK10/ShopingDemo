import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/mock_catalog_data_source.dart';
import '../../data/repositories/mock_catalog_repository.dart';
import '../../domain/catalog_repository.dart';
import '../../domain/category.dart';
import '../../domain/product.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => MockCatalogRepository(MockCatalogDataSource()),
);

final categoriesProvider = FutureProvider<List<Category>>(
  (ref) => ref.watch(catalogRepositoryProvider).getCategories(),
);

final productsProvider = FutureProvider<List<Product>>(
  (ref) => ref.watch(catalogRepositoryProvider).getProducts(),
);

final productByIdProvider = FutureProvider.family<Product?, String>(
  (ref, id) => ref.watch(catalogRepositoryProvider).getProductById(id),
);
