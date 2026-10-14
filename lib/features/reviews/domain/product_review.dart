class ProductReview {
  const ProductReview({
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
}

class ProductReviewSummary {
  ProductReviewSummary.fromReviews(List<ProductReview> reviews)
    : count = reviews.length,
      average = reviews.isEmpty
          ? 0
          : reviews.fold<int>(0, (sum, review) => sum + review.rating) /
                reviews.length,
      starCounts = List<int>.unmodifiable([
        for (var stars = 1; stars <= 5; stars++)
          reviews.where((review) => review.rating == stars).length,
      ]);

  final int count;
  final double average;
  final List<int> starCounts;

  int countForStars(int stars) => starCounts[stars - 1];
}

class ReviewException implements Exception {
  const ReviewException(this.message);

  final String message;
}
