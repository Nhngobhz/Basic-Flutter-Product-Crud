import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/category_service.dart';
import '../../style/theme.dart';
import '../../widgets/shared.dart';
import 'category_form_screen.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  List<Category> _categories = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final cats = await CategoryService.getAll(
        search: _searchCtrl.text.trim(),
      );
      if (mounted) setState(() => _categories = cats);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearch(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _load);
  }

  Future<void> _delete(Category cat) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete Category',
      message:
          'Are you sure you want to delete "${cat.name}"? Products in this category may be affected.',
    );
    if (confirm != true || !mounted) return;
    try {
      await CategoryService.delete(cat.id);
      showSnack(context, '"${cat.name}" deleted', success: true);
      _load();
    } catch (e) {
      showSnack(context, e.toString(), error: true);
    }
  }

  Future<void> _openForm([Category? cat]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CategoryFormScreen(category: cat)),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: AppSearchBar(
                controller: _searchCtrl,
                hint: 'Search categories... / ស្វែងរកប្រភេទ',
                onChanged: _onSearch,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () => _openForm(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.success,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.success.withOpacity(0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Add Category',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          Expanded(child: Text('Categories', style: AppTheme.headingLarge)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.success.withOpacity(0.3)),
            ),
            child: Text(
              '${_categories.length}',
              style: const TextStyle(
                color: AppTheme.success,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) =>
            const ShimmerBox(width: double.infinity, height: 64, radius: 14),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppTheme.danger,
                size: 40,
              ),
              const SizedBox(height: 16),
              Text(
                _error,
                style: AppTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(label: 'Retry', onTap: _load),
            ],
          ),
        ),
      );
    }

    if (_categories.isEmpty) {
      return EmptyState(
        icon: Icons.category_rounded,
        title: 'No Categories',
        subtitle: 'Create your first category to organize products',
        actionLabel: 'Add Category',
        onAction: () => _openForm(),
      );
    }

    return RefreshIndicator(
      color: AppTheme.accent,
      backgroundColor: AppTheme.card,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _CategoryTile(
          category: _categories[i],
          onEdit: () => _openForm(_categories[i]),
          onDelete: () => _delete(_categories[i]),
        ),
      ),
    );
  }
}

// ─── Category Tile ────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.label_rounded,
              color: AppTheme.success,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.name, style: AppTheme.bodyMedium),
                Text(
                  'ID: ${category.id}',
                  style: AppTheme.labelSmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _IconBtn(
                icon: Icons.edit_rounded,
                color: AppTheme.accent,
                onTap: onEdit,
              ),
              const SizedBox(width: 8),
              _IconBtn(
                icon: Icons.delete_rounded,
                color: AppTheme.danger,
                onTap: onDelete,
              ),
            ],
          ),
        ],
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 15),
      ),
    );
  }
}
