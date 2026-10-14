import 'product_review.dart';

abstract interface class ReviewRepository {
  Future<List<ProductReview>> getReviews(String productId);

  Future<ProductReview> addReview({
    required String productId,
    required String orderId,
    required String variantId,
    required String variantLabel,
    required String author,
    required int rating,
    required String comment,
  });
}
