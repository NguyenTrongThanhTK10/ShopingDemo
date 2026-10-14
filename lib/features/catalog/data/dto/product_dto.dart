import '../../domain/product.dart';

class ProductVariantDto {
  const ProductVariantDto({
    required this.id,
    required this.label,
    required this.price,
    required this.stock,
    this.imageIndex,
  });

  final String id;
  final String label;
  final int price;
  final int stock;
  final int? imageIndex;

  ProductVariant toEntity() => ProductVariant(
    id: id,
    label: label,
    price: price,
    stock: stock,
    imageIndex: imageIndex,
  );
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
    this.imagePaths = const [],
    this.oldPrice,
    this.shipFrom,
    this.deliveryEstimate,
  });

  final String id;
  final String name;
  final String description;
  final String shopId;
  final String shopName;
  final String? shipFrom;
  final String? deliveryEstimate;
  final String categoryId;
  final int price;
  final int? oldPrice;
  final double rating;
  final int soldCount;
  final String emoji;
  final List<ProductVariantDto> variants;
  final List<String> imagePaths;

  Product toEntity() => Product(
    id: id,
    name: name,
    description: description,
    shopId: shopId,
    shopName: shopName,
    shipFrom: shipFrom,
    deliveryEstimate: deliveryEstimate,
    categoryId: categoryId,
    price: price,
    oldPrice: oldPrice,
    rating: rating,
    soldCount: soldCount,
    emoji: emoji,
    variants: variants.map((variant) => variant.toEntity()).toList(),
    imagePaths: imagePaths,
  );
}
