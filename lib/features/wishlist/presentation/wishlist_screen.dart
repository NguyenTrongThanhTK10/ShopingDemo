import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalog/presentation/product_detail_screen.dart';
import '../../catalog/presentation/product_list_screen.dart';
import '../../catalog/presentation/providers/catalog_providers.dart';
import '../../catalog/presentation/widgets/product_card.dart';
import 'providers/wishlist_provider.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(wishlistProvider);
    final products = ref.watch(productsProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Yêu thích (${favorites.length})')),
      body: products.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: FilledButton.tonalIcon(
            onPressed: () => ref.invalidate(productsProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Tải lại sản phẩm'),
          ),
        ),
        data: (items) {
          final saved = items.where((p) => favorites.contains(p.id)).toList();
          if (saved.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Lưu lại những món bạn thích',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Chạm trái tim trên sản phẩm để dễ dàng tìm lại.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ProductListScreen(),
                        ),
                      ),
                      child: const Text('Khám phá sản phẩm'),
                    ),
                  ],
                ),
              ),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final columns = (constraints.maxWidth / 190).floor().clamp(2, 6);
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisExtent: 290,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: saved.length,
                itemBuilder: (context, index) => ProductCard(
                  product: saved[index],
                  compact: true,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          ProductDetailScreen(productId: saved[index].id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
