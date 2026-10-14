import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/design_tokens.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../catalog/presentation/product_detail_screen.dart';
import '../../chat/presentation/chat_inbox_screen.dart';
import '../../live_video/presentation/live_video_screen.dart';
import '../../orders/presentation/orders_screen.dart';
import '../domain/demo_notification.dart';
import 'providers/notification_read_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key, this.onExplore});

  final VoidCallback? onExplore;

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  NotificationKind? _filter;

  void _openPage(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  void _open(DemoNotification item) {
    ref.read(notificationReadProvider.notifier).markRead(item.id);
    final Widget? page = switch (item.target) {
      NotificationTarget.orders => const OrdersScreen(),
      NotificationTarget.live => const LiveVideoScreen(),
      NotificationTarget.product => ProductDetailScreen(
        productId: item.productId!,
      ),
      NotificationTarget.none => null,
    };
    if (page != null) {
      _openPage(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final headerColor = theme.brightness == Brightness.dark
        ? AppColors.profileHeaderDark
        : AppColors.profileHeaderLight;
    final readIds = ref.watch(notificationReadProvider);
    final unread = demoNotifications
        .where((item) => !readIds.contains(item.id))
        .length;
    final visible = demoNotifications.where(
      (item) => _filter == null || item.kind == _filter,
    );
    final recent = visible.where((item) => item.recent);
    final earlier = visible.where((item) => !item.recent);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: headerColor,
        foregroundColor: Colors.white,
        title: Text(
          'Thông báo',
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            tooltip: 'Mở giỏ hàng',
            onPressed: () => _openPage(const CartScreen()),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
          IconButton(
            tooltip: 'Mở lịch sử chat',
            onPressed: () => _openPage(const ChatInboxScreen()),
            icon: const Icon(Icons.forum_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
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
                        'Thông báo mẫu để xem trước giao diện. Không có tin nào được gửi thật.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Cập nhật dành cho bạn',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (unread > 0)
                Row(
                  children: [
                    Text(
                      '$unread chưa đọc',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: colors.onSurface,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () => ref
                          .read(notificationReadProvider.notifier)
                          .markAllRead(
                            demoNotifications.map((item) => item.id),
                          ),
                      child: const Text('Đọc tất cả'),
                    ),
                  ],
                )
              else
                const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('Tất cả', null),
                    _filterChip('Đơn hàng', NotificationKind.order),
                    _filterChip('Ưu đãi', NotificationKind.offer),
                    _filterChip('Live', NotificationKind.live),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (recent.isNotEmpty) ...[
                _sectionTitle('Mới'),
                for (final item in recent)
                  _NotificationTile(
                    item: item,
                    unread: !readIds.contains(item.id),
                    onTap: () => _open(item),
                  ),
              ],
              if (earlier.isNotEmpty) ...[
                _sectionTitle('Trước đó'),
                for (final item in earlier)
                  _NotificationTile(
                    item: item,
                    unread: !readIds.contains(item.id),
                    onTap: () => _open(item),
                  ),
              ],
              if (widget.onExplore != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton.icon(
                    onPressed: widget.onExplore,
                    icon: const Icon(Icons.explore_outlined),
                    label: const Text('Khám phá sản phẩm'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, NotificationKind? kind) {
    final colors = Theme.of(context).colorScheme;
    final selected = _filter == kind;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        backgroundColor: colors.surface,
        selectedColor: colors.onSurface,
        side: BorderSide(
          color: selected
              ? colors.onSurface
              : colors.onSurface.withValues(alpha: .3),
        ),
        labelStyle: TextStyle(
          color: selected ? colors.surface : colors.onSurface,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
        onSelected: (_) => setState(() => _filter = kind),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 12, 2, 10),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleSmall
          ?.copyWith(fontWeight: FontWeight.w700),
    ),
  );
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.unread,
    required this.onTap,
  });

  final DemoNotification item;
  final bool unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final icon = switch (item.kind) {
      NotificationKind.order => Icons.local_shipping_outlined,
      NotificationKind.offer => Icons.sell_outlined,
      NotificationKind.live => Icons.live_tv_outlined,
      NotificationKind.account => Icons.waving_hand_outlined,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.onSurface.withValues(alpha: .14)),
        ),
        child: InkWell(
          key: ValueKey('notification-${item.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 3,
                  height: 44,
                  decoration: BoxDecoration(
                    color: unread ? colors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 9),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: colors.onPrimaryContainer, size: 23),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: unread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (unread) ...[
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 4,
                              backgroundColor: colors.primary,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface.withValues(alpha: .86),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        item.time,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.target != NotificationTarget.none) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
