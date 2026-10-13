import 'package:flutter/material.dart';

import '../../../../app/theme/design_tokens.dart';

/// A locally rendered illustration for the demo catalog.
///
/// Keeping artwork in Flutter makes the catalog usable without a network
/// connection or rights to third-party product photography.
class ProductArtwork extends StatelessWidget {
  const ProductArtwork({
    required this.emoji,
    super.key,
    this.compact = false,
    this.label,
  });

  final String emoji;
  final bool compact;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const tints = <String, Color>{
      '🎧': AppColors.productTech,
      '⌨️': AppColors.productTech,
      '📷': AppColors.productTech,
      '👕': AppColors.productFashion,
      '👟': AppColors.productFashion,
      '🎒': AppColors.productFashion,
      '🧴': AppColors.productBeauty,
      '💄': AppColors.productBeauty,
      '💡': AppColors.productHome,
      '🪴': AppColors.productHome,
      '🥤': AppColors.productLifestyle,
      '☕': AppColors.productFood,
    };
    final tint = tints[emoji] ?? AppColors.canvas;
    final artwork = switch (emoji) {
      '🎧' => Icons.headphones_outlined,
      '⌨️' => Icons.keyboard_outlined,
      '📷' => Icons.photo_camera_outlined,
      '👕' => Icons.checkroom_outlined,
      '👟' => Icons.directions_run_outlined,
      '🎒' => Icons.backpack_outlined,
      '🧴' => Icons.water_drop_outlined,
      '💄' => Icons.brush_outlined,
      '💡' => Icons.lightbulb_outline,
      '🪴' => Icons.spa_outlined,
      '🥤' => Icons.local_drink_outlined,
      '☕' => Icons.local_cafe_outlined,
      _ => Icons.inventory_2_outlined,
    };
    final accent = switch (emoji) {
      '🎧' || '⌨️' || '📷' => AppColors.productTechInk,
      '👕' || '👟' || '🎒' => AppColors.productFashionInk,
      '🧴' || '💄' => AppColors.productBeautyInk,
      '💡' || '🪴' => AppColors.productHomeInk,
      '🥤' => AppColors.productLifestyleInk,
      '☕' => AppColors.productFoodInk,
      _ => colors.secondary,
    };
    final background = Color.lerp(
      tint,
      colors.surface,
      Theme.of(context).brightness == Brightness.dark ? .78 : .12,
    )!;

    return Semantics(
      label: label == null ? 'Hình minh họa sản phẩm' : 'Hình minh họa $label',
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(compact ? 0 : 18),
        child: DecoratedBox(
          decoration: BoxDecoration(color: background),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.biggest.shortestSide;
              return Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    width: size * .7,
                    height: size * .7,
                    top: -size * .36,
                    right: -size * .27,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: .35),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    width: size * .52,
                    height: size * .52,
                    bottom: -size * .31,
                    left: -size * .14,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: .04),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Center(
                    child: ExcludeSemantics(
                      child: Icon(
                        artwork,
                        size: size * (compact ? .36 : .32),
                        color: accent,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
