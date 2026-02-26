import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../services/category_service.dart';
import '../../style/theme.dart';
import '../../widgets/shared.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, required this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;

  List<Category> _categories = [];
  int? _selectedCategoryId;
  bool _loading = false;
  bool _isEdit = false;

  // Image state
  File? _pickedImage;
  String? _existingImageUrl; // retained for edit mode (already-uploaded URL)
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _isEdit = widget.product != null;
    _nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    _descCtrl = TextEditingController(text: widget.product?.description ?? '');
    _priceCtrl = TextEditingController(
      text: widget.product != null
          ? widget.product!.price.toStringAsFixed(2)
          : '',
    );
    _existingImageUrl = widget.product?.imageUrl;
    _selectedCategoryId = widget.product?.categoryId;
    _loadCategories();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await CategoryService.getAll();
      if (mounted) setState(() => _categories = cats);
    } catch (_) {}
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (picked != null && mounted) {
        setState(() {
          _pickedImage = File(picked.path);
          _existingImageUrl = null; // replace existing
        });
      }
    } catch (e) {
      if (mounted) showSnack(context, 'Could not pick image: $e', error: true);
    }
  }

  void _showPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Choose Image', style: AppTheme.headingMedium),
              const SizedBox(height: 4),
              const Text(
                'Select a source for the product image',
                style: AppTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 10),
              _SheetOption(
                icon: Icons.photo_library_rounded,
                label: 'Choose from Gallery',
                subtitle: 'Browse your photos',
                color: AppTheme.success,
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_pickedImage != null || _existingImageUrl != null) ...[
                const SizedBox(height: 10),
                _SheetOption(
                  icon: Icons.delete_outline_rounded,
                  label: 'Remove Image',
                  subtitle: 'Clear the current image',
                  color: AppTheme.danger,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _pickedImage = null;
                      _existingImageUrl = null;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      if (_isEdit) {
        await ProductService.update(
          id: widget.product!.id,
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          categoryId: _selectedCategoryId,
          price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
          imageFile: _pickedImage,
          removeImage: _existingImageUrl == null && _pickedImage == null,
        );
        if (mounted) showSnack(context, 'Product updated!', success: true);
      } else {
        await ProductService.create(
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          categoryId: _selectedCategoryId,
          price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
          imageFile: _pickedImage,
        );
        if (mounted) showSnack(context, 'Product created!', success: true);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showSnack(context, e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImagePicker(),
                      const SizedBox(height: 24),
                      _label('Product Name *'),
                      const SizedBox(height: 8),
                      _buildField(
                        controller: _nameCtrl,
                        hint: 'Enter product name / ឈ្មោះផលិតផល',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      _label('Price *'),
                      const SizedBox(height: 8),
                      _buildField(
                        controller: _priceCtrl,
                        hint: '0.00',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        prefixText: '\$',
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return 'Price is required';
                          if (double.tryParse(v) == null)
                            return 'Enter a valid price';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _label('Category'),
                      const SizedBox(height: 8),
                      _buildCategoryDropdown(),
                      const SizedBox(height: 16),
                      _label('Description'),
                      const SizedBox(height: 8),
                      _buildField(
                        controller: _descCtrl,
                        hint: 'Optional description / ការពិពណ៌នា',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        label: _isEdit ? 'Save Changes' : 'Create Product',
                        icon: _isEdit ? Icons.save_rounded : Icons.add_rounded,
                        loading: _loading,
                        onTap: _submit,
                        width: double.infinity,
                      ),
                    ],
                  ),
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
          Text(
            _isEdit ? 'Edit Product' : 'New Product',
            style: AppTheme.headingLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    final hasImage = _pickedImage != null || _existingImageUrl != null;

    return GestureDetector(
      onTap: _showPickerSheet,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage
                ? AppTheme.accent.withOpacity(0.4)
                : AppTheme.border,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image or placeholder
              if (_pickedImage != null)
                Image.file(_pickedImage!, fit: BoxFit.cover)
              else if (_existingImageUrl != null)
                Image.network(
                  _existingImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _EmptyImageSlot(),
                )
              else
                const _EmptyImageSlot(),

              // "Change" badge overlay when image is present
              if (hasImage)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_rounded, color: Colors.white, size: 13),
                        SizedBox(width: 5),
                        Text(
                          'Change',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final seen = <int>{};
    final items = <DropdownMenuItem<int?>>[];

    for (var c in _categories) {
      if (seen.add(c.id)) {
        items.add(DropdownMenuItem<int?>(value: c.id, child: Text(c.name)));
      }
    }

    int? dropdownValue = _selectedCategoryId;
    if (dropdownValue != null &&
        !items.any((item) => item.value == dropdownValue)) {
      dropdownValue = null;
    }

    return DropdownButtonFormField<int?>(
      value: dropdownValue,
      dropdownColor: AppTheme.card,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      hint: const Text(
        'Select category',
        style: TextStyle(color: AppTheme.textTertiary, fontSize: 14),
      ),
      items: items,
      onChanged: (v) => setState(() => _selectedCategoryId = v),
      validator: (value) {
        if (value == null) {
          return 'Please select a category';
        }
        return null;
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.accent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.danger),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? prefixText,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefixText,
        prefixStyle: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 14,
        ),
      ),
    );
  }
}

// ─── Empty Image Slot ─────────────────────────────────────────────────────────

class _EmptyImageSlot extends StatelessWidget {
  const _EmptyImageSlot();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.accentDim,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.add_photo_alternate_rounded,
            color: AppTheme.accent,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Tap to add image',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Camera or gallery',
          style: TextStyle(color: AppTheme.textTertiary, fontSize: 12),
        ),
      ],
    );
  }
}

// ─── Bottom Sheet Option Row ──────────────────────────────────────────────────

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTheme.bodySmall.copyWith(fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textTertiary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
