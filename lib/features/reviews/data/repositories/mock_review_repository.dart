import '../../domain/product_review.dart';
import '../../domain/review_repository.dart';
import '../datasources/mock_review_data_source.dart';

class MockReviewRepository implements ReviewRepository {
  MockReviewRepository(this._dataSource);

  final MockReviewDataSource _dataSource;

  @override
  Future<List<ProductReview>> getReviews(String productId) async =>
      List<ProductReview>.unmodifiable(
        (await _dataSource.getReviews(productId)).map((dto) => dto.toEntity()),
      );

  @override
  Future<ProductReview> addReview({
    required String productId,
    required String orderId,
    required String variantId,
    required String variantLabel,
    required String author,
    required int rating,
    required String comment,
  }) async => (await _dataSource.addReview(
    productId: productId,
    orderId: orderId,
    variantId: variantId,
    variantLabel: variantLabel,
    author: author,
    rating: rating,
    comment: comment,
  )).toEntity();
}
