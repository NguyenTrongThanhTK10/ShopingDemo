import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chat_screen.dart';
import 'providers/chat_provider.dart';

class ChatInboxScreen extends ConsumerWidget {
  const ChatInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref
        .watch(chatProvider)
        .where((chat) => chat.messages.isNotEmpty)
        .toList(growable: false);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text('Lịch sử chat')),
      body: conversations.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.forum_rounded,
                      size: 52,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Chưa có lịch sử chat',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mở một sản phẩm và chọn Chat với shop để bắt đầu.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              itemCount: conversations.length + 1,
              separatorBuilder: (_, index) => index == 0
                  ? const SizedBox(height: 10)
                  : Divider(
                      height: 1,
                      indent: 72,
                      color: colors.outlineVariant,
                    ),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                    child: Text(
                      'Các cuộc trò chuyện chỉ lưu trong phiên này và chưa gửi đến shop.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }
                final chat = conversations[index - 1];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 5),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: colors.surfaceContainerHighest,
                    child: Icon(
                      Icons.storefront_outlined,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.shopName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatLastMessageTime(chat.messages.last.sentAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  subtitle: Text(
                    chat.messages.last.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ChatScreen(
                        shopId: chat.shopId,
                        shopName: chat.shopName,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

String _formatLastMessageTime(DateTime time) {
  final now = DateTime.now();
  if (time.year == now.year && time.month == now.month && time.day == now.day) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  return '${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}';
}
