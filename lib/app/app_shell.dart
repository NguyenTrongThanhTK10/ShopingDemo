import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'theme/design_tokens.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/live_video/presentation/live_video_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/notifications/domain/demo_notification.dart';
import '../features/notifications/presentation/providers/notification_read_provider.dart';
import '../features/orders/presentation/orders_screen.dart';
import '../features/profile/presentation/profile_screen.dart';

/// Persistent buyer navigation with a separate cart route.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.categories, required this.cart});

  final Widget categories;
  final Widget cart;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _selectedIndex = 0;

  void _selectTab(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  void _openCart() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => widget.cart));
  }

  void _openOrders() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const OrdersScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final headerColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.profileHeaderDark
        : AppColors.profileHeaderLight;
    final readIds = ref.watch(notificationReadProvider);
    final unreadCount = demoNotifications
        .where((item) => !readIds.contains(item.id))
        .length;
    final pages = <Widget>[
      HomeScreen(onOpenCart: _openCart),
      widget.categories,
      const LiveVideoScreen(),
      NotificationsScreen(onExplore: () => _selectTab(0)),
      ProfileScreen(onExplore: () => _selectTab(0), onOpenOrders: _openOrders),
    ];

    return Scaffold(
      backgroundColor: headerColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: IndexedStack(index: _selectedIndex, children: pages),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _selectTab,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Trang chủ',
            ),
            const NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'Danh mục',
            ),
            const NavigationDestination(
              icon: Icon(Icons.live_tv_outlined),
              selectedIcon: Icon(Icons.live_tv_rounded),
              label: 'Live & Video',
            ),
            NavigationDestination(
              icon: _notificationIcon(
                Icons.notifications_none_rounded,
                unreadCount,
              ),
              selectedIcon: _notificationIcon(
                Icons.notifications_rounded,
                unreadCount,
                selected: true,
              ),
              label: 'Thông báo',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Tôi',
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationIcon(
    IconData icon,
    int unreadCount, {
    bool selected = false,
  }) {
    final child = Icon(icon);
    if (unreadCount == 0) return child;
    final colors = Theme.of(context).colorScheme;
    return Badge.count(
      key: ValueKey(
        selected ? 'notification-tab-badge-selected' : 'notification-tab-badge',
      ),
      count: unreadCount,
      backgroundColor: colors.error,
      textColor: colors.onError,
      child: child,
    );
  }
}
