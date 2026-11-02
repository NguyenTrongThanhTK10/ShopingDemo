import 'product.dart';

enum ProductSort { popular, priceAsc, priceDesc, topRated }

/// Lowest-priced option that satisfies the same price and stock constraints.
ProductVariant? matchingProductVariant(
  Product product, {
  int? minimumPrice,
  int? maximumPrice,
  bool inStockOnly = false,
}) {
  ProductVariant? result;
  for (final variant in product.variants) {
    if (inStockOnly && variant.stock < 1) continue;
    if (minimumPrice != null && variant.price < minimumPrice) continue;
    if (maximumPrice != null && variant.price > maximumPrice) continue;
    if (result == null || variant.price < result.price) result = variant;
  }
  return result;
}

/// Matches the local demo catalog without changing its source list.
/// The API backed catalog should eventually perform filtering on the server.
List<Product> filterProducts(
  List<Product> products, {
  String query = '',
  String? categoryId,
  ProductSort sortOrder = ProductSort.popular,
  Map<String, double> ratingOverrides = const {},
  int? minimumPrice,
  int? maximumPrice,
  double minimumRating = 0,
  bool inStockOnly = false,
}) {
  final normalizedQuery = normalizeVietnameseSearchText(query);
  final matchingPrices = <String, int>{};
  final matching = products.where((product) {
    if (categoryId != null && product.categoryId != categoryId) return false;
    // Match purchasable variants, so a low starting price cannot hide a
    // higher-priced option that fits the buyer's range.
    if (minimumPrice != null || maximumPrice != null || inStockOnly) {
      final variant = matchingProductVariant(
        product,
        minimumPrice: minimumPrice,
        maximumPrice: maximumPrice,
        inStockOnly: inStockOnly,
      );
      if (variant == null) return false;
      matchingPrices[product.id] = variant.price;
    }
    if ((ratingOverrides[product.id] ?? product.rating) < minimumRating) {
      return false;
    }
    if (normalizedQuery.isEmpty) return true;

    final searchable = normalizeVietnameseSearchText(
      '${product.name} ${product.shopName} ${product.description}',
    );
    return searchable.contains(normalizedQuery);
  }).toList();

  matching.sort((a, b) {
    final comparison = switch (sortOrder) {
      ProductSort.popular => b.soldCount.compareTo(a.soldCount),
      ProductSort.priceAsc => (matchingPrices[a.id] ?? a.price).compareTo(
        matchingPrices[b.id] ?? b.price,
      ),
      ProductSort.priceDesc => (matchingPrices[b.id] ?? b.price).compareTo(
        matchingPrices[a.id] ?? a.price,
      ),
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
