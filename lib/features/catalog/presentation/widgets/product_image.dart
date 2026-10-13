import 'package:flutter/material.dart';

import '../../domain/product.dart';
import 'product_artwork.dart';

/// Shows a bundled catalog photo and keeps the artwork fallback for fixtures
/// that do not provide one.
class ProductImage extends StatelessWidget {
  const ProductImage({
    required this.product,
    super.key,
    this.imageIndex = 0,
    this.fit = BoxFit.cover,
    this.compact = false,
  });

  final Product product;
  final int imageIndex;
  final BoxFit fit;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final paths = product.imagePaths;
    if (imageIndex < 0 || imageIndex >= paths.length) {
      return ProductArtwork(
        emoji: product.emoji,
        label: product.name,
        compact: compact,
      );
    }

    return Image.asset(
      paths[imageIndex],
      width: double.infinity,
      height: double.infinity,
      fit: fit,
      semanticLabel: 'Ảnh ${product.name}',
      errorBuilder: (context, error, stackTrace) => ProductArtwork(
        emoji: product.emoji,
        label: product.name,
        compact: compact,
      ),
    );
  }
}
