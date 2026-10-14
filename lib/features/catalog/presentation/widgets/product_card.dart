import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/money_formatter.dart';
import '../../../reviews/presentation/providers/review_providers.dart';
import '../../domain/product.dart';
import 'product_image.dart';

class ProductCard extends ConsumerWidget {
  const ProductCard({
    required this.product,
    required this.onTap,
    this.compact = false,
    super.key,
  });

  final Product product;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final summary = ref.watch(productReviewSummaryProvider(product.id));
    final ratingLabel = summary == null
        ? product.rating.toStringAsFixed(1)
        : summary.count == 0
        ? 'Mới'
        : summary.average.toStringAsFixed(1);
    final oldPrice = product.oldPrice;
    final hasDiscount = oldPrice != null && oldPrice > product.price;
    final discount = oldPrice == null || oldPrice <= product.price
        ? 0
        : ((oldPrice - product.price) * 100 / oldPrice).round();

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: .7)),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImage(product: product, compact: true),
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          child: Text(
                            '-$discount%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: compact
                  ? const EdgeInsets.fromLTRB(8, 6, 8, 7)
                  : const EdgeInsets.fromLTRB(10, 8, 10, 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.22,
                      fontSize: compact ? 12.5 : null,
                    ),
                  ),
                  SizedBox(height: compact ? 3 : 5),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatVnd(product.price),
                      maxLines: 1,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: compact ? 14 : null,
                      ),
                    ),
                  ),
                  if (hasDiscount)
                    Text(
                      formatVnd(oldPrice),
                      style: theme.textTheme.labelSmall?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  SizedBox(height: compact ? 3 : 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: compact ? 12 : 14,
                        color: colors.tertiary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        ratingLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: compact ? 10 : null,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          '·  Đã bán ${product.soldCount}',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: compact ? 10 : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (compact && product.shipFrom != null) ...[
                    const SizedBox(height: 5),
                    _ProductMetaLine(
                      icon: Icons.location_on_outlined,
                      label: product.shipFrom!,
                      tooltip: 'Gửi từ ${product.shipFrom}',
                    ),
                  ],
                  if (compact && product.deliveryEstimate != null) ...[
                    const SizedBox(height: 2),
                    _ProductMetaLine(
                      icon: Icons.local_shipping_outlined,
                      label: product.deliveryEstimate!,
                      tooltip: 'Giao dự kiến ${product.deliveryEstimate}',
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductMetaLine extends StatelessWidget {
  const _ProductMetaLine({
    required this.icon,
    required this.label,
    required this.tooltip,
  });

  final IconData icon;
  final String label;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Row(
        children: [
          Icon(icon, size: 12, color: colors.onSurfaceVariant),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10.5,
                height: 1.15,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
