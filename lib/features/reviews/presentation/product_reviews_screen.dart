import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalog/domain/filter_products.dart';
import '../../catalog/domain/product.dart';
import '../domain/product_review.dart';
import 'providers/review_providers.dart';
import 'widgets/review_widgets.dart';
import 'widgets/review_write_action.dart';

class ProductReviewsScreen extends ConsumerStatefulWidget {
  const ProductReviewsScreen({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<ProductReviewsScreen> createState() =>
      _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends ConsumerState<ProductReviewsScreen> {
  final _searchController = TextEditingController();
  int? _stars;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reviews = ref.watch(productReviewsProvider(widget.product.id));
    return Scaffold(
      appBar: AppBar(title: const Text('Đánh giá sản phẩm')),
      bottomNavigationBar: Container(
        color: theme.colorScheme.surface,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: ReviewWriteAction(productId: widget.product.id),
          ),
        ),
      ),
      body: reviews.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: ReviewLoadError(
            onRetry: () =>
                ref.invalidate(productReviewsProvider(widget.product.id)),
          ),
        ),
        data: (items) {
          final summary = ProductReviewSummary.fromReviews(items);
          final query = normalizeVietnameseSearchText(_searchController.text);
          final filtered = items
              .where(
                (review) =>
                    (_stars == null || review.rating == _stars) &&
                    (query.isEmpty ||
                        normalizeVietnameseSearchText(
                          '${review.author} ${review.comment} ${review.variantLabel ?? ''}',
                        ).contains(query)),
              )
              .toList();
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          ReviewSummary(summary: summary),
                          const SizedBox(height: 12),
                          if (items.any((review) => review.isSample))
                            Text(
                              'Nhận xét có nhãn “Mẫu” là dữ liệu minh họa.',
                              style: theme.textTheme.bodySmall,
                            ),
                          const SizedBox(height: 10),
                          SizedBox(
                            key: const ValueKey('review-star-filters'),
                            height: 48,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                ChoiceChip(
                                  label: Text('Tất cả (${items.length})'),
                                  selected: _stars == null,
                                  onSelected: (_) =>
                                      setState(() => _stars = null),
                                ),
                                for (var stars = 5; stars >= 1; stars--) ...[
                                  const SizedBox(width: 8),
                                  ChoiceChip(
                                    label: Text(
                                      '$stars sao (${summary.countForStars(stars)})',
                                    ),
                                    selected: _stars == stars,
                                    onSelected: (_) =>
                                        setState(() => _stars = stars),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Tìm trong nhận xét',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _searchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Xóa tìm kiếm nhận xét',
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                      icon: const Icon(Icons.close_rounded),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${filtered.length} nhận xét',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (filtered.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.rate_review_outlined,
                              size: 44,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              items.isEmpty
                                  ? 'Chưa có đánh giá nào'
                                  : 'Không có nhận xét phù hợp',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium,
                            ),
                            if (_stars != null || query.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _stars = null);
                                },
                                child: const Text('Xóa bộ lọc'),
                              ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, index) => Container(
                        color: theme.colorScheme.surface,
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        padding: const EdgeInsets.all(16),
                        child: ProductReviewCard(review: filtered[index]),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
