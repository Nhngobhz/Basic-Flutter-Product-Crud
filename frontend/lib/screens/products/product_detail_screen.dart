import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../services/category_service.dart';
import '../../style/theme.dart';
import '../../widgets/shared.dart';
import 'product_form_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _product;
  String _categoryName = '';

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _loadCategory();
  }

  Future<void> _loadCategory() async {
    if (_product.categoryId == null) return;
    try {
      final cat = await CategoryService.getById(_product.categoryId!);
      if (mounted) setState(() => _categoryName = cat.name);
    } catch (_) {}
  }

  Future<void> _delete() async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete Product',
      message: 'Are you sure you want to delete "${_product.name}"?',
    );
    if (confirm != true || !mounted) return;
    try {
      await ProductService.delete(_product.id);
      if (mounted) {
        showSnack(context, 'Product deleted', success: true);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(),
                    const SizedBox(height: 24),
                    _buildInfoCard(),
                    const SizedBox(height: 24),
                    _buildActions(),
                  ],
                ),
              ),
            ),
          ],
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
          const Expanded(
            child: Text('Product Detail', style: AppTheme.headingLarge),
          ),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductFormScreen(product: _product),
                ),
              );
              if (result == true) Navigator.pop(context, true);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accentDim,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: AppTheme.accent,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: _product.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                _product.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _NoImage(),
              ),
            )
          : const _NoImage(),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(_product.name, style: AppTheme.headingLarge),
              ),
              const SizedBox(width: 12),
              Text(
                '\$${_product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          if (_categoryName.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.successDim,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.success.withOpacity(0.3)),
              ),
              child: Text(
                _categoryName,
                style: const TextStyle(
                  color: AppTheme.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          if (_product.description != null &&
              _product.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: AppTheme.border, height: 1),
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _product.description!,
              style: AppTheme.bodySmall.copyWith(height: 1.6),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(color: AppTheme.border, height: 1),
          const SizedBox(height: 16),
          _infoRow('Product ID', '#${_product.id}'),
          const SizedBox(height: 8),
          _infoRow(
            'Category ID',
            _product.categoryId?.toString() ?? 'Uncategorized',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.bodySmall),
        Text(
          value,
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textPrimary),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: 'Edit Product',
            icon: Icons.edit_rounded,
            outlined: true,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductFormScreen(product: _product),
                ),
              );
              if (result == true && mounted) Navigator.pop(context, true);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppButton(
            label: 'Delete',
            icon: Icons.delete_rounded,
            danger: true,
            onTap: _delete,
          ),
        ),
      ],
    );
  }
}

class _NoImage extends StatelessWidget {
  const _NoImage();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.image_not_supported_rounded,
          color: AppTheme.textTertiary,
          size: 40,
        ),
        SizedBox(height: 8),
        Text('No image', style: TextStyle(color: AppTheme.textTertiary)),
      ],
    );
  }
}
