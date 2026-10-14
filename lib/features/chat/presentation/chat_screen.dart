import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalog/domain/product.dart';
import '../../catalog/presentation/widgets/product_image.dart';
import '../domain/chat_conversation.dart';
import 'providers/chat_provider.dart';

const _chatBlue = Color(0xFF006FE6);

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    required this.shopId,
    required this.shopName,
    this.product,
    super.key,
  });

  final String shopId;
  final String shopName;
  final Product? product;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(chatProvider.notifier)
          .openShop(
            shopId: widget.shopId,
            shopName: widget.shopName,
            product: widget.product,
          );
      _scrollToEnd();
    });
  }

  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(chatProvider.notifier).sendMessage(widget.shopId, text);
    _controller.clear();
    setState(() => _canSend = false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversation = ref
        .watch(chatProvider)
        .firstWhere(
          (chat) => chat.shopId == widget.shopId,
          orElse: () => ChatConversation(
            shopId: widget.shopId,
            shopName: widget.shopName,
            product: widget.product,
          ),
        );
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: colors.surfaceContainerHighest,
              child: Icon(
                Icons.storefront_outlined,
                size: 20,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.shopName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Chat mẫu',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: colors.outlineVariant),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
            children: [
              Text(
                'Tin nhắn chỉ lưu trong phiên này, chưa gửi đến shop.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (conversation.product != null) ...[
                const SizedBox(height: 20),
                _ProductContext(product: conversation.product!),
              ],
              if (conversation.messages.isEmpty) ...[
                const SizedBox(height: 52),
                Center(
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: colors.surfaceContainerHighest,
                    child: Icon(
                      Icons.storefront_outlined,
                      size: 28,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Bắt đầu trò chuyện với ${conversation.shopName}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Bạn có thể hỏi về sản phẩm, phân loại hoặc đơn hàng.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ] else ...[
                const SizedBox(height: 24),
                for (var i = 0; i < conversation.messages.length; i++) ...[
                  _MessageBubble(
                    message: conversation.messages[i],
                    showStatus: i == conversation.messages.length - 1,
                  ),
                  const SizedBox(height: 4),
                ],
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(top: BorderSide(color: colors.outlineVariant)),
          ),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const ValueKey('chat-message-input'),
                        controller: _controller,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.send,
                        maxLines: 4,
                        minLines: 1,
                        maxLength: 1000,
                        buildCounter: (
                          _, {
                          required currentLength,
                          required isFocused,
                          maxLength,
                        }) => null,
                        decoration: InputDecoration(
                          hintText: 'Nhập tin nhắn...',
                          isDense: true,
                          filled: true,
                          fillColor: colors.surfaceContainerLow,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 11,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) =>
                            setState(() => _canSend = value.trim().isNotEmpty),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Gửi tin nhắn',
                      onPressed: _canSend ? _send : null,
                      color: _chatBlue,
                      disabledColor: colors.onSurfaceVariant.withValues(
                        alpha: .4,
                      ),
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductContext extends StatelessWidget {
  const _ProductContext({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 44,
              height: 44,
              child: ProductImage(product: product, compact: true),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sản phẩm đang hỏi',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.showStatus});

  final ChatMessage message;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hour = message.sentAt.hour.toString().padLeft(2, '0');
    final minute = message.sentAt.minute.toString().padLeft(2, '0');
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: _chatBlue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(color: Colors.white, height: 1.3),
                ),
              ),
            ),
          ),
          if (showStatus) ...[
            const SizedBox(height: 4),
            Text(
              '$hour:$minute · Chưa gửi',
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
