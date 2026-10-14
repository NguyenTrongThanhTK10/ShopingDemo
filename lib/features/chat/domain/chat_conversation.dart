import '../../catalog/domain/product.dart';

class ChatMessage {
  const ChatMessage({required this.text, required this.sentAt});

  final String text;
  final DateTime sentAt;
}

class ChatConversation {
  const ChatConversation({
    required this.shopId,
    required this.shopName,
    this.product,
    this.messages = const [],
  });

  final String shopId;
  final String shopName;
  final Product? product;
  final List<ChatMessage> messages;

  ChatConversation copyWith({Product? product, List<ChatMessage>? messages}) =>
      ChatConversation(
        shopId: shopId,
        shopName: shopName,
        product: product ?? this.product,
        messages: messages ?? this.messages,
      );
}
