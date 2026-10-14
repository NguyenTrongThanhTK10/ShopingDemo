import 'package:flutter/material.dart';

import '../../domain/product_review.dart';

class ReviewStars extends StatelessWidget {
  const ReviewStars({super.key, required this.rating, this.size = 16});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '${rating.toStringAsFixed(1)} trên 5 sao',
    child: ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < 5; index++)
            Icon(
              rating - index >= 1
                  ? Icons.star_rounded
                  : rating - index >= .5
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
              size: size,
              color: Theme.of(context).colorScheme.tertiary,
            ),
        ],
      ),
    ),
  );
}

class ReviewSummary extends StatelessWidget {
  const ReviewSummary({super.key, required this.summary});

  final ProductReviewSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 98,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.count == 0 ? '—' : summary.average.toStringAsFixed(1),
                  key: const ValueKey('review-average'),
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text('trên 5 sao', style: theme.textTheme.bodySmall),
                const SizedBox(height: 6),
                ReviewStars(rating: summary.average),
                const SizedBox(height: 5),
                Text(
                  '${summary.count} đánh giá',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                for (var stars = 5; stars >= 1; stars--)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Text('$stars', style: theme.textTheme.labelSmall),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: colors.tertiary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: summary.count == 0
                                ? 0
                                : summary.countForStars(stars) / summary.count,
                            minHeight: 5,
                            borderRadius: BorderRadius.circular(4),
                            backgroundColor: colors.outlineVariant,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${summary.countForStars(stars)}',
                            textAlign: TextAlign.end,
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductReviewCard extends StatelessWidget {
  const ProductReviewCard({
    super.key,
    required this.review,
    this.compact = false,
  });

  final ProductReview review;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final date = review.createdAt.toLocal();
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: colors.primaryContainer,
              foregroundColor: colors.primary,
              child: Text(
                review.author.characters.first.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.author, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ReviewStars(rating: review.rating.toDouble(), size: 14),
                      Text(formattedDate, style: theme.textTheme.bodySmall),
                      Text(
                        review.isSample ? 'Mẫu' : 'Đã nhận hàng',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (review.variantLabel != null) ...[
          const SizedBox(height: 8),
          Text(
            'Phân loại: ${review.variantLabel}',
            style: theme.textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 8),
        Text(
          review.comment,
          maxLines: compact ? 4 : null,
          overflow: compact ? TextOverflow.ellipsis : TextOverflow.visible,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class ReviewLoadError extends StatelessWidget {
  const ReviewLoadError({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_off_outlined, size: 36),
        const SizedBox(height: 10),
        const Text(
          'Không tải được đánh giá. Thử lại nhé.',
          textAlign: TextAlign.center,
        ),
        TextButton(onPressed: onRetry, child: const Text('Thử lại')),
      ],
    ),
  );
}
