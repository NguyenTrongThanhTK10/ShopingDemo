import 'package:flutter/material.dart';

import '../../../app/theme/design_tokens.dart';
import '../../orders/presentation/orders_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.onExplore});

  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Tôi')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: 42,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Chào bạn đến với Lumi Market',
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Đăng nhập và đồng bộ tài khoản đang được phát triển. '
                      'Bạn có thể xem đơn hàng mẫu bên dưới.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        'Chế độ trải nghiệm',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Material(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    side: BorderSide(color: theme.dividerColor),
                  ),
                  leading: Icon(
                    Icons.receipt_long_outlined,
                    color: colorScheme.secondary,
                  ),
                  title: const Text('Đơn mua'),
                  subtitle: const Text('Xem đơn hàng trong bản demo'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const OrdersScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (onExplore != null)
                FilledButton.icon(
                  onPressed: onExplore,
                  icon: const Icon(Icons.storefront_outlined),
                  label: const Text('Tiếp tục mua sắm'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
