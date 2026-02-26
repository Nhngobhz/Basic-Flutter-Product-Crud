import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../services/category_service.dart';
import '../../style/theme.dart';
import '../../widgets/shared.dart';
import 'product_form_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  List<Product> _products = [];
  List<Category> _categories = [];
  bool _loading = true;
  bool _loadingMore = false;
  String _error = '';

  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;

  String _sortBy = 'name';
  int? _selectedCategoryId;
  double _minPrice = 0;
  double _maxPrice = 100;
  bool _showFilters = false;

  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _load(reset: true);
    _loadCategories();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await CategoryService.getAll();
      if (mounted) setState(() => _categories = cats);
    } catch (_) {}
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _page = 1;
        _hasMore = true;
        _products = [];
        _error = '';
      });
    }

    try {
      final results = await ProductService.getAll(
        page: _page,
        limit: _limit,
        search: _searchCtrl.text.trim(),
        sortBy: _sortBy,
      );

      final filtered = results.where((p) {
        final inCategory =
            _selectedCategoryId == null || p.categoryId == _selectedCategoryId;
        final inPrice = p.price >= _minPrice && p.price <= _maxPrice;
        return inCategory && inPrice;
      }).toList();

      if (mounted) {
        setState(() {
          if (reset) {
            _products = filtered;
          } else {
            _products.addAll(filtered);
          }
          _hasMore = results.length == _limit;
          _loading = false;
          _loadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
          _loadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    setState(() {
      _loadingMore = true;
      _page++;
    });
    await _load();
  }

  void _onSearchChanged(String val) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _load(reset: true);
    });
  }

  Future<void> _deleteProduct(Product p) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete Product',
      message:
          'Are you sure you want to delete "${p.name}"? This cannot be undone.',
    );
    if (confirm != true || !mounted) return;
    try {
      await ProductService.delete(p.id);
      showSnack(context, '"${p.name}" deleted', success: true);
      _load(reset: true);
    } catch (e) {
      showSnack(context, e.toString(), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildSearchAndFilter(),
            if (_showFilters) _buildFilterPanel(),
            _buildSortBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      floatingActionButton: _buildFab(),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textSecondary,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text('Products', style: AppTheme.headingLarge)),
          _badge('${_products.length}'),
        ],
      ),
    );
  }

  Widget _badge(String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.accentDim,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      child: Text(
        count,
        style: const TextStyle(
          color: AppTheme.accent,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: AppSearchBar(
              controller: _searchCtrl,
              hint: 'Search... / ស្វែងរក...',
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => setState(() => _showFilters = !_showFilters),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _showFilters ? AppTheme.accentDim : AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _showFilters ? AppTheme.accent : AppTheme.border,
                ),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: _showFilters ? AppTheme.accent : AppTheme.textSecondary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category filter
            const Text(
              'Category',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  FilterChipWidget(
                    label: 'All',
                    selected: _selectedCategoryId == null,
                    onTap: () {
                      setState(() => _selectedCategoryId = null);
                      _load(reset: true);
                    },
                  ),
                  ..._categories.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: FilterChipWidget(
                        label: c.name,
                        selected: _selectedCategoryId == c.id,
                        onTap: () {
                          setState(() => _selectedCategoryId = c.id);
                          _load(reset: true);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Price range
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Price Range',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '\$${_minPrice.toStringAsFixed(0)} – \$${_maxPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: RangeValues(_minPrice, _maxPrice),
              min: 0,
              max: 100,
              activeColor: AppTheme.accent,
              inactiveColor: AppTheme.border,
              onChanged: (v) => setState(() {
                _minPrice = v.start;
                _maxPrice = v.end;
              }),
              onChangeEnd: (_) => _load(reset: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          const Text(
            'Sort:',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(width: 8),
          FilterChipWidget(
            label: 'Name',
            selected: _sortBy == 'name',
            onTap: () {
              setState(() => _sortBy = 'name');
              _load(reset: true);
            },
          ),
          const SizedBox(width: 8),
          FilterChipWidget(
            label: 'Price ↑',
            selected: _sortBy == 'price_asc',
            onTap: () {
              setState(() => _sortBy = 'price_asc');
              _load(reset: true);
            },
          ),
          const SizedBox(width: 8),
          FilterChipWidget(
            label: 'Price ↓',
            selected: _sortBy == 'price_desc',
            onTap: () {
              setState(() => _sortBy = 'price_desc');
              _load(reset: true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) return _buildLoadingSkeleton();
    if (_error.isNotEmpty) return _buildError();
    if (_products.isEmpty) {
      return EmptyState(
        icon: Icons.inventory_2_rounded,
        title: 'No Products Found',
        subtitle: 'Try adjusting your search or filters',
        actionLabel: 'Add Product',
        onAction: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProductFormScreen(product: null),
            ),
          );
          _load(reset: true);
        },
      );
    }

    return ListView.separated(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: _products.length + (_loadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        if (i == _products.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: AppTheme.accent,
                strokeWidth: 2,
              ),
            ),
          );
        }
        return _ProductTile(
          product: _products[i],
          categories: _categories,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: _products[i]),
              ),
            );
            _load(reset: true);
          },
          onEdit: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductFormScreen(product: _products[i]),
              ),
            );
            _load(reset: true);
          },
          onDelete: () => _deleteProduct(_products[i]),
        );
      },
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => Container(
        height: 80,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            const ShimmerBox(width: 48, height: 48, radius: 12),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShimmerBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 14,
                  ),
                  const SizedBox(height: 8),
                  const ShimmerBox(width: 80, height: 12),
                ],
              ),
            ),
            const ShimmerBox(width: 60, height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.dangerDim,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppTheme.danger,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text('Failed to load products', style: AppTheme.headingMedium),
            const SizedBox(height: 8),
            Text(
              _error,
              style: AppTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(label: 'Retry', onTap: () => _load(reset: true)),
          ],
        ),
      ),
    );
  }

  Widget _buildFab() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProductFormScreen(product: null),
          ),
        );
        _load(reset: true);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentGlow,
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Add Product',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Product Tile ─────────────────────────────────────────────────────────────

class _ProductTile extends StatelessWidget {
  final Product product;
  final List<Category> categories;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductTile({
    required this.product,
    required this.categories,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  String get _categoryName {
    if (product.categoryId == null) return 'Uncategorized';
    final cat = categories.where((c) => c.id == product.categoryId).firstOrNull;
    return cat?.name ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            // Image / Icon
            Container(
              width: 52,
              height: 52,
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
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image_rounded,
                          color: AppTheme.textTertiary,
                          size: 22,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.inventory_2_rounded,
                      color: AppTheme.accent,
                      size: 22,
                    ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Text(
                          _categoryName,
                          style: AppTheme.labelSmall.copyWith(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Price + Actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.accent,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _IconBtn(
                      icon: Icons.edit_rounded,
                      color: AppTheme.accent,
                      onTap: onEdit,
                    ),
                    const SizedBox(width: 6),
                    _IconBtn(
                      icon: Icons.delete_rounded,
                      color: AppTheme.danger,
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 14),
      ),
    );
  }
}
