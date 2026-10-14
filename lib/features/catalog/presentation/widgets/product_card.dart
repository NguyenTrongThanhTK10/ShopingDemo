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
    final shippingTooltip = [
      if (product.deliveryEstimate != null)
        'Giao dự kiến ${product.deliveryEstimate}',
      if (product.shipFrom != null) 'Gửi từ ${product.shipFrom}',
    ].join(' · ');

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
                  if (shippingTooltip.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    _ProductMetaLine(
                      deliveryEstimate: product.deliveryEstimate,
                      shipFrom: product.shipFrom,
                      tooltip: shippingTooltip,
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
    required this.deliveryEstimate,
    required this.shipFrom,
    required this.tooltip,
  });

  final String? deliveryEstimate;
  final String? shipFrom;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelSmall
        ?.copyWith(fontSize: 10, height: 1.15, color: colors.onSurfaceVariant);
    return Tooltip(
      message: tooltip,
      child: Row(
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (deliveryEstimate != null)
                    Text(deliveryEstimate!, maxLines: 1, style: labelStyle),
                  if (deliveryEstimate != null && shipFrom != null)
                    Text(' · ', style: labelStyle),
                  if (shipFrom != null) ...[
                    Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 2),
                    Text(shipFrom!, maxLines: 1, style: labelStyle),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
