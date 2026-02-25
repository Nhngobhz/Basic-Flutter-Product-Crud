import 'package:flutter/material.dart';
import '../../services/category_service.dart';
import '../../style/theme.dart';
import '../../widgets/shared.dart';

class CategoryFormScreen extends StatefulWidget {
  final Category? category;
  const CategoryFormScreen({super.key, required this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  bool _loading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.category != null;
    _nameCtrl = TextEditingController(text: widget.category?.name ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      if (_isEdit) {
        await CategoryService.update(
          id: widget.category!.id,
          name: _nameCtrl.text.trim(),
        );
        if (mounted) showSnack(context, 'Category updated!', success: true);
      } else {
        await CategoryService.create(name: _nameCtrl.text.trim());
        if (mounted) showSnack(context, 'Category created!', success: true);
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
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final ts = mq.textScaleFactor;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: w * .07),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: mq.size.height * .08), // use relative spacing
              Container(
                width: w * .12,
                height: w * .12,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(w * .035),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              SizedBox(height: mq.size.height * .05),
              Text(
                'Welcome\nback.',
                style: AppTheme.headingLarge.copyWith(
                  fontSize: w * .09 * ts, // scale with width/ user font size
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Sign in to continue',
                style: TextStyle(
                  color: const Color(0xFF888888),
                  fontSize: 15 * ts,
                ),
              ),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Visual placeholder
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(bottom: 32, top: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: AppTheme.success.withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.category_rounded,
                            color: AppTheme.success,
                            size: 42,
                          ),
                        ),
                      ),
                      const Text(
                        'CATEGORY NAME',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameCtrl,
                        autofocus: true,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Enter name / ឈ្មោះប្រភេទ',
                          prefixIcon: Icon(
                            Icons.label_outline_rounded,
                            color: AppTheme.textTertiary,
                            size: 18,
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Name is required'
                            : null,
                      ),
                      const Spacer(),
                      AppButton(
                        label: _isEdit ? 'Save Changes' : 'Create Category',
                        icon: _isEdit ? Icons.save_rounded : Icons.add_rounded,
                        loading: _loading,
                        onTap: _submit,
                        width: double.infinity,
                      ),
                      const SizedBox(height: 8),
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
}
