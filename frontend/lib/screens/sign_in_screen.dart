import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFFF5555),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    // Responsive scale factors
    final hPad = w * 0.07;
    final headingSize = (w * 0.095).clamp(28.0, 48.0);
    final bodySize = (w * 0.037).clamp(13.0, 17.0);
    final labelSize = (w * 0.032).clamp(11.0, 14.0);
    final buttonHeight = (h * 0.065).clamp(46.0, 60.0);
    final fieldVertPad = (h * 0.019).clamp(12.0, 20.0);
    final topSpace = (h * 0.075).clamp(40.0, 80.0);
    final sectionGap = (h * 0.04).clamp(24.0, 52.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: topSpace),
              Container(
                width: w * 0.11,
                height: w * 0.11,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  maxWidth: 56,
                  minHeight: 36,
                  maxHeight: 56,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF),
                  borderRadius: BorderRadius.circular(w * 0.035),
                ),
                child: Icon(
                  Icons.bolt_rounded,
                  color: Colors.white,
                  size: w * 0.065,
                ),
              ),
              SizedBox(height: sectionGap),
              Text(
                'Welcome\nback.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: headingSize,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: h * 0.015),
              Text(
                'Sign in to continue',
                style: TextStyle(
                  color: const Color(0xFF888888),
                  fontSize: bodySize,
                ),
              ),
              SizedBox(height: sectionGap * 1.2),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildField(
                      context: context,
                      controller: _emailController,
                      label: 'Email',
                      hint: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      fieldVertPad: fieldVertPad,
                      labelSize: labelSize,
                      bodySize: bodySize,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    SizedBox(height: h * 0.02),
                    _buildField(
                      context: context,
                      controller: _passwordController,
                      label: 'Password',
                      hint: '••••••••',
                      obscureText: _obscurePassword,
                      fieldVertPad: fieldVertPad,
                      labelSize: labelSize,
                      bodySize: bodySize,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFF555555),
                          size: w * 0.05,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Password is required';
                        if (v.length < 6) return 'At least 6 characters';
                        return null;
                      },
                    ),
                    SizedBox(height: h * 0.015),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen(),
                          ),
                        ),
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: const Color(0xFF6C63FF),
                            fontSize: labelSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: sectionGap),
                    _buildPrimaryButton(
                      label: 'Sign In',
                      isLoading: _isLoading,
                      onTap: _signIn,
                      height: buttonHeight,
                      fontSize: bodySize,
                    ),
                  ],
                ),
              ),
              SizedBox(height: sectionGap * 0.9),
              _buildDivider(bodySize: bodySize),
              SizedBox(height: sectionGap),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: const Color(0xFF888888),
                      fontSize: bodySize - 1,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    ),
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        color: const Color(0xFF6C63FF),
                        fontSize: bodySize - 1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sectionGap),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required double fieldVertPad,
    required double labelSize,
    required double bodySize,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFFAAAAAA),
            fontSize: labelSize,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: TextStyle(color: Colors.white, fontSize: bodySize),
          decoration: _inputDecoration(
            hint,
            suffixIcon: suffixIcon,
            vertPad: fieldVertPad,
            bodySize: bodySize,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
    String hint, {
    Widget? suffixIcon,
    required double vertPad,
    required double bodySize,
  }) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: const Color(0xFF444444), fontSize: bodySize),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: const Color(0xFF161616),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFFF5555)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFFF5555)),
    ),
    errorStyle: const TextStyle(color: Color(0xFFFF5555)),
    contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: vertPad),
  );

  Widget _buildPrimaryButton({
    required String label,
    required bool isLoading,
    required VoidCallback onTap,
    required double height,
    required double fontSize,
  }) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          disabledBackgroundColor: const Color(0xFF6C63FF).withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider({required double bodySize}) => Row(
    children: [
      Expanded(child: Container(height: 1, color: const Color(0xFF1E1E1E))),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'or',
          style: TextStyle(
            color: const Color(0xFF555555),
            fontSize: bodySize - 2,
          ),
        ),
      ),
      Expanded(child: Container(height: 1, color: const Color(0xFF1E1E1E))),
    ],
  );
}
