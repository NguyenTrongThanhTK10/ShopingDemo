import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../catalog/domain/product.dart';
import '../../domain/chat_conversation.dart';

final chatProvider = NotifierProvider<ChatNotifier, List<ChatConversation>>(
  ChatNotifier.new,
);

/// Keeps demo conversations only while the app is running.
class ChatNotifier extends Notifier<List<ChatConversation>> {
  @override
  List<ChatConversation> build() => const [];

  void openShop({
    required String shopId,
    required String shopName,
    Product? product,
  }) {
    if (shopId.trim().isEmpty || shopName.trim().isEmpty) {
      throw ArgumentError('Shop details are required');
    }
    final index = state.indexWhere((chat) => chat.shopId == shopId);
    if (index == -1) {
      state = [
        ChatConversation(shopId: shopId, shopName: shopName, product: product),
        ...state,
      ];
    } else if (product != null) {
      state = [
        for (final chat in state)
          if (chat.shopId == shopId) chat.copyWith(product: product) else chat,
      ];
    }
  }

  void sendMessage(String shopId, String text) {
    final message = text.trim();
    if (message.isEmpty) return;
    final index = state.indexWhere((chat) => chat.shopId == shopId);
    if (index == -1) throw StateError('Conversation not found');
    final current = state[index];
    state = [
      current.copyWith(
        messages: List.unmodifiable([
          ...current.messages,
          ChatMessage(text: message, sentAt: DateTime.now()),
        ]),
      ),
      for (var i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
  }
}
