import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopingdemo/app/theme/app_theme.dart';
import 'package:shopingdemo/features/cart/presentation/cart_screen.dart';
import 'package:shopingdemo/features/cart/presentation/providers/cart_provider.dart';
import 'package:shopingdemo/features/chat/presentation/chat_inbox_screen.dart';
import 'package:shopingdemo/features/chat/presentation/chat_screen.dart';
import 'package:shopingdemo/features/chat/presentation/providers/chat_provider.dart';
import 'package:shopingdemo/features/catalog/domain/product.dart';
import 'package:shopingdemo/features/catalog/presentation/product_detail_screen.dart';
import 'package:shopingdemo/main.dart';

void main() {
  test('messages are trimmed and kept in separate shop conversations', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final chats = container.read(chatProvider.notifier);

    chats.openShop(shopId: 'a', shopName: 'Shop A');
    chats.openShop(shopId: 'b', shopName: 'Shop B');
    chats.sendMessage('a', '  Xin chào  ');
    chats.sendMessage('a', '   ');
    chats.sendMessage('b', 'Hỏi shop B');
    chats.openShop(shopId: 'a', shopName: 'Shop A');

    final conversations = container.read(chatProvider);
    expect(conversations, hasLength(2));
    expect(conversations.first.shopId, 'b');
    expect(conversations.last.messages.single.text, 'Xin chào');
    expect(conversations.first.messages.single.text, 'Hỏi shop B');
  });

  testWidgets('buyer chats from product and reopens the conversation', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ProductDetailScreen(productId: 'earbuds'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    final chatButton = find.byKey(const ValueKey('chat-with-shop'));
    await tester.ensureVisible(chatButton);
    await tester.pumpAndSettle();
    await tester.tap(chatButton);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.text('Sản phẩm đang hỏi'), findsOneWidget);
    expect(find.textContaining('chưa gửi đến shop'), findsOneWidget);

    final input = find.byKey(const ValueKey('chat-message-input'));
    await tester.enterText(input, '  Shop còn màu đen không?  ');
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'chat with keyboard open');
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Gửi tin nhắn'));
    await tester.pumpAndSettle();
    expect(find.text('Shop còn màu đen không?'), findsOneWidget);
    expect(tester.widget<TextField>(input).controller!.text, isEmpty);

    await tester.pageBack();
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ProductDetailScreen)),
    );
    expect(
      container.read(chatProvider).single.messages.single.text,
      'Shop còn màu đen không?',
    );

    await tester.tap(chatButton);
    await tester.pumpAndSettle();
    expect(find.text('Shop còn màu đen không?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chat inbox shows the empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ChatInboxScreen(),
        ),
      ),
    );
    expect(find.text('Lịch sử chat'), findsOneWidget);
    expect(find.text('Chưa có lịch sử chat'), findsOneWidget);
  });

  testWidgets('home chat icon opens recent shop conversations', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final chats = container.read(chatProvider.notifier);
    chats.openShop(shopId: 'a', shopName: 'Shop A');
    chats.sendMessage('a', 'Hỏi về sản phẩm A');
    chats.openShop(shopId: 'b', shopName: 'Shop B');
    chats.sendMessage('b', 'Hỏi về sản phẩm B');
    chats.openShop(shopId: 'c', shopName: 'Shop C');

    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const LumiMarketApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Mở lịch sử chat'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatInboxScreen), findsOneWidget);
    expect(find.text('Lịch sử chat'), findsOneWidget);
    expect(find.text('Shop A'), findsOneWidget);
    expect(find.text('Shop B'), findsOneWidget);
    expect(find.text('Shop C'), findsNothing);
    expect(find.text('Hỏi về sản phẩm B'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Shop B')).dy,
      lessThan(tester.getTopLeft(find.text('Shop A')).dy),
    );

    await tester.tap(find.text('Shop B'));
    await tester.pumpAndSettle();
    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.text('Hỏi về sản phẩm B'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cart opens shop chat and inbox restores its messages', (
    tester,
  ) async {
    const variant = ProductVariant(
      id: 'variant',
      label: 'Màu đen',
      price: 100000,
      stock: 3,
    );
    const product = Product(
      id: 'product',
      name: 'Tai nghe mẫu',
      description: 'Mô tả',
      shopId: 'shop',
      shopName: 'Shop mẫu',
      categoryId: 'audio',
      price: 100000,
      rating: 4.5,
      soldCount: 5,
      emoji: '🎧',
      variants: [variant],
    );
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(cartProvider.notifier).add(product, variant);
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const CartScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Chat với Shop mẫu'));
    await tester.pumpAndSettle();
    expect(find.byType(ChatScreen), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('chat-message-input')),
      'Cho mình hỏi phí ship?',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Gửi tin nhắn'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ChatInboxScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Shop mẫu'), findsOneWidget);
    expect(find.text('Cho mình hỏi phí ship?'), findsOneWidget);
    await tester.tap(find.text('Shop mẫu'));
    await tester.pumpAndSettle();
    expect(find.byType(ChatScreen), findsOneWidget);
    expect(find.text('Cho mình hỏi phí ship?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
