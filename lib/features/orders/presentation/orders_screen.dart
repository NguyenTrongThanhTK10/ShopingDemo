import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopingdemo/core/utils/money_formatter.dart';
import 'package:shopingdemo/features/cart/domain/cart_line.dart';
import 'package:shopingdemo/features/catalog/presentation/widgets/product_image.dart';
import 'package:shopingdemo/features/orders/domain/demo_order.dart';
import 'package:shopingdemo/features/orders/presentation/providers/orders_provider.dart';
import 'package:shopingdemo/features/payment/domain/payment_types.dart';
import 'package:shopingdemo/features/payment/presentation/vietqr_payment_screen.dart';
import 'package:shopingdemo/features/payment/presentation/vnpay_payment_screen.dart';
import 'package:shopingdemo/features/reviews/presentation/providers/review_providers.dart';
import 'package:shopingdemo/features/reviews/presentation/widgets/review_form_sheet.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key, this.initialStage});

  final OrderStage? initialStage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    return DefaultTabController(
      length: OrderStage.values.length + 1,
      initialIndex: initialStage == null
          ? 0
          : OrderStage.values.indexOf(initialStage!) + 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đơn mua'),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              const Tab(text: 'Tất cả'),
              for (final stage in OrderStage.values) Tab(text: stage.label),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OrdersTab(orders: orders),
            for (final stage in OrderStage.values)
              _OrdersTab(
                orders: orders.where((order) => order.stage == stage).toList(),
                stage: stage,
              ),
          ],
        ),
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab({required this.orders, this.stage});

  final List<DemoOrder> orders;
  final OrderStage? stage;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return _EmptyOrders(stage: stage);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: orders.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) return const _DemoNotice();
        return _OrderCard(order: orders[index - 1]);
      },
    );
  }
}

class _DemoNotice extends StatelessWidget {
  const _DemoNotice();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: colors.onPrimaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Đơn mẫu chỉ lưu trong phiên sử dụng ứng dụng này.',
              style: TextStyle(color: colors.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  const _OrderCard({required this.order});

  final DemoOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final itemCount = order.items.fold<int>(
      0,
      (sum, line) => sum + line.quantity,
    );
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          order.id,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('${_formatDate(order.createdAt)} · $itemCount sản phẩm'),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusPill(status: order.stage.label),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          const Divider(height: 16),
          for (var i = 0; i < order.items.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _OrderLine(
              line: order.items[i],
              completedOrderId: order.stage == OrderStage.completed
                  ? order.id
                  : null,
            ),
          ],
          const Divider(height: 24),
          Row(
            children: [
              const Expanded(child: Text('Tổng thanh toán')),
              Text(
                formatVnd(order.total),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Giao đến ${order.recipient} · ${order.phone}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 3),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              order.address,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(order.paymentMethod.icon, size: 18, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.paymentMethod.title,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        order.paymentStatus.label,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: order.paymentStatus.color,
                        ),
                      ),
                    ],
                  ),
                ),
                if (order.stage == OrderStage.awaitingPayment &&
                    order.paymentStatus == PaymentStatus.pending &&
                    order.paymentMethod != PaymentMethod.cod)
                  FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onPressed: () {
                      if (order.paymentMethod == PaymentMethod.vietQr) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => VietQrPaymentScreen(order: order),
                          ),
                        );
                      } else if (order.paymentMethod == PaymentMethod.vnpay) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => VnpayPaymentScreen(order: order),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Thanh toán ngay',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          if (order.stage != OrderStage.completed &&
              order.stage != OrderStage.canceled &&
              (order.paymentMethod == PaymentMethod.cod ||
                  order.paymentStatus == PaymentStatus.paid)) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => ref
                    .read(ordersProvider.notifier)
                    .completeDemoOrder(order.id),
                icon: const Icon(Icons.inventory_2_outlined, size: 18),
                label: const Text('Mô phỏng nhận hàng'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colors.onTertiaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _OrderLine extends ConsumerWidget {
  const _OrderLine({required this.line, this.completedOrderId});

  final CartLine line;
  final String? completedOrderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderId = completedOrderId;
    final reviews = orderId == null
        ? null
        : ref.watch(productReviewsProvider(line.product.id)).value;
    final alreadyReviewed =
        reviews?.any(
          (review) =>
              review.orderId == orderId && review.variantId == line.variant.id,
        ) ??
        false;
    return Column(
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 48,
                height: 48,
                child: ProductImage(
                  product: line.product,
                  imageIndex: line.variant.imageIndex ?? 0,
                  compact: true,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${line.variant.label} · x${line.quantity}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(formatVnd(line.subtotal)),
          ],
        ),
        if (orderId != null)
          Align(
            alignment: Alignment.centerRight,
            child: alreadyReviewed
                ? Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'Đã đánh giá',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  )
                : TextButton.icon(
                    onPressed: reviews == null
                        ? null
                        : () async {
                            final sent = await showReviewFormSheet(
                              context,
                              targets: [
                                ProductReviewTarget(
                                  orderId: orderId,
                                  product: line.product,
                                  variant: line.variant,
                                ),
                              ],
                            );
                            if (context.mounted && sent == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã gửi đánh giá của bạn'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                    icon: const Icon(Icons.rate_review_outlined, size: 16),
                    label: const Text('Đánh giá'),
                  ),
          ),
      ],
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders({this.stage});

  final OrderStage? stage;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 72, color: colors.primary),
            const SizedBox(height: 16),
            Text(
              stage == null
                  ? 'Chưa có đơn hàng'
                  : 'Chưa có đơn ${stage!.label.toLowerCase()}',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              stage == null
                  ? 'Các đơn hàng mẫu đã đặt sẽ xuất hiện tại đây trong phiên sử dụng.'
                  : 'Đơn hàng ở trạng thái này sẽ xuất hiện tại đây.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year} '
      '${two(local.hour)}:${two(local.minute)}';
}
