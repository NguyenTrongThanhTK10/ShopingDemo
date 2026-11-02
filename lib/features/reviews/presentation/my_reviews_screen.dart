import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalog/presentation/product_detail_screen.dart';
import '../../catalog/presentation/widgets/product_image.dart';
import '../../orders/domain/demo_order.dart';
import '../../orders/presentation/providers/orders_provider.dart';
import '../domain/product_review.dart';
import 'providers/review_providers.dart';
import 'widgets/review_form_sheet.dart';
import 'widgets/review_widgets.dart';

final _myReviewEntriesProvider = Provider<AsyncValue<List<_ReviewEntry>>>((
  ref,
) {
  final orders = ref
      .watch(ordersProvider)
      .where((order) => order.stage == OrderStage.completed);
  final entries = <_ReviewEntry>[];
  var loading = false;
  AsyncError<List<_ReviewEntry>>? failure;
  for (final order in orders) {
    for (final line in order.items) {
      final reviews = ref.watch(productReviewsProvider(line.product.id));
      if (reviews.hasError) {
        failure = AsyncError(reviews.error!, reviews.stackTrace!);
      } else if (reviews.isLoading) {
        loading = true;
      } else {
        final matches = reviews.requireValue.where(
          (review) =>
              review.orderId == order.id && review.variantId == line.variant.id,
        );
        entries.add(
          _ReviewEntry(
            target: ProductReviewTarget(
              orderId: order.id,
              product: line.product,
              variant: line.variant,
            ),
            review: matches.isEmpty ? null : matches.first,
          ),
        );
      }
    }
  }
  if (failure != null) return failure;
  if (loading) return const AsyncLoading();
  return AsyncData(entries);
});

class _ReviewEntry {
  const _ReviewEntry({required this.target, this.review});
  final ProductReviewTarget target;
  final ProductReview? review;
}

class MyReviewsScreen extends ConsumerWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(_myReviewEntriesProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đánh giá của tôi'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Chờ đánh giá'),
              Tab(text: 'Đã đánh giá'),
            ],
          ),
        ),
        body: entries.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: ReviewLoadError(
              onRetry: () {
                for (final order in ref.read(ordersProvider)) {
                  for (final line in order.items) {
                    ref.invalidate(productReviewsProvider(line.product.id));
                  }
                }
              },
            ),
          ),
          data: (items) => TabBarView(
            children: [
              _ReviewList(
                entries: items.where((entry) => entry.review == null).toList(),
                pending: true,
              ),
              _ReviewList(
                entries: items.where((entry) => entry.review != null).toList(),
                pending: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewList extends StatelessWidget {
  const _ReviewList({required this.entries, required this.pending});
  final List<_ReviewEntry> entries;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                pending
                    ? 'Chưa có sản phẩm chờ đánh giá'
                    : 'Chưa có đánh giá nào',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                pending
                    ? 'Sau khi nhận hàng, bạn có thể chia sẻ trải nghiệm tại đây.'
                    : 'Những nhận xét bạn đã gửi sẽ xuất hiện ở đây.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final target = entry.target;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          ProductDetailScreen(productId: target.product.id),
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: ProductImage(
                            product: target.product,
                            imageIndex: target.variant.imageIndex ?? 0,
                            compact: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              target.product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${target.variant.label} · ${target.orderId}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (entry.review != null)
                  ProductReviewCard(review: entry.review!)
                else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: () async {
                        final sent = await showReviewFormSheet(
                          context,
                          targets: [target],
                        );
                        if (context.mounted && sent == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Cảm ơn bạn đã chia sẻ trải nghiệm!',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.star_outline_rounded),
                      label: const Text('Viết đánh giá'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
