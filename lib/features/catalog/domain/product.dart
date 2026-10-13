class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.label,
    required this.price,
    required this.stock,
    this.imageIndex,
  });

  final String id;
  final String label;

  /// Price in whole Vietnamese đồng. Display only in this local demo.
  final int price;
  final int stock;

  /// Index of the matching photo in [Product.imagePaths], when available.
  final int? imageIndex;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.shopId,
    required this.shopName,
    required this.categoryId,
    required this.price,
    required this.rating,
    required this.soldCount,
    required this.emoji,
    required this.variants,
    this.imagePaths = const [],
    this.oldPrice,
  });

  final String id;
  final String name;
  final String description;
  final String shopId;
  final String shopName;
  final String categoryId;

  /// Starting price in whole Vietnamese đồng.
  final int price;
  final int? oldPrice;
  final double rating;
  final int soldCount;
  final String emoji;
  final List<ProductVariant> variants;
  final List<String> imagePaths;
}
