import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../catalog/domain/product.dart';
import '../../../orders/domain/demo_order.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../../data/datasources/mock_review_data_source.dart';
import '../../data/repositories/mock_review_repository.dart';
import '../../domain/product_review.dart';
import '../../domain/review_repository.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => MockReviewRepository(MockReviewDataSource()),
);

final productReviewsProvider =
    FutureProvider.family<List<ProductReview>, String>(
      (ref, productId) =>
          ref.watch(reviewRepositoryProvider).getReviews(productId),
      retry: (retryCount, error) => null,
    );

final productReviewSummaryProvider =
    Provider.family<ProductReviewSummary?, String>((ref, productId) {
      final reviews = ref.watch(productReviewsProvider(productId)).value;
      return reviews == null ? null : ProductReviewSummary.fromReviews(reviews);
    });

class ProductReviewTarget {
  const ProductReviewTarget({
    required this.orderId,
    required this.product,
    required this.variant,
  });

  final String orderId;
  final Product product;
  final ProductVariant variant;
}

final productReviewTargetsProvider =
    Provider.family<List<ProductReviewTarget>, String>((ref, productId) {
      final orders = ref.watch(ordersProvider);
      final reviews = ref.watch(productReviewsProvider(productId)).value;
      if (reviews == null) return const [];
      return [
        for (final order in orders)
          if (order.stage == OrderStage.completed)
            for (final line in order.items)
              if (line.product.id == productId &&
                  !reviews.any(
                    (review) =>
                        review.orderId == order.id &&
                        review.variantId == line.variant.id,
                  ))
                ProductReviewTarget(
                  orderId: order.id,
                  product: line.product,
                  variant: line.variant,
                ),
      ];
    });

final reviewSubmissionProvider =
    NotifierProvider<ReviewSubmissionNotifier, AsyncValue<void>>(
      ReviewSubmissionNotifier.new,
    );

class ReviewSubmissionNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<ProductReview> submit({
    required String orderId,
    required String variantId,
    required int rating,
    required String comment,
  }) async {
    if (state.isLoading) {
      throw const ReviewException('Đang gửi đánh giá, vui lòng đợi.');
    }
    state = const AsyncLoading();
    try {
      final orders = ref
          .read(ordersProvider)
          .where((order) => order.id == orderId);
      if (orders.isEmpty || orders.first.stage != OrderStage.completed) {
        throw const ReviewException(
          'Bạn chỉ có thể đánh giá đơn hàng đã hoàn thành.',
        );
      }
      final order = orders.first;
      final lines = order.items.where((line) => line.variant.id == variantId);
      if (lines.isEmpty) {
        throw const ReviewException('Sản phẩm không thuộc đơn hàng này.');
      }
      final line = lines.first;
      final review = await ref
          .read(reviewRepositoryProvider)
          .addReview(
            productId: line.product.id,
            orderId: order.id,
            variantId: line.variant.id,
            variantLabel: line.variant.label,
            author: order.recipient,
            rating: rating,
            comment: comment,
          );
      if (ref.mounted) {
        ref.invalidate(productReviewsProvider(line.product.id));
        state = const AsyncData(null);
      }
      return review;
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
