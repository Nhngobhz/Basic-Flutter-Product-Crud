import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';
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

  int _categoryCount = 0;
  bool _loadingCategories = true;

  final ScrollController _scrollController = ScrollController();
  int _page = 1;
  bool _hasMore = true;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadFeatured();
    _loadCategoryCount();

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
      if (mounted) setState(() => _featuredProducts = products);
    } catch (_) {}

    if (mounted) setState(() => _loadingProducts = false);
  }

  Future<void> _loadCategoryCount() async {
    try {
      final categories = await CategoryService.getAll();
      if (mounted) {
        setState(() {
          _categoryCount = categories.length;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingCategories = false);
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
    if (mounted) setState(() => _loadingMore = false);
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
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
            ),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.035),
              _buildHeader(context),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              _buildStats(context),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              _buildNavGrid(context),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              _buildFeaturedProducts(context),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final bodySize = (w * 0.037).clamp(13.0, 17.0);
    final headingSize = (w * 0.06).clamp(20.0, 30.0);
    final labelSize = (w * 0.032).clamp(11.0, 14.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning 👋',
              style: AppTheme.bodySmall.copyWith(fontSize: labelSize),
            ),
            const SizedBox(height: 4),
            Text(
              'Dashboard',
              style: AppTheme.headingLarge.copyWith(fontSize: headingSize),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => _signOut(context),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: w * 0.035,
              vertical: w * 0.025,
            ),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: AppTheme.textSecondary,
                  size: w * 0.038,
                ),
                SizedBox(width: w * 0.018),
                Text(
                  'Sign Out',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: bodySize - 2,
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

  Widget _buildStats(BuildContext context) {
    return Row(
      children: [
        StatCard(
          label: 'Products',
          value: _loadingProducts ? '—' : '${_featuredProducts.length}+',
          icon: Icons.inventory_2_rounded,
          color: AppTheme.accent,
        ),
        const SizedBox(width: 12),
        StatCard(
          label: 'Categories',
          value: _loadingCategories ? '—' : '$_categoryCount',
          icon: Icons.category_rounded,
          color: AppTheme.success,
        ),
      ],
    );
  }

  Widget _buildNavGrid(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final labelSize = (w * 0.032).clamp(11.0, 14.0);
    final subLabelSize = (w * 0.027).clamp(10.0, 13.0);

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
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: w * 0.03,
            mainAxisSpacing: w * 0.03,
            childAspectRatio: (w > 400) ? 1.65 : 1.5,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => _NavCard(
            item: items[i],
            labelSize: labelSize,
            subLabelSize: subLabelSize,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProducts(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

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
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ShimmerBox(
                  width: double.infinity,
                  height: w * 0.25,
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
  final double labelSize;
  final double subLabelSize;
  const _NavCard({
    required this.item,
    required this.labelSize,
    required this.subLabelSize,
  });

  @override
  State<_NavCard> createState() => _NavCardState();
}

class _NavCardState extends State<_NavCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

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
        padding: EdgeInsets.all(w * 0.04),
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
              padding: EdgeInsets.all(w * 0.02),
              decoration: BoxDecoration(
                color: widget.item.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.item.icon,
                color: widget.item.color,
                size: w * 0.045,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.label,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: widget.labelSize,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.item.subtitle,
                  style: AppTheme.bodySmall.copyWith(
                    fontSize: widget.subLabelSize,
                  ),
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
    final w = MediaQuery.of(context).size.width;
    final imageSize = (w * 0.18).clamp(56.0, 80.0);
    final nameSize = (w * 0.037).clamp(13.0, 16.0);
    final priceSize = (w * 0.035).clamp(12.0, 15.0);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(w * 0.035),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: imageSize,
              height: imageSize,
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
            SizedBox(width: w * 0.035),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: nameSize,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: priceSize,
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
