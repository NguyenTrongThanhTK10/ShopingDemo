import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/design_tokens.dart';
import '../../../core/utils/money_formatter.dart';
import '../../catalog/domain/product.dart';
import '../../catalog/presentation/product_detail_screen.dart';
import '../../catalog/presentation/providers/catalog_providers.dart';
import '../../catalog/presentation/widgets/product_image.dart';
import '../domain/demo_live_session.dart';
import 'demo_live_room_screen.dart';

class LiveVideoScreen extends ConsumerWidget {
  const LiveVideoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final headerColor = theme.brightness == Brightness.dark
        ? AppColors.profileHeaderDark
        : AppColors.profileHeaderLight;
    final products = ref.watch(productsProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: headerColor,
          foregroundColor: Colors.white,
          title: Text(
            'Live & Video',
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Color(0xFFEDEDED),
            indicatorColor: Colors.white,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: 'Live'),
              Tab(text: 'Video'),
            ],
          ),
        ),
        body: products.when(
          data: (items) => TabBarView(
            children: [
              _MediaPage(products: items, type: _MediaType.live),
              _MediaPage(products: items, type: _MediaType.video),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: FilledButton.tonalIcon(
              onPressed: () => ref.invalidate(productsProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tải lại sản phẩm'),
            ),
          ),
        ),
      ),
    );
  }
}

enum _MediaType { live, video }

class _MediaPage extends StatelessWidget {
  const _MediaPage({required this.products, required this.type});

  final List<Product> products;
  final _MediaType type;

  void _openProduct(BuildContext context, Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(productId: product.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLive = type == _MediaType.live;
    final picks = products.take(6).toList();
    final theme = Theme.of(context);
    List<Product> productsFor(DemoLiveSession session) => products
        .where((product) => session.productIds.contains(product.id))
        .toList();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          key: ValueKey(isLive ? 'live-feed' : 'video-feed'),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            if (isLive) ...[
              Text('Phiên live mẫu', style: theme.textTheme.titleLarge),
              const SizedBox(height: 5),
              Text(
                'Xem thử cách shop giới thiệu sản phẩm và mua hàng trong live.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 14),
              for (final session in demoLiveSessions)
                if (productsFor(session).isNotEmpty) ...[
                  _LiveSessionCard(
                    session: session,
                    cover: productsFor(session).first,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => DemoLiveRoomScreen(
                          session: session,
                          products: productsFor(session),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              if (products.isEmpty) const _MediaNotice(isLive: true),
            ] else
              const _MediaNotice(isLive: false),
            if (picks.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                isLive ? 'Sản phẩm từ các shop' : 'Sản phẩm nổi bật',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (isLive)
                for (final product in picks) ...[
                  _LiveProductTile(
                    product: product,
                    onTap: () => _openProduct(context, product),
                  ),
                  const SizedBox(height: 10),
                ]
              else
                LayoutBuilder(
                  builder: (context, constraints) => GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: picks.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth >= 600 ? 3 : 2,
                      mainAxisExtent: 244,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      final product = picks[index];
                      return _VideoProductTile(
                        product: product,
                        onTap: () => _openProduct(context, product),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MediaNotice extends StatelessWidget {
  const _MediaNotice({required this.isLive});

  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      key: ValueKey(isLive ? 'live-empty-state' : 'video-empty-state'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            isLive ? Icons.live_tv_outlined : Icons.smart_display_outlined,
            size: 42,
            color: colors.primary,
          ),
          const SizedBox(height: 10),
          Text(
            isLive ? 'Chưa có phiên live' : 'Chưa có video mới',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 5),
          Text(
            isLive
                ? 'Khi shop bắt đầu phát trực tiếp, nội dung sẽ xuất hiện tại đây.'
                : 'Video giới thiệu sản phẩm sẽ xuất hiện tại đây.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _LiveSessionCard extends StatelessWidget {
  const _LiveSessionCard({
    required this.session,
    required this.cover,
    required this.onTap,
  });

  final DemoLiveSession session;
  final Product cover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('demo-live-${session.id}'),
        onTap: onTap,
        child: SizedBox(
          height: 190,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ProductImage(product: cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black12, Colors.black87],
                  ),
                ),
              ),
              const Center(
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  color: Colors.white70,
                  size: 52,
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC3B28),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'LIVE MẪU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.shopName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      session.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveProductTile extends StatelessWidget {
  const _LiveProductTile({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 82,
                  height: 82,
                  child: ProductImage(product: product),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.shopName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatVnd(product.price),
                      style: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(color: colors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoProductTile extends StatelessWidget {
  const _VideoProductTile({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: ProductImage(product: product)),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    formatVnd(product.price),
                    style: Theme.of(context).textTheme.labelLarge
                        ?.copyWith(color: colors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
