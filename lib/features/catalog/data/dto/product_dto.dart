import '../../domain/product.dart';

class ProductVariantDto {
  const ProductVariantDto({
    required this.id,
    required this.label,
    required this.price,
    required this.stock,
  });

  final String id;
  final String label;
  final int price;
  final int stock;

  ProductVariant toEntity() =>
      ProductVariant(id: id, label: label, price: price, stock: stock);
}

class ProductDto {
  const ProductDto({
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
    this.oldPrice,
  });

  final String id;
  final String name;
  final String description;
  final String shopId;
  final String shopName;
  final String categoryId;
  final int price;
  final int? oldPrice;
  final double rating;
  final int soldCount;
  final String emoji;
  final List<ProductVariantDto> variants;

  Product toEntity() => Product(
    id: id,
    name: name,
    description: description,
    shopId: shopId,
    shopName: shopName,
    categoryId: categoryId,
    price: price,
    oldPrice: oldPrice,
    rating: rating,
    soldCount: soldCount,
    emoji: emoji,
    variants: variants.map((variant) => variant.toEntity()).toList(),
  );
}
