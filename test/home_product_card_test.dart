import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopingdemo/app/theme/app_theme.dart';
import 'package:shopingdemo/features/catalog/data/datasources/mock_catalog_data_source.dart';
import 'package:shopingdemo/features/catalog/presentation/widgets/product_card.dart';

void main() {
  testWidgets('compact home card shows shipping details and two-line title', (
    tester,
  ) async {
    final product = MockCatalogDataSource.products.first.toEntity();
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final size in [const Size(160, 266), const Size(139, 232)]) {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: ProductCard(
                    product: product,
                    compact: true,
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(ProductCard)), size);
      final delivery = find.text('2–4 ngày');
      final location = find.text('TP.HCM');
      final shipping = find.byTooltip('Giao dự kiến 2–4 ngày · Gửi từ TP.HCM');
      final locationIcon = find.descendant(
        of: shipping,
        matching: find.byIcon(Icons.location_on_outlined),
      );
      expect(delivery, findsOneWidget);
      expect(location, findsOneWidget);
      expect(shipping, findsOneWidget);
      expect(locationIcon, findsOneWidget);
      expect(
        tester.getRect(delivery).right,
        lessThan(tester.getRect(locationIcon).left),
      );
      expect(
        tester.getRect(locationIcon).right,
        lessThan(tester.getRect(location).left),
      );
      expect(tester.getCenter(delivery).dy, tester.getCenter(location).dy);
      expect(
        tester.renderObject<RenderParagraph>(location).didExceedMaxLines,
        isFalse,
        reason: 'shipping details at $size',
      );
      expect(tester.widget<Text>(find.text(product.name)).maxLines, 2);
      expect(tester.takeException(), isNull, reason: 'compact card at $size');
    }
  });

  testWidgets('catalog card keeps origin and delivery on one line', (
    tester,
  ) async {
    final product = MockCatalogDataSource.products.first.toEntity();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 139,
                height: 244,
                child: ProductCard(product: product, onTap: () {}),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    final delivery = find.text('2–4 ngày');
    final location = find.text('TP.HCM');
    expect(delivery, findsOneWidget);
    expect(location, findsOneWidget);
    expect(
      tester.renderObject<RenderParagraph>(location).didExceedMaxLines,
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });
}
