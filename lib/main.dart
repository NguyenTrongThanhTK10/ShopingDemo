import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_shell.dart';
import 'app/theme/app_theme.dart';
import 'features/cart/presentation/cart_screen.dart';
import 'features/catalog/presentation/categories_screen.dart';

void main() {
  runApp(const ProviderScope(child: LumiMarketApp()));
}

class LumiMarketApp extends StatelessWidget {
  const LumiMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumi Market',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const AppShell(categories: CategoriesScreen(), cart: CartScreen()),
    );
  }
}
