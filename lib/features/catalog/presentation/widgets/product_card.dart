import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/money_formatter.dart';
import '../../../reviews/presentation/providers/review_providers.dart';
import '../../../wishlist/presentation/providers/wishlist_provider.dart';
import '../../domain/product.dart';
import 'product_image.dart';

class ProductCard extends ConsumerWidget {
  const ProductCard({
    required this.product,
    required this.onTap,
    this.compact = false,
    this.displayPrice,
    super.key,
  });

  final Product product;
  final VoidCallback onTap;
  final bool compact;
  final int? displayPrice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final favorite = ref.watch(wishlistProvider).contains(product.id);
    final summary = ref.watch(productReviewSummaryProvider(product.id));
    final ratingLabel = summary == null
        ? product.rating.toStringAsFixed(1)
        : summary.count == 0
        ? 'Mới'
        : summary.average.toStringAsFixed(1);
    final oldPrice = product.oldPrice;
    final price = displayPrice ?? product.price;
    final hasDiscount =
        oldPrice != null && oldPrice > price && price == product.price;
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
        borderRadius: BorderRadius.circular(4),
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
                  Positioned(
                    top: 4,
                    left: 4,
                    child: IconButton.filledTonal(
                      tooltip: favorite ? 'Bỏ yêu thích' : 'Yêu thích sản phẩm',
                      isSelected: favorite,
                      style: IconButton.styleFrom(
                        backgroundColor: colors.surface.withValues(alpha: .94),
                        foregroundColor: colors.primary,
                        minimumSize: const Size(40, 40),
                        maximumSize: const Size(40, 40),
                        iconSize: 20,
                      ),
                      onPressed: () => ref
                          .read(wishlistProvider.notifier)
                          .toggle(product.id),
                      icon: Icon(
                        favorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                      ),
                    ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE6A1),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(4),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          child: Text(
                            '-$discount%',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: const Color(0xFFA12D18),
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
                  SizedBox(
                    height:
                        MediaQuery.textScalerOf(context)
                            .scale(compact ? 12.5 : 14) *
                        1.22 *
                        2,
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.22,
                        fontSize: compact ? 12.5 : 14,
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 3 : 5),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatVnd(price),
                      maxLines: 1,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: compact ? 16 : 18,
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
