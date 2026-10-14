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
      final origin = find.text('TP.HCM');
      final delivery = find.text('2–4 ngày');
      expect(origin, findsOneWidget);
      expect(delivery, findsOneWidget);
      expect(find.byTooltip('Gửi từ TP.HCM'), findsOneWidget);
      expect(find.byTooltip('Giao dự kiến 2–4 ngày'), findsOneWidget);
      expect(
        tester.renderObject<RenderParagraph>(origin).didExceedMaxLines,
        isFalse,
      );
      expect(
        tester.renderObject<RenderParagraph>(delivery).didExceedMaxLines,
        isFalse,
        reason: 'delivery label at $size',
      );
      expect(tester.widget<Text>(find.text(product.name)).maxLines, 2);
      expect(tester.takeException(), isNull, reason: 'compact card at $size');
    }
  });
}
