import 'package:flutter_test/flutter_test.dart';
import 'package:shopingdemo/features/catalog/domain/filter_products.dart';
import 'package:shopingdemo/features/catalog/domain/product.dart';

void main() {
  const products = <Product>[
    Product(
      id: 'coffee',
      name: 'Cà phê sữa',
      description: 'Hạt rang thơm',
      shopId: 'cafe-shop',
      shopName: 'Tiệm Cà Phê',
      categoryId: 'drinks',
      price: 39000,
      rating: 4.9,
      soldCount: 15,
      emoji: '☕',
      variants: [],
    ),
    Product(
      id: 'tea',
      name: 'Trà hoa',
      description: 'Hương nhẹ',
      shopId: 'tea-shop',
      shopName: 'Tiệm Trà',
      categoryId: 'drinks',
      price: 29000,
      rating: 4.5,
      soldCount: 100,
      emoji: '🍵',
      variants: [],
    ),
    Product(
      id: 'lamp',
      name: 'Đèn để bàn',
      description: 'Ánh sáng dịu',
      shopId: 'home-shop',
      shopName: 'Nhà Mộc',
      categoryId: 'home',
      price: 199000,
      rating: 5,
      soldCount: 5,
      emoji: '💡',
      variants: [],
    ),
  ];

  test('search ignores Vietnamese marks in names, shops, and descriptions', () {
    expect(filterProducts(products, query: 'ca phe').map((item) => item.id), [
      'coffee',
    ]);
    expect(filterProducts(products, query: 'den').map((item) => item.id), [
      'lamp',
    ]);
    expect(
      filterProducts(products, query: '  nha   moc  ').map((item) => item.id),
      ['lamp'],
    );
    expect(normalizeVietnameseSearchText('Phê\u0301'), 'phe');
  });

  test('category and query filters are combined', () {
    expect(
      filterProducts(
        products,
        query: 'tra',
        categoryId: 'drinks',
      ).map((item) => item.id),
      ['tea'],
    );
    expect(filterProducts(products, query: 'tra', categoryId: 'home'), isEmpty);
  });

  test('sort orders are deterministic and do not mutate source', () {
    expect(filterProducts(products).map((item) => item.id), [
      'tea',
      'coffee',
      'lamp',
    ]);
    expect(
      filterProducts(
        products,
        sortOrder: ProductSort.priceAsc,
      ).map((item) => item.id),
      ['tea', 'coffee', 'lamp'],
    );
    expect(
      filterProducts(
        products,
        sortOrder: ProductSort.priceDesc,
      ).map((item) => item.id),
      ['lamp', 'coffee', 'tea'],
    );
    expect(
      filterProducts(
        products,
        sortOrder: ProductSort.topRated,
      ).map((item) => item.id),
      ['lamp', 'coffee', 'tea'],
    );
    expect(products.map((item) => item.id), ['coffee', 'tea', 'lamp']);
  });
}
