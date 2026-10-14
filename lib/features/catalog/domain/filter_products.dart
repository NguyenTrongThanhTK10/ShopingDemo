import 'product.dart';

enum ProductSort { popular, priceAsc, priceDesc, topRated }

/// Matches the local demo catalog without changing its source list.
/// The API backed catalog should eventually perform filtering on the server.
List<Product> filterProducts(
  List<Product> products, {
  String query = '',
  String? categoryId,
  ProductSort sortOrder = ProductSort.popular,
  Map<String, double> ratingOverrides = const {},
}) {
  final normalizedQuery = normalizeVietnameseSearchText(query);
  final matching = products.where((product) {
    if (categoryId != null && product.categoryId != categoryId) return false;
    if (normalizedQuery.isEmpty) return true;

    final searchable = normalizeVietnameseSearchText(
      '${product.name} ${product.shopName} ${product.description}',
    );
    return searchable.contains(normalizedQuery);
  }).toList();

  matching.sort((a, b) {
    final comparison = switch (sortOrder) {
      ProductSort.popular => b.soldCount.compareTo(a.soldCount),
      ProductSort.priceAsc => a.price.compareTo(b.price),
      ProductSort.priceDesc => b.price.compareTo(a.price),
      ProductSort.topRated => (ratingOverrides[b.id] ?? b.rating).compareTo(
        ratingOverrides[a.id] ?? a.rating,
      ),
    };
    return comparison == 0 ? a.id.compareTo(b.id) : comparison;
  });
  return matching;
}

/// Lowercases Vietnamese text and removes tone marks, vowel marks and đ.
String normalizeVietnameseSearchText(String input) {
  var result = input.toLowerCase().replaceAll('đ', 'd');
  const variants = <String, String>{
    'a': 'àáảãạăằắẳẵặâầấẩẫậ',
    'e': 'èéẻẽẹêềếểễệ',
    'i': 'ìíỉĩị',
    'o': 'òóỏõọôồốổỗộơờớởỡợ',
    'u': 'ùúủũụưừứửữự',
    'y': 'ỳýỷỹỵ',
  };
  for (final entry in variants.entries) {
    result = result.replaceAll(RegExp('[${entry.value}]'), entry.key);
  }
  return result
      .replaceAll(RegExp(r'[\u0300-\u036f]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
