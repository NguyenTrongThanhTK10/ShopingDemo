import '../../domain/product_review.dart';

class ProductReviewDto {
  const ProductReviewDto({
    required this.id,
    required this.productId,
    required this.author,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.orderId,
    this.variantId,
    this.variantLabel,
    this.isSample = false,
  });

  final String id;
  final String productId;
  final String author;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String? orderId;
  final String? variantId;
  final String? variantLabel;
  final bool isSample;

  ProductReview toEntity() => ProductReview(
    id: id,
    productId: productId,
    author: author,
    rating: rating,
    comment: comment,
    createdAt: createdAt,
    orderId: orderId,
    variantId: variantId,
    variantLabel: variantLabel,
    isSample: isSample,
  );
}
