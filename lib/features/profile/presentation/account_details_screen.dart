import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/demo_account_provider.dart';
import 'register_account_screen.dart';

class AccountDetailsScreen extends ConsumerWidget {
  const AccountDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(demoAccountProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết tài khoản')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: colors.primaryContainer,
                    child: Icon(
                      Icons.person_rounded,
                      size: 32,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    account?.name ?? 'Chưa có tài khoản',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    account == null
                        ? 'Đăng ký để xem thử trang tài khoản cá nhân.'
                        : 'Tài khoản trải nghiệm của bạn',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (account == null) ...[
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const RegisterAccountScreen(),
                ),
              ),
              child: const Text('Đăng ký tài khoản mẫu'),
            ),
          ] else ...[
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.badge_outlined),
                    title: const Text('Tên tài khoản'),
                    subtitle: Text(account.name),
                  ),
                  Divider(height: 1, color: colors.outlineVariant),
                  ListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: const Text('Số điện thoại'),
                    subtitle: Text(account.phone),
                  ),
                  if (account.email.isNotEmpty) ...[
                    Divider(height: 1, color: colors.outlineVariant),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email'),
                      subtitle: Text(account.email),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const RegisterAccountScreen(),
                ),
              ),
              child: const Text('Chỉnh sửa thông tin'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.read(demoAccountProvider.notifier).signOut(),
              child: const Text('Trở về tài khoản khách'),
            ),
          ],
          const SizedBox(height: 18),
          Text(
            'Dữ liệu tài khoản chỉ lưu trong phiên trải nghiệm. Chưa có đăng ký hoặc đăng nhập với máy chủ.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
