import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  const CategoryIcon({required this.categoryId, this.size = 26, super.key});

  final String categoryId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final icon = switch (categoryId) {
      'tech' => Icons.headphones_outlined,
      'fashion' => Icons.checkroom_outlined,
      'beauty' => Icons.spa_outlined,
      'home' => Icons.chair_outlined,
      'lifestyle' => Icons.local_drink_outlined,
      'food' => Icons.local_cafe_outlined,
      _ => Icons.grid_view_outlined,
    };
    return Icon(
      icon,
      size: size,
      color: Theme.of(context).colorScheme.secondary,
    );
  }
}
