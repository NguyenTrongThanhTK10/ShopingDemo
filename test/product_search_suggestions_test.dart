import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopingdemo/app/theme/app_theme.dart';
import 'package:shopingdemo/features/catalog/presentation/product_list_screen.dart';
import 'package:shopingdemo/features/catalog/presentation/widgets/product_card.dart';

const _suggestionsKey = ValueKey('search-suggestions');

Future<void> _pumpSearch(WidgetTester tester, {bool dark = false}) async {
  await tester.binding.setSurfaceSize(const Size(320, 640));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: dark ? AppTheme.dark : AppTheme.light,
        home: const ProductListScreen(autofocusSearch: true),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'suggestions update while typing and selecting searches the catalog',
    (tester) async {
      await _pumpSearch(tester);
      // Typing before the catalog has loaded must still produce suggestions.
      await tester.enterText(find.byType(TextField), 'ca phe');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      final suggestions = find.byKey(_suggestionsKey);
      final coffee = find.byKey(
        const ValueKey('search-suggestion-Cà phê hạt rang mộc 250g'),
      );
      expect(suggestions, findsOneWidget);
      expect(coffee.hitTestable(), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'serein');
      await tester.pumpAndSettle();
      expect(coffee, findsNothing);
      final shop = find.byKey(const ValueKey('search-suggestion-Serein Wear'));
      expect(shop, findsOneWidget);
      await tester.tap(shop);
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, 'Serein Wear');
      expect(field.focusNode!.hasFocus, isFalse);
      expect(suggestions, findsNothing);
      expect(find.byType(ProductCard), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('clearing, unmatched text and submitting dismiss suggestions', (
    tester,
  ) async {
    await _pumpSearch(tester);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.enterText(find.byType(TextField), 'tai');
    await tester.pumpAndSettle();
    expect(find.byKey(_suggestionsKey), findsOneWidget);
    await tester.tap(find.byTooltip('Xóa tìm kiếm'));
    await tester.pumpAndSettle();
    expect(find.byKey(_suggestionsKey), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );

    await tester.enterText(find.byType(TextField), 'khongtimthay');
    await tester.pumpAndSettle();
    expect(find.byKey(_suggestionsKey), findsNothing);
    expect(find.text('Chưa tìm thấy sản phẩm'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'tai');
    await tester.pumpAndSettle();
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.byKey(_suggestionsKey), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'tai',
    );
    expect(find.byType(ProductCard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('suggestions fit a narrow dark screen with the keyboard open', (
    tester,
  ) async {
    await _pumpSearch(tester, dark: true);
    await tester.pump(const Duration(milliseconds: 500));
    tester.view.viewInsets = FakeViewPadding(
      bottom: 280 * tester.view.devicePixelRatio,
    );
    addTearDown(tester.view.resetViewInsets);
    await tester.enterText(find.byType(TextField), 'm');
    await tester.pumpAndSettle();

    final overlay = tester.getRect(find.byKey(_suggestionsKey));
    final field = tester.getRect(find.byType(TextField));
    expect(overlay.left, closeTo(field.left, 1));
    expect(overlay.width, closeTo(field.width, 1));
    expect(overlay.top, greaterThanOrEqualTo(field.bottom));
    expect(overlay.bottom, lessThanOrEqualTo(360));
    final shop = find.byKey(const ValueKey('search-suggestion-Melo Studio'));
    await tester.tap(shop);
    await tester.pumpAndSettle();
    expect(find.byKey(_suggestionsKey), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Melo Studio',
    );
    expect(tester.takeException(), isNull);
  });
}
