import 'filter_products.dart';
import 'product.dart';

/// Suggests distinct catalog names, prioritizing names that start with the query.
List<String> productSearchSuggestions(
  List<Product> products, {
  required String query,
  String? categoryId,
}) {
  final normalizedQuery = normalizeVietnameseSearchText(query);
  if (normalizedQuery.isEmpty) return const [];

  final candidates = <String, String>{};
  for (final product in filterProducts(products, categoryId: categoryId)) {
    for (final name in [product.name, product.shopName]) {
      final normalizedName = normalizeVietnameseSearchText(name);
      if (normalizedName.contains(normalizedQuery)) {
        candidates.putIfAbsent(normalizedName, () => name);
      }
    }
  }

  return [
    for (final entry in candidates.entries)
      if (entry.key.startsWith(normalizedQuery)) entry.value,
    for (final entry in candidates.entries)
      if (!entry.key.startsWith(normalizedQuery)) entry.value,
  ].take(6).toList();
}
