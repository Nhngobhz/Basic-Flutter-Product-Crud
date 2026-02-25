import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '/style/theme.dart';
import '../widgets/shared.dart';
import 'sign_in_screen.dart';
import 'products/product_list_screen.dart';
import 'categories/category_list_screen.dart';
import 'products/product_form_screen.dart';
import 'categories/category_form_screen.dart';
import 'products/product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _featuredProducts = [];
  bool _loadingProducts = true;
  final ScrollController _scrollController = ScrollController();
  int _page = 1;
  bool _hasMore = true;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadFeatured();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_loadingMore &&
          _hasMore) {
        _loadMore();
      }
    });
  }

  Future<void> _loadFeatured() async {
    _page = 1;
    _hasMore = true;

    try {
      final products = await ProductService.getAll(
        page: _page,
        limit: 6,
        sortBy: 'name',
      );

      if (mounted) {
        setState(() {
          _featuredProducts = products;
        });
      }
    } catch (_) {}

    if (mounted) setState(() => _loadingProducts = false);
  }

  Future<void> _loadMore() async {
    if (!_hasMore) return;

    setState(() => _loadingMore = true);

    _page++;

    try {
      final more = await ProductService.getAll(
        page: _page,
        limit: 6,
        sortBy: 'name',
      );

      if (more.isEmpty) {
        _hasMore = false;
      } else {
        _featuredProducts.addAll(more);
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _loadingMore = false);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await AuthService.logout();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.accent,
          backgroundColor: AppTheme.card,
          onRefresh: _loadFeatured,
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 28),
              _buildHeader(),
              const SizedBox(height: 32),
              _buildStats(),
              const SizedBox(height: 32),
              _buildNavGrid(),
              const SizedBox(height: 32),
              _buildFeaturedProducts(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning 👋',
              style: AppTheme.bodySmall.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text('Dashboard', style: AppTheme.headingLarge),
          ],
        ),
        GestureDetector(
          onTap: () => _signOut(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: AppTheme.textSecondary,
                  size: 15,
                ),
                SizedBox(width: 7),
                Text(
                  'Sign Out',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        StatCard(
          label: 'Products',
          value: _loadingProducts ? '—' : '${_featuredProducts.length}+',
          icon: Icons.inventory_2_rounded,
          color: AppTheme.accent,
        ),
        const SizedBox(width: 12),
        const StatCard(
          label: 'Categories',
          value: '—',
          icon: Icons.category_rounded,
          color: AppTheme.success,
        ),
      ],
    );
  }

  Widget _buildNavGrid() {
    final items = [
      _NavItem(
        label: 'Products',
        subtitle: 'Manage inventory',
        icon: Icons.inventory_2_rounded,
        color: AppTheme.accent,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductListScreen()),
        ),
      ),
      _NavItem(
        label: 'Categories',
        subtitle: 'Organize items',
        icon: Icons.category_rounded,
        color: AppTheme.success,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CategoryListScreen()),
        ),
      ),
      _NavItem(
        label: 'Add Product',
        subtitle: 'Quick add',
        icon: Icons.add_box_rounded,
        color: AppTheme.warning,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProductFormScreen(product: null),
          ),
        ),
      ),
      _NavItem(
        label: 'Add Category',
        subtitle: 'New category',
        icon: Icons.create_new_folder_rounded,
        color: const Color(0xFFEC4899),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CategoryFormScreen(category: null),
          ),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Quick Actions'),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => _NavCard(item: items[i]),
        ),
      ],
    );
  }

  Widget _buildFeaturedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Product Showcase',
          action: 'See all',
          onAction: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductListScreen()),
          ),
        ),
        const SizedBox(height: 16),

        if (_loadingProducts)
          Column(
            children: List.generate(
              4,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: ShimmerBox(
                  width: double.infinity,
                  height: 100,
                  radius: 16,
                ),
              ),
            ),
          )
        else if (_featuredProducts.isEmpty)
          EmptyState(
            icon: Icons.inventory_2_rounded,
            title: 'No Products Yet',
            subtitle: 'Add your first product to see it showcased here',
            actionLabel: 'Add Product',
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProductFormScreen(product: null),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _featuredProducts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) =>
                _VerticalProductCard(product: _featuredProducts[i]),
          ),
      ],
    );
  }
}

// ─── Nav Item Model ───────────────────────────────────────────────────────────

class _NavItem {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _NavItem({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

// ─── Nav Card ─────────────────────────────────────────────────────────────────

class _NavCard extends StatefulWidget {
  final _NavItem item;
  const _NavCard({required this.item});

  @override
  State<_NavCard> createState() => _NavCardState();
}

class _NavCardState extends State<_NavCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.item.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _pressed ? widget.item.color : AppTheme.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.item.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(widget.item.icon, color: widget.item.color, size: 18),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.label,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.item.subtitle,
                  style: AppTheme.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Product Showcase Card ────────────────────────────────────────────────────

class _VerticalProductCard extends StatelessWidget {
  final Product product;
  const _VerticalProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppTheme.accentDim,
                borderRadius: BorderRadius.circular(12),
              ),
              child: product.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.inventory_2_rounded),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w700,
                    ),
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
