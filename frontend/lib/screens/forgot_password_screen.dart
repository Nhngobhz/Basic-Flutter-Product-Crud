import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'otp_reset_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await AuthService.forgotPassword(email: _emailController.text.trim());
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OtpResetScreen(email: _emailController.text.trim()),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: const Color(0xFFFF5555),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
    final iconSize = (w * 0.14).clamp(44.0, 64.0);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Padding(
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
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(iconSize * 0.32),
                ),
                child: Icon(
                  Icons.lock_reset_rounded,
                  color: const Color(0xFF6C63FF),
                  size: iconSize * 0.5,
                ),
              ),
              SizedBox(height: sectionGap * 0.7),
              Text(
                'Reset\npassword.',
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
                "Enter your email and we'll send you a code to reset your password.",
                style: TextStyle(
                  color: const Color(0xFF888888),
                  fontSize: bodySize,
                  height: 1.5,
                ),
              ),
              SizedBox(height: sectionGap * 1.2),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email',
                      style: TextStyle(
                        color: const Color(0xFFAAAAAA),
                        fontSize: labelSize,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                      style: TextStyle(color: Colors.white, fontSize: bodySize),
                      decoration: InputDecoration(
                        hintText: 'you@example.com',
                        hintStyle: TextStyle(
                          color: const Color(0xFF444444),
                          fontSize: bodySize,
                        ),
                        prefixIcon: Icon(
                          Icons.mail_outline_rounded,
                          color: const Color(0xFF444444),
                          size: w * 0.05,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF161616),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF2A2A2A),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF2A2A2A),
                          ),
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
                          borderSide: const BorderSide(
                            color: Color(0xFFFF5555),
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF5555),
                          ),
                        ),
                        errorStyle: const TextStyle(color: Color(0xFFFF5555)),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: fieldVertPad,
                        ),
                      ),
                    ),
                    SizedBox(height: sectionGap),
                    SizedBox(
                      width: double.infinity,
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          disabledBackgroundColor: const Color(
                            0xFF6C63FF,
                          ).withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Send Reset Code',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: bodySize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: h * 0.04),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Remember your password? ',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
