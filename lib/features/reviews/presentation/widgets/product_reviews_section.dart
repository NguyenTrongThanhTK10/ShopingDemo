import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../catalog/domain/product.dart';
import '../../domain/product_review.dart';
import '../product_reviews_screen.dart';
import '../providers/review_providers.dart';
import 'review_widgets.dart';
import 'review_write_action.dart';

class ProductReviewsSection extends ConsumerWidget {
  const ProductReviewsSection({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reviews = ref.watch(productReviewsProvider(product.id));
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Đánh giá sản phẩm',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ProductReviewsScreen(product: product),
                  ),
                ),
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          reviews.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => ReviewLoadError(
              onRetry: () => ref.invalidate(productReviewsProvider(product.id)),
            ),
            data: (items) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReviewSummary(summary: ProductReviewSummary.fromReviews(items)),
                const SizedBox(height: 12),
                if (items.any((review) => review.isSample))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Các nhận xét gắn nhãn “Mẫu” là dữ liệu minh họa.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Chưa có nhận xét. Hãy chia sẻ trải nghiệm sau khi nhận hàng.',
                    ),
                  ),
                for (final review in items.take(2)) ...[
                  ProductReviewCard(review: review, compact: true),
                  const Divider(height: 28),
                ],
                ReviewWriteAction(productId: product.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
