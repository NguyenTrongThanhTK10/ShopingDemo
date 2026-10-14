import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/design_tokens.dart';
import '../../chat/presentation/chat_inbox_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../orders/domain/demo_order.dart';
import '../../orders/presentation/orders_screen.dart';
import '../../orders/presentation/providers/orders_provider.dart';
import '../../payment/presentation/payment_settings_screen.dart';
import '../../payment/presentation/providers/payment_preferences_provider.dart';
import 'account_details_screen.dart';
import 'delivery_details_screen.dart';
import 'providers/delivery_details_provider.dart';
import 'providers/demo_account_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.onExplore, this.onOpenOrders});

  final VoidCallback? onExplore;
  final VoidCallback? onOpenOrders;

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final headerColor = theme.brightness == Brightness.dark
        ? AppColors.profileHeaderDark
        : AppColors.profileHeaderLight;
    final orders = ref.watch(ordersProvider);
    final preferredPayment = ref.watch(preferredPaymentMethodProvider);
    final deliveryDetails = ref.watch(deliveryDetailsProvider);
    final account = ref.watch(demoAccountProvider);
    final openOrders =
        onOpenOrders ?? () => _openPage(context, const OrdersScreen());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: headerColor,
        foregroundColor: Colors.white,
        title: InkWell(
          key: const ValueKey('profile-account-button'),
          onTap: () => _openPage(context, const AccountDetailsScreen()),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_rounded,
                    color: headerColor,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account?.name ?? 'Chưa đăng nhập',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        account?.phone ?? 'Tài khoản khách',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: .9),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Mở thông báo',
            onPressed: () => _openPage(context, const NotificationsScreen()),
            icon: const Icon(Icons.notifications_none_rounded),
            color: Colors.white,
          ),
          IconButton(
            tooltip: 'Mở lịch sử chat',
            onPressed: () => _openPage(context, const ChatInboxScreen()),
            icon: const Icon(Icons.forum_rounded),
            color: Colors.white,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _OrdersPanel(
                  orders: orders,
                  onOpenAll: openOrders,
                  onOpenStage: (stage) =>
                      _openPage(context, OrdersScreen(initialStage: stage)),
                ),
                const SizedBox(height: 22),
                Text('Tài khoản của tôi', style: theme.textTheme.titleLarge),
                const SizedBox(height: 10),
                _AccountGroup(
                  tiles: [
                    _AccountActionTile(
                      icon: Icons.location_on_outlined,
                      title: 'Địa chỉ nhận hàng',
                      subtitle: deliveryDetails == null
                          ? 'Thêm thông tin giao hàng mặc định'
                          : '${deliveryDetails.recipient} · ${deliveryDetails.address}',
                      onTap: () =>
                          _openPage(context, const DeliveryDetailsScreen()),
                    ),
                    _AccountActionTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Cài đặt thanh toán',
                      subtitle: 'Ưu tiên: ${preferredPayment.title}',
                      onTap: () =>
                          _openPage(context, const PaymentSettingsScreen()),
                    ),
                    _AccountActionTile(
                      icon: Icons.rate_review_outlined,
                      title: 'Đánh giá sản phẩm',
                      subtitle: 'Xem đơn hoàn thành để viết đánh giá',
                      onTap: () => _openPage(
                        context,
                        const OrdersScreen(initialStage: OrderStage.completed),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text('Kết nối và khám phá', style: theme.textTheme.titleLarge),
                const SizedBox(height: 10),
                _AccountGroup(
                  tiles: [
                    _AccountActionTile(
                      icon: Icons.forum_rounded,
                      title: 'Chat với shop',
                      subtitle: 'Lịch sử trò chuyện với các shop',
                      onTap: () => _openPage(context, const ChatInboxScreen()),
                    ),
                    _AccountActionTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Thông báo',
                      subtitle: 'Tin mới về đơn hàng và ưu đãi',
                      onTap: () =>
                          _openPage(context, const NotificationsScreen()),
                    ),
                    if (onExplore != null)
                      _AccountActionTile(
                        icon: Icons.storefront_outlined,
                        title: 'Tiếp tục mua sắm',
                        subtitle: 'Khám phá thêm sản phẩm',
                        onTap: onExplore!,
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Bạn đang dùng bản trải nghiệm. Đơn hàng, địa chỉ và cài đặt thanh toán chỉ lưu trong phiên này.',
                          style: theme.textTheme.bodySmall,
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

class _OrdersPanel extends StatelessWidget {
  const _OrdersPanel({
    required this.orders,
    required this.onOpenAll,
    required this.onOpenStage,
  });

  final List<DemoOrder> orders;
  final VoidCallback onOpenAll;
  final ValueChanged<OrderStage> onOpenStage;

  static const stages = [
    OrderStage.awaitingPayment,
    OrderStage.awaitingConfirmation,
    OrderStage.awaitingPickup,
    OrderStage.shipping,
    OrderStage.completed,
  ];

  static const icons = [
    Icons.payments_outlined,
    Icons.schedule_outlined,
    Icons.inventory_2_outlined,
    Icons.local_shipping_outlined,
    Icons.task_alt_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Đơn mua của tôi',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: onOpenAll,
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colors.outlineVariant),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth < 340 ? 3 : 5;
                return Wrap(
                  alignment: WrapAlignment.center,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < stages.length; i++)
                      SizedBox(
                        width: constraints.maxWidth / columns,
                        child: _OrderShortcut(
                          stage: stages[i],
                          icon: icons[i],
                          count: orders
                              .where((order) => order.stage == stages[i])
                              .length,
                          onTap: () => onOpenStage(stages[i]),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderShortcut extends StatelessWidget {
  const _OrderShortcut({
    required this.stage,
    required this.icon,
    required this.count,
    required this.onTap,
  });

  final OrderStage stage;
  final IconData icon;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      key: ValueKey('profile-order-${stage.name}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Column(
          children: [
            Badge(
              isLabelVisible: count > 0,
              label: Text(count > 99 ? '99+' : '$count'),
              child: Icon(icon, size: 24, color: colors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              stage.label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 13,
                height: 1.25,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountGroup extends StatelessWidget {
  const _AccountGroup({required this.tiles});

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0)
              Divider(height: 1, indent: 64, color: colors.outlineVariant),
            tiles[i],
          ],
        ],
      ),
    );
  }
}

class _AccountActionTile extends StatelessWidget {
  const _AccountActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(12, 3, 8, 3),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 21, color: colors.primary),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colors.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}
