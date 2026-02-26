import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      _showSnack(
        'Please agree to the terms',
        const Color.fromARGB(255, 255, 255, 255),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await AuthService.signup(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      _showSnack('Account created! Welcome.', const Color(0xFF6C63FF));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnack(e.message, const Color(0xFFFF5555));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
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

    final hPad = w * 0.07;
    final headingSize = (w * 0.095).clamp(28.0, 48.0);
    final bodySize = (w * 0.037).clamp(13.0, 17.0);
    final labelSize = (w * 0.032).clamp(11.0, 14.0);
    final buttonHeight = (h * 0.065).clamp(46.0, 60.0);
    final fieldVertPad = (h * 0.019).clamp(12.0, 20.0);
    final topSpace = (h * 0.03).clamp(16.0, 36.0);
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
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: w * 0.1,
                  height: w * 0.1,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    maxWidth: 48,
                    minHeight: 36,
                    maxHeight: 48,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161616),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: w * 0.04,
                  ),
                ),
              ),
              SizedBox(height: sectionGap * 0.9),
              Text(
                'Create\naccount.',
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
                'Join us today',
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
                      controller: _usernameController,
                      label: 'Username',
                      hint: 'johndoe',
                      prefixIcon: Icons.alternate_email_rounded,
                      fieldVertPad: fieldVertPad,
                      labelSize: labelSize,
                      bodySize: bodySize,
                      w: w,
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Username is required';
                        if (v.length < 3) return 'At least 3 characters';
                        if (v.contains(' ')) return 'No spaces allowed';
                        return null;
                      },
                    ),
                    SizedBox(height: h * 0.02),
                    _buildField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'you@example.com',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      fieldVertPad: fieldVertPad,
                      labelSize: labelSize,
                      bodySize: bodySize,
                      w: w,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    SizedBox(height: h * 0.02),
                    _buildField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      fieldVertPad: fieldVertPad,
                      labelSize: labelSize,
                      bodySize: bodySize,
                      w: w,
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
                        if (v.length < 8) return 'At least 8 characters';
                        return null;
                      },
                    ),
                    SizedBox(height: h * 0.01),
                    _buildPasswordStrength(_passwordController.text),
                    SizedBox(height: h * 0.025),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              setState(() => _agreedToTerms = !_agreedToTerms),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: w * 0.055,
                            height: w * 0.055,
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              maxWidth: 26,
                              minHeight: 20,
                              maxHeight: 26,
                            ),
                            decoration: BoxDecoration(
                              color: _agreedToTerms
                                  ? const Color(0xFF6C63FF)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _agreedToTerms
                                    ? const Color(0xFF6C63FF)
                                    : const Color(0xFF2A2A2A),
                                width: 1.5,
                              ),
                            ),
                            child: _agreedToTerms
                                ? Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: w * 0.035,
                                  )
                                : null,
                          ),
                        ),
                        SizedBox(width: w * 0.03),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'I agree to the ',
                              style: TextStyle(
                                color: const Color(0xFF888888),
                                fontSize: labelSize,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: const Color(0xFF6C63FF),
                                    fontSize: labelSize,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: const Color(0xFF6C63FF),
                                    fontSize: labelSize,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sectionGap),
                    _buildPrimaryButton(
                      label: 'Create Account',
                      isLoading: _isLoading,
                      onTap: _signUp,
                      height: buttonHeight,
                      fontSize: bodySize,
                    ),
                  ],
                ),
              ),
              SizedBox(height: sectionGap),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: const Color(0xFF888888),
                      fontSize: bodySize - 1,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Sign in',
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

  Widget _buildPasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*]'))) strength++;

    final colors = [
      const Color(0xFF333333),
      const Color(0xFFFF5555),
      const Color(0xFFFFAA33),
      const Color(0xFF33AAFF),
      const Color(0xFF33FF99),
    ];
    final labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
    final w = MediaQuery.of(context).size.width;
    final labelSize = (w * 0.028).clamp(10.0, 13.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(
            4,
            (i) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                height: 3,
                decoration: BoxDecoration(
                  color: i < strength
                      ? colors[strength]
                      : const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        if (password.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            labels[strength],
            style: TextStyle(
              color: colors[strength],
              fontSize: labelSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required double fieldVertPad,
    required double labelSize,
    required double bodySize,
    required double w,
    IconData? prefixIcon,
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
          onChanged: (v) {
            if (label == 'Password') setState(() {});
          },
          style: TextStyle(color: Colors.white, fontSize: bodySize),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: const Color(0xFF444444),
              fontSize: bodySize,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: const Color(0xFF444444),
                    size: w * 0.05,
                  )
                : null,
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
              borderSide: const BorderSide(
                color: Color(0xFF6C63FF),
                width: 1.5,
              ),
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
            contentPadding: EdgeInsets.symmetric(
              horizontal: 18,
              vertical: fieldVertPad,
            ),
          ),
        ),
      ],
    );
  }

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
}
