import 'package:flutter/material.dart';

import '../../../app/theme/design_tokens.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, this.onExplore});

  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Thông báo')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_active_outlined,
                    color: colorScheme.secondary,
                    size: 46,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Chưa có thông báo nào',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Tin về đơn hàng và ưu đãi sẽ xuất hiện ở đây. '
                  'Đây là dữ liệu mẫu của bản demo.',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: Theme.of(context).hintColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (onExplore != null)
                  FilledButton.icon(
                    onPressed: onExplore,
                    icon: const Icon(Icons.explore_outlined),
                    label: const Text('Khám phá sản phẩm'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
