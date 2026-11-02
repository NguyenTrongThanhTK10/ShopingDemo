import 'package:flutter_riverpod/flutter_riverpod.dart';

final wishlistProvider = NotifierProvider<WishlistNotifier, Set<String>>(
  WishlistNotifier.new,
);

/// Favorites are shared across screens for the current demo session.
class WishlistNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String productId) {
    state = Set.unmodifiable(
      state.contains(productId)
          ? (Set<String>.of(state)..remove(productId))
          : {...state, productId},
    );
  }
}
